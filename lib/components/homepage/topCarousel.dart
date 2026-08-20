// ignore_for_file: file_names

import 'package:bookmyshowclone/models/constants.dart';
import 'package:bookmyshowclone/models/movie_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../api_services/tmdb_api.dart';
import '../../components/common/movie_poster_image.dart';
import '../../screens/movie_detail_screen.dart';

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
            "Trending",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: secondaryFonts,
                color: Colors.white),
          ),
        ),
        if (isLoading)
          SizedBox(
            height: 190,
            child: Center(
              child: LoadingAnimationWidget.waveDots(
                color: const Color.fromARGB(158, 255, 255, 255),
                size: 50,
              ),
            ),
          )
        else if (trendingMovies.isEmpty)
          const SizedBox(
            height: 190,
            child: Center(
              child: Text(
                "No trending movies found.",
                style: TextStyle(color: Colors.white54),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: FlutterCarousel(
              items: trendingMovies.map((movie) {
                final imageUrl = movie.backdropPath.isNotEmpty
                    ? movie.backdropPath
                    : movie.posterPath;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailScreen(
                          movieId: movie.id,
                          movieTitle: movie.title,
                        ),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          MoviePosterImage(
                            url: imageUrl,
                            width: double.infinity,
                            height: 180,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.78),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 14,
                            right: 14,
                            bottom: 14,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Text(
                                    movie.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: secondaryFonts,
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.72),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.yellow,
                                        size: 16,
                                      ),
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
              options: FlutterCarouselOptions(
                height: 180,
                enableInfiniteScroll: true,
                viewportFraction: 0.88,
                autoPlay: true,
                showIndicator: false,
              ),
            ),
          ),
      ],
    );
  }
}
