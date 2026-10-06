// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Dashboard {

 String get name; DateTime get asOf; int get balance; int get monthChange; String get monthChangePercent; int get inflow; int get outflow; int get savings; String get savingsRate; int get transactionCount; int get accountCount; int get budgetLimit; int? get budgetSpent; int get daysLeft; int get projectedExtraSavings; List<BudgetSnapshot> get budgets; List<TransactionRecord> get transactions; List<UpcomingBill> get bills;
/// Create a copy of Dashboard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardCopyWith<Dashboard> get copyWith => _$DashboardCopyWithImpl<Dashboard>(this as Dashboard, _$identity);

  /// Serializes this Dashboard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Dashboard;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Dashboard&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.asOf, _this.asOf) || other.asOf == _this.asOf)&&(identical(other.balance, _this.balance) || other.balance == _this.balance)&&(identical(other.monthChange, _this.monthChange) || other.monthChange == _this.monthChange)&&(identical(other.monthChangePercent, _this.monthChangePercent) || other.monthChangePercent == _this.monthChangePercent)&&(identical(other.inflow, _this.inflow) || other.inflow == _this.inflow)&&(identical(other.outflow, _this.outflow) || other.outflow == _this.outflow)&&(identical(other.savings, _this.savings) || other.savings == _this.savings)&&(identical(other.savingsRate, _this.savingsRate) || other.savingsRate == _this.savingsRate)&&(identical(other.transactionCount, _this.transactionCount) || other.transactionCount == _this.transactionCount)&&(identical(other.accountCount, _this.accountCount) || other.accountCount == _this.accountCount)&&(identical(other.budgetLimit, _this.budgetLimit) || other.budgetLimit == _this.budgetLimit)&&(identical(other.budgetSpent, _this.budgetSpent) || other.budgetSpent == _this.budgetSpent)&&(identical(other.daysLeft, _this.daysLeft) || other.daysLeft == _this.daysLeft)&&(identical(other.projectedExtraSavings, _this.projectedExtraSavings) || other.projectedExtraSavings == _this.projectedExtraSavings)&&const DeepCollectionEquality().equals(other.budgets, _this.budgets)&&const DeepCollectionEquality().equals(other.transactions, _this.transactions)&&const DeepCollectionEquality().equals(other.bills, _this.bills));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Dashboard;
  return Object.hash(runtimeType,_this.name,_this.asOf,_this.balance,_this.monthChange,_this.monthChangePercent,_this.inflow,_this.outflow,_this.savings,_this.savingsRate,_this.transactionCount,_this.accountCount,_this.budgetLimit,_this.budgetSpent,_this.daysLeft,_this.projectedExtraSavings,const DeepCollectionEquality().hash(_this.budgets),const DeepCollectionEquality().hash(_this.transactions),const DeepCollectionEquality().hash(_this.bills));
}

@override
String toString() {
  final _this = this as Dashboard;
  return 'Dashboard(name: ${_this.name}, asOf: ${_this.asOf}, balance: ${_this.balance}, monthChange: ${_this.monthChange}, monthChangePercent: ${_this.monthChangePercent}, inflow: ${_this.inflow}, outflow: ${_this.outflow}, savings: ${_this.savings}, savingsRate: ${_this.savingsRate}, transactionCount: ${_this.transactionCount}, accountCount: ${_this.accountCount}, budgetLimit: ${_this.budgetLimit}, budgetSpent: ${_this.budgetSpent}, daysLeft: ${_this.daysLeft}, projectedExtraSavings: ${_this.projectedExtraSavings}, budgets: ${_this.budgets}, transactions: ${_this.transactions}, bills: ${_this.bills})';
}


}

