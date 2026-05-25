# Accessibility Patterns

WCAG AA compliance for adaptive widgets. Every widget must be usable with VoiceOver (iOS) and TalkBack (Android).

## Table of Contents

1. [Semantics](#semantics)
2. [Dynamic Type / Font Scaling](#dynamic-type--font-scaling)
3. [Contrast & Color](#contrast--color)
4. [Touch Targets](#touch-targets)
5. [Screen Reader Patterns](#screen-reader-patterns)

---

## Semantics

Wrap interactive widgets in `Semantics` to provide screen reader labels.

### Buttons

```dart
// Every button needs a label if icon-only
Semantics(
  button: true,
  label: 'Add to cart',
  child: AdaptiveIconButton(
    onPressed: _addToCart,
    icon: HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: 24),
  ),
)
```

### Images

```dart
Semantics(
  image: true,
  label: 'Profile photo of John',
  child: CircleAvatar(backgroundImage: NetworkImage(url)),
)

// Decorative image — exclude from semantics
ExcludeSemantics(
  child: Image.asset('assets/decorative_bg.png'),
)
```

### Groups

Merge semantics for composite widgets to avoid VoiceOver reading each piece separately.

```dart
MergeSemantics(
  child: AdaptiveListTile(
    leading: avatar,
    title: Text(name),
    subtitle: Text(role),
    trailing: statusBadge,
    onTap: _openProfile,
  ),
)
```

### Custom Semantics for Adaptive Widgets

Add semantics inside adaptive widget implementations:

```dart
class AdaptiveSwitch extends PlatformWidget<Switch, CupertinoSwitch> {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: semanticLabel,
      child: super.build(context),
    );
  }
}
```

### Live Regions

Announce dynamic content changes (e.g., snackbar, score updates):

```dart
Semantics(
  liveRegion: true,
  child: Text('$itemCount items in cart'),
)
```

---

## Dynamic Type / Font Scaling

Respect user's system font size. Never hardcode text sizes without `MediaQuery.textScalerOf`.

### Allow Scaling

```dart
// Default: text scales with system settings. This is correct.
Text('Hello', style: TextStyle(fontSize: 16))

// If you MUST limit scaling (rare — only for space-constrained UI):
MediaQuery.withClampedTextScaling(
  minScaleFactor: 1.0,
  maxScaleFactor: 1.3,  // cap at 130%
  child: AdaptiveChip(label: 'Tag'),
)
```

### Test with Large Text

Always test with max font size:
- iOS: Settings → Accessibility → Larger Text → max slider
- Android: Settings → Display → Font size → max

### Adaptive Text Style Helper

```dart
TextStyle adaptiveBody(BuildContext context) {
  if (PlatformUtils.isCupertino) {
    return CupertinoTheme.of(context).textTheme.textStyle; // Respects Dynamic Type
  }
  return Theme.of(context).textTheme.bodyLarge!;
}
```

### Overflow Protection

```dart
// Always handle text overflow for scaled text
Text(
  longText,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)

// Use FittedBox for constrained spaces
FittedBox(
  fit: BoxFit.scaleDown,
  child: Text('Score: 100', style: TextStyle(fontSize: 48)),
)
```

---

## Contrast & Color

WCAG AA minimum contrast ratios:
- **Normal text**: 4.5:1
- **Large text** (≥18px bold or ≥24px): 3:1
- **UI components** (icons, borders): 3:1

### iOS System Colors (auto-resolve for dark/light)

```dart
// These automatically adjust for dark mode and accessibility
CupertinoColors.label              // primary text
CupertinoColors.secondaryLabel     // secondary text
CupertinoColors.systemBackground   // background
CupertinoColors.separator          // dividers

// Always use .resolveFrom(context) for dynamic resolution
final labelColor = CupertinoColors.label.resolveFrom(context);
```

### Never Rely on Color Alone

```dart
// BAD: color-only status
Container(color: isError ? Colors.red : Colors.green)

// GOOD: color + icon + text
Row(children: [
  HugeIcon(
    icon: isError ? HugeIcons.strokeRoundedCancel01 : HugeIcons.strokeRoundedCheckmarkCircle01,
    color: isError ? CupertinoColors.systemRed : CupertinoColors.systemGreen,
  ),
  Text(isError ? 'Failed' : 'Success'),
])
```

---

## Touch Targets

Minimum touch target: **44x44pt** (Apple HIG) / **48x48dp** (Material).

```dart
// Ensure minimum tap area even for small icons
class AdaptiveIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        minSize: 44, // Apple minimum
        onPressed: onPressed,
        child: icon,
      );
    }
    return IconButton(
      onPressed: onPressed,
      icon: icon,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    );
  }
}
```

### Spacing Between Targets

Minimum 8px between interactive elements to prevent mis-taps.

```dart
Row(
  children: [
    AdaptiveIconButton(icon: editIcon, onPressed: _edit),
    const SizedBox(width: 8), // minimum spacing
    AdaptiveIconButton(icon: deleteIcon, onPressed: _delete),
  ],
)
```

---

## Screen Reader Patterns

### Custom Actions

```dart
Semantics(
  customSemanticsActions: {
    CustomSemanticsAction(label: 'Delete'): _deleteItem,
    CustomSemanticsAction(label: 'Edit'): _editItem,
  },
  child: AdaptiveListTile(title: Text(item.name)),
)
```

### Sort Order

Control VoiceOver/TalkBack reading order:

```dart
Semantics(
  sortKey: const OrdinalSortKey(0), // read first
  child: Text('Important heading'),
)
```

### Dismiss Barriers

Modal overlays must be dismissible:

```dart
// AdaptiveDialog already handles this via showCupertinoDialog/showDialog
// For custom overlays, ensure GestureDetector on barrier
GestureDetector(
  onTap: () => Navigator.pop(context),
  child: Semantics(
    label: 'Dismiss',
    button: true,
    child: Container(color: Colors.black54),
  ),
)
```

### Checklist for Every Adaptive Widget

- [ ] All interactive elements have tap targets ≥ 44pt (iOS) / 48dp (Android)
- [ ] Icon-only buttons have `Semantics(label:)`
- [ ] Decorative images use `ExcludeSemantics`
- [ ] Text respects Dynamic Type (no clamping unless justified)
- [ ] Color is never the only differentiator
- [ ] Contrast ratio ≥ 4.5:1 for text, ≥ 3:1 for UI
- [ ] Composite widgets use `MergeSemantics`
- [ ] Dynamic updates use `liveRegion: true`
