/// Widget-test template for the adaptive design system.
///
/// Platform divergence is the defect this design system is most exposed to and
/// the hardest to catch by reading code. A widget whose Cupertino branch was
/// never wired up still compiles, still runs, and looks wrong only on a device
/// nobody on the team is holding. Widget tests close that gap: they render both
/// branches in the same run, in seconds, on any machine.
///
/// Copy this file into the project's `test/` directory, rename it to
/// `*_test.dart` (only that suffix is collected by `flutter test`), repoint the
/// two relative imports below at `package:…` — a file under `test/` cannot
/// reach `lib/` by relative path — and swap the [AdaptiveButton] examples for
/// your own widget.
///
/// ## Forcing the platform: two mechanisms, one recommendation
///
/// **`debugDefaultTargetPlatformOverride`** (from
/// `package:flutter/foundation.dart`) rewrites [defaultTargetPlatform] itself,
/// so it moves the entire framework — `Theme.of(context).platform`, page
/// transitions, default scroll physics, text selection controls — and not just
/// this design system. It is *debug-only*: assigning it in a release build
/// throws, and outside debug [defaultTargetPlatform] ignores it. Widget tests
/// run in debug, so using it here is legitimate.
///
/// **[PlatformUtils.debugOverridePlatform]** is read first by
/// [PlatformUtils.isCupertino] and works in every build mode, which is why the
/// design-system gallery relies on it. **Prefer it in tests**: what the test
/// exercises is then exactly the code path production reads, with no
/// debug-only indirection in between.
///
/// [testAdaptiveWidget] sets both by default — the design-system override for
/// the widgets themselves, the foundation override so the framework around
/// them behaves like the same platform.
///
/// ## Reset in tearDown — this is not optional
///
/// Both switches are static, global, and outlive the test that set them. Leak
/// one and every later test in the file inherits a platform it never asked
/// for; the failure then surfaces in an unrelated test and gets filed as
/// flakiness.
///
/// `flutter_test` catches half of it for you: the binding asserts, at the end
/// of each `testWidgets`, that the foundation debug variables are back to
/// `null`, so a leaked `debugDefaultTargetPlatformOverride` fails loudly. It
/// knows nothing about [PlatformUtils.debugOverridePlatform] — resetting that
/// one is entirely on you.
///
/// That same assertion is why the reset happens in a `finally` **inside** the
/// test body rather than through `addTearDown`: the binding checks the
/// invariants as soon as the body returns, before test-level teardown
/// callbacks run.
///
/// ## Alternative: `TargetPlatformVariant`
///
/// The framework ships its own way to run one body across platforms:
///
/// ```dart
/// testWidgets('renders', (WidgetTester tester) async { ... },
///     variant: TargetPlatformVariant.only(TargetPlatform.iOS));
/// ```
///
/// It only sets `debugDefaultTargetPlatformOverride`, which still reaches
/// [PlatformUtils.isCupertino] through its [defaultTargetPlatform] fallback.
/// Use it when a test needs the full matrix (macOS, Windows, Linux, …);
/// use [testAdaptiveWidget] for the two-branch case this design system models.
library;

import 'package:flutter/cupertino.dart';
// `debugDefaultTargetPlatformOverride` lives here and is deliberately absent
// from the `show` clause that material.dart re-exports.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// ADJUST THESE TWO IMPORTS — they are the only thing to change in this file.
//
// They are relative here because that is how the templates reference each other
// inside `templates/`. Once this file sits in `test/` and the design system in
// `lib/`, a relative import can no longer reach it — switch both to
// `package:<your pubspec name>/<where you copied templates>/…`, e.g.
// `package:my_app/shared/design_system/foundation/platform_utils.dart`.
// ---------------------------------------------------------------------------
import '../foundation/platform_utils.dart';
import '../widgets/buttons/adaptive_button.dart';

/// The two platforms every adaptive widget branches on.
///
/// `PlatformUtils.isCupertino` is true for iOS and macOS and false everywhere
/// else, so exercising one representative of each branch is enough. Widen this
/// list only when a widget special-cases a third platform.
const List<TargetPlatform> kAdaptivePlatforms = <TargetPlatform>[
  TargetPlatform.android,
  TargetPlatform.iOS,
];

/// Minimum touch target per Apple's Human Interface Guidelines: 44×44 pt.
const double kCupertinoMinTouchTarget = 44;

/// Minimum touch target per Material 3 accessibility guidance: 48×48 dp.
const double kMaterialMinTouchTarget = 48;

