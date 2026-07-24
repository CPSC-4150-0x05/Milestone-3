import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

Future<String> ensureWritableCsvPath(String assetPath) async {
  final dir = await getApplicationDocumentsDirectory();
  final path = '${dir.path}/seed_words.csv';
  final file = File(path);

  if (!await file.exists()) {
    final data = await rootBundle.loadString(assetPath);
    await file.writeAsString(data);
  }

  return path;
}

Future<String> readFileAsString(String path) {
  return File(path).readAsString();
}

Future<void> writeFileAsString(String path, String content) {
  return File(path).writeAsString(content);
}
