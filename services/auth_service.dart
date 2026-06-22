import 'package:firebase_auth/firebase_auth.dart';

/// Handles mobile number OTP authentication via Firebase Auth.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  String? _verificationId;

  /// Step 1: send OTP to the given mobile number.
  /// [mobile] should be in E.164 format, e.g. +919876543210
  Future<void> sendOtp({
    required String mobile,
    required void Function() onCodeSent,
    required void Function(String error) onError,
    required void Function(UserCredential credential) onAutoVerified,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: mobile,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          final result = await _auth.signInWithCredential(credential);
          onAutoVerified(result);
        } catch (e) {
          onError(e.toString());
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        onCodeSent();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  /// Step 2: verify the OTP entered by the user.
  Future<UserCredential> verifyOtp(String smsCode) async {
    if (_verificationId == null) {
      throw Exception('No OTP was requested. Please request OTP again.');
    }
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
