import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_utils.dart';
import 'adaptive_bottom_nav.dart';

/// Adaptive tab scaffold that provides a full tabbed page layout.
///
/// Material: [Scaffold] with [NavigationBar] at the bottom.
/// Cupertino: [CupertinoTabScaffold] with [CupertinoTabBar].
class AdaptiveTabScaffold extends StatelessWidget {
  final List<AdaptiveBottomNavItem> tabs;
  final IndexedWidgetBuilder tabBuilder;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final Color? tabBarBackgroundColor;

  const AdaptiveTabScaffold({
    super.key,
    required this.tabs,
    required this.tabBuilder,
    this.currentIndex = 0,
    this.onTap,
    this.backgroundColor,
    this.tabBarBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: tabs
              .map(
                (tab) => BottomNavigationBarItem(
                  icon: tab.icon,
                  activeIcon: tab.activeIcon,
                  label: tab.label,
                ),
              )
              .toList(),
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: tabBarBackgroundColor,
        ),
        tabBuilder: tabBuilder,
        backgroundColor: backgroundColor,
      );
    }

    return _MaterialTabScaffold(
      tabs: tabs,
      tabBuilder: tabBuilder,
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: backgroundColor,
      tabBarBackgroundColor: tabBarBackgroundColor,
    );
  }
}

class _MaterialTabScaffold extends StatefulWidget {
  final List<AdaptiveBottomNavItem> tabs;
  final IndexedWidgetBuilder tabBuilder;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final Color? tabBarBackgroundColor;

  const _MaterialTabScaffold({
    required this.tabs,
    required this.tabBuilder,
    required this.currentIndex,
    this.onTap,
    this.backgroundColor,
    this.tabBarBackgroundColor,
  });

  @override
  State<_MaterialTabScaffold> createState() => _MaterialTabScaffoldState();
}

class _MaterialTabScaffoldState extends State<_MaterialTabScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(covariant _MaterialTabScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _currentIndex = widget.currentIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: widget.tabBuilder(context, _currentIndex),
      bottomNavigationBar: NavigationBar(
        destinations: widget.tabs
            .map(
              (tab) => NavigationDestination(
                icon: tab.icon,
                selectedIcon: tab.activeIcon,
                label: tab.label,
              ),
            )
            .toList(),
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          widget.onTap?.call(index);
        },
        backgroundColor: widget.tabBarBackgroundColor,
      ),
    );
  }
}
