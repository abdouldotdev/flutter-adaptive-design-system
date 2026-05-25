import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_utils.dart';

/// An item for use in [AdaptivePopupMenu].
class AdaptiveMenuItem<T> {
  final String label;
  final IconData? icon;
  final T? value;
  final bool isDestructive;
  final bool enabled;

  const AdaptiveMenuItem({
    required this.label,
    this.icon,
    this.value,
    this.isDestructive = false,
    this.enabled = true,
  });
}

/// Adaptive popup menu that renders [PopupMenuButton] on Material platforms
/// and a [CupertinoActionSheet] triggered by tap on Cupertino platforms.
class AdaptivePopupMenu<T> extends StatelessWidget {
  /// The child widget that triggers the menu.
  final Widget child;

  /// The icon shown in the trigger button. Used when [child] is not needed
  /// for Material [PopupMenuButton]. If [child] is provided, the child
  /// is used instead on both platforms.
  final IconData? icon;

  /// The menu items to display.
  final List<AdaptiveMenuItem<T>> items;

  /// Called when a menu item is selected.
  final ValueChanged<T?>? onSelected;

  /// Optional title for the Cupertino action sheet.
  final String? title;

  /// Optional message for the Cupertino action sheet.
  final String? message;

  /// Optional tooltip for the Material popup menu button.
  final String? tooltip;

  const AdaptivePopupMenu({
    super.key,
    required this.child,
    required this.items,
    this.icon,
    this.onSelected,
    this.title,
    this.message,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return _buildCupertinoMenu(context);
    }
    return _buildMaterialMenu(context);
  }

  Widget _buildMaterialMenu(BuildContext context) {
    return PopupMenuButton<T>(
      tooltip: tooltip,
      onSelected: onSelected,
      itemBuilder: (context) {
        return items.map((item) {
          return PopupMenuItem<T>(
            value: item.value,
            enabled: item.enabled,
            child: Row(
              children: [
                if (item.icon != null) ...[
                  Icon(
                    item.icon,
                    size: 20,
                    color: item.isDestructive
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  item.label,
                  style: TextStyle(
                    color: item.isDestructive
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      child: child,
    );
  }

  Widget _buildCupertinoMenu(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCupertinoSheet(context),
      child: child,
    );
  }

  void _showCupertinoSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: title != null ? Text(title!) : null,
        message: message != null ? Text(message!) : null,
        actions: items
            .where((item) => item.enabled)
            .map((item) {
          return CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              onSelected?.call(item.value);
            },
            isDestructiveAction: item.isDestructive,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (item.icon != null) ...[
                  Icon(item.icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(item.label),
              ],
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}
