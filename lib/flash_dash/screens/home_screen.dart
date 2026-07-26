import 'package:flutter/material.dart';
import 'flash_dash_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedLevel = "Pre-Primer";

  final List<String> levels = [
    "Pre-Primer",
    "Primer",
    "1st Grade",
    "2nd Grade",
    "3rd Grade",
  ];

  final List<IconData> levelIcons = [
    Icons.looks_one,
    Icons.looks_two,
    Icons.looks_3,
    Icons.looks_4,
    Icons.looks_5,
  ];

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(
                Icons.style,
                size: 75,
                color: Colors.orange,
              ),

              const SizedBox(height: 10),

              const Text(
                "Choose Your Level",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "Pick a word group and start playing!",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              Expanded(
                child: ListView.builder(
                  itemCount: levels.length,
                  itemBuilder: (context, index) {
                    final level = levels[index];
                    final isSelected = selectedLevel == level;

                    return Card(
                      elevation: isSelected ? 7 : 3,
                      margin: const EdgeInsets.symmetric(vertical: 7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.orange
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: RadioListTile<String>(
                        value: level,
                        groupValue: selectedLevel,
                        activeColor: Colors.orange,
                        secondary: CircleAvatar(
                          backgroundColor: isSelected
                              ? Colors.orange
                              : Colors.orange.shade100,
                          foregroundColor: isSelected
                              ? Colors.white
                              : Colors.orange.shade900,
                          child: Icon(levelIcons[index]),
                        ),
                        title: Text(
                          level,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onChanged: (value) {
                          if (value == null) return;

                          setState(() {
                            selectedLevel = value;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FlashDashScreen(
                          level: selectedLevel,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.play_arrow,
                    size: 34,
                  ),
                  label: const Text(
                    "PLAY",
                    style: TextStyle(
                      fontSize: 24,
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

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StatsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.bar_chart,
                    size: 30,
                  ),
                  label: const Text(
                    "STATISTICS",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}