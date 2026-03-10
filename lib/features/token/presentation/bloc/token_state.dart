part of 'token_bloc.dart';

@freezed
class TokenState with _$TokenState {
  const factory TokenState.initial() = Initial;
  const factory TokenState.loadingToken() = LoadingToken;
  const factory TokenState.tokenSuccess(String token) = TokenSuccess;
  const factory TokenState.errorToken(String message) = ErrorToken;
}
