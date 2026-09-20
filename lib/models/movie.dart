class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double rating;
  final String releaseDate;
  final String mediaType;
  final List<int> genreIds;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.rating,
    required this.releaseDate,
    required this.mediaType,
    required this.genreIds,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? 'Unknown',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      rating: (json['vote_average'] ?? 0).toDouble(),
      releaseDate: json['release_date'] ?? json['first_air_date'] ?? '',
      mediaType: json['media_type'] ?? 'movie',

      // TMDB trả về genre_ids cho trending/list endpoint
      genreIds: List<int>.from(json['genre_ids'] ?? []),
    );
  }

  String get posterUrl {
    if (posterPath.isEmpty) {
      return '';
    }

    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  String get backdropUrl {
    if (backdropPath.isEmpty) {
      return '';
    }

    return 'https://image.tmdb.org/t/p/w1280$backdropPath';
  }

  String get year {
    if (releaseDate.isEmpty) {
      return 'N/A';
    }

    return releaseDate.substring(0, 4);
  }
}
