// SelectLocationScreen.dart
// ignore_for_file: curly_braces_in_flow_control_structures, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:convert';
import '../models/constants.dart';
import 'cinema_list_screen.dart';

class SelectLocationScreen extends StatelessWidget {
  final int movieId;
  final String movieTitle;
  final List<String> castList;

  const SelectLocationScreen({
    super.key,
    required this.movieId,
    required this.movieTitle,
    required this.castList,
  });

  final List<Map<String, dynamic>> cities = const [
    {
      'name': 'Delhi',
      'lat': 28.6139,
      'lng': 77.2090,
      'image': 'assets/images/delhi.png'
    },
    {
      'name': 'Mumbai',
      'lat': 19.0760,
      'lng': 72.8777,
      'image': 'assets/images/mumbai.png',
    },
    {
      'name': 'Chennai',
      'lat': 13.0827,
      'lng': 80.2707,
      'image': 'assets/images/chennai.png'
    },
    {
      'name': 'Kolkata',
      'lat': 22.5726,
      'lng': 88.3639,
      'image': 'assets/images/kolkata.png'
    },
  ];

  Future<List<Map<String, String>>> fetchCinemas(
      double lat, double lng, String cityName) async {
    final fallbackCinemas = _fallbackCinemasFor(cityName);
    final query = '''
      [out:json][timeout:25];
      (
        node["amenity"="cinema"](around:5000,$lat,$lng);
        way["amenity"="cinema"](around:5000,$lat,$lng);
        relation["amenity"="cinema"](around:5000,$lat,$lng);
      );
      out center;
    ''';

    final url = Uri.parse(
        'https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}');

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) return fallbackCinemas;

      final data = json.decode(response.body);
      final elements = data['elements'] as List<dynamic>;

      final cinemas = elements
          .where((e) => e['tags'] != null && e['tags']['name'] != null)
          .map<Map<String, String>>((e) {
        final tags = e['tags'] as Map<String, dynamic>;

        final parts = <String>[];
        if (tags['addr:street'] != null) {
          parts.add(tags['addr:street'].toString());
        }
        if (tags['addr:suburb'] != null) {
          parts.add(tags['addr:suburb'].toString());
        }
        if (tags['addr:district'] != null) {
          parts.add(tags['addr:district'].toString());
        }
        if (tags['addr:city'] != null) {
          parts.add(tags['addr:city'].toString());
        }

        final location = parts.isEmpty ? cityName : parts.join(', ');

        return {
          'name': tags['name'].toString(),
          'location': location,
        };
      }).toList();

      return cinemas.isEmpty ? fallbackCinemas : cinemas;
    } catch (_) {
      return fallbackCinemas;
    }
  }

  List<Map<String, String>> _fallbackCinemasFor(String cityName) {
    const fallbackByCity = {
      'Delhi': [
        {'name': 'PVR Select Citywalk', 'location': 'Saket, Delhi'},
        {'name': 'INOX Nehru Place', 'location': 'Nehru Place, Delhi'},
        {'name': 'Cinepolis DLF Avenue', 'location': 'Saket, Delhi'},
      ],
      'Mumbai': [
        {
          'name': 'PVR ICON Phoenix Palladium',
          'location': 'Lower Parel, Mumbai'
        },
        {'name': 'INOX R-City', 'location': 'Ghatkopar, Mumbai'},
        {'name': 'Metro INOX Cinema', 'location': 'Marine Lines, Mumbai'},
      ],
      'Chennai': [
        {'name': 'PVR Palazzo', 'location': 'Vadapalani, Chennai'},
        {'name': 'INOX Chennai Citi Centre', 'location': 'Mylapore, Chennai'},
        {'name': 'Sathyam Cinemas', 'location': 'Royapettah, Chennai'},
      ],
      'Kolkata': [
        {'name': 'INOX South City', 'location': 'Jadavpur, Kolkata'},
        {'name': 'PVR Mani Square', 'location': 'Kankurgachi, Kolkata'},
        {'name': 'Cinepolis Acropolis Mall', 'location': 'Kasba, Kolkata'},
      ],
    };

    return List<Map<String, String>>.from(
      fallbackByCity[cityName] ??
          [
            {'name': 'PVR Cinemas', 'location': cityName},
            {'name': 'INOX Cinemas', 'location': cityName},
            {'name': 'Cinepolis', 'location': cityName},
          ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0E0E),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          "Location",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: secondaryFonts,
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 15, 14, 14),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 0, 0, 0),
              Color.fromARGB(255, 49, 1, 1),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: GridView.builder(
              itemCount: cities.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                final city = cities[index];
                final cityName = city['name'] as String;
                final imagePath = city['image'] as String;

                return GestureDetector(
                  onTap: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => Center(
                        child: LoadingAnimationWidget.waveDots(
                          color: kPrimaryColor,
                          size: 50,
                        ),
                      ),
                    );

                    final cinemas = await fetchCinemas(
                      city['lat'],
                      city['lng'],
                      city['name'],
                    );

                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CinemaListScreen(
                          cityName: city['name'],
                          cinemas: cinemas,
                          movieId: movieId,
                          movieTitle: movieTitle,
                          castList: castList,
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: Colors.grey.shade300,
                              child: Center(
                                child: Icon(
                                  Icons.location_city,
                                  size: 40,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                                stops: const [0.5, 1.0],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 10,
                            right: 10,
                            child: Text(
                              cityName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                shadows: [
                                  Shadow(
                                    blurRadius: 4.0,
                                    color: Colors.black,
                                    offset: Offset(1.0, 1.0),
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
