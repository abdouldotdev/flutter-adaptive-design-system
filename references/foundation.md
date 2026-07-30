# Foundation — Core Abstractions

## PlatformUtils

Single source of truth for platform detection.

**UI branching uses `defaultTargetPlatform`, never `dart:io`'s `Platform`.** A direct
`import 'dart:io'` **breaks the web build outright** — the import itself is rejected at
compile time, even under a `kIsWeb` runtime guard. The real-host-OS getters therefore
reach `dart:io` through a **conditional import** (a web stub + a native impl). And UI
branching stays off `Platform` entirely so the iOS branch is reachable from a web gallery
and exercisable from widget tests.

The `isIOS` / `isAndroid` / … getters report the REAL host OS and must be reserved for
non-UI concerns (permissions, store links, file paths).

```dart
// platform_utils.dart
import 'package:flutter/foundation.dart';

import 'platform_os_stub.dart' if (dart.library.io) 'platform_os_io.dart' as os;

abstract final class PlatformUtils {
  /// Forces the rendering in ANY build mode (release-safe). null in production.
  static TargetPlatform? debugOverridePlatform;

  static bool get isCupertino {
    final p = debugOverridePlatform ?? defaultTargetPlatform;
    return p == TargetPlatform.iOS || p == TargetPlatform.macOS;
  }
  static bool get isMaterial => !isCupertino;

  // Real host OS — non-UI concerns only. Routed through the conditional import.
  static bool get isIOS => os.isIOS;
  static bool get isAndroid => os.isAndroid;
  static bool get isMacOS => os.isMacOS;
  static bool get isLinux => os.isLinux;
  static bool get isWindows => os.isWindows;
  static bool get isWeb => kIsWeb;
  static bool get isMobile => isIOS || isAndroid;
  static bool get isDesktop => isMacOS || isLinux || isWindows;
}
```

```dart
// platform_os_stub.dart — web (no dart:io)
bool get isIOS => false;
bool get isAndroid => false;
bool get isMacOS => false;
bool get isLinux => false;
bool get isWindows => false;
```

```dart
// platform_os_io.dart — native
import 'dart:io' as io;
bool get isIOS => io.Platform.isIOS;
bool get isAndroid => io.Platform.isAndroid;
bool get isMacOS => io.Platform.isMacOS;
bool get isLinux => io.Platform.isLinux;
bool get isWindows => io.Platform.isWindows;
```

> **Note**: both `defaultTargetPlatform` and `Platform` are resolved once at startup. These getters are effectively constants — no performance concern.

> **Gallery / preview toggle**: set `PlatformUtils.debugOverridePlatform =
> TargetPlatform.iOS` (or `.android`) and rebuild the subtree. This works in **every build
> mode**, including a `--release` build deployed to a static host.
>
> Do **not** use `debugDefaultTargetPlatformOverride` for a deployed gallery: it is
> debug-only. Setting it in a release build throws `Cannot modify
> debugDefaultTargetPlatformOverride in non-debug builds`, and `defaultTargetPlatform`
> ignores it outside debug — so the toggle crashes the moment the gallery is served. It is
> fine in **widget tests** (they run in debug), where `debugOverridePlatform` stays null
> and `defaultTargetPlatform` picks up the debug override.

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

**Use the shipped barrel: `templates/adaptive.dart`.** It is generated against the real
template layout, exports all 51 widgets plus the foundation, and is verified to have no name
collisions. Copy it alongside the other templates and import that one file.

The listing below shows the *shape* of a barrel and is illustrative only — its folder names
predate the current layout (`widgets/layout/`, `widgets/buttons/`, … rather than `navigation/`,
`content/`), so do not copy it verbatim.

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
