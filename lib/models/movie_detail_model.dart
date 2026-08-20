import '../utils/tmdb_image.dart';

class MovieDetail {
  final int id;
  final String title;
  final String overview;
  final String releaseDate;
  final String language;
  final int runtime;
  final double rating;
  final int voteCount;
  final String backdropPath;
  final String posterPath;
  final List<Cast> cast;
  final List<Review> reviews;

  MovieDetail({
    required this.id,
    required this.title,
    required this.overview,
    required this.releaseDate,
    required this.language,
    required this.runtime,
    required this.rating,
    required this.voteCount,
    required this.backdropPath,
    required this.posterPath,
    required this.cast,
    required this.reviews,
  });

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    return MovieDetail(
      id: json['id'],
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      releaseDate: json['release_date'] ?? '',
      language: json['original_language'] ?? '',
      runtime: json['runtime'] ?? 0,
      rating: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      backdropPath: json['backdrop_path'] ?? '',
      posterPath: json['poster_path'] ?? '',
      cast: (json['credits']?['cast'] as List? ?? [])
          .map((c) => Cast.fromJson(c))
          .toList(),
      reviews: (json['reviews']?['results'] as List? ?? [])
          .map((r) => Review.fromJson(r))
          .toList(),
    );
  }
}

class Cast {
  final String name;
  final String character;
  final String profilePath;

  Cast(
      {required this.name, required this.character, required this.profilePath});

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      name: json['name'] ?? '',
      character: json['character'] ?? '',
      profilePath: TmdbImage.profile(json['profile_path']?.toString()),
    );
  }
}

class Review {
  final String author;
  final String content;

  Review({required this.author, required this.content});

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      author: json['author'] ?? '',
      content: json['content'] ?? '',
    );
  }
}
