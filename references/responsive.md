# Responsive & Multi-Device Patterns

Breakpoints, LayoutBuilder, iPad/tablet, and landscape handling for adaptive widgets.

## Table of Contents

1. [Breakpoints](#breakpoints)
2. [LayoutBuilder Patterns](#layoutbuilder-patterns)
3. [Responsive Scaffold](#responsive-scaffold)
4. [iPad / Tablet Patterns](#ipad--tablet-patterns)
5. [Landscape Handling](#landscape-handling)
6. [Safe Areas](#safe-areas)

---

## Breakpoints

```dart
abstract final class Breakpoints {
  static const double compact = 600;   // phone
  static const double medium = 840;    // tablet portrait, foldable
  static const double expanded = 1200; // tablet landscape, desktop

  static ScreenSize of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < compact) return ScreenSize.compact;
    if (width < medium) return ScreenSize.medium;
    if (width < expanded) return ScreenSize.expanded;
    return ScreenSize.large;
  }
}

enum ScreenSize { compact, medium, expanded, large }
```

Usage:

```dart
final screen = Breakpoints.of(context);
switch (screen) {
  case ScreenSize.compact:
    return _buildPhoneLayout();
  case ScreenSize.medium:
    return _buildTabletLayout();
  case ScreenSize.expanded:
  case ScreenSize.large:
    return _buildDesktopLayout();
}
```

---

## LayoutBuilder Patterns

### Responsive Grid

```dart
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double minChildWidth;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minChildWidth = 160,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / minChildWidth).floor().clamp(1, 6);
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          children: children,
        );
      },
    );
  }
}
```

### Responsive Padding

```dart
EdgeInsets responsivePadding(BuildContext context) {
  final screen = Breakpoints.of(context);
  return switch (screen) {
    ScreenSize.compact => const EdgeInsets.all(16),
    ScreenSize.medium => const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    ScreenSize.expanded => const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
    ScreenSize.large => const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
  };
}
```

### Content Width Constraint

Prevent content from stretching too wide on large screens:

```dart
class ConstrainedContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ConstrainedContent({
    super.key,
    required this.child,
    this.maxWidth = 680,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
```

---

## Responsive Scaffold

Adapts navigation based on screen size:
- Compact: bottom nav
- Medium: navigation rail
- Expanded: navigation drawer

```dart
class ResponsiveScaffold extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final List<NavigationItem> items;
  final Widget body;

  const ResponsiveScaffold({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.items,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final screen = Breakpoints.of(context);

    if (screen == ScreenSize.compact) {
      return AdaptiveScaffold(
        body: body,
        bottomNavigationBar: AdaptiveBottomNav(
          currentIndex: currentIndex,
          onTap: onIndexChanged,
          items: items.map((i) => i.toBottomNavItem()).toList(),
        ),
      );
    }

    if (screen == ScreenSize.medium) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: onIndexChanged,
              labelType: NavigationRailLabelType.all,
              destinations: items.map((i) => i.toRailDestination()).toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    // Expanded / Large
    return Scaffold(
      body: Row(
        children: [
          NavigationDrawer(
            selectedIndex: currentIndex,
            onDestinationSelected: onIndexChanged,
            children: items.map((i) => i.toDrawerDestination()).toList(),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class NavigationItem {
  final Widget icon;
  final Widget selectedIcon;
  final String label;

  const NavigationItem({required this.icon, required this.selectedIcon, required this.label});

  BottomNavigationBarItem toBottomNavItem() =>
      BottomNavigationBarItem(icon: icon, activeIcon: selectedIcon, label: label);

  NavigationRailDestination toRailDestination() =>
      NavigationRailDestination(icon: icon, selectedIcon: selectedIcon, label: Text(label));

  NavigationDrawerDestination toDrawerDestination() =>
      NavigationDrawerDestination(icon: icon, selectedIcon: selectedIcon, label: Text(label));
}
```

---

## iPad / Tablet Patterns

### Master-Detail (Split View)

```dart
class MasterDetailLayout extends StatelessWidget {
  final Widget master;
  final Widget? detail;
  final Widget emptyDetail;

  const MasterDetailLayout({
    super.key,
    required this.master,
    this.detail,
    this.emptyDetail = const Center(child: Text('Select an item')),
  });

  @override
  Widget build(BuildContext context) {
    final screen = Breakpoints.of(context);

    // Phone: master only, detail pushes as new page
    if (screen == ScreenSize.compact) {
      return master;
    }

    // Tablet+: side-by-side
    return Row(
      children: [
        SizedBox(
          width: screen == ScreenSize.medium ? 320 : 380,
          child: master,
        ),
        const VerticalDivider(width: 1),
        Expanded(child: detail ?? emptyDetail),
      ],
    );
  }
}
```

### iPad Multitasking (Slide Over / Split View)

Flutter supports iPad multitasking natively. Ensure:

```dart
// In Info.plist, ensure these are NOT set to false:
// UIRequiresFullScreen = false (allow split view)
// UISupportedInterfaceOrientations includes landscape

// Use LayoutBuilder, not fixed sizes
LayoutBuilder(
  builder: (context, constraints) {
    // constraints.maxWidth changes when iPad split view resizes
    final isNarrow = constraints.maxWidth < 400;
    return isNarrow ? _compactView() : _wideView();
  },
)
```

---

## Landscape Handling

### Detect Orientation

```dart
final orientation = MediaQuery.orientationOf(context);
final isLandscape = orientation == Orientation.landscape;
```

### OrientationBuilder

```dart
OrientationBuilder(
  builder: (context, orientation) {
    if (orientation == Orientation.landscape) {
      return Row(
        children: [
          Expanded(child: imageSection),
          Expanded(child: contentSection),
        ],
      );
    }
    return Column(
      children: [imageSection, contentSection],
    );
  },
)
```

### Lock Orientation (when needed)

```dart
// In main.dart, before runApp:
SystemChrome.setPreferredOrientations([
  DeviceOrientation.portraitUp,
  // Add landscape if supported:
  // DeviceOrientation.landscapeLeft,
  // DeviceOrientation.landscapeRight,
]);
```

---

## Safe Areas

Always respect safe areas for notch, Dynamic Island, home indicator.

```dart
// Full safe area (most common)
SafeArea(child: content)

// Selective safe area
SafeArea(
  top: true,
  bottom: true,
  left: false,
  right: false,
  child: content,
)

// Custom padding from safe area
Padding(
  padding: EdgeInsets.only(
    top: MediaQuery.of(context).padding.top,
    bottom: MediaQuery.of(context).padding.bottom,
  ),
  child: content,
)
```

### SliverSafeArea

For CustomScrollView with slivers:

```dart
CustomScrollView(
  slivers: [
    CupertinoSliverNavigationBar(largeTitle: Text('Title')),
    // Content slivers...
    SliverSafeArea(
      top: false, // already handled by nav bar
      sliver: SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(...),
      ),
    ),
  ],
)
```
