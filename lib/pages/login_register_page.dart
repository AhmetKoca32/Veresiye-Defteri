import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:veresiye_app/pages/home_page.dart'; // HomePage yönlendirmesi için
import 'package:veresiye_app/service/auth.dart';

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key});

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? errorMessage;

  Future<void> signIn() async {
    try {
      await Auth().signIn(
        email: emailController.text,
        password: passwordController.text,
      );

      // Giriş başarılı olduğunda HomePage'e yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arka plan resmi
          Positioned.fill(
            child: Image.asset(
              'lib/assets/background.jpg', // Burada kendi arka plan resminizi koyabilirsiniz
              fit: BoxFit.cover,
            ),
          ),
          // İçerik
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Şaşalı başlık
                Text(
                  "Tambalaj Veresiye Defteri",
                  style: TextStyle(
                    fontSize: 36, // Daha büyük yazı boyutu
                    fontWeight: FontWeight.bold, // Kalın yazı tipi
                    color: Colors.orangeAccent, // Renkli metin
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black.withOpacity(0.5),
                        offset: Offset(4.0, 4.0),
                      ),
                    ],
                    letterSpacing: 2.0, // Harfler arası mesafe
                  ),
                ),
                const SizedBox(height: 40),
                // Email ve Password dikdörtgeni
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Color(0xFFEEEEEE).withAlpha((255 * 0.9).toInt()),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          hintText: "Email",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: "Password",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      errorMessage != null
                          ? Text(
                            errorMessage!,
                            style: TextStyle(color: Colors.red),
                          )
                          : const SizedBox.shrink(),
                      ElevatedButton(
                        onPressed: signIn,
                        child: const Text("Login"),
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
}
