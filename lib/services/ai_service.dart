// lib/services/ai_service.dart
// 
// AI-Powered Features for Awesome Notes
// This service provides AI-powered note summarization and smart tag suggestions
//
// For production, integrate with:
// - Google Gemini API
// - OpenAI API
// - Hugging Face Inference API
// - On-device ML with TensorFlow Lite

import 'dart:async';

class AIService {
  AIService._();

  /// Generates an AI summary of the note content
  /// In production, replace with actual API call to Gemini/OpenAI
  static Future<String> generateSummary(String content) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1500));

    if (content.trim().isEmpty) {
      return 'No content to summarize.';
    }

    // Simple extractive summary (first 2-3 sentences)
    // In production, use actual AI API
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

  /// Suggests tags based on note content
  /// In production, use NLP/ML for better suggestions
  static Future<List<String>> suggestTags(String title, String content) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1000));

    final combinedText = '$title $content'.toLowerCase();
    final suggestedTags = <String>[];

    // Keyword-based tag suggestions
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

    // Add generic tags if no specific matches
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

  /// Extracts key points from the note
  static Future<List<String>> extractKeyPoints(String content) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (content.trim().isEmpty) return [];

    // Simple extraction: look for bullet points, numbered items, or short sentences
    final lines = content.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final keyPoints = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      // Check if it looks like a key point
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

  /// Suggests a title based on content
  static Future<String?> suggestTitle(String content) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (content.trim().isEmpty) return null;

    // Get first line or first few words
    final lines = content.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return null;

    String firstLine = lines.first.trim();
    
    // If first line is short enough, use it as title
    if (firstLine.length <= 50) {
      return firstLine.replaceAll(RegExp(r'[.!?]+$'), '');
    }

    // Otherwise, take first few words
    final words = firstLine.split(' ').take(6).join(' ');
    return '$words...';
  }
}

/// AI Feature availability checker
class AIFeatureChecker {
  static bool get isSummarizationAvailable => true;
  static bool get isTagSuggestionAvailable => true;
  static bool get isSentimentAnalysisAvailable => true;
  
  // In production, check for API key availability
  static Future<bool> checkAPIConnection() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return true; // Return false if API is not configured
  }
}
