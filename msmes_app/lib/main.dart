import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/subscription_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/password_reset_complete_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
  }

  void _handleIncomingLinks() {
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri == null) return;

      final path = uri.path;
      final queryParams = uri.queryParameters;

      // Password reset
      if (uri.host == 'reset-password' || path.contains('reset-password')) {
        final uid = queryParams['uid'];
        final token = queryParams['token'];
        if (uid != null && token != null) {
          Navigator.pushNamed(
            navigatorKey.currentContext!,
            '/reset-password-complete',
            arguments: {'uidb64': uid, 'token': token},
          );
        }
      }
      // Chapa success
      else if (uri.host == 'payment-success' ||
          path.contains('payment-success')) {
        Navigator.pushNamed(navigatorKey.currentContext!, '/home');
      }
    });
  }

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'MSMES App',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/subscribe': (context) => const SubscriptionScreen(),
        '/reset': (context) => const ResetPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/reset-password-complete': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, String>?;
          return PasswordResetCompleteScreen(
            uidb64: args?['uidb64'] ?? '',
            token: args?['token'] ?? '',
          );
        },
      },
    );
  }
}
