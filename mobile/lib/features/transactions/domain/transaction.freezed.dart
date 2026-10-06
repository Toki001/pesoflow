// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TransactionRecord {

 String get id; String get merchant; String get metadata; int get amount; DateTime get occurredAt; TransactionKind get kind; TransactionCategory get category; String get account; TransactionStatus get status; TransactionSource get source; String get note; bool get hasReceipt; bool get recurring; bool get excludedFromBudget; List<String> get tags;
/// Create a copy of TransactionRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionRecordCopyWith<TransactionRecord> get copyWith => _$TransactionRecordCopyWithImpl<TransactionRecord>(this as TransactionRecord, _$identity);

  /// Serializes this TransactionRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TransactionRecord;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionRecord&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.merchant, _this.merchant) || other.merchant == _this.merchant)&&(identical(other.metadata, _this.metadata) || other.metadata == _this.metadata)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.occurredAt, _this.occurredAt) || other.occurredAt == _this.occurredAt)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.account, _this.account) || other.account == _this.account)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.hasReceipt, _this.hasReceipt) || other.hasReceipt == _this.hasReceipt)&&(identical(other.recurring, _this.recurring) || other.recurring == _this.recurring)&&(identical(other.excludedFromBudget, _this.excludedFromBudget) || other.excludedFromBudget == _this.excludedFromBudget)&&const DeepCollectionEquality().equals(other.tags, _this.tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TransactionRecord;
  return Object.hash(runtimeType,_this.id,_this.merchant,_this.metadata,_this.amount,_this.occurredAt,_this.kind,_this.category,_this.account,_this.status,_this.source,_this.note,_this.hasReceipt,_this.recurring,_this.excludedFromBudget,const DeepCollectionEquality().hash(_this.tags));
}

@override
String toString() {
  final _this = this as TransactionRecord;
  return 'TransactionRecord(id: ${_this.id}, merchant: ${_this.merchant}, metadata: ${_this.metadata}, amount: ${_this.amount}, occurredAt: ${_this.occurredAt}, kind: ${_this.kind}, category: ${_this.category}, account: ${_this.account}, status: ${_this.status}, source: ${_this.source}, note: ${_this.note}, hasReceipt: ${_this.hasReceipt}, recurring: ${_this.recurring}, excludedFromBudget: ${_this.excludedFromBudget}, tags: ${_this.tags})';
}


}

