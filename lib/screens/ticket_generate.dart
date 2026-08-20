import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import '../components/common/movie_poster_image.dart';
import 'homepage.dart';
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
  final String bookingId;
  final String posterUrl;

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
    required this.bookingId,
    required this.posterUrl,
  });

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _revealController;

  @override
  void initState() {
    super.initState();
    _ensureRevealController().forward(from: 0);
  }

  AnimationController _ensureRevealController() {
    return _revealController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300),
    );
  }

  @override
  void dispose() {
    _revealController?.dispose();
    super.dispose();
  }

  void _goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePageScreen()),
      (_) => false,
    );
  }

  void _goToBookings() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyBookingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _ensureRevealController(),
          builder: (context, child) {
            final controller = _ensureRevealController();
            final rotation = CurvedAnimation(
              parent: controller,
              curve: const Interval(0, 0.58, curve: Curves.easeInOutBack),
            ).value;
            final burst = CurvedAnimation(
              parent: controller,
              curve: const Interval(0.54, 0.82, curve: Curves.easeOut),
            ).value;
            final ticketReveal = CurvedAnimation(
              parent: controller,
              curve: const Interval(0.76, 1, curve: Curves.easeOutCubic),
            ).value;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 58, 18, 26),
              child: Column(
                children: [
                  _TicketPanel(
                    posterUrl: widget.posterUrl,
                    movieTitle: widget.movieTitle,
                    cinemaName: widget.cinemaName,
                    cinemaLocation: widget.cinemaLocation,
                    showTime: widget.showTime,
                    selectedSeats: widget.selectedSeats,
                    totalPrice: widget.totalPrice,
                    bookingId: widget.bookingId,
                    rotation: rotation,
                    burst: burst,
                    reveal: ticketReveal,
                  ),
                  const SizedBox(height: 18),
                  Opacity(
                    opacity: ticketReveal,
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(
                                color: Color.fromARGB(255, 150, 32, 32),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _goHome,
                            child: const Text(
                              'Close',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 125, 0, 0),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _goToBookings,
                            child: const Text(
                              'My Bookings',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TicketPanel extends StatelessWidget {
  final String posterUrl;
  final String movieTitle;
  final String cinemaName;
  final String cinemaLocation;
  final String showTime;
  final List<String> selectedSeats;
  final int totalPrice;
  final String bookingId;
  final double rotation;
  final double burst;
  final double reveal;

  const _TicketPanel({
    required this.posterUrl,
    required this.movieTitle,
    required this.cinemaName,
    required this.cinemaLocation,
    required this.showTime,
    required this.selectedSeats,
    required this.totalPrice,
    required this.bookingId,
    required this.rotation,
    required this.burst,
    required this.reveal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 16, 15, 15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color.fromARGB(255, 95, 16, 16)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(160, 109, 4, 4),
            blurRadius: 14,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 250,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (burst > 0)
                  CustomPaint(
                    size: const Size(260, 260),
                    painter: _TicketBurstPainter(progress: burst),
                  ),
                Transform.rotate(
                  angle: rotation * math.pi * 4,
                  child: Transform.scale(
                    scale: 1 + (math.sin(rotation * math.pi) * 0.08),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromARGB(180, 125, 0, 0),
                            blurRadius: 18,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: MoviePosterImage(
                        url: posterUrl,
                        height: 218,
                        width: 146,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(14),
                        fallbackColor: const Color.fromARGB(255, 28, 28, 28),
                        iconColor: const Color.fromARGB(255, 130, 0, 0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Opacity(
            opacity: reveal,
            child: Transform.translate(
              offset: Offset(0, 18 * (1 - reveal)),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Text(
                    movieTitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _TicketInfoRow(
                    icon: Icons.location_on,
                    iconColor: const Color.fromARGB(255, 190, 44, 44),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cinemaName,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                        Text(
                          cinemaLocation,
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _TicketInfoRow(
                    icon: Icons.calendar_month,
                    iconColor: const Color.fromARGB(255, 190, 44, 44),
                    child: Text(
                      showTime,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _TicketInfoRow(
                    icon: Icons.event_seat,
                    iconColor: const Color.fromARGB(255, 190, 44, 44),
                    child: Text(
                      selectedSeats.join(', '),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _TicketInfoRow(
                    icon: Icons.payments,
                    iconColor: const Color.fromARGB(255, 190, 44, 44),
                    child: Text(
                      'Paid Rs. $totalPrice',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: Colors.white12, thickness: 1),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SizedBox(
                      height: 86,
                      width: 86,
                      child: SfBarcodeGenerator(
                        value: bookingId,
                        symbology: QRCode(),
                        showValue: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Booking ID: $bookingId',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketInfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _TicketInfoRow({
    required this.icon,
    required this.child,
    this.iconColor = Colors.white70,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 21, color: iconColor),
        const SizedBox(width: 10),
        Expanded(child: child),
      ],
    );
  }
}

class _TicketBurstPainter extends CustomPainter {
  final double progress;

  const _TicketBurstPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final colors = [
      Colors.yellow,
      Colors.white,
      const Color.fromARGB(255, 180, 0, 0),
      const Color.fromARGB(255, 255, 160, 64),
    ];

    for (var i = 0; i < 22; i += 1) {
      final angle = (math.pi * 2 / 22) * i;
      final distance = 32 + (progress * 112) + (i.isEven ? 10 : 0);
      final point =
          center + Offset(math.cos(angle), math.sin(angle)) * distance;
      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: 1 - progress)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      canvas.drawCircle(point, 3.8 * (1 - (progress * 0.45)), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TicketBurstPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
