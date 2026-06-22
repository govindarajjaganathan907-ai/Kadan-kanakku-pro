import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth_gate.dart';
import 'utils/app_theme.dart';
import 'utils/app_locale.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.init();
  runApp(const KadanKanakkuApp());
}

class KadanKanakkuApp extends StatefulWidget {
  const KadanKanakkuApp({super.key});

  @override
  State<KadanKanakkuApp> createState() => _KadanKanakkuAppState();
}

class _KadanKanakkuAppState extends State<KadanKanakkuApp> {
  @override
  void initState() {
    super.initState();
    AppLocale.languageCode.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kadan Kanakku Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const AuthGate(),
    );
  }
}
