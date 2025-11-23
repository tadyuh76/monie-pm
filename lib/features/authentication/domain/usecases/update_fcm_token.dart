import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:monie/core/errors/failures.dart';
import 'package:monie/features/authentication/domain/repositories/auth_repository.dart';

class UpdateFcmToken {
  final AuthRepository repository;

  UpdateFcmToken(this.repository);

  Future<Either<Failure, void>> call(UpdateFcmTokenParams params) async {
    return await repository.updateFcmToken(token: params.token);
  }
}

class UpdateFcmTokenParams extends Equatable {
  final String token;

  const UpdateFcmTokenParams({required this.token});

  @override
  List<Object> get props => [token];
}




