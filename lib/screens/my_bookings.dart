// ignore_for_file: deprecated_member_use, unused_local_variable

import 'package:flutter/material.dart';
import 'homepage.dart';
import 'review.dart';
import '../services/booking_service.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';

class BookingPoster extends StatelessWidget {
  final String? url;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const BookingPoster({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = url ?? '';
    final fallback = Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 143, 42, 42),
        borderRadius: borderRadius,
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.local_movies,
        color: Colors.white,
        size: 48,
      ),
    );

    if (!imageUrl.startsWith('http')) return fallback;

    final image = Image.network(
      imageUrl,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (_, __, ___) => fallback,
    );

    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  late Future<List<Map<String, dynamic>>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = BookingService.getBookings();
  }

  void _refreshBookings() {
    setState(() {
      _bookingsFuture = BookingService.getBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          " All Set for Movie Mayhem!",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white, size: 28),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePageScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Could not load bookings: ${snapshot.error}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }

          final bookings = snapshot.data ?? [];
          if (bookings.isEmpty) {
            return const Center(
              child: Text(
                "No bookings yet",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _refreshBookings(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];

                return GestureDetector(
                  onTap: () async {
                    await showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.black.withOpacity(0.9),
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (_) => BookingDetailsSheet(
                        booking: booking,
                        bookingId: booking['bookingId'].toString(),
                        onReviewed: _refreshBookings,
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        BookingPoster(
                          url: booking['posterUrl']?.toString(),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        Container(color: Colors.black.withOpacity(0.45)),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking['movieTitle'] ?? '',
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "${booking['cinemaName'] ?? ''}, ${booking['cinemaLocation'] ?? ''}",
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                booking['showTime'] ?? "Date not available",
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class BookingDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> booking;
  final String bookingId;
  final VoidCallback onReviewed;

  const BookingDetailsSheet({
    super.key,
    required this.booking,
    required this.bookingId,
    required this.onReviewed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 6,
              width: 60,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(3)),
            ),
            BookingPoster(
              url: booking['posterUrl']?.toString(),
              height: 200,
              width: double.infinity,
              borderRadius: BorderRadius.circular(16),
            ),
            const SizedBox(height: 16),
            Text(
              booking['movieTitle'] ?? '',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 14),
            infoRow(
              "📍 Cinema",
              "${booking['cinemaName'] ?? "Unknown Cinema"}, ${booking['cinemaLocation'] ?? "Location not available"}",
            ),
            infoRow("🗓 Date & Time", booking['showTime'] ?? "Not available"),
            infoRow(
                "💺 Seats",
                (booking['selectedSeats'] != null &&
                        booking['selectedSeats'].isNotEmpty)
                    ? List<String>.from(booking['selectedSeats']).join(", ")
                    : "Not selected"),
            infoRow(
                "💰 Paid",
                booking['totalPrice'] != null
                    ? "Rs. ${booking['totalPrice']}"
                    : "Not available"),
            const SizedBox(height: 14),
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: SfBarcodeGenerator(
                    value: (booking['bookingId'] ?? "000000").toString(),
                    symbology: QRCode(),
                    showValue: false,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Booking ID: $bookingId",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: Builder(
                builder: (context) {
                  final showTime = _parseShowTime(booking['showTime']);
                  final now = DateTime.now();
                  final hasShowStarted =
                      showTime != null && now.isAfter(showTime);
                  final isReviewed = booking['reviewed'] == true;
                  final isButtonEnabled = hasShowStarted && !isReviewed;

                  return ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (states) {
                          if (states.contains(MaterialState.disabled)) {
                            return Colors.grey;
                          }
                          return const Color.fromARGB(255, 65, 2, 2);
                        },
                      ),
                      padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 14)),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    onPressed: isButtonEnabled
                        ? () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReviewPage(
                                  bookingId: booking['bookingId'],
                                ),
                              ),
                            );
                            if (result == true) {
                              await BookingService.markReviewed(bookingId);
                              onReviewed();
                              if (context.mounted) Navigator.pop(context);
                            }
                          }
                        : null,
                    child: Text(
                      isReviewed
                          ? "Reviewed"
                          : isButtonEnabled
                              ? "Review"
                              : "Review (Available after Show)",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  DateTime? _parseShowTime(dynamic rawTime) {
    if (rawTime is! String) return null;
    try {
      final regex = RegExp(
          r'([A-Za-z]{3}), ([A-Za-z]{3}) (\d{1,2}) - (\d{1,2}):(\d{2}) ([APMapm]{2})');
      final match = regex.firstMatch(rawTime);
      if (match == null) return null;

      const months = {
        'Jan': 1,
        'Feb': 2,
        'Mar': 3,
        'Apr': 4,
        'May': 5,
        'Jun': 6,
        'Jul': 7,
        'Aug': 8,
        'Sep': 9,
        'Oct': 10,
        'Nov': 11,
        'Dec': 12
      };
      final month = months[match.group(2)!] ?? 1;
      final day = int.parse(match.group(3)!);
      final hour = int.parse(match.group(4)!);
      final minute = int.parse(match.group(5)!);
      final period = match.group(6)!.toUpperCase();
      var hour24 = hour % 12;
      if (period == 'PM') hour24 += 12;
      final now = DateTime.now();
      return DateTime(now.year, month, day, hour24, minute);
    } catch (_) {
      return null;
    }
  }

  Widget infoRow(String icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon,
              style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
