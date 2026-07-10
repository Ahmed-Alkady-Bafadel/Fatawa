// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fatwa_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FatwaModelAdapter extends TypeAdapter<FatwaModel> {
  @override
  final int typeId = 0;

  @override
  FatwaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FatwaModel(
      title: fields[0] as String,
      questionSnippet: fields[1] as String,
      date: fields[2] as String,
      pdfUrl: fields[3] as String,
      isAnswered: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, FatwaModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.questionSnippet)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.pdfUrl)
      ..writeByte(4)
      ..write(obj.isAnswered);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FatwaModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
