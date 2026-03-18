part of 'photobooth_bloc.dart';

@freezed
class PhotoboothState with _$PhotoboothState {
  const factory PhotoboothState.initial() = Initial;
  const factory PhotoboothState.loadingPhotobooth() = LoadingPhotobooth;
  const factory PhotoboothState.loadingPhotobooth2() = LoadingPhotobooth2;
  const factory PhotoboothState.loadingPhotobooth3() = LoadingPhotobooth3;
  const factory PhotoboothState.createFileSuccess(
    CreatePhotoboothResponseModel response,
  ) = CreateFileSuccess;
  const factory PhotoboothState.createFileVidioSuccess(
    CreatePhotoboothResponseModel response,
  ) = CreateFileVidioSuccess;
  const factory PhotoboothState.deleteFileSuccess() = DeleteFileSuccess;
  const factory PhotoboothState.deleteAllFileSuccess() = DeleteAllFileSuccess;
  const factory PhotoboothState.errorPhotobooth(String error) = ErrorPhotobooth;
}
