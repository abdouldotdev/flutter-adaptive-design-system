/// Adaptive design system — single import.
///
/// ```dart
/// import 'package:your_app/shared/design_system/adaptive.dart';
/// ```
///
/// `platform_os_io.dart` and `platform_os_stub.dart` are deliberately absent:
/// they are the two halves of a conditional import consumed by
/// `platform_utils.dart`, never imported directly.
library;

// Foundation
export 'foundation/adaptive_icons.dart';
export 'foundation/adaptive_theme_scope.dart';
export 'foundation/adaptive_tokens.dart';
export 'foundation/adaptive_typography.dart';
export 'foundation/platform_builder.dart';
export 'foundation/platform_utils.dart';
export 'foundation/platform_widget.dart';

// Layout
export 'widgets/layout/adaptive_app_bar.dart';
export 'widgets/layout/adaptive_bottom_nav.dart';
export 'widgets/layout/adaptive_card.dart';
export 'widgets/layout/adaptive_divider.dart';
export 'widgets/layout/adaptive_list_section.dart';
export 'widgets/layout/adaptive_list_tile.dart';
export 'widgets/layout/adaptive_scaffold.dart';
export 'widgets/layout/adaptive_sliver_app_bar.dart';
export 'widgets/layout/adaptive_tab_scaffold.dart';

// Buttons
export 'widgets/buttons/adaptive_button.dart';
export 'widgets/buttons/adaptive_fab.dart';
export 'widgets/buttons/adaptive_icon_button.dart';
export 'widgets/buttons/adaptive_text_button.dart';

// Inputs
export 'widgets/inputs/adaptive_checkbox.dart';
export 'widgets/inputs/adaptive_form_field.dart';
export 'widgets/inputs/adaptive_radio.dart';
export 'widgets/inputs/adaptive_search_bar.dart';
export 'widgets/inputs/adaptive_segmented_control.dart';
export 'widgets/inputs/adaptive_slider.dart';
export 'widgets/inputs/adaptive_switch.dart';
export 'widgets/inputs/adaptive_text_field.dart';

// Feedback
export 'widgets/feedback/adaptive_action_sheet.dart';
export 'widgets/feedback/adaptive_dialog.dart';
export 'widgets/feedback/adaptive_progress_indicator.dart';
export 'widgets/feedback/adaptive_refresh_indicator.dart';
export 'widgets/feedback/adaptive_snack_bar.dart';
export 'widgets/feedback/adaptive_tooltip.dart';

// Chips
export 'widgets/chips/adaptive_chip.dart';
export 'widgets/chips/adaptive_filter_chip.dart';

// Navigation
export 'widgets/navigation/adaptive_navigation_drawer.dart';
export 'widgets/navigation/adaptive_page_route.dart';
export 'widgets/navigation/adaptive_popup_menu.dart';
export 'widgets/navigation/adaptive_tab_bar.dart';

// Pickers
export 'widgets/pickers/adaptive_date_picker.dart';
export 'widgets/pickers/adaptive_picker.dart';
export 'widgets/pickers/adaptive_time_picker.dart';

// Context menu
export 'widgets/context_menu/adaptive_context_menu.dart';

// States
export 'widgets/states/adaptive_disabled.dart';
export 'widgets/states/adaptive_empty_state.dart';
export 'widgets/states/adaptive_error_banner.dart';
export 'widgets/states/adaptive_error_state.dart';
export 'widgets/states/adaptive_loading_button.dart';
export 'widgets/states/adaptive_loading_overlay.dart';
export 'widgets/states/adaptive_loading_page.dart';
export 'widgets/states/adaptive_shimmer.dart';
export 'widgets/states/adaptive_skeleton.dart';

// Responsive
export 'responsive/adaptive_constrained_content.dart';
export 'responsive/adaptive_master_detail.dart';
export 'responsive/adaptive_responsive_grid.dart';
export 'responsive/adaptive_responsive_scaffold.dart';
export 'responsive/breakpoints.dart';
