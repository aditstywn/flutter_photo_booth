import 'dart:io';

import 'package:bloc/bloc.dart';
import '../../../data/datasource/photo_booth_remote_datasource.dart';
import '../../../data/models/response/create_photobooth_response_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../data/models/request/create_photobooth_request_model.dart';

part 'photobooth_event.dart';
part 'photobooth_state.dart';
part 'photobooth_bloc.freezed.dart';

class PhotoboothBloc extends Bloc<PhotoboothEvent, PhotoboothState> {
  final PhotoBoothRemoteDatasource _photoBoothRemoteDatasource;
  PhotoboothBloc(this._photoBoothRemoteDatasource) : super(Initial()) {
    on<_CreateFile>((event, emit) async {
      emit(const LoadingPhotobooth());
      final result = await _photoBoothRemoteDatasource.createFile(event.files);
      result.fold(
        (l) => emit(ErrorPhotobooth(l)),
        (r) => emit(CreateFileSuccess(r)),
      );
    });
    on<_CreateFileVidio>((event, emit) async {
      emit(const LoadingPhotobooth3());
      final result = await _photoBoothRemoteDatasource.createFileVidio(
        event.file,
        event.idPhoto,
      );
      result.fold(
        (l) => emit(ErrorPhotobooth(l)),
        (r) => emit(CreateFileVidioSuccess(r)),
      );
    });
    on<_DeleteFile>((event, emit) async {
      emit(const LoadingPhotobooth2());
      final result = await _photoBoothRemoteDatasource.deleteFile(event.id);
      result.fold(
        (l) => emit(ErrorPhotobooth(l)),
        (r) => emit(const DeleteFileSuccess()),
      );
    });
    on<_DeleteAllFile>((event, emit) async {
      emit(const LoadingPhotobooth());
      final result = await _photoBoothRemoteDatasource.deleteAllFile();
      result.fold(
        (l) => emit(ErrorPhotobooth(l)),
        (r) => emit(const DeleteAllFileSuccess()),
      );
    });
  }
}