/// @nodoc
abstract mixin class $DashboardCopyWith<$Res>  {
  factory $DashboardCopyWith(Dashboard value, $Res Function(Dashboard) _then) = _$DashboardCopyWithImpl;
@useResult
$Res call({
 String name, DateTime asOf, int balance, int monthChange, String monthChangePercent, int inflow, int outflow, int savings, String savingsRate, int transactionCount, int accountCount, int budgetLimit, int? budgetSpent, int daysLeft, int projectedExtraSavings, List<BudgetSnapshot> budgets, List<TransactionRecord> transactions, List<UpcomingBill> bills
});




}
/// @nodoc
class _$DashboardCopyWithImpl<$Res>
    implements $DashboardCopyWith<$Res> {
  _$DashboardCopyWithImpl(this._self, this._then);

  final Dashboard _self;
  final $Res Function(Dashboard) _then;

/// Create a copy of Dashboard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? asOf = null,Object? balance = null,Object? monthChange = null,Object? monthChangePercent = null,Object? inflow = null,Object? outflow = null,Object? savings = null,Object? savingsRate = null,Object? transactionCount = null,Object? accountCount = null,Object? budgetLimit = null,Object? budgetSpent = freezed,Object? daysLeft = null,Object? projectedExtraSavings = null,Object? budgets = null,Object? transactions = null,Object? bills = null,}) {
  return _then(Dashboard(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,asOf: null == asOf ? _self.asOf : asOf // ignore: cast_nullable_to_non_nullable
as DateTime,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as int,monthChange: null == monthChange ? _self.monthChange : monthChange // ignore: cast_nullable_to_non_nullable
as int,monthChangePercent: null == monthChangePercent ? _self.monthChangePercent : monthChangePercent // ignore: cast_nullable_to_non_nullable
as String,inflow: null == inflow ? _self.inflow : inflow // ignore: cast_nullable_to_non_nullable
as int,outflow: null == outflow ? _self.outflow : outflow // ignore: cast_nullable_to_non_nullable
as int,savings: null == savings ? _self.savings : savings // ignore: cast_nullable_to_non_nullable
as int,savingsRate: null == savingsRate ? _self.savingsRate : savingsRate // ignore: cast_nullable_to_non_nullable
as String,transactionCount: null == transactionCount ? _self.transactionCount : transactionCount // ignore: cast_nullable_to_non_nullable
as int,accountCount: null == accountCount ? _self.accountCount : accountCount // ignore: cast_nullable_to_non_nullable
as int,budgetLimit: null == budgetLimit ? _self.budgetLimit : budgetLimit // ignore: cast_nullable_to_non_nullable
as int,budgetSpent: freezed == budgetSpent ? _self.budgetSpent : budgetSpent // ignore: cast_nullable_to_non_nullable
as int?,daysLeft: null == daysLeft ? _self.daysLeft : daysLeft // ignore: cast_nullable_to_non_nullable
as int,projectedExtraSavings: null == projectedExtraSavings ? _self.projectedExtraSavings : projectedExtraSavings // ignore: cast_nullable_to_non_nullable
as int,budgets: null == budgets ? _self.budgets : budgets // ignore: cast_nullable_to_non_nullable
as List<BudgetSnapshot>,transactions: null == transactions ? _self.transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<TransactionRecord>,bills: null == bills ? _self.bills : bills // ignore: cast_nullable_to_non_nullable
as List<UpcomingBill>,
  ));
}

}


