// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photobooth_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PhotoboothEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoboothEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PhotoboothEvent()';
}


}

/// @nodoc
class $PhotoboothEventCopyWith<$Res>  {
$PhotoboothEventCopyWith(PhotoboothEvent _, $Res Function(PhotoboothEvent) __);
}


/// Adds pattern-matching-related methods to [PhotoboothEvent].
extension PhotoboothEventPatterns on PhotoboothEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Started value)?  started,TResult Function( _CreateFile value)?  createFile,TResult Function( _CreateFileVidio value)?  createFileVidio,TResult Function( _DeleteFile value)?  deleteFile,TResult Function( _DeleteAllFile value)?  deleteAllFile,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _CreateFile() when createFile != null:
return createFile(_that);case _CreateFileVidio() when createFileVidio != null:
return createFileVidio(_that);case _DeleteFile() when deleteFile != null:
return deleteFile(_that);case _DeleteAllFile() when deleteAllFile != null:
return deleteAllFile(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Started value)  started,required TResult Function( _CreateFile value)  createFile,required TResult Function( _CreateFileVidio value)  createFileVidio,required TResult Function( _DeleteFile value)  deleteFile,required TResult Function( _DeleteAllFile value)  deleteAllFile,}){
final _that = this;
switch (_that) {
case _Started():
return started(_that);case _CreateFile():
return createFile(_that);case _CreateFileVidio():
return createFileVidio(_that);case _DeleteFile():
return deleteFile(_that);case _DeleteAllFile():
return deleteAllFile(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Started value)?  started,TResult? Function( _CreateFile value)?  createFile,TResult? Function( _CreateFileVidio value)?  createFileVidio,TResult? Function( _DeleteFile value)?  deleteFile,TResult? Function( _DeleteAllFile value)?  deleteAllFile,}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _CreateFile() when createFile != null:
return createFile(_that);case _CreateFileVidio() when createFileVidio != null:
return createFileVidio(_that);case _DeleteFile() when deleteFile != null:
return deleteFile(_that);case _DeleteAllFile() when deleteAllFile != null:
return deleteAllFile(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  started,TResult Function( CreatePhotoboothRequestModel files)?  createFile,TResult Function( File file,  int idPhoto)?  createFileVidio,TResult Function( int id)?  deleteFile,TResult Function()?  deleteAllFile,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _CreateFile() when createFile != null:
return createFile(_that.files);case _CreateFileVidio() when createFileVidio != null:
return createFileVidio(_that.file,_that.idPhoto);case _DeleteFile() when deleteFile != null:
return deleteFile(_that.id);case _DeleteAllFile() when deleteAllFile != null:
return deleteAllFile();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  started,required TResult Function( CreatePhotoboothRequestModel files)  createFile,required TResult Function( File file,  int idPhoto)  createFileVidio,required TResult Function( int id)  deleteFile,required TResult Function()  deleteAllFile,}) {final _that = this;
switch (_that) {
case _Started():
return started();case _CreateFile():
return createFile(_that.files);case _CreateFileVidio():
return createFileVidio(_that.file,_that.idPhoto);case _DeleteFile():
return deleteFile(_that.id);case _DeleteAllFile():
return deleteAllFile();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  started,TResult? Function( CreatePhotoboothRequestModel files)?  createFile,TResult? Function( File file,  int idPhoto)?  createFileVidio,TResult? Function( int id)?  deleteFile,TResult? Function()?  deleteAllFile,}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _CreateFile() when createFile != null:
return createFile(_that.files);case _CreateFileVidio() when createFileVidio != null:
return createFileVidio(_that.file,_that.idPhoto);case _DeleteFile() when deleteFile != null:
return deleteFile(_that.id);case _DeleteAllFile() when deleteAllFile != null:
return deleteAllFile();case _:
  return null;

}
}

}

/// @nodoc


class _Started implements PhotoboothEvent {
  const _Started();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Started);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PhotoboothEvent.started()';
}


}




/// @nodoc


class _CreateFile implements PhotoboothEvent {
  const _CreateFile(this.files);
  

 final  CreatePhotoboothRequestModel files;

/// Create a copy of PhotoboothEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateFileCopyWith<_CreateFile> get copyWith => __$CreateFileCopyWithImpl<_CreateFile>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateFile&&(identical(other.files, files) || other.files == files));
}


@override
int get hashCode => Object.hash(runtimeType,files);

