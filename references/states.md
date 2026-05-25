# Widget State Patterns

Loading, empty, error, and disabled state patterns for adaptive widgets.

## Table of Contents

1. [Loading States](#loading-states)
2. [Empty States](#empty-states)
3. [Error States](#error-states)
4. [Disabled States](#disabled-states)
5. [Skeleton / Shimmer](#skeleton--shimmer)

---

## Loading States

### Inline Loading

```dart
class AdaptiveLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const AdaptiveLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: PlatformUtils.isCupertino
                  ? CupertinoColors.systemBackground.withOpacity(0.7)
                  : Colors.white.withOpacity(0.7),
              child: const Center(child: AdaptiveProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
```

### Full-Page Loading

```dart
class AdaptiveLoadingPage extends StatelessWidget {
  final String? message;

  const AdaptiveLoadingPage({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AdaptiveProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: PlatformUtils.isCupertino
                  ? CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                        color: CupertinoColors.secondaryLabel,
                      )
                  : Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
            ),
          ],
        ],
      ),
    );
  }
}
```

### Button Loading

```dart
class AdaptiveLoadingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;

  const AdaptiveLoadingButton({
    super.key,
    this.onPressed,
    required this.child,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: PlatformUtils.isCupertino
                  ? const CupertinoActivityIndicator(radius: 10)
                  : const CircularProgressIndicator(strokeWidth: 2),
            )
          : child,
    );
  }
}
```

---

## Empty States

### Generic Empty State

```dart
class AdaptiveEmptyState extends StatelessWidget {
  final Widget icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AdaptiveEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTheme(
              data: IconThemeData(
                size: 64,
                color: PlatformUtils.isCupertino
                    ? CupertinoColors.secondaryLabel.resolveFrom(context)
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              child: icon,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: PlatformUtils.isCupertino
                  ? CupertinoTheme.of(context).textTheme.navTitleTextStyle
                  : Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: PlatformUtils.isCupertino
                    ? CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                          color: CupertinoColors.secondaryLabel,
                        )
                    : Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              AdaptiveButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
```

### Empty List

```dart
// Usage with a list
Widget build(BuildContext context) {
  if (items.isEmpty) {
    return AdaptiveEmptyState(
      icon: HugeIcon(icon: HugeIcons.strokeRoundedInbox, size: 64),
      title: 'No items yet',
      subtitle: 'Tap the button below to create your first item.',
      actionLabel: 'Create',
      onAction: _createItem,
    );
  }
  return ListView.builder(
    itemCount: items.length,
    itemBuilder: (_, i) => AdaptiveListTile(title: Text(items[i].name)),
  );
}
```

---

## Error States

### Inline Error

```dart
class AdaptiveErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AdaptiveErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final errorColor = PlatformUtils.isCupertino
        ? CupertinoColors.systemRed
        : Theme.of(context).colorScheme.error;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedAlert02,
              color: errorColor,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: PlatformUtils.isCupertino
                  ? CupertinoTheme.of(context).textTheme.textStyle
                  : Theme.of(context).textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              AdaptiveTextButton(
                onPressed: onRetry,
                child: Text(
                  'Retry',
                  style: TextStyle(color: errorColor),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### AsyncValue Pattern (Riverpod)

```dart
// Reusable async state handler
Widget buildAsyncState<T>({
  required AsyncValue<T> state,
  required Widget Function(T data) builder,
  String? loadingMessage,
}) {
  return state.when(
    loading: () => AdaptiveLoadingPage(message: loadingMessage),
    error: (error, _) => AdaptiveErrorState(
      message: error.toString(),
      onRetry: () {/* invalidate provider */},
    ),
    data: builder,
  );
}
```

### Error Banner (non-blocking)

```dart
class AdaptiveErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const AdaptiveErrorBanner({super.key, required this.message, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: CupertinoColors.systemRed.withOpacity(0.1),
        child: Row(
          children: [
            const HugeIcon(
              icon: HugeIcons.strokeRoundedAlert02,
              color: CupertinoColors.systemRed,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: const TextStyle(fontSize: 14))),
            if (onDismiss != null)
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 30,
                onPressed: onDismiss,
                child: const Icon(CupertinoIcons.xmark, size: 16),
              ),
          ],
        ),
      );
    }
    return MaterialBanner(
      content: Text(message),
      leading: const Icon(Icons.error_outline, color: Colors.red),
      actions: [
        if (onDismiss != null)
          TextButton(onPressed: onDismiss, child: const Text('Dismiss')),
      ],
    );
  }
}
```

---

## Disabled States

### Adaptive Opacity Wrapper

```dart
class AdaptiveDisabled extends StatelessWidget {
  final bool disabled;
  final Widget child;

  const AdaptiveDisabled({super.key, required this.disabled, required this.child});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: disabled,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: disabled ? 0.4 : 1.0,
        child: child,
      ),
    );
  }
}
```

### Usage

```dart
AdaptiveDisabled(
  disabled: !isFormValid,
  child: AdaptiveButton(
    onPressed: _submit,
    child: const Text('Submit'),
  ),
)
```

---

## Skeleton / Shimmer

### Shimmer Effect

```dart
class AdaptiveShimmer extends StatefulWidget {
  final Widget child;

  const AdaptiveShimmer({super.key, required this.child});

  @override
  State<AdaptiveShimmer> createState() => _AdaptiveShimmerState();
}

class _AdaptiveShimmerState extends State<AdaptiveShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ].map((s) => s.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}
```

### Skeleton Shapes

```dart
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: PlatformUtils.isCupertino
            ? CupertinoColors.systemGrey5
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class SkeletonCircle extends StatelessWidget {
  final double size;
  const SkeletonCircle({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: PlatformUtils.isCupertino
            ? CupertinoColors.systemGrey5
            : Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
    );
  }
}
```

### Skeleton List Tile

```dart
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveShimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const SkeletonCircle(size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: double.infinity, height: 14),
                  const SizedBox(height: 8),
                  SkeletonBox(width: 120, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Usage: loading list
ListView.builder(
  itemCount: 8,
  itemBuilder: (_, __) => const SkeletonListTile(),
)
```

### Skeleton Card

```dart
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveShimmer(
      child: AdaptiveCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: double.infinity, height: 160, borderRadius: 8),
            const SizedBox(height: 12),
            SkeletonBox(width: double.infinity, height: 16),
            const SizedBox(height: 8),
            SkeletonBox(width: 200, height: 14),
          ],
        ),
      ),
    );
  }
}
```