/// Adds pattern-matching-related methods to [Dashboard].
extension DashboardPatterns on Dashboard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Dashboard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Dashboard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Dashboard value)  $default,){
final _that = this;
switch (_that) {
case _Dashboard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Dashboard value)?  $default,){
final _that = this;
switch (_that) {
case _Dashboard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  DateTime asOf,  int balance,  int monthChange,  String monthChangePercent,  int inflow,  int outflow,  int savings,  String savingsRate,  int transactionCount,  int accountCount,  int budgetLimit,  int? budgetSpent,  int daysLeft,  int projectedExtraSavings,  List<BudgetSnapshot> budgets,  List<TransactionRecord> transactions,  List<UpcomingBill> bills)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Dashboard() when $default != null:
return $default(_that.name,_that.asOf,_that.balance,_that.monthChange,_that.monthChangePercent,_that.inflow,_that.outflow,_that.savings,_that.savingsRate,_that.transactionCount,_that.accountCount,_that.budgetLimit,_that.budgetSpent,_that.daysLeft,_that.projectedExtraSavings,_that.budgets,_that.transactions,_that.bills);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  DateTime asOf,  int balance,  int monthChange,  String monthChangePercent,  int inflow,  int outflow,  int savings,  String savingsRate,  int transactionCount,  int accountCount,  int budgetLimit,  int? budgetSpent,  int daysLeft,  int projectedExtraSavings,  List<BudgetSnapshot> budgets,  List<TransactionRecord> transactions,  List<UpcomingBill> bills)  $default,) {final _that = this;
switch (_that) {
case _Dashboard():
return $default(_that.name,_that.asOf,_that.balance,_that.monthChange,_that.monthChangePercent,_that.inflow,_that.outflow,_that.savings,_that.savingsRate,_that.transactionCount,_that.accountCount,_that.budgetLimit,_that.budgetSpent,_that.daysLeft,_that.projectedExtraSavings,_that.budgets,_that.transactions,_that.bills);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  DateTime asOf,  int balance,  int monthChange,  String monthChangePercent,  int inflow,  int outflow,  int savings,  String savingsRate,  int transactionCount,  int accountCount,  int budgetLimit,  int? budgetSpent,  int daysLeft,  int projectedExtraSavings,  List<BudgetSnapshot> budgets,  List<TransactionRecord> transactions,  List<UpcomingBill> bills)?  $default,) {final _that = this;
switch (_that) {
case _Dashboard() when $default != null:
return $default(_that.name,_that.asOf,_that.balance,_that.monthChange,_that.monthChangePercent,_that.inflow,_that.outflow,_that.savings,_that.savingsRate,_that.transactionCount,_that.accountCount,_that.budgetLimit,_that.budgetSpent,_that.daysLeft,_that.projectedExtraSavings,_that.budgets,_that.transactions,_that.bills);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Dashboard implements Dashboard {
  const _Dashboard({required this.name, required this.asOf, required this.balance, required this.monthChange, required this.monthChangePercent, required this.inflow, required this.outflow, required this.savings, required this.savingsRate, required this.transactionCount, required this.accountCount, required this.budgetLimit, this.budgetSpent, required this.daysLeft, required this.projectedExtraSavings, required  List<BudgetSnapshot> budgets, required  List<TransactionRecord> transactions, required  List<UpcomingBill> bills}): _budgets = budgets,_transactions = transactions,_bills = bills;
  factory _Dashboard.fromJson(Map<String, dynamic> json) => _$DashboardFromJson(json);

@override final  String name;
@override final  DateTime asOf;
@override final  int balance;
@override final  int monthChange;
@override final  String monthChangePercent;
@override final  int inflow;
@override final  int outflow;
@override final  int savings;
@override final  String savingsRate;
@override final  int transactionCount;
@override final  int accountCount;
@override final  int budgetLimit;
@override final  int? budgetSpent;
@override final  int daysLeft;
@override final  int projectedExtraSavings;
 final  List<BudgetSnapshot> _budgets;
@override List<BudgetSnapshot> get budgets {
  if (_budgets is EqualUnmodifiableListView) return _budgets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_budgets);
}

 final  List<TransactionRecord> _transactions;
@override List<TransactionRecord> get transactions {
  if (_transactions is EqualUnmodifiableListView) return _transactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transactions);
}

 final  List<UpcomingBill> _bills;
@override List<UpcomingBill> get bills {
  if (_bills is EqualUnmodifiableListView) return _bills;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bills);
}


/// Create a copy of Dashboard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardCopyWith<_Dashboard> get copyWith => __$DashboardCopyWithImpl<_Dashboard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DashboardToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Dashboard&&(identical(other.name, name) || other.name == name)&&(identical(other.asOf, asOf) || other.asOf == asOf)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.monthChange, monthChange) || other.monthChange == monthChange)&&(identical(other.monthChangePercent, monthChangePercent) || other.monthChangePercent == monthChangePercent)&&(identical(other.inflow, inflow) || other.inflow == inflow)&&(identical(other.outflow, outflow) || other.outflow == outflow)&&(identical(other.savings, savings) || other.savings == savings)&&(identical(other.savingsRate, savingsRate) || other.savingsRate == savingsRate)&&(identical(other.transactionCount, transactionCount) || other.transactionCount == transactionCount)&&(identical(other.accountCount, accountCount) || other.accountCount == accountCount)&&(identical(other.budgetLimit, budgetLimit) || other.budgetLimit == budgetLimit)&&(identical(other.budgetSpent, budgetSpent) || other.budgetSpent == budgetSpent)&&(identical(other.daysLeft, daysLeft) || other.daysLeft == daysLeft)&&(identical(other.projectedExtraSavings, projectedExtraSavings) || other.projectedExtraSavings == projectedExtraSavings)&&const DeepCollectionEquality().equals(other.budgets, _budgets)&&const DeepCollectionEquality().equals(other.transactions, _transactions)&&const DeepCollectionEquality().equals(other.bills, _bills));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,asOf,balance,monthChange,monthChangePercent,inflow,outflow,savings,savingsRate,transactionCount,accountCount,budgetLimit,budgetSpent,daysLeft,projectedExtraSavings,const DeepCollectionEquality().hash(_budgets),const DeepCollectionEquality().hash(_transactions),const DeepCollectionEquality().hash(_bills));
}

