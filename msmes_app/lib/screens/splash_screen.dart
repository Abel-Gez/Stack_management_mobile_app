import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'dart:developer';
import 'package:msmes_app/screens/password_reset_complete_screen.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  StreamSubscription<Uri>? _sub;
  final AppLinks _appLinks = AppLinks(); // app_links instance

  @override
  void initState() {
    super.initState();

    // Handle deep links
    handleIncomingLinks();

    // Animation for logo scale
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Delay and navigate to welcome if no deep link
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    });
  }

  void handleIncomingLinks() async {
    try {
      _sub = _appLinks.uriLinkStream.listen(
        (Uri? uri) {
          if (uri != null && uri.path.contains("reset-password")) {
            final uid = uri.queryParameters['uid'] ?? '';
            final token = uri.queryParameters['token'] ?? '';

            log("Deep link: uid=$uid, token=$token");

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        PasswordResetCompleteScreen(uidb64: uid, token: token),
              ),
            );
          }
        },
        onError: (err) {
          log("Error parsing deep link: $err");
        },
      );
    } on PlatformException catch (e) {
      log("PlatformException: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 40), // Mimic top bar
          Expanded(
            child: Center(
              child: ScaleTransition(
                scale: _animation,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF4BE4EA), // Light cyan
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'MSMES',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'ArialRoundedMTBold', // optional
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 40),
            child: DotLoading(),
          ),
        ],
      ),
    );
  }
}

class DotLoading extends StatefulWidget {
  const DotLoading({super.key});

  @override
  _DotLoadingState createState() => _DotLoadingState();
}

class _DotLoadingState extends State<DotLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    _animation = StepTween(begin: 0, end: 2).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: i == _animation.value ? 12 : 8,
              height: i == _animation.value ? 12 : 8,
              decoration: BoxDecoration(
                color: Colors.cyan,
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
