part of 'qrcode_bloc.dart';

@freezed
class QrcodeEvent with _$QrcodeEvent {
  const factory QrcodeEvent.started() = _Started;
  const factory QrcodeEvent.createQr(String token) = _CreateQr;
  const factory QrcodeEvent.createQrVideo(String token) = _CreateQrVideo;
}
