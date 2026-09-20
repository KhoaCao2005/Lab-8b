import 'package:flutter/material.dart';

import 'currency_screen.dart';
import 'movie_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab 8B Explorer'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),
          const Icon(Icons.explore, size: 80),
          const SizedBox(height: 20),
          const Text(
            'Practical REST API Apps',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Choose an API-powered tool below.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 40),
          _buildFeatureCard(
            context: context,
            icon: Icons.movie_outlined,
            title: 'Movie & TV Explorer',
            description:
                'Discover trending movies and view '
                'ratings, posters, and descriptions.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MovieScreen()),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildFeatureCard(
            context: context,
            icon: Icons.currency_exchange,
            title: 'Currency Rate Helper',
            description:
                'Convert currencies and compare '
                'exchange rates for travel or shopping.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CurrencyScreen()),
              );
            },
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
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(radius: 30, child: Icon(icon, size: 30)),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(description),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
