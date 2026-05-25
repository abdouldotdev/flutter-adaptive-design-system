import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_utils.dart';

/// Adaptive time picker that uses [showTimePicker] on Material platforms
/// and a [CupertinoDatePicker] in time mode on Cupertino platforms.
class AdaptiveTimePicker {
  const AdaptiveTimePicker._();

  /// Shows a platform-adaptive time picker and returns the selected time,
  /// or `null` if dismissed.
  static Future<TimeOfDay?> show({
    required BuildContext context,
    required TimeOfDay initialTime,
    String? helpText,
    String? cancelText,
    String? confirmText,
    bool use24hFormat = false,
  }) {
    if (PlatformUtils.isCupertino) {
      return _showCupertinoPicker(
        context: context,
        initialTime: initialTime,
        cancelText: cancelText,
        confirmText: confirmText,
        use24hFormat: use24hFormat,
      );
    }
    return _showMaterialPicker(
      context: context,
      initialTime: initialTime,
      helpText: helpText,
      cancelText: cancelText,
      confirmText: confirmText,
    );
  }

  static Future<TimeOfDay?> _showMaterialPicker({
    required BuildContext context,
    required TimeOfDay initialTime,
    String? helpText,
    String? cancelText,
    String? confirmText,
  }) {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: helpText,
      cancelText: cancelText,
      confirmText: confirmText,
    );
  }

  static Future<TimeOfDay?> _showCupertinoPicker({
    required BuildContext context,
    required TimeOfDay initialTime,
    String? cancelText,
    String? confirmText,
    required bool use24hFormat,
  }) async {
    final now = DateTime.now();
    DateTime selectedDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      initialTime.hour,
      initialTime.minute,
    );

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
                mode: CupertinoDatePickerMode.time,
                initialDateTime: selectedDateTime,
                use24hFormat: use24hFormat,
                onDateTimeChanged: (dateTime) =>
                    selectedDateTime = dateTime,
              ),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      return TimeOfDay(
        hour: selectedDateTime.hour,
        minute: selectedDateTime.minute,
      );
    }
    return null;
  }
}
