part of 'token_bloc.dart';

@freezed
class TokenEvent with _$TokenEvent {
  const factory TokenEvent.started() = _Started;
  const factory TokenEvent.generateToken(int activeDays) = _GenerateToken;
}
