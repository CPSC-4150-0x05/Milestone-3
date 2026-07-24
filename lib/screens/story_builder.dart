import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:team_3_f25_project/services/list_service.dart';
import 'package:team_3_f25_project/services/user_db.dart';

class StoryBuilderScreen extends StatefulWidget {
  const StoryBuilderScreen({super.key});

  @override
  State<StoryBuilderScreen> createState() => _StoryBuilderScreenState();
}

class _StoryBuilderScreenState extends State<StoryBuilderScreen> {
  final TextEditingController _topicController = TextEditingController();

  bool _loadingPage = true;
  bool _generatingStory = false;

  String? _errorMessage;
  String? _story;
  String? _gradeLevel;

  int? _userId;
  int? _currentListId;

  List<String> _dolchWords = [];

  @override
  void initState() {
    super.initState();
    _loadStudentWordList();
  }

  Future<void> _loadStudentWordList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        throw Exception('No logged-in student was found.');
      }

      final currentListId =
          await DatabaseHelper.instance.getUserListId(userId);

      if (currentListId == null) {
        throw Exception(
          'No Dolch word list has been assigned to this student.',
        );
      }

      final words = await WordService.getWords(currentListId);
      final category = await WordService.getCategory(currentListId);

      if (words.isEmpty) {
        throw Exception('The assigned Dolch word list is empty.');
      }

      if (!mounted) return;

      setState(() {
        _userId = userId;
        _currentListId = currentListId;
        _gradeLevel = category;
        _dolchWords = words.map((word) => word.word).toList();
        _loadingPage = false;
        _errorMessage = null;
      });
    } catch (e, stackTrace) {
      debugPrint('Story Builder load error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _loadingPage = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _generateStory() async {
    final topic = _topicController.text.trim();

    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a topic for the story.'),
        ),
      );
      return;
    }

    if (_userId == null ||
        _currentListId == null ||
        _gradeLevel == null ||
        _dolchWords.isEmpty) {
      setState(() {
        _errorMessage =
            'The student word list is not ready. Please reload the page.';
      });
      return;
    }

    setState(() {
      _generatingStory = true;
      _errorMessage = null;
      _story = null;
    });

    try {
      final response =
          await Supabase.instance.client.functions.invoke(
        'generate-story',
        body: {
          'gradeLevel': _gradeLevel,
          'topic': topic,
          'dolchWords': _dolchWords,
        },
      );

      debugPrint("Raw response: ${response.data}");
      debugPrint("Response type: ${response.data.runtimeType}");

      final data = response.data;

      if (data is! Map) {
        throw Exception('The server returned an invalid response.');
      }

      final error = data['error'];

      if (error != null) {
        throw Exception(error.toString());
      }

      final generatedStory = data['story']?.toString().trim();

      if (generatedStory == null || generatedStory.isEmpty) {
        throw Exception('No story was returned by the server.');
      }

      if (!mounted) return;

      setState(() {
        _story = generatedStory;
        _generatingStory = false;
      });
    } on FunctionException catch (e, stackTrace) {
      debugPrint('Edge Function error: ${e.details}');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _generatingStory = false;
        _errorMessage =
            'The story service returned an error: ${e.details ?? e.reasonPhrase}';
      });
    } catch (e, stackTrace) {
      debugPrint('Story generation error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _generatingStory = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Widget _buildLoadingPage() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorCard() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 56,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Something went wrong.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _loadStudentWordList,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoryCard() {
    if (_story == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(top: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_stories),
                SizedBox(width: 8),
                Text(
                  'Your Story',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            SelectableText(
              _story!,
              style: const TextStyle(
                fontSize: 18,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 750),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.menu_book_rounded,
                size: 72,
                color: Colors.indigo,
              ),
              const SizedBox(height: 12),
              const Text(
                'AI Story Builder',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Reading level: ${_gradeLevel ?? 'Unknown'}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${_dolchWords.length} Dolch words will be included',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _topicController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (!_generatingStory) {
                    _generateStory();
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Story topic',
                  hintText: 'Fishing, dinosaurs, space, dogs...',
                  prefixIcon: Icon(Icons.lightbulb_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed:
                    _generatingStory ? null : _generateStory,
                icon: _generatingStory
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    _generatingStory
                        ? 'Generating Story...'
                        : 'Generate Story',
                    style: const TextStyle(fontSize: 17),
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 18),
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              _buildStoryCard(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text('Story Builder'),
      ),
      body: _loadingPage
          ? _buildLoadingPage()
          : (_errorMessage != null &&
                  _currentListId == null)
              ? _buildErrorCard()
              : _buildMainContent(),
    );
  }
}