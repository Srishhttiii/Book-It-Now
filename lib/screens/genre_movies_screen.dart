import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../api_services/tmdb_api.dart';
import '../../models/movie_model.dart';
import '../../models/constants.dart';
import '../screens/movie_detail_screen.dart';

class GenreMoviesScreen extends StatefulWidget {
  final int genreId;
  final String genreName;

  const GenreMoviesScreen({
    super.key,
    required this.genreId,
    required this.genreName,
  });

  @override
  State<GenreMoviesScreen> createState() => _GenreMoviesScreenState();
}

class _GenreMoviesScreenState extends State<GenreMoviesScreen> {
  late Future<List<Movie>> genreMovies;

  @override
  void initState() {
    super.initState();
    genreMovies = ApiService().fetchMoviesByGenre(widget.genreId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        title: Text(
          widget.genreName,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: secondaryFonts),
        ),
        backgroundColor: const Color.fromARGB(252, 0, 0, 0),
        iconTheme: const IconThemeData(
          color: Color.fromARGB(253, 239, 225, 225),
        ),
      ),
      body: FutureBuilder<List<Movie>>(
        future: genreMovies,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.waveDots(
                color: const Color.fromARGB(158, 255, 255, 255),
                size: 50,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No movies found"));
          }

          final movies = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.65,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MovieDetailScreen(
                        movieId: movie.id,
                        movieTitle: movie.title,
                      ),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          movie.posterPath,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: secondaryFonts,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
