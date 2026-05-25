import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_utils.dart';

/// An action for use in [AdaptiveActionSheet].
class AdaptiveSheetAction {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final bool isDefault;

  const AdaptiveSheetAction({
    required this.label,
    this.icon,
    this.onPressed,
    this.isDestructive = false,
    this.isDefault = false,
  });
}

/// Adaptive action sheet that renders a [BottomSheet] on Material platforms
/// and a [CupertinoActionSheet] on Cupertino platforms.
class AdaptiveActionSheet {
  const AdaptiveActionSheet._();

  /// Shows a platform-adaptive action sheet.
  ///
  /// Returns the value passed to [Navigator.pop] when dismissed.
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    String? message,
    required List<AdaptiveSheetAction> actions,
    AdaptiveSheetAction? cancelAction,
  }) {
    if (PlatformUtils.isCupertino) {
      return _showCupertinoSheet<T>(
        context: context,
        title: title,
        message: message,
        actions: actions,
        cancelAction: cancelAction,
      );
    }
    return _showMaterialSheet<T>(
      context: context,
      title: title,
      message: message,
      actions: actions,
      cancelAction: cancelAction,
    );
  }

  static Future<T?> _showMaterialSheet<T>({
    required BuildContext context,
    String? title,
    String? message,
    required List<AdaptiveSheetAction> actions,
    AdaptiveSheetAction? cancelAction,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null || message != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      children: [
                        if (title != null)
                          Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        if (message != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            message,
                            style: theme.textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                if (title != null || message != null) const Divider(height: 1),
                ...actions.map((action) {
                  return ListTile(
                    leading: action.icon != null ? Icon(action.icon) : null,
                    title: Text(
                      action.label,
                      style: TextStyle(
                        color: action.isDestructive
                            ? theme.colorScheme.error
                            : null,
                        fontWeight:
                            action.isDefault ? FontWeight.bold : null,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      action.onPressed?.call();
                    },
                  );
                }),
                if (cancelAction != null) ...[
                  const Divider(height: 1),
                  ListTile(
                    title: Text(
                      cancelAction.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      cancelAction.onPressed?.call();
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<T?> _showCupertinoSheet<T>({
    required BuildContext context,
    String? title,
    String? message,
    required List<AdaptiveSheetAction> actions,
    AdaptiveSheetAction? cancelAction,
  }) {
    return showCupertinoModalPopup<T>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: title != null ? Text(title) : null,
        message: message != null ? Text(message) : null,
        actions: actions.map((action) {
          return CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              action.onPressed?.call();
            },
            isDestructiveAction: action.isDestructive,
            isDefaultAction: action.isDefault,
            child: Text(action.label),
          );
        }).toList(),
        cancelButton: cancelAction != null
            ? CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                  cancelAction.onPressed?.call();
                },
                child: Text(cancelAction.label),
              )
            : null,
      ),
    );
  }
}
