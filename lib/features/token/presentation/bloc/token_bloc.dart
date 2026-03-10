import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/datasource/token_local_datasource.dart';

part 'token_bloc.freezed.dart';
part 'token_event.dart';
part 'token_state.dart';

class TokenBloc extends Bloc<TokenEvent, TokenState> {
  final TokenLocalDatasource tokenLocalDatasource;
  TokenBloc(this.tokenLocalDatasource) : super(Initial()) {
    on<_GenerateToken>((event, emit) async {
      emit(LoadingToken());

      final result = await tokenLocalDatasource.generateLicenseToken(
        event.activeDays,
      );
      result.fold((l) => emit(ErrorToken(l)), (r) => emit(TokenSuccess(r)));
    });
  }
}
