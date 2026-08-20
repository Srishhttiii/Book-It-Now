import '../models/movie_detail_model.dart';
import '../models/movie_model.dart';
import '../services/api_client.dart';
import '../utils/tmdb_image.dart';

class ApiService {
  /// Fetch upcoming movies from TMDb through the local backend.
  Future<List<Movie>> fetchUpcomingMovies() async {
    final data = await ApiClient.getJson('/tmdb/movie/upcoming/list')
        as Map<String, dynamic>;
    final List results = data['results'] ?? [];

    final filtered = results.where((movie) {
      final dateStr = movie['release_date'] ?? '';
      return dateStr.isNotEmpty;
    }).toList();

    return filtered.map((json) => Movie.fromJson(json)).toList();
  }

  /// Fetch now playing / new releases (exclude movies that are in upcoming)
  Future<List<Movie>> fetchNowPlayingMovies() async {
    final upcomingMovies = await fetchUpcomingMovies();
    final upcomingIds = upcomingMovies.map((m) => m.id).toSet();

    final data = await ApiClient.getJson('/tmdb/movie/now_playing/list')
        as Map<String, dynamic>;
    final List results = data['results'] ?? [];
    final today = DateTime.now();

    final filtered = results.where((movie) {
      final dateStr = movie['release_date'] ?? '';
      if (dateStr.isEmpty) return false;
      final releaseDate = DateTime.tryParse(dateStr);
      return releaseDate != null &&
          releaseDate.isBefore(today) &&
          !upcomingIds.contains(movie['id']);
    }).toList();

    return filtered.map((json) => Movie.fromJson(json)).toList();
  }

  /// Fetch movies by genre
  Future<List<Movie>> fetchMoviesByGenre(int genreId) async {
    final data = await ApiClient.getJson(
      '/tmdb/discover/movie?with_genres=$genreId&sort_by=popularity.desc&page=1',
    ) as Map<String, dynamic>;
    final List results = data['results'] ?? [];
    final filtered = results.where((m) => m['adult'] == false).toList();
    return filtered.map((json) => Movie.fromJson(json)).toList();
  }

  Future<MovieDetail> fetchMovieDetails(int movieId) async {
    final data = await ApiClient.getJson('/tmdb/movie/$movieId/details')
        as Map<String, dynamic>;
    final detailJson = data['detail'] as Map<String, dynamic>;
    final creditsJson = data['credits'] as Map<String, dynamic>;
    final reviewsJson = data['reviews'] as Map<String, dynamic>;

    return MovieDetail(
      id: detailJson['id'],
      title: detailJson['title'] ?? '',
      overview: detailJson['overview'] ?? '',
      releaseDate: detailJson['release_date'] ?? '',
      language: detailJson['original_language'] ?? '',
      runtime: detailJson['runtime'] ?? 0,
      rating: (detailJson['vote_average'] ?? 0).toDouble(),
      voteCount: detailJson['vote_count'] ?? 0,
      backdropPath: TmdbImage.backdrop(detailJson['backdrop_path']?.toString()),
      posterPath: TmdbImage.poster(detailJson['poster_path']?.toString()),
      cast: (creditsJson['cast'] as List).map((c) => Cast.fromJson(c)).toList(),
      reviews: (reviewsJson['results'] as List)
          .map((r) => Review.fromJson(r))
          .toList(),
    );
  }

  Future<List<Movie>> fetchTrendingMovies() async {
    final data = await ApiClient.getJson('/tmdb/trending/movie/week')
        as Map<String, dynamic>;
    final List results = data['results'] ?? [];
    return results.map((json) => Movie.fromJson(json)).toList();
  }
}
