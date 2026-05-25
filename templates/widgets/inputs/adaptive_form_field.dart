import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundation/platform_utils.dart';

/// Adaptive form field with validation support.
///
/// Material: [TextFormField] with [OutlineInputBorder].
/// Cupertino: [CupertinoTextField] wrapped in a [FormField] for
/// validation support, since Cupertino has no native form field.
class AdaptiveFormField extends StatelessWidget {
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
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final FocusNode? focusNode;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final String? initialValue;

  const AdaptiveFormField({
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
    this.onSaved,
    this.validator,
    this.autovalidateMode,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return _CupertinoFormField(
        controller: controller,
        placeholder: placeholder ?? labelText,
        prefix: prefix,
        suffix: suffix,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onSaved: onSaved,
        validator: validator,
        autovalidateMode: autovalidateMode,
        focusNode: focusNode,
        enabled: enabled,
        readOnly: readOnly,
        autofocus: autofocus,
        maxLines: maxLines,
        minLines: minLines,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        initialValue: initialValue,
      );
    }

    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      decoration: InputDecoration(
        hintText: placeholder,
        labelText: labelText,
        prefixIcon: prefix,
        suffixIcon: suffix,
        border: const OutlineInputBorder(),
        enabled: enabled,
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onSaved: onSaved,
      validator: validator,
      autovalidateMode: autovalidateMode,
      focusNode: focusNode,
      readOnly: readOnly,
      autofocus: autofocus,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
    );
  }
}

/// Cupertino text field wrapped in [FormField] so it participates in
/// [Form] validation on iOS/macOS.
class _CupertinoFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final FocusNode? focusNode;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final String? initialValue;

  const _CupertinoFormField({
    this.controller,
    this.placeholder,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onSaved,
    this.validator,
    this.autovalidateMode,
    this.focusNode,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.initialValue,
  });

  @override
  State<_CupertinoFormField> createState() => _CupertinoFormFieldState();
}

class _CupertinoFormFieldState extends State<_CupertinoFormField> {
  late TextEditingController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController(text: widget.initialValue ?? '');
      _ownsController = true;
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: _controller.text,
      onSaved: widget.onSaved,
      validator: widget.validator,
      autovalidateMode:
          widget.autovalidateMode ?? AutovalidateMode.disabled,
      enabled: widget.enabled,
      builder: (FormFieldState<String> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoTextField(
              controller: _controller,
              placeholder: widget.placeholder,
              prefix: widget.prefix != null
                  ? Padding(
                      padding:
                          const EdgeInsetsDirectional.only(start: 8),
                      child: widget.prefix,
                    )
                  : null,
              suffix: widget.suffix,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              onChanged: (value) {
                field.didChange(value);
                widget.onChanged?.call(value);
              },
              onSubmitted: widget.onSubmitted,
              focusNode: widget.focusNode,
              enabled: widget.enabled,
              readOnly: widget.readOnly,
              autofocus: widget.autofocus,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              maxLength: widget.maxLength,
              inputFormatters: widget.inputFormatters,
              textCapitalization: widget.textCapitalization,
              decoration: BoxDecoration(
                border: Border.all(
                  color: field.hasError
                      ? CupertinoColors.systemRed
                      : CupertinoColors.separator,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  field.errorText!,
                  style: const TextStyle(
                    color: CupertinoColors.systemRed,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
