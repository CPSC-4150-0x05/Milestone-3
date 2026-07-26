import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String scoresKey = "scores";

  static Future<void> saveScore(int score) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> scores = prefs.getStringList(scoresKey) ?? [];

    scores.add(score.toString());

    await prefs.setStringList(scoresKey, scores);
  }

  static Future<List<int>> loadScores() async {
    final prefs = await SharedPreferences.getInstance();

    final scores = prefs.getStringList(scoresKey) ?? [];

    return scores.map(int.parse).toList();
  }
}