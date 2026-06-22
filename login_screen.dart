import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/misc_models.dart';
import '../utils/app_locale.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  final _mobileController = TextEditingController();
  final _nameController = TextEditingController();
  final _otpController = TextEditingController();

  bool _otpSent = false;
  bool _loading = false;
  String? _error;

  Future<void> _sendOtp() async {
    final mobile = _mobileController.text.trim();
    if (mobile.length < 10) {
      setState(() => _error = 'Enter a valid 10-digit mobile number');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final e164 = mobile.startsWith('+') ? mobile : '+91$mobile';

    await _authService.sendOtp(
      mobile: e164,
      onCodeSent: () {
        setState(() {
          _loading = false;
          _otpSent = true;
        });
      },
      onError: (err) {
        setState(() {
          _loading = false;
          _error = err;
        });
      },
      onAutoVerified: (credential) async {
        await _onLoginSuccess(credential.user?.uid ?? '');
      },
    );
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _authService.verifyOtp(_otpController.text.trim());
      await _onLoginSuccess(result.user?.uid ?? '');
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Invalid OTP. Please try again.';
      });
    }
  }

  Future<void> _onLoginSuccess(String uid) async {
    final user = UserModel(
      userId: uid,
      name: _nameController.text.trim().isEmpty ? 'Lender' : _nameController.text.trim(),
      mobile: _mobileController.text.trim(),
    );
    await _firestoreService.upsertUser(user);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Icon(Icons.account_balance_wallet_rounded,
                      size: 72, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('app_name'),
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Daily Interest Loan Tracker',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 40),
                  if (!_otpSent) ...[
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Your Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: InputDecoration(
                        labelText: context.tr('mobile_number'),
                        prefixIcon: const Icon(Icons.phone_android),
                        prefixText: '+91 ',
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(_error!, style: const TextStyle(color: Colors.red)),
                      ),
                    ElevatedButton(
                      onPressed: _loading ? null : _sendOtp,
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(context.tr('send_otp')),
                    ),
                  ] else ...[
                    Text(context.tr('enter_otp'),
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    PinCodeTextField(
                      appContext: context,
                      length: 6,
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      animationType: AnimationType.fade,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(10),
                        fieldHeight: 48,
                        fieldWidth: 42,
                        activeColor: Theme.of(context).primaryColor,
                        selectedColor: Theme.of(context).primaryColor,
                        inactiveColor: Colors.grey.shade300,
                      ),
                      onChanged: (_) {},
                    ),
                    const SizedBox(height: 24),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(_error!, style: const TextStyle(color: Colors.red)),
                      ),
                    ElevatedButton(
                      onPressed: _loading ? null : _verifyOtp,
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(context.tr('verify')),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _otpSent = false),
                      child: const Text('Change number'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
