// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'qrcode_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$QrcodeEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QrcodeEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'QrcodeEvent()';
}


}

/// @nodoc
class $QrcodeEventCopyWith<$Res>  {
$QrcodeEventCopyWith(QrcodeEvent _, $Res Function(QrcodeEvent) __);
}


/// Adds pattern-matching-related methods to [QrcodeEvent].
extension QrcodeEventPatterns on QrcodeEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Started value)?  started,TResult Function( _CreateQr value)?  createQr,TResult Function( _CreateQrVideo value)?  createQrVideo,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _CreateQr() when createQr != null:
return createQr(_that);case _CreateQrVideo() when createQrVideo != null:
return createQrVideo(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Started value)  started,required TResult Function( _CreateQr value)  createQr,required TResult Function( _CreateQrVideo value)  createQrVideo,}){
final _that = this;
switch (_that) {
case _Started():
return started(_that);case _CreateQr():
return createQr(_that);case _CreateQrVideo():
return createQrVideo(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Started value)?  started,TResult? Function( _CreateQr value)?  createQr,TResult? Function( _CreateQrVideo value)?  createQrVideo,}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _CreateQr() when createQr != null:
return createQr(_that);case _CreateQrVideo() when createQrVideo != null:
return createQrVideo(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  started,TResult Function( String token)?  createQr,TResult Function( String token)?  createQrVideo,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _CreateQr() when createQr != null:
return createQr(_that.token);case _CreateQrVideo() when createQrVideo != null:
return createQrVideo(_that.token);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  started,required TResult Function( String token)  createQr,required TResult Function( String token)  createQrVideo,}) {final _that = this;
switch (_that) {
case _Started():
return started();case _CreateQr():
return createQr(_that.token);case _CreateQrVideo():
return createQrVideo(_that.token);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  started,TResult? Function( String token)?  createQr,TResult? Function( String token)?  createQrVideo,}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _CreateQr() when createQr != null:
return createQr(_that.token);case _CreateQrVideo() when createQrVideo != null:
return createQrVideo(_that.token);case _:
  return null;

}
}

}

/// @nodoc


class _Started implements QrcodeEvent {
  const _Started();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Started);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'QrcodeEvent.started()';
}


}




/// @nodoc


class _CreateQr implements QrcodeEvent {
  const _CreateQr(this.token);
  

 final  String token;

/// Create a copy of QrcodeEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateQrCopyWith<_CreateQr> get copyWith => __$CreateQrCopyWithImpl<_CreateQr>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateQr&&(identical(other.token, token) || other.token == token));
}


@override
int get hashCode => Object.hash(runtimeType,token);

@override
String toString() {
  return 'QrcodeEvent.createQr(token: $token)';
}


}

