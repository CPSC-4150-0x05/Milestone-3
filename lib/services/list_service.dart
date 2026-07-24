// Will read information about the list from seed_words.csv
// Also allows changes to be saved directly to csv file
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_3_f25_project/models/wordlist.dart';
import 'package:team_3_f25_project/utils/file_io_stub.dart'
    if (dart.library.io) 'package:team_3_f25_project/utils/file_io.dart';

class WordService {
  static const _assetPath = 'lib/data/seed_words.csv';
  static const _prefsKey = 'seed_words_csv';
  static String? _csvPath;

  static Future<String> _getCSVContent() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_prefsKey);
      if (cached != null) return cached;

      final data = await rootBundle.loadString(_assetPath);
      await prefs.setString(_prefsKey, data);
      return data;
    }

    final path = await _getCSVPath();
    return readFileAsString(path);
  }

  static Future<void> _saveCSVContent(String content) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, content);
      return;
    }

    final path = await _getCSVPath();
    await writeFileAsString(path, content);
  }

  static Future<String> _getCSVPath() async {
    if (_csvPath != null) return _csvPath!;

    final path = await ensureWritableCsvPath(_assetPath);
    _csvPath = path;
    return _csvPath!;
  }

  static Future<List<WordList>> loadWords() async {
    final csvData = await _getCSVContent();
    final lines = const LineSplitter().convert(csvData);
    final List<WordList> words = [];

    for (int i = 1; i < lines.length; i++) {
      final row = lines[i].split(',');
      if (row.length >= 7) {
        words.add(WordList.fromCSV(row));
      }
    }

    return words;
  }

  static Future<List<WordList>> getWords(int listId) async {
    final allWords = await loadWords();
    return allWords.where((w) => w.listId == listId).toList();
  }

  static Future<List<int>> getListIds() async {
    final allWords = await loadWords();
    return allWords.map((w) => w.listId).toSet().toList();
  }

  static Future<String> getCategory(int listId) async {
    final allWords = await loadWords();
    return allWords.firstWhere((w) => w.listId == listId).category;
  }

  static Future<void> addListOfWords(
    List<WordWithSentences> wordsWithSentences,
    String listCategory,
  ) async {
    final allWords = await loadWords();
    final List<int> listIds = await getListIds();
    listIds.sort();
    int nextListId = listIds.last + 1;
    int nextWordId = allWords.length + 1;

    final header =
        'id,list_id,priority,category,word,sentence1,sentence2,sentence3';
    final csvLines = [header];
    for (var w in allWords) {
      csvLines.add(
        '${w.id},${w.listId},${w.priority},${w.category},${w.word},${w.sentence1},${w.sentence2},${w.sentence3}',
      );
    }

    int highest = await getHighestPriority();
    int newPriority = highest + 1;

    for (var w in wordsWithSentences) {
      csvLines.add(
        '$nextWordId,$nextListId,$newPriority,$listCategory,${w.word},${w.sentence1},${w.sentence2},${w.sentence3}',
      );
      nextWordId++;
    }
    await _saveCSVContent(csvLines.join('\n'));
  }

  static Future<void> updateListPriority(int listId, int newPriority) async {
    final allWords = await loadWords();
    for (var word in allWords) {
      if (word.listId == listId) {
        word.priority = newPriority;
      }
    }

    final header =
        'id,list_id,priority,category,word,sentence1,sentence2,sentence3';
    final csvLines = [header];
    for (var w in allWords) {
      csvLines.add(
        '${w.id},${w.listId},${w.priority},${w.category},${w.word},${w.sentence1},${w.sentence2},${w.sentence3}',
      );
    }

    await _saveCSVContent(csvLines.join('\n'));
  }

  static Future<int> getTopPriority() async {
    final allWords = await loadWords();

    final Map<int, int> listPriorities = {};
    for (var w in allWords) {
      listPriorities[w.listId] = w.priority;
    }

    int? topListId;
    int minPriority = 100;
    listPriorities.forEach((listId, priority) {
      if (priority < minPriority) {
        minPriority = priority;
        topListId = listId;
      }
    });
    return topListId!;
  }

  static Future<int?> getNextListID(int currentListID) async {
    final allwords = await loadWords();

    final Map<int, int> listPriorities = {};
    for (var w in allwords) {
      listPriorities[w.listId] = w.priority;
    }

    if (!listPriorities.containsKey(currentListID)) return null;

    final currentPriority = listPriorities[currentListID]!;

    int? nextListID;
    int? nextPriority;

    listPriorities.forEach((id, priority) {
      if (priority > currentPriority &&
          (nextPriority == null || priority < nextPriority!)) {
        nextPriority = priority;
        nextListID = id;
      }
    });

    return nextListID;
  }

  static Future<int> getHighestPriority() async {
    final allWords = await loadWords();

    int highest = 0;
    for (var w in allWords) {
      if (w.priority > highest) highest = w.priority;
    }
    return highest;
  }

  static Future<List<WordWithSentences>?> importCSV() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: kIsWeb,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final pickedFile = result.files.single;
      final String raw;
      if (pickedFile.bytes != null) {
        raw = utf8.decode(pickedFile.bytes!);
      } else if (pickedFile.path != null) {
        raw = await readFileAsString(pickedFile.path!);
      } else {
        return null;
      }

      final lines = const LineSplitter().convert(raw);
      if (lines.isEmpty) return [];

      int startIndex = 0;
      final header = lines.first.toLowerCase();
      if (header.contains("word") && header.contains("sentence")) {
        startIndex = 1;
      }

      List<WordWithSentences> imported = [];

      for (int i = startIndex; i < lines.length; i++) {
        final row = lines[i].split(",");

        if (row.length < 4) continue;

        imported.add(
          WordWithSentences(
            word: row[0].trim(),
            sentence1: row[1].trim(),
            sentence2: row[2].trim(),
            sentence3: row[3].trim(),
          ),
        );
      }
      return imported;
    } catch (e) {
      debugPrint("CSV import error: $e");
      return null;
    }
  }
}