@override
String toString() {
  return 'PhotoboothEvent.createFile(files: $files)';
}


}

/// @nodoc
abstract mixin class _$CreateFileCopyWith<$Res> implements $PhotoboothEventCopyWith<$Res> {
  factory _$CreateFileCopyWith(_CreateFile value, $Res Function(_CreateFile) _then) = __$CreateFileCopyWithImpl;
@useResult
$Res call({
 CreatePhotoboothRequestModel files
});




}
/// @nodoc
class __$CreateFileCopyWithImpl<$Res>
    implements _$CreateFileCopyWith<$Res> {
  __$CreateFileCopyWithImpl(this._self, this._then);

  final _CreateFile _self;
  final $Res Function(_CreateFile) _then;

/// Create a copy of PhotoboothEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? files = null,}) {
  return _then(_CreateFile(
null == files ? _self.files : files // ignore: cast_nullable_to_non_nullable
as CreatePhotoboothRequestModel,
  ));
}


}

/// @nodoc


class _CreateFileVidio implements PhotoboothEvent {
  const _CreateFileVidio(this.file, this.idPhoto);
  

 final  File file;
 final  int idPhoto;

/// Create a copy of PhotoboothEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateFileVidioCopyWith<_CreateFileVidio> get copyWith => __$CreateFileVidioCopyWithImpl<_CreateFileVidio>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateFileVidio&&(identical(other.file, file) || other.file == file)&&(identical(other.idPhoto, idPhoto) || other.idPhoto == idPhoto));
}


@override
int get hashCode => Object.hash(runtimeType,file,idPhoto);

@override
String toString() {
  return 'PhotoboothEvent.createFileVidio(file: $file, idPhoto: $idPhoto)';
}


}

/// @nodoc
abstract mixin class _$CreateFileVidioCopyWith<$Res> implements $PhotoboothEventCopyWith<$Res> {
  factory _$CreateFileVidioCopyWith(_CreateFileVidio value, $Res Function(_CreateFileVidio) _then) = __$CreateFileVidioCopyWithImpl;
@useResult
$Res call({
 File file, int idPhoto
});




}
/// @nodoc
class __$CreateFileVidioCopyWithImpl<$Res>
    implements _$CreateFileVidioCopyWith<$Res> {
  __$CreateFileVidioCopyWithImpl(this._self, this._then);

  final _CreateFileVidio _self;
  final $Res Function(_CreateFileVidio) _then;

/// Create a copy of PhotoboothEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? file = null,Object? idPhoto = null,}) {
  return _then(_CreateFileVidio(
null == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as File,null == idPhoto ? _self.idPhoto : idPhoto // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _DeleteFile implements PhotoboothEvent {
  const _DeleteFile(this.id);
  

 final  int id;

/// Create a copy of PhotoboothEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeleteFileCopyWith<_DeleteFile> get copyWith => __$DeleteFileCopyWithImpl<_DeleteFile>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeleteFile&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'PhotoboothEvent.deleteFile(id: $id)';
}


}

/// @nodoc
abstract mixin class _$DeleteFileCopyWith<$Res> implements $PhotoboothEventCopyWith<$Res> {
  factory _$DeleteFileCopyWith(_DeleteFile value, $Res Function(_DeleteFile) _then) = __$DeleteFileCopyWithImpl;
@useResult
$Res call({
 int id
});




}
/// @nodoc
class __$DeleteFileCopyWithImpl<$Res>
    implements _$DeleteFileCopyWith<$Res> {
  __$DeleteFileCopyWithImpl(this._self, this._then);

  final _DeleteFile _self;
  final $Res Function(_DeleteFile) _then;

/// Create a copy of PhotoboothEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(_DeleteFile(
null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _DeleteAllFile implements PhotoboothEvent {
  const _DeleteAllFile();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeleteAllFile);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PhotoboothEvent.deleteAllFile()';
}


}




/// @nodoc
mixin _$PhotoboothState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PhotoboothState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PhotoboothState()';
}


}

/// @nodoc
class $PhotoboothStateCopyWith<$Res>  {
$PhotoboothStateCopyWith(PhotoboothState _, $Res Function(PhotoboothState) __);
}


