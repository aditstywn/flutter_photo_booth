// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SettingsEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SettingsEvent()';
}


}

/// @nodoc
class $SettingsEventCopyWith<$Res>  {
$SettingsEventCopyWith(SettingsEvent _, $Res Function(SettingsEvent) __);
}


/// Adds pattern-matching-related methods to [SettingsEvent].
extension SettingsEventPatterns on SettingsEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Started value)?  started,TResult Function( _Statistic value)?  statistic,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _Statistic() when statistic != null:
return statistic(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Started value)  started,required TResult Function( _Statistic value)  statistic,}){
final _that = this;
switch (_that) {
case _Started():
return started(_that);case _Statistic():
return statistic(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Started value)?  started,TResult? Function( _Statistic value)?  statistic,}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _Statistic() when statistic != null:
return statistic(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  started,TResult Function()?  statistic,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _Statistic() when statistic != null:
return statistic();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  started,required TResult Function()  statistic,}) {final _that = this;
switch (_that) {
case _Started():
return started();case _Statistic():
return statistic();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  started,TResult? Function()?  statistic,}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _Statistic() when statistic != null:
return statistic();case _:
  return null;

}
}

}

/// @nodoc


class _Started implements SettingsEvent {
  const _Started();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Started);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SettingsEvent.started()';
}


}




/// @nodoc


class _Statistic implements SettingsEvent {
  const _Statistic();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Statistic);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SettingsEvent.statistic()';
}


}




/// @nodoc
mixin _$SettingsState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SettingsState()';
}


}

/// @nodoc
class $SettingsStateCopyWith<$Res>  {
$SettingsStateCopyWith(SettingsState _, $Res Function(SettingsState) __);
}


/// Adds pattern-matching-related methods to [SettingsState].
extension SettingsStatePatterns on SettingsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Initial value)?  initial,TResult Function( LoadingSettings value)?  loadingSettings,TResult Function( StatisticSuccess value)?  statisticSuccess,TResult Function( ErrorSettings value)?  errorSettings,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial(_that);case LoadingSettings() when loadingSettings != null:
return loadingSettings(_that);case StatisticSuccess() when statisticSuccess != null:
return statisticSuccess(_that);case ErrorSettings() when errorSettings != null:
return errorSettings(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Initial value)  initial,required TResult Function( LoadingSettings value)  loadingSettings,required TResult Function( StatisticSuccess value)  statisticSuccess,required TResult Function( ErrorSettings value)  errorSettings,}){
final _that = this;
switch (_that) {
case Initial():
return initial(_that);case LoadingSettings():
return loadingSettings(_that);case StatisticSuccess():
return statisticSuccess(_that);case ErrorSettings():
return errorSettings(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Initial value)?  initial,TResult? Function( LoadingSettings value)?  loadingSettings,TResult? Function( StatisticSuccess value)?  statisticSuccess,TResult? Function( ErrorSettings value)?  errorSettings,}){
final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial(_that);case LoadingSettings() when loadingSettings != null:
return loadingSettings(_that);case StatisticSuccess() when statisticSuccess != null:
return statisticSuccess(_that);case ErrorSettings() when errorSettings != null:
return errorSettings(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loadingSettings,TResult Function( StatisticResponseModel statistic)?  statisticSuccess,TResult Function( String error)?  errorSettings,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial();case LoadingSettings() when loadingSettings != null:
return loadingSettings();case StatisticSuccess() when statisticSuccess != null:
return statisticSuccess(_that.statistic);case ErrorSettings() when errorSettings != null:
return errorSettings(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loadingSettings,required TResult Function( StatisticResponseModel statistic)  statisticSuccess,required TResult Function( String error)  errorSettings,}) {final _that = this;
switch (_that) {
case Initial():
return initial();case LoadingSettings():
return loadingSettings();case StatisticSuccess():
return statisticSuccess(_that.statistic);case ErrorSettings():
return errorSettings(_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loadingSettings,TResult? Function( StatisticResponseModel statistic)?  statisticSuccess,TResult? Function( String error)?  errorSettings,}) {final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial();case LoadingSettings() when loadingSettings != null:
return loadingSettings();case StatisticSuccess() when statisticSuccess != null:
return statisticSuccess(_that.statistic);case ErrorSettings() when errorSettings != null:
return errorSettings(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class Initial implements SettingsState {
  const Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SettingsState.initial()';
}


}




/// @nodoc


class LoadingSettings implements SettingsState {
  const LoadingSettings();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadingSettings);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SettingsState.loadingSettings()';
}


}




/// @nodoc


class StatisticSuccess implements SettingsState {
  const StatisticSuccess(this.statistic);
  

 final  StatisticResponseModel statistic;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatisticSuccessCopyWith<StatisticSuccess> get copyWith => _$StatisticSuccessCopyWithImpl<StatisticSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatisticSuccess&&(identical(other.statistic, statistic) || other.statistic == statistic));
}


@override
int get hashCode => Object.hash(runtimeType,statistic);

@override
String toString() {
  return 'SettingsState.statisticSuccess(statistic: $statistic)';
}


}

/// @nodoc
abstract mixin class $StatisticSuccessCopyWith<$Res> implements $SettingsStateCopyWith<$Res> {
  factory $StatisticSuccessCopyWith(StatisticSuccess value, $Res Function(StatisticSuccess) _then) = _$StatisticSuccessCopyWithImpl;
@useResult
$Res call({
 StatisticResponseModel statistic
});




}
/// @nodoc
class _$StatisticSuccessCopyWithImpl<$Res>
    implements $StatisticSuccessCopyWith<$Res> {
  _$StatisticSuccessCopyWithImpl(this._self, this._then);

  final StatisticSuccess _self;
  final $Res Function(StatisticSuccess) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? statistic = null,}) {
  return _then(StatisticSuccess(
null == statistic ? _self.statistic : statistic // ignore: cast_nullable_to_non_nullable
as StatisticResponseModel,
  ));
}


}

/// @nodoc


class ErrorSettings implements SettingsState {
  const ErrorSettings(this.error);
  

 final  String error;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ErrorSettingsCopyWith<ErrorSettings> get copyWith => _$ErrorSettingsCopyWithImpl<ErrorSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ErrorSettings&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'SettingsState.errorSettings(error: $error)';
}


}

/// @nodoc
abstract mixin class $ErrorSettingsCopyWith<$Res> implements $SettingsStateCopyWith<$Res> {
  factory $ErrorSettingsCopyWith(ErrorSettings value, $Res Function(ErrorSettings) _then) = _$ErrorSettingsCopyWithImpl;
@useResult
$Res call({
 String error
});




}
/// @nodoc
class _$ErrorSettingsCopyWithImpl<$Res>
    implements $ErrorSettingsCopyWith<$Res> {
  _$ErrorSettingsCopyWithImpl(this._self, this._then);

  final ErrorSettings _self;
  final $Res Function(ErrorSettings) _then;

/// Create a copy of SettingsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(ErrorSettings(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
