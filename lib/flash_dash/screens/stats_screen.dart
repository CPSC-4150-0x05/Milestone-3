import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<int> scores = [];

  @override
  void initState() {
    super.initState();
    loadScores();
  }

  Future<void> loadScores() async {
    scores = await StorageService.loadScores();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    int games = scores.length;

    int best = games == 0
        ? 0
        : scores.reduce((a, b) => a > b ? a : b);

    double average = games == 0
        ? 0
        : scores.reduce((a, b) => a + b) / games;

    int totalPoints = scores.fold(0, (sum, score) => sum + score);

    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text("⭐ Statistics ⭐"),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            buildCard(
              icon: Icons.sports_esports,
              title: "Games Played",
              value: "$games",
              color: Colors.blue,
            ),

            const SizedBox(height: 18),

            buildCard(
              icon: Icons.emoji_events,
              title: "Best Score",
              value: "$best / 10",
              color: Colors.green,
            ),

            const SizedBox(height: 18),

            buildCard(
              icon: Icons.trending_up,
              title: "Average Score",
              value: "${average.toStringAsFixed(1)} / 10",
              color: Colors.purple,
            ),

            const SizedBox(height: 18),

            buildCard(
              icon: Icons.star,
              title: "Total Points",
              value: "$totalPoints",
              color: Colors.orange,
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.home),
                label: const Text(
                  "HOME",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color,
              child: Icon(
                icon,
                color: Colors.white,
                size: 30,
              ),
            ),

            const SizedBox(width: 20),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}