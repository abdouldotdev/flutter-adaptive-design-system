# Flutter Adaptive Design System

> An Agent Skill that generates platform-native Flutter UI — iOS renders **Cupertino**, Android renders **Material 3**. Single codebase, two genuinely native experiences.

Brought to you by **[Appbiz Studio LLC](https://appbiz.studio)**.

## Install

```bash
npx skills add Prodevking1/flutter-adaptive-design-system
```

This installs the skill into your agent (Claude Code, etc.). Once installed, ask your agent to build adaptive Flutter UI and it will use the bundled, production-tested widget templates.

## What it does

Most cross-platform Flutter UI ends up looking like a generic hybrid. This skill ships **41 production-tested adaptive widget files** that branch on platform and render the *real* native control — `CupertinoTextField` on iOS, Material `TextField` on Android — behind one consistent `Adaptive*` API.

Use it to:

- Create adaptive widgets that render natively per platform
- Build Flutter UI that looks like a real iOS or Android app
- Generate Cupertino/Material widget pairs with a single, consistent API
- Implement adaptive navigation, dialogs, forms, inputs, and layouts
- Set up a project's design-system foundation with platform detection

## Component catalog

**Foundation (4):** `PlatformUtils` · `PlatformWidget` · `PlatformBuilder` · `AdaptiveThemeScope`

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

All widgets use the fixed `Adaptive` prefix (`AdaptiveButton`, `AdaptiveScaffold`, `AdaptiveDialog`, …) for a consistent API across projects.

## Requirements

- **Flutter** (stable)
- **[`hugeicons`](https://pub.dev/packages/hugeicons)** — used for all app icons (never `CupertinoIcons` or `Icons` directly)

Templates use only relative imports and depend solely on `flutter` and `hugeicons` — copy them verbatim, nothing to rewire.

## Layout

```
flutter-adaptive-design-system/
├── SKILL.md              # Skill instructions & metadata
├── templates/            # 41 ready-to-copy .dart files
│   ├── foundation/
│   └── widgets/          # layout, buttons, inputs, feedback, chips, navigation, pickers, context_menu
└── references/           # foundation, widgets, states, responsive, accessibility, performance
```

## License

MIT © Appbiz Studio LLC — see [LICENSE](LICENSE).
