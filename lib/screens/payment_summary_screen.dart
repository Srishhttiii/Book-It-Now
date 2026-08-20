import 'package:flutter/material.dart';
import '../components/common/movie_poster_image.dart';
import '../services/api_client.dart';
import '../services/booking_service.dart';
import '../utils/tmdb_image.dart';
import 'ticket_generate.dart';

class PaymentSummaryScreen extends StatefulWidget {
  final int movieId;
  final String movieTitle;
  final String cinemaName;
  final String cinemaLocation;
  final String showTime;
  final List<String> selectedSeats;
  final int totalPrice;
  final List<String> castList;

  const PaymentSummaryScreen({
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
  State<PaymentSummaryScreen> createState() => _PaymentSummaryScreenState();
}

class _PaymentSummaryScreenState extends State<PaymentSummaryScreen> {
  String? posterUrl;
  bool isPaying = false;

  @override
  void initState() {
    super.initState();
    _fetchPosterUrl();
  }

  Future<void> _fetchPosterUrl() async {
    Object? lastError;

    for (var attempt = 1; attempt <= 3; attempt += 1) {
      try {
        final data = await ApiClient.getJson('/tmdb/movie/${widget.movieId}')
            as Map<String, dynamic>;
        final posterPath = data['poster_path']?.toString() ?? '';
        if (!mounted) return;
        setState(() {
          posterUrl = TmdbImage.poster(posterPath);
        });
        return;
      } catch (error) {
        lastError = error;
        if (attempt < 3) {
          await Future.delayed(Duration(milliseconds: 300 * attempt));
        }
      }
    }

    debugPrint('Could not fetch payment poster: $lastError');
    if (!mounted) return;
    setState(() {
      posterUrl = '';
    });
  }

  Future<void> _payAndOpenTicket() async {
    if (isPaying) return;

    setState(() => isPaying = true);
    final bookingId = 'BK${DateTime.now().millisecondsSinceEpoch}';
    final bookingDetails =
        '${widget.movieTitle} - ${widget.cinemaName} (${widget.showTime})';

    try {
      final success = await BookingService.createBooking(
        movieId: widget.movieId,
        movieTitle: widget.movieTitle,
        bookingDetails: bookingDetails,
        selectedSeats: widget.selectedSeats,
        totalPrice: widget.totalPrice,
      );

      if (!mounted) return;
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
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
        posterUrl: posterUrl ?? '',
        castList: widget.castList,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking successful!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TicketPage(
            movieId: widget.movieId,
            movieTitle: widget.movieTitle,
            cinemaName: widget.cinemaName,
            cinemaLocation: widget.cinemaLocation,
            showTime: widget.showTime,
            selectedSeats: widget.selectedSeats,
            totalPrice: widget.totalPrice,
            castList: widget.castList,
            bookingId: bookingId,
            posterUrl: posterUrl ?? '',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $error')),
      );
    } finally {
      if (mounted) setState(() => isPaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Summary'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 50, 18, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: MoviePosterImage(
                  url: posterUrl,
                  height: 230,
                  width: 155,
                  borderRadius: BorderRadius.circular(14),
                  fallbackColor: const Color.fromARGB(255, 28, 28, 28),
                  iconColor: const Color.fromARGB(255, 140, 0, 0),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.movieTitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 46),
              _PaymentRow(
                icon: Icons.location_on,
                label: 'Cinema',
                title: widget.cinemaName,
                subtitle: widget.cinemaLocation,
              ),
              const Divider(color: Colors.white12, height: 28),
              _PaymentRow(
                icon: Icons.calendar_month,
                label: 'Show Time',
                title: widget.showTime,
              ),
              const Divider(color: Colors.white12, height: 28),
              _PaymentRow(
                icon: Icons.event_seat,
                label: 'Seats',
                title: widget.selectedSeats.join(', '),
              ),
              const Divider(color: Colors.white12, height: 28),
              _PaymentRow(
                icon: Icons.payments,
                label: 'Amount',
                title: 'Rs. ${widget.totalPrice}',
                titleColor: const Color.fromARGB(255, 255, 255, 255),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 125, 0, 0),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: isPaying ? null : _payAndOpenTicket,
          child: isPaying
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.4,
                  ),
                )
              : Text(
                  'Pay Rs. ${widget.totalPrice}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String title;
  final String? subtitle;
  final Color titleColor;

  const _PaymentRow({
    required this.icon,
    required this.label,
    required this.title,
    this.subtitle,
    this.titleColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color.fromARGB(255, 170, 32, 32), size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: const TextStyle(color: Colors.white60, fontSize: 14),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
