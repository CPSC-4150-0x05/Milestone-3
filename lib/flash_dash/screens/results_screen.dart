import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';

class ResultsScreen extends StatefulWidget {
  final int score;
  final int total;
  final int seconds;

  const ResultsScreen({
    super.key,
    required this.score,
    required this.total,
    required this.seconds,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  @override
  void initState() {
    super.initState();
    _saveScore();
  }

  Future<void> _saveScore() async {
    await StorageService.saveScore(widget.score);
  }

  String formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final percent = ((widget.score / widget.total) * 100).round();

    String message;

    if (percent >= 90) {
      message = 'Amazing!';
    } else if (percent >= 70) {
      message = 'Great job!';
    } else if (percent >= 50) {
      message = 'Nice work!';
    } else {
      message = 'Keep practicing!';
    }

    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text('⭐ Results ⭐'),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 58,
                  backgroundColor: Colors.orange,
                  child: Icon(
                    Icons.emoji_events,
                    size: 75,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'You finished the round!',
                  style: TextStyle(
                    fontSize: 19,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 30),

                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 28,
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'First-Try Score',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          '${widget.score} / ${widget.total}',
                          style: const TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          '$percent%',
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Divider(),

                        const SizedBox(height: 14),

                        const Text(
                          'Time',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          '⏱ ${formatTime(widget.seconds)}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                SizedBox(
                  width: double.infinity,
                  height: 65,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    icon: const Icon(
                      Icons.home,
                      size: 28,
                    ),
                    label: const Text(
                      'HOME',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}