import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        ListTile(leading: Icon(Icons.settings), title: Text('Settings')),
        ListTile(leading: Icon(Icons.person), title: Text('Profile')),
        ListTile(leading: Icon(Icons.logout), title: Text('Logout')),
      ],
    );
  }
}
