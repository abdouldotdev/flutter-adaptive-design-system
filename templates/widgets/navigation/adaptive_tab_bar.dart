import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_utils.dart';

/// Represents a tab with its label, optional icon, and content widget.
class AdaptiveTab {
  final String label;
  final IconData? icon;
  final Widget child;

  const AdaptiveTab({
    required this.label,
    this.icon,
    required this.child,
  });
}

/// Adaptive tab bar that renders [TabBar]+[TabBarView] on Material platforms
/// and a [CupertinoSlidingSegmentedControl]+[IndexedStack] on Cupertino.
class AdaptiveTabBar extends StatefulWidget {
  /// The list of tabs to display.
  final List<AdaptiveTab> tabs;

  /// The initially selected tab index.
  final int initialIndex;

  /// Called when the selected tab changes.
  final ValueChanged<int>? onTabChanged;

  /// Whether to keep the state of inactive tabs alive.
  final bool keepAlive;

  /// The color of the selected tab indicator (Material only).
  final Color? indicatorColor;

  /// The color of selected tab labels.
  final Color? selectedColor;

  /// The color of unselected tab labels.
  final Color? unselectedColor;

  /// Padding around the segmented control (Cupertino only).
  final EdgeInsets cupertinoPadding;

  const AdaptiveTabBar({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.onTabChanged,
    this.keepAlive = false,
    this.indicatorColor,
    this.selectedColor,
    this.unselectedColor,
    this.cupertinoPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
  });

  @override
  State<AdaptiveTabBar> createState() => _AdaptiveTabBarState();
}

class _AdaptiveTabBarState extends State<AdaptiveTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    _tabController.addListener(_onTabChanged);
  }

  @override
  void didUpdateWidget(covariant AdaptiveTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabs.length != widget.tabs.length) {
      _tabController.removeListener(_onTabChanged);
      _tabController.dispose();
      _tabController = TabController(
        length: widget.tabs.length,
        vsync: this,
        initialIndex: _selectedIndex.clamp(0, widget.tabs.length - 1),
      );
      _tabController.addListener(_onTabChanged);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() => _selectedIndex = _tabController.index);
    widget.onTabChanged?.call(_tabController.index);
  }

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return _buildCupertinoTabs(context);
    }
    return _buildMaterialTabs(context);
  }

  Widget _buildMaterialTabs(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          indicatorColor: widget.indicatorColor,
          labelColor: widget.selectedColor,
          unselectedLabelColor: widget.unselectedColor,
          tabs: widget.tabs.map((tab) {
            if (tab.icon != null) {
              return Tab(text: tab.label, icon: Icon(tab.icon));
            }
            return Tab(text: tab.label);
          }).toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.tabs.map((tab) => tab.child).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCupertinoTabs(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: widget.cupertinoPadding,
          child: SizedBox(
            width: double.infinity,
            child: CupertinoSlidingSegmentedControl<int>(
              groupValue: _selectedIndex,
              thumbColor: widget.selectedColor ??
                  CupertinoColors.systemBackground.resolveFrom(context),
              onValueChanged: (index) {
                if (index != null) {
                  setState(() => _selectedIndex = index);
                  _tabController.animateTo(index);
                  widget.onTabChanged?.call(index);
                }
              },
              children: {
                for (int i = 0; i < widget.tabs.length; i++)
                  i: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.tabs[i].icon != null) ...[
                          Icon(widget.tabs[i].icon, size: 16),
                          const SizedBox(width: 4),
                        ],
                        Text(widget.tabs[i].label),
                      ],
                    ),
                  ),
              },
            ),
          ),
        ),
        Expanded(
          child: widget.keepAlive
              ? IndexedStack(
                  index: _selectedIndex,
                  children: widget.tabs.map((tab) => tab.child).toList(),
                )
              : widget.tabs[_selectedIndex].child,
        ),
      ],
    );
  }
}
