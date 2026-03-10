// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'token_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TokenEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TokenEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TokenEvent()';
}


}

/// @nodoc
class $TokenEventCopyWith<$Res>  {
$TokenEventCopyWith(TokenEvent _, $Res Function(TokenEvent) __);
}


/// Adds pattern-matching-related methods to [TokenEvent].
extension TokenEventPatterns on TokenEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Started value)?  started,TResult Function( _GenerateToken value)?  generateToken,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _GenerateToken() when generateToken != null:
return generateToken(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Started value)  started,required TResult Function( _GenerateToken value)  generateToken,}){
final _that = this;
switch (_that) {
case _Started():
return started(_that);case _GenerateToken():
return generateToken(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Started value)?  started,TResult? Function( _GenerateToken value)?  generateToken,}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _GenerateToken() when generateToken != null:
return generateToken(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  started,TResult Function( int activeDays)?  generateToken,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _GenerateToken() when generateToken != null:
return generateToken(_that.activeDays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  started,required TResult Function( int activeDays)  generateToken,}) {final _that = this;
switch (_that) {
case _Started():
return started();case _GenerateToken():
return generateToken(_that.activeDays);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  started,TResult? Function( int activeDays)?  generateToken,}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _GenerateToken() when generateToken != null:
return generateToken(_that.activeDays);case _:
  return null;

}
}

}

/// @nodoc


class _Started implements TokenEvent {
  const _Started();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Started);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TokenEvent.started()';
}


}




/// @nodoc


class _GenerateToken implements TokenEvent {
  const _GenerateToken(this.activeDays);
  

 final  int activeDays;

/// Create a copy of TokenEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenerateTokenCopyWith<_GenerateToken> get copyWith => __$GenerateTokenCopyWithImpl<_GenerateToken>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GenerateToken&&(identical(other.activeDays, activeDays) || other.activeDays == activeDays));
}


@override
int get hashCode => Object.hash(runtimeType,activeDays);

@override
String toString() {
  return 'TokenEvent.generateToken(activeDays: $activeDays)';
}


}

