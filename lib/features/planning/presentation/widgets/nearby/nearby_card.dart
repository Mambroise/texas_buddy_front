//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/widgets/nearby/nearby_card.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';
import 'package:texas_buddy/features/map/domain/entities/nearby_item.dart';
import 'package:texas_buddy/features/map/presentation/blocs/detail/detail_panel_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


//  helpers + widget de distance
import 'package:texas_buddy/features/planning/presentation/widgets/nearby/distance_label.dart';


class NearbyCard extends StatelessWidget {
  final NearbyItem item;
  final Widget? trailing;
  final bool dimmed;
  final bool useMiles;

  const NearbyCard({super.key, 
    required this.item,
    required this.useMiles,
    this.trailing,
    this.dimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed ? .35 : 1.0,
      child: GestureDetector(
        onTap: () {
          // 👉 Ouvre la bottom sheet de détail via le DetailPanelBloc
          final bloc = context.read<DetailPanelBloc>();
          bloc.add(
            DetailOpenRequested(
              type: item.kind == NearbyKind.event
                  ? DetailType.event
                  : DetailType.activity,
              idOrPlaceId: item.id,
              byPlaceId: false, // on utilise l'id "classique" du NearbyItem
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(top: 12),
          height: 88,
          decoration: BoxDecoration(
            color: AppColors.fog,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.texasBlue, width: 1),
            boxShadow: const [
              BoxShadow(
                blurRadius: 10,
                offset: Offset(0, 4),
                color: Color(0x12000000),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Stack(
            children: [
              Row(
                children: [
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

              // Label distance discret en bas à droite
              if (item.distanceKm != null)
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: DistanceLabel(km: item.distanceKm!, useMiles: useMiles),
                ),
            ],
          ),
        ),
      ),
    );
  }
}