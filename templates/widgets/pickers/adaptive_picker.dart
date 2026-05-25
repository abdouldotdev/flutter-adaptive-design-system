import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_utils.dart';

/// Adaptive generic picker that renders a dialog with [ListWheelScrollView]
/// on Material platforms and a [CupertinoPicker] in a modal sheet on
/// Cupertino platforms.
class AdaptivePicker {
  const AdaptivePicker._();

  /// Shows a platform-adaptive picker and returns the selected index,
  /// or `null` if dismissed.
  static Future<int?> show({
    required BuildContext context,
    required List<String> items,
    int initialIndex = 0,
    String? title,
    String? cancelText,
    String? confirmText,
    double itemExtent = 40.0,
  }) {
    if (PlatformUtils.isCupertino) {
      return _showCupertinoPicker(
        context: context,
        items: items,
        initialIndex: initialIndex,
        title: title,
        cancelText: cancelText,
        confirmText: confirmText,
        itemExtent: itemExtent,
      );
    }
    return _showMaterialPicker(
      context: context,
      items: items,
      initialIndex: initialIndex,
      title: title,
      cancelText: cancelText,
      confirmText: confirmText,
      itemExtent: itemExtent,
    );
  }

  /// Shows a platform-adaptive picker and returns the selected value,
  /// or `null` if dismissed.
  static Future<T?> showValue<T>({
    required BuildContext context,
    required List<T> items,
    required String Function(T item) labelBuilder,
    int initialIndex = 0,
    String? title,
    String? cancelText,
    String? confirmText,
    double itemExtent = 40.0,
  }) async {
    final labels = items.map(labelBuilder).toList();
    final index = await show(
      context: context,
      items: labels,
      initialIndex: initialIndex,
      title: title,
      cancelText: cancelText,
      confirmText: confirmText,
      itemExtent: itemExtent,
    );
    if (index != null && index >= 0 && index < items.length) {
      return items[index];
    }
    return null;
  }

  static Future<int?> _showMaterialPicker({
    required BuildContext context,
    required List<String> items,
    required int initialIndex,
    String? title,
    String? cancelText,
    String? confirmText,
    required double itemExtent,
  }) {
    int selectedIndex = initialIndex;

    return showDialog<int>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: title != null ? Text(title) : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          content: SizedBox(
            height: 200,
            width: 280,
            child: StatefulBuilder(
              builder: (context, setState) {
                final scrollController = FixedExtentScrollController(
                  initialItem: initialIndex,
                );
                return ListWheelScrollView.useDelegate(
                  controller: scrollController,
                  itemExtent: itemExtent,
                  physics: const FixedExtentScrollPhysics(),
                  diameterRatio: 1.5,
                  onSelectedItemChanged: (index) {
                    selectedIndex = index;
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: items.length,
                    builder: (context, index) {
                      return Center(
                        child: Text(
                          items[index],
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: index == selectedIndex
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(cancelText ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(selectedIndex),
              child: Text(confirmText ?? 'OK'),
            ),
          ],
        );
      },
    );
  }

  static Future<int?> _showCupertinoPicker({
    required BuildContext context,
    required List<String> items,
    required int initialIndex,
    String? title,
    String? cancelText,
    String? confirmText,
    required double itemExtent,
  }) async {
    int selectedIndex = initialIndex;

    final result = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (context) {
        final cupertinoTheme = CupertinoTheme.of(context);
        return Container(
          height: title != null ? 340 : 300,
          color: cupertinoTheme.scaffoldBackgroundColor,
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
                    if (title != null)
                      Text(
                        title,
                        style: cupertinoTheme.textTheme.navTitleTextStyle,
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
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: initialIndex,
                  ),
                  itemExtent: itemExtent,
                  onSelectedItemChanged: (index) {
                    selectedIndex = index;
                  },
                  children: items
                      .map(
                        (item) => Center(
                          child: Text(
                            item,
                            style:
                                cupertinoTheme.textTheme.pickerTextStyle,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result == true) return selectedIndex;
    return null;
  }
}
