// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BudgetAllowance {

 TransactionCategory get category; String get description; int get limit; int get spent; bool get settled; bool get fixed; int? get projectedAdditional;
/// Create a copy of BudgetAllowance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetAllowanceCopyWith<BudgetAllowance> get copyWith => _$BudgetAllowanceCopyWithImpl<BudgetAllowance>(this as BudgetAllowance, _$identity);

  /// Serializes this BudgetAllowance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BudgetAllowance;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetAllowance&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.limit, _this.limit) || other.limit == _this.limit)&&(identical(other.spent, _this.spent) || other.spent == _this.spent)&&(identical(other.settled, _this.settled) || other.settled == _this.settled)&&(identical(other.fixed, _this.fixed) || other.fixed == _this.fixed)&&(identical(other.projectedAdditional, _this.projectedAdditional) || other.projectedAdditional == _this.projectedAdditional));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BudgetAllowance;
  return Object.hash(runtimeType,_this.category,_this.description,_this.limit,_this.spent,_this.settled,_this.fixed,_this.projectedAdditional);
}

@override
String toString() {
  final _this = this as BudgetAllowance;
  return 'BudgetAllowance(category: ${_this.category}, description: ${_this.description}, limit: ${_this.limit}, spent: ${_this.spent}, settled: ${_this.settled}, fixed: ${_this.fixed}, projectedAdditional: ${_this.projectedAdditional})';
}


}

