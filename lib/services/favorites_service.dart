import '../models/movie.dart';

class FavoritesService {
  final Set<int> _favoriteIds = {};
  bool isFavorite(int movieId) {
    return _favoriteIds.contains(movieId);
  }

  void toggleFavorite(Movie movie) {
    if (_favoriteIds.contains(movie.id)) {
      _favoriteIds.remove(movie.id);
    } else {
      _favoriteIds.add(movie.id);
    }
  }

  List<Movie> getFavorites(List<Movie> movies) {
    return movies.where((movie) => _favoriteIds.contains(movie.id)).toList();
  }

  void removeFavorite(int movieId) {
    _favoriteIds.remove(movieId);
  }

  void clearFavorites() {
    _favoriteIds.clear();
  }
}
