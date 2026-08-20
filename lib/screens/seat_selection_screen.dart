// seat_selection_screen.dart
// lib/services/booking_service.dart

import 'package:book_my_seat/book_my_seat.dart' hide SeatLayoutWidget;
import '../components/seatselections/seat_layout_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../components/seatselections/seat_preview_modal.dart';
import '../models/constants.dart';
import '../services/booking_service.dart';
import 'ticket_generate.dart';

// --- PRICE CONSTANTS ---
const int _priceClassic = 200;
const int _pricePrime = 350;

int _getPriceByRowIndex(int absoluteRowIndex) {
  if (absoluteRowIndex >= 0 && absoluteRowIndex <= 7) return _priceClassic;
  if (absoluteRowIndex >= 8 && absoluteRowIndex <= 9) return _pricePrime;
  return 0;
}

// --- GENERAL COMMENTS BASED ON SEAT SECTIONS ---
final Map<String, String> generalSeatComments = {
  'front':
      'Front rows offer an immersive experience but can be too close for some viewers. Great for action lovers.',
  'middle':
      'Middle rows provide the best balance of sound and visuals — ideal for a comfortable viewing experience.',
  'back':
      'Back rows are perfect for a relaxed, panoramic view and less crowding, though the screen appears smaller.',
};

// --- SPECIFIC COMMENTS FOR PARTICULAR SEATS (optional, extendable) ---
final Map<String, String> seatSpecificComments = {
  'A1': 'Very close to the screen — best for full immersion.',
  'B5': 'Slightly off-center but still gives a good view.',
  'E6': 'Perfectly centered seat with great sound balance.',
  'H10': 'Near the aisle — good for quick exits.',
  'J3': 'Top row, minimal disturbance and best privacy.',
};

class SeatSelectionScreen extends StatefulWidget {
  final int movieId;
  final String bookingDetailsTitle;
  final String movieTitle;
  final String cinemaName;
  final String cinemaLocation;
  final String dateTime;
  final List<String> castList;

  const SeatSelectionScreen({
    super.key,
    required this.movieId,
    required this.bookingDetailsTitle,
    required this.movieTitle,
    required this.cinemaName,
    required this.cinemaLocation,
    required this.dateTime,
    required this.castList,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  Set<SeatNumber> selectedSeats = {};
  int _nextRowLabelIndex = 0;
  int _totalPrice = 0;
  bool _isProcessing = false;

  String _getRowLabel(int index) {
    return String.fromCharCode(65 + index);
  }

  void _calculateTotalPrice() {
    int total = 0;
    for (var seat in selectedSeats) {
      total += seat.price;
    }
    setState(() {
      _totalPrice = total;
    });
  }

  Map<String, String> _parseBookingDetails() {
    final fullTitle = widget.bookingDetailsTitle;

    // 1. Extract the Movie Title (everything before the first ' - ')
    final titleParts = fullTitle.split(' - ');
    String movieTitle =
        titleParts.isNotEmpty ? titleParts.first.trim() : widget.movieTitle;

    // The remaining string contains the cinema, location, and date/time.
    // Example: "INOX, Delhi (Thu, Sep 25 - 10:00 AM)"
    String remainingString = fullTitle.substring(movieTitle.length + 3).trim();

    // Regex to capture "Cinema Details" (Group 1) and the content inside the parentheses (Group 2: Date and Time)
    final regex = RegExp(r'^(.*?)\s\((.*?)\)$');
    final match = regex.firstMatch(remainingString);

    String cinemaDetailsSubtitle = "N/A";
    String showDateTime = "N/A"; // This will hold "Day, Date - Time"

    if (match != null && match.groupCount == 2) {
      // Group 1: Cinema Name, City Name (e.g., "INOX, Delhi")
      cinemaDetailsSubtitle = match.group(1)?.trim() ?? "N/A";
      // Group 2: Day, Date - Time (e.g., "Thu, Sep 25 - 10:00 AM")
      showDateTime = match.group(2)?.trim() ?? "N/A";
    }
    // If regex fails, use existing logic as a fallback (less reliable)
    else {
      cinemaDetailsSubtitle =
          remainingString.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim();
      // Try to find the time/date in parentheses manually if regex failed
      final timeMatch = RegExp(r'\((.*?)\)$').firstMatch(remainingString);
      showDateTime = timeMatch?.group(1)?.trim() ?? "N/A";
    }

    // Now, showDateTime holds the full string, including Day and Date.
    return {
      'movieTitle': movieTitle,
      'cinemaDetailsSubtitle': cinemaDetailsSubtitle,
      // The full string including Day and Date is used for the banner.
      'showTime': showDateTime,
    };
  }

  Widget _buildSectionTitle(String title, int price) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
      color: const Color.fromARGB(255, 15, 14, 14),
      child: Text(
        '$title: Rs. $price',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Color.fromARGB(255, 128, 125, 125),
        ),
      ),
    );
  }

