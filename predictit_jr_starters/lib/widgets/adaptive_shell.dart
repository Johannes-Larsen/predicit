import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const double kWideBreakpoint = 600.0;

class _TabDestination {
  const _TabDestination({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

const List<_TabDestination> _tabs = <_TabDestination>[
  _TabDestination(label: 'Markets', icon: Icons.show_chart),
  _TabDestination(label: 'Portfolio', icon: Icons.account_balance_wallet),
  _TabDestination(label: 'Profile', icon: Icons.person),
];

class AdaptiveShell extends StatelessWidget {
  const AdaptiveShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goToBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Responsive layout is driven by the current available window width, not
    // the operating system. Rotating/resizing past this breakpoint changes the
    // app chrome immediately.
    final double width = MediaQuery.sizeOf(context).width;
    final bool wide = width >= kWideBreakpoint;

    return wide ? _WideShell(this) : _NarrowShell(this);
  }
}

class _NarrowShell extends StatelessWidget {
  const _NarrowShell(this.shell);

  final AdaptiveShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.navigationShell.currentIndex,
        onDestinationSelected: shell._goToBranch,
        destinations: <NavigationDestination>[
          for (final _TabDestination tab in _tabs)
            NavigationDestination(icon: Icon(tab.icon), label: tab.label),
        ],
      ),
    );
  }
}

class _WideShell extends StatelessWidget {
  const _WideShell(this.shell);

  final AdaptiveShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          NavigationRail(
            selectedIndex: shell.navigationShell.currentIndex,
            onDestinationSelected: shell._goToBranch,
            labelType: NavigationRailLabelType.all,
            destinations: <NavigationRailDestination>[
              for (final _TabDestination tab in _tabs)
                NavigationRailDestination(
                  icon: Icon(tab.icon),
                  label: Text(tab.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: shell.navigationShell),
        ],
      ),
    );
  }
}
