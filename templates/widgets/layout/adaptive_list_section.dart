import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../foundation/platform_utils.dart';

/// Adaptive list section.
///
/// Material: [Column] with [Divider] separators and optional header/footer.
/// Cupertino: [CupertinoListSection.insetGrouped] with native iOS styling.
class AdaptiveListSection extends StatelessWidget {
  final String? header;
  final String? footer;
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final bool hasLeadingWidget;

  const AdaptiveListSection({
    super.key,
    this.header,
    this.footer,
    required this.children,
    this.margin,
    this.backgroundColor,
    this.hasLeadingWidget = false,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return _buildCupertino(context);
    }
    return _buildMaterial(context);
  }

  Widget _buildCupertino(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      header: header != null ? Text(header!) : null,
      footer: footer != null ? Text(footer!) : null,
      margin: margin as EdgeInsets?,
      backgroundColor:
          backgroundColor ?? CupertinoColors.systemGroupedBackground,
      hasLeading: hasLeadingWidget,
      children: children,
    );
  }

  Widget _buildMaterial(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: margin ?? const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 8),
              child: Text(
                header!,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            elevation: 0,
            color: backgroundColor ?? theme.colorScheme.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: _buildChildrenWithDividers(context),
            ),
          ),
          if (footer != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 8),
              child: Text(
                footer!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildChildrenWithDividers(BuildContext context) {
    final result = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(const Divider(height: 0.5, indent: 16));
      }
    }
    return result;
  }
}
