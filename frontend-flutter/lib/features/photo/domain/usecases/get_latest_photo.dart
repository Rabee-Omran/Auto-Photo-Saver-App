import 'package:dartz/dartz.dart';
import '../entities/photo.dart';
import '../repositories/photo_repository.dart';
import '../../../../core/error/failure.dart';

class GetLatestPhoto {
  final PhotoRepository repository;
  GetLatestPhoto(this.repository);

  Future<Either<Failure, Photo>> call() {
    return repository.getLatestPhoto();
  }
}
