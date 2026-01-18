part of 'note_model_enhanced.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteModelAdapter extends TypeAdapter<NoteModel> {
  @override
  final int typeId = 0;

  @override
  NoteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteModel(
      title: fields[0] as String?,
      description: fields[1] as String?,
      imagePath: fields[2] as String?,
      voiceText: fields[3] as String?,
      dateCreated: fields[4] as int?,
      dateModified: fields[5] as int?,
      contentJson: fields[6] as String?,
      tags: (fields[7] as List?)?.cast<String>(),
      isPinned: fields[8] as bool,
      isFavorite: fields[9] as bool,
      isArchived: fields[10] as bool,
      isDeleted: fields[11] as bool,
      deletedAt: fields[12] as int?,
      reminderDateTime: fields[13] as int?,
      noteColor: fields[14] as int,
      aiSummary: fields[15] as String?,
      aiSuggestedTags: (fields[16] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, NoteModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.imagePath)
      ..writeByte(3)
      ..write(obj.voiceText)
      ..writeByte(4)
      ..write(obj.dateCreated)
      ..writeByte(5)
      ..write(obj.dateModified)
      ..writeByte(6)
      ..write(obj.contentJson)
      ..writeByte(7)
      ..write(obj.tags)
      ..writeByte(8)
      ..write(obj.isPinned)
      ..writeByte(9)
      ..write(obj.isFavorite)
      ..writeByte(10)
      ..write(obj.isArchived)
      ..writeByte(11)
      ..write(obj.isDeleted)
      ..writeByte(12)
      ..write(obj.deletedAt)
      ..writeByte(13)
      ..write(obj.reminderDateTime)
      ..writeByte(14)
      ..write(obj.noteColor)
      ..writeByte(15)
      ..write(obj.aiSummary)
      ..writeByte(16)
      ..write(obj.aiSuggestedTags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