@override
String toString() {
    return 'Dashboard(name: $name, asOf: $asOf, balance: $balance, monthChange: $monthChange, monthChangePercent: $monthChangePercent, inflow: $inflow, outflow: $outflow, savings: $savings, savingsRate: $savingsRate, transactionCount: $transactionCount, accountCount: $accountCount, budgetLimit: $budgetLimit, budgetSpent: $budgetSpent, daysLeft: $daysLeft, projectedExtraSavings: $projectedExtraSavings, budgets: $budgets, transactions: $transactions, bills: $bills)';
}


}

/// @nodoc
abstract mixin class _$DashboardCopyWith<$Res> implements $DashboardCopyWith<$Res> {
  factory _$DashboardCopyWith(_Dashboard value, $Res Function(_Dashboard) _then) = __$DashboardCopyWithImpl;
@override @useResult
$Res call({
 String name, DateTime asOf, int balance, int monthChange, String monthChangePercent, int inflow, int outflow, int savings, String savingsRate, int transactionCount, int accountCount, int budgetLimit, int? budgetSpent, int daysLeft, int projectedExtraSavings, List<BudgetSnapshot> budgets, List<TransactionRecord> transactions, List<UpcomingBill> bills
});




}
/// @nodoc
class __$DashboardCopyWithImpl<$Res>
    implements _$DashboardCopyWith<$Res> {
  __$DashboardCopyWithImpl(this._self, this._then);

  final _Dashboard _self;
  final $Res Function(_Dashboard) _then;

/// Create a copy of Dashboard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? asOf = null,Object? balance = null,Object? monthChange = null,Object? monthChangePercent = null,Object? inflow = null,Object? outflow = null,Object? savings = null,Object? savingsRate = null,Object? transactionCount = null,Object? accountCount = null,Object? budgetLimit = null,Object? budgetSpent = freezed,Object? daysLeft = null,Object? projectedExtraSavings = null,Object? budgets = null,Object? transactions = null,Object? bills = null,}) {
  return _then(_Dashboard(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,asOf: null == asOf ? _self.asOf : asOf // ignore: cast_nullable_to_non_nullable
as DateTime,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as int,monthChange: null == monthChange ? _self.monthChange : monthChange // ignore: cast_nullable_to_non_nullable
as int,monthChangePercent: null == monthChangePercent ? _self.monthChangePercent : monthChangePercent // ignore: cast_nullable_to_non_nullable
as String,inflow: null == inflow ? _self.inflow : inflow // ignore: cast_nullable_to_non_nullable
as int,outflow: null == outflow ? _self.outflow : outflow // ignore: cast_nullable_to_non_nullable
as int,savings: null == savings ? _self.savings : savings // ignore: cast_nullable_to_non_nullable
as int,savingsRate: null == savingsRate ? _self.savingsRate : savingsRate // ignore: cast_nullable_to_non_nullable
as String,transactionCount: null == transactionCount ? _self.transactionCount : transactionCount // ignore: cast_nullable_to_non_nullable
as int,accountCount: null == accountCount ? _self.accountCount : accountCount // ignore: cast_nullable_to_non_nullable
as int,budgetLimit: null == budgetLimit ? _self.budgetLimit : budgetLimit // ignore: cast_nullable_to_non_nullable
as int,budgetSpent: freezed == budgetSpent ? _self.budgetSpent : budgetSpent // ignore: cast_nullable_to_non_nullable
as int?,daysLeft: null == daysLeft ? _self.daysLeft : daysLeft // ignore: cast_nullable_to_non_nullable
as int,projectedExtraSavings: null == projectedExtraSavings ? _self.projectedExtraSavings : projectedExtraSavings // ignore: cast_nullable_to_non_nullable
as int,budgets: null == budgets ? _self._budgets : budgets // ignore: cast_nullable_to_non_nullable
as List<BudgetSnapshot>,transactions: null == transactions ? _self._transactions : transactions // ignore: cast_nullable_to_non_nullable
as List<TransactionRecord>,bills: null == bills ? _self._bills : bills // ignore: cast_nullable_to_non_nullable
as List<UpcomingBill>,
  ));
}


}


