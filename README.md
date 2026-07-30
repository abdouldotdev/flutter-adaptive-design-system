# 📱 Flutter Adaptive Design System

> **Your Flutter app should feel like it was written twice.** iOS renders Cupertino. Android renders Material 3. One codebase, one API, two genuinely native experiences.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-stable-02569B.svg)](https://flutter.dev)
[![Agent Skill](https://img.shields.io/badge/Agent-Skill-black.svg)](https://skills.sh)

```dart
// You write this once.
AdaptiveScaffold(
  appBar: const AdaptiveAppBar(title: Text('Wallet')),
  body: AdaptiveListSection(
    children: [
      AdaptiveTextField(placeholder: 'Amount'),
      AdaptiveSwitch(value: autoTopUp, onChanged: setAutoTopUp),
    ],
  ),
)
```

```
        iOS                              Android
┌────────────────────┐          ┌────────────────────┐
│ CupertinoPageScaffold│         │ Scaffold (M3)      │
│ CupertinoNavigationBar│        │ AppBar             │
│ CupertinoListSection │         │ Column + Dividers  │
│ CupertinoTextField   │         │ TextField (outlined)│
│ CupertinoSwitch      │         │ Switch             │
└────────────────────┘          └────────────────────┘
   bounces on overscroll           stretches and glows
   swipe-from-edge back            system back + predictive
```

## ✨ Why this exists

Most "cross-platform adaptive" solutions are **Material with a coat of paint**. They swap a colour, round a corner, and ship an Android app to iPhone users. Packages that advertise themselves as adaptive routinely branch on fewer than a quarter of their components — the rest render Material everywhere.

This skill takes the opposite position: **every single widget branches.** There is no widget in this catalog that renders the same tree on both platforms.

- **🎯 Real native controls** — `CupertinoTextField` on iOS, Material `TextField` on Android. Not a lookalike, the actual framework widget, behind one `Adaptive*` API.
- **📋 Templates you own** — you copy files into your project. No dependency to version-pin, no breaking minor release, no `pub upgrade` roulette. Critical if you ship with code push: a dependency change is not patchable, your own code is.
- **🧱 A complete foundation, not just widgets** — type scale, design tokens, semantic icons, loading/empty/error states, breakpoints. The parts every project otherwise reinvents badly.
- **📐 Three patterns, documented** — so you can build widget #52 yourself instead of filing an issue.
- **🪤 The traps, pre-solved** — the platform-override that crashes in release, the type scaling that breaks accessibility, the font licence that silently substitutes. See below.
- **🪶 Two dependencies** — `flutter` and `hugeicons`. That's the whole list.

## 🚀 Install

```bash
npx skills add abdouldotdev/flutter-adaptive-design-system
```

Then ask your coding agent to build adaptive Flutter UI — it will use the bundled templates instead of improvising.

To wire it into a project, copy `templates/` into `lib/shared/` and create a barrel export. Templates use relative imports only; there is nothing to rewire.

## 🧩 Catalog

**Foundation** — `PlatformUtils` · `PlatformWidget` · `PlatformBuilder` · `AdaptiveThemeScope` · `AdaptiveTypography` · `AdaptiveTokens` · `AdaptiveIcons`

| Category | Widgets |
|---|---|
| **Layout** | Scaffold · AppBar · BottomNav · Card · Divider · ListTile · ListSection · SliverAppBar · TabScaffold |
| **Buttons** | Button · FAB · IconButton · TextButton |
| **Inputs** | TextField · SearchBar · Switch · Slider · Checkbox · Radio · SegmentedControl · FormField |
| **Feedback** | Dialog · ActionSheet · SnackBar · ProgressIndicator · RefreshIndicator · Tooltip |
| **Navigation** | NavigationDrawer · PageRoute · PopupMenu · TabBar |
| **Pickers** | DatePicker · TimePicker · Picker |
| **Chips** | Chip · FilterChip |
| **Context menu** | ContextMenu (iOS peek & pop) |
| **States** | LoadingOverlay · LoadingPage · LoadingButton · EmptyState · ErrorState · ErrorBanner · Disabled · Shimmer · Skeletons |
| **Responsive** | Breakpoints · ResponsiveGrid · ConstrainedContent · ResponsiveScaffold · MasterDetail |

Every widget carries the fixed `Adaptive` prefix — `AdaptiveButton`, `AdaptiveScaffold`, `AdaptiveDialog` — so the API reads the same across every project that installs this.

## 📐 Three patterns

Adaptive widgets fall into exactly three shapes. Knowing which one applies is the whole job:

| Pattern | When | Shape |
|---|---|---|
| **A** | Both platforms have a similar constructor | `extends PlatformWidget<Switch, CupertinoSwitch>` |
| **B** | APIs diverge, or one side needs wrapping | `StatelessWidget` + `if (PlatformUtils.isCupertino)` |
| **C** | Shown imperatively (`showDialog`, sheets, pickers) | `static Future<T?> show<T>(...)` |

## ⚡ Foundation

**Type scale** — `AdaptiveTypography` produces the Material `TextTheme` *and* a complete `CupertinoTextThemeData` from one scale. All eight Cupertino slots are filled: a partially filled Cupertino text theme silently falls back to Flutter's defaults, which is how an app ends up with two fonts on one screen.

**Design tokens** — `AdaptiveSpacing`, `AdaptiveRadius`, `AdaptiveColors`, `AdaptiveMotion`, `AdaptiveScrollPhysics`. Radii branch by platform (a card is 12 on Material, 10 on iOS; a button is a pill on Material, a 10pt rectangle on iOS). Colours resolve through `resolveFrom(context)` so dark mode actually works.

**Semantic icons** — `AdaptiveIcons` names icons by purpose (`AdaptiveIcons.back`, not `arrowLeft01`), so swapping a glyph is one line instead of a repo-wide search.

## 🪤 Traps this saves you from

Each of these has shipped to production somewhere. All are documented and pre-solved.

**The platform override that crashes in release.** `debugDefaultTargetPlatformOverride` is debug-only — it throws in a release build, and `defaultTargetPlatform` ignores it outside debug. A deployed gallery with an iOS/Android toggle built with `--release` crashes the moment someone flips it. This skill ships `PlatformUtils.debugOverridePlatform`, a plain static field that works in every build mode.

**Scaling type by screen width.** Body text is 17pt on an iPhone SE and 17pt on a 16 Pro Max — a bigger screen shows *more content*, not bigger text. Packages that compute font size from screen width (`flutter_screenutil`'s `.sp`, `sizer`, `responsive_sizer`) override the user's accessibility setting and produce a rendering that is neither iOS nor Android. Adapt **layout** to device size; respect `MediaQuery.textScalerOf` for type, and bound it per screen with `AdaptiveTextScale.clamp` only where density demands it.

**The icon variant that doesn't exist.** `hugeicons` ships one family: all ~4,470 constants are `strokeRounded*`. There are no `solid*` constants, so a registry branching stroke-on-Android / solid-on-iOS cannot compile — however sensible it sounds. Icon adaptation here runs through colour and size.

**The font licence that substitutes silently.** San Francisco is licensed for iOS, macOS and tvOS only. Force a Cupertino rendering on Android and Flutter falls back to another font. Expected behaviour, not a bug — but it generates phantom bug reports if nobody wrote it down.

**Dead `dart:io` imports on web.** A direct `import 'dart:io'` breaks the web build even behind a `kIsWeb` guard — it is the import itself that is rejected, not its execution. The foundation uses a conditional import so the same code compiles for web and native.

## 📁 Layout

```
flutter-adaptive-design-system/
├── SKILL.md              # Agent instructions & metadata
├── templates/            # Ready-to-copy .dart files
│   ├── foundation/       # platform detection, theme, typography, tokens, icons
│   ├── widgets/          # layout, buttons, inputs, feedback, chips,
│   │                     # navigation, pickers, context_menu, states
│   ├── responsive/       # breakpoints and adaptive layouts
│   └── test/             # bi-platform widget test template
└── references/           # foundation, widgets, accessibility,
                          # responsive, states, performance
```

## 📚 References

Deep-dive docs live in `references/`:

- **`foundation.md`** — platform detection, patterns, theme scope, app entry point, barrel file
- **`widgets.md`** — full implementation notes for every widget
- **`accessibility.md`** — Semantics, Dynamic Type, VoiceOver/TalkBack, WCAG AA, touch targets
- **`responsive.md`** — breakpoints, tablet and iPad, landscape, safe areas
- **`states.md`** — loading, empty, error, disabled, shimmer
- **`performance.md`** — `const` discipline, rebuild prevention, list performance, profiling

## 📄 License

MIT © [Appbiz Studio LLC](https://appbiz.studio) — see [LICENSE](LICENSE).
