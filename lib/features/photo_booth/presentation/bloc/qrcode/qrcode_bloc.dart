import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../data/datasource/photo_booth_remote_datasource.dart';
import '../../../data/models/response/create_qr_response_model.dart';

part 'qrcode_event.dart';
part 'qrcode_state.dart';
part 'qrcode_bloc.freezed.dart';

class QrcodeBloc extends Bloc<QrcodeEvent, QrcodeState> {
  final PhotoBoothRemoteDatasource _photoBoothRemoteDatasource;
  QrcodeBloc(this._photoBoothRemoteDatasource) : super(Initial()) {
    on<_CreateQr>((event, emit) async {
      emit(const LoadingQrCode());
      final result = await _photoBoothRemoteDatasource.createQr(event.token);
      result.fold((l) => emit(ErrorQrCode(l)), (r) => emit(CreateQrSuccess(r)));
    });
    on<_CreateQrVideo>((event, emit) async {
      emit(const LoadingQrCode2());
      final result = await _photoBoothRemoteDatasource.createQrVideo(
        event.token,
      );
      result.fold(
        (l) => emit(ErrorQrCode(l)),
        (r) => emit(CreateQrVideoSuccess(r)),
      );
    });
  }
}
