import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '../data/dolch_words.dart';
import 'results_screen.dart';

class FlashDashScreen extends StatefulWidget {
  final String level;

  const FlashDashScreen({
    super.key,
    required this.level,
  });

  @override
  State<FlashDashScreen> createState() => _FlashDashScreenState();
}

class _FlashDashScreenState extends State<FlashDashScreen> {
  late List<String> words;

  int currentIndex = 0;
  int firstTryCorrect = 0;

  final Set<String> missedWords = {};

  late Timer timer;
  int secondsElapsed = 0;

  @override
  void initState() {
    super.initState();

    words = List.from(DolchWords.levels[widget.level]!);
    words.shuffle(Random());
    words = words.take(10).toList();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        secondsElapsed++;
      });
    });
  }

  void knowIt() {
    if (!missedWords.contains(words[currentIndex])) {
      firstTryCorrect++;
    }

    if (currentIndex == words.length - 1) {
      timer.cancel();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            score: firstTryCorrect,
            total: words.length,
            seconds: secondsElapsed,
          ),
        ),
      );
      return;
    }

    setState(() {
      currentIndex++;
    });
  }

  void practiceAgain() {
    setState(() {
      missedWords.add(words[currentIndex]);

      final word = words.removeAt(currentIndex);
      words.add(word);

      if (currentIndex >= words.length) {
        currentIndex = words.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text("⭐ Flash Dash ⭐"),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              "Level: ${widget.level}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "⏱ Time: ${secondsElapsed ~/ 60}:${(secondsElapsed % 60).toString().padLeft(2, '0')}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              "Word ${currentIndex + 1} of ${words.length}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            LinearProgressIndicator(
              value: (currentIndex + 1) / words.length,
              minHeight: 12,
              borderRadius: BorderRadius.circular(20),
            ),

            const SizedBox(height: 35),

            Expanded(
              child: Center(
                child: Dismissible(
                  key: ValueKey(words[currentIndex]),
                  direction: DismissDirection.horizontal,
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      knowIt();
                    } else {
                      practiceAgain();
                    }
                    return false;
                  },
                  background: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 25),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  secondaryBackground: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 25),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Container(
                      width: 320,
                      height: 220,
                      alignment: Alignment.center,
                      child: Text(
                        words[currentIndex],
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 65,
              child: ElevatedButton.icon(
                onPressed: knowIt,
                icon: const Icon(Icons.check),
                label: const Text(
                  "I KNOW IT",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 65,
              child: ElevatedButton.icon(
                onPressed: practiceAgain,
                icon: const Icon(Icons.refresh),
                label: const Text(
                  "PRACTICE AGAIN",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}