//---------------------------------------------------------------------------
//                           TEXAS BUDDY   ( 2 0 2 5 )
//---------------------------------------------------------------------------
// File   : features/planning/presentation/widgets/nearby/nearby_card.dart
// Author : Morice
//---------------------------------------------------------------------------

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:texas_buddy/core/theme/app_colors.dart';
import 'package:texas_buddy/features/map/domain/entities/nearby_item.dart';
import 'package:texas_buddy/features/map/presentation/blocs/detail/detail_panel_bloc.dart';

class NearbyCard extends StatefulWidget {
  final NearbyItem item;
  final Widget? trailing;
  final bool dimmed;

  const NearbyCard({
    super.key,
    required this.item,
    this.trailing,
    this.dimmed = false,
  });

  @override
  State<NearbyCard> createState() => _NearbyCardState();
}

class _NearbyCardState extends State<NearbyCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowCtrl;

  bool get _isMatch => widget.item.matchesUserInterest == true;

  @override
  void initState() {
    super.initState();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Pulse uniquement à l’apparition si match
    if (_isMatch) {
      _glowCtrl.forward();
    }
  }

  @override
  void didUpdateWidget(covariant NearbyCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    final wasMatch = oldWidget.item.matchesUserInterest == true;
    final isMatchNow = _isMatch;

    // Si l’item devient "match" après coup, on rejoue un pulse
    if (!wasMatch && isMatchNow) {
      _glowCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opacity = widget.dimmed ? .35 : 1.0;

    return Opacity(
      opacity: opacity,
      child: GestureDetector(
        onTap: () {
          final bloc = context.read<DetailPanelBloc>();
          final lang = Localizations.localeOf(context).languageCode.toLowerCase();

          bloc.add(
            DetailOpenRequested(
              type: widget.item.kind == NearbyKind.event
                  ? DetailType.event
                  : DetailType.activity,
              idOrPlaceId: widget.item.id,
              byPlaceId: false,
              lang: lang,
            ),
          );
        },
        child: TweenAnimationBuilder<double>(
          // micro animation d’apparition (scale léger) uniquement si match
          tween: Tween(begin: _isMatch ? 0.985 : 1.0, end: 1.0),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          builder: (context, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: AnimatedBuilder(
            animation: _glowCtrl,
            builder: (context, child) {
              // t: 0 -> 1 durant le pulse
              final t = _glowCtrl.value;

              final pulse = math.sin(t * math.pi); // 0→1→0

            // Glow plus visible
              final glow1 = AppColors.texasBlue.withAlpha((0x40 + (0x50 * pulse).round()).clamp(0, 0x90));
              final glow2 = AppColors.texasBlue.withAlpha((0x20 + (0x30 * pulse).round()).clamp(0, 0x70));
              
              return Container(
                margin: const EdgeInsets.only(top: 12),
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.fog,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.texasBlue,
                    width: _isMatch ? 1.4 : 1.0,
                  ),
                  boxShadow: [
                    const BoxShadow(
                      blurRadius: 10,
                      offset: Offset(0, 4),
                      color: Color(0x12000000),
                    ),

                    if (_isMatch) ...[
                      // halo large
                      BoxShadow(
                        blurRadius: 22 + (10 * pulse),
                        spreadRadius: 1.5 + (1.2 * pulse),
                        offset: const Offset(0, 0),
                        color: glow2,
                      ),
                      // halo serré (brillant)
                      BoxShadow(
                        blurRadius: 10 + (8 * pulse),
                        spreadRadius: 0.4 + (0.6 * pulse),
                        offset: const Offset(0, 0),
                        color: glow1,
                      ),
                    ],
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
                            widget.item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.texasBlue,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (widget.trailing != null) ...[
                          const SizedBox(width: 8),
                          widget.trailing!,
                        ],
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
