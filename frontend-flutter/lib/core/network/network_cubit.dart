// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'network_info.dart';

class NetworkState extends Equatable {
  final NetworkType type;
  const NetworkState(this.type);

  @override
  List<Object> get props => [type.index];
}

class NetworkCubit extends Cubit<NetworkState> {
  final NetworkInfo networkInfo;
  StreamSubscription<NetworkType>? _subscription;

  NetworkCubit(this.networkInfo) : super(NetworkState(NetworkType.offline)) {
    _init();
  }

  void _init() async {
    final type = await networkInfo.getCurrentNetworkType();
    emit(NetworkState(type));
    _subscription = networkInfo.onNetworkChanged.listen((type) {
      emit(NetworkState(type));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
