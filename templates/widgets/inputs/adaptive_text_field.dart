import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundation/platform_utils.dart';

/// Adaptive text field.
///
/// Material: [TextField] with [OutlineInputBorder] (outlined variant).
/// Cupertino: [CupertinoTextField] with native iOS styling.
class AdaptiveTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final String? labelText;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final EdgeInsetsGeometry? padding;
  final TextStyle? style;
  final TextAlign textAlign;
  final bool autocorrect;
  final bool enableSuggestions;

  const AdaptiveTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.labelText,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.onTap,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.padding,
    this.style,
    this.textAlign = TextAlign.start,
    this.autocorrect = false,
    this.enableSuggestions = false,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return CupertinoTextField(
        controller: controller,
        placeholder: placeholder ?? labelText,
        prefix: prefix != null
            ? Padding(
                padding: const EdgeInsetsDirectional.only(start: 8),
                child: prefix,
              )
            : null,
        suffix: suffix,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onEditingComplete: onEditingComplete,
        onTap: onTap,
        focusNode: focusNode,
        enabled: enabled,
        readOnly: readOnly,
        autofocus: autofocus,
        maxLines: maxLines,
        minLines: minLines,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        padding:
            padding as EdgeInsets? ?? const EdgeInsets.all(12),
        style: style,
        textAlign: textAlign,
        autocorrect: autocorrect,
        enableSuggestions: enableSuggestions,
        decoration: BoxDecoration(
          border: Border.all(
            color: CupertinoColors.separator,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
      );
    }

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: placeholder,
        labelText: labelText,
        prefixIcon: prefix,
        suffixIcon: suffix,
        border: const OutlineInputBorder(),
        contentPadding: padding,
        enabled: enabled,
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onEditingComplete: onEditingComplete,
      onTap: onTap,
      focusNode: focusNode,
      readOnly: readOnly,
      autofocus: autofocus,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      style: style,
      textAlign: textAlign,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
    );
  }
}
