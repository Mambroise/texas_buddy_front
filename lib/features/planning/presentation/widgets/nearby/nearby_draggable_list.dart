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

class NearbyDraggableList extends StatelessWidget {
  final double maxCardWidth;
  const NearbyDraggableList({super.key, required this.maxCardWidth});


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

        return ScrollConfiguration(
          behavior: const _NoGlowScroll(),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              final it = items[i];
              final card = _NearbyCard(item: it);
              final cardWidth  = maxCardWidth; // passé par le parent
              const cardHeight = 88.0;

              return LongPressDraggable<NearbyItem>(
                data: it,
                dragAnchorStrategy: pointerDragAnchorStrategy,
                feedback: Transform.translate(
                  offset: Offset(-cardWidth / 2, -cardHeight / 2),   // ✅ doigt au centre
                  child: _DragFeedbackCard(item: it, width: cardWidth, height: cardHeight),
                ),
                childWhenDragging: Opacity(opacity: .35, child: card),
                child: card, // ton _NearbyCard actuel (il peut garder sa margin)
              );
            },
          ),
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
  const _NearbyCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      height: 88,
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
          color: AppColors.fog,                             // ✅ pas de blanc “nu”
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
