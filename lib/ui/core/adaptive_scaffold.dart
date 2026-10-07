import 'package:flutter/material.dart';

class AdaptiveScaffoldDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const AdaptiveScaffoldDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class AdaptiveScaffold extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AdaptiveScaffoldDestination> destinations;
  final Widget body;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? appBar;

  const AdaptiveScaffold({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.body,
    this.floatingActionButton,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth >= 650;

        if (isLargeScreen) {
          return Scaffold(
            appBar: appBar,
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.only(bottom: 16, top: 8),
                    child: floatingActionButton,
                  ),
                  destinations: destinations.map((d) {
                    return NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: Text(d.label),
                    );
                  }).toList(),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: body,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: appBar,
          body: body,
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: destinations.map((d) {
              return NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: d.label,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