// --- HANDLE BOOKING PROCESS ---
  Future<void> _handleBooking() async {
    if (selectedSeats.isEmpty) return;

    // 1. Show loading indicator
    setState(() {
      _isProcessing = true;
    });

    final seatStrings =
        selectedSeats.map((seat) => seat.toSeatString(_getRowLabel)).toList();

    // 2. using try-catch to handle errors from BookingService
    try {
      // Call the booking service
      bool success = await BookingService.createBooking(
        movieId: widget.movieId,
        movieTitle: widget.movieTitle,
        bookingDetails: widget.bookingDetailsTitle,
        selectedSeats: seatStrings,
        totalPrice: _totalPrice,
      );

      // Check if the widget is still in the tree
      if (!mounted) return;

      // 3. This 'if' will only run if success is true AND no error was thrown
      if (success) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TicketPage(
              movieId: widget.movieId,
              movieTitle: widget.movieTitle,
              cinemaName: widget.cinemaName,
              cinemaLocation: widget.cinemaLocation,
              showTime: widget.dateTime,
              selectedSeats: seatStrings,
              totalPrice: _totalPrice,
              castList: widget.castList,
            ),
          ),
        );
      } else {
        // This case handles when success is false but no exception was thrown

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // 4. This block will catch the *real* error from BookingService
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // Display the actual error message
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // 5. 'finally' ensures the loading indicator is always hidden
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _nextRowLabelIndex = 0;
    final details = _parseBookingDetails();
    final movieTitle = details['movieTitle']!;
    final cinemaDetailsSubtitle = details['cinemaDetailsSubtitle']!;
    final showTime = details['showTime']!; // This is now "Day, Date - Time"

    // Helper to build a section, update the index, and return the widgets
    List<Widget> buildSectionAndUpdate({
      required int rows,
      required int cols,
      required List<List<SeatState>> seatStates,
    }) {
      final widgets = buildSeatSection(
        startRowIndex: _nextRowLabelIndex,
        rows: rows,
        cols: cols,
        seatStates: seatStates,
      );
      _nextRowLabelIndex += rows;
      return widgets;
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 15, 14, 14),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              movieTitle,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: secondaryFonts),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              cinemaDetailsSubtitle,
              style: const TextStyle(fontSize: 15, color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        backgroundColor: Colors.black,
        foregroundColor: const Color.fromARGB(255, 254, 254, 254),
        elevation: 1,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Show Time Banner - Now displays full date and time
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  color: const Color.fromARGB(255, 65, 2, 2),
                  child: Center(
                    child: Text(
                      // ShowTime now contains Day and Date
                      'Show Time: $showTime', // Output: "Show Time: Thu, Sep 25 - 10:00 AM"
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),
                const Text(
                  "Screen This Way",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/theatre_screen_image.png',
                        fit: BoxFit.cover,
                        width: 400,
                      ),
                    ],
                  ),
                ),

                _buildSectionTitle('CLASSIC', _priceClassic),
                const SizedBox(height: 5),

                /// Section 1-A (Rows A, B, C, D)
                ...buildSectionAndUpdate(
                  rows: 4,
                  cols: 10,
                  seatStates: [
                    [
                      SeatState.unselected,
                      SeatState.sold,
                      SeatState.unselected,
                      SeatState.disabled,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.sold,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.unselected
                    ],
                    [
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.sold,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.disabled,
                      SeatState.unselected
                    ],
                    [
                      SeatState.sold,
                      SeatState.sold,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.sold,
                      SeatState.unselected,
                      SeatState.unselected
                    ],
                    [
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.disabled,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.unselected
                    ],
                  ],
                ),

                const SizedBox(height: 18),

                /// Section 1-B (Rows E, F, G, H) - Part of CLASSIC
                ...buildSectionAndUpdate(
                  rows: 4,
                  cols: 10,
                  seatStates: [
                    [
                      SeatState.unselected,
                      SeatState.sold,
                      SeatState.unselected,
                      SeatState.disabled,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.sold,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.unselected
                    ],
                    [
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.sold,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.disabled,
                      SeatState.unselected
                    ],
                    [
                      SeatState.sold,
                      SeatState.sold,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.sold,
                      SeatState.unselected,
                      SeatState.unselected
                    ],
                    [
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.disabled,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.unselected
                    ],
                  ],
                ),

                const SizedBox(height: 18),

                _buildSectionTitle('PRIME', _pricePrime),
                const SizedBox(height: 10),

                /// Section 2 (Rows I, J)
                ...buildSectionAndUpdate(
                  rows: 2,
                  cols: 10,
                  seatStates: [
                    [
                      SeatState.unselected,
                      SeatState.sold,
                      SeatState.unselected,
                      SeatState.disabled,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.sold,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.unselected
                    ],
                    [
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.sold,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.unselected,
                      SeatState.disabled,
                      SeatState.unselected
                    ],
                  ],
                ),

                const SizedBox(height: 20),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 12, right: 12, bottom: 80),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 18,
                    runSpacing: 12,
                    children: [
                      legendItem('Disabled',
                          'assets/images/svg_disabled_bus_seat.svg'),
                      legendItem('Sold', 'assets/images/svg_sold_bus_seat.svg'),
                      legendItem('Available',
                          'assets/images/svg_unselected_bus_seat.svg'),
                      legendItem('Selected',
                          'assets/images/svg_selected_bus_seats.svg'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

// Add this floating section after your Scaffold body:
      bottomSheet: selectedSeats.isEmpty
          ? null
          : AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              height: 120,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 19, 19, 19),
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Selected',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 17,
                            fontFamily: secondaryFonts),
                      ),
                      Text(
                        '${selectedSeats.length} seat${selectedSeats.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          fontFamily: secondaryFonts,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _isProcessing ? null : _handleBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 120, 10, 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 80, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Text(
                            "Pay ₹$_totalPrice",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                fontFamily: secondaryFonts),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

