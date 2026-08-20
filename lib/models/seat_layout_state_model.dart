import 'package:book_my_seat/book_my_seat.dart';

class SeatLayoutStateModel {
  final int rows;
  final int cols;
  final List<List<SeatState>> currentSeatsState;
  final int seatSvgSize;
  final String pathSelectedSeat;
  final String pathPreviewSeat;
  final String pathUnSelectedSeat;
  final String pathSoldSeat;
  final String pathDisabledSeat;

  const SeatLayoutStateModel({
    required this.rows,
    required this.cols,
    required this.currentSeatsState,
    required this.pathSelectedSeat,
    required this.pathPreviewSeat,
    required this.pathUnSelectedSeat,
    required this.pathSoldSeat,
    required this.pathDisabledSeat,
    this.seatSvgSize = 20,
  });
}
