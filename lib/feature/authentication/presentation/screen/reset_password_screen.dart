import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2E3349),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height * 0.65,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFE7ED00),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(100),
                  topRight: Radius.circular(100),
                ),
              ),
            ),
          ),

          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 60),
            child: Column(
              children: [
                SizedBox(height: 150),
                Text(
                  "New Password",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 100),

                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Kata Sandi"),
                      SizedBox(height: 6),
                      _inputField(),

                      SizedBox(height: 18),

                      Text("Konfirmasi Kata Sandi"),
                      SizedBox(height: 6),
                      TextField(
                        obscureText: obscureConfirm,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFE5E5E5),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() => obscureConfirm = !obscureConfirm);
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4A74FF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Create"),
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
    );
  }

  Widget _inputField() {
    return TextField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xFFE5E5E5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      obscureText: true,
    );
  }
}
