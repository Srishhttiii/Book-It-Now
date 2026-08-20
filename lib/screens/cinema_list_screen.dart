// cinema_list.dart (UPDATED to StatefulWidget)
// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/ticketbooking/showTiming.dart';
import '../models/constants.dart';
import 'seat_selection_screen.dart';

class CinemaListScreen extends StatefulWidget {
  final String cityName;
  final List<Map<String, String>> cinemas;
  final int movieId;
  final String movieTitle;
  final List<String> castList;

  const CinemaListScreen({
    super.key,
    required this.cityName,
    required this.cinemas,
    required this.movieId,
    required this.movieTitle,
    required this.castList,
  });

  @override
  State<CinemaListScreen> createState() => _CinemaListScreenState();
}

class _CinemaListScreenState extends State<CinemaListScreen> {
  DateTime _selectedDate = DateTime.now();

  final List<String> showTimings = const [
    "10:00 AM",
    "1:00 PM",
    "4:00 PM",
    "7:00 PM",
    "10:00 PM",
  ];

  void _handleDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedDayAndDate = DateFormat('EEE, MMM dd').format(_selectedDate);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Cinemas",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: secondaryFonts),
        ),
      ),
      body: Column(
        children: [
          ShowTimingSelector(
            movieIndex: widget.movieId,
            onDateSelected: _handleDateSelected,
          ),
          Expanded(
            child: widget.cinemas.isEmpty
                ? Center(
                    child: Text(
                      "No cinemas with valid locations found.",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: secondaryFonts,
                          color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    itemCount: widget.cinemas.length,
                    itemBuilder: (context, index) {
                      final cinema = widget.cinemas[index];
                      final cinemaNameAndLocation =
                          "${cinema['name'] ?? 'Cinema'}, ${widget.cityName}";

                      return Card(
                        color: const Color.fromARGB(255, 36, 36, 36),
                        shadowColor: const Color.fromARGB(255, 66, 40, 40),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      color: Color.fromARGB(255, 139, 0, 0),
                                      size: 22),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      cinemaNameAndLocation,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          fontFamily: secondaryFonts,
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              if (cinema['location'] != null)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 4.0, left: 28),
                                  child: Text(
                                    cinema['location']!,
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                        fontFamily: secondaryFonts),
                                  ),
                                ),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 17.0),
                                child: Wrap(
                                  spacing: 10,
                                  runSpacing: 8,
                                  children: showTimings.map((time) {
                                    return ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 190, 188, 188),
                                        foregroundColor: const Color.fromARGB(
                                            255, 15, 13, 13),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => SeatSelectionScreen(
                                              movieId: widget.movieId,
                                              bookingDetailsTitle:
                                                  "${widget.movieTitle} - $cinemaNameAndLocation ($selectedDayAndDate - $time)",
                                              movieTitle: widget.movieTitle,
                                              cinemaName:
                                                  cinema['name'] ?? 'Cinema',
                                              cinemaLocation:
                                                  cinema['location'] ??
                                                      widget.cityName,
                                              dateTime:
                                                  "$selectedDayAndDate - $time",
                                              castList: widget.castList,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(time),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
