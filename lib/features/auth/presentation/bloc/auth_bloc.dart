import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../token/data/datasource/token_local_datasource.dart';
import '../../../token/data/models/response/validate_token_response_model.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_bloc.freezed.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final TokenLocalDatasource tokenLocalDatasource;
  AuthBloc(this.tokenLocalDatasource) : super(Initial()) {
    on<_Login>((event, emit) async {
      emit(LoadingAuth());

      final result = await tokenLocalDatasource.validateToken(event.token);
      result.fold((l) => emit(ErrorAuth(l)), (r) => emit(LoginSuccess(r)));
    });
  }
}
