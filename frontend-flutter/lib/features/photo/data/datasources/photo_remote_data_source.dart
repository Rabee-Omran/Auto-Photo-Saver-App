import 'package:auto_photo_saver_app/core/constants/constants.dart';
import 'package:dio/dio.dart';
import '../models/photo_model.dart';

abstract class PhotoRemoteDataSource {
  Future<PhotoModel> getLatestPhoto();
}

class PhotoRemoteDataSourceImpl implements PhotoRemoteDataSource {
  final Dio dio;
  PhotoRemoteDataSourceImpl(this.dio);

  @override
  Future<PhotoModel> getLatestPhoto() async {
    final response = await dio.get(
      '${Constants.baseUrl}/api/photo/',
    );
    if (response.statusCode == 200) {
      return PhotoModel.fromJson(response.data);
    } else {
      throw Exception('Failed to load photo');
    }
  }
}
