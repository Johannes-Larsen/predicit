import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/portfolio_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmReset(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Reset account?'),
          content: const Text(
            'This clears your saved bets and restores your cash balance to '
            '\$1,000.00.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await context.read<PortfolioModel>().resetAccount();

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account reset')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.person, size: 64),
              const SizedBox(height: 16),
              const Text('Signed in as demo user'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _confirmReset(context),
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reset account'),
                ),
              ),
              const SizedBox(height: 8),
              const FilledButton(
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
