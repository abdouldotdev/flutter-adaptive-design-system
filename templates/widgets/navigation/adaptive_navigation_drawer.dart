import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_utils.dart';

/// An item for use in [AdaptiveNavigationDrawer].
class AdaptiveDrawerItem {
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final VoidCallback? onTap;
  final bool selected;

  const AdaptiveDrawerItem({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.onTap,
    this.selected = false,
  });
}

/// A separator or section header for the drawer.
class AdaptiveDrawerSection {
  final String? title;
  final List<AdaptiveDrawerItem> items;

  const AdaptiveDrawerSection({
    this.title,
    required this.items,
  });
}

/// Adaptive navigation drawer that renders [NavigationDrawer] on Material
/// platforms and a Cupertino-styled drawer on Cupertino platforms.
class AdaptiveNavigationDrawer extends StatelessWidget {
  /// The header widget displayed at the top of the drawer.
  final Widget? header;

  /// Flat list of drawer items. Used when sections are not needed.
  final List<AdaptiveDrawerItem>? items;

  /// Sectioned drawer items. Takes precedence over [items].
  final List<AdaptiveDrawerSection>? sections;

  /// The currently selected index (used for Material NavigationDrawer).
  final int selectedIndex;

  /// Called when the selection changes (Material only).
  final ValueChanged<int>? onDestinationSelected;

  /// The background color of the drawer.
  final Color? backgroundColor;

  /// The width of the drawer.
  final double width;

  const AdaptiveNavigationDrawer({
    super.key,
    this.header,
    this.items,
    this.sections,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.backgroundColor,
    this.width = 304,
  }) : assert(
          items != null || sections != null,
          'Either items or sections must be provided.',
        );

  List<AdaptiveDrawerItem> get _allItems {
    if (sections != null) {
      return sections!.expand((s) => s.items).toList();
    }
    return items ?? [];
  }

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return _buildCupertinoDrawer(context);
    }
    return _buildMaterialDrawer(context);
  }

  Widget _buildMaterialDrawer(BuildContext context) {
    final destinations = _allItems.map((item) {
      return NavigationDrawerDestination(
        icon: Icon(item.icon),
        selectedIcon: item.selectedIcon != null
            ? Icon(item.selectedIcon)
            : null,
        label: Text(item.label),
      );
    }).toList();

    final children = <Widget>[];

    if (header != null) {
      children.add(header!);
      children.add(const Divider());
    }

    if (sections != null) {
      for (final section in sections!) {
        if (section.title != null) {
          children.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 16, 8),
              child: Text(
                section.title!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          );
        }
      }
    }

    return NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        final allItems = _allItems;
        if (index >= 0 && index < allItems.length) {
          allItems[index].onTap?.call();
        }
        onDestinationSelected?.call(index);
      },
      backgroundColor: backgroundColor,
      children: [
        if (header != null) ...[
          header!,
          const Divider(),
        ],
        ...destinations,
      ],
    );
  }

  Widget _buildCupertinoDrawer(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    final effectiveBackground = backgroundColor ??
        CupertinoColors.systemGroupedBackground.resolveFrom(context);

    return SizedBox(
      width: width,
      child: ColoredBox(
        color: effectiveBackground,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (header != null) ...[
                header!,
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1),
                ),
              ],
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: _buildCupertinoItems(context, cupertinoTheme),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCupertinoItems(
    BuildContext context,
    CupertinoThemeData theme,
  ) {
    final widgets = <Widget>[];

    if (sections != null) {
      for (final section in sections!) {
        if (section.title != null) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
              child: Text(
                section.title!.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        }
        for (final item in section.items) {
          widgets.add(_buildCupertinoItem(context, item, theme));
        }
      }
    } else if (items != null) {
      for (final item in items!) {
        widgets.add(_buildCupertinoItem(context, item, theme));
      }
    }

    return widgets;
  }

  Widget _buildCupertinoItem(
    BuildContext context,
    AdaptiveDrawerItem item,
    CupertinoThemeData theme,
  ) {
    final isSelected = item.selected;
    final primaryColor = theme.primaryColor;
    final labelColor = isSelected
        ? primaryColor
        : CupertinoColors.label.resolveFrom(context);

    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.1)
              : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? (item.selectedIcon ?? item.icon) : item.icon,
              size: 22,
              color: labelColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: labelColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
