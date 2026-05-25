import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_utils.dart';

/// Adaptive radio button.
///
/// Material: [Radio<T>] with M3 styling.
/// Cupertino: Custom circular radio using [CupertinoColors] because
/// Flutter does not ship a [CupertinoRadio] for all SDK versions.
class AdaptiveRadio<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T?>? onChanged;
  final Color? activeColor;
  final bool toggleable;

  const AdaptiveRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.activeColor,
    this.toggleable = false,
  });

  bool get _isSelected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return _buildCupertinoRadio(context);
    }

    // ignore: deprecated_member_use
    return Radio<T>(
      value: value,
      // ignore: deprecated_member_use
      groupValue: groupValue,
      // ignore: deprecated_member_use
      onChanged: onChanged,
      activeColor: activeColor,
      toggleable: toggleable,
    );
  }

  Widget _buildCupertinoRadio(BuildContext context) {
    final color =
        activeColor ?? CupertinoTheme.of(context).primaryColor;
    final isDisabled = onChanged == null;

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
              if (_isSelected && toggleable) {
                onChanged?.call(null);
              } else if (!_isSelected) {
                onChanged?.call(value);
              }
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _isSelected
                ? color
                : (isDisabled
                    ? CupertinoColors.quaternarySystemFill
                    : CupertinoColors.separator),
            width: _isSelected ? 6.5 : 1.5,
          ),
        ),
      ),
    );
  }
}