/// @nodoc
abstract mixin class _$GenerateTokenCopyWith<$Res> implements $TokenEventCopyWith<$Res> {
  factory _$GenerateTokenCopyWith(_GenerateToken value, $Res Function(_GenerateToken) _then) = __$GenerateTokenCopyWithImpl;
@useResult
$Res call({
 int activeDays
});




}
/// @nodoc
class __$GenerateTokenCopyWithImpl<$Res>
    implements _$GenerateTokenCopyWith<$Res> {
  __$GenerateTokenCopyWithImpl(this._self, this._then);

  final _GenerateToken _self;
  final $Res Function(_GenerateToken) _then;

/// Create a copy of TokenEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? activeDays = null,}) {
  return _then(_GenerateToken(
null == activeDays ? _self.activeDays : activeDays // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$TokenState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TokenState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TokenState()';
}


}

/// @nodoc
class $TokenStateCopyWith<$Res>  {
$TokenStateCopyWith(TokenState _, $Res Function(TokenState) __);
}


/// Adds pattern-matching-related methods to [TokenState].
extension TokenStatePatterns on TokenState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Initial value)?  initial,TResult Function( LoadingToken value)?  loadingToken,TResult Function( TokenSuccess value)?  tokenSuccess,TResult Function( ErrorToken value)?  errorToken,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial(_that);case LoadingToken() when loadingToken != null:
return loadingToken(_that);case TokenSuccess() when tokenSuccess != null:
return tokenSuccess(_that);case ErrorToken() when errorToken != null:
return errorToken(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Initial value)  initial,required TResult Function( LoadingToken value)  loadingToken,required TResult Function( TokenSuccess value)  tokenSuccess,required TResult Function( ErrorToken value)  errorToken,}){
final _that = this;
switch (_that) {
case Initial():
return initial(_that);case LoadingToken():
return loadingToken(_that);case TokenSuccess():
return tokenSuccess(_that);case ErrorToken():
return errorToken(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Initial value)?  initial,TResult? Function( LoadingToken value)?  loadingToken,TResult? Function( TokenSuccess value)?  tokenSuccess,TResult? Function( ErrorToken value)?  errorToken,}){
final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial(_that);case LoadingToken() when loadingToken != null:
return loadingToken(_that);case TokenSuccess() when tokenSuccess != null:
return tokenSuccess(_that);case ErrorToken() when errorToken != null:
return errorToken(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loadingToken,TResult Function( String token)?  tokenSuccess,TResult Function( String message)?  errorToken,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial();case LoadingToken() when loadingToken != null:
return loadingToken();case TokenSuccess() when tokenSuccess != null:
return tokenSuccess(_that.token);case ErrorToken() when errorToken != null:
return errorToken(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loadingToken,required TResult Function( String token)  tokenSuccess,required TResult Function( String message)  errorToken,}) {final _that = this;
switch (_that) {
case Initial():
return initial();case LoadingToken():
return loadingToken();case TokenSuccess():
return tokenSuccess(_that.token);case ErrorToken():
return errorToken(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loadingToken,TResult? Function( String token)?  tokenSuccess,TResult? Function( String message)?  errorToken,}) {final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial();case LoadingToken() when loadingToken != null:
return loadingToken();case TokenSuccess() when tokenSuccess != null:
return tokenSuccess(_that.token);case ErrorToken() when errorToken != null:
return errorToken(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class Initial implements TokenState {
  const Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TokenState.initial()';
}


}




/// @nodoc


class LoadingToken implements TokenState {
  const LoadingToken();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadingToken);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TokenState.loadingToken()';
}


}




/// @nodoc


class TokenSuccess implements TokenState {
  const TokenSuccess(this.token);
  

 final  String token;

/// Create a copy of TokenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TokenSuccessCopyWith<TokenSuccess> get copyWith => _$TokenSuccessCopyWithImpl<TokenSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TokenSuccess&&(identical(other.token, token) || other.token == token));
}


@override
int get hashCode => Object.hash(runtimeType,token);

@override
String toString() {
  return 'TokenState.tokenSuccess(token: $token)';
}


}

/// @nodoc
abstract mixin class $TokenSuccessCopyWith<$Res> implements $TokenStateCopyWith<$Res> {
  factory $TokenSuccessCopyWith(TokenSuccess value, $Res Function(TokenSuccess) _then) = _$TokenSuccessCopyWithImpl;
@useResult
$Res call({
 String token
});




}
/// @nodoc
class _$TokenSuccessCopyWithImpl<$Res>
    implements $TokenSuccessCopyWith<$Res> {
  _$TokenSuccessCopyWithImpl(this._self, this._then);

  final TokenSuccess _self;
  final $Res Function(TokenSuccess) _then;

/// Create a copy of TokenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? token = null,}) {
  return _then(TokenSuccess(
null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ErrorToken implements TokenState {
  const ErrorToken(this.message);
  

 final  String message;

/// Create a copy of TokenState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ErrorTokenCopyWith<ErrorToken> get copyWith => _$ErrorTokenCopyWithImpl<ErrorToken>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ErrorToken&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'TokenState.errorToken(message: $message)';
}


}

/// @nodoc
abstract mixin class $ErrorTokenCopyWith<$Res> implements $TokenStateCopyWith<$Res> {
  factory $ErrorTokenCopyWith(ErrorToken value, $Res Function(ErrorToken) _then) = _$ErrorTokenCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$ErrorTokenCopyWithImpl<$Res>
    implements $ErrorTokenCopyWith<$Res> {
  _$ErrorTokenCopyWithImpl(this._self, this._then);

  final ErrorToken _self;
  final $Res Function(ErrorToken) _then;

/// Create a copy of TokenState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(ErrorToken(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
