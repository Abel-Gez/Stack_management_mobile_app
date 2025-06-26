import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:msmes_app/screens/password_reset_complete_screen.dart';

final AppLinks _appLinks = AppLinks();

void initDeepLinks(BuildContext context) {
  // Handle initial link
  _appLinks.getInitialAppLink().then((uri) {
    if (uri != null) {
      _handleLink(uri, context);
    }
  });

  // Listen for incoming links
  _appLinks.uriLinkStream.listen((Uri uri) {
    _handleLink(uri, context);
  });
}

void _handleLink(Uri uri, BuildContext context) {
  if (uri.scheme == 'msmesapp' && uri.host == 'reset-password') {
    final uid = uri.queryParameters['uid'];
    final token = uri.queryParameters['token'];

    if (uid != null && token != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => PasswordResetCompleteScreen(uidb64: uid, token: token),
        ),
      );
    }
  }
}