/// @nodoc
abstract mixin class $TransactionRecordCopyWith<$Res>  {
  factory $TransactionRecordCopyWith(TransactionRecord value, $Res Function(TransactionRecord) _then) = _$TransactionRecordCopyWithImpl;
@useResult
$Res call({
 String id, String merchant, String metadata, int amount, DateTime occurredAt, TransactionKind kind, TransactionCategory category, String account, TransactionStatus status, TransactionSource source, String note, bool hasReceipt, bool recurring, bool excludedFromBudget, List<String> tags
});




}
/// @nodoc
class _$TransactionRecordCopyWithImpl<$Res>
    implements $TransactionRecordCopyWith<$Res> {
  _$TransactionRecordCopyWithImpl(this._self, this._then);

  final TransactionRecord _self;
  final $Res Function(TransactionRecord) _then;

/// Create a copy of TransactionRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? merchant = null,Object? metadata = null,Object? amount = null,Object? occurredAt = null,Object? kind = null,Object? category = null,Object? account = null,Object? status = null,Object? source = null,Object? note = null,Object? hasReceipt = null,Object? recurring = null,Object? excludedFromBudget = null,Object? tags = null,}) {
  return _then(TransactionRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,merchant: null == merchant ? _self.merchant : merchant // ignore: cast_nullable_to_non_nullable
as String,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as TransactionKind,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as TransactionCategory,account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransactionStatus,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as TransactionSource,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,hasReceipt: null == hasReceipt ? _self.hasReceipt : hasReceipt // ignore: cast_nullable_to_non_nullable
as bool,recurring: null == recurring ? _self.recurring : recurring // ignore: cast_nullable_to_non_nullable
as bool,excludedFromBudget: null == excludedFromBudget ? _self.excludedFromBudget : excludedFromBudget // ignore: cast_nullable_to_non_nullable
as bool,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionRecord].
extension TransactionRecordPatterns on TransactionRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionRecord value)  $default,){
final _that = this;
switch (_that) {
case _TransactionRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionRecord value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String merchant,  String metadata,  int amount,  DateTime occurredAt,  TransactionKind kind,  TransactionCategory category,  String account,  TransactionStatus status,  TransactionSource source,  String note,  bool hasReceipt,  bool recurring,  bool excludedFromBudget,  List<String> tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionRecord() when $default != null:
return $default(_that.id,_that.merchant,_that.metadata,_that.amount,_that.occurredAt,_that.kind,_that.category,_that.account,_that.status,_that.source,_that.note,_that.hasReceipt,_that.recurring,_that.excludedFromBudget,_that.tags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String merchant,  String metadata,  int amount,  DateTime occurredAt,  TransactionKind kind,  TransactionCategory category,  String account,  TransactionStatus status,  TransactionSource source,  String note,  bool hasReceipt,  bool recurring,  bool excludedFromBudget,  List<String> tags)  $default,) {final _that = this;
switch (_that) {
case _TransactionRecord():
return $default(_that.id,_that.merchant,_that.metadata,_that.amount,_that.occurredAt,_that.kind,_that.category,_that.account,_that.status,_that.source,_that.note,_that.hasReceipt,_that.recurring,_that.excludedFromBudget,_that.tags);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String merchant,  String metadata,  int amount,  DateTime occurredAt,  TransactionKind kind,  TransactionCategory category,  String account,  TransactionStatus status,  TransactionSource source,  String note,  bool hasReceipt,  bool recurring,  bool excludedFromBudget,  List<String> tags)?  $default,) {final _that = this;
switch (_that) {
case _TransactionRecord() when $default != null:
return $default(_that.id,_that.merchant,_that.metadata,_that.amount,_that.occurredAt,_that.kind,_that.category,_that.account,_that.status,_that.source,_that.note,_that.hasReceipt,_that.recurring,_that.excludedFromBudget,_that.tags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransactionRecord extends TransactionRecord {
  const _TransactionRecord({required this.id, required this.merchant, required this.metadata, required this.amount, required this.occurredAt, required this.kind, required this.category, this.account = 'GCash', this.status = TransactionStatus.posted, this.source = TransactionSource.manual, this.note = '', this.hasReceipt = false, this.recurring = false, this.excludedFromBudget = false,  List<String> tags = const []}): _tags = tags,super._();
  factory _TransactionRecord.fromJson(Map<String, dynamic> json) => _$TransactionRecordFromJson(json);

@override final  String id;
@override final  String merchant;
@override final  String metadata;
@override final  int amount;
@override final  DateTime occurredAt;
@override final  TransactionKind kind;
@override final  TransactionCategory category;
@override@JsonKey() final  String account;
@override@JsonKey() final  TransactionStatus status;
@override@JsonKey() final  TransactionSource source;
@override@JsonKey() final  String note;
@override@JsonKey() final  bool hasReceipt;
@override@JsonKey() final  bool recurring;
@override@JsonKey() final  bool excludedFromBudget;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}


/// Create a copy of TransactionRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionRecordCopyWith<_TransactionRecord> get copyWith => __$TransactionRecordCopyWithImpl<_TransactionRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionRecordToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.merchant, merchant) || other.merchant == merchant)&&(identical(other.metadata, metadata) || other.metadata == metadata)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.category, category) || other.category == category)&&(identical(other.account, account) || other.account == account)&&(identical(other.status, status) || other.status == status)&&(identical(other.source, source) || other.source == source)&&(identical(other.note, note) || other.note == note)&&(identical(other.hasReceipt, hasReceipt) || other.hasReceipt == hasReceipt)&&(identical(other.recurring, recurring) || other.recurring == recurring)&&(identical(other.excludedFromBudget, excludedFromBudget) || other.excludedFromBudget == excludedFromBudget)&&const DeepCollectionEquality().equals(other.tags, _tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,merchant,metadata,amount,occurredAt,kind,category,account,status,source,note,hasReceipt,recurring,excludedFromBudget,const DeepCollectionEquality().hash(_tags));
}

@override
String toString() {
    return 'TransactionRecord(id: $id, merchant: $merchant, metadata: $metadata, amount: $amount, occurredAt: $occurredAt, kind: $kind, category: $category, account: $account, status: $status, source: $source, note: $note, hasReceipt: $hasReceipt, recurring: $recurring, excludedFromBudget: $excludedFromBudget, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$TransactionRecordCopyWith<$Res> implements $TransactionRecordCopyWith<$Res> {
  factory _$TransactionRecordCopyWith(_TransactionRecord value, $Res Function(_TransactionRecord) _then) = __$TransactionRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, String merchant, String metadata, int amount, DateTime occurredAt, TransactionKind kind, TransactionCategory category, String account, TransactionStatus status, TransactionSource source, String note, bool hasReceipt, bool recurring, bool excludedFromBudget, List<String> tags
});




}
/// @nodoc
class __$TransactionRecordCopyWithImpl<$Res>
    implements _$TransactionRecordCopyWith<$Res> {
  __$TransactionRecordCopyWithImpl(this._self, this._then);

  final _TransactionRecord _self;
  final $Res Function(_TransactionRecord) _then;

/// Create a copy of TransactionRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? merchant = null,Object? metadata = null,Object? amount = null,Object? occurredAt = null,Object? kind = null,Object? category = null,Object? account = null,Object? status = null,Object? source = null,Object? note = null,Object? hasReceipt = null,Object? recurring = null,Object? excludedFromBudget = null,Object? tags = null,}) {
  return _then(_TransactionRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,merchant: null == merchant ? _self.merchant : merchant // ignore: cast_nullable_to_non_nullable
as String,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as TransactionKind,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as TransactionCategory,account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransactionStatus,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as TransactionSource,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,hasReceipt: null == hasReceipt ? _self.hasReceipt : hasReceipt // ignore: cast_nullable_to_non_nullable
as bool,recurring: null == recurring ? _self.recurring : recurring // ignore: cast_nullable_to_non_nullable
as bool,excludedFromBudget: null == excludedFromBudget ? _self.excludedFromBudget : excludedFromBudget // ignore: cast_nullable_to_non_nullable
as bool,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
