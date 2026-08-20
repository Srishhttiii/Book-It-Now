import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import '../components/common/movie_poster_image.dart';
import '../utils/tmdb_image.dart';
import '../services/api_client.dart';
import '../services/booking_service.dart';
import 'my_bookings.dart';

class TicketPage extends StatefulWidget {
  final int movieId;
  final String movieTitle;
  final String cinemaName;
  final String cinemaLocation;
  final String showTime;
  final List<String> selectedSeats;
  final int totalPrice;
  final List<String> castList;

  const TicketPage({
    super.key,
    required this.movieId,
    required this.movieTitle,
    required this.cinemaName,
    required this.cinemaLocation,
    required this.showTime,
    required this.selectedSeats,
    required this.totalPrice,
    required this.castList,
  });

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  String? posterUrl;
  String bookingId = '';
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    fetchMoviePoster();
    generateBookingId();
  }

  Future<String> _fetchPosterUrl() async {
    Object? lastError;

    for (var attempt = 1; attempt <= 3; attempt += 1) {
      try {
        final data = await ApiClient.getJson('/tmdb/movie/${widget.movieId}')
            as Map<String, dynamic>;
        final posterPath = data['poster_path']?.toString() ?? '';
        if (posterPath.isNotEmpty) {
          return TmdbImage.poster(posterPath);
        }
        return '';
      } catch (error) {
        lastError = error;
        if (attempt < 3) {
          await Future.delayed(Duration(milliseconds: 300 * attempt));
        }
      }
    }

    debugPrint('Could not fetch ticket poster: $lastError');
    return '';
  }

  Future<void> fetchMoviePoster() async {
    final url = await _fetchPosterUrl();
    if (!mounted) return;
    setState(() {
      posterUrl = url;
    });
  }

  void generateBookingId() {
    bookingId = 'BK${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> saveBookingToMySql() async {
    setState(() => isSaving = true);

    try {
      final posterToSave = (posterUrl ?? '').startsWith('http')
          ? posterUrl!
          : await _fetchPosterUrl();

      if (!mounted) return;
      if (posterToSave != posterUrl) {
        setState(() {
          posterUrl = posterToSave;
        });
      }

      await BookingService.saveTicketBooking(
        bookingId: bookingId,
        movieId: widget.movieId,
        movieTitle: widget.movieTitle,
        cinemaName: widget.cinemaName,
        cinemaLocation: widget.cinemaLocation,
        showTime: widget.showTime,
        selectedSeats: widget.selectedSeats,
        totalPrice: widget.totalPrice,
        posterUrl: posterToSave,
        castList: widget.castList,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking saved successfully!')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyBookingsPage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving booking: $e')),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 0, 0, 0)),
        title: const Padding(
          padding: EdgeInsets.only(top: 30),
          child: Text(
            "🎞️ Your Golden Ticket 🎞️",
            style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: posterUrl == null
            ? const CircularProgressIndicator(
                color: Color.fromARGB(255, 255, 254, 254))
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 232, 231, 231),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(255, 109, 4, 4),
                        blurRadius: 8,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MoviePosterImage(
                        url: posterUrl,
                        height: 200,
                        width: double.infinity,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        fallbackColor: const Color.fromARGB(255, 210, 210, 210),
                        iconColor: const Color.fromARGB(255, 100, 0, 0),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.movieTitle,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "📍",
                                  style: TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.cinemaName,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        widget.cinemaLocation,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Text(
                                  "🗓",
                                  style: TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.showTime,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(
                                  Icons.event_seat,
                                  size: 20,
                                  color: Colors.black87,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    " ${widget.selectedSeats.join(", ")}",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.payments,
                                  size: 20,
                                  color: Color.fromARGB(255, 100, 0, 0),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Paid Rs. ${widget.totalPrice}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 139, 0, 0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Divider(color: Colors.grey[400], thickness: 1),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 80,
                        width: 80,
                        child: SfBarcodeGenerator(
                          value: bookingId,
                          symbology: QRCode(),
                          showValue: false,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Booking ID: $bookingId",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 30.0, right: 15, left: 15),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 65, 2, 2),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: isSaving ? null : saveBookingToMySql,
          child: isSaving
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  "My Bookings",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
