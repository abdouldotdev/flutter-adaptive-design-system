# Performance Optimization

Critical rules for adaptive widgets dispatching hundreds of widgets per screen across platforms.

## Table of Contents

1. [Platform Check Cost](#platform-check-cost)
2. [const Constructors](#const-constructors)
3. [Widget Rebuild Optimization](#widget-rebuild-optimization)
4. [Lazy Building](#lazy-building)
5. [List Performance](#list-performance)
6. [Image & Asset Optimization](#image--asset-optimization)
7. [Animation Performance](#animation-performance)
8. [Profiling Checklist](#profiling-checklist)

---

## Platform Check Cost

`PlatformUtils.isCupertino` reads `Platform.isIOS` — a static field resolved once at startup. **Zero runtime cost per call.** No caching needed.

```dart
// This is FREE — just a static bool read
if (PlatformUtils.isCupertino) { ... }
```

**Never** do this:

```dart
// WRONG: unnecessary caching
late final bool _isCupertino = PlatformUtils.isCupertino;
```

The platform never changes at runtime. The static getter is already optimal.

---

## const Constructors

**Critical**: Every adaptive widget MUST have a `const` constructor when possible. This enables Flutter's const widget optimization — identical const widgets are instantiated once and reused.

```dart
// GOOD: const constructor
class AdaptiveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const AdaptiveButton({   // <-- const
    super.key,
    this.onPressed,
    required this.child,
  });
}

// Usage: const when possible
const AdaptiveButton(
  onPressed: null,
  child: Text('Disabled'),
)
```

**Rules:**
- All fields must be `final`
- No mutable state in constructor
- Prefer `const` in widget trees wherever possible
- Use `const []` for empty lists, `const EdgeInsets.all(0)` for zero padding

---

## Widget Rebuild Optimization

### RepaintBoundary for Heavy Widgets

Isolate expensive platform widgets from parent rebuilds:

```dart
class AdaptiveCard extends PlatformWidget<Card, Container> {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(  // Prevents ripple repaints from leaking
      child: super.build(context),
    );
  }
}
```

Use `RepaintBoundary` on:
- Cards with complex content
- List items with animations
- Widgets that rebuild independently from parents

### Extract Subtrees

Break large build methods into smaller const-eligible widgets:

```dart
// BAD: entire tree rebuilds on state change
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      _buildHeader(),     // rebuilds even when unrelated state changes
      Text('$counter'),   // only this needs to rebuild
      _buildFooter(),     // rebuilds unnecessarily
    ],
  );
}

// GOOD: extract static parts as const widgets
@override
Widget build(BuildContext context) {
  return Column(
    children: [
      const _Header(),        // const — never rebuilds
      Text('$counter'),       // rebuilds on change
      const _Footer(),        // const — never rebuilds
    ],
  );
}
```

### Avoid Closures in Build

```dart
// BAD: new closure every build → child rebuilds
AdaptiveButton(
  onPressed: () => _doSomething(),
  child: const Text('Tap'),
)

// GOOD: method reference — stable identity
AdaptiveButton(
  onPressed: _doSomething,
  child: const Text('Tap'),
)
```

---

## Lazy Building

### Platform-Specific Lazy Initialization

Only build the active platform's widget:

```dart
// PlatformWidget already does this correctly:
@override
Widget build(BuildContext context) {
  if (PlatformUtils.isCupertino) {
    return buildCupertinoWidget(context);  // Only this runs on iOS
  }
  return buildMaterialWidget(context);     // Only this runs on Android
}
// The other branch is NEVER called — zero cost.
```

### Conditional Imports (advanced)

For platform-specific packages, use conditional imports:

```dart
// lib/design_system/foundation/platform_widget.dart
import 'platform_widget_stub.dart'
    if (dart.library.io) 'platform_widget_io.dart'
    if (dart.library.html) 'platform_widget_web.dart';
```

---

## List Performance

### Always Use ListView.builder

```dart
// BAD: builds all 1000 items upfront
ListView(
  children: items.map((i) => AdaptiveListTile(title: Text(i.name))).toList(),
)

// GOOD: builds only visible items
ListView.builder(
  itemCount: items.length,
  itemBuilder: (_, index) => AdaptiveListTile(
    title: Text(items[index].name),
  ),
)
```

### itemExtent for Fixed-Height Items

If all items have the same height, specify `itemExtent` for ~30% scroll perf gain:

```dart
ListView.builder(
  itemCount: items.length,
  itemExtent: 56.0,  // known height for ListTile
  itemBuilder: (_, i) => AdaptiveListTile(title: Text(items[i].name)),
)
```

### Sliver Performance

For complex scrollable layouts, use slivers:

```dart
CustomScrollView(
  physics: adaptiveScrollPhysics(),
  slivers: [
    AdaptiveSliverAppBar(largeTitle: 'Items'),
    AdaptiveRefreshIndicator.asSliver(onRefresh: _refresh),
    SliverList.builder(
      itemCount: items.length,
      itemBuilder: (_, i) => AdaptiveListTile(title: Text(items[i].name)),
    ),
  ],
)
```

### AutomaticKeepAlive

For tab views where you want to preserve scroll position:

```dart
class _MyTabContent extends StatefulWidget {
  @override
  State createState() => _MyTabContentState();
}

class _MyTabContentState extends State<_MyTabContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(...);
  }
}
```

---

## Image & Asset Optimization

### Cached Network Images

```dart
// Use cached_network_image for network images
CachedNetworkImage(
  imageUrl: url,
  placeholder: (_, __) => const SkeletonBox(width: 100, height: 100),
  errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
  memCacheWidth: 200,  // decode at display size, not full resolution
)
```

### Resize at Decode

```dart
// Decode at display size — saves memory
Image.network(
  url,
  cacheWidth: 200,   // decode width (not display width)
  cacheHeight: 200,
)

// For asset images
Image.asset(
  'assets/hero.png',
  cacheWidth: (MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio).toInt(),
)
```

---

## Animation Performance

### Use AnimatedBuilder, Not setState

```dart
// BAD: setState rebuilds entire widget tree
void _onAnimationTick() {
  setState(() {});
}

// GOOD: AnimatedBuilder rebuilds only the animated part
AnimatedBuilder(
  animation: _controller,
  builder: (_, child) => Transform.translate(
    offset: Offset(_animation.value, 0),
    child: child,  // child is NOT rebuilt
  ),
  child: const ExpensiveWidget(),  // built once
)
```

### Avoid Opacity Animations

```dart
// BAD: Opacity causes saveLayer (expensive)
AnimatedOpacity(opacity: _value, child: heavyWidget)

// GOOD: FadeTransition is more efficient
FadeTransition(opacity: _animation, child: heavyWidget)

// BETTER: if just showing/hiding, use Visibility
Visibility(visible: _isVisible, child: heavyWidget)
```

### Use transform over layout changes

```dart
// BAD: changes layout, triggers relayout
AnimatedContainer(margin: EdgeInsets.only(top: _value))

// GOOD: transform doesn't affect layout
Transform.translate(offset: Offset(0, _value), child: widget)
```

---

## Profiling Checklist

### Before Shipping

1. **Flutter DevTools**: Check rebuild counts in Widget Inspector
   - Enable "Track Widget Builds" in DevTools
   - Red highlights = excessive rebuilds

2. **Performance Overlay**: Enable to check 60fps
   ```dart
   MaterialApp(showPerformanceOverlay: true)
   ```

3. **Profile Mode**: Always profile in release mode
   ```bash
   flutter run --profile
   ```

4. **Common Issues**:

| Issue | Symptom | Fix |
|-------|---------|-----|
| Missing const | Unnecessary rebuilds | Add const to constructors and usage |
| Build closures | New objects every frame | Extract to methods |
| Unbounded lists | Jank on scroll | Use ListView.builder |
| Large images | Memory spikes | Set cacheWidth/cacheHeight |
| Opacity animations | Dropped frames | Use FadeTransition |
| Missing RepaintBoundary | Ripple effects leak | Wrap interactive cards |
| setState too high | Subtree rebuilds | Push state down, use const children |

### Performance Budgets

| Metric | Target |
|--------|--------|
| First frame | < 2s |
| Frame render | < 16ms (60fps) |
| Frame render (120Hz) | < 8ms |
| List scroll | 0 jank frames |
| Memory (idle) | < 100MB |
| App size | < 30MB |