/// @nodoc
abstract mixin class _$CreateQrCopyWith<$Res> implements $QrcodeEventCopyWith<$Res> {
  factory _$CreateQrCopyWith(_CreateQr value, $Res Function(_CreateQr) _then) = __$CreateQrCopyWithImpl;
@useResult
$Res call({
 String token
});




}
/// @nodoc
class __$CreateQrCopyWithImpl<$Res>
    implements _$CreateQrCopyWith<$Res> {
  __$CreateQrCopyWithImpl(this._self, this._then);

  final _CreateQr _self;
  final $Res Function(_CreateQr) _then;

/// Create a copy of QrcodeEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? token = null,}) {
  return _then(_CreateQr(
null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _CreateQrVideo implements QrcodeEvent {
  const _CreateQrVideo(this.token);
  

 final  String token;

/// Create a copy of QrcodeEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateQrVideoCopyWith<_CreateQrVideo> get copyWith => __$CreateQrVideoCopyWithImpl<_CreateQrVideo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateQrVideo&&(identical(other.token, token) || other.token == token));
}


@override
int get hashCode => Object.hash(runtimeType,token);

@override
String toString() {
  return 'QrcodeEvent.createQrVideo(token: $token)';
}


}

/// @nodoc
abstract mixin class _$CreateQrVideoCopyWith<$Res> implements $QrcodeEventCopyWith<$Res> {
  factory _$CreateQrVideoCopyWith(_CreateQrVideo value, $Res Function(_CreateQrVideo) _then) = __$CreateQrVideoCopyWithImpl;
@useResult
$Res call({
 String token
});




}
/// @nodoc
class __$CreateQrVideoCopyWithImpl<$Res>
    implements _$CreateQrVideoCopyWith<$Res> {
  __$CreateQrVideoCopyWithImpl(this._self, this._then);

  final _CreateQrVideo _self;
  final $Res Function(_CreateQrVideo) _then;

/// Create a copy of QrcodeEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? token = null,}) {
  return _then(_CreateQrVideo(
null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$QrcodeState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QrcodeState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'QrcodeState()';
}


}

/// @nodoc
class $QrcodeStateCopyWith<$Res>  {
$QrcodeStateCopyWith(QrcodeState _, $Res Function(QrcodeState) __);
}


/// Adds pattern-matching-related methods to [QrcodeState].
extension QrcodeStatePatterns on QrcodeState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Initial value)?  initial,TResult Function( LoadingQrCode value)?  loadingQrCode,TResult Function( LoadingQrCode2 value)?  loadingQrCode2,TResult Function( CreateQrSuccess value)?  createQrSuccess,TResult Function( CreateQrVideoSuccess value)?  createQrVideoSuccess,TResult Function( ErrorQrCode value)?  errorQrCode,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial(_that);case LoadingQrCode() when loadingQrCode != null:
return loadingQrCode(_that);case LoadingQrCode2() when loadingQrCode2 != null:
return loadingQrCode2(_that);case CreateQrSuccess() when createQrSuccess != null:
return createQrSuccess(_that);case CreateQrVideoSuccess() when createQrVideoSuccess != null:
return createQrVideoSuccess(_that);case ErrorQrCode() when errorQrCode != null:
return errorQrCode(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Initial value)  initial,required TResult Function( LoadingQrCode value)  loadingQrCode,required TResult Function( LoadingQrCode2 value)  loadingQrCode2,required TResult Function( CreateQrSuccess value)  createQrSuccess,required TResult Function( CreateQrVideoSuccess value)  createQrVideoSuccess,required TResult Function( ErrorQrCode value)  errorQrCode,}){
final _that = this;
switch (_that) {
case Initial():
return initial(_that);case LoadingQrCode():
return loadingQrCode(_that);case LoadingQrCode2():
return loadingQrCode2(_that);case CreateQrSuccess():
return createQrSuccess(_that);case CreateQrVideoSuccess():
return createQrVideoSuccess(_that);case ErrorQrCode():
return errorQrCode(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Initial value)?  initial,TResult? Function( LoadingQrCode value)?  loadingQrCode,TResult? Function( LoadingQrCode2 value)?  loadingQrCode2,TResult? Function( CreateQrSuccess value)?  createQrSuccess,TResult? Function( CreateQrVideoSuccess value)?  createQrVideoSuccess,TResult? Function( ErrorQrCode value)?  errorQrCode,}){
final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial(_that);case LoadingQrCode() when loadingQrCode != null:
return loadingQrCode(_that);case LoadingQrCode2() when loadingQrCode2 != null:
return loadingQrCode2(_that);case CreateQrSuccess() when createQrSuccess != null:
return createQrSuccess(_that);case CreateQrVideoSuccess() when createQrVideoSuccess != null:
return createQrVideoSuccess(_that);case ErrorQrCode() when errorQrCode != null:
return errorQrCode(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loadingQrCode,TResult Function()?  loadingQrCode2,TResult Function( CreateQrResponseModel response)?  createQrSuccess,TResult Function( CreateQrResponseModel response)?  createQrVideoSuccess,TResult Function( String error)?  errorQrCode,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial();case LoadingQrCode() when loadingQrCode != null:
return loadingQrCode();case LoadingQrCode2() when loadingQrCode2 != null:
return loadingQrCode2();case CreateQrSuccess() when createQrSuccess != null:
return createQrSuccess(_that.response);case CreateQrVideoSuccess() when createQrVideoSuccess != null:
return createQrVideoSuccess(_that.response);case ErrorQrCode() when errorQrCode != null:
return errorQrCode(_that.error);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loadingQrCode,required TResult Function()  loadingQrCode2,required TResult Function( CreateQrResponseModel response)  createQrSuccess,required TResult Function( CreateQrResponseModel response)  createQrVideoSuccess,required TResult Function( String error)  errorQrCode,}) {final _that = this;
switch (_that) {
case Initial():
return initial();case LoadingQrCode():
return loadingQrCode();case LoadingQrCode2():
return loadingQrCode2();case CreateQrSuccess():
return createQrSuccess(_that.response);case CreateQrVideoSuccess():
return createQrVideoSuccess(_that.response);case ErrorQrCode():
return errorQrCode(_that.error);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loadingQrCode,TResult? Function()?  loadingQrCode2,TResult? Function( CreateQrResponseModel response)?  createQrSuccess,TResult? Function( CreateQrResponseModel response)?  createQrVideoSuccess,TResult? Function( String error)?  errorQrCode,}) {final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial();case LoadingQrCode() when loadingQrCode != null:
return loadingQrCode();case LoadingQrCode2() when loadingQrCode2 != null:
return loadingQrCode2();case CreateQrSuccess() when createQrSuccess != null:
return createQrSuccess(_that.response);case CreateQrVideoSuccess() when createQrVideoSuccess != null:
return createQrVideoSuccess(_that.response);case ErrorQrCode() when errorQrCode != null:
return errorQrCode(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class Initial implements QrcodeState {
  const Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'QrcodeState.initial()';
}


}




/// @nodoc


class LoadingQrCode implements QrcodeState {
  const LoadingQrCode();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadingQrCode);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'QrcodeState.loadingQrCode()';
}


}




