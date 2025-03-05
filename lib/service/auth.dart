import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Giriş yapma
  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Çıkış yapma
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Mevcut kullanıcı
  User? get currentUser => _auth.currentUser;
}
