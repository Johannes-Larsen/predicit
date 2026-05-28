import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.person, size: 64),
              SizedBox(height: 16),
              Text('Signed in as demo user'),
              SizedBox(height: 16),
              FilledButton(
                onPressed: null,
                child: Text('Sign out coming in A7'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