/// Adds pattern-matching-related methods to [PhotoboothState].
extension PhotoboothStatePatterns on PhotoboothState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Initial value)?  initial,TResult Function( LoadingPhotobooth value)?  loadingPhotobooth,TResult Function( LoadingPhotobooth2 value)?  loadingPhotobooth2,TResult Function( LoadingPhotobooth3 value)?  loadingPhotobooth3,TResult Function( CreateFileSuccess value)?  createFileSuccess,TResult Function( CreateFileVidioSuccess value)?  createFileVidioSuccess,TResult Function( DeleteFileSuccess value)?  deleteFileSuccess,TResult Function( DeleteAllFileSuccess value)?  deleteAllFileSuccess,TResult Function( ErrorPhotobooth value)?  errorPhotobooth,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial(_that);case LoadingPhotobooth() when loadingPhotobooth != null:
return loadingPhotobooth(_that);case LoadingPhotobooth2() when loadingPhotobooth2 != null:
return loadingPhotobooth2(_that);case LoadingPhotobooth3() when loadingPhotobooth3 != null:
return loadingPhotobooth3(_that);case CreateFileSuccess() when createFileSuccess != null:
return createFileSuccess(_that);case CreateFileVidioSuccess() when createFileVidioSuccess != null:
return createFileVidioSuccess(_that);case DeleteFileSuccess() when deleteFileSuccess != null:
return deleteFileSuccess(_that);case DeleteAllFileSuccess() when deleteAllFileSuccess != null:
return deleteAllFileSuccess(_that);case ErrorPhotobooth() when errorPhotobooth != null:
return errorPhotobooth(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Initial value)  initial,required TResult Function( LoadingPhotobooth value)  loadingPhotobooth,required TResult Function( LoadingPhotobooth2 value)  loadingPhotobooth2,required TResult Function( LoadingPhotobooth3 value)  loadingPhotobooth3,required TResult Function( CreateFileSuccess value)  createFileSuccess,required TResult Function( CreateFileVidioSuccess value)  createFileVidioSuccess,required TResult Function( DeleteFileSuccess value)  deleteFileSuccess,required TResult Function( DeleteAllFileSuccess value)  deleteAllFileSuccess,required TResult Function( ErrorPhotobooth value)  errorPhotobooth,}){
final _that = this;
switch (_that) {
case Initial():
return initial(_that);case LoadingPhotobooth():
return loadingPhotobooth(_that);case LoadingPhotobooth2():
return loadingPhotobooth2(_that);case LoadingPhotobooth3():
return loadingPhotobooth3(_that);case CreateFileSuccess():
return createFileSuccess(_that);case CreateFileVidioSuccess():
return createFileVidioSuccess(_that);case DeleteFileSuccess():
return deleteFileSuccess(_that);case DeleteAllFileSuccess():
return deleteAllFileSuccess(_that);case ErrorPhotobooth():
return errorPhotobooth(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Initial value)?  initial,TResult? Function( LoadingPhotobooth value)?  loadingPhotobooth,TResult? Function( LoadingPhotobooth2 value)?  loadingPhotobooth2,TResult? Function( LoadingPhotobooth3 value)?  loadingPhotobooth3,TResult? Function( CreateFileSuccess value)?  createFileSuccess,TResult? Function( CreateFileVidioSuccess value)?  createFileVidioSuccess,TResult? Function( DeleteFileSuccess value)?  deleteFileSuccess,TResult? Function( DeleteAllFileSuccess value)?  deleteAllFileSuccess,TResult? Function( ErrorPhotobooth value)?  errorPhotobooth,}){
final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial(_that);case LoadingPhotobooth() when loadingPhotobooth != null:
return loadingPhotobooth(_that);case LoadingPhotobooth2() when loadingPhotobooth2 != null:
return loadingPhotobooth2(_that);case LoadingPhotobooth3() when loadingPhotobooth3 != null:
return loadingPhotobooth3(_that);case CreateFileSuccess() when createFileSuccess != null:
return createFileSuccess(_that);case CreateFileVidioSuccess() when createFileVidioSuccess != null:
return createFileVidioSuccess(_that);case DeleteFileSuccess() when deleteFileSuccess != null:
return deleteFileSuccess(_that);case DeleteAllFileSuccess() when deleteAllFileSuccess != null:
return deleteAllFileSuccess(_that);case ErrorPhotobooth() when errorPhotobooth != null:
return errorPhotobooth(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loadingPhotobooth,TResult Function()?  loadingPhotobooth2,TResult Function()?  loadingPhotobooth3,TResult Function( CreatePhotoboothResponseModel response)?  createFileSuccess,TResult Function( CreatePhotoboothResponseModel response)?  createFileVidioSuccess,TResult Function()?  deleteFileSuccess,TResult Function()?  deleteAllFileSuccess,TResult Function( String error)?  errorPhotobooth,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial();case LoadingPhotobooth() when loadingPhotobooth != null:
return loadingPhotobooth();case LoadingPhotobooth2() when loadingPhotobooth2 != null:
return loadingPhotobooth2();case LoadingPhotobooth3() when loadingPhotobooth3 != null:
return loadingPhotobooth3();case CreateFileSuccess() when createFileSuccess != null:
return createFileSuccess(_that.response);case CreateFileVidioSuccess() when createFileVidioSuccess != null:
return createFileVidioSuccess(_that.response);case DeleteFileSuccess() when deleteFileSuccess != null:
return deleteFileSuccess();case DeleteAllFileSuccess() when deleteAllFileSuccess != null:
return deleteAllFileSuccess();case ErrorPhotobooth() when errorPhotobooth != null:
return errorPhotobooth(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loadingPhotobooth,required TResult Function()  loadingPhotobooth2,required TResult Function()  loadingPhotobooth3,required TResult Function( CreatePhotoboothResponseModel response)  createFileSuccess,required TResult Function( CreatePhotoboothResponseModel response)  createFileVidioSuccess,required TResult Function()  deleteFileSuccess,required TResult Function()  deleteAllFileSuccess,required TResult Function( String error)  errorPhotobooth,}) {final _that = this;
switch (_that) {
case Initial():
return initial();case LoadingPhotobooth():
return loadingPhotobooth();case LoadingPhotobooth2():
return loadingPhotobooth2();case LoadingPhotobooth3():
return loadingPhotobooth3();case CreateFileSuccess():
return createFileSuccess(_that.response);case CreateFileVidioSuccess():
return createFileVidioSuccess(_that.response);case DeleteFileSuccess():
return deleteFileSuccess();case DeleteAllFileSuccess():
return deleteAllFileSuccess();case ErrorPhotobooth():
return errorPhotobooth(_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loadingPhotobooth,TResult? Function()?  loadingPhotobooth2,TResult? Function()?  loadingPhotobooth3,TResult? Function( CreatePhotoboothResponseModel response)?  createFileSuccess,TResult? Function( CreatePhotoboothResponseModel response)?  createFileVidioSuccess,TResult? Function()?  deleteFileSuccess,TResult? Function()?  deleteAllFileSuccess,TResult? Function( String error)?  errorPhotobooth,}) {final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial();case LoadingPhotobooth() when loadingPhotobooth != null:
return loadingPhotobooth();case LoadingPhotobooth2() when loadingPhotobooth2 != null:
return loadingPhotobooth2();case LoadingPhotobooth3() when loadingPhotobooth3 != null:
return loadingPhotobooth3();case CreateFileSuccess() when createFileSuccess != null:
return createFileSuccess(_that.response);case CreateFileVidioSuccess() when createFileVidioSuccess != null:
return createFileVidioSuccess(_that.response);case DeleteFileSuccess() when deleteFileSuccess != null:
return deleteFileSuccess();case DeleteAllFileSuccess() when deleteAllFileSuccess != null:
return deleteAllFileSuccess();case ErrorPhotobooth() when errorPhotobooth != null:
return errorPhotobooth(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class Initial implements PhotoboothState {
  const Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PhotoboothState.initial()';
}


}




/// @nodoc


class LoadingPhotobooth implements PhotoboothState {
  const LoadingPhotobooth();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadingPhotobooth);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PhotoboothState.loadingPhotobooth()';
}


}




/// @nodoc


class LoadingPhotobooth2 implements PhotoboothState {
  const LoadingPhotobooth2();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadingPhotobooth2);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PhotoboothState.loadingPhotobooth2()';
}


}