/// @nodoc
abstract mixin class $BudgetAllowanceCopyWith<$Res>  {
  factory $BudgetAllowanceCopyWith(BudgetAllowance value, $Res Function(BudgetAllowance) _then) = _$BudgetAllowanceCopyWithImpl;
@useResult
$Res call({
 TransactionCategory category, String description, int limit, int spent, bool settled, bool fixed, int? projectedAdditional
});




}
/// @nodoc
class _$BudgetAllowanceCopyWithImpl<$Res>
    implements $BudgetAllowanceCopyWith<$Res> {
  _$BudgetAllowanceCopyWithImpl(this._self, this._then);

  final BudgetAllowance _self;
  final $Res Function(BudgetAllowance) _then;

/// Create a copy of BudgetAllowance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? description = null,Object? limit = null,Object? spent = null,Object? settled = null,Object? fixed = null,Object? projectedAdditional = freezed,}) {
  return _then(BudgetAllowance(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as TransactionCategory,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,spent: null == spent ? _self.spent : spent // ignore: cast_nullable_to_non_nullable
as int,settled: null == settled ? _self.settled : settled // ignore: cast_nullable_to_non_nullable
as bool,fixed: null == fixed ? _self.fixed : fixed // ignore: cast_nullable_to_non_nullable
as bool,projectedAdditional: freezed == projectedAdditional ? _self.projectedAdditional : projectedAdditional // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetAllowance].
extension BudgetAllowancePatterns on BudgetAllowance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetAllowance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetAllowance() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetAllowance value)  $default,){
final _that = this;
switch (_that) {
case _BudgetAllowance():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetAllowance value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetAllowance() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TransactionCategory category,  String description,  int limit,  int spent,  bool settled,  bool fixed,  int? projectedAdditional)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetAllowance() when $default != null:
return $default(_that.category,_that.description,_that.limit,_that.spent,_that.settled,_that.fixed,_that.projectedAdditional);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TransactionCategory category,  String description,  int limit,  int spent,  bool settled,  bool fixed,  int? projectedAdditional)  $default,) {final _that = this;
switch (_that) {
case _BudgetAllowance():
return $default(_that.category,_that.description,_that.limit,_that.spent,_that.settled,_that.fixed,_that.projectedAdditional);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TransactionCategory category,  String description,  int limit,  int spent,  bool settled,  bool fixed,  int? projectedAdditional)?  $default,) {final _that = this;
switch (_that) {
case _BudgetAllowance() when $default != null:
return $default(_that.category,_that.description,_that.limit,_that.spent,_that.settled,_that.fixed,_that.projectedAdditional);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BudgetAllowance extends BudgetAllowance {
  const _BudgetAllowance({required this.category, required this.description, required this.limit, this.spent = 0, this.settled = false, this.fixed = false, this.projectedAdditional}): super._();
  factory _BudgetAllowance.fromJson(Map<String, dynamic> json) => _$BudgetAllowanceFromJson(json);

@override final  TransactionCategory category;
@override final  String description;
@override final  int limit;
@override@JsonKey() final  int spent;
@override@JsonKey() final  bool settled;
@override@JsonKey() final  bool fixed;
@override final  int? projectedAdditional;

/// Create a copy of BudgetAllowance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetAllowanceCopyWith<_BudgetAllowance> get copyWith => __$BudgetAllowanceCopyWithImpl<_BudgetAllowance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BudgetAllowanceToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetAllowance&&(identical(other.category, category) || other.category == category)&&(identical(other.description, description) || other.description == description)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.spent, spent) || other.spent == spent)&&(identical(other.settled, settled) || other.settled == settled)&&(identical(other.fixed, fixed) || other.fixed == fixed)&&(identical(other.projectedAdditional, projectedAdditional) || other.projectedAdditional == projectedAdditional));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,category,description,limit,spent,settled,fixed,projectedAdditional);
}

@override
String toString() {
    return 'BudgetAllowance(category: $category, description: $description, limit: $limit, spent: $spent, settled: $settled, fixed: $fixed, projectedAdditional: $projectedAdditional)';
}


}

/// @nodoc
abstract mixin class _$BudgetAllowanceCopyWith<$Res> implements $BudgetAllowanceCopyWith<$Res> {
  factory _$BudgetAllowanceCopyWith(_BudgetAllowance value, $Res Function(_BudgetAllowance) _then) = __$BudgetAllowanceCopyWithImpl;
@override @useResult
$Res call({
 TransactionCategory category, String description, int limit, int spent, bool settled, bool fixed, int? projectedAdditional
});




}
/// @nodoc
class __$BudgetAllowanceCopyWithImpl<$Res>
    implements _$BudgetAllowanceCopyWith<$Res> {
  __$BudgetAllowanceCopyWithImpl(this._self, this._then);

  final _BudgetAllowance _self;
  final $Res Function(_BudgetAllowance) _then;

/// Create a copy of BudgetAllowance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? description = null,Object? limit = null,Object? spent = null,Object? settled = null,Object? fixed = null,Object? projectedAdditional = freezed,}) {
  return _then(_BudgetAllowance(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as TransactionCategory,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,spent: null == spent ? _self.spent : spent // ignore: cast_nullable_to_non_nullable
as int,settled: null == settled ? _self.settled : settled // ignore: cast_nullable_to_non_nullable
as bool,fixed: null == fixed ? _self.fixed : fixed // ignore: cast_nullable_to_non_nullable
as bool,projectedAdditional: freezed == projectedAdditional ? _self.projectedAdditional : projectedAdditional // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$BudgetPlan {

 int get year; int get month; int get monthlyLimit; List<BudgetAllowance> get allowances; List<TransactionCategory> get editedCategories; int get spent; int? get projectedAdditional;
/// Create a copy of BudgetPlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetPlanCopyWith<BudgetPlan> get copyWith => _$BudgetPlanCopyWithImpl<BudgetPlan>(this as BudgetPlan, _$identity);

  /// Serializes this BudgetPlan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BudgetPlan;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetPlan&&(identical(other.year, _this.year) || other.year == _this.year)&&(identical(other.month, _this.month) || other.month == _this.month)&&(identical(other.monthlyLimit, _this.monthlyLimit) || other.monthlyLimit == _this.monthlyLimit)&&const DeepCollectionEquality().equals(other.allowances, _this.allowances)&&const DeepCollectionEquality().equals(other.editedCategories, _this.editedCategories)&&(identical(other.spent, _this.spent) || other.spent == _this.spent)&&(identical(other.projectedAdditional, _this.projectedAdditional) || other.projectedAdditional == _this.projectedAdditional));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BudgetPlan;
  return Object.hash(runtimeType,_this.year,_this.month,_this.monthlyLimit,const DeepCollectionEquality().hash(_this.allowances),const DeepCollectionEquality().hash(_this.editedCategories),_this.spent,_this.projectedAdditional);
}

@override
String toString() {
  final _this = this as BudgetPlan;
  return 'BudgetPlan(year: ${_this.year}, month: ${_this.month}, monthlyLimit: ${_this.monthlyLimit}, allowances: ${_this.allowances}, editedCategories: ${_this.editedCategories}, spent: ${_this.spent}, projectedAdditional: ${_this.projectedAdditional})';
}


}

/// @nodoc
abstract mixin class $BudgetPlanCopyWith<$Res>  {
  factory $BudgetPlanCopyWith(BudgetPlan value, $Res Function(BudgetPlan) _then) = _$BudgetPlanCopyWithImpl;
@useResult
$Res call({
 int year, int month, int monthlyLimit, List<BudgetAllowance> allowances, List<TransactionCategory> editedCategories, int spent, int? projectedAdditional
});




}
/// @nodoc
class _$BudgetPlanCopyWithImpl<$Res>
    implements $BudgetPlanCopyWith<$Res> {
  _$BudgetPlanCopyWithImpl(this._self, this._then);

  final BudgetPlan _self;
  final $Res Function(BudgetPlan) _then;

/// Create a copy of BudgetPlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? year = null,Object? month = null,Object? monthlyLimit = null,Object? allowances = null,Object? editedCategories = null,Object? spent = null,Object? projectedAdditional = freezed,}) {
  return _then(BudgetPlan(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,monthlyLimit: null == monthlyLimit ? _self.monthlyLimit : monthlyLimit // ignore: cast_nullable_to_non_nullable
as int,allowances: null == allowances ? _self.allowances : allowances // ignore: cast_nullable_to_non_nullable
as List<BudgetAllowance>,editedCategories: null == editedCategories ? _self.editedCategories : editedCategories // ignore: cast_nullable_to_non_nullable
as List<TransactionCategory>,spent: null == spent ? _self.spent : spent // ignore: cast_nullable_to_non_nullable
as int,projectedAdditional: freezed == projectedAdditional ? _self.projectedAdditional : projectedAdditional // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetPlan].
extension BudgetPlanPatterns on BudgetPlan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetPlan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetPlan() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetPlan value)  $default,){
final _that = this;
switch (_that) {
case _BudgetPlan():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetPlan value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetPlan() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int year,  int month,  int monthlyLimit,  List<BudgetAllowance> allowances,  List<TransactionCategory> editedCategories,  int spent,  int? projectedAdditional)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetPlan() when $default != null:
return $default(_that.year,_that.month,_that.monthlyLimit,_that.allowances,_that.editedCategories,_that.spent,_that.projectedAdditional);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int year,  int month,  int monthlyLimit,  List<BudgetAllowance> allowances,  List<TransactionCategory> editedCategories,  int spent,  int? projectedAdditional)  $default,) {final _that = this;
switch (_that) {
case _BudgetPlan():
return $default(_that.year,_that.month,_that.monthlyLimit,_that.allowances,_that.editedCategories,_that.spent,_that.projectedAdditional);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int year,  int month,  int monthlyLimit,  List<BudgetAllowance> allowances,  List<TransactionCategory> editedCategories,  int spent,  int? projectedAdditional)?  $default,) {final _that = this;
switch (_that) {
case _BudgetPlan() when $default != null:
return $default(_that.year,_that.month,_that.monthlyLimit,_that.allowances,_that.editedCategories,_that.spent,_that.projectedAdditional);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BudgetPlan extends BudgetPlan {
  const _BudgetPlan({required this.year, required this.month, required this.monthlyLimit, required  List<BudgetAllowance> allowances,  List<TransactionCategory> editedCategories = const [], this.spent = 0, this.projectedAdditional}): _allowances = allowances,_editedCategories = editedCategories,super._();
  factory _BudgetPlan.fromJson(Map<String, dynamic> json) => _$BudgetPlanFromJson(json);

@override final  int year;
@override final  int month;
@override final  int monthlyLimit;
 final  List<BudgetAllowance> _allowances;
@override List<BudgetAllowance> get allowances {
  if (_allowances is EqualUnmodifiableListView) return _allowances;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allowances);
}

 final  List<TransactionCategory> _editedCategories;
@override@JsonKey() List<TransactionCategory> get editedCategories {
  if (_editedCategories is EqualUnmodifiableListView) return _editedCategories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_editedCategories);
}

@override@JsonKey() final  int spent;
@override final  int? projectedAdditional;

/// Create a copy of BudgetPlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetPlanCopyWith<_BudgetPlan> get copyWith => __$BudgetPlanCopyWithImpl<_BudgetPlan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BudgetPlanToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetPlan&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month)&&(identical(other.monthlyLimit, monthlyLimit) || other.monthlyLimit == monthlyLimit)&&const DeepCollectionEquality().equals(other.allowances, _allowances)&&const DeepCollectionEquality().equals(other.editedCategories, _editedCategories)&&(identical(other.spent, spent) || other.spent == spent)&&(identical(other.projectedAdditional, projectedAdditional) || other.projectedAdditional == projectedAdditional));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,year,month,monthlyLimit,const DeepCollectionEquality().hash(_allowances),const DeepCollectionEquality().hash(_editedCategories),spent,projectedAdditional);
}

@override
String toString() {
    return 'BudgetPlan(year: $year, month: $month, monthlyLimit: $monthlyLimit, allowances: $allowances, editedCategories: $editedCategories, spent: $spent, projectedAdditional: $projectedAdditional)';
}


}

/// @nodoc
abstract mixin class _$BudgetPlanCopyWith<$Res> implements $BudgetPlanCopyWith<$Res> {
  factory _$BudgetPlanCopyWith(_BudgetPlan value, $Res Function(_BudgetPlan) _then) = __$BudgetPlanCopyWithImpl;
@override @useResult
$Res call({
 int year, int month, int monthlyLimit, List<BudgetAllowance> allowances, List<TransactionCategory> editedCategories, int spent, int? projectedAdditional
});




}
/// @nodoc
class __$BudgetPlanCopyWithImpl<$Res>
    implements _$BudgetPlanCopyWith<$Res> {
  __$BudgetPlanCopyWithImpl(this._self, this._then);

  final _BudgetPlan _self;
  final $Res Function(_BudgetPlan) _then;

/// Create a copy of BudgetPlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? year = null,Object? month = null,Object? monthlyLimit = null,Object? allowances = null,Object? editedCategories = null,Object? spent = null,Object? projectedAdditional = freezed,}) {
  return _then(_BudgetPlan(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,monthlyLimit: null == monthlyLimit ? _self.monthlyLimit : monthlyLimit // ignore: cast_nullable_to_non_nullable
as int,allowances: null == allowances ? _self._allowances : allowances // ignore: cast_nullable_to_non_nullable
as List<BudgetAllowance>,editedCategories: null == editedCategories ? _self._editedCategories : editedCategories // ignore: cast_nullable_to_non_nullable
as List<TransactionCategory>,spent: null == spent ? _self.spent : spent // ignore: cast_nullable_to_non_nullable
as int,projectedAdditional: freezed == projectedAdditional ? _self.projectedAdditional : projectedAdditional // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
