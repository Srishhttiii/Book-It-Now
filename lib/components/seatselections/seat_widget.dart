// ignore_for_file: unreachable_switch_default

import 'dart:async';

import 'package:book_my_seat/book_my_seat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SeatWidget extends StatefulWidget {
  final SeatModel model;
  final FutureOr<bool> Function(int rowI, int colI, SeatState currentState)
      onSeatStateChanged;

  const SeatWidget({
    super.key,
    required this.model,
    required this.onSeatStateChanged,
  });

  @override
  State<SeatWidget> createState() => _SeatWidgetState();
}

class _SeatWidgetState extends State<SeatWidget>
    with SingleTickerProviderStateMixin {
  late SeatState seatState;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    seatState = widget.model.seatState;

    // ✨ Setup pulsing glow animation
    _glowController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _glowController.reverse();
            } else if (status == AnimationStatus.dismissed) {
              _glowController.forward();
            }
          });

    _glowAnimation =
        Tween<double>(begin: 0.7, end: 1.2).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Start glow if seat was already selected
    if (seatState == SeatState.selected) {
      _glowController.forward();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SeatWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.model.seatState != seatState) {
      setState(() {
        seatState = widget.model.seatState;
        _syncGlowWithSeatState();
      });
    }
  }

  void _syncGlowWithSeatState() {
    if (seatState == SeatState.selected) {
      _glowController.forward();
    } else {
      _glowController.stop();
      _glowController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final seatSize = widget.model.seatSvgSize.toDouble();

    return GestureDetector(
      onTap: () async {
        final nextState = switch (seatState) {
          SeatState.unselected => SeatState.selected,
          SeatState.selected => SeatState.unselected,
          _ => null,
        };

        if (nextState == null) return;

        final shouldApplyState = await widget.onSeatStateChanged(
          widget.model.rowI,
          widget.model.colI,
          nextState,
        );

        if (!mounted || !shouldApplyState) return;

        setState(() {
          seatState = nextState;
          _syncGlowWithSeatState();
        });
      },
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, _) {
          bool isSelected = seatState == SeatState.selected;

          return Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              boxShadow: isSelected
                  ? [
                      // Strong glowing red effect for selected
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.9),
                        blurRadius: 30 * _glowAnimation.value,
                        spreadRadius: 10 * _glowAnimation.value,
                      ),
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.4),
                        blurRadius: 60 * _glowAnimation.value,
                        spreadRadius: 20 * _glowAnimation.value,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 🪑 Seat SVG based on its state
                SvgPicture.asset(
                  _getSvgForSeat(seatState),
                  width: seatSize,
                  height: seatSize,
                ),

                // ✨ Light overlay for glowing shine (selected only)
                if (isSelected)
                  Opacity(
                    opacity: 0.6,
                    child: Container(
                      width: seatSize,
                      height: seatSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.redAccent.withOpacity(0.6),
                            Colors.transparent,
                          ],
                          radius: 0.8,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🖼️ SVG Paths for different seat states
  String _getSvgForSeat(SeatState state) {
    switch (state) {
      case SeatState.selected:
        return widget.model.pathSelectedSeat;
      case SeatState.unselected:
        return widget.model.pathUnSelectedSeat;
      case SeatState.sold:
        return widget.model.pathSoldSeat;
      case SeatState.disabled:
        return widget.model.pathDisabledSeat;
      case SeatState.empty:
      default:
        return '';
    }
  }
}
