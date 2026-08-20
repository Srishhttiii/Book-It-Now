import '../utils/tmdb_image.dart';

class Movie {
  final int id;
  final String title;
  final String posterPath;
  final String backdropPath;
  final double rating;
  final String overview;

  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.backdropPath,
    required this.rating,
    required this.overview,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'] ?? '',
      posterPath: TmdbImage.poster(json['poster_path']?.toString()),
      backdropPath: TmdbImage.backdrop(json['backdrop_path']?.toString()),
      rating: (json['vote_average'] ?? 0).toDouble(),
      overview: json['overview'] ?? '',
    );
  }
}
