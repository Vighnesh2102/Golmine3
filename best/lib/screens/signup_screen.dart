import 'package:best/screens/home_screen.dart';
import 'package:flutter/material.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: screenHeight * 0.05,
            left: 10,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xFFF5F4F8),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_back,
                    color: Color(0xFF988A44),
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      textAlign: TextAlign.left,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Create your ",
                            style: TextStyle(
                              fontSize: screenWidth * 0.07,
                              fontFamily: "Lato",
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            text: "account",
                            style: TextStyle(
                              fontSize: screenWidth * 0.07,
                              fontFamily: "Lato",
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 9, 48, 74),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    "Create an account to get started",
                    style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  _buildTextField(icon: Icons.person_outline, label: "Full Name"),
                  SizedBox(height: screenHeight * 0.02),
                  _buildTextField(icon: Icons.email_outlined, label: "Email"),
                  SizedBox(height: screenHeight * 0.02),
                  _buildPasswordField(
                    label: "Password",
                    isObscure: _obscurePassword,
                    onToggle: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildPasswordField(
                    label: "Confirm Password",
                    isObscure: _obscureConfirmPassword,
                    onToggle: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>  HomeScreen()), //just chnage  the "RealEstateApp() thing here to redirect to any page"
                            );
                          },
                          child: Text(
                            "Register",
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required IconData icon, required String label}) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Color(0xFF988A44)),
        labelText: label,
        filled: true,
        fillColor: Color(0xFFF5F4F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPasswordField({required String label, required bool isObscure, required VoidCallback onToggle}) {
    return TextField(
      obscureText: isObscure,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF988A44)),
        labelText: label,
        filled: true,
        fillColor: Color(0xFFF5F4F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isObscure ? Icons.visibility_off : Icons.visibility,
            color: Color(0xFF988A44),
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
