part of 'photobooth_bloc.dart';

@freezed
class PhotoboothEvent with _$PhotoboothEvent {
  const factory PhotoboothEvent.started() = _Started;
  const factory PhotoboothEvent.createFile(CreatePhotoboothRequestModel files) =
      _CreateFile;
  const factory PhotoboothEvent.createFileVidio(File file, int idPhoto) =
      _CreateFileVidio;
  const factory PhotoboothEvent.deleteFile(int id) = _DeleteFile;
  const factory PhotoboothEvent.deleteAllFile() = _DeleteAllFile;
}
