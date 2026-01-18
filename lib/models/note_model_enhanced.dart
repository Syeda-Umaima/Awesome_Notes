// lib/models/note_model_enhanced.dart
import 'package:hive/hive.dart';

part 'note_model_enhanced.g.dart';

@HiveType(typeId: 0)
class NoteModel extends HiveObject {
  @HiveField(0)
  String? title;

  @HiveField(1)
  String? description;

  @HiveField(2)
  String? imagePath;

  @HiveField(3)
  String? voiceText;

  @HiveField(4)
  int? dateCreated;

  @HiveField(5)
  int? dateModified;

  @HiveField(6)
  String? contentJson;

  @HiveField(7)
  List<String>? tags;

  // ========== NEW ENHANCED FIELDS ==========

  @HiveField(8)
  bool isPinned;

  @HiveField(9)
  bool isFavorite;

  @HiveField(10)
  bool isArchived;

  @HiveField(11)
  bool isDeleted;

  @HiveField(12)
  int? deletedAt;

  @HiveField(13)
  int? reminderDateTime;

  @HiveField(14)
  int noteColor; // Index of color in predefined list

  @HiveField(15)
  String? aiSummary;

  @HiveField(16)
  List<String>? aiSuggestedTags;

  NoteModel({
    this.title,
    this.description,
    this.imagePath,
    this.voiceText,
    this.dateCreated,
    this.dateModified,
    this.contentJson,
    this.tags,
    this.isPinned = false,
    this.isFavorite = false,
    this.isArchived = false,
    this.isDeleted = false,
    this.deletedAt,
    this.reminderDateTime,
    this.noteColor = 0,
    this.aiSummary,
    this.aiSuggestedTags,
  });

  // Helper to check if note has a reminder set
  bool get hasReminder =>
      reminderDateTime != null &&
      reminderDateTime! > DateTime.now().millisecondsSinceEpoch;

  // Helper to get reminder as DateTime
  DateTime? get reminderDate => reminderDateTime != null
      ? DateTime.fromMillisecondsSinceEpoch(reminderDateTime!)
      : null;

  // Copy with method for immutable updates
  NoteModel copyWith({
    String? title,
    String? description,
    String? imagePath,
    String? voiceText,
    int? dateCreated,
    int? dateModified,
    String? contentJson,
    List<String>? tags,
    bool? isPinned,
    bool? isFavorite,
    bool? isArchived,
    bool? isDeleted,
    int? deletedAt,
    int? reminderDateTime,
    int? noteColor,
    String? aiSummary,
    List<String>? aiSuggestedTags,
  }) {
    return NoteModel(
      title: title ?? this.title,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      voiceText: voiceText ?? this.voiceText,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? this.dateModified,
      contentJson: contentJson ?? this.contentJson,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
      noteColor: noteColor ?? this.noteColor,
      aiSummary: aiSummary ?? this.aiSummary,
      aiSuggestedTags: aiSuggestedTags ?? this.aiSuggestedTags,
    );
  }
}

// Predefined note colors
class NoteColors {
  static const List<int> colors = [
    0xFFFFFFFF, // White (default)
    0xFFFFF9C4, // Light Yellow
    0xFFFFCCBC, // Light Orange
    0xFFF8BBD9, // Light Pink
    0xFFE1BEE7, // Light Purple
    0xFFBBDEFB, // Light Blue
    0xFFB2DFDB, // Light Teal
    0xFFC8E6C9, // Light Green
    0xFFD7CCC8, // Light Brown
    0xFFCFD8DC, // Light Gray
  ];

  static int getColor(int index) {
    if (index < 0 || index >= colors.length) return colors[0];
    return colors[index];
  }
}
