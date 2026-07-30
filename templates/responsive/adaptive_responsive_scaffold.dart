import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../foundation/adaptive_icons.dart';
import '../foundation/adaptive_tokens.dart';
import '../foundation/adaptive_typography.dart';
import '../foundation/platform_utils.dart';
import '../widgets/layout/adaptive_bottom_nav.dart';
import '../widgets/layout/adaptive_scaffold.dart';
import 'breakpoints.dart';

/// A scaffold whose navigation changes shape with the window.
///
/// | Size class          | Navigation                                  |
/// |---------------------|---------------------------------------------|
/// | compact             | bottom bar (`AdaptiveBottomNav`)            |
/// | medium              | collapsed side rail                         |
/// | expanded / large    | expanded sidebar with labels                |
///
/// Both platforms follow that progression, but not with the same widgets: on
/// Material the rail is a [NavigationRail] and the sidebar a
/// [NavigationDrawer]; on Cupertino both are a hand-built list, because
/// UIKit's iPad sidebar is a plain grouped list and Material's rail would read
/// as an Android app running on an iPad.
///
/// ```dart
/// AdaptiveResponsiveScaffold(
///   currentIndex: index,
///   onIndexChanged: (int i) => setState(() => index = i),
///   items: const <NavigationItem>[
///     NavigationItem(icon: AdaptiveIcons.home, label: 'Home'),
///     NavigationItem(icon: AdaptiveIcons.wallet, label: 'Wallet'),
///     NavigationItem(icon: AdaptiveIcons.settings, label: 'Settings'),
///   ],
///   body: pages[index],
/// )
/// ```
///
/// ## Layout only
///
/// The window width decides how much navigation is on screen at once. It never
/// decides how large the labels are — those come from `AdaptiveTypography`,
/// scaled by the user's accessibility setting and nothing else.
class AdaptiveResponsiveScaffold extends StatelessWidget {
  /// Index of the selected destination, into [items].
  final int currentIndex;

  /// Called with the index of the destination the user picked.
  final ValueChanged<int> onIndexChanged;

  /// The destinations, in display order. Two to five reads well in a bottom
  /// bar; a sidebar tolerates more.
  final List<NavigationItem> items;

  /// The content next to (or above) the navigation.
  final Widget body;

  /// Material app bar, forwarded to `AdaptiveScaffold`.
  final PreferredSizeWidget? appBar;

  /// Cupertino navigation bar, forwarded to `AdaptiveScaffold`.
  final ObstructingPreferredSizeWidget? cupertinoNavigationBar;

  /// Background colour of the scaffold.
  final Color? backgroundColor;

  /// Floating action button, Material only in practice.
  final Widget? floatingActionButton;

  const AdaptiveResponsiveScaffold({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.items,
    required this.body,
    this.appBar,
    this.cupertinoNavigationBar,
    this.backgroundColor,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final ScreenSize screen = Breakpoints.of(context);
    final Color activeColor = AdaptiveColors.primary(context);
    final Color inactiveColor = AdaptiveColors.secondaryLabel(context);

    if (screen.isCompact) {
      return AdaptiveScaffold(
        appBar: appBar,
        cupertinoNavigationBar: cupertinoNavigationBar,
        backgroundColor: backgroundColor,
        floatingActionButton: floatingActionButton,
        body: body,
        bottomNavigationBar: AdaptiveBottomNav(
          currentIndex: currentIndex,
          onTap: onIndexChanged,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          items: <AdaptiveBottomNavItem>[
            for (final NavigationItem item in items)
              item.toBottomNavItem(
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
          ],
        ),
      );
    }

    // Everything wider gets a permanent side navigation: labels appear from
    // [ScreenSize.expanded] up, where there is room for them.
    final bool expandedLabels = screen.isAtLeast(ScreenSize.expanded);

    return AdaptiveScaffold(
      appBar: appBar,
      cupertinoNavigationBar: cupertinoNavigationBar,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      body: Row(
        // Stretch so the navigation column and the hairline fill the height.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildSideNavigation(
            context,
            expandedLabels: expandedLabels,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
          ),
          _buildSeparator(context),
          Expanded(child: body),
        ],
      ),
    );
  }