/// @nodoc


class LoadingPhotobooth3 implements PhotoboothState {
  const LoadingPhotobooth3();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadingPhotobooth3);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PhotoboothState.loadingPhotobooth3()';
}


}




/// @nodoc


class CreateFileSuccess implements PhotoboothState {
  const CreateFileSuccess(this.response);
  

 final  CreatePhotoboothResponseModel response;

/// Create a copy of PhotoboothState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateFileSuccessCopyWith<CreateFileSuccess> get copyWith => _$CreateFileSuccessCopyWithImpl<CreateFileSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateFileSuccess&&(identical(other.response, response) || other.response == response));
}


@override
int get hashCode => Object.hash(runtimeType,response);

@override
String toString() {
  return 'PhotoboothState.createFileSuccess(response: $response)';
}


}

/// @nodoc
abstract mixin class $CreateFileSuccessCopyWith<$Res> implements $PhotoboothStateCopyWith<$Res> {
  factory $CreateFileSuccessCopyWith(CreateFileSuccess value, $Res Function(CreateFileSuccess) _then) = _$CreateFileSuccessCopyWithImpl;
@useResult
$Res call({
 CreatePhotoboothResponseModel response
});




}
/// @nodoc
class _$CreateFileSuccessCopyWithImpl<$Res>
    implements $CreateFileSuccessCopyWith<$Res> {
  _$CreateFileSuccessCopyWithImpl(this._self, this._then);

  final CreateFileSuccess _self;
  final $Res Function(CreateFileSuccess) _then;

/// Create a copy of PhotoboothState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? response = null,}) {
  return _then(CreateFileSuccess(
null == response ? _self.response : response // ignore: cast_nullable_to_non_nullable
as CreatePhotoboothResponseModel,
  ));
}


}

