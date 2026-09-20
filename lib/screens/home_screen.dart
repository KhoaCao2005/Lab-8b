import 'package:flutter/material.dart';

import 'currency_screen.dart';
import 'movie_screen.dart';
import 'weather_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color _backgroundTop = Color(0xFF425363);
  static const Color _backgroundBottom = Color(0xFF26323D);
  static const Color _panelTop = Color(0xFF5A6B7C);
  static const Color _panelBottom = Color(0xFF323B44);
  static const Color _lightCard = Color(0xFFF0EBE1);
  static const Color _accent = Color(0xFFFF521B);
  static const Color _textDark = Color(0xFF1E4663);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_backgroundTop, _backgroundBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 28),
                _buildIntroPanel(),
                const SizedBox(height: 24),
                const Text(
                  'Explore',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  context: context,
                  icon: Icons.cloud_outlined,
                  title: 'Weather Companion',
                  description: 'Check current weather conditions and get practical recommendations.',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WeatherScreen()),
                    );
                  },
                ),
                const SizedBox(height: 14),
                _buildFeatureCard(
                  context: context,
                  icon: Icons.movie_outlined,
                  title: 'Movie & TV Explorer',
                  description: 'Discover trending movies and explore ratings, posters and descriptions.',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MovieScreen()),
                    );
                  },
                ),
                const SizedBox(height: 14),
                _buildFeatureCard(
                  context: context,
                  icon: Icons.currency_exchange,
                  title: 'Currency Rate Helper',
                  description: 'Convert currencies and compare exchange rates for travel or shopping.',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CurrencyScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.explore, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Lab 8B Explorer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntroPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [_panelTop, _panelBottom],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Practical REST API Apps',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Explore useful applications powered by real-world REST APIs.',
            style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: _lightCard,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFF5A6B7C),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Color(0xFF5A6B7C)),
            ],
          ),
        ),
      ),
    );
  }
}
