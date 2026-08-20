class TmdbImage {
  static const String _baseUrl = 'https://image.tmdb.org/t/p';

  static String poster(String? path, {String size = 'w500'}) {
    return _url(path, size: size);
  }

  static String backdrop(String? path, {String size = 'w500'}) {
    return _url(path, size: size);
  }

  static String profile(String? path, {String size = 'w200'}) {
    return _url(path, size: size);
  }

  static String _url(String? path, {required String size}) {
    final value = path ?? '';
    if (value.isEmpty) return '';
    if (value.startsWith('http')) return value;
    return '$_baseUrl/$size$value';
  }
}
