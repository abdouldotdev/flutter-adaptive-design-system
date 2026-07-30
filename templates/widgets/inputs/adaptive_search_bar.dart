import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../foundation/platform_utils.dart';

/// Adaptive search bar.
///
/// Material: [SearchBar] with M3 styling.
/// Cupertino: [CupertinoSearchTextField] with native iOS styling.
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
  final Color? backgroundColor;

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
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return Padding(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: CupertinoSearchTextField(
          controller: controller,
          placeholder: placeholder ?? 'Search',
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          onTap: onTap,
          focusNode: focusNode,
          autofocus: autofocus,
          prefixIcon: leading ??
              const HugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                color: CupertinoColors.systemGrey,
                size: 20,
              ),
          suffixIcon: const Icon(
            CupertinoIcons.clear_circled_solid,
            color: CupertinoColors.systemGrey,
            size: 18,
          ),
          backgroundColor: backgroundColor,
        ),
      );
    }

    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SearchBar(
        controller: controller,
        hintText: placeholder ?? 'Search',
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onTap: onTap,
        focusNode: focusNode,
        autoFocus: autofocus,
        leading: leading ??
            HugeIcon(
              icon: HugeIcons.strokeRoundedSearch01,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
        trailing: trailing != null ? [trailing!] : null,
        backgroundColor: backgroundColor != null
            ? WidgetStatePropertyAll(backgroundColor!)
            : null,
        elevation: const WidgetStatePropertyAll(0.5),
      ),
    );
  }
}
