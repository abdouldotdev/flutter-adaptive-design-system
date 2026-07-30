import 'package:flutter/widgets.dart';

import '../foundation/adaptive_tokens.dart';
import '../foundation/platform_utils.dart';
import 'breakpoints.dart';

/// List and detail side by side when there is room, list alone when there is
/// not.
///
/// This is the iPad split view and the tablet two-pane layout: below
/// [ScreenSize.compact] only [master] is built and selecting a row is expected
/// to push a page; from [ScreenSize.medium] up, [detail] fills the pane next
/// to it and no navigation happens at all.
///
/// ```dart
/// AdaptiveMasterDetail(
///   master: ConversationList(onSelect: _select),
///   detail: selected == null ? null : ConversationView(selected!),
///   placeholder: const EmptyConversationState(),
/// )
/// ```
///
/// The selection handler has to know which of the two modes is live, since
/// pushing a page while the detail pane is visible would cover the pane it
/// just filled. Ask [isSplit]:
///
/// ```dart
/// void _select(Conversation c) {
///   setState(() => selected = c);
///   if (!AdaptiveMasterDetail.isSplit(context)) {
///     Navigator.of(context).push(adaptivePageRoute(ConversationView(c)));
///   }
/// }
/// ```
///
/// ## Width buys a second pane, not larger type
///
/// The whole point of the layout is that a wide window shows two things at
/// once instead of one thing blown up. Text inside either pane keeps the size
/// it has on a phone — see `AdaptiveTypography`.
///
/// ## Measures its box, not the window
///
/// The decision comes from a [LayoutBuilder], so the layout stays correct when
/// it is itself inside a pane: an iPad in Slide Over, or a window the user
/// dragged to a third of the screen, gets the single-pane treatment it should.
class AdaptiveMasterDetail extends StatelessWidget {
  /// The list pane. Always built, at every size.
  final Widget master;

  /// The detail pane, or null when nothing is selected.
  ///
  /// Only built in split mode; on a compact window the detail is expected to
  /// be a pushed page instead.
  final Widget? detail;

  /// Shown in the detail pane while [detail] is null.
  ///
  /// Defaults to an empty surface. Pass a real empty state — the wording has
  /// to be localised, which is why no default text ships here.
  final Widget? placeholder;

  /// Width of the list pane, in logical pixels.
  ///
  /// Defaults to 320 at [ScreenSize.medium] and 380 above, matching the
  /// primary column of a UIKit split view.
  final double? masterWidth;

  const AdaptiveMasterDetail({
    super.key,
    required this.master,
    this.detail,
    this.placeholder,
    this.masterWidth,
  });

  /// Whether a window of this size shows both panes at once.
  ///
  /// Drives the push-or-select decision at the call site; keep it and the
  /// widget reading the same context so the two can never disagree.
  static bool isSplit(BuildContext context) =>
      !Breakpoints.of(context).isCompact;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final ScreenSize screen = Breakpoints.fromWidth(constraints.maxWidth);

        // Compact: one pane. The detail belongs on the navigation stack.
        if (screen.isCompact) return master;

        final double paneWidth = masterWidth ??
            (screen.isAtLeast(ScreenSize.expanded) ? 380 : 320);

        return Row(
          // Stretch so both panes and the hairline fill the height.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(width: paneWidth, child: master),
            _buildSeparator(context),
            Expanded(
              child: detail ??
                  placeholder ??
                  ColoredBox(color: AdaptiveColors.background(context)),
            ),
          ],
        );
      },
    );
  }

  /// Hairline between the panes, at the platform's separator thickness.
  Widget _buildSeparator(BuildContext context) {
    return SizedBox(
      width: PlatformUtils.isCupertino ? 0.5 : 1,
      child: ColoredBox(color: AdaptiveColors.separator(context)),
    );
  }
}
