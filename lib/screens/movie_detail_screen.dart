import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/favorites_service.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  final FavoritesService favoritesService;

  const MovieDetailScreen({
    super.key,
    required this.movie,
    required this.favoritesService,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool get isFavorite {
    return widget.favoritesService.isFavorite(widget.movie.id);
  }

  void _toggleFavorite() {
    setState(() {
      widget.favoritesService.toggleFavorite(widget.movie);
    });
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(movie),
                if (movie.backdropUrl.isNotEmpty) _buildBackdrop(movie),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildMovieInformation(movie),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(Movie movie) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            tooltip: isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
            onPressed: _toggleFavorite,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.redAccent : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackdrop(Movie movie) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 230,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22)),
      child: Image.network(
        movie.backdropUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5A6B7C), Color(0xFF323B44)],
              ),
            ),
            child: const Center(
              child: Icon(Icons.broken_image, size: 60, color: Colors.white70),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMovieInformation(Movie movie) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBE1),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  movie.title,
                  style: const TextStyle(
                    color: Color(0xFF1E4663),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                tooltip: isFavorite
                    ? 'Remove from Favorites'
                    : 'Add to Favorites',
                onPressed: _toggleFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 32,
                  color: isFavorite ? Colors.red : const Color(0xFF5A6B7C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF5A6B7C).withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFFF521B)),
                const SizedBox(width: 6),
                Text(
                  movie.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Color(0xFF1E4663),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 20),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: Color(0xFF5A6B7C),
                ),
                const SizedBox(width: 6),
                Text(
                  movie.year,
                  style: const TextStyle(
                    color: Color(0xFF5A6B7C),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const Text(
            'Overview',
            style: TextStyle(
              color: Color(0xFF1E4663),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.overview.isEmpty ? 'No overview available.' : movie.overview,
            style: const TextStyle(
              color: Color(0xFF5A6B7C),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 26),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF5A6B7C).withOpacity(0.10),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, color: Color(0xFF5A6B7C)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tip: Check the rating and overview to decide whether this movie matches your interests.',
                    style: TextStyle(color: Color(0xFF5A6B7C), height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              isFavorite ? '❤️ Added to Favorites' : '♡ Not in Favorites',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isFavorite ? Colors.red : const Color(0xFF5A6B7C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
