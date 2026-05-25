import 'package:flutter/widgets.dart';

import 'platform_utils.dart';

abstract class PlatformWidget<M extends Widget, C extends Widget>
    extends StatelessWidget {
  const PlatformWidget({super.key});

  M buildMaterialWidget(BuildContext context);
  C buildCupertinoWidget(BuildContext context);

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return buildCupertinoWidget(context);
    }
    return buildMaterialWidget(context);
  }
}
