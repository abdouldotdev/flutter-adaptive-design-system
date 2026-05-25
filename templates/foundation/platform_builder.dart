import 'package:flutter/widgets.dart';

import 'platform_utils.dart';

class PlatformBuilder extends StatelessWidget {
  final WidgetBuilder materialBuilder;
  final WidgetBuilder cupertinoBuilder;

  const PlatformBuilder({
    super.key,
    required this.materialBuilder,
    required this.cupertinoBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return cupertinoBuilder(context);
    }
    return materialBuilder(context);
  }
}
