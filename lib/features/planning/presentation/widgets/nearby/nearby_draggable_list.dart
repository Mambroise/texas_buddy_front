//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/widgets/nearby/nearby_draggable_list.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';
import 'package:texas_buddy/features/map/domain/entities/nearby_item.dart';
import 'package:texas_buddy/features/map/presentation/blocs/nearby/nearby_bloc.dart';

class NearbyDraggableList extends StatefulWidget {
  final double maxCardWidth;
  const NearbyDraggableList({super.key, required this.maxCardWidth});

  @override
  State<NearbyDraggableList> createState() => _NearbyDraggableListState();
}

class _NearbyDraggableListState extends State<NearbyDraggableList> {
  int? _draggingIndex;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NearbyBloc, NearbyState>(
      buildWhen: (p, n) => p.status != n.status || p.items != n.items,
      builder: (context, state) {
        if (state.status == NearbyStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == NearbyStatus.error) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Unable to load nearby items.",
                style: const TextStyle(color: AppColors.texasBlue),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final items = state.items;
        if (items.isEmpty) {
          return const Center(child: Text("No nearby items."));
        }

        // ⚠️ On calcule un extraScroll proportionnel à la hauteur dispo,
        // exactement comme dans TimelinePane, pour atteindre la dernière carte.
        return LayoutBuilder(
          builder: (ctx, cons) {
            final bottomSafe = MediaQuery.of(ctx).padding.bottom;
            final extraScroll = cons.maxHeight * 0.30; // ↩︎ même logique que TimelinePane

            return ScrollConfiguration(
              behavior: const _NoGlowScroll(),
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(12, 0, 12, 12 + extraScroll + bottomSafe),
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                itemCount: items.length,
                itemBuilder: (ctx, i) {
                  final it = items[i];
                  final cardWidth  = widget.maxCardWidth;
                  const cardHeight = 88.0;

                  // poignée de drag (GAUCHE) — inchangée
                  final handle = Draggable<NearbyItem>(
                    data: it,
                    dragAnchorStrategy: pointerDragAnchorStrategy,
                    feedback: Transform.translate(
                      offset: Offset(-cardWidth / 2, -cardHeight / 2),   // doigt au centre
                      child: _DragFeedbackCard(item: it, width: cardWidth, height: cardHeight),
                    ),
                    child: const _DragHandleIcon(),
                    childWhenDragging: const _DragHandleIcon(dimmed: true),
                    onDragStarted: () => setState(() => _draggingIndex = i),
                    onDragEnd: (_) => setState(() => _draggingIndex = null),
                  );

                  return _NearbyCard(
                    item: it,
                    dimmed: _draggingIndex == i, // assombrir la carte pendant le drag
                    leading: handle,             // ✅ poignée à GAUCHE
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _NoGlowScroll extends ScrollBehavior {
  const _NoGlowScroll();
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) => child;
}

class _NearbyCard extends StatelessWidget {
  final NearbyItem item;
  final Widget? leading;   // ✅ poignée / avatar / etc. à gauche
  final Widget? trailing;  // (non utilisé ici, conservé pour flexibilité)
  final bool dimmed;

  const _NearbyCard({
    required this.item,
    this.leading,
    this.trailing,
    this.dimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed ? .35 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        height: 88,
        decoration: BoxDecoration(
          color: AppColors.fog,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.texasBlue, width: 1),
          boxShadow: const [BoxShadow(blurRadius: 10, offset: Offset(0, 4), color: Color(0x12000000))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            if (leading != null) ...[
              SizedBox(width: 32, child: Center(child: leading)),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.place, color: AppColors.texasBlue),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.texasBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class _DragFeedbackCard extends StatelessWidget {
  final NearbyItem item;
  final double width;
  final double height;
  const _DragFeedbackCard({required this.item, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.fog,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.texasBlue, width: 1),
          boxShadow: const [BoxShadow(blurRadius: 10, offset: Offset(0, 4), color: Color(0x12000000))],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.place, color: AppColors.texasBlue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.texasBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DragHandleIcon extends StatelessWidget {
  final bool dimmed;
  const _DragHandleIcon({this.dimmed = false});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.drag_indicator_rounded,
      color: dimmed ? Colors.black26 : AppColors.texasBlue,
      size: 22,
    );
  }
}