/// @nodoc


class CreateFileVidioSuccess implements PhotoboothState {
  const CreateFileVidioSuccess(this.response);
  

 final  CreatePhotoboothResponseModel response;

/// Create a copy of PhotoboothState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateFileVidioSuccessCopyWith<CreateFileVidioSuccess> get copyWith => _$CreateFileVidioSuccessCopyWithImpl<CreateFileVidioSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateFileVidioSuccess&&(identical(other.response, response) || other.response == response));
}


@override
int get hashCode => Object.hash(runtimeType,response);

@override
String toString() {
  return 'PhotoboothState.createFileVidioSuccess(response: $response)';
}


}

/// @nodoc
abstract mixin class $CreateFileVidioSuccessCopyWith<$Res> implements $PhotoboothStateCopyWith<$Res> {
  factory $CreateFileVidioSuccessCopyWith(CreateFileVidioSuccess value, $Res Function(CreateFileVidioSuccess) _then) = _$CreateFileVidioSuccessCopyWithImpl;
@useResult
$Res call({
 CreatePhotoboothResponseModel response
});




}
/// @nodoc
class _$CreateFileVidioSuccessCopyWithImpl<$Res>
    implements $CreateFileVidioSuccessCopyWith<$Res> {
  _$CreateFileVidioSuccessCopyWithImpl(this._self, this._then);

  final CreateFileVidioSuccess _self;
  final $Res Function(CreateFileVidioSuccess) _then;

/// Create a copy of PhotoboothState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? response = null,}) {
  return _then(CreateFileVidioSuccess(
null == response ? _self.response : response // ignore: cast_nullable_to_non_nullable
as CreatePhotoboothResponseModel,
  ));
}


}

/// @nodoc


class DeleteFileSuccess implements PhotoboothState {
  const DeleteFileSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeleteFileSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PhotoboothState.deleteFileSuccess()';
}


}




/// @nodoc


class DeleteAllFileSuccess implements PhotoboothState {
  const DeleteAllFileSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeleteAllFileSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PhotoboothState.deleteAllFileSuccess()';
}


}




/// @nodoc


class ErrorPhotobooth implements PhotoboothState {
  const ErrorPhotobooth(this.error);
  

 final  String error;

/// Create a copy of PhotoboothState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ErrorPhotoboothCopyWith<ErrorPhotobooth> get copyWith => _$ErrorPhotoboothCopyWithImpl<ErrorPhotobooth>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ErrorPhotobooth&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'PhotoboothState.errorPhotobooth(error: $error)';
}


}

/// @nodoc
abstract mixin class $ErrorPhotoboothCopyWith<$Res> implements $PhotoboothStateCopyWith<$Res> {
  factory $ErrorPhotoboothCopyWith(ErrorPhotobooth value, $Res Function(ErrorPhotobooth) _then) = _$ErrorPhotoboothCopyWithImpl;
@useResult
$Res call({
 String error
});




}
/// @nodoc
class _$ErrorPhotoboothCopyWithImpl<$Res>
    implements $ErrorPhotoboothCopyWith<$Res> {
  _$ErrorPhotoboothCopyWithImpl(this._self, this._then);

  final ErrorPhotobooth _self;
  final $Res Function(ErrorPhotobooth) _then;

/// Create a copy of PhotoboothState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(ErrorPhotobooth(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
