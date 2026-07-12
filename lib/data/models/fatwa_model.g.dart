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
      pdfUrl: fields[2] as String,
      isAnswered: fields[3] as bool,
      localPdfPath: fields[4] as String?,
      localAudioPath: fields[6] as String?,
      textAnswer: fields[7] as String?,
      date: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FatwaModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.questionSnippet)
      ..writeByte(2)
      ..write(obj.pdfUrl)
      ..writeByte(3)
      ..write(obj.isAnswered)
      ..writeByte(4)
      ..write(obj.localPdfPath)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.localAudioPath)
      ..writeByte(7)
      ..write(obj.textAnswer);
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