/// @nodoc


class LoadingQrCode2 implements QrcodeState {
  const LoadingQrCode2();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadingQrCode2);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'QrcodeState.loadingQrCode2()';
}


}




/// @nodoc


class CreateQrSuccess implements QrcodeState {
  const CreateQrSuccess(this.response);
  

 final  CreateQrResponseModel response;

/// Create a copy of QrcodeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateQrSuccessCopyWith<CreateQrSuccess> get copyWith => _$CreateQrSuccessCopyWithImpl<CreateQrSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateQrSuccess&&(identical(other.response, response) || other.response == response));
}


@override
int get hashCode => Object.hash(runtimeType,response);

@override
String toString() {
  return 'QrcodeState.createQrSuccess(response: $response)';
}


}

/// @nodoc
abstract mixin class $CreateQrSuccessCopyWith<$Res> implements $QrcodeStateCopyWith<$Res> {
  factory $CreateQrSuccessCopyWith(CreateQrSuccess value, $Res Function(CreateQrSuccess) _then) = _$CreateQrSuccessCopyWithImpl;
@useResult
$Res call({
 CreateQrResponseModel response
});




}
/// @nodoc
class _$CreateQrSuccessCopyWithImpl<$Res>
    implements $CreateQrSuccessCopyWith<$Res> {
  _$CreateQrSuccessCopyWithImpl(this._self, this._then);

  final CreateQrSuccess _self;
  final $Res Function(CreateQrSuccess) _then;

/// Create a copy of QrcodeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? response = null,}) {
  return _then(CreateQrSuccess(
null == response ? _self.response : response // ignore: cast_nullable_to_non_nullable
as CreateQrResponseModel,
  ));
}


}

/// @nodoc


class CreateQrVideoSuccess implements QrcodeState {
  const CreateQrVideoSuccess(this.response);
  

 final  CreateQrResponseModel response;

/// Create a copy of QrcodeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateQrVideoSuccessCopyWith<CreateQrVideoSuccess> get copyWith => _$CreateQrVideoSuccessCopyWithImpl<CreateQrVideoSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateQrVideoSuccess&&(identical(other.response, response) || other.response == response));
}


@override
int get hashCode => Object.hash(runtimeType,response);

@override
String toString() {
  return 'QrcodeState.createQrVideoSuccess(response: $response)';
}


}

/// @nodoc
abstract mixin class $CreateQrVideoSuccessCopyWith<$Res> implements $QrcodeStateCopyWith<$Res> {
  factory $CreateQrVideoSuccessCopyWith(CreateQrVideoSuccess value, $Res Function(CreateQrVideoSuccess) _then) = _$CreateQrVideoSuccessCopyWithImpl;
@useResult
$Res call({
 CreateQrResponseModel response
});




}
/// @nodoc
class _$CreateQrVideoSuccessCopyWithImpl<$Res>
    implements $CreateQrVideoSuccessCopyWith<$Res> {
  _$CreateQrVideoSuccessCopyWithImpl(this._self, this._then);

  final CreateQrVideoSuccess _self;
  final $Res Function(CreateQrVideoSuccess) _then;

/// Create a copy of QrcodeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? response = null,}) {
  return _then(CreateQrVideoSuccess(
null == response ? _self.response : response // ignore: cast_nullable_to_non_nullable
as CreateQrResponseModel,
  ));
}


}

/// @nodoc


class ErrorQrCode implements QrcodeState {
  const ErrorQrCode(this.error);
  

 final  String error;

/// Create a copy of QrcodeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ErrorQrCodeCopyWith<ErrorQrCode> get copyWith => _$ErrorQrCodeCopyWithImpl<ErrorQrCode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ErrorQrCode&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'QrcodeState.errorQrCode(error: $error)';
}


}

/// @nodoc
abstract mixin class $ErrorQrCodeCopyWith<$Res> implements $QrcodeStateCopyWith<$Res> {
  factory $ErrorQrCodeCopyWith(ErrorQrCode value, $Res Function(ErrorQrCode) _then) = _$ErrorQrCodeCopyWithImpl;
@useResult
$Res call({
 String error
});




}
/// @nodoc
class _$ErrorQrCodeCopyWithImpl<$Res>
    implements $ErrorQrCodeCopyWith<$Res> {
  _$ErrorQrCodeCopyWithImpl(this._self, this._then);

  final ErrorQrCode _self;
  final $Res Function(ErrorQrCode) _then;

/// Create a copy of QrcodeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(ErrorQrCode(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
