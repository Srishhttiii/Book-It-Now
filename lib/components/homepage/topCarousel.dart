// ignore_for_file: file_names

import 'package:bookmyshowclone/models/constants.dart';
import 'package:bookmyshowclone/models/movie_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../api_services/tmdb_api.dart';

class TopCarouselSection extends StatefulWidget {
  const TopCarouselSection({super.key});

  @override
  State<TopCarouselSection> createState() => _TopCarouselSectionState();
}

class _TopCarouselSectionState extends State<TopCarouselSection> {
  final ApiService apiService = ApiService();
  List<Movie> trendingMovies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTrendingMovies();
  }

  void fetchTrendingMovies() async {
    try {
      final response = await apiService.fetchTrendingMovies();
      setState(() {
        trendingMovies = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Failed to fetch trending movies: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
          child: Text(
            "Trending This Month 🔥",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: secondaryFonts,
                color: Colors.white),
          ),
        ),
        if (isLoading)
          SizedBox(
            height: 220,
            child: Center(
              child: LoadingAnimationWidget.waveDots(
                color: const Color.fromARGB(158, 255, 255, 255),
                size: 50,
              ),
            ),
          )
        else if (trendingMovies.isEmpty)
          const SizedBox(
            height: 220,
            child: Center(child: Text("No trending movies found.")),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
            child: FlutterCarousel(
              items: trendingMovies.map((movie) {
                final posterUrl = movie.posterPath.isNotEmpty
                    ? movie.posterPath
                    : 'https://via.placeholder.com/500x750?text=No+Image';

                return Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 2 / 3,
                          child: Image.network(
                            posterUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.yellow, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  movie.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              options: FlutterCarouselOptions(
                height: 220,
                enableInfiniteScroll: true,
                viewportFraction: 0.45,
                autoPlay: true,
                showIndicator: false,
              ),
            ),
          ),
      ],
    );
  }
}
