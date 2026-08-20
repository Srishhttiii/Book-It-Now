import 'dart:async';

import 'package:book_my_seat/book_my_seat.dart';
import 'package:flutter/material.dart';
import 'seat_widget.dart';

class SeatLayoutWidget extends StatelessWidget {
  final SeatLayoutStateModel stateModel;
  final FutureOr<bool> Function(int rowI, int colI, SeatState currentState)
      onSeatStateChanged;

  const SeatLayoutWidget({
    super.key,
    required this.stateModel,
    required this.onSeatStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      maxScale: 5,
      minScale: 0.8,
      boundaryMargin: const EdgeInsets.all(10),
      child: Column(
        children: List.generate(stateModel.rows, (rowI) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(stateModel.cols, (colI) {
              return Padding(
                padding: const EdgeInsets.all(3.0),
                child: SeatWidget(
                  model: SeatModel(
                    rowI: rowI,
                    colI: colI,
                    seatState: stateModel.currentSeatsState[rowI][colI],
                    seatSvgSize: stateModel.seatSvgSize,
                    pathSelectedSeat: stateModel.pathSelectedSeat,
                    pathUnSelectedSeat: stateModel.pathUnSelectedSeat,
                    pathSoldSeat: stateModel.pathSoldSeat,
                    pathDisabledSeat: stateModel.pathDisabledSeat,
                  ),
                  onSeatStateChanged: onSeatStateChanged,
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}
