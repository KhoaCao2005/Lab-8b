import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/movie_service.dart';
import '../services/favorites_service.dart';
import 'movie_detail_screen.dart';
import 'home_screen.dart';

class MovieScreen extends StatefulWidget {
  const MovieScreen({super.key});

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  final MovieService _movieService = MovieService();
  final FavoritesService _favoritesService = FavoritesService();

  late Future<List<Movie>> _moviesFuture;

  String _selectedGenre = 'All';
  double? _selectedRating;

  static const Map<int, String> _genreMap = {
    28: 'Action',
    12: 'Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    99: 'Documentary',
    18: 'Drama',
    10751: 'Family',
    14: 'Fantasy',
    36: 'History',
    27: 'Horror',
    10402: 'Music',
    9648: 'Mystery',
    10749: 'Romance',
    878: 'Science Fiction',
    10770: 'TV Movie',
    53: 'Thriller',
    10752: 'War',
    37: 'Western',
  };

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  void _loadMovies() {
    setState(() {
      _moviesFuture = _movieService.fetchTrendingMovies();
    });
  }

  Future<void> _retry() async {
    _loadMovies();
  }

  void _toggleFavorite(Movie movie) {
    setState(() {
      _favoritesService.toggleFavorite(movie);
    });
  }

  List<Movie> _filterMovies(List<Movie> movies) {
    return movies.where((movie) {
      final bool genreMatches =
          _selectedGenre == 'All' ||
          movie.genreIds.any((genreId) => _genreMap[genreId] == _selectedGenre);

      final bool ratingMatches =
          _selectedRating == null || movie.rating >= _selectedRating!;

      return genreMatches && ratingMatches;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      _selectedGenre = 'All';
      _selectedRating = null;
    });
  }

  bool get _hasActiveFilter {
    return _selectedGenre != 'All' || _selectedRating != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF425363), Color(0xFF26323D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: FutureBuilder<List<Movie>>(
                  future: _moviesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (snapshot.hasError) {
                      return _buildError(snapshot.error);
                    }

                    final movies = snapshot.data ?? [];

                    if (movies.isEmpty) {
                      return const Center(
                        child: Text(
                          'No movies found.',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final filteredMovies = _filterMovies(movies);

                    return RefreshIndicator(
                      onRefresh: _retry,
                      color: const Color(0xFFFF521B),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                        children: [
                          _buildFilterSection(),
                          const SizedBox(height: 16),
                          Text(
                            _hasActiveFilter
                                ? '${filteredMovies.length} movies found'
                                : '${movies.length} movies',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (filteredMovies.isEmpty)
                            _buildNoResults()
                          else
                            ...filteredMovies.map(
                              (movie) => _buildMovieCard(movie),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Home',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
            icon: const Icon(
              Icons.home_outlined,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.movie_outlined, color: Colors.white, size: 25),
          const SizedBox(width: 10),
          const Text(
            'Movie Explorer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF5A6B7C), Color(0xFF323B44)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list, color: Colors.white),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Filter Movies',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (_hasActiveFilter)
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Genre',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          _buildGenreDropdown(),
          const SizedBox(height: 14),
          const Text(
            'Minimum Rating',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          _buildRatingDropdown(),
        ],
      ),
    );
  }

  Widget _buildGenreDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedGenre,
      dropdownColor: const Color(0xFFFDFBF7),
      style: const TextStyle(
        color: Color(0xFF1E4663),
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFFDFBF7),
        prefixIcon: const Icon(
          Icons.category_outlined,
          color: Color(0xFF5A6B7C),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      items: [
        const DropdownMenuItem(value: 'All', child: Text('All Genres')),
        ..._genreMap.values.map(
          (genre) => DropdownMenuItem(value: genre, child: Text(genre)),
        ),
      ],
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _selectedGenre = value;
        });
      },
    );
  }

  Widget _buildRatingDropdown() {
    return DropdownButtonFormField<double?>(
      initialValue: _selectedRating,
      dropdownColor: const Color(0xFFFDFBF7),
      style: const TextStyle(
        color: Color(0xFF1E4663),
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFFDFBF7),
        prefixIcon: const Icon(Icons.star_border, color: Color(0xFF5A6B7C)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      items: const [
        DropdownMenuItem<double?>(value: null, child: Text('All Ratings')),
        DropdownMenuItem<double?>(value: 5.0, child: Text('⭐ 5.0+')),
        DropdownMenuItem<double?>(value: 6.0, child: Text('⭐ 6.0+')),
        DropdownMenuItem<double?>(value: 7.0, child: Text('⭐ 7.0+')),
        DropdownMenuItem<double?>(value: 8.0, child: Text('⭐ 8.0+')),
        DropdownMenuItem<double?>(value: 9.0, child: Text('⭐ 9.0+')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedRating = value;
        });
      },
    );
  }

  Widget _buildMovieCard(Movie movie) {
    final isFavorite = _favoritesService.isFavorite(movie.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBE1),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MovieDetailScreen(
                movie: movie,
                favoritesService: _favoritesService,
              ),
            ),
          );

          setState(() {});
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              height: 165,
              child: movie.posterUrl.isEmpty
                  ? const Icon(Icons.movie, size: 50, color: Color(0xFF5A6B7C))
                  : Image.network(
                      movie.posterUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Color(0xFF5A6B7C),
                        );
                      },
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            movie.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF1E4663),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: isFavorite
                              ? 'Remove from Favorites'
                              : 'Add to Favorites',
                          onPressed: () {
                            _toggleFavorite(movie);
                          },
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? Colors.red
                                : const Color(0xFF5A6B7C),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${movie.year} • ⭐ ${movie.rating.toStringAsFixed(1)}',
                      style: const TextStyle(
                        color: Color(0xFF5A6B7C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (movie.genreIds.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: movie.genreIds
                            .where(_genreMap.containsKey)
                            .take(3)
                            .map(
                              (genreId) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5A6B7C)
                                      .withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _genreMap[genreId]!,
                                  style: const TextStyle(
                                    color: Color(0xFF5A6B7C),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      movie.overview.isEmpty
                          ? 'No overview available.'
                          : movie.overview,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF5A6B7C),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tap for details →',
                      style: TextStyle(
                        color: Color(0xFFFF521B),
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
  }

  Widget _buildError(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF0EBE1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFFFF521B),
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to load movies.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1E4663),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF5A6B7C)),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF521B),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBE1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off, size: 60, color: Color(0xFF5A6B7C)),
          SizedBox(height: 12),
          Text(
            'No movies match your filters.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF1E4663), fontSize: 16),
          ),
        ],
      ),
    );
  }
}
