part of 'qrcode_bloc.dart';

@freezed
class QrcodeState with _$QrcodeState {
  const factory QrcodeState.initial() = Initial;
  const factory QrcodeState.loadingQrCode() = LoadingQrCode;
  const factory QrcodeState.loadingQrCode2() = LoadingQrCode2;
  const factory QrcodeState.createQrSuccess(CreateQrResponseModel response) =
      CreateQrSuccess;
  const factory QrcodeState.createQrVideoSuccess(
    CreateQrResponseModel response,
  ) = CreateQrVideoSuccess;
  const factory QrcodeState.errorQrCode(String error) = ErrorQrCode;
}