/// @nodoc
mixin _$BudgetSnapshot {

 String get name; int get spent; int get limit; String get status;
/// Create a copy of BudgetSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetSnapshotCopyWith<BudgetSnapshot> get copyWith => _$BudgetSnapshotCopyWithImpl<BudgetSnapshot>(this as BudgetSnapshot, _$identity);

  /// Serializes this BudgetSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as BudgetSnapshot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetSnapshot&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.spent, _this.spent) || other.spent == _this.spent)&&(identical(other.limit, _this.limit) || other.limit == _this.limit)&&(identical(other.status, _this.status) || other.status == _this.status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as BudgetSnapshot;
  return Object.hash(runtimeType,_this.name,_this.spent,_this.limit,_this.status);
}

@override
String toString() {
  final _this = this as BudgetSnapshot;
  return 'BudgetSnapshot(name: ${_this.name}, spent: ${_this.spent}, limit: ${_this.limit}, status: ${_this.status})';
}


}

/// @nodoc
abstract mixin class $BudgetSnapshotCopyWith<$Res>  {
  factory $BudgetSnapshotCopyWith(BudgetSnapshot value, $Res Function(BudgetSnapshot) _then) = _$BudgetSnapshotCopyWithImpl;
@useResult
$Res call({
 String name, int spent, int limit, String status
});




}
/// @nodoc
class _$BudgetSnapshotCopyWithImpl<$Res>
    implements $BudgetSnapshotCopyWith<$Res> {
  _$BudgetSnapshotCopyWithImpl(this._self, this._then);

  final BudgetSnapshot _self;
  final $Res Function(BudgetSnapshot) _then;

/// Create a copy of BudgetSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? spent = null,Object? limit = null,Object? status = null,}) {
  return _then(BudgetSnapshot(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,spent: null == spent ? _self.spent : spent // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetSnapshot].
extension BudgetSnapshotPatterns on BudgetSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _BudgetSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int spent,  int limit,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetSnapshot() when $default != null:
return $default(_that.name,_that.spent,_that.limit,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int spent,  int limit,  String status)  $default,) {final _that = this;
switch (_that) {
case _BudgetSnapshot():
return $default(_that.name,_that.spent,_that.limit,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int spent,  int limit,  String status)?  $default,) {final _that = this;
switch (_that) {
case _BudgetSnapshot() when $default != null:
return $default(_that.name,_that.spent,_that.limit,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BudgetSnapshot extends BudgetSnapshot {
  const _BudgetSnapshot({required this.name, required this.spent, required this.limit, required this.status}): super._();
  factory _BudgetSnapshot.fromJson(Map<String, dynamic> json) => _$BudgetSnapshotFromJson(json);

@override final  String name;
@override final  int spent;
@override final  int limit;
@override final  String status;

/// Create a copy of BudgetSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetSnapshotCopyWith<_BudgetSnapshot> get copyWith => __$BudgetSnapshotCopyWithImpl<_BudgetSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BudgetSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetSnapshot&&(identical(other.name, name) || other.name == name)&&(identical(other.spent, spent) || other.spent == spent)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,spent,limit,status);
}

@override
String toString() {
    return 'BudgetSnapshot(name: $name, spent: $spent, limit: $limit, status: $status)';
}


}

/// @nodoc
abstract mixin class _$BudgetSnapshotCopyWith<$Res> implements $BudgetSnapshotCopyWith<$Res> {
  factory _$BudgetSnapshotCopyWith(_BudgetSnapshot value, $Res Function(_BudgetSnapshot) _then) = __$BudgetSnapshotCopyWithImpl;
@override @useResult
$Res call({
 String name, int spent, int limit, String status
});




}
/// @nodoc
class __$BudgetSnapshotCopyWithImpl<$Res>
    implements _$BudgetSnapshotCopyWith<$Res> {
  __$BudgetSnapshotCopyWithImpl(this._self, this._then);

  final _BudgetSnapshot _self;
  final $Res Function(_BudgetSnapshot) _then;

/// Create a copy of BudgetSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? spent = null,Object? limit = null,Object? status = null,}) {
  return _then(_BudgetSnapshot(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,spent: null == spent ? _self.spent : spent // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$UpcomingBill {

 String get name; int get amount; int get daysUntilDue; bool get estimated;
/// Create a copy of UpcomingBill
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpcomingBillCopyWith<UpcomingBill> get copyWith => _$UpcomingBillCopyWithImpl<UpcomingBill>(this as UpcomingBill, _$identity);

  /// Serializes this UpcomingBill to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UpcomingBill;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpcomingBill&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.daysUntilDue, _this.daysUntilDue) || other.daysUntilDue == _this.daysUntilDue)&&(identical(other.estimated, _this.estimated) || other.estimated == _this.estimated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UpcomingBill;
  return Object.hash(runtimeType,_this.name,_this.amount,_this.daysUntilDue,_this.estimated);
}

@override
String toString() {
  final _this = this as UpcomingBill;
  return 'UpcomingBill(name: ${_this.name}, amount: ${_this.amount}, daysUntilDue: ${_this.daysUntilDue}, estimated: ${_this.estimated})';
}


}

/// @nodoc
abstract mixin class $UpcomingBillCopyWith<$Res>  {
  factory $UpcomingBillCopyWith(UpcomingBill value, $Res Function(UpcomingBill) _then) = _$UpcomingBillCopyWithImpl;
@useResult
$Res call({
 String name, int amount, int daysUntilDue, bool estimated
});




}
/// @nodoc
class _$UpcomingBillCopyWithImpl<$Res>
    implements $UpcomingBillCopyWith<$Res> {
  _$UpcomingBillCopyWithImpl(this._self, this._then);

  final UpcomingBill _self;
  final $Res Function(UpcomingBill) _then;

/// Create a copy of UpcomingBill
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? amount = null,Object? daysUntilDue = null,Object? estimated = null,}) {
  return _then(UpcomingBill(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,daysUntilDue: null == daysUntilDue ? _self.daysUntilDue : daysUntilDue // ignore: cast_nullable_to_non_nullable
as int,estimated: null == estimated ? _self.estimated : estimated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UpcomingBill].
extension UpcomingBillPatterns on UpcomingBill {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpcomingBill value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpcomingBill() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpcomingBill value)  $default,){
final _that = this;
switch (_that) {
case _UpcomingBill():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpcomingBill value)?  $default,){
final _that = this;
switch (_that) {
case _UpcomingBill() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int amount,  int daysUntilDue,  bool estimated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpcomingBill() when $default != null:
return $default(_that.name,_that.amount,_that.daysUntilDue,_that.estimated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int amount,  int daysUntilDue,  bool estimated)  $default,) {final _that = this;
switch (_that) {
case _UpcomingBill():
return $default(_that.name,_that.amount,_that.daysUntilDue,_that.estimated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int amount,  int daysUntilDue,  bool estimated)?  $default,) {final _that = this;
switch (_that) {
case _UpcomingBill() when $default != null:
return $default(_that.name,_that.amount,_that.daysUntilDue,_that.estimated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpcomingBill implements UpcomingBill {
  const _UpcomingBill({required this.name, required this.amount, required this.daysUntilDue, this.estimated = false});
  factory _UpcomingBill.fromJson(Map<String, dynamic> json) => _$UpcomingBillFromJson(json);

@override final  String name;
@override final  int amount;
@override final  int daysUntilDue;
@override@JsonKey() final  bool estimated;

/// Create a copy of UpcomingBill
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpcomingBillCopyWith<_UpcomingBill> get copyWith => __$UpcomingBillCopyWithImpl<_UpcomingBill>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpcomingBillToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpcomingBill&&(identical(other.name, name) || other.name == name)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.daysUntilDue, daysUntilDue) || other.daysUntilDue == daysUntilDue)&&(identical(other.estimated, estimated) || other.estimated == estimated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,amount,daysUntilDue,estimated);
}

@override
String toString() {
    return 'UpcomingBill(name: $name, amount: $amount, daysUntilDue: $daysUntilDue, estimated: $estimated)';
}


}

/// @nodoc
abstract mixin class _$UpcomingBillCopyWith<$Res> implements $UpcomingBillCopyWith<$Res> {
  factory _$UpcomingBillCopyWith(_UpcomingBill value, $Res Function(_UpcomingBill) _then) = __$UpcomingBillCopyWithImpl;
@override @useResult
$Res call({
 String name, int amount, int daysUntilDue, bool estimated
});




}
/// @nodoc
class __$UpcomingBillCopyWithImpl<$Res>
    implements _$UpcomingBillCopyWith<$Res> {
  __$UpcomingBillCopyWithImpl(this._self, this._then);

  final _UpcomingBill _self;
  final $Res Function(_UpcomingBill) _then;

/// Create a copy of UpcomingBill
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? amount = null,Object? daysUntilDue = null,Object? estimated = null,}) {
  return _then(_UpcomingBill(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,daysUntilDue: null == daysUntilDue ? _self.daysUntilDue : daysUntilDue // ignore: cast_nullable_to_non_nullable
as int,estimated: null == estimated ? _self.estimated : estimated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
