import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_utils.dart';

/// An action for use in [AdaptiveContextMenu].
class ContextMenuAction {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isDestructive;

  const ContextMenuAction({
    required this.label,
    this.icon,
    this.onPressed,
    this.isDestructive = false,
  });
}

/// Adaptive context menu that renders a [PopupMenuButton] activated by
/// long press on Material platforms and [CupertinoContextMenu] on
/// Cupertino platforms.
class AdaptiveContextMenu extends StatelessWidget {
  /// The child widget that triggers the context menu on long press.
  final Widget child;

  /// A preview widget shown during the Cupertino context menu (iOS 13+ style).
  /// If null, the [child] is used as the preview.
  final Widget? previewBuilder;

  /// The context menu actions.
  final List<ContextMenuAction> actions;

  const AdaptiveContextMenu({
    super.key,
    required this.child,
    required this.actions,
    this.previewBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return _buildCupertinoContextMenu(context);
    }
    return _buildMaterialContextMenu(context);
  }

  Widget _buildMaterialContextMenu(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) {
        _showMaterialMenu(context, details.globalPosition);
      },
      child: child,
    );
  }

  void _showMaterialMenu(BuildContext context, Offset position) {
    final items = actions.map((action) {
      return PopupMenuItem<ContextMenuAction>(
        value: action,
        child: Row(
          children: [
            if (action.icon != null) ...[
              Icon(
                action.icon,
                size: 20,
                color: action.isDestructive
                    ? Theme.of(context).colorScheme.error
                    : null,
              ),
              const SizedBox(width: 12),
            ],
            Text(
              action.label,
              style: TextStyle(
                color: action.isDestructive
                    ? Theme.of(context).colorScheme.error
                    : null,
              ),
            ),
          ],
        ),
      );
    }).toList();

    showMenu<ContextMenuAction>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: items,
    ).then((selectedAction) {
      selectedAction?.onPressed?.call();
    });
  }

  Widget _buildCupertinoContextMenu(BuildContext context) {
    return CupertinoContextMenu(
      actions: actions.map((action) {
        return CupertinoContextMenuAction(
          onPressed: () {
            Navigator.of(context).pop();
            action.onPressed?.call();
          },
          isDestructiveAction: action.isDestructive,
          trailingIcon: action.icon,
          child: Text(action.label),
        );
      }).toList(),
      child: previewBuilder ?? child,
    );
  }
}
