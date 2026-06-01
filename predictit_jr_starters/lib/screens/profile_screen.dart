import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_model.dart';
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

  Future<void> _signOut(BuildContext context) async {
    await context.read<AuthModel>().signOut();
    // No context.go('/signin') here. The go_router redirect observes
    // AuthModel through refreshListenable and moves the user automatically.
  }

  @override
  Widget build(BuildContext context) {
    final AuthModel auth = context.watch<AuthModel>();
    final String displayName = auth.currentUser?.displayName ?? 'Unknown user';
    final String username = auth.currentUser?.username ?? 'unknown';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Icon(Icons.person, size: 64),
                const SizedBox(height: 16),
                Text(
                  displayName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '@$username',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => _confirmReset(context),
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reset account'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _signOut(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
