import 'dart:async';

/// Provides AI-powered features for note analysis and suggestions.
/// Ready for integration with external AI APIs (Gemini, OpenAI, etc.)
class AIService {
  AIService._();

  /// Generates a summary of the note content
  static Future<String> generateSummary(String content) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    if (content.trim().isEmpty) {
      return 'No content to summarize.';
    }

    // Extract first few sentences as summary
    final sentences = content
        .replaceAll(RegExp(r'\n+'), ' ')
        .split(RegExp(r'[.!?]+'))
        .where((s) => s.trim().isNotEmpty)
        .take(3)
        .map((s) => s.trim())
        .toList();

    if (sentences.isEmpty) {
      return 'Brief note with key points.';
    }

    String summary = sentences.join('. ');
    if (summary.length > 200) {
      summary = '${summary.substring(0, 197)}...';
    }

    return summary.endsWith('.') ? summary : '$summary.';
  }

  /// Suggests relevant tags based on note title and content
  static Future<List<String>> suggestTags(String title, String content) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    final combinedText = '$title $content'.toLowerCase();
    final suggestedTags = <String>[];

    final tagKeywords = {
      'work': ['meeting', 'project', 'deadline', 'task', 'office', 'client', 'report'],
      'personal': ['family', 'friend', 'birthday', 'vacation', 'hobby', 'health'],
      'study': ['exam', 'lecture', 'homework', 'assignment', 'course', 'class', 'learn'],
      'ideas': ['idea', 'thought', 'concept', 'brainstorm', 'innovation', 'creative'],
      'shopping': ['buy', 'shop', 'grocery', 'list', 'purchase', 'store', 'order'],
      'finance': ['money', 'budget', 'expense', 'payment', 'bill', 'salary', 'invest'],
      'travel': ['trip', 'flight', 'hotel', 'booking', 'destination', 'vacation'],
      'health': ['doctor', 'medicine', 'exercise', 'diet', 'gym', 'wellness'],
      'important': ['urgent', 'important', 'priority', 'critical', 'asap', 'deadline'],
      'meeting': ['meeting', 'call', 'conference', 'discussion', 'agenda'],
    };

    for (final entry in tagKeywords.entries) {
      for (final keyword in entry.value) {
        if (combinedText.contains(keyword)) {
          suggestedTags.add(entry.key);
          break;
        }
      }
    }

    // Fallback tags if no matches found
    if (suggestedTags.isEmpty) {
      if (combinedText.length > 500) {
        suggestedTags.add('detailed');
      }
      if (combinedText.contains('?')) {
        suggestedTags.add('question');
      }
      suggestedTags.add('note');
    }

    return suggestedTags.take(5).toList();
  }

  /// Analyzes note sentiment (positive, negative, neutral)
  static Future<String> analyzeSentiment(String content) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (content.trim().isEmpty) return 'neutral';

    final text = content.toLowerCase();

    final positiveWords = ['happy', 'great', 'excellent', 'good', 'amazing', 'wonderful',
                          'love', 'success', 'achieved', 'completed', 'excited'];
    final negativeWords = ['sad', 'bad', 'terrible', 'awful', 'hate', 'failed',
                          'problem', 'issue', 'worried', 'stressed', 'angry'];

    int positiveCount = 0;
    int negativeCount = 0;

    for (final word in positiveWords) {
      if (text.contains(word)) positiveCount++;
    }
    for (final word in negativeWords) {
      if (text.contains(word)) negativeCount++;
    }

    if (positiveCount > negativeCount) return 'positive';
    if (negativeCount > positiveCount) return 'negative';
    return 'neutral';
  }

  /// Extracts key points from note content
  static Future<List<String>> extractKeyPoints(String content) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (content.trim().isEmpty) return [];

    final lines = content.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final keyPoints = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      // Look for bullet points, numbered items, or short headers
      if (trimmed.startsWith('-') ||
          trimmed.startsWith('•') ||
          trimmed.startsWith('*') ||
          RegExp(r'^\d+[.)]\s').hasMatch(trimmed)) {
        keyPoints.add(trimmed.replaceFirst(RegExp(r'^[-•*\d.)\s]+'), ''));
      } else if (trimmed.length < 100 && trimmed.endsWith(':')) {
        keyPoints.add(trimmed);
      }
    }

    return keyPoints.take(5).toList();
  }

  /// Suggests a title based on note content
  static Future<String?> suggestTitle(String content) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (content.trim().isEmpty) return null;

    final lines = content.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return null;

    String firstLine = lines.first.trim();

    if (firstLine.length <= 50) {
      return firstLine.replaceAll(RegExp(r'[.!?]+$'), '');
    }

    final words = firstLine.split(' ').take(6).join(' ');
    return '$words...';
  }
}

/// Checks availability of AI features
class AIFeatureChecker {
  static bool get isSummarizationAvailable => true;
  static bool get isTagSuggestionAvailable => true;
  static bool get isSentimentAnalysisAvailable => true;

  static Future<bool> checkAPIConnection() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }
}
