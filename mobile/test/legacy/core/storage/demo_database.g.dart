// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'demo_database.dart';

// ignore_for_file: type=lint
class $DemoSnapshotsTable extends DemoSnapshots
    with TableInfo<$DemoSnapshotsTable, DemoSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DemoSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'demo_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<DemoSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DemoSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DemoSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $DemoSnapshotsTable createAlias(String alias) {
    return $DemoSnapshotsTable(attachedDatabase, alias);
  }
}

class DemoSnapshot extends DataClass implements Insertable<DemoSnapshot> {
  final int id;
  final String payload;
  const DemoSnapshot({required this.id, required this.payload});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  DemoSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return DemoSnapshotsCompanion(id: Value(id), payload: Value(payload));
  }

  factory DemoSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DemoSnapshot(
      id: serializer.fromJson<int>(json['id']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'payload': serializer.toJson<String>(payload),
    };
  }

  DemoSnapshot copyWith({int? id, String? payload}) =>
      DemoSnapshot(id: id ?? this.id, payload: payload ?? this.payload);
  DemoSnapshot copyWithCompanion(DemoSnapshotsCompanion data) {
    return DemoSnapshot(
      id: data.id.present ? data.id.value : this.id,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DemoSnapshot(')
          ..write('id: $id, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DemoSnapshot &&
          other.id == this.id &&
          other.payload == this.payload);
}

class DemoSnapshotsCompanion extends UpdateCompanion<DemoSnapshot> {
  final Value<int> id;
  final Value<String> payload;
  const DemoSnapshotsCompanion({
    this.id = const Value.absent(),
    this.payload = const Value.absent(),
  });
  DemoSnapshotsCompanion.insert({
    this.id = const Value.absent(),
    required String payload,
  }) : payload = Value(payload);
  static Insertable<DemoSnapshot> custom({
    Expression<int>? id,
    Expression<String>? payload,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payload != null) 'payload': payload,
    });
  }

  DemoSnapshotsCompanion copyWith({Value<int>? id, Value<String>? payload}) {
    return DemoSnapshotsCompanion(
      id: id ?? this.id,
      payload: payload ?? this.payload,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DemoSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }
}

abstract class _$DemoDatabase extends GeneratedDatabase {
  _$DemoDatabase(QueryExecutor e) : super(e);
  $DemoDatabaseManager get managers => $DemoDatabaseManager(this);
  late final $DemoSnapshotsTable demoSnapshots = $DemoSnapshotsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [demoSnapshots];
}

typedef $$DemoSnapshotsTableCreateCompanionBuilder =
    DemoSnapshotsCompanion Function({Value<int> id, required String payload});
typedef $$DemoSnapshotsTableUpdateCompanionBuilder =
    DemoSnapshotsCompanion Function({Value<int> id, Value<String> payload});

class $$DemoSnapshotsTableFilterComposer
    extends Composer<_$DemoDatabase, $DemoSnapshotsTable> {
  $$DemoSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DemoSnapshotsTableOrderingComposer
    extends Composer<_$DemoDatabase, $DemoSnapshotsTable> {
  $$DemoSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DemoSnapshotsTableAnnotationComposer
    extends Composer<_$DemoDatabase, $DemoSnapshotsTable> {
  $$DemoSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$DemoSnapshotsTableTableManager
    extends
        RootTableManager<
          _$DemoDatabase,
          $DemoSnapshotsTable,
          DemoSnapshot,
          $$DemoSnapshotsTableFilterComposer,
          $$DemoSnapshotsTableOrderingComposer,
          $$DemoSnapshotsTableAnnotationComposer,
          $$DemoSnapshotsTableCreateCompanionBuilder,
          $$DemoSnapshotsTableUpdateCompanionBuilder,
          (
            DemoSnapshot,
            BaseReferences<_$DemoDatabase, $DemoSnapshotsTable, DemoSnapshot>,
          ),
          DemoSnapshot,
          PrefetchHooks Function()
        > {
  $$DemoSnapshotsTableTableManager(_$DemoDatabase db, $DemoSnapshotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DemoSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DemoSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DemoSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> payload = const Value.absent(),
          }) => DemoSnapshotsCompanion(id: id, payload: payload),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String payload,
          }) => DemoSnapshotsCompanion.insert(id: id, payload: payload),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DemoSnapshotsTable, DemoSnapshot>(table),
                  BaseReferences<
                    _$DemoDatabase,
                    $DemoSnapshotsTable,
                    DemoSnapshot
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DemoSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$DemoDatabase,
      $DemoSnapshotsTable,
      DemoSnapshot,
      $$DemoSnapshotsTableFilterComposer,
      $$DemoSnapshotsTableOrderingComposer,
      $$DemoSnapshotsTableAnnotationComposer,
      $$DemoSnapshotsTableCreateCompanionBuilder,
      $$DemoSnapshotsTableUpdateCompanionBuilder,
      (
        DemoSnapshot,
        BaseReferences<_$DemoDatabase, $DemoSnapshotsTable, DemoSnapshot>,
      ),
      DemoSnapshot,
      PrefetchHooks Function()
    >;

class $DemoDatabaseManager {
  final _$DemoDatabase _db;
  $DemoDatabaseManager(this._db);
  $$DemoSnapshotsTableTableManager get demoSnapshots =>
      $$DemoSnapshotsTableTableManager(_db, _db.demoSnapshots);
}
