import 'package:auto_photo_saver_app/core/constants/constants.dart';

import '../../domain/entities/photo.dart';

class PhotoModel {
  final int id;
  final String image;
  final String originalFileName;
  final int fileSize;
  final DateTime uploadedAt;

  PhotoModel({
    required this.id,
    required this.image,
    required this.originalFileName,
    required this.fileSize,
    required this.uploadedAt,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id'],
      image: Constants.mediaUrl + json['image'],
      originalFileName: json['original_file_name'],
      fileSize: json['file_size'],
      uploadedAt: DateTime.parse(json['uploaded_at']).toLocal(),
    );
  }

  Photo toEntity() => Photo(
    id: id,
    image: image,
    originalFileName: originalFileName,
    fileSize: fileSize,
    uploadedAt: uploadedAt,
  );
}
