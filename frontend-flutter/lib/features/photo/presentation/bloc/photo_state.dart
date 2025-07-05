part of 'photo_cubit.dart';

abstract class PhotoState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PhotoInitial extends PhotoState {}

class PhotoLoading extends PhotoState {}

class PhotoLoaded extends PhotoState {
  final Photo photo;
  PhotoLoaded(this.photo);
  @override
  List<Object?> get props => [photo];
}

class PhotoImageSaved extends PhotoState {}

class PhotoErrorState extends PhotoState {
  final String message;
  PhotoErrorState({required this.message});
  @override
  List<Object?> get props => [message];
}

class PhotoNoInternetState extends PhotoState {}
