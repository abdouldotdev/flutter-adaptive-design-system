import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_utils.dart';

/// An item for use with [AdaptiveBottomNav].
class AdaptiveBottomNavItem {
  final Widget icon;
  final Widget? activeIcon;
  final String label;

  const AdaptiveBottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}

/// Adaptive bottom navigation bar.
///
/// Renders [NavigationBar] (Material 3) on Android/web and
/// [CupertinoTabBar] on iOS/macOS.
///
/// Does not extend [PlatformWidget] because the return types differ
/// and [CupertinoTabBar] implements specific sizing protocols.
class AdaptiveBottomNav extends StatelessWidget {
  final List<AdaptiveBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? inactiveColor;

  const AdaptiveBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    this.onTap,
    this.backgroundColor,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return CupertinoTabBar(
        items: items
            .map(
              (item) => BottomNavigationBarItem(
                icon: item.icon,
                activeIcon: item.activeIcon,
                label: item.label,
              ),
            )
            .toList(),
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: backgroundColor,
        activeColor: activeColor ?? CupertinoTheme.of(context).primaryColor,
        inactiveColor: inactiveColor ?? CupertinoColors.inactiveGray,
      );
    }

    return NavigationBar(
      destinations: items
          .map(
            (item) => NavigationDestination(
              icon: item.icon,
              selectedIcon: item.activeIcon,
              label: item.label,
            ),
          )
          .toList(),
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: backgroundColor,
      indicatorColor: activeColor?.withValues(alpha: 0.15),
    );
  }
}
