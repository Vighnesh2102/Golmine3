import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  List<TextEditingController> otpControllers =
      List.generate(4, (index) => TextEditingController());
  int countdown = 30;
  late Timer timer;
  String correctOTP = "1234"; // Mock OTP

  @override
  void initState() {
    super.initState();
    startTimer();
    sendOTP(); // Send OTP initially
  }

  void startTimer() {
    countdown = 30;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        setState(() {
          countdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void sendOTP() {
    correctOTP = generateOTP(); // Generate new OTP
    print("New OTP: $correctOTP"); // Simulating OTP sent via backend
    // TODO: Integrate with backend API to send OTP to the user's email
  }

  String generateOTP() {
    Random random = Random();
    return (1000 + random.nextInt(9000)).toString(); // Generates a 4-digit OTP
  }

  void resendOTP() {
    setState(() {
      startTimer(); // Restart timer
      sendOTP(); // Send new OTP
    });
  }

  void verifyOTP() {
    String enteredOTP = otpControllers.map((e) => e.text).join();
    if (enteredOTP == correctOTP) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP Verified Successfully!")),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Invalid OTP"),
          content: Text("The entered OTP is incorrect. Please try again."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    timer.cancel();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 80, color: Colors.yellow[600]),
            SizedBox(height: 10),
            Text(
              "Enter the Code",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 10),
            Text("Enter the 4-digit code that we just sent to", style: TextStyle(color: Colors.black54)),
            Text("jonathan@email.com", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  width: 50,
                  height: 50,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: TextField(
                    controller: otpControllers[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      counterText: "",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.yellow),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.yellow),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.length == 1 && index < 3) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: countdown == 0 ? resendOTP : null,
              child: Text(
                countdown > 0
                    ? "00:${countdown.toString().padLeft(2, '0')}"
                    : "Resend OTP",
                style: TextStyle(
                  color: countdown > 0 ? Colors.black : Colors.yellow[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: verifyOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: Text("Verify", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
