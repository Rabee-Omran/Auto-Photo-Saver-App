import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/photo.dart';

abstract class PhotoRepository {
  Future<Either<Failure, Photo>> getLatestPhoto();
}
