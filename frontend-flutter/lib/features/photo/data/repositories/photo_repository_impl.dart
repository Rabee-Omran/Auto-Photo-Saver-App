import 'package:dartz/dartz.dart';
import '../../../../core/constants/constants.dart';
import '../../domain/entities/photo.dart';
import '../../domain/repositories/photo_repository.dart';
import '../../../../core/error/failure.dart';
import '../datasources/photo_remote_data_source.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  final PhotoRemoteDataSource remoteDataSource;
  PhotoRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Photo>> getLatestPhoto() async {
    try {
      final model = await remoteDataSource.getLatestPhoto();
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(Constants.serverErrorMessage));
    }
  }
}
