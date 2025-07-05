import 'package:equatable/equatable.dart';

class Photo extends Equatable {
  final int id;
  final String image;
  final String originalFileName;
  final int fileSize;
  final DateTime uploadedAt;
  final DateTime? lastDownloadDate;

  const Photo({
    required this.id,
    required this.image,
    required this.originalFileName,
    required this.fileSize,
    required this.uploadedAt,
    this.lastDownloadDate,
  });

  Photo copyWith({
    int? id,
    String? image,
    String? originalFileName,
    int? fileSize,
    DateTime? uploadedAt,
    DateTime? lastDownloadDate,
  }) {
    return Photo(
      id: id ?? this.id,
      image: image ?? this.image,
      originalFileName: originalFileName ?? this.originalFileName,
      fileSize: fileSize ?? this.fileSize,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      lastDownloadDate: lastDownloadDate ?? this.lastDownloadDate,
    );
  }

  @override
  List<Object?> get props {
    return [id];
  }
}
