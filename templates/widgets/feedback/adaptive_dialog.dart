import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_utils.dart';

/// An action for use in [AdaptiveDialog].
class AdaptiveDialogAction {
  final String label;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final bool isDefault;

  const AdaptiveDialogAction({
    required this.label,
    this.onPressed,
    this.isDestructive = false,
    this.isDefault = false,
  });
}

/// Adaptive dialog that renders [AlertDialog] on Material platforms
/// and [CupertinoAlertDialog] on Cupertino platforms.
class AdaptiveDialog {
  const AdaptiveDialog._();

  /// Shows a platform-adaptive dialog.
  ///
  /// Returns the value passed to [Navigator.pop] when the dialog is dismissed.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? content,
    Widget? contentWidget,
    List<AdaptiveDialogAction> actions = const [],
    bool barrierDismissible = true,
  }) {
    if (PlatformUtils.isCupertino) {
      return _showCupertinoDialog<T>(
        context: context,
        title: title,
        content: content,
        contentWidget: contentWidget,
        actions: actions,
        barrierDismissible: barrierDismissible,
      );
    }
    return _showMaterialDialog<T>(
      context: context,
      title: title,
      content: content,
      contentWidget: contentWidget,
      actions: actions,
      barrierDismissible: barrierDismissible,
    );
  }

  static Future<T?> _showMaterialDialog<T>({
    required BuildContext context,
    required String title,
    String? content,
    Widget? contentWidget,
    required List<AdaptiveDialogAction> actions,
    required bool barrierDismissible,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: contentWidget ?? (content != null ? Text(content) : null),
        actions: actions.map((action) {
          return TextButton(
            onPressed: action.onPressed ?? () => Navigator.of(context).pop(),
            child: Text(
              action.label,
              style: TextStyle(
                color: action.isDestructive
                    ? Theme.of(context).colorScheme.error
                    : null,
                fontWeight: action.isDefault ? FontWeight.bold : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  static Future<T?> _showCupertinoDialog<T>({
    required BuildContext context,
    required String title,
    String? content,
    Widget? contentWidget,
    required List<AdaptiveDialogAction> actions,
    required bool barrierDismissible,
  }) {
    return showCupertinoDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: contentWidget ?? (content != null ? Text(content) : null),
        actions: actions.map((action) {
          return CupertinoDialogAction(
            onPressed: action.onPressed ?? () => Navigator.of(context).pop(),
            isDestructiveAction: action.isDestructive,
            isDefaultAction: action.isDefault,
            child: Text(action.label),
          );
        }).toList(),
      ),
    );
  }
}
