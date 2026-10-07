// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_database.dart';

// ignore_for_file: type=lint
class $EncryptedWorkspacesTable extends EncryptedWorkspaces
    with TableInfo<$EncryptedWorkspacesTable, EncryptedWorkspace> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EncryptedWorkspacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<Uint8List> payload = GeneratedColumn<Uint8List>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, revision, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'encrypted_workspaces';
  @override
  VerificationContext validateIntegrity(
    Insertable<EncryptedWorkspace> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
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
  EncryptedWorkspace map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EncryptedWorkspace(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $EncryptedWorkspacesTable createAlias(String alias) {
    return $EncryptedWorkspacesTable(attachedDatabase, alias);
  }
}

class EncryptedWorkspace extends DataClass
    implements Insertable<EncryptedWorkspace> {
  final int id;
  final int revision;
  final Uint8List payload;
  const EncryptedWorkspace({
    required this.id,
    required this.revision,
    required this.payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['revision'] = Variable<int>(revision);
    map['payload'] = Variable<Uint8List>(payload);
    return map;
  }

  EncryptedWorkspacesCompanion toCompanion(bool nullToAbsent) {
    return EncryptedWorkspacesCompanion(
      id: Value(id),
      revision: Value(revision),
      payload: Value(payload),
    );
  }

  factory EncryptedWorkspace.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EncryptedWorkspace(
      id: serializer.fromJson<int>(json['id']),
      revision: serializer.fromJson<int>(json['revision']),
      payload: serializer.fromJson<Uint8List>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'revision': serializer.toJson<int>(revision),
      'payload': serializer.toJson<Uint8List>(payload),
    };
  }

  EncryptedWorkspace copyWith({int? id, int? revision, Uint8List? payload}) =>
      EncryptedWorkspace(
        id: id ?? this.id,
        revision: revision ?? this.revision,
        payload: payload ?? this.payload,
      );
  EncryptedWorkspace copyWithCompanion(EncryptedWorkspacesCompanion data) {
    return EncryptedWorkspace(
      id: data.id.present ? data.id.value : this.id,
      revision: data.revision.present ? data.revision.value : this.revision,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EncryptedWorkspace(')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, revision, $driftBlobEquality.hash(payload));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EncryptedWorkspace &&
          other.id == this.id &&
          other.revision == this.revision &&
          $driftBlobEquality.equals(other.payload, this.payload));
}

class EncryptedWorkspacesCompanion extends UpdateCompanion<EncryptedWorkspace> {
  final Value<int> id;
  final Value<int> revision;
  final Value<Uint8List> payload;
  const EncryptedWorkspacesCompanion({
    this.id = const Value.absent(),
    this.revision = const Value.absent(),
    this.payload = const Value.absent(),
  });
  EncryptedWorkspacesCompanion.insert({
    this.id = const Value.absent(),
    required int revision,
    required Uint8List payload,
  }) : revision = Value(revision),
       payload = Value(payload);
  static Insertable<EncryptedWorkspace> custom({
    Expression<int>? id,
    Expression<int>? revision,
    Expression<Uint8List>? payload,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (revision != null) 'revision': revision,
      if (payload != null) 'payload': payload,
    });
  }

  EncryptedWorkspacesCompanion copyWith({
    Value<int>? id,
    Value<int>? revision,
    Value<Uint8List>? payload,
  }) {
    return EncryptedWorkspacesCompanion(
      id: id ?? this.id,
      revision: revision ?? this.revision,
      payload: payload ?? this.payload,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (payload.present) {
      map['payload'] = Variable<Uint8List>(payload.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EncryptedWorkspacesCompanion(')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }
}

class $EncryptedReceiptsTable extends EncryptedReceipts
    with TableInfo<$EncryptedReceiptsTable, EncryptedReceipt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EncryptedReceiptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<Uint8List> payload = GeneratedColumn<Uint8List>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'encrypted_receipts';
  @override
  VerificationContext validateIntegrity(
    Insertable<EncryptedReceipt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
  EncryptedReceipt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EncryptedReceipt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $EncryptedReceiptsTable createAlias(String alias) {
    return $EncryptedReceiptsTable(attachedDatabase, alias);
  }
}

class EncryptedReceipt extends DataClass
    implements Insertable<EncryptedReceipt> {
  final String id;
  final Uint8List payload;
  const EncryptedReceipt({required this.id, required this.payload});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payload'] = Variable<Uint8List>(payload);
    return map;
  }

  EncryptedReceiptsCompanion toCompanion(bool nullToAbsent) {
    return EncryptedReceiptsCompanion(id: Value(id), payload: Value(payload));
  }

  factory EncryptedReceipt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EncryptedReceipt(
      id: serializer.fromJson<String>(json['id']),
      payload: serializer.fromJson<Uint8List>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'payload': serializer.toJson<Uint8List>(payload),
    };
  }

  EncryptedReceipt copyWith({String? id, Uint8List? payload}) =>
      EncryptedReceipt(id: id ?? this.id, payload: payload ?? this.payload);
  EncryptedReceipt copyWithCompanion(EncryptedReceiptsCompanion data) {
    return EncryptedReceipt(
      id: data.id.present ? data.id.value : this.id,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EncryptedReceipt(')
          ..write('id: $id, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, $driftBlobEquality.hash(payload));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EncryptedReceipt &&
          other.id == this.id &&
          $driftBlobEquality.equals(other.payload, this.payload));
}

class EncryptedReceiptsCompanion extends UpdateCompanion<EncryptedReceipt> {
  final Value<String> id;
  final Value<Uint8List> payload;
  final Value<int> rowid;
  const EncryptedReceiptsCompanion({
    this.id = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EncryptedReceiptsCompanion.insert({
    required String id,
    required Uint8List payload,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payload = Value(payload);
  static Insertable<EncryptedReceipt> custom({
    Expression<String>? id,
    Expression<Uint8List>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EncryptedReceiptsCompanion copyWith({
    Value<String>? id,
    Value<Uint8List>? payload,
    Value<int>? rowid,
  }) {
    return EncryptedReceiptsCompanion(
      id: id ?? this.id,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (payload.present) {
      map['payload'] = Variable<Uint8List>(payload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EncryptedReceiptsCompanion(')
          ..write('id: $id, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$FinanceDatabase extends GeneratedDatabase {
  _$FinanceDatabase(QueryExecutor e) : super(e);
  $FinanceDatabaseManager get managers => $FinanceDatabaseManager(this);
  late final $EncryptedWorkspacesTable encryptedWorkspaces =
      $EncryptedWorkspacesTable(this);
  late final $EncryptedReceiptsTable encryptedReceipts =
      $EncryptedReceiptsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    encryptedWorkspaces,
    encryptedReceipts,
  ];
}

typedef $$EncryptedWorkspacesTableCreateCompanionBuilder =
    EncryptedWorkspacesCompanion Function({
      Value<int> id,
      required int revision,
      required Uint8List payload,
    });
typedef $$EncryptedWorkspacesTableUpdateCompanionBuilder =
    EncryptedWorkspacesCompanion Function({
      Value<int> id,
      Value<int> revision,
      Value<Uint8List> payload,
    });

class $$EncryptedWorkspacesTableFilterComposer
    extends Composer<_$FinanceDatabase, $EncryptedWorkspacesTable> {
  $$EncryptedWorkspacesTableFilterComposer({
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

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EncryptedWorkspacesTableOrderingComposer
    extends Composer<_$FinanceDatabase, $EncryptedWorkspacesTable> {
  $$EncryptedWorkspacesTableOrderingComposer({
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

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EncryptedWorkspacesTableAnnotationComposer
    extends Composer<_$FinanceDatabase, $EncryptedWorkspacesTable> {
  $$EncryptedWorkspacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<Uint8List> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$EncryptedWorkspacesTableTableManager
    extends
        RootTableManager<
          _$FinanceDatabase,
          $EncryptedWorkspacesTable,
          EncryptedWorkspace,
          $$EncryptedWorkspacesTableFilterComposer,
          $$EncryptedWorkspacesTableOrderingComposer,
          $$EncryptedWorkspacesTableAnnotationComposer,
          $$EncryptedWorkspacesTableCreateCompanionBuilder,
          $$EncryptedWorkspacesTableUpdateCompanionBuilder,
          (
            EncryptedWorkspace,
            BaseReferences<
              _$FinanceDatabase,
              $EncryptedWorkspacesTable,
              EncryptedWorkspace
            >,
          ),
          EncryptedWorkspace,
          PrefetchHooks Function()
        > {
  $$EncryptedWorkspacesTableTableManager(
    _$FinanceDatabase db,
    $EncryptedWorkspacesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EncryptedWorkspacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EncryptedWorkspacesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$EncryptedWorkspacesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<Uint8List> payload = const Value.absent(),
              }) => EncryptedWorkspacesCompanion(
                id: id,
                revision: revision,
                payload: payload,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int revision,
                required Uint8List payload,
              }) => EncryptedWorkspacesCompanion.insert(
                id: id,
                revision: revision,
                payload: payload,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EncryptedWorkspacesTable, EncryptedWorkspace>(
                    table,
                  ),
                  BaseReferences<
                    _$FinanceDatabase,
                    $EncryptedWorkspacesTable,
                    EncryptedWorkspace
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EncryptedWorkspacesTableProcessedTableManager =
    ProcessedTableManager<
      _$FinanceDatabase,
      $EncryptedWorkspacesTable,
      EncryptedWorkspace,
      $$EncryptedWorkspacesTableFilterComposer,
      $$EncryptedWorkspacesTableOrderingComposer,
      $$EncryptedWorkspacesTableAnnotationComposer,
      $$EncryptedWorkspacesTableCreateCompanionBuilder,
      $$EncryptedWorkspacesTableUpdateCompanionBuilder,
      (
        EncryptedWorkspace,
        BaseReferences<
          _$FinanceDatabase,
          $EncryptedWorkspacesTable,
          EncryptedWorkspace
        >,
      ),
      EncryptedWorkspace,
      PrefetchHooks Function()
    >;
typedef $$EncryptedReceiptsTableCreateCompanionBuilder =
    EncryptedReceiptsCompanion Function({
      required String id,
      required Uint8List payload,
      Value<int> rowid,
    });
typedef $$EncryptedReceiptsTableUpdateCompanionBuilder =
    EncryptedReceiptsCompanion Function({
      Value<String> id,
      Value<Uint8List> payload,
      Value<int> rowid,
    });

class $$EncryptedReceiptsTableFilterComposer
    extends Composer<_$FinanceDatabase, $EncryptedReceiptsTable> {
  $$EncryptedReceiptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EncryptedReceiptsTableOrderingComposer
    extends Composer<_$FinanceDatabase, $EncryptedReceiptsTable> {
  $$EncryptedReceiptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EncryptedReceiptsTableAnnotationComposer
    extends Composer<_$FinanceDatabase, $EncryptedReceiptsTable> {
  $$EncryptedReceiptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<Uint8List> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$EncryptedReceiptsTableTableManager
    extends
        RootTableManager<
          _$FinanceDatabase,
          $EncryptedReceiptsTable,
          EncryptedReceipt,
          $$EncryptedReceiptsTableFilterComposer,
          $$EncryptedReceiptsTableOrderingComposer,
          $$EncryptedReceiptsTableAnnotationComposer,
          $$EncryptedReceiptsTableCreateCompanionBuilder,
          $$EncryptedReceiptsTableUpdateCompanionBuilder,
          (
            EncryptedReceipt,
            BaseReferences<
              _$FinanceDatabase,
              $EncryptedReceiptsTable,
              EncryptedReceipt
            >,
          ),
          EncryptedReceipt,
          PrefetchHooks Function()
        > {
  $$EncryptedReceiptsTableTableManager(
    _$FinanceDatabase db,
    $EncryptedReceiptsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EncryptedReceiptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EncryptedReceiptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EncryptedReceiptsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<Uint8List> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EncryptedReceiptsCompanion(
                id: id,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required Uint8List payload,
                Value<int> rowid = const Value.absent(),
              }) => EncryptedReceiptsCompanion.insert(
                id: id,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EncryptedReceiptsTable, EncryptedReceipt>(table),
                  BaseReferences<
                    _$FinanceDatabase,
                    $EncryptedReceiptsTable,
                    EncryptedReceipt
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EncryptedReceiptsTableProcessedTableManager =
    ProcessedTableManager<
      _$FinanceDatabase,
      $EncryptedReceiptsTable,
      EncryptedReceipt,
      $$EncryptedReceiptsTableFilterComposer,
      $$EncryptedReceiptsTableOrderingComposer,
      $$EncryptedReceiptsTableAnnotationComposer,
      $$EncryptedReceiptsTableCreateCompanionBuilder,
      $$EncryptedReceiptsTableUpdateCompanionBuilder,
      (
        EncryptedReceipt,
        BaseReferences<
          _$FinanceDatabase,
          $EncryptedReceiptsTable,
          EncryptedReceipt
        >,
      ),
      EncryptedReceipt,
      PrefetchHooks Function()
    >;

class $FinanceDatabaseManager {
  final _$FinanceDatabase _db;
  $FinanceDatabaseManager(this._db);
  $$EncryptedWorkspacesTableTableManager get encryptedWorkspaces =>
      $$EncryptedWorkspacesTableTableManager(_db, _db.encryptedWorkspaces);
  $$EncryptedReceiptsTableTableManager get encryptedReceipts =>
      $$EncryptedReceiptsTableTableManager(_db, _db.encryptedReceipts);
}
