import 'package:digiattend/core/service/auth_local_storage.dart';
import 'package:digiattend/feature/authentication/data/service/auth_api.dart';
import 'package:digiattend/feature/authentication/presentation/screen/register_screen.dart';
import 'package:digiattend/feature/home/presentation/screen/main_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailC = TextEditingController();
  final passC = TextEditingController();

  bool obscurePass = true;
  bool isLoading = false;

  Future<void> doLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      /// 🔥 KIRIM REQUEST LOGIN KE API
      final data = await AuthAPI.loginUser(
        email: emailC.text.trim(),
        password: passC.text.trim(),
      );

      final String token = data["token"];
      final Map<String, dynamic> user = data["user"];

      /// 🔥 SIMPAN TOKEN & USER KE SHARED PREFERENCES
      await AuthLocalStorage.saveLoginData(token: token, user: user);

      if (!mounted) return;

      /// 🔥 PINDAH KE MAIN SCREEN (HAPUS STACK)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    } catch (e) {
      /// Error dari API
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E3349),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.45,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFE7ED00),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(70),
                  topRight: Radius.circular(70),
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      "Welcome Back",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Login to your account",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 40),

                    Container(
                      padding: const EdgeInsets.all(24),
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
                          const Text("Email"),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: emailC,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return "Email tidak boleh kosong";
                              }
                              if (!v.contains("@")) {
                                return "Format email tidak valid";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFE5E5E5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                          const Text("Password"),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: passC,
                            obscureText: obscurePass,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return "Password tidak boleh kosong";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFE5E5E5),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePass
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() => obscurePass = !obscurePass);
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A74FF),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: isLoading ? null : doLogin,
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text("Login"),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don’t have an account? "),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
