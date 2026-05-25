# Foundation — Core Abstractions

## PlatformUtils

Single source of truth for platform detection. Use `dart:io` Platform.

```dart
import 'dart:io' show Platform;

abstract final class PlatformUtils {
  static bool get isCupertino => Platform.isIOS || Platform.isMacOS;
  static bool get isMaterial => !isCupertino;
  static bool get isIOS => Platform.isIOS;
  static bool get isAndroid => Platform.isAndroid;
  static bool get isMacOS => Platform.isMacOS;
  static bool get isDesktop => Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  static bool get isMobile => Platform.isIOS || Platform.isAndroid;
}
```

> **Note**: `Platform` is resolved at startup and never changes at runtime. These getters are effectively constants — no performance concern.

## PlatformWidget — Pattern A Base Class

```dart
import 'package:flutter/widgets.dart';
import '../core/utils/platform_utils.dart';

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
```

## PlatformBuilder — Function-based One-off Split

When you need a one-off platform split without creating a full widget class.

```dart
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
```

## AdaptiveThemeScope — Theme Wrapper

Wraps child in the correct theme data for the platform.

```dart
class AdaptiveThemeScope extends StatelessWidget {
  final ThemeData materialTheme;
  final CupertinoThemeData cupertinoTheme;
  final Widget child;

  const AdaptiveThemeScope({
    super.key,
    required this.materialTheme,
    required this.cupertinoTheme,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isCupertino) {
      return CupertinoTheme(data: cupertinoTheme, child: child);
    }
    return Theme(data: materialTheme, child: child);
  }
}
```

## App Entry Point

Use `MaterialApp.router` or `CupertinoApp.router` based on platform. Both share the same GoRouter config.

```dart
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRouter.router; // GoRouter instance

    if (PlatformUtils.isCupertino) {
      return CupertinoApp.router(
        routerConfig: router,
        theme: const CupertinoThemeData(
          primaryColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      );
    }

    return MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(
        colorSchemeSeed: AppColors.primary,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
```

## AdaptivePageRoute — Navigation Transitions

```dart
class AdaptivePageRoute {
  const AdaptivePageRoute._();

  static PageRoute<T> create<T>({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool fullscreenDialog = false,
  }) {
    if (PlatformUtils.isCupertino) {
      return CupertinoPageRoute<T>(
        builder: builder,
        settings: settings,
        fullscreenDialog: fullscreenDialog,
      );
    }
    return MaterialPageRoute<T>(
      builder: builder,
      settings: settings,
      fullscreenDialog: fullscreenDialog,
    );
  }
}
```

## Barrel File — Single Import

`lib/design_system/design_system.dart`:

```dart
library;

// Foundation
export 'foundation/platform_widget.dart';
export 'foundation/platform_builder.dart';
export 'foundation/adaptive_theme_scope.dart';

// Navigation & Structure
export 'navigation/adaptive_scaffold.dart';
export 'navigation/adaptive_app_bar.dart';
export 'navigation/adaptive_bottom_nav.dart';
export 'navigation/adaptive_tab_scaffold.dart';
export 'navigation/adaptive_sliver_app_bar.dart';
export 'navigation/adaptive_page_route.dart';
export 'navigation/adaptive_tab_bar.dart';
export 'navigation/adaptive_navigation_drawer.dart';

// Content & Lists
export 'content/adaptive_card.dart';
export 'content/adaptive_list_tile.dart';
export 'content/adaptive_list_section.dart';
export 'content/adaptive_divider.dart';

// Buttons & Actions
export 'buttons/adaptive_button.dart';
export 'buttons/adaptive_text_button.dart';
export 'buttons/adaptive_icon_button.dart';
export 'buttons/adaptive_fab.dart';
export 'buttons/adaptive_popup_menu.dart';
export 'buttons/adaptive_context_menu.dart';

// Forms & Inputs
export 'inputs/adaptive_text_field.dart';
export 'inputs/adaptive_search_bar.dart';
export 'inputs/adaptive_switch.dart';
export 'inputs/adaptive_slider.dart';
export 'inputs/adaptive_checkbox.dart';
export 'inputs/adaptive_radio.dart';
export 'inputs/adaptive_segmented_control.dart';
export 'inputs/adaptive_picker.dart';
export 'inputs/adaptive_form_field.dart';

// Chips
export 'chips/adaptive_chip.dart';
export 'chips/adaptive_filter_chip.dart';

// Feedback & Overlays
export 'feedback/adaptive_dialog.dart';
export 'feedback/adaptive_action_sheet.dart';
export 'feedback/adaptive_snack_bar.dart';
export 'feedback/adaptive_progress_indicator.dart';
export 'feedback/adaptive_tooltip.dart';

// Scroll
export 'scroll/adaptive_refresh_indicator.dart';

// Pickers
export 'pickers/adaptive_date_picker.dart';
export 'pickers/adaptive_time_picker.dart';
```

Consumer usage:

```dart
import 'package:myapp/design_system/design_system.dart';
```

## Folder Structure

```
lib/
├── core/
│   └── utils/
│       └── platform_utils.dart
└── design_system/
    ├── design_system.dart          # barrel
    ├── foundation/
    │   ├── platform_widget.dart
    │   ├── platform_builder.dart
    │   └── adaptive_theme_scope.dart
    ├── navigation/
    ├── content/
    ├── buttons/
    ├── inputs/
    ├── chips/
    ├── feedback/
    ├── scroll/
    └── pickers/
```
