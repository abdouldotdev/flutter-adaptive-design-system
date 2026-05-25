# Widget Implementations

Complete implementation code for all 37 adaptive widgets. Each widget shows the recommended pattern.

## Table of Contents

1. [Navigation & Structure](#navigation--structure)
2. [Content & Lists](#content--lists)
3. [Buttons & Actions](#buttons--actions)
4. [Forms & Inputs](#forms--inputs)
5. [Chips & Tags](#chips--tags)
6. [Feedback & Overlays](#feedback--overlays)
7. [Scroll & Refresh](#scroll--refresh)
8. [Pickers & Dates](#pickers--dates)

---

## Navigation & Structure

### AdaptiveScaffold (Pattern A)

```dart
class AdaptiveScaffold extends PlatformWidget<Scaffold, CupertinoPageScaffold> {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final ObstructingPreferredSizeWidget? cupertinoNavigationBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;

  const AdaptiveScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.cupertinoNavigationBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
  });

  @override
  Scaffold buildMaterialWidget(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      backgroundColor: backgroundColor,
    );
  }

  @override
  CupertinoPageScaffold buildCupertinoWidget(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: cupertinoNavigationBar,
      backgroundColor: backgroundColor ?? CupertinoColors.systemGroupedBackground,
      child: bottomNavigationBar != null
          ? Column(children: [Expanded(child: body), bottomNavigationBar!])
          : body,
    );
  }
}
```

### AdaptiveAppBar (Pattern B)

Implements both `PreferredSizeWidget` and `ObstructingPreferredSizeWidget` so it works in both Scaffold and CupertinoPageScaffold.

```dart
class AdaptiveAppBar extends StatelessWidget
    implements PreferredSizeWidget, ObstructingPreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool automaticallyImplyLeading;

  const AdaptiveAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.automaticallyImplyLeading = true,
  });

  @override
  Size get preferredSize => PlatformUtils.isCupertino
      ? const Size.fromHeight(44.0)
      : const Size.fromHeight(kToolbarHeight);

  @override
  bool shouldFullyObstruct(BuildContext context) => true;

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return CupertinoNavigationBar(
        middle: titleWidget ?? (title != null ? Text(title!) : null),
        leading: leading,
        trailing: actions != null
            ? Row(mainAxisSize: MainAxisSize.min, children: actions!)
            : null,
        backgroundColor: backgroundColor,
        automaticallyImplyLeading: automaticallyImplyLeading,
      );
    }
    return AppBar(
      title: titleWidget ?? (title != null ? Text(title!) : null),
      leading: leading,
      actions: actions,
      backgroundColor: backgroundColor,
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }
}
```

### AdaptiveBottomNav (Pattern B)

```dart
class AdaptiveBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;

  const AdaptiveBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return CupertinoTabBar(
        currentIndex: currentIndex,
        onTap: onTap,
        items: items,
      );
    }
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: items
          .map((item) => NavigationDestination(
                icon: item.icon,
                selectedIcon: item.activeIcon,
                label: item.label ?? '',
              ))
          .toList(),
    );
  }
}
```

### AdaptiveSliverAppBar (Pattern B)

```dart
class AdaptiveSliverAppBar extends StatelessWidget {
  final String largeTitle;
  final Widget? leading;
  final Widget? trailing;

  const AdaptiveSliverAppBar({
    super.key,
    required this.largeTitle,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return CupertinoSliverNavigationBar(
        largeTitle: Text(largeTitle),
        leading: leading,
        trailing: trailing,
      );
    }
    return SliverAppBar.large(
      title: Text(largeTitle),
      leading: leading,
      actions: trailing != null ? [trailing!] : null,
    );
  }
}
```

### AdaptiveTabBar (Pattern B — Stateful)

```dart
class AdaptiveTabBar extends StatefulWidget {
  final List<String> tabs;
  final List<Widget> children;
  final int initialIndex;

  const AdaptiveTabBar({
    super.key,
    required this.tabs,
    required this.children,
    this.initialIndex = 0,
  });

  @override
  State<AdaptiveTabBar> createState() => _AdaptiveTabBarState();
}

class _AdaptiveTabBarState extends State<AdaptiveTabBar>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    if (PlatformUtils.isMaterial) {
      _tabController = TabController(
        length: widget.tabs.length,
        vsync: this,
        initialIndex: _currentIndex,
      );
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CupertinoSlidingSegmentedControl<int>(
              groupValue: _currentIndex,
              children: {
                for (var i = 0; i < widget.tabs.length; i++)
                  i: Text(widget.tabs[i]),
              },
              onValueChanged: (i) => setState(() => _currentIndex = i!),
            ),
          ),
          Expanded(child: widget.children[_currentIndex]),
        ],
      );
    }
    return Column(
      children: [
        TabBar(controller: _tabController, tabs: widget.tabs.map((t) => Tab(text: t)).toList()),
        Expanded(child: TabBarView(controller: _tabController, children: widget.children)),
      ],
    );
  }
}
```

### AdaptiveNavigationDrawer (Pattern B)

```dart
class AdaptiveNavigationDrawer extends StatelessWidget {
  final List<AdaptiveDrawerItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemTap;
  final Widget? header;

  const AdaptiveNavigationDrawer({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemTap,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return _buildCupertinoDrawer(context);
    }
    return NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: onItemTap,
      children: [
        if (header != null) header!,
        ...items.map((item) => NavigationDrawerDestination(
              icon: item.icon,
              label: Text(item.label),
            )),
      ],
    );
  }

  Widget _buildCupertinoDrawer(BuildContext context) {
    return Container(
      width: 280,
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (header != null) header!,
            ...List.generate(items.length, (i) {
              final selected = i == selectedIndex;
              return CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                onPressed: () => onItemTap(i),
                child: Row(
                  children: [
                    items[i].icon,
                    const SizedBox(width: 12),
                    Text(
                      items[i].label,
                      style: TextStyle(
                        color: selected
                            ? CupertinoColors.activeBlue
                            : CupertinoColors.label.resolveFrom(context),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class AdaptiveDrawerItem {
  final Widget icon;
  final String label;
  const AdaptiveDrawerItem({required this.icon, required this.label});
}
```

---

## Content & Lists

### AdaptiveCard (Pattern A)

```dart
class AdaptiveCard extends PlatformWidget<Card, Container> {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? elevation;

  const AdaptiveCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.elevation,
  });

  @override
  Card buildMaterialWidget(BuildContext context) {
    return Card(
      elevation: elevation ?? 1,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(padding: padding ?? const EdgeInsets.all(16), child: child),
    );
  }

  @override
  Container buildCupertinoWidget(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
```

### AdaptiveListTile (Pattern A)

```dart
class AdaptiveListTile extends PlatformWidget<ListTile, CupertinoListTile> {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const AdaptiveListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  ListTile buildMaterialWidget(BuildContext context) {
    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
    );
  }

  @override
  CupertinoListTile buildCupertinoWidget(BuildContext context) {
    return CupertinoListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing ?? const CupertinoListTileChevron(),
      onTap: onTap,
    );
  }
}
```

### AdaptiveListSection (Pattern B)

```dart
class AdaptiveListSection extends StatelessWidget {
  final String? header;
  final String? footer;
  final List<Widget> children;

  const AdaptiveListSection({
    super.key,
    this.header,
    this.footer,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return CupertinoListSection.insetGrouped(
        header: header != null ? Text(header!) : null,
        footer: footer != null ? Text(footer!) : null,
        children: children,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(header!, style: Theme.of(context).textTheme.titleSmall),
          ),
        ...children.expand((child) => [child, const Divider(height: 1)]),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(footer!, style: Theme.of(context).textTheme.bodySmall),
          ),
      ],
    );
  }
}
```

### AdaptiveDivider (Pattern A)

```dart
class AdaptiveDivider extends PlatformWidget<Divider, Container> {
  final double? indent;
  const AdaptiveDivider({super.key, this.indent});

  @override
  Divider buildMaterialWidget(BuildContext context) =>
      Divider(height: 1, indent: indent);

  @override
  Container buildCupertinoWidget(BuildContext context) {
    return Container(
      height: 0.5,
      margin: EdgeInsets.only(left: indent ?? 16),
      color: CupertinoColors.separator.resolveFrom(context),
    );
  }
}
```

---

## Buttons & Actions

### AdaptiveButton (Pattern B)

```dart
class AdaptiveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  const AdaptiveButton({
    super.key,
    this.onPressed,
    required this.child,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return CupertinoButton.filled(
        onPressed: onPressed,
        padding: padding,
        child: child,
      );
    }
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        padding: padding,
      ),
      child: child,
    );
  }
}
```

### AdaptiveTextButton (Pattern B)

```dart
class AdaptiveTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const AdaptiveTextButton({super.key, this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return CupertinoButton(onPressed: onPressed, child: child);
    }
    return TextButton(onPressed: onPressed, child: child);
  }
}
```

### AdaptiveIconButton (Pattern B)

```dart
class AdaptiveIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final double? size;

  const AdaptiveIconButton({super.key, this.onPressed, required this.icon, this.size});

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        minSize: size ?? 44,
        onPressed: onPressed,
        child: icon,
      );
    }
    return IconButton(
      onPressed: onPressed,
      icon: icon,
      iconSize: size,
    );
  }
}
```

### AdaptiveFAB (Pattern B)

```dart
/// FAB on Android. On iOS, FABs are an anti-pattern —
/// provide a nav bar trailing button instead.
class AdaptiveFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final String? tooltip;

  const AdaptiveFAB({super.key, this.onPressed, required this.icon, this.tooltip});

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      // iOS: no FAB — typically put action in nav bar trailing
      return const SizedBox.shrink();
    }
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      child: icon,
    );
  }
}
```

### AdaptivePopupMenu (Pattern B)

```dart
class AdaptivePopupMenu<T> extends StatelessWidget {
  final List<AdaptiveMenuItem<T>> items;
  final ValueChanged<T> onSelected;
  final Widget? icon;

  const AdaptivePopupMenu({
    super.key,
    required this.items,
    required this.onSelected,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _showCupertinoMenu(context),
        child: icon ?? const Icon(CupertinoIcons.ellipsis_vertical),
      );
    }
    return PopupMenuButton<T>(
      onSelected: onSelected,
      icon: icon,
      itemBuilder: (_) => items
          .map((item) => PopupMenuItem<T>(value: item.value, child: Text(item.label)))
          .toList(),
    );
  }

  void _showCupertinoMenu(BuildContext context) {
    showCupertinoModalPopup<T>(
      context: context,
      builder: (_) => CupertinoActionSheet(
        actions: items.map((item) => CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            onSelected(item.value);
          },
          child: Text(item.label),
        )).toList(),
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}

class AdaptiveMenuItem<T> {
  final T value;
  final String label;
  final Widget? icon;
  const AdaptiveMenuItem({required this.value, required this.label, this.icon});
}
```

---

## Forms & Inputs

### AdaptiveTextField (Pattern B)

```dart
class AdaptiveTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final String? label;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final FocusNode? focusNode;
  final Widget? prefix;
  final Widget? suffix;

  const AdaptiveTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.label,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.focusNode,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return CupertinoTextField(
        controller: controller,
        placeholder: placeholder ?? label,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: maxLines,
        focusNode: focusNode,
        prefix: prefix,
        suffix: suffix,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: CupertinoColors.tertiarySystemFill,
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        hintText: placeholder,
        prefixIcon: prefix,
        suffixIcon: suffix,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
```

### AdaptiveSearchBar (Pattern B)

```dart
class AdaptiveSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final bool autofocus;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const AdaptiveSearchBar({
    super.key,
    this.controller,
    this.placeholder,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.autofocus = false,
    this.leading,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: CupertinoSearchTextField(
          controller: controller,
          placeholder: placeholder ?? 'Search',
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          onTap: onTap,
          focusNode: focusNode,
          autofocus: autofocus,
        ),
      );
    }
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SearchBar(
        controller: controller,
        hintText: placeholder ?? 'Search',
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onTap: onTap,
        focusNode: focusNode,
        autoFocus: autofocus,
        leading: leading ?? const Icon(Icons.search),
        trailing: trailing != null ? [trailing!] : null,
        elevation: const WidgetStatePropertyAll(0.5),
      ),
    );
  }
}
```

### AdaptiveSwitch (Pattern A)

```dart
class AdaptiveSwitch extends PlatformWidget<Switch, CupertinoSwitch> {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const AdaptiveSwitch({super.key, required this.value, this.onChanged});

  @override
  Switch buildMaterialWidget(BuildContext context) =>
      Switch(value: value, onChanged: onChanged);

  @override
  CupertinoSwitch buildCupertinoWidget(BuildContext context) =>
      CupertinoSwitch(value: value, onChanged: onChanged);
}
```

### AdaptiveSlider (Pattern A)

```dart
class AdaptiveSlider extends PlatformWidget<Slider, CupertinoSlider> {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;

  const AdaptiveSlider({
    super.key,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    this.onChanged,
  });

  @override
  Slider buildMaterialWidget(BuildContext context) =>
      Slider(value: value, min: min, max: max, onChanged: onChanged);

  @override
  CupertinoSlider buildCupertinoWidget(BuildContext context) =>
      CupertinoSlider(value: value, min: min, max: max, onChanged: onChanged);
}
```

### AdaptiveCheckbox (Pattern A)

```dart
class AdaptiveCheckbox extends PlatformWidget<Checkbox, CupertinoCheckbox> {
  final bool value;
  final ValueChanged<bool?>? onChanged;

  const AdaptiveCheckbox({super.key, required this.value, this.onChanged});

  @override
  Checkbox buildMaterialWidget(BuildContext context) =>
      Checkbox(value: value, onChanged: onChanged);

  @override
  CupertinoCheckbox buildCupertinoWidget(BuildContext context) =>
      CupertinoCheckbox(value: value, onChanged: onChanged);
}
```

### AdaptiveSegmentedControl (Pattern B)

```dart
class AdaptiveSegmentedControl<T extends Object> extends StatelessWidget {
  final Map<T, Widget> children;
  final T groupValue;
  final ValueChanged<T> onValueChanged;

  const AdaptiveSegmentedControl({
    super.key,
    required this.children,
    required this.groupValue,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return CupertinoSlidingSegmentedControl<T>(
        groupValue: groupValue,
        children: children,
        onValueChanged: (v) => onValueChanged(v as T),
      );
    }
    return SegmentedButton<T>(
      segments: children.entries
          .map((e) => ButtonSegment<T>(value: e.key, label: e.value))
          .toList(),
      selected: {groupValue},
      onSelectionChanged: (s) => onValueChanged(s.first),
    );
  }
}
```

### AdaptiveFormField (Pattern B)

```dart
class AdaptiveFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? placeholder;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;

  const AdaptiveFormField({
    super.key,
    this.controller,
    this.label,
    this.placeholder,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return _CupertinoFormField(
        controller: controller,
        placeholder: placeholder ?? label,
        validator: validator,
        keyboardType: keyboardType,
        obscureText: obscureText,
      );
    }
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: placeholder,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
    );
  }
}

class _CupertinoFormField extends FormField<String> {
  _CupertinoFormField({
    TextEditingController? controller,
    String? placeholder,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) : super(
          initialValue: controller?.text ?? '',
          validator: validator,
          builder: (state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CupertinoTextField(
                  controller: controller,
                  placeholder: placeholder,
                  keyboardType: keyboardType,
                  obscureText: obscureText,
                  onChanged: (v) => state.didChange(v),
                  decoration: BoxDecoration(
                    color: CupertinoColors.tertiarySystemFill,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(
                      state.errorText!,
                      style: const TextStyle(color: CupertinoColors.systemRed, fontSize: 12),
                    ),
                  ),
              ],
            );
          },
        );
}
```

---

## Feedback & Overlays

### AdaptiveDialog (Pattern C)

```dart
class AdaptiveDialog {
  const AdaptiveDialog._();

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? content,
    List<AdaptiveDialogAction> actions = const [],
  }) {
    if (PlatformUtils.isCupertino) {
      return showCupertinoDialog<T>(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: Text(title),
          content: content != null ? Text(content) : null,
          actions: actions
              .map((a) => CupertinoDialogAction(
                    isDefaultAction: a.isDefault,
                    isDestructiveAction: a.isDestructive,
                    onPressed: () => Navigator.pop(context, a.value),
                    child: Text(a.label),
                  ))
              .toList(),
        ),
      );
    }
    return showDialog<T>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: content != null ? Text(content) : null,
        actions: actions
            .map((a) => TextButton(
                  onPressed: () => Navigator.pop(context, a.value),
                  child: Text(
                    a.label,
                    style: a.isDestructive ? const TextStyle(color: Colors.red) : null,
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class AdaptiveDialogAction<T> {
  final String label;
  final T? value;
  final bool isDefault;
  final bool isDestructive;
  const AdaptiveDialogAction({
    required this.label,
    this.value,
    this.isDefault = false,
    this.isDestructive = false,
  });
}
```

### AdaptiveActionSheet (Pattern C)

```dart
class AdaptiveActionSheet {
  const AdaptiveActionSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? message,
    required List<AdaptiveSheetAction<T>> actions,
    AdaptiveSheetAction<T>? cancelAction,
  }) {
    if (PlatformUtils.isCupertino) {
      return showCupertinoModalPopup<T>(
        context: context,
        builder: (_) => CupertinoActionSheet(
          title: title != null ? Text(title) : null,
          message: message != null ? Text(message) : null,
          actions: actions
              .map((a) => CupertinoActionSheetAction(
                    isDestructiveAction: a.isDestructive,
                    onPressed: () => Navigator.pop(context, a.value),
                    child: Text(a.label),
                  ))
              .toList(),
          cancelButton: cancelAction != null
              ? CupertinoActionSheetAction(
                  isDefaultAction: true,
                  onPressed: () => Navigator.pop(context),
                  child: Text(cancelAction.label),
                )
              : null,
        ),
      );
    }
    return showModalBottomSheet<T>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) Padding(
              padding: const EdgeInsets.all(16),
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            ...actions.map((a) => ListTile(
              title: Text(a.label,
                style: a.isDestructive ? const TextStyle(color: Colors.red) : null),
              onTap: () => Navigator.pop(context, a.value),
            )),
          ],
        ),
      ),
    );
  }
}

class AdaptiveSheetAction<T> {
  final String label;
  final T? value;
  final bool isDestructive;
  const AdaptiveSheetAction({required this.label, this.value, this.isDestructive = false});
}
```

### AdaptiveSnackBar (Pattern C)

```dart
class AdaptiveSnackBar {
  const AdaptiveSnackBar._();

  static void show({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    if (PlatformUtils.isCupertino) {
      _showCupertinoToast(context, message, duration);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: actionLabel != null
            ? SnackBarAction(label: actionLabel, onPressed: onAction ?? () {})
            : null,
      ),
    );
  }

  static void _showCupertinoToast(BuildContext context, String message, Duration duration) {
    final overlay = Navigator.of(context).overlay;
    if (overlay == null) return;
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 32,
        right: 32,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey.withOpacity(0.95),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: CupertinoColors.white, fontSize: 15)),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(duration, () => entry.remove());
  }
}
```

### AdaptiveProgressIndicator (Pattern A)

```dart
class AdaptiveProgressIndicator
    extends PlatformWidget<CircularProgressIndicator, CupertinoActivityIndicator> {
  final double? radius;
  const AdaptiveProgressIndicator({super.key, this.radius});

  @override
  CircularProgressIndicator buildMaterialWidget(BuildContext context) =>
      const CircularProgressIndicator();

  @override
  CupertinoActivityIndicator buildCupertinoWidget(BuildContext context) =>
      CupertinoActivityIndicator(radius: radius ?? 10);
}
```

---

## Scroll & Refresh

### AdaptiveRefreshIndicator (Pattern B)

Use differently: Material wraps a `ListView`, Cupertino is a sliver inside `CustomScrollView`.

```dart
/// Material: Wrap your scrollable in AdaptiveRefreshIndicator.
/// Cupertino: Use AdaptiveRefreshIndicator.asSliver() inside CustomScrollView.
class AdaptiveRefreshIndicator extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const AdaptiveRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      // For Cupertino, use CustomScrollView with asSliver()
      return child;
    }
    return RefreshIndicator(onRefresh: onRefresh, child: child);
  }

  /// Use inside CustomScrollView slivers list for iOS pull-to-refresh.
  static Widget asSliver({required Future<void> Function() onRefresh}) {
    return CupertinoSliverRefreshControl(onRefresh: onRefresh);
  }
}
```

---

## Pickers & Dates

### AdaptiveDatePicker (Pattern C)

```dart
class AdaptiveDatePicker {
  const AdaptiveDatePicker._();

  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    if (PlatformUtils.isCupertino) {
      return _showCupertinoPicker(context, initialDate, firstDate, lastDate);
    }
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
  }

  static Future<DateTime?> _showCupertinoPicker(
    BuildContext context,
    DateTime initial,
    DateTime first,
    DateTime last,
  ) async {
    DateTime selected = initial;
    final result = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (_) => Container(
        height: 280,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context, false),
                ),
                CupertinoButton(
                  child: const Text('Done'),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: initial,
                minimumDate: first,
                maximumDate: last,
                onDateTimeChanged: (d) => selected = d,
              ),
            ),
          ],
        ),
      ),
    );
    return result == true ? selected : null;
  }
}
```

### AdaptiveTimePicker (Pattern C)

```dart
class AdaptiveTimePicker {
  const AdaptiveTimePicker._();

  static Future<TimeOfDay?> show({
    required BuildContext context,
    required TimeOfDay initialTime,
  }) async {
    if (PlatformUtils.isCupertino) {
      return _showCupertinoPicker(context, initialTime);
    }
    return showTimePicker(context: context, initialTime: initialTime);
  }

  static Future<TimeOfDay?> _showCupertinoPicker(
    BuildContext context,
    TimeOfDay initial,
  ) async {
    DateTime selected = DateTime(2024, 1, 1, initial.hour, initial.minute);
    final result = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (_) => Container(
        height: 280,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context, false),
                ),
                CupertinoButton(
                  child: const Text('Done'),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: selected,
                onDateTimeChanged: (d) => selected = d,
              ),
            ),
          ],
        ),
      ),
    );
    return result == true ? TimeOfDay.fromDateTime(selected) : null;
  }
}
```