  Widget _buildSideNavigation(
    BuildContext context, {
    required bool expandedLabels,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    if (PlatformUtils.isCupertino) {
      return _buildCupertinoSidebar(
        context,
        expandedLabels: expandedLabels,
        activeColor: activeColor,
        inactiveColor: inactiveColor,
      );
    }

    if (expandedLabels) {
      return NavigationDrawer(
        selectedIndex: currentIndex,
        onDestinationSelected: onIndexChanged,
        children: <Widget>[
          for (final NavigationItem item in items)
            item.toDrawerDestination(
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
        ],
      );
    }

    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: onIndexChanged,
      labelType: NavigationRailLabelType.all,
      destinations: <NavigationRailDestination>[
        for (final NavigationItem item in items)
          item.toRailDestination(
            activeColor: activeColor,
            inactiveColor: inactiveColor,
          ),
      ],
    );
  }

  /// The iPad-style sidebar: a plain list of rows, selection shown as a
  /// tinted rounded row rather than a Material indicator pill.
  Widget _buildCupertinoSidebar(
    BuildContext context, {
    required bool expandedLabels,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    return ColoredBox(
      color: AdaptiveColors.background(context),
      child: SizedBox(
        width: expandedLabels ? 260 : 88,
        child: SafeArea(
          right: false,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AdaptiveSpacing.sm),
            physics: AdaptiveScrollPhysics.of(),
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildCupertinoSidebarRow(
                index: index,
                expandedLabels: expandedLabels,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCupertinoSidebarRow({
    required int index,
    required bool expandedLabels,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final NavigationItem item = items[index];
    final bool selected = index == currentIndex;
    final Color color = selected ? activeColor : inactiveColor;

    final Widget icon = AdaptiveIcon(
      item.resolveIcon(selected: selected),
      size: 22,
      color: color,
    );

    final Widget label = Text(
      item.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: expandedLabels ? TextAlign.start : TextAlign.center,
      style: TextStyle(
        fontSize: expandedLabels
            ? AdaptiveTypography.titleSmallSize
            : AdaptiveTypography.labelSmallSize,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        color: color,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AdaptiveSpacing.sm,
        vertical: AdaptiveSpacing.xs,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onIndexChanged(index),
        child: Container(
          padding: const EdgeInsets.all(AdaptiveSpacing.md),
          decoration: BoxDecoration(
            color: selected ? activeColor.withValues(alpha: 0.12) : null,
            borderRadius: AdaptiveRadius.cardBorder,
          ),
          child: expandedLabels
              ? Row(
                  children: <Widget>[
                    icon,
                    const SizedBox(width: AdaptiveSpacing.md),
                    Expanded(child: label),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    icon,
                    const SizedBox(height: AdaptiveSpacing.xs),
                    label,
                  ],
                ),
        ),
      ),
    );
  }

  /// Hairline between the navigation and the content: 0.5pt on iOS, 1pt on
  /// Material, matching each platform's separator.
  Widget _buildSeparator(BuildContext context) {
    return SizedBox(
      width: PlatformUtils.isCupertino ? 0.5 : 1,
      child: ColoredBox(color: AdaptiveColors.separator(context)),
    );
  }
}

/// One destination of [AdaptiveResponsiveScaffold].
///
/// Holds [IconData] rather than a built widget because `hugeicons` requires an
/// explicit colour on every glyph: the scaffold resolves the selected and
/// unselected colours for the current platform, then asks this class to build
/// the destination for whichever navigation shape is on screen.
class NavigationItem {
  /// Glyph shown when the destination is not selected, normally a constant
  /// from `AdaptiveIcons`.
  final IconData icon;

  /// Glyph shown when the destination is selected. Falls back to [icon].
  ///
  /// `hugeicons` ships one variant family — every constant is `strokeRounded*`
  /// — so selection is normally conveyed by colour alone and this stays null.
  final IconData? selectedIcon;

  /// The destination's label. Localise it at the call site.
  final String label;

  const NavigationItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });

  /// The glyph for the given selection state.
  IconData resolveIcon({required bool selected}) =>
      selected ? (selectedIcon ?? icon) : icon;

  /// Converts to an item of `AdaptiveBottomNav` (compact windows).
  AdaptiveBottomNavItem toBottomNavItem({
    required Color activeColor,
    required Color inactiveColor,
  }) {
    return AdaptiveBottomNavItem(
      icon: AdaptiveIcon(icon, size: 24, color: inactiveColor),
      activeIcon: AdaptiveIcon(
        resolveIcon(selected: true),
        size: 24,
        color: activeColor,
      ),
      label: label,
    );
  }

  /// Converts to a [NavigationRailDestination] (medium windows, Material).
  NavigationRailDestination toRailDestination({
    required Color activeColor,
    required Color inactiveColor,
  }) {
    return NavigationRailDestination(
      icon: AdaptiveIcon(icon, color: inactiveColor),
      selectedIcon: AdaptiveIcon(
        resolveIcon(selected: true),
        color: activeColor,
      ),
      label: Text(label),
    );
  }

  /// Converts to a [NavigationDrawerDestination] (expanded windows, Material).
  NavigationDrawerDestination toDrawerDestination({
    required Color activeColor,
    required Color inactiveColor,
  }) {
    return NavigationDrawerDestination(
      icon: AdaptiveIcon(icon, color: inactiveColor),
      selectedIcon: AdaptiveIcon(
        resolveIcon(selected: true),
        color: activeColor,
      ),
      label: Text(label),
    );
  }
}