/// Runs [body] once per entry in [platforms], with the platform forced.
///
/// This is the core of the template. One scenario, written once, verified on
/// both branches — which is the only way a missing Cupertino path shows up
/// before a user does.
///
/// [body] receives the forced [TargetPlatform] so a single scenario can assert
/// platform-specific outcomes (`FilledButton` here, `CupertinoButton` there)
/// without being duplicated.
///
/// Set [overrideFrameworkPlatform] to `false` to force *only*
/// [PlatformUtils.debugOverridePlatform] and leave [defaultTargetPlatform]
/// alone. That is the stricter test: it proves the widget branches on the
/// design system's own switch rather than accidentally inheriting the
/// framework's.
void testAdaptiveWidget(
  String description,
  Future<void> Function(WidgetTester tester, TargetPlatform platform) body, {
  List<TargetPlatform> platforms = kAdaptivePlatforms,
  bool overrideFrameworkPlatform = true,
}) {
  for (final TargetPlatform platform in platforms) {
    testWidgets('$description · ${platform.name}', (WidgetTester tester) async {
      PlatformUtils.debugOverridePlatform = platform;
      if (overrideFrameworkPlatform) {
        debugDefaultTargetPlatformOverride = platform;
      }
      try {
        await body(tester, platform);
      } finally {
        // Reset here, not in `addTearDown`: the binding verifies the foundation
        // debug variables the moment this body returns.
        PlatformUtils.debugOverridePlatform = null;
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }
}

/// Wraps [child] in the app shell matching the currently forced platform.
///
/// The shell matters. A `CupertinoButton` mounted under a [MaterialApp] finds a
/// Material [Theme] and no [CupertinoTheme], so it resolves the wrong colours
/// and the test validates a rendering the app will never produce. Pairing
/// [CupertinoApp] with the Cupertino branch keeps the test honest.
///
/// [textScaler] overrides the ambient text scale from *inside* the app, where
/// it survives the [MediaQuery] the app's [View] installs.
Widget _wrap(
  Widget child, {
  TextScaler textScaler = TextScaler.noScaling,
}) {
  final Widget body = Builder(
    builder: (BuildContext context) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: Center(child: child),
      );
    },
  );

  if (PlatformUtils.isCupertino) {
    return CupertinoApp(home: body);
  }

  return MaterialApp(
    theme: ThemeData(platform: TargetPlatform.android),
    home: Scaffold(body: body),
  );
}

void main() {
  // Safety net for the hand-rolled tests below, which set the switches without
  // going through [testAdaptiveWidget].
  tearDown(() {
    PlatformUtils.debugOverridePlatform = null;
    debugDefaultTargetPlatformOverride = null;
  });

  group('Forcing the platform', () {
    test('PlatformUtils.debugOverridePlatform works in every build mode', () {
      // No widget, no binding, no debug-only API: this is the switch the
      // gallery flips at runtime and the one production code reads.
      PlatformUtils.debugOverridePlatform = TargetPlatform.iOS;
      expect(PlatformUtils.isCupertino, isTrue);
      expect(PlatformUtils.isMaterial, isFalse);

      PlatformUtils.debugOverridePlatform = TargetPlatform.android;
      expect(PlatformUtils.isCupertino, isFalse);

      // macOS takes the Cupertino branch too.
      PlatformUtils.debugOverridePlatform = TargetPlatform.macOS;
      expect(PlatformUtils.isCupertino, isTrue);
    });

    testWidgets('debugDefaultTargetPlatformOverride also reaches isCupertino',
        (WidgetTester tester) async {
      // Legitimate in tests because they run in debug. In a release build this
      // assignment throws, which is precisely why the design system does not
      // depend on it.
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        // debugOverridePlatform is null, so isCupertino falls back to
        // defaultTargetPlatform — which the line above has rewritten.
        expect(PlatformUtils.debugOverridePlatform, isNull);
        expect(PlatformUtils.isCupertino, isTrue);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    test('no override leaked from the tests above', () {
      // Runs after the two tests above (declaration order is execution order
      // within a group). If either had leaked, this fails immediately instead
      // of corrupting an unrelated test further down the file.
      expect(PlatformUtils.debugOverridePlatform, isNull);
      expect(debugDefaultTargetPlatformOverride, isNull);
    });
  });

  group('AdaptiveButton', () {
    testAdaptiveWidget('renders the platform-native primitive',
        (WidgetTester tester, TargetPlatform platform) async {
      await tester.pumpWidget(
        _wrap(AdaptiveButton.label(onPressed: () {}, label: 'Continue')),
      );

      // The label is platform-independent; the primitive under it is not.
      expect(find.text('Continue'), findsOneWidget);

      if (platform == TargetPlatform.iOS) {
        expect(find.byType(CupertinoButton), findsOneWidget);
        // The negative assertion is the one that catches a missing branch: a
        // widget that forgot its Cupertino path renders a FilledButton on iOS
        // and every positive assertion above still passes.
        expect(find.byType(FilledButton), findsNothing);
      } else {
        expect(find.byType(FilledButton), findsOneWidget);
        expect(find.byType(CupertinoButton), findsNothing);
      }
    });

    testAdaptiveWidget('invokes onPressed when tapped',
        (WidgetTester tester, TargetPlatform platform) async {
      int taps = 0;

      await tester.pumpWidget(
        _wrap(AdaptiveButton.label(onPressed: () => taps++, label: 'Continue')),
      );

      // Target the adaptive widget, not the primitive: the same line then works
      // on both platforms.
      await tester.tap(find.byType(AdaptiveButton));
      await tester.pump();

      expect(taps, 1);
    });

    testAdaptiveWidget('is disabled when onPressed is null',
        (WidgetTester tester, TargetPlatform platform) async {
      int taps = 0;

      // Enabled first, to prove the tap actually reaches the button. Without
      // this step a broken finder would make the disabled assertion pass for
      // the wrong reason.
      await tester.pumpWidget(
        _wrap(AdaptiveButton.label(onPressed: () => taps++, label: 'Continue')),
      );
      await tester.tap(find.byType(AdaptiveButton));
      await tester.pump();
      expect(taps, 1, reason: 'the enabled button must receive the tap');

      // Same tree, callback removed.
      await tester.pumpWidget(
        _wrap(const AdaptiveButton(onPressed: null, child: Text('Continue'))),
      );
      // warnIfMissed: false — a disabled button detaches its gesture recogniser,
      // so the tap legitimately lands on nothing.
      await tester.tap(find.byType(AdaptiveButton), warnIfMissed: false);
      await tester.pump();
      expect(taps, 1, reason: 'a disabled button must swallow the tap');

      // And the primitive itself reports the disabled state, which is what
      // drives the greyed-out rendering and the accessibility tree.
      if (platform == TargetPlatform.iOS) {
        final CupertinoButton button =
            tester.widget<CupertinoButton>(find.byType(CupertinoButton));
        expect(button.enabled, isFalse);
      } else {
        final FilledButton button =
            tester.widget<FilledButton>(find.byType(FilledButton));
        expect(button.enabled, isFalse);
      }
    });
  });

  group('Accessibility', () {
    testAdaptiveWidget('meets the platform minimum touch target',
        (WidgetTester tester, TargetPlatform platform) async {
      await tester.pumpWidget(
        _wrap(AdaptiveButton.label(onPressed: () {}, label: 'OK')),
      );

      // 44×44 pt on iOS (Human Interface Guidelines), 48×48 dp on Material.
      // A short label is the worst case: it is the one that lets a button
      // shrink below the minimum.
      final double minSide = platform == TargetPlatform.iOS
          ? kCupertinoMinTouchTarget
          : kMaterialMinTouchTarget;

      final Size size = tester.getSize(find.byType(AdaptiveButton));

      expect(
        size.height,
        greaterThanOrEqualTo(minSide),
        reason: '${platform.name}: height ${size.height} < $minSide',
      );
      expect(
        size.width,
        greaterThanOrEqualTo(minSide),
        reason: '${platform.name}: width ${size.width} < $minSide',
      );
    });

    testAdaptiveWidget('survives the maximum accessibility text scale',
        (WidgetTester tester, TargetPlatform platform) async {
      Widget subject() => SizedBox(
            width: 320,
            child: AdaptiveButton.label(onPressed: () {}, label: 'Confirm'),
          );

      // Baseline at the default scale, to compare against below.
      await tester.pumpWidget(_wrap(subject()));
      final Size unscaled = tester.getSize(find.byType(AdaptiveButton));

      // iOS Dynamic Type reaches ~3.1× at the largest accessibility size and
      // Android's font-size slider goes to 2×. Testing at 3× covers both and
      // is where fixed-height rows, single-line labels and tight Rows break.
      await tester.pumpWidget(
        _wrap(subject(), textScaler: const TextScaler.linear(3)),
      );

      // A RenderFlex or RenderBox overflow is reported as a framework error,
      // which the binding records rather than throwing. takeException() is how
      // a widget test turns "a yellow-and-black stripe appeared" into a
      // failure — nothing else in the test would have noticed.
      expect(
        tester.takeException(),
        isNull,
        reason: '${platform.name}: layout overflows at 3× text scale',
      );

      expect(find.text('Confirm'), findsOneWidget);

      // The button must also have actually grown. A height identical to the
      // baseline means the scale was swallowed — a hard-coded `height:`, a
      // `TextStyle` applied outside the MediaQuery, or a stray
      // `MediaQuery(textScaler: TextScaler.noScaling)` — and the label is now
      // clipped for the very users who asked for larger text.
      final Size scaled = tester.getSize(find.byType(AdaptiveButton));
      expect(
        scaled.height,
        greaterThan(unscaled.height),
        reason: '${platform.name}: the button ignored the text scale',
      );
    });
  });
}
