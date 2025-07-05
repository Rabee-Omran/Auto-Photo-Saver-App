import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../features/photo/data/datasources/photo_remote_data_source.dart';
import '../features/photo/data/repositories/photo_repository_impl.dart';
import '../features/photo/domain/repositories/photo_repository.dart';
import '../features/photo/domain/usecases/get_latest_photo.dart';
import '../features/photo/presentation/bloc/photo_cubit.dart';
import '../core/network/network_info.dart';
import '../core/network/network_cubit.dart';
import '../core/services/shared_prefs_service.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // Core
  sl.registerLazySingleton<Dio>(() => Dio());
  final sharedPrefsService = SharedPrefsService();
  await sharedPrefsService.init();
  SharedPrefsService.setInstance(sharedPrefsService);
  sl.registerSingleton<SharedPrefsService>(sharedPrefsService);

  // Photo Feature
  sl.registerLazySingleton<PhotoRemoteDataSource>(
    () => PhotoRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<PhotoRepository>(() => PhotoRepositoryImpl(sl()));
  sl.registerLazySingleton<GetLatestPhoto>(() => GetLatestPhoto(sl()));
  sl.registerFactory<PhotoCubit>(() => PhotoCubit(sl(), sl()));

  // Network Feature
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfo());
  sl.registerFactory<NetworkCubit>(() => NetworkCubit(sl()));
}
