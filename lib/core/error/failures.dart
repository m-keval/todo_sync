import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final List<dynamic> properties;
  const Failure([this.properties = const <dynamic>[]]);

  @override
  List<dynamic> get props => properties;
}

class ServerFailure extends Failure {
  final String? message;
  const ServerFailure([this.message]);
}

class CacheFailure extends Failure {
  final String? message;
  const CacheFailure([this.message]);
}

class NetworkFailure extends Failure {}
