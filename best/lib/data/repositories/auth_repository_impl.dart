import 'package:best/data/models/user_model.dart';
import 'package:best/domain/entities/user_entity.dart';
import 'package:best/domain/repositories/auth_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabaseClient;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl({
    required SupabaseClient supabaseClient,
    required GoogleSignIn googleSignIn,
  })  : _supabaseClient = supabaseClient,
        _googleSignIn = googleSignIn;

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      // Step 1: Sign up the user with Supabase Auth - disable email confirmation
      final authResponse = await _supabaseClient.auth.signUp(
          email: email,
          password: password,
          emailRedirectTo: null, // Disable email verification redirection
          data: {'full_name': fullName, 'phone_number': phoneNumber});

      if (authResponse.user == null) {
        throw Exception('Failed to create user');
      }

      // Step 2: Insert profile data
      try {
        await _supabaseClient.from('profiles').insert({
          'id': authResponse.user!.id,
          'full_name': fullName,
          'email': email,
          'phone_number': phoneNumber,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (profileError) {
        print('Profile creation attempted but may have failed: $profileError');
        // Continue anyway since the user was created in auth
      }

      // Step 3: Send welcome email
      _sendWelcomeEmail(email, fullName);

      // Return the created user entity
      return UserModel(
        id: authResponse.user!.id,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  // Send a welcome email to the user
  Future<void> _sendWelcomeEmail(String email, String fullName) async {
    try {
      // This is a simplified example. In a real app, you'd use a proper email service
      // For Supabase, you might use Edge Functions or a separate email service API

      // For now, we'll just print to console that we would send an email
      print('Sending welcome email to $email');

      // Example of how you might call a Supabase Edge Function to send an email
      // await _supabaseClient.functions.invoke('send-welcome-email', {
      //   'email': email,
      //   'fullName': fullName,
      //   'subject': 'Welcome to Goldmine Properties!',
      //   'message': 'Thank you for joining Goldmine Properties! We\'re excited to help you find your perfect property.',
      // });
    } catch (e) {
      print('Failed to send welcome email: ${e.toString()}');
      // Don't throw an exception here - we don't want to fail the signup if the email fails
    }
  }

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with Supabase
      final authResponse = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Login failed');
      }

      // Try to fetch user profile data
      try {
        final userData = await _supabaseClient
            .from('profiles')
            .select()
            .eq('id', authResponse.user!.id)
            .single();

        return UserModel.fromJson(userData);
      } catch (e) {
        // Profile might not exist yet (if email verification was required)
        // Try to create it now
        print(
            'Profile not found, attempting to create it now: ${e.toString()}');

        await _supabaseClient.from('profiles').insert({
          'id': authResponse.user!.id,
          'full_name':
              authResponse.user!.email!.split('@')[0], // Use email as temp name
          'email': authResponse.user!.email!,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        // Fetch the newly created profile
        final userData = await _supabaseClient
            .from('profiles')
            .select()
            .eq('id', authResponse.user!.id)
            .single();

        return UserModel.fromJson(userData);
      }
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      // Sign in with Google
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      final googleAuth = await googleUser.authentication;

      // Sign in with Supabase using Google token
      final authResponse = await _supabaseClient.auth.signInWithIdToken(
        provider: Provider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      if (authResponse.user == null) {
        throw Exception('Failed to sign in with Google');
      }

      // Check if profile exists
      final data = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', authResponse.user!.id)
          .maybeSingle();

      // Create profile if not exists
      if (data == null) {
        await _supabaseClient.from('profiles').insert({
          'id': authResponse.user!.id,
          'full_name': googleUser.displayName ?? '',
          'email': googleUser.email,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        return UserModel(
          id: authResponse.user!.id,
          fullName: googleUser.displayName ?? '',
          email: googleUser.email,
          createdAt: DateTime.now(),
        );
      }

      return UserModel.fromJson(data);
    } catch (e) {
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser == null) {
        return null;
      }

      final userData = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', currentUser.id)
          .maybeSingle();

      if (userData == null) {
        return null;
      }

      return UserModel.fromJson(userData);
    } catch (e) {
      throw Exception('Get current user failed: ${e.toString()}');
    }
  }
}
