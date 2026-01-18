// lib/widgets/ai_features_sheet.dart
import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class AIFeaturesSheet extends StatefulWidget {
  final String title;
  final String content;
  final Function(String)? onSummaryGenerated;
  final Function(List<String>)? onTagsSuggested;
  final Function(String)? onTitleSuggested;

  const AIFeaturesSheet({
    Key? key,
    required this.title,
    required this.content,
    this.onSummaryGenerated,
    this.onTagsSuggested,
    this.onTitleSuggested,
  }) : super(key: key);

  @override
  State<AIFeaturesSheet> createState() => _AIFeaturesSheetState();
}

class _AIFeaturesSheetState extends State<AIFeaturesSheet> {
  bool _isLoading = false;
  String? _summary;
  List<String>? _suggestedTags;
  String? _sentiment;
  List<String>? _keyPoints;
  String? _suggestedTitle;
  String? _activeFeature;

  Future<void> _generateSummary() async {
    setState(() {
      _isLoading = true;
      _activeFeature = 'summary';
    });

    try {
      final summary = await AIService.generateSummary(widget.content);
      setState(() {
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _suggestTags() async {
    setState(() {
      _isLoading = true;
      _activeFeature = 'tags';
    });

    try {
      final tags = await AIService.suggestTags(widget.title, widget.content);
      setState(() {
        _suggestedTags = tags;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _analyzeSentiment() async {
    setState(() {
      _isLoading = true;
      _activeFeature = 'sentiment';
    });

    try {
      final sentiment = await AIService.analyzeSentiment(widget.content);
      setState(() {
        _sentiment = sentiment;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _extractKeyPoints() async {
    setState(() {
      _isLoading = true;
      _activeFeature = 'keypoints';
    });

    try {
      final points = await AIService.extractKeyPoints(widget.content);
      setState(() {
        _keyPoints = points;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _suggestTitle() async {
    setState(() {
      _isLoading = true;
      _activeFeature = 'title';
    });

    try {
      final title = await AIService.suggestTitle(widget.content);
      setState(() {
        _suggestedTitle = title;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _getSentimentEmoji(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return '😊';
      case 'negative':
        return '😔';
      default:
        return '😐';
    }
  }

  Color _getSentimentColor(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return Colors.green;
      case 'negative':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFC39E18).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFFC39E18),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI Features',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // AI Feature Buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFeatureButton(
                  icon: Icons.summarize,
                  label: 'Summary',
                  onTap: _generateSummary,
                  isActive: _activeFeature == 'summary',
                ),
                const SizedBox(width: 10),
                _buildFeatureButton(
                  icon: Icons.tag,
                  label: 'Tags',
                  onTap: _suggestTags,
                  isActive: _activeFeature == 'tags',
                ),
                const SizedBox(width: 10),
                _buildFeatureButton(
                  icon: Icons.mood,
                  label: 'Sentiment',
                  onTap: _analyzeSentiment,
                  isActive: _activeFeature == 'sentiment',
                ),
                const SizedBox(width: 10),
                _buildFeatureButton(
                  icon: Icons.format_list_bulleted,
                  label: 'Key Points',
                  onTap: _extractKeyPoints,
                  isActive: _activeFeature == 'keypoints',
                ),
                const SizedBox(width: 10),
                _buildFeatureButton(
                  icon: Icons.title,
                  label: 'Title',
                  onTap: _suggestTitle,
                  isActive: _activeFeature == 'title',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Results Area
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFFC39E18),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'AI is thinking...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            _buildResultsArea(),
        ],
      ),
    );
  }

  Widget _buildFeatureButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFC39E18)
              : const Color(0xFFC39E18).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFC39E18),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : const Color(0xFFC39E18),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFFC39E18),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsArea() {
    if (_activeFeature == null) {
      return Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.touch_app, size: 40, color: Colors.grey),
              SizedBox(height: 10),
              Text(
                'Select a feature above to get started',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Result
          if (_activeFeature == 'summary' && _summary != null) ...[
            _buildResultHeader('Summary', Icons.summarize),
            const SizedBox(height: 10),
            Text(_summary!, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            _buildApplyButton('Use Summary', () {
              widget.onSummaryGenerated?.call(_summary!);
              Navigator.pop(context);
            }),
          ],

          // Tags Result
          if (_activeFeature == 'tags' && _suggestedTags != null) ...[
            _buildResultHeader('Suggested Tags', Icons.tag),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestedTags!.map((tag) {
                return Chip(
                  label: Text('#$tag'),
                  backgroundColor: const Color(0xFFC39E18).withOpacity(0.1),
                  labelStyle: const TextStyle(color: Color(0xFFC39E18)),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            _buildApplyButton('Apply Tags', () {
              widget.onTagsSuggested?.call(_suggestedTags!);
              Navigator.pop(context);
            }),
          ],

          // Sentiment Result
          if (_activeFeature == 'sentiment' && _sentiment != null) ...[
            _buildResultHeader('Sentiment Analysis', Icons.mood),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  _getSentimentEmoji(_sentiment!),
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _sentiment!.toUpperCase(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getSentimentColor(_sentiment!),
                      ),
                    ),
                    Text(
                      'Based on the content of your note',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],

          // Key Points Result
          if (_activeFeature == 'keypoints' && _keyPoints != null) ...[
            _buildResultHeader('Key Points', Icons.format_list_bulleted),
            const SizedBox(height: 10),
            if (_keyPoints!.isEmpty)
              const Text(
                'No key points found. Try adding bullet points or numbered lists to your note.',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...(_keyPoints!.map((point) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle,
                            color: Color(0xFFC39E18), size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(point)),
                      ],
                    ),
                  ))),
          ],

          // Title Result
          if (_activeFeature == 'title' && _suggestedTitle != null) ...[
            _buildResultHeader('Suggested Title', Icons.title),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFC39E18)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _suggestedTitle!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildApplyButton('Use This Title', () {
              widget.onTitleSuggested?.call(_suggestedTitle!);
              Navigator.pop(context);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildResultHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFC39E18)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildApplyButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.check, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC39E18),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
