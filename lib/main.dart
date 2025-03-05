import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Poppins fontunu kullanmak için
import 'package:veresiye_app/pages/login_register_page.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tambalaj Veresiye Defteri',
      theme: ThemeData(
        // Global fontu Poppins olarak ayarlıyoruz
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(
            context,
          ).textTheme, // Mevcut metin temasını Poppins ile günceller
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF222831)),
      ),
      home: const LoginRegisterPage(),
    );
  }
}
