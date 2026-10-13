import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get userChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع. حاول مرة أخرى.');
    }
  }

  Future<User?> registerWithEmailPassword(String email, String password, String name) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await credential.user?.updateDisplayName(name.trim());
      await credential.user?.reload();
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e.code));
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع. حاول مرة أخرى.');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'البريد الإلكتروني غير مسجل. قم بإنشاء حساب جديد.';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة. حاول مرة أخرى.';
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مستخدم بالفعل.';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح. يرجى التحقق.';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً. استخدم 6 أحرف على الأقل.';
      case 'too-many-requests':
        return 'محاولات كثيرة جداً. حاول بعد فترة.';
      case 'network-request-failed':
        return 'لا يوجد اتصال بالإنترنت. تحقق من اتصالك.';
      default:
        return 'حدث خطأ غير متوقع. حاول مرة أخرى.';
    }
  }
}