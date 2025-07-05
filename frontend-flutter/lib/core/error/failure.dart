abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
}

class NoInternetConnectionFailure extends Failure {
  NoInternetConnectionFailure([super.message = 'No internet connection.']);
}
