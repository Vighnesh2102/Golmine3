import 'package:best/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
// Import the SignupScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        print("Google Sign-In Success: ${account.displayName}");
      }
    } catch (error) {
      print("Google Sign-In Error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Responsive Image Banner
            Container(
              width: double.infinity,
              height: screenHeight * 0.3,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/sakshi.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.05),

                  // Sign In Text with Gradient
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: [
                          Color.fromARGB(255, 187, 190, 39),
                          Color(0xFF898B10),
                          Color(0xFF52530D),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Let's ",
                            style: TextStyle(
                              fontSize: screenWidth * 0.07,
                              fontFamily: "Lato",
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            text: "Sign In",
                            style: TextStyle(
                              fontSize: screenWidth * 0.07,
                              fontFamily: "Lato",
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F4C6B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  Text(
                    "Enter your credentials to continue",
                    style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Email Input Field
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF988A44)),
                      labelText: "Email",
                      filled: true,
                      fillColor: Color(0xFFF5F4F8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02, horizontal: screenWidth * 0.04),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Password Input Field
                  TextField(
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF988A44)),
                      labelText: "Password",
                      filled: true,
                      fillColor: Color(0xFFF5F4F8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02, horizontal: screenWidth * 0.04),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Color(0xFF988A44),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.015),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Login Button
                  Center(
                    child: Container(
                      width: screenWidth * 0.7,
                      height: screenHeight * 0.07,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFF3F717),
                            Color(0xFF898B10),
                            Color(0xFF52530D),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton(
                        onPressed: () {
                          print("Login button clicked");
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.025),

                  // Register Option - Navigate to SignupScreen
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(fontSize: screenWidth * 0.04),
                        ),
                        TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()), // Add 'const' before SignupScreen()
    );
  },
  child: Text(
    "Register",
    style: TextStyle(          
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.blue,
    ),
  ),
),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
