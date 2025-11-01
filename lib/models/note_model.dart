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
  DateTime createdAt;

  NoteModel({
    this.title,
    this.description,
    this.imagePath,
    this.voiceText,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
