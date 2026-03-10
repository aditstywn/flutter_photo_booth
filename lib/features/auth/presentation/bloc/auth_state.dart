part of 'auth_bloc.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = Initial;
  const factory AuthState.loadingAuth() = LoadingAuth;
  const factory AuthState.loginSuccess(ValidateTokenResponseModel response) =
      LoginSuccess;
  const factory AuthState.errorAuth(String message) = ErrorAuth;
}
