part of 'settings_bloc.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState.initial() = Initial;
  const factory SettingsState.loadingSettings() = LoadingSettings;
  const factory SettingsState.statisticSuccess(
    StatisticResponseModel statistic,
  ) = StatisticSuccess;
  const factory SettingsState.errorSettings(String error) = ErrorSettings;
}