// --- DETERMINE SEAT SECTION ---
  String _getSeatSection(String seatLabel) {
    final row = seatLabel[0].toUpperCase();
    if (['A', 'B', 'C', 'D'].contains(row)) return 'front';
    if (['E', 'F', 'G', 'H'].contains(row)) return 'middle';
    if (['I', 'J'].contains(row)) return 'back';
    return 'middle';
  }

  // --- SHOW SEAT PREVIEW MODAL ---
  Future<bool> _showSeatPreviewModal(
    BuildContext context,
    String seatLabel,
    int seatPrice,
    VoidCallback onSelect,
  ) async {
    final seatSection = _getSeatSection(seatLabel);
    final generalComment =
        generalSeatComments[seatSection] ?? 'General seating info unavailable.';
    final seatComment = seatSpecificComments[seatLabel] ?? generalComment;

    final didConfirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return SeatPreviewModal(
          seatLabel: seatLabel,
          seatComment: seatComment,

          // Keep your seat view images named like A1.jpg, B3.jpg, etc.
          onSelectSeat: () {
            Navigator.pop(ctx, true); // close modal and confirm selection
            onSelect(); // actually select seat
          },
          onClose: () {
            Navigator.pop(ctx, false); // just close modal
          },
        );
      },
    );

    return didConfirm ?? false;
  }

  // Reusable function to build the seat section row-by-row with labels (Unchanged)
  List<Widget> buildSeatSection({
    required int startRowIndex,
    required int rows,
    required int cols,
    required List<List<SeatState>> seatStates,
  }) {
    return List.generate(rows, (rowIndex) {
      final absoluteRowIndex = startRowIndex + rowIndex;
      final rowLabel = _getRowLabel(absoluteRowIndex);
      final displaySeatStates = List<SeatState>.generate(cols, (colIndex) {
        final currentSeatState = seatStates[rowIndex][colIndex];
        final seatNumber = SeatNumber(
          rowI: absoluteRowIndex,
          colI: colIndex,
          price: _getPriceByRowIndex(absoluteRowIndex),
        );

        if (currentSeatState == SeatState.unselected &&
            selectedSeats.contains(seatNumber)) {
          return SeatState.selected;
        }

        return currentSeatState;
      });

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              child: Text(
                rowLabel,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 249, 249, 249),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Center(
              child: SeatLayoutWidget(
                onSeatStateChanged: (localRowI, colI, seatState) async {
                  final seatPrice = _getPriceByRowIndex(absoluteRowIndex);
                  final seatLabel =
                      '${_getRowLabel(absoluteRowIndex)}${colI + 1}';
                  final seatNumber = SeatNumber(
                    rowI: absoluteRowIndex,
                    colI: colI,
                    price: seatPrice,
                  );
                  if (seatState == SeatState.selected) {
                    return _showSeatPreviewModal(
                      context,
                      seatLabel,
                      seatPrice,
                      () {
                        setState(() {
                          selectedSeats.add(seatNumber);
                          _calculateTotalPrice();
                        });
                      },
                    );
                  }

                  setState(() {
                    selectedSeats.remove(seatNumber);
                    _calculateTotalPrice();
                  });
                  return true;
                },
                stateModel: SeatLayoutStateModel(
                  currentSeatsState: [displaySeatStates],
                  pathDisabledSeat: 'assets/images/svg_disabled_bus_seat.svg',
                  pathSelectedSeat: 'assets/images/svg_selected_bus_seats.svg',
                  pathSoldSeat: 'assets/images/svg_sold_bus_seat.svg',
                  pathUnSelectedSeat:
                      'assets/images/svg_unselected_bus_seat.svg',
                  rows: 1,
                  cols: cols,
                  seatSvgSize: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 16,
              child: Text(
                rowLabel,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget legendItem(String label, String assetPath) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(assetPath, width: 25, height: 25),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(fontSize: 15, color: Colors.white70)),
      ],
    );
  }
}

// --- SeatNumber CLASS (Unchanged) ---
class SeatNumber {
  final int rowI;
  final int colI;
  final int price;

  const SeatNumber(
      {required this.rowI, required this.colI, required this.price});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SeatNumber && rowI == other.rowI && colI == other.colI;

  @override
  int get hashCode => Object.hash(rowI, colI);

  String toSeatString(String Function(int) getRowLabel) {
    final rowLetter = getRowLabel(rowI);
    return '$rowLetter${colI + 1}';
  }
}
