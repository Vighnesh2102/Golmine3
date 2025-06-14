import 'package:best/domain/entities/user_entity.dart';
import 'package:best/domain/usecases/google_sign_in_usecase.dart';
import 'package:best/domain/usecases/reset_password_usecase.dart';
import 'package:best/domain/usecases/sign_in_usecase.dart';
import 'package:best/domain/usecases/sign_up_usecase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final SignUpUseCase signUpUseCase;
  final SignInUseCase signInUseCase;
  final GoogleSignInUseCase googleSignInUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  AuthController({
    required this.signUpUseCase,
    required this.signInUseCase,
    required this.googleSignInUseCase,
    required this.resetPasswordUseCase,
  });

  final isLoading = false.obs;
  final currentUser = Rxn<UserEntity>();

  // Sign up a new user
  Future<String> signUp({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    try {
      final user = await signUpUseCase.execute(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );

      currentUser.value = user;
      isLoading.value = false;
      return "Success";
    } catch (e) {
      isLoading.value = false;
      return e.toString();
    }
  }

  // Sign in an existing user
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    try {
      final user = await signInUseCase.execute(
        email: email,
        password: password,
      );

      currentUser.value = user;
      isLoading.value = false;
      return "Success";
    } catch (e) {
      isLoading.value = false;
      return e.toString();
    }
  }

  // Sign in with Google
  Future<String> signInWithGoogle() async {
    isLoading.value = true;
    try {
      final user = await googleSignInUseCase.execute();

      currentUser.value = user;
      isLoading.value = false;
      return "Success";
    } catch (e) {
      isLoading.value = false;
      return e.toString();
    }
  }

  // Reset password
  Future<String> resetPassword({required String email}) async {
    isLoading.value = true;
    try {
      await resetPasswordUseCase.execute(email: email);
      isLoading.value = false;
      return "Success";
    } catch (e) {
      isLoading.value = false;
      return e.toString();
    }
  }

  // Show error snackbar
  void showError(String message) {
    Get.snackbar(
      "Error",
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Show success snackbar
  void showSuccess(String message) {
    Get.snackbar(
      "Success",
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
