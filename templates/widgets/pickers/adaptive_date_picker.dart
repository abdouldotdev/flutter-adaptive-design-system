import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_utils.dart';

/// Adaptive date picker that uses [showDatePicker] on Material platforms
/// and a [CupertinoDatePicker] in a modal sheet on Cupertino platforms.
class AdaptiveDatePicker {
  const AdaptiveDatePicker._();

  /// Shows a platform-adaptive date picker and returns the selected date,
  /// or `null` if dismissed.
  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    String? helpText,
    String? cancelText,
    String? confirmText,
    CupertinoDatePickerMode cupertinoMode = CupertinoDatePickerMode.date,
  }) {
    if (PlatformUtils.isCupertino) {
      return _showCupertinoPicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        cancelText: cancelText,
        confirmText: confirmText,
        mode: cupertinoMode,
      );
    }
    return _showMaterialPicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: helpText,
      cancelText: cancelText,
      confirmText: confirmText,
    );
  }

  static Future<DateTime?> _showMaterialPicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    String? helpText,
    String? cancelText,
    String? confirmText,
  }) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: helpText,
      cancelText: cancelText,
      confirmText: confirmText,
    );
  }

  static Future<DateTime?> _showCupertinoPicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    String? cancelText,
    String? confirmText,
    required CupertinoDatePickerMode mode,
  }) async {
    DateTime selectedDate = initialDate;

    final result = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoTheme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            SizedBox(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(cancelText ?? 'Cancel'),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      confirmText ?? 'Done',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: CupertinoDatePicker(
                mode: mode,
                initialDateTime: initialDate,
                minimumDate: firstDate,
                maximumDate: lastDate,
                onDateTimeChanged: (date) => selectedDate = date,
              ),
            ),
          ],
        ),
      ),
    );

    if (result == true) return selectedDate;
    return null;
  }
}
