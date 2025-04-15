import 'package:flutter/material.dart';
import 'package:best/widgets/bottom_nav_bar.dart';
import 'privacy_policy_page.dart';
import 'faq_support_page.dart';
import 'filter_page.dart';
import 'forgot_password.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = true;
  bool _isEditing = false;
  String? _userId;
  String? _avatarUrl;
  File? _localImageFile;

  // Session management constants
  static const String _lastLoginKey = 'last_login_time';
  static const String _localImagePathKey = 'local_image_path';
  static const Duration _sessionTimeout = Duration(days: 30); // 1 month timeout
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _checkSessionValidity();
    _loadUserProfile();
  }

  Future<void> _checkSessionValidity() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLoginTimeString = prefs.getString(_lastLoginKey);

    if (lastLoginTimeString != null) {
      final lastLoginTime = DateTime.parse(lastLoginTimeString);
      final currentTime = DateTime.now();
      final difference = currentTime.difference(lastLoginTime);

      // Check if session is expired (more than 1 month)
      if (difference > _sessionTimeout) {
        // Auto logout
        _signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your session has expired. Please sign in again.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }

    // Update last login time
    await prefs.setString(_lastLoginKey, DateTime.now().toIso8601String());
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user
      final User? user = _supabase.auth.currentUser;

      if (user == null) {
        // No user is logged in, navigate to login
        Get.offAllNamed('/login');
        return;
      }

      _userId = user.id;

      // Fetch profile data from database
      final userData = await _supabase
          .from('profiles')
          .select('full_name, email, phone_number, avatar_url')
          .eq('id', user.id)
          .single();

      setState(() {
        _fullNameController.text = userData['full_name'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _phoneController.text = userData['phone_number'] ?? '';
        _avatarUrl = userData['avatar_url'];
      });

      // Check for local image
      await _loadLocalImage();

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      print('Error loading profile: $error');

      // Handle case where profile might not exist yet
      final User? user = _supabase.auth.currentUser;
      if (user != null) {
        setState(() {
          _fullNameController.text = '';
          _emailController.text = user.email ?? '';
          _phoneController.text = '';
          _isLoading = false;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load profile: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadLocalImage() async {
    final prefs = await SharedPreferences.getInstance();
    final localImagePath = prefs.getString('${_userId}_$_localImagePathKey');

    if (localImagePath != null) {
      final file = File(localImagePath);
      if (await file.exists()) {
        setState(() {
          _localImageFile = file;
        });
      }
    }
  }

  Future<void> _pickAndSaveImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      // Get app's local directory
      final directory = await getApplicationDocumentsDirectory();

      // Create a unique filename with user ID
      final fileName =
          '${_userId}_profile_${DateTime.now().millisecondsSinceEpoch}${path.extension(pickedFile.path)}';
      final localPath = path.join(directory.path, fileName);

      // Copy the picked image to the app's local directory
      final File newImage = await File(pickedFile.path).copy(localPath);

      // Save the path to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${_userId}_$_localImagePathKey', localPath);

      setState(() {
        _localImageFile = newImage;
        _isUploading = true;
      });

      // Upload to Supabase storage
      await _uploadImageToSupabase(newImage);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture updated'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile picture: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadImageToSupabase(File imageFile) async {
    try {
      if (_userId == null) return;

      final fileExt = path.extension(imageFile.path);
      final fileName = const Uuid().v4() + fileExt;
      final filePath = 'user_avatars/$_userId/$fileName';

      // Read file as bytes to avoid File type conflicts
      final fileBytes = await imageFile.readAsBytes();

      // Upload file to Supabase Storage using bytes instead of File
      final response = await _supabase.storage
          .from('avatars')
          .uploadBinary(filePath, fileBytes,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ));

      // Get public URL for the uploaded file
      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(filePath);

      // Update profile with new avatar URL
      await _supabase.from('profiles').update({
        'avatar_url': imageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', _userId);

      setState(() {
        _avatarUrl = imageUrl;
        _isUploading = false;
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _supabase.from('profiles').upsert({
        'id': _userId,
        'full_name': _fullNameController.text,
        'email': _emailController.text,
        'phone_number': _phoneController.text,
        'updated_at': DateTime.now().toIso8601String(),
      });

      setState(() {
        _isLoading = false;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _signOut() async {
    try {
      // Clear session data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastLoginKey);

      // Sign out from Supabase
      await _supabase.auth.signOut();
      Get.offAllNamed('/login');
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "My Profile",
          style: GoogleFonts.raleway(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF7C8500),
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.check_circle : Icons.edit,
              color: const Color(0xFF7C8500),
              size: 28,
            ),
            onPressed: () {
              if (_isEditing) {
                _updateProfile();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF7C8500)),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            "Personal Information",
                            style: GoogleFonts.raleway(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildProfileForm(),
                          const SizedBox(height: 30),
                          _settingsSection(context),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: const BottomNavBar(selectedIndex: 3),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileImage(),
          const SizedBox(height: 16),
          Text(
            _fullNameController.text.isNotEmpty
                ? _fullNameController.text
                : "User",
            style: GoogleFonts.raleway(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF7C8500),
            ),
          ),
          Text(
            _emailController.text,
            style: GoogleFonts.raleway(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Stack(
              alignment: Alignment.center,
              children: [
                _localImageFile != null
                    ? Image.file(
                        _localImageFile!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      )
                    : _avatarUrl != null && _avatarUrl!.isNotEmpty
                        ? Image.network(
                            _avatarUrl!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF7C8500),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.person,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            'assets/profile.jpg',
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.person,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                              );
                            },
                          ),
                if (_isUploading)
                  Container(
                    width: 120,
                    height: 120,
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (_isEditing)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF7C8500),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: _pickAndSaveImage,
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildFormField(
            controller: _fullNameController,
            label: 'Full Name',
            icon: Icons.person,
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildFormField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email,
            enabled: false, // Email cannot be changed after signup
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildFormField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone,
            enabled: _isEditing,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        enabled: enabled,
        labelStyle: GoogleFonts.raleway(color: Colors.grey[600]),
        prefixIcon: Icon(icon, color: const Color(0xFF7C8500), size: 20),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: const Color(0xFF7C8500), width: 2),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      style: GoogleFonts.raleway(
        fontSize: 16,
        color: enabled ? Colors.black87 : Colors.grey[600],
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _settingsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Settings",
            style: GoogleFonts.raleway(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _settingsTile(
            icon: Icons.lock,
            title: "Change Password",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ForgotPasswordScreen()),
              );
            },
          ),
          _divider(),
          _settingsTile(
            icon: Icons.notifications,
            title: "Notifications",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Notifications settings coming soon')),
              );
            },
          ),
          _divider(),
          _settingsTile(
            icon: Icons.help_outline,
            title: "Help & Support",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FAQSupportPage()),
              );
            },
          ),
          _divider(),
          _settingsTile(
            icon: Icons.privacy_tip,
            title: "Privacy Policy",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyPage()),
              );
            },
          ),
          _divider(),
          _settingsTile(
            icon: Icons.logout,
            title: "Logout",
            titleColor: Colors.red,
            iconColor: Colors.red,
            onTap: _signOut,
          ),
        ],
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFFD4C600),
    Color titleColor = Colors.black87,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  color: titleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      color: Colors.grey[200],
      thickness: 1,
      height: 1,
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
