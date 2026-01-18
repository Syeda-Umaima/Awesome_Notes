// lib/models/note_model.dart
import 'package:hive/hive.dart';

part 'note_model.g.dart';

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

  @HiveField(8)
  String? userId;

  NoteModel({
    this.title,
    this.description,
    this.imagePath,
    this.voiceText,
    this.dateCreated,
    this.dateModified,
    this.contentJson,
    this.tags,
    this.userId,
  });
}