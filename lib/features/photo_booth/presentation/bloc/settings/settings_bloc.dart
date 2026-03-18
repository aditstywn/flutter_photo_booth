import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../data/datasource/photo_booth_remote_datasource.dart';
import '../../../data/models/response/statistic_response_model.dart';

part 'settings_bloc.freezed.dart';
part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final PhotoBoothRemoteDatasource _photoBoothRemoteDatasource;
  SettingsBloc(this._photoBoothRemoteDatasource) : super(Initial()) {
    on<_Statistic>((event, emit) async {
      emit(const LoadingSettings());
      final result = await _photoBoothRemoteDatasource.statistic();
      result.fold(
        (error) => emit(ErrorSettings(error)),
        (statistic) => emit(StatisticSuccess(statistic)),
      );
    });
  }
}
