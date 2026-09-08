// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SyncMetaTable extends SyncMeta
    with TableInfo<$SyncMetaTable, SyncMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<String> cursor = GeneratedColumn<String>(
    'cursor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, lastSyncedAt, cursor];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('cursor')) {
      context.handle(
        _cursorMeta,
        cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetaData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      cursor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cursor'],
      ),
    );
  }

  @override
  $SyncMetaTable createAlias(String alias) {
    return $SyncMetaTable(attachedDatabase, alias);
  }
}

class SyncMetaData extends DataClass implements Insertable<SyncMetaData> {
  final String key;
  final DateTime? lastSyncedAt;

  /// Server pagination cursor / ETag when applicable.
  final String? cursor;
  const SyncMetaData({required this.key, this.lastSyncedAt, this.cursor});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || cursor != null) {
      map['cursor'] = Variable<String>(cursor);
    }
    return map;
  }

  SyncMetaCompanion toCompanion(bool nullToAbsent) {
    return SyncMetaCompanion(
      key: Value(key),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      cursor: cursor == null && nullToAbsent
          ? const Value.absent()
          : Value(cursor),
    );
  }

  factory SyncMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetaData(
      key: serializer.fromJson<String>(json['key']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      cursor: serializer.fromJson<String?>(json['cursor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'cursor': serializer.toJson<String?>(cursor),
    };
  }

  SyncMetaData copyWith({
    String? key,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    Value<String?> cursor = const Value.absent(),
  }) => SyncMetaData(
    key: key ?? this.key,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    cursor: cursor.present ? cursor.value : this.cursor,
  );
  SyncMetaData copyWithCompanion(SyncMetaCompanion data) {
    return SyncMetaData(
      key: data.key.present ? data.key.value : this.key,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaData(')
          ..write('key: $key, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('cursor: $cursor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, lastSyncedAt, cursor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetaData &&
          other.key == this.key &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.cursor == this.cursor);
}

class SyncMetaCompanion extends UpdateCompanion<SyncMetaData> {
  final Value<String> key;
  final Value<DateTime?> lastSyncedAt;
  final Value<String?> cursor;
  final Value<int> rowid;
  const SyncMetaCompanion({
    this.key = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.cursor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetaCompanion.insert({
    required String key,
    this.lastSyncedAt = const Value.absent(),
    this.cursor = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<SyncMetaData> custom({
    Expression<String>? key,
    Expression<DateTime>? lastSyncedAt,
    Expression<String>? cursor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (cursor != null) 'cursor': cursor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetaCompanion copyWith({
    Value<String>? key,
    Value<DateTime?>? lastSyncedAt,
    Value<String?>? cursor,
    Value<int>? rowid,
  }) {
    return SyncMetaCompanion(
      key: key ?? this.key,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      cursor: cursor ?? this.cursor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<String>(cursor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaCompanion(')
          ..write('key: $key, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('cursor: $cursor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextTryAtMeta = const VerificationMeta(
    'nextTryAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextTryAt = GeneratedColumn<DateTime>(
    'next_try_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    seq,
    kind,
    payload,
    priority,
    idempotencyKey,
    attempts,
    createdAt,
    nextTryAt,
    expiresAt,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('next_try_at')) {
      context.handle(
        _nextTryAtMeta,
        nextTryAt.isAcceptableOrUnknown(data['next_try_at']!, _nextTryAtMeta),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  OutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxData(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      ),
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      nextTryAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_try_at'],
      ),
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }
}

class OutboxData extends DataClass implements Insertable<OutboxData> {
  final int seq;

  /// rollup | health | alert_ack | mode | state | command | config | log
  final String kind;

  /// JSON payload for the handler.
  final String payload;

  /// Higher drains first: alert_ack(30) > mode/state(20) > config(10) > rest(0).
  final int priority;

  /// Reused across retries and across LAN+cloud so the server dedupes.
  final String? idempotencyKey;
  final int attempts;
  final DateTime createdAt;
  final DateTime? nextTryAt;
  final DateTime? expiresAt;
  final String? lastError;
  const OutboxData({
    required this.seq,
    required this.kind,
    required this.payload,
    required this.priority,
    this.idempotencyKey,
    required this.attempts,
    required this.createdAt,
    this.nextTryAt,
    this.expiresAt,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['kind'] = Variable<String>(kind);
    map['payload'] = Variable<String>(payload);
    map['priority'] = Variable<int>(priority);
    if (!nullToAbsent || idempotencyKey != null) {
      map['idempotency_key'] = Variable<String>(idempotencyKey);
    }
    map['attempts'] = Variable<int>(attempts);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || nextTryAt != null) {
      map['next_try_at'] = Variable<DateTime>(nextTryAt);
    }
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      seq: Value(seq),
      kind: Value(kind),
      payload: Value(payload),
      priority: Value(priority),
      idempotencyKey: idempotencyKey == null && nullToAbsent
          ? const Value.absent()
          : Value(idempotencyKey),
      attempts: Value(attempts),
      createdAt: Value(createdAt),
      nextTryAt: nextTryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextTryAt),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory OutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxData(
      seq: serializer.fromJson<int>(json['seq']),
      kind: serializer.fromJson<String>(json['kind']),
      payload: serializer.fromJson<String>(json['payload']),
      priority: serializer.fromJson<int>(json['priority']),
      idempotencyKey: serializer.fromJson<String?>(json['idempotencyKey']),
      attempts: serializer.fromJson<int>(json['attempts']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      nextTryAt: serializer.fromJson<DateTime?>(json['nextTryAt']),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'kind': serializer.toJson<String>(kind),
      'payload': serializer.toJson<String>(payload),
      'priority': serializer.toJson<int>(priority),
      'idempotencyKey': serializer.toJson<String?>(idempotencyKey),
      'attempts': serializer.toJson<int>(attempts),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'nextTryAt': serializer.toJson<DateTime?>(nextTryAt),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  OutboxData copyWith({
    int? seq,
    String? kind,
    String? payload,
    int? priority,
    Value<String?> idempotencyKey = const Value.absent(),
    int? attempts,
    DateTime? createdAt,
    Value<DateTime?> nextTryAt = const Value.absent(),
    Value<DateTime?> expiresAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => OutboxData(
    seq: seq ?? this.seq,
    kind: kind ?? this.kind,
    payload: payload ?? this.payload,
    priority: priority ?? this.priority,
    idempotencyKey: idempotencyKey.present
        ? idempotencyKey.value
        : this.idempotencyKey,
    attempts: attempts ?? this.attempts,
    createdAt: createdAt ?? this.createdAt,
    nextTryAt: nextTryAt.present ? nextTryAt.value : this.nextTryAt,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  OutboxData copyWithCompanion(OutboxCompanion data) {
    return OutboxData(
      seq: data.seq.present ? data.seq.value : this.seq,
      kind: data.kind.present ? data.kind.value : this.kind,
      payload: data.payload.present ? data.payload.value : this.payload,
      priority: data.priority.present ? data.priority.value : this.priority,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      nextTryAt: data.nextTryAt.present ? data.nextTryAt.value : this.nextTryAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxData(')
          ..write('seq: $seq, ')
          ..write('kind: $kind, ')
          ..write('payload: $payload, ')
          ..write('priority: $priority, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('nextTryAt: $nextTryAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    seq,
    kind,
    payload,
    priority,
    idempotencyKey,
    attempts,
    createdAt,
    nextTryAt,
    expiresAt,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxData &&
          other.seq == this.seq &&
          other.kind == this.kind &&
          other.payload == this.payload &&
          other.priority == this.priority &&
          other.idempotencyKey == this.idempotencyKey &&
          other.attempts == this.attempts &&
          other.createdAt == this.createdAt &&
          other.nextTryAt == this.nextTryAt &&
          other.expiresAt == this.expiresAt &&
          other.lastError == this.lastError);
}

class OutboxCompanion extends UpdateCompanion<OutboxData> {
  final Value<int> seq;
  final Value<String> kind;
  final Value<String> payload;
  final Value<int> priority;
  final Value<String?> idempotencyKey;
  final Value<int> attempts;
  final Value<DateTime> createdAt;
  final Value<DateTime?> nextTryAt;
  final Value<DateTime?> expiresAt;
  final Value<String?> lastError;
  const OutboxCompanion({
    this.seq = const Value.absent(),
    this.kind = const Value.absent(),
    this.payload = const Value.absent(),
    this.priority = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.attempts = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.nextTryAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  OutboxCompanion.insert({
    this.seq = const Value.absent(),
    required String kind,
    required String payload,
    this.priority = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.attempts = const Value.absent(),
    required DateTime createdAt,
    this.nextTryAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.lastError = const Value.absent(),
  }) : kind = Value(kind),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<OutboxData> custom({
    Expression<int>? seq,
    Expression<String>? kind,
    Expression<String>? payload,
    Expression<int>? priority,
    Expression<String>? idempotencyKey,
    Expression<int>? attempts,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? nextTryAt,
    Expression<DateTime>? expiresAt,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (kind != null) 'kind': kind,
      if (payload != null) 'payload': payload,
      if (priority != null) 'priority': priority,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (attempts != null) 'attempts': attempts,
      if (createdAt != null) 'created_at': createdAt,
      if (nextTryAt != null) 'next_try_at': nextTryAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (lastError != null) 'last_error': lastError,
    });
  }

  OutboxCompanion copyWith({
    Value<int>? seq,
    Value<String>? kind,
    Value<String>? payload,
    Value<int>? priority,
    Value<String?>? idempotencyKey,
    Value<int>? attempts,
    Value<DateTime>? createdAt,
    Value<DateTime?>? nextTryAt,
    Value<DateTime?>? expiresAt,
    Value<String?>? lastError,
  }) {
    return OutboxCompanion(
      seq: seq ?? this.seq,
      kind: kind ?? this.kind,
      payload: payload ?? this.payload,
      priority: priority ?? this.priority,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      attempts: attempts ?? this.attempts,
      createdAt: createdAt ?? this.createdAt,
      nextTryAt: nextTryAt ?? this.nextTryAt,
      expiresAt: expiresAt ?? this.expiresAt,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (nextTryAt.present) {
      map['next_try_at'] = Variable<DateTime>(nextTryAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('seq: $seq, ')
          ..write('kind: $kind, ')
          ..write('payload: $payload, ')
          ..write('priority: $priority, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('attempts: $attempts, ')
          ..write('createdAt: $createdAt, ')
          ..write('nextTryAt: $nextTryAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

class $CommandDedupTable extends CommandDedup
    with TableInfo<$CommandDedupTable, CommandDedupData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommandDedupTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliedAtMeta = const VerificationMeta(
    'appliedAt',
  );
  @override
  late final GeneratedColumn<DateTime> appliedAt = GeneratedColumn<DateTime>(
    'applied_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
    'result',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [idempotencyKey, appliedAt, result];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'command_dedup';
  @override
  VerificationContext validateIntegrity(
    Insertable<CommandDedupData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('applied_at')) {
      context.handle(
        _appliedAtMeta,
        appliedAt.isAcceptableOrUnknown(data['applied_at']!, _appliedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_appliedAtMeta);
    }
    if (data.containsKey('result')) {
      context.handle(
        _resultMeta,
        result.isAcceptableOrUnknown(data['result']!, _resultMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {idempotencyKey};
  @override
  CommandDedupData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CommandDedupData(
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      appliedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}applied_at'],
      )!,
      result: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result'],
      ),
    );
  }

  @override
  $CommandDedupTable createAlias(String alias) {
    return $CommandDedupTable(attachedDatabase, alias);
  }
}

class CommandDedupData extends DataClass
    implements Insertable<CommandDedupData> {
  final String idempotencyKey;
  final DateTime appliedAt;
  final String? result;
  const CommandDedupData({
    required this.idempotencyKey,
    required this.appliedAt,
    this.result,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['applied_at'] = Variable<DateTime>(appliedAt);
    if (!nullToAbsent || result != null) {
      map['result'] = Variable<String>(result);
    }
    return map;
  }

  CommandDedupCompanion toCompanion(bool nullToAbsent) {
    return CommandDedupCompanion(
      idempotencyKey: Value(idempotencyKey),
      appliedAt: Value(appliedAt),
      result: result == null && nullToAbsent
          ? const Value.absent()
          : Value(result),
    );
  }

  factory CommandDedupData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CommandDedupData(
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      appliedAt: serializer.fromJson<DateTime>(json['appliedAt']),
      result: serializer.fromJson<String?>(json['result']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'appliedAt': serializer.toJson<DateTime>(appliedAt),
      'result': serializer.toJson<String?>(result),
    };
  }

  CommandDedupData copyWith({
    String? idempotencyKey,
    DateTime? appliedAt,
    Value<String?> result = const Value.absent(),
  }) => CommandDedupData(
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    appliedAt: appliedAt ?? this.appliedAt,
    result: result.present ? result.value : this.result,
  );
  CommandDedupData copyWithCompanion(CommandDedupCompanion data) {
    return CommandDedupData(
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      appliedAt: data.appliedAt.present ? data.appliedAt.value : this.appliedAt,
      result: data.result.present ? data.result.value : this.result,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CommandDedupData(')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('result: $result')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(idempotencyKey, appliedAt, result);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommandDedupData &&
          other.idempotencyKey == this.idempotencyKey &&
          other.appliedAt == this.appliedAt &&
          other.result == this.result);
}

class CommandDedupCompanion extends UpdateCompanion<CommandDedupData> {
  final Value<String> idempotencyKey;
  final Value<DateTime> appliedAt;
  final Value<String?> result;
  final Value<int> rowid;
  const CommandDedupCompanion({
    this.idempotencyKey = const Value.absent(),
    this.appliedAt = const Value.absent(),
    this.result = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CommandDedupCompanion.insert({
    required String idempotencyKey,
    required DateTime appliedAt,
    this.result = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : idempotencyKey = Value(idempotencyKey),
       appliedAt = Value(appliedAt);
  static Insertable<CommandDedupData> custom({
    Expression<String>? idempotencyKey,
    Expression<DateTime>? appliedAt,
    Expression<String>? result,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (appliedAt != null) 'applied_at': appliedAt,
      if (result != null) 'result': result,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CommandDedupCompanion copyWith({
    Value<String>? idempotencyKey,
    Value<DateTime>? appliedAt,
    Value<String?>? result,
    Value<int>? rowid,
  }) {
    return CommandDedupCompanion(
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      appliedAt: appliedAt ?? this.appliedAt,
      result: result ?? this.result,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (appliedAt.present) {
      map['applied_at'] = Variable<DateTime>(appliedAt.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommandDedupCompanion(')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('result: $result, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedUsersTable extends CachedUsers
    with TableInfo<$CachedUsersTable, CachedUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneE164Meta = const VerificationMeta(
    'phoneE164',
  );
  @override
  late final GeneratedColumn<String> phoneE164 = GeneratedColumn<String>(
    'phone_e164',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en-KE'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _lastLoginAtMeta = const VerificationMeta(
    'lastLoginAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastLoginAt = GeneratedColumn<DateTime>(
    'last_login_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    phoneE164,
    email,
    displayName,
    role,
    locale,
    status,
    lastLoginAt,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedUser> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('phone_e164')) {
      context.handle(
        _phoneE164Meta,
        phoneE164.isAcceptableOrUnknown(data['phone_e164']!, _phoneE164Meta),
      );
    } else if (isInserting) {
      context.missing(_phoneE164Meta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('last_login_at')) {
      context.handle(
        _lastLoginAtMeta,
        lastLoginAt.isAcceptableOrUnknown(
          data['last_login_at']!,
          _lastLoginAtMeta,
        ),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedUser(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      phoneE164: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_e164'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      lastLoginAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_login_at'],
      ),
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedUsersTable createAlias(String alias) {
    return $CachedUsersTable(attachedDatabase, alias);
  }
}

class CachedUser extends DataClass implements Insertable<CachedUser> {
  final String id;
  final String tenantId;
  final String phoneE164;
  final String? email;
  final String? displayName;

  /// owner | member | viewer | installer  (tenant-wide)
  final String role;
  final String locale;
  final String status;
  final DateTime? lastLoginAt;
  final DateTime cachedAt;
  const CachedUser({
    required this.id,
    required this.tenantId,
    required this.phoneE164,
    this.email,
    this.displayName,
    required this.role,
    required this.locale,
    required this.status,
    this.lastLoginAt,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['phone_e164'] = Variable<String>(phoneE164);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    map['role'] = Variable<String>(role);
    map['locale'] = Variable<String>(locale);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || lastLoginAt != null) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedUsersCompanion toCompanion(bool nullToAbsent) {
    return CachedUsersCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      phoneE164: Value(phoneE164),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      role: Value(role),
      locale: Value(locale),
      status: Value(status),
      lastLoginAt: lastLoginAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLoginAt),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedUser.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedUser(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      phoneE164: serializer.fromJson<String>(json['phoneE164']),
      email: serializer.fromJson<String?>(json['email']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      role: serializer.fromJson<String>(json['role']),
      locale: serializer.fromJson<String>(json['locale']),
      status: serializer.fromJson<String>(json['status']),
      lastLoginAt: serializer.fromJson<DateTime?>(json['lastLoginAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'phoneE164': serializer.toJson<String>(phoneE164),
      'email': serializer.toJson<String?>(email),
      'displayName': serializer.toJson<String?>(displayName),
      'role': serializer.toJson<String>(role),
      'locale': serializer.toJson<String>(locale),
      'status': serializer.toJson<String>(status),
      'lastLoginAt': serializer.toJson<DateTime?>(lastLoginAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedUser copyWith({
    String? id,
    String? tenantId,
    String? phoneE164,
    Value<String?> email = const Value.absent(),
    Value<String?> displayName = const Value.absent(),
    String? role,
    String? locale,
    String? status,
    Value<DateTime?> lastLoginAt = const Value.absent(),
    DateTime? cachedAt,
  }) => CachedUser(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    phoneE164: phoneE164 ?? this.phoneE164,
    email: email.present ? email.value : this.email,
    displayName: displayName.present ? displayName.value : this.displayName,
    role: role ?? this.role,
    locale: locale ?? this.locale,
    status: status ?? this.status,
    lastLoginAt: lastLoginAt.present ? lastLoginAt.value : this.lastLoginAt,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CachedUser copyWithCompanion(CachedUsersCompanion data) {
    return CachedUser(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      phoneE164: data.phoneE164.present ? data.phoneE164.value : this.phoneE164,
      email: data.email.present ? data.email.value : this.email,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      role: data.role.present ? data.role.value : this.role,
      locale: data.locale.present ? data.locale.value : this.locale,
      status: data.status.present ? data.status.value : this.status,
      lastLoginAt: data.lastLoginAt.present
          ? data.lastLoginAt.value
          : this.lastLoginAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedUser(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('phoneE164: $phoneE164, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('role: $role, ')
          ..write('locale: $locale, ')
          ..write('status: $status, ')
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    phoneE164,
    email,
    displayName,
    role,
    locale,
    status,
    lastLoginAt,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedUser &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.phoneE164 == this.phoneE164 &&
          other.email == this.email &&
          other.displayName == this.displayName &&
          other.role == this.role &&
          other.locale == this.locale &&
          other.status == this.status &&
          other.lastLoginAt == this.lastLoginAt &&
          other.cachedAt == this.cachedAt);
}

class CachedUsersCompanion extends UpdateCompanion<CachedUser> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> phoneE164;
  final Value<String?> email;
  final Value<String?> displayName;
  final Value<String> role;
  final Value<String> locale;
  final Value<String> status;
  final Value<DateTime?> lastLoginAt;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedUsersCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.phoneE164 = const Value.absent(),
    this.email = const Value.absent(),
    this.displayName = const Value.absent(),
    this.role = const Value.absent(),
    this.locale = const Value.absent(),
    this.status = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedUsersCompanion.insert({
    required String id,
    required String tenantId,
    required String phoneE164,
    this.email = const Value.absent(),
    this.displayName = const Value.absent(),
    required String role,
    this.locale = const Value.absent(),
    this.status = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       phoneE164 = Value(phoneE164),
       role = Value(role),
       cachedAt = Value(cachedAt);
  static Insertable<CachedUser> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? phoneE164,
    Expression<String>? email,
    Expression<String>? displayName,
    Expression<String>? role,
    Expression<String>? locale,
    Expression<String>? status,
    Expression<DateTime>? lastLoginAt,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (phoneE164 != null) 'phone_e164': phoneE164,
      if (email != null) 'email': email,
      if (displayName != null) 'display_name': displayName,
      if (role != null) 'role': role,
      if (locale != null) 'locale': locale,
      if (status != null) 'status': status,
      if (lastLoginAt != null) 'last_login_at': lastLoginAt,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedUsersCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? phoneE164,
    Value<String?>? email,
    Value<String?>? displayName,
    Value<String>? role,
    Value<String>? locale,
    Value<String>? status,
    Value<DateTime?>? lastLoginAt,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CachedUsersCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      phoneE164: phoneE164 ?? this.phoneE164,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      locale: locale ?? this.locale,
      status: status ?? this.status,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (phoneE164.present) {
      map['phone_e164'] = Variable<String>(phoneE164.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (lastLoginAt.present) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedUsersCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('phoneE164: $phoneE164, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('role: $role, ')
          ..write('locale: $locale, ')
          ..write('status: $status, ')
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedSitesTable extends CachedSites
    with TableInfo<$CachedSitesTable, CachedSite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedSitesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Africa/Nairobi'),
  );
  static const VerificationMeta _meterTypeMeta = const VerificationMeta(
    'meterType',
  );
  @override
  late final GeneratedColumn<String> meterType = GeneratedColumn<String>(
    'meter_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kplcAccountNoMeta = const VerificationMeta(
    'kplcAccountNo',
  );
  @override
  late final GeneratedColumn<String> kplcAccountNo = GeneratedColumn<String>(
    'kplc_account_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kplcMeterNoMeta = const VerificationMeta(
    'kplcMeterNo',
  );
  @override
  late final GeneratedColumn<String> kplcMeterNo = GeneratedColumn<String>(
    'kplc_meter_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supplyPhaseMeta = const VerificationMeta(
    'supplyPhase',
  );
  @override
  late final GeneratedColumn<String> supplyPhase = GeneratedColumn<String>(
    'supply_phase',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('single'),
  );
  static const VerificationMeta _occupantCountMeta = const VerificationMeta(
    'occupantCount',
  );
  @override
  late final GeneratedColumn<int> occupantCount = GeneratedColumn<int>(
    'occupant_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _staticIpMeta = const VerificationMeta(
    'staticIp',
  );
  @override
  late final GeneratedColumn<String> staticIp = GeneratedColumn<String>(
    'static_ip',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localApiPortMeta = const VerificationMeta(
    'localApiPort',
  );
  @override
  late final GeneratedColumn<int> localApiPort = GeneratedColumn<int>(
    'local_api_port',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(8443),
  );
  static const VerificationMeta _allowLanCommandsMeta = const VerificationMeta(
    'allowLanCommands',
  );
  @override
  late final GeneratedColumn<bool> allowLanCommands = GeneratedColumn<bool>(
    'allow_lan_commands',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("allow_lan_commands" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _allowCloudCommandsMeta =
      const VerificationMeta('allowCloudCommands');
  @override
  late final GeneratedColumn<bool> allowCloudCommands = GeneratedColumn<bool>(
    'allow_cloud_commands',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("allow_cloud_commands" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    label,
    timezone,
    meterType,
    kplcAccountNo,
    kplcMeterNo,
    supplyPhase,
    occupantCount,
    status,
    staticIp,
    localApiPort,
    allowLanCommands,
    allowCloudCommands,
    createdAt,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_sites';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedSite> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    }
    if (data.containsKey('meter_type')) {
      context.handle(
        _meterTypeMeta,
        meterType.isAcceptableOrUnknown(data['meter_type']!, _meterTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_meterTypeMeta);
    }
    if (data.containsKey('kplc_account_no')) {
      context.handle(
        _kplcAccountNoMeta,
        kplcAccountNo.isAcceptableOrUnknown(
          data['kplc_account_no']!,
          _kplcAccountNoMeta,
        ),
      );
    }
    if (data.containsKey('kplc_meter_no')) {
      context.handle(
        _kplcMeterNoMeta,
        kplcMeterNo.isAcceptableOrUnknown(
          data['kplc_meter_no']!,
          _kplcMeterNoMeta,
        ),
      );
    }
    if (data.containsKey('supply_phase')) {
      context.handle(
        _supplyPhaseMeta,
        supplyPhase.isAcceptableOrUnknown(
          data['supply_phase']!,
          _supplyPhaseMeta,
        ),
      );
    }
    if (data.containsKey('occupant_count')) {
      context.handle(
        _occupantCountMeta,
        occupantCount.isAcceptableOrUnknown(
          data['occupant_count']!,
          _occupantCountMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('static_ip')) {
      context.handle(
        _staticIpMeta,
        staticIp.isAcceptableOrUnknown(data['static_ip']!, _staticIpMeta),
      );
    }
    if (data.containsKey('local_api_port')) {
      context.handle(
        _localApiPortMeta,
        localApiPort.isAcceptableOrUnknown(
          data['local_api_port']!,
          _localApiPortMeta,
        ),
      );
    }
    if (data.containsKey('allow_lan_commands')) {
      context.handle(
        _allowLanCommandsMeta,
        allowLanCommands.isAcceptableOrUnknown(
          data['allow_lan_commands']!,
          _allowLanCommandsMeta,
        ),
      );
    }
    if (data.containsKey('allow_cloud_commands')) {
      context.handle(
        _allowCloudCommandsMeta,
        allowCloudCommands.isAcceptableOrUnknown(
          data['allow_cloud_commands']!,
          _allowCloudCommandsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedSite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedSite(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      meterType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meter_type'],
      )!,
      kplcAccountNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kplc_account_no'],
      ),
      kplcMeterNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kplc_meter_no'],
      ),
      supplyPhase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supply_phase'],
      )!,
      occupantCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occupant_count'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      staticIp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}static_ip'],
      ),
      localApiPort: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_api_port'],
      )!,
      allowLanCommands: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allow_lan_commands'],
      )!,
      allowCloudCommands: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allow_cloud_commands'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedSitesTable createAlias(String alias) {
    return $CachedSitesTable(attachedDatabase, alias);
  }
}

class CachedSite extends DataClass implements Insertable<CachedSite> {
  final String id;
  final String tenantId;
  final String label;
  final String timezone;
  final String meterType;
  final String? kplcAccountNo;
  final String? kplcMeterNo;
  final String supplyPhase;
  final int? occupantCount;
  final String status;
  final String? staticIp;
  final int localApiPort;
  final bool allowLanCommands;
  final bool allowCloudCommands;
  final DateTime? createdAt;
  final DateTime cachedAt;
  const CachedSite({
    required this.id,
    required this.tenantId,
    required this.label,
    required this.timezone,
    required this.meterType,
    this.kplcAccountNo,
    this.kplcMeterNo,
    required this.supplyPhase,
    this.occupantCount,
    required this.status,
    this.staticIp,
    required this.localApiPort,
    required this.allowLanCommands,
    required this.allowCloudCommands,
    this.createdAt,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['label'] = Variable<String>(label);
    map['timezone'] = Variable<String>(timezone);
    map['meter_type'] = Variable<String>(meterType);
    if (!nullToAbsent || kplcAccountNo != null) {
      map['kplc_account_no'] = Variable<String>(kplcAccountNo);
    }
    if (!nullToAbsent || kplcMeterNo != null) {
      map['kplc_meter_no'] = Variable<String>(kplcMeterNo);
    }
    map['supply_phase'] = Variable<String>(supplyPhase);
    if (!nullToAbsent || occupantCount != null) {
      map['occupant_count'] = Variable<int>(occupantCount);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || staticIp != null) {
      map['static_ip'] = Variable<String>(staticIp);
    }
    map['local_api_port'] = Variable<int>(localApiPort);
    map['allow_lan_commands'] = Variable<bool>(allowLanCommands);
    map['allow_cloud_commands'] = Variable<bool>(allowCloudCommands);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedSitesCompanion toCompanion(bool nullToAbsent) {
    return CachedSitesCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      label: Value(label),
      timezone: Value(timezone),
      meterType: Value(meterType),
      kplcAccountNo: kplcAccountNo == null && nullToAbsent
          ? const Value.absent()
          : Value(kplcAccountNo),
      kplcMeterNo: kplcMeterNo == null && nullToAbsent
          ? const Value.absent()
          : Value(kplcMeterNo),
      supplyPhase: Value(supplyPhase),
      occupantCount: occupantCount == null && nullToAbsent
          ? const Value.absent()
          : Value(occupantCount),
      status: Value(status),
      staticIp: staticIp == null && nullToAbsent
          ? const Value.absent()
          : Value(staticIp),
      localApiPort: Value(localApiPort),
      allowLanCommands: Value(allowLanCommands),
      allowCloudCommands: Value(allowCloudCommands),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedSite.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedSite(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      label: serializer.fromJson<String>(json['label']),
      timezone: serializer.fromJson<String>(json['timezone']),
      meterType: serializer.fromJson<String>(json['meterType']),
      kplcAccountNo: serializer.fromJson<String?>(json['kplcAccountNo']),
      kplcMeterNo: serializer.fromJson<String?>(json['kplcMeterNo']),
      supplyPhase: serializer.fromJson<String>(json['supplyPhase']),
      occupantCount: serializer.fromJson<int?>(json['occupantCount']),
      status: serializer.fromJson<String>(json['status']),
      staticIp: serializer.fromJson<String?>(json['staticIp']),
      localApiPort: serializer.fromJson<int>(json['localApiPort']),
      allowLanCommands: serializer.fromJson<bool>(json['allowLanCommands']),
      allowCloudCommands: serializer.fromJson<bool>(json['allowCloudCommands']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'label': serializer.toJson<String>(label),
      'timezone': serializer.toJson<String>(timezone),
      'meterType': serializer.toJson<String>(meterType),
      'kplcAccountNo': serializer.toJson<String?>(kplcAccountNo),
      'kplcMeterNo': serializer.toJson<String?>(kplcMeterNo),
      'supplyPhase': serializer.toJson<String>(supplyPhase),
      'occupantCount': serializer.toJson<int?>(occupantCount),
      'status': serializer.toJson<String>(status),
      'staticIp': serializer.toJson<String?>(staticIp),
      'localApiPort': serializer.toJson<int>(localApiPort),
      'allowLanCommands': serializer.toJson<bool>(allowLanCommands),
      'allowCloudCommands': serializer.toJson<bool>(allowCloudCommands),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedSite copyWith({
    String? id,
    String? tenantId,
    String? label,
    String? timezone,
    String? meterType,
    Value<String?> kplcAccountNo = const Value.absent(),
    Value<String?> kplcMeterNo = const Value.absent(),
    String? supplyPhase,
    Value<int?> occupantCount = const Value.absent(),
    String? status,
    Value<String?> staticIp = const Value.absent(),
    int? localApiPort,
    bool? allowLanCommands,
    bool? allowCloudCommands,
    Value<DateTime?> createdAt = const Value.absent(),
    DateTime? cachedAt,
  }) => CachedSite(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    label: label ?? this.label,
    timezone: timezone ?? this.timezone,
    meterType: meterType ?? this.meterType,
    kplcAccountNo: kplcAccountNo.present
        ? kplcAccountNo.value
        : this.kplcAccountNo,
    kplcMeterNo: kplcMeterNo.present ? kplcMeterNo.value : this.kplcMeterNo,
    supplyPhase: supplyPhase ?? this.supplyPhase,
    occupantCount: occupantCount.present
        ? occupantCount.value
        : this.occupantCount,
    status: status ?? this.status,
    staticIp: staticIp.present ? staticIp.value : this.staticIp,
    localApiPort: localApiPort ?? this.localApiPort,
    allowLanCommands: allowLanCommands ?? this.allowLanCommands,
    allowCloudCommands: allowCloudCommands ?? this.allowCloudCommands,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CachedSite copyWithCompanion(CachedSitesCompanion data) {
    return CachedSite(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      label: data.label.present ? data.label.value : this.label,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      meterType: data.meterType.present ? data.meterType.value : this.meterType,
      kplcAccountNo: data.kplcAccountNo.present
          ? data.kplcAccountNo.value
          : this.kplcAccountNo,
      kplcMeterNo: data.kplcMeterNo.present
          ? data.kplcMeterNo.value
          : this.kplcMeterNo,
      supplyPhase: data.supplyPhase.present
          ? data.supplyPhase.value
          : this.supplyPhase,
      occupantCount: data.occupantCount.present
          ? data.occupantCount.value
          : this.occupantCount,
      status: data.status.present ? data.status.value : this.status,
      staticIp: data.staticIp.present ? data.staticIp.value : this.staticIp,
      localApiPort: data.localApiPort.present
          ? data.localApiPort.value
          : this.localApiPort,
      allowLanCommands: data.allowLanCommands.present
          ? data.allowLanCommands.value
          : this.allowLanCommands,
      allowCloudCommands: data.allowCloudCommands.present
          ? data.allowCloudCommands.value
          : this.allowCloudCommands,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedSite(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('label: $label, ')
          ..write('timezone: $timezone, ')
          ..write('meterType: $meterType, ')
          ..write('kplcAccountNo: $kplcAccountNo, ')
          ..write('kplcMeterNo: $kplcMeterNo, ')
          ..write('supplyPhase: $supplyPhase, ')
          ..write('occupantCount: $occupantCount, ')
          ..write('status: $status, ')
          ..write('staticIp: $staticIp, ')
          ..write('localApiPort: $localApiPort, ')
          ..write('allowLanCommands: $allowLanCommands, ')
          ..write('allowCloudCommands: $allowCloudCommands, ')
          ..write('createdAt: $createdAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    label,
    timezone,
    meterType,
    kplcAccountNo,
    kplcMeterNo,
    supplyPhase,
    occupantCount,
    status,
    staticIp,
    localApiPort,
    allowLanCommands,
    allowCloudCommands,
    createdAt,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedSite &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.label == this.label &&
          other.timezone == this.timezone &&
          other.meterType == this.meterType &&
          other.kplcAccountNo == this.kplcAccountNo &&
          other.kplcMeterNo == this.kplcMeterNo &&
          other.supplyPhase == this.supplyPhase &&
          other.occupantCount == this.occupantCount &&
          other.status == this.status &&
          other.staticIp == this.staticIp &&
          other.localApiPort == this.localApiPort &&
          other.allowLanCommands == this.allowLanCommands &&
          other.allowCloudCommands == this.allowCloudCommands &&
          other.createdAt == this.createdAt &&
          other.cachedAt == this.cachedAt);
}

class CachedSitesCompanion extends UpdateCompanion<CachedSite> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> label;
  final Value<String> timezone;
  final Value<String> meterType;
  final Value<String?> kplcAccountNo;
  final Value<String?> kplcMeterNo;
  final Value<String> supplyPhase;
  final Value<int?> occupantCount;
  final Value<String> status;
  final Value<String?> staticIp;
  final Value<int> localApiPort;
  final Value<bool> allowLanCommands;
  final Value<bool> allowCloudCommands;
  final Value<DateTime?> createdAt;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedSitesCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.label = const Value.absent(),
    this.timezone = const Value.absent(),
    this.meterType = const Value.absent(),
    this.kplcAccountNo = const Value.absent(),
    this.kplcMeterNo = const Value.absent(),
    this.supplyPhase = const Value.absent(),
    this.occupantCount = const Value.absent(),
    this.status = const Value.absent(),
    this.staticIp = const Value.absent(),
    this.localApiPort = const Value.absent(),
    this.allowLanCommands = const Value.absent(),
    this.allowCloudCommands = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedSitesCompanion.insert({
    required String id,
    required String tenantId,
    required String label,
    this.timezone = const Value.absent(),
    required String meterType,
    this.kplcAccountNo = const Value.absent(),
    this.kplcMeterNo = const Value.absent(),
    this.supplyPhase = const Value.absent(),
    this.occupantCount = const Value.absent(),
    this.status = const Value.absent(),
    this.staticIp = const Value.absent(),
    this.localApiPort = const Value.absent(),
    this.allowLanCommands = const Value.absent(),
    this.allowCloudCommands = const Value.absent(),
    this.createdAt = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       label = Value(label),
       meterType = Value(meterType),
       cachedAt = Value(cachedAt);
  static Insertable<CachedSite> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? label,
    Expression<String>? timezone,
    Expression<String>? meterType,
    Expression<String>? kplcAccountNo,
    Expression<String>? kplcMeterNo,
    Expression<String>? supplyPhase,
    Expression<int>? occupantCount,
    Expression<String>? status,
    Expression<String>? staticIp,
    Expression<int>? localApiPort,
    Expression<bool>? allowLanCommands,
    Expression<bool>? allowCloudCommands,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (label != null) 'label': label,
      if (timezone != null) 'timezone': timezone,
      if (meterType != null) 'meter_type': meterType,
      if (kplcAccountNo != null) 'kplc_account_no': kplcAccountNo,
      if (kplcMeterNo != null) 'kplc_meter_no': kplcMeterNo,
      if (supplyPhase != null) 'supply_phase': supplyPhase,
      if (occupantCount != null) 'occupant_count': occupantCount,
      if (status != null) 'status': status,
      if (staticIp != null) 'static_ip': staticIp,
      if (localApiPort != null) 'local_api_port': localApiPort,
      if (allowLanCommands != null) 'allow_lan_commands': allowLanCommands,
      if (allowCloudCommands != null)
        'allow_cloud_commands': allowCloudCommands,
      if (createdAt != null) 'created_at': createdAt,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedSitesCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? label,
    Value<String>? timezone,
    Value<String>? meterType,
    Value<String?>? kplcAccountNo,
    Value<String?>? kplcMeterNo,
    Value<String>? supplyPhase,
    Value<int?>? occupantCount,
    Value<String>? status,
    Value<String?>? staticIp,
    Value<int>? localApiPort,
    Value<bool>? allowLanCommands,
    Value<bool>? allowCloudCommands,
    Value<DateTime?>? createdAt,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CachedSitesCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      label: label ?? this.label,
      timezone: timezone ?? this.timezone,
      meterType: meterType ?? this.meterType,
      kplcAccountNo: kplcAccountNo ?? this.kplcAccountNo,
      kplcMeterNo: kplcMeterNo ?? this.kplcMeterNo,
      supplyPhase: supplyPhase ?? this.supplyPhase,
      occupantCount: occupantCount ?? this.occupantCount,
      status: status ?? this.status,
      staticIp: staticIp ?? this.staticIp,
      localApiPort: localApiPort ?? this.localApiPort,
      allowLanCommands: allowLanCommands ?? this.allowLanCommands,
      allowCloudCommands: allowCloudCommands ?? this.allowCloudCommands,
      createdAt: createdAt ?? this.createdAt,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (meterType.present) {
      map['meter_type'] = Variable<String>(meterType.value);
    }
    if (kplcAccountNo.present) {
      map['kplc_account_no'] = Variable<String>(kplcAccountNo.value);
    }
    if (kplcMeterNo.present) {
      map['kplc_meter_no'] = Variable<String>(kplcMeterNo.value);
    }
    if (supplyPhase.present) {
      map['supply_phase'] = Variable<String>(supplyPhase.value);
    }
    if (occupantCount.present) {
      map['occupant_count'] = Variable<int>(occupantCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (staticIp.present) {
      map['static_ip'] = Variable<String>(staticIp.value);
    }
    if (localApiPort.present) {
      map['local_api_port'] = Variable<int>(localApiPort.value);
    }
    if (allowLanCommands.present) {
      map['allow_lan_commands'] = Variable<bool>(allowLanCommands.value);
    }
    if (allowCloudCommands.present) {
      map['allow_cloud_commands'] = Variable<bool>(allowCloudCommands.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedSitesCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('label: $label, ')
          ..write('timezone: $timezone, ')
          ..write('meterType: $meterType, ')
          ..write('kplcAccountNo: $kplcAccountNo, ')
          ..write('kplcMeterNo: $kplcMeterNo, ')
          ..write('supplyPhase: $supplyPhase, ')
          ..write('occupantCount: $occupantCount, ')
          ..write('status: $status, ')
          ..write('staticIp: $staticIp, ')
          ..write('localApiPort: $localApiPort, ')
          ..write('allowLanCommands: $allowLanCommands, ')
          ..write('allowCloudCommands: $allowCloudCommands, ')
          ..write('createdAt: $createdAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedRoomsTable extends CachedRooms
    with TableInfo<$CachedRoomsTable, CachedRoom> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedRoomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _siteIdMeta = const VerificationMeta('siteId');
  @override
  late final GeneratedColumn<String> siteId = GeneratedColumn<String>(
    'site_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roomTypeMeta = const VerificationMeta(
    'roomType',
  );
  @override
  late final GeneratedColumn<String> roomType = GeneratedColumn<String>(
    'room_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, siteId, name, roomType, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_rooms';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedRoom> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('site_id')) {
      context.handle(
        _siteIdMeta,
        siteId.isAcceptableOrUnknown(data['site_id']!, _siteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_siteIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('room_type')) {
      context.handle(
        _roomTypeMeta,
        roomType.isAcceptableOrUnknown(data['room_type']!, _roomTypeMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedRoom map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedRoom(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      siteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      roomType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_type'],
      ),
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedRoomsTable createAlias(String alias) {
    return $CachedRoomsTable(attachedDatabase, alias);
  }
}

class CachedRoom extends DataClass implements Insertable<CachedRoom> {
  final String id;
  final String siteId;
  final String name;
  final String? roomType;
  final DateTime cachedAt;
  const CachedRoom({
    required this.id,
    required this.siteId,
    required this.name,
    this.roomType,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['site_id'] = Variable<String>(siteId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || roomType != null) {
      map['room_type'] = Variable<String>(roomType);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedRoomsCompanion toCompanion(bool nullToAbsent) {
    return CachedRoomsCompanion(
      id: Value(id),
      siteId: Value(siteId),
      name: Value(name),
      roomType: roomType == null && nullToAbsent
          ? const Value.absent()
          : Value(roomType),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedRoom.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedRoom(
      id: serializer.fromJson<String>(json['id']),
      siteId: serializer.fromJson<String>(json['siteId']),
      name: serializer.fromJson<String>(json['name']),
      roomType: serializer.fromJson<String?>(json['roomType']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'siteId': serializer.toJson<String>(siteId),
      'name': serializer.toJson<String>(name),
      'roomType': serializer.toJson<String?>(roomType),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedRoom copyWith({
    String? id,
    String? siteId,
    String? name,
    Value<String?> roomType = const Value.absent(),
    DateTime? cachedAt,
  }) => CachedRoom(
    id: id ?? this.id,
    siteId: siteId ?? this.siteId,
    name: name ?? this.name,
    roomType: roomType.present ? roomType.value : this.roomType,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CachedRoom copyWithCompanion(CachedRoomsCompanion data) {
    return CachedRoom(
      id: data.id.present ? data.id.value : this.id,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      name: data.name.present ? data.name.value : this.name,
      roomType: data.roomType.present ? data.roomType.value : this.roomType,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedRoom(')
          ..write('id: $id, ')
          ..write('siteId: $siteId, ')
          ..write('name: $name, ')
          ..write('roomType: $roomType, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, siteId, name, roomType, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedRoom &&
          other.id == this.id &&
          other.siteId == this.siteId &&
          other.name == this.name &&
          other.roomType == this.roomType &&
          other.cachedAt == this.cachedAt);
}

class CachedRoomsCompanion extends UpdateCompanion<CachedRoom> {
  final Value<String> id;
  final Value<String> siteId;
  final Value<String> name;
  final Value<String?> roomType;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedRoomsCompanion({
    this.id = const Value.absent(),
    this.siteId = const Value.absent(),
    this.name = const Value.absent(),
    this.roomType = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedRoomsCompanion.insert({
    required String id,
    required String siteId,
    required String name,
    this.roomType = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       siteId = Value(siteId),
       name = Value(name),
       cachedAt = Value(cachedAt);
  static Insertable<CachedRoom> custom({
    Expression<String>? id,
    Expression<String>? siteId,
    Expression<String>? name,
    Expression<String>? roomType,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (siteId != null) 'site_id': siteId,
      if (name != null) 'name': name,
      if (roomType != null) 'room_type': roomType,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedRoomsCompanion copyWith({
    Value<String>? id,
    Value<String>? siteId,
    Value<String>? name,
    Value<String?>? roomType,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CachedRoomsCompanion(
      id: id ?? this.id,
      siteId: siteId ?? this.siteId,
      name: name ?? this.name,
      roomType: roomType ?? this.roomType,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (siteId.present) {
      map['site_id'] = Variable<String>(siteId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (roomType.present) {
      map['room_type'] = Variable<String>(roomType.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedRoomsCompanion(')
          ..write('id: $id, ')
          ..write('siteId: $siteId, ')
          ..write('name: $name, ')
          ..write('roomType: $roomType, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedSiteMembersTable extends CachedSiteMembers
    with TableInfo<$CachedSiteMembersTable, CachedSiteMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedSiteMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _siteIdMeta = const VerificationMeta('siteId');
  @override
  late final GeneratedColumn<String> siteId = GeneratedColumn<String>(
    'site_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneE164Meta = const VerificationMeta(
    'phoneE164',
  );
  @override
  late final GeneratedColumn<String> phoneE164 = GeneratedColumn<String>(
    'phone_e164',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _grantedByMeta = const VerificationMeta(
    'grantedBy',
  );
  @override
  late final GeneratedColumn<String> grantedBy = GeneratedColumn<String>(
    'granted_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _grantedAtMeta = const VerificationMeta(
    'grantedAt',
  );
  @override
  late final GeneratedColumn<DateTime> grantedAt = GeneratedColumn<DateTime>(
    'granted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revokedAtMeta = const VerificationMeta(
    'revokedAt',
  );
  @override
  late final GeneratedColumn<DateTime> revokedAt = GeneratedColumn<DateTime>(
    'revoked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    siteId,
    userId,
    phoneE164,
    displayName,
    role,
    grantedBy,
    grantedAt,
    revokedAt,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_site_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedSiteMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('site_id')) {
      context.handle(
        _siteIdMeta,
        siteId.isAcceptableOrUnknown(data['site_id']!, _siteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_siteIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('phone_e164')) {
      context.handle(
        _phoneE164Meta,
        phoneE164.isAcceptableOrUnknown(data['phone_e164']!, _phoneE164Meta),
      );
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('granted_by')) {
      context.handle(
        _grantedByMeta,
        grantedBy.isAcceptableOrUnknown(data['granted_by']!, _grantedByMeta),
      );
    }
    if (data.containsKey('granted_at')) {
      context.handle(
        _grantedAtMeta,
        grantedAt.isAcceptableOrUnknown(data['granted_at']!, _grantedAtMeta),
      );
    }
    if (data.containsKey('revoked_at')) {
      context.handle(
        _revokedAtMeta,
        revokedAt.isAcceptableOrUnknown(data['revoked_at']!, _revokedAtMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedSiteMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedSiteMember(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      siteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      phoneE164: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_e164'],
      ),
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      grantedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}granted_by'],
      ),
      grantedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}granted_at'],
      ),
      revokedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}revoked_at'],
      ),
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedSiteMembersTable createAlias(String alias) {
    return $CachedSiteMembersTable(attachedDatabase, alias);
  }
}

class CachedSiteMember extends DataClass
    implements Insertable<CachedSiteMember> {
  final int id;
  final String siteId;
  final String userId;
  final String? phoneE164;
  final String? displayName;
  final String role;
  final String? grantedBy;
  final DateTime? grantedAt;
  final DateTime? revokedAt;
  final DateTime cachedAt;
  const CachedSiteMember({
    required this.id,
    required this.siteId,
    required this.userId,
    this.phoneE164,
    this.displayName,
    required this.role,
    this.grantedBy,
    this.grantedAt,
    this.revokedAt,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['site_id'] = Variable<String>(siteId);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || phoneE164 != null) {
      map['phone_e164'] = Variable<String>(phoneE164);
    }
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || grantedBy != null) {
      map['granted_by'] = Variable<String>(grantedBy);
    }
    if (!nullToAbsent || grantedAt != null) {
      map['granted_at'] = Variable<DateTime>(grantedAt);
    }
    if (!nullToAbsent || revokedAt != null) {
      map['revoked_at'] = Variable<DateTime>(revokedAt);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedSiteMembersCompanion toCompanion(bool nullToAbsent) {
    return CachedSiteMembersCompanion(
      id: Value(id),
      siteId: Value(siteId),
      userId: Value(userId),
      phoneE164: phoneE164 == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneE164),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      role: Value(role),
      grantedBy: grantedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(grantedBy),
      grantedAt: grantedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(grantedAt),
      revokedAt: revokedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(revokedAt),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedSiteMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedSiteMember(
      id: serializer.fromJson<int>(json['id']),
      siteId: serializer.fromJson<String>(json['siteId']),
      userId: serializer.fromJson<String>(json['userId']),
      phoneE164: serializer.fromJson<String?>(json['phoneE164']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      role: serializer.fromJson<String>(json['role']),
      grantedBy: serializer.fromJson<String?>(json['grantedBy']),
      grantedAt: serializer.fromJson<DateTime?>(json['grantedAt']),
      revokedAt: serializer.fromJson<DateTime?>(json['revokedAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'siteId': serializer.toJson<String>(siteId),
      'userId': serializer.toJson<String>(userId),
      'phoneE164': serializer.toJson<String?>(phoneE164),
      'displayName': serializer.toJson<String?>(displayName),
      'role': serializer.toJson<String>(role),
      'grantedBy': serializer.toJson<String?>(grantedBy),
      'grantedAt': serializer.toJson<DateTime?>(grantedAt),
      'revokedAt': serializer.toJson<DateTime?>(revokedAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedSiteMember copyWith({
    int? id,
    String? siteId,
    String? userId,
    Value<String?> phoneE164 = const Value.absent(),
    Value<String?> displayName = const Value.absent(),
    String? role,
    Value<String?> grantedBy = const Value.absent(),
    Value<DateTime?> grantedAt = const Value.absent(),
    Value<DateTime?> revokedAt = const Value.absent(),
    DateTime? cachedAt,
  }) => CachedSiteMember(
    id: id ?? this.id,
    siteId: siteId ?? this.siteId,
    userId: userId ?? this.userId,
    phoneE164: phoneE164.present ? phoneE164.value : this.phoneE164,
    displayName: displayName.present ? displayName.value : this.displayName,
    role: role ?? this.role,
    grantedBy: grantedBy.present ? grantedBy.value : this.grantedBy,
    grantedAt: grantedAt.present ? grantedAt.value : this.grantedAt,
    revokedAt: revokedAt.present ? revokedAt.value : this.revokedAt,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CachedSiteMember copyWithCompanion(CachedSiteMembersCompanion data) {
    return CachedSiteMember(
      id: data.id.present ? data.id.value : this.id,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      userId: data.userId.present ? data.userId.value : this.userId,
      phoneE164: data.phoneE164.present ? data.phoneE164.value : this.phoneE164,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      role: data.role.present ? data.role.value : this.role,
      grantedBy: data.grantedBy.present ? data.grantedBy.value : this.grantedBy,
      grantedAt: data.grantedAt.present ? data.grantedAt.value : this.grantedAt,
      revokedAt: data.revokedAt.present ? data.revokedAt.value : this.revokedAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedSiteMember(')
          ..write('id: $id, ')
          ..write('siteId: $siteId, ')
          ..write('userId: $userId, ')
          ..write('phoneE164: $phoneE164, ')
          ..write('displayName: $displayName, ')
          ..write('role: $role, ')
          ..write('grantedBy: $grantedBy, ')
          ..write('grantedAt: $grantedAt, ')
          ..write('revokedAt: $revokedAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    siteId,
    userId,
    phoneE164,
    displayName,
    role,
    grantedBy,
    grantedAt,
    revokedAt,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedSiteMember &&
          other.id == this.id &&
          other.siteId == this.siteId &&
          other.userId == this.userId &&
          other.phoneE164 == this.phoneE164 &&
          other.displayName == this.displayName &&
          other.role == this.role &&
          other.grantedBy == this.grantedBy &&
          other.grantedAt == this.grantedAt &&
          other.revokedAt == this.revokedAt &&
          other.cachedAt == this.cachedAt);
}

class CachedSiteMembersCompanion extends UpdateCompanion<CachedSiteMember> {
  final Value<int> id;
  final Value<String> siteId;
  final Value<String> userId;
  final Value<String?> phoneE164;
  final Value<String?> displayName;
  final Value<String> role;
  final Value<String?> grantedBy;
  final Value<DateTime?> grantedAt;
  final Value<DateTime?> revokedAt;
  final Value<DateTime> cachedAt;
  const CachedSiteMembersCompanion({
    this.id = const Value.absent(),
    this.siteId = const Value.absent(),
    this.userId = const Value.absent(),
    this.phoneE164 = const Value.absent(),
    this.displayName = const Value.absent(),
    this.role = const Value.absent(),
    this.grantedBy = const Value.absent(),
    this.grantedAt = const Value.absent(),
    this.revokedAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  CachedSiteMembersCompanion.insert({
    this.id = const Value.absent(),
    required String siteId,
    required String userId,
    this.phoneE164 = const Value.absent(),
    this.displayName = const Value.absent(),
    required String role,
    this.grantedBy = const Value.absent(),
    this.grantedAt = const Value.absent(),
    this.revokedAt = const Value.absent(),
    required DateTime cachedAt,
  }) : siteId = Value(siteId),
       userId = Value(userId),
       role = Value(role),
       cachedAt = Value(cachedAt);
  static Insertable<CachedSiteMember> custom({
    Expression<int>? id,
    Expression<String>? siteId,
    Expression<String>? userId,
    Expression<String>? phoneE164,
    Expression<String>? displayName,
    Expression<String>? role,
    Expression<String>? grantedBy,
    Expression<DateTime>? grantedAt,
    Expression<DateTime>? revokedAt,
    Expression<DateTime>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (siteId != null) 'site_id': siteId,
      if (userId != null) 'user_id': userId,
      if (phoneE164 != null) 'phone_e164': phoneE164,
      if (displayName != null) 'display_name': displayName,
      if (role != null) 'role': role,
      if (grantedBy != null) 'granted_by': grantedBy,
      if (grantedAt != null) 'granted_at': grantedAt,
      if (revokedAt != null) 'revoked_at': revokedAt,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  CachedSiteMembersCompanion copyWith({
    Value<int>? id,
    Value<String>? siteId,
    Value<String>? userId,
    Value<String?>? phoneE164,
    Value<String?>? displayName,
    Value<String>? role,
    Value<String?>? grantedBy,
    Value<DateTime?>? grantedAt,
    Value<DateTime?>? revokedAt,
    Value<DateTime>? cachedAt,
  }) {
    return CachedSiteMembersCompanion(
      id: id ?? this.id,
      siteId: siteId ?? this.siteId,
      userId: userId ?? this.userId,
      phoneE164: phoneE164 ?? this.phoneE164,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      grantedBy: grantedBy ?? this.grantedBy,
      grantedAt: grantedAt ?? this.grantedAt,
      revokedAt: revokedAt ?? this.revokedAt,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (siteId.present) {
      map['site_id'] = Variable<String>(siteId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (phoneE164.present) {
      map['phone_e164'] = Variable<String>(phoneE164.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (grantedBy.present) {
      map['granted_by'] = Variable<String>(grantedBy.value);
    }
    if (grantedAt.present) {
      map['granted_at'] = Variable<DateTime>(grantedAt.value);
    }
    if (revokedAt.present) {
      map['revoked_at'] = Variable<DateTime>(revokedAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedSiteMembersCompanion(')
          ..write('id: $id, ')
          ..write('siteId: $siteId, ')
          ..write('userId: $userId, ')
          ..write('phoneE164: $phoneE164, ')
          ..write('displayName: $displayName, ')
          ..write('role: $role, ')
          ..write('grantedBy: $grantedBy, ')
          ..write('grantedAt: $grantedAt, ')
          ..write('revokedAt: $revokedAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

class $CachedDevicesTable extends CachedDevices
    with TableInfo<$CachedDevicesTable, CachedDevice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedDevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _siteIdMeta = const VerificationMeta('siteId');
  @override
  late final GeneratedColumn<String> siteId = GeneratedColumn<String>(
    'site_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceClassMeta = const VerificationMeta(
    'deviceClass',
  );
  @override
  late final GeneratedColumn<String> deviceClass = GeneratedColumn<String>(
    'device_class',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
    'room_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roomNameMeta = const VerificationMeta(
    'roomName',
  );
  @override
  late final GeneratedColumn<String> roomName = GeneratedColumn<String>(
    'room_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _relayStateMeta = const VerificationMeta(
    'relayState',
  );
  @override
  late final GeneratedColumn<bool> relayState = GeneratedColumn<bool>(
    'relay_state',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("relay_state" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reachableMeta = const VerificationMeta(
    'reachable',
  );
  @override
  late final GeneratedColumn<bool> reachable = GeneratedColumn<bool>(
    'reachable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reachable" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _switchableMeta = const VerificationMeta(
    'switchable',
  );
  @override
  late final GeneratedColumn<bool> switchable = GeneratedColumn<bool>(
    'switchable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("switchable" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _wattsMeta = const VerificationMeta('watts');
  @override
  late final GeneratedColumn<double> watts = GeneratedColumn<double>(
    'watts',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _voltsMeta = const VerificationMeta('volts');
  @override
  late final GeneratedColumn<double> volts = GeneratedColumn<double>(
    'volts',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ampsMeta = const VerificationMeta('amps');
  @override
  late final GeneratedColumn<double> amps = GeneratedColumn<double>(
    'amps',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    siteId,
    name,
    deviceClass,
    roomId,
    roomName,
    relayState,
    reachable,
    switchable,
    watts,
    volts,
    amps,
    lastSeenAt,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedDevice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('site_id')) {
      context.handle(
        _siteIdMeta,
        siteId.isAcceptableOrUnknown(data['site_id']!, _siteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_siteIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('device_class')) {
      context.handle(
        _deviceClassMeta,
        deviceClass.isAcceptableOrUnknown(
          data['device_class']!,
          _deviceClassMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deviceClassMeta);
    }
    if (data.containsKey('room_id')) {
      context.handle(
        _roomIdMeta,
        roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta),
      );
    }
    if (data.containsKey('room_name')) {
      context.handle(
        _roomNameMeta,
        roomName.isAcceptableOrUnknown(data['room_name']!, _roomNameMeta),
      );
    }
    if (data.containsKey('relay_state')) {
      context.handle(
        _relayStateMeta,
        relayState.isAcceptableOrUnknown(data['relay_state']!, _relayStateMeta),
      );
    }
    if (data.containsKey('reachable')) {
      context.handle(
        _reachableMeta,
        reachable.isAcceptableOrUnknown(data['reachable']!, _reachableMeta),
      );
    }
    if (data.containsKey('switchable')) {
      context.handle(
        _switchableMeta,
        switchable.isAcceptableOrUnknown(data['switchable']!, _switchableMeta),
      );
    }
    if (data.containsKey('watts')) {
      context.handle(
        _wattsMeta,
        watts.isAcceptableOrUnknown(data['watts']!, _wattsMeta),
      );
    }
    if (data.containsKey('volts')) {
      context.handle(
        _voltsMeta,
        volts.isAcceptableOrUnknown(data['volts']!, _voltsMeta),
      );
    }
    if (data.containsKey('amps')) {
      context.handle(
        _ampsMeta,
        amps.isAcceptableOrUnknown(data['amps']!, _ampsMeta),
      );
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedDevice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedDevice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      siteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      deviceClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_class'],
      )!,
      roomId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_id'],
      ),
      roomName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_name'],
      ),
      relayState: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}relay_state'],
      )!,
      reachable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reachable'],
      )!,
      switchable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}switchable'],
      )!,
      watts: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}watts'],
      )!,
      volts: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}volts'],
      ),
      amps: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amps'],
      ),
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      ),
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedDevicesTable createAlias(String alias) {
    return $CachedDevicesTable(attachedDatabase, alias);
  }
}

class CachedDevice extends DataClass implements Insertable<CachedDevice> {
  final String id;
  final String siteId;
  final String name;
  final String deviceClass;
  final String? roomId;
  final String? roomName;
  final bool relayState;
  final bool reachable;
  final bool switchable;
  final double watts;
  final double? volts;
  final double? amps;
  final DateTime? lastSeenAt;
  final DateTime cachedAt;
  const CachedDevice({
    required this.id,
    required this.siteId,
    required this.name,
    required this.deviceClass,
    this.roomId,
    this.roomName,
    required this.relayState,
    required this.reachable,
    required this.switchable,
    required this.watts,
    this.volts,
    this.amps,
    this.lastSeenAt,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['site_id'] = Variable<String>(siteId);
    map['name'] = Variable<String>(name);
    map['device_class'] = Variable<String>(deviceClass);
    if (!nullToAbsent || roomId != null) {
      map['room_id'] = Variable<String>(roomId);
    }
    if (!nullToAbsent || roomName != null) {
      map['room_name'] = Variable<String>(roomName);
    }
    map['relay_state'] = Variable<bool>(relayState);
    map['reachable'] = Variable<bool>(reachable);
    map['switchable'] = Variable<bool>(switchable);
    map['watts'] = Variable<double>(watts);
    if (!nullToAbsent || volts != null) {
      map['volts'] = Variable<double>(volts);
    }
    if (!nullToAbsent || amps != null) {
      map['amps'] = Variable<double>(amps);
    }
    if (!nullToAbsent || lastSeenAt != null) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedDevicesCompanion toCompanion(bool nullToAbsent) {
    return CachedDevicesCompanion(
      id: Value(id),
      siteId: Value(siteId),
      name: Value(name),
      deviceClass: Value(deviceClass),
      roomId: roomId == null && nullToAbsent
          ? const Value.absent()
          : Value(roomId),
      roomName: roomName == null && nullToAbsent
          ? const Value.absent()
          : Value(roomName),
      relayState: Value(relayState),
      reachable: Value(reachable),
      switchable: Value(switchable),
      watts: Value(watts),
      volts: volts == null && nullToAbsent
          ? const Value.absent()
          : Value(volts),
      amps: amps == null && nullToAbsent ? const Value.absent() : Value(amps),
      lastSeenAt: lastSeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenAt),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedDevice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedDevice(
      id: serializer.fromJson<String>(json['id']),
      siteId: serializer.fromJson<String>(json['siteId']),
      name: serializer.fromJson<String>(json['name']),
      deviceClass: serializer.fromJson<String>(json['deviceClass']),
      roomId: serializer.fromJson<String?>(json['roomId']),
      roomName: serializer.fromJson<String?>(json['roomName']),
      relayState: serializer.fromJson<bool>(json['relayState']),
      reachable: serializer.fromJson<bool>(json['reachable']),
      switchable: serializer.fromJson<bool>(json['switchable']),
      watts: serializer.fromJson<double>(json['watts']),
      volts: serializer.fromJson<double?>(json['volts']),
      amps: serializer.fromJson<double?>(json['amps']),
      lastSeenAt: serializer.fromJson<DateTime?>(json['lastSeenAt']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'siteId': serializer.toJson<String>(siteId),
      'name': serializer.toJson<String>(name),
      'deviceClass': serializer.toJson<String>(deviceClass),
      'roomId': serializer.toJson<String?>(roomId),
      'roomName': serializer.toJson<String?>(roomName),
      'relayState': serializer.toJson<bool>(relayState),
      'reachable': serializer.toJson<bool>(reachable),
      'switchable': serializer.toJson<bool>(switchable),
      'watts': serializer.toJson<double>(watts),
      'volts': serializer.toJson<double?>(volts),
      'amps': serializer.toJson<double?>(amps),
      'lastSeenAt': serializer.toJson<DateTime?>(lastSeenAt),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedDevice copyWith({
    String? id,
    String? siteId,
    String? name,
    String? deviceClass,
    Value<String?> roomId = const Value.absent(),
    Value<String?> roomName = const Value.absent(),
    bool? relayState,
    bool? reachable,
    bool? switchable,
    double? watts,
    Value<double?> volts = const Value.absent(),
    Value<double?> amps = const Value.absent(),
    Value<DateTime?> lastSeenAt = const Value.absent(),
    DateTime? cachedAt,
  }) => CachedDevice(
    id: id ?? this.id,
    siteId: siteId ?? this.siteId,
    name: name ?? this.name,
    deviceClass: deviceClass ?? this.deviceClass,
    roomId: roomId.present ? roomId.value : this.roomId,
    roomName: roomName.present ? roomName.value : this.roomName,
    relayState: relayState ?? this.relayState,
    reachable: reachable ?? this.reachable,
    switchable: switchable ?? this.switchable,
    watts: watts ?? this.watts,
    volts: volts.present ? volts.value : this.volts,
    amps: amps.present ? amps.value : this.amps,
    lastSeenAt: lastSeenAt.present ? lastSeenAt.value : this.lastSeenAt,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CachedDevice copyWithCompanion(CachedDevicesCompanion data) {
    return CachedDevice(
      id: data.id.present ? data.id.value : this.id,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      name: data.name.present ? data.name.value : this.name,
      deviceClass: data.deviceClass.present
          ? data.deviceClass.value
          : this.deviceClass,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      roomName: data.roomName.present ? data.roomName.value : this.roomName,
      relayState: data.relayState.present
          ? data.relayState.value
          : this.relayState,
      reachable: data.reachable.present ? data.reachable.value : this.reachable,
      switchable: data.switchable.present
          ? data.switchable.value
          : this.switchable,
      watts: data.watts.present ? data.watts.value : this.watts,
      volts: data.volts.present ? data.volts.value : this.volts,
      amps: data.amps.present ? data.amps.value : this.amps,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedDevice(')
          ..write('id: $id, ')
          ..write('siteId: $siteId, ')
          ..write('name: $name, ')
          ..write('deviceClass: $deviceClass, ')
          ..write('roomId: $roomId, ')
          ..write('roomName: $roomName, ')
          ..write('relayState: $relayState, ')
          ..write('reachable: $reachable, ')
          ..write('switchable: $switchable, ')
          ..write('watts: $watts, ')
          ..write('volts: $volts, ')
          ..write('amps: $amps, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    siteId,
    name,
    deviceClass,
    roomId,
    roomName,
    relayState,
    reachable,
    switchable,
    watts,
    volts,
    amps,
    lastSeenAt,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedDevice &&
          other.id == this.id &&
          other.siteId == this.siteId &&
          other.name == this.name &&
          other.deviceClass == this.deviceClass &&
          other.roomId == this.roomId &&
          other.roomName == this.roomName &&
          other.relayState == this.relayState &&
          other.reachable == this.reachable &&
          other.switchable == this.switchable &&
          other.watts == this.watts &&
          other.volts == this.volts &&
          other.amps == this.amps &&
          other.lastSeenAt == this.lastSeenAt &&
          other.cachedAt == this.cachedAt);
}

class CachedDevicesCompanion extends UpdateCompanion<CachedDevice> {
  final Value<String> id;
  final Value<String> siteId;
  final Value<String> name;
  final Value<String> deviceClass;
  final Value<String?> roomId;
  final Value<String?> roomName;
  final Value<bool> relayState;
  final Value<bool> reachable;
  final Value<bool> switchable;
  final Value<double> watts;
  final Value<double?> volts;
  final Value<double?> amps;
  final Value<DateTime?> lastSeenAt;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedDevicesCompanion({
    this.id = const Value.absent(),
    this.siteId = const Value.absent(),
    this.name = const Value.absent(),
    this.deviceClass = const Value.absent(),
    this.roomId = const Value.absent(),
    this.roomName = const Value.absent(),
    this.relayState = const Value.absent(),
    this.reachable = const Value.absent(),
    this.switchable = const Value.absent(),
    this.watts = const Value.absent(),
    this.volts = const Value.absent(),
    this.amps = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedDevicesCompanion.insert({
    required String id,
    required String siteId,
    required String name,
    required String deviceClass,
    this.roomId = const Value.absent(),
    this.roomName = const Value.absent(),
    this.relayState = const Value.absent(),
    this.reachable = const Value.absent(),
    this.switchable = const Value.absent(),
    this.watts = const Value.absent(),
    this.volts = const Value.absent(),
    this.amps = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       siteId = Value(siteId),
       name = Value(name),
       deviceClass = Value(deviceClass),
       cachedAt = Value(cachedAt);
  static Insertable<CachedDevice> custom({
    Expression<String>? id,
    Expression<String>? siteId,
    Expression<String>? name,
    Expression<String>? deviceClass,
    Expression<String>? roomId,
    Expression<String>? roomName,
    Expression<bool>? relayState,
    Expression<bool>? reachable,
    Expression<bool>? switchable,
    Expression<double>? watts,
    Expression<double>? volts,
    Expression<double>? amps,
    Expression<DateTime>? lastSeenAt,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (siteId != null) 'site_id': siteId,
      if (name != null) 'name': name,
      if (deviceClass != null) 'device_class': deviceClass,
      if (roomId != null) 'room_id': roomId,
      if (roomName != null) 'room_name': roomName,
      if (relayState != null) 'relay_state': relayState,
      if (reachable != null) 'reachable': reachable,
      if (switchable != null) 'switchable': switchable,
      if (watts != null) 'watts': watts,
      if (volts != null) 'volts': volts,
      if (amps != null) 'amps': amps,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedDevicesCompanion copyWith({
    Value<String>? id,
    Value<String>? siteId,
    Value<String>? name,
    Value<String>? deviceClass,
    Value<String?>? roomId,
    Value<String?>? roomName,
    Value<bool>? relayState,
    Value<bool>? reachable,
    Value<bool>? switchable,
    Value<double>? watts,
    Value<double?>? volts,
    Value<double?>? amps,
    Value<DateTime?>? lastSeenAt,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CachedDevicesCompanion(
      id: id ?? this.id,
      siteId: siteId ?? this.siteId,
      name: name ?? this.name,
      deviceClass: deviceClass ?? this.deviceClass,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      relayState: relayState ?? this.relayState,
      reachable: reachable ?? this.reachable,
      switchable: switchable ?? this.switchable,
      watts: watts ?? this.watts,
      volts: volts ?? this.volts,
      amps: amps ?? this.amps,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (siteId.present) {
      map['site_id'] = Variable<String>(siteId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (deviceClass.present) {
      map['device_class'] = Variable<String>(deviceClass.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (roomName.present) {
      map['room_name'] = Variable<String>(roomName.value);
    }
    if (relayState.present) {
      map['relay_state'] = Variable<bool>(relayState.value);
    }
    if (reachable.present) {
      map['reachable'] = Variable<bool>(reachable.value);
    }
    if (switchable.present) {
      map['switchable'] = Variable<bool>(switchable.value);
    }
    if (watts.present) {
      map['watts'] = Variable<double>(watts.value);
    }
    if (volts.present) {
      map['volts'] = Variable<double>(volts.value);
    }
    if (amps.present) {
      map['amps'] = Variable<double>(amps.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedDevicesCompanion(')
          ..write('id: $id, ')
          ..write('siteId: $siteId, ')
          ..write('name: $name, ')
          ..write('deviceClass: $deviceClass, ')
          ..write('roomId: $roomId, ')
          ..write('roomName: $roomName, ')
          ..write('relayState: $relayState, ')
          ..write('reachable: $reachable, ')
          ..write('switchable: $switchable, ')
          ..write('watts: $watts, ')
          ..write('volts: $volts, ')
          ..write('amps: $amps, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedRollupsTable extends CachedRollups
    with TableInfo<$CachedRollupsTable, CachedRollup> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedRollupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hourMeta = const VerificationMeta('hour');
  @override
  late final GeneratedColumn<DateTime> hour = GeneratedColumn<DateTime>(
    'hour',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _energyWhMeta = const VerificationMeta(
    'energyWh',
  );
  @override
  late final GeneratedColumn<double> energyWh = GeneratedColumn<double>(
    'energy_wh',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _avgWattsMeta = const VerificationMeta(
    'avgWatts',
  );
  @override
  late final GeneratedColumn<double> avgWatts = GeneratedColumn<double>(
    'avg_watts',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [deviceId, hour, energyWh, avgWatts];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_rollups';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedRollup> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('hour')) {
      context.handle(
        _hourMeta,
        hour.isAcceptableOrUnknown(data['hour']!, _hourMeta),
      );
    } else if (isInserting) {
      context.missing(_hourMeta);
    }
    if (data.containsKey('energy_wh')) {
      context.handle(
        _energyWhMeta,
        energyWh.isAcceptableOrUnknown(data['energy_wh']!, _energyWhMeta),
      );
    }
    if (data.containsKey('avg_watts')) {
      context.handle(
        _avgWattsMeta,
        avgWatts.isAcceptableOrUnknown(data['avg_watts']!, _avgWattsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId, hour};
  @override
  CachedRollup map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedRollup(
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      hour: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}hour'],
      )!,
      energyWh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}energy_wh'],
      )!,
      avgWatts: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_watts'],
      ),
    );
  }

  @override
  $CachedRollupsTable createAlias(String alias) {
    return $CachedRollupsTable(attachedDatabase, alias);
  }
}

class CachedRollup extends DataClass implements Insertable<CachedRollup> {
  final String deviceId;
  final DateTime hour;
  final double energyWh;
  final double? avgWatts;
  const CachedRollup({
    required this.deviceId,
    required this.hour,
    required this.energyWh,
    this.avgWatts,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<String>(deviceId);
    map['hour'] = Variable<DateTime>(hour);
    map['energy_wh'] = Variable<double>(energyWh);
    if (!nullToAbsent || avgWatts != null) {
      map['avg_watts'] = Variable<double>(avgWatts);
    }
    return map;
  }

  CachedRollupsCompanion toCompanion(bool nullToAbsent) {
    return CachedRollupsCompanion(
      deviceId: Value(deviceId),
      hour: Value(hour),
      energyWh: Value(energyWh),
      avgWatts: avgWatts == null && nullToAbsent
          ? const Value.absent()
          : Value(avgWatts),
    );
  }

  factory CachedRollup.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedRollup(
      deviceId: serializer.fromJson<String>(json['deviceId']),
      hour: serializer.fromJson<DateTime>(json['hour']),
      energyWh: serializer.fromJson<double>(json['energyWh']),
      avgWatts: serializer.fromJson<double?>(json['avgWatts']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceId': serializer.toJson<String>(deviceId),
      'hour': serializer.toJson<DateTime>(hour),
      'energyWh': serializer.toJson<double>(energyWh),
      'avgWatts': serializer.toJson<double?>(avgWatts),
    };
  }

  CachedRollup copyWith({
    String? deviceId,
    DateTime? hour,
    double? energyWh,
    Value<double?> avgWatts = const Value.absent(),
  }) => CachedRollup(
    deviceId: deviceId ?? this.deviceId,
    hour: hour ?? this.hour,
    energyWh: energyWh ?? this.energyWh,
    avgWatts: avgWatts.present ? avgWatts.value : this.avgWatts,
  );
  CachedRollup copyWithCompanion(CachedRollupsCompanion data) {
    return CachedRollup(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      hour: data.hour.present ? data.hour.value : this.hour,
      energyWh: data.energyWh.present ? data.energyWh.value : this.energyWh,
      avgWatts: data.avgWatts.present ? data.avgWatts.value : this.avgWatts,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedRollup(')
          ..write('deviceId: $deviceId, ')
          ..write('hour: $hour, ')
          ..write('energyWh: $energyWh, ')
          ..write('avgWatts: $avgWatts')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(deviceId, hour, energyWh, avgWatts);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedRollup &&
          other.deviceId == this.deviceId &&
          other.hour == this.hour &&
          other.energyWh == this.energyWh &&
          other.avgWatts == this.avgWatts);
}

class CachedRollupsCompanion extends UpdateCompanion<CachedRollup> {
  final Value<String> deviceId;
  final Value<DateTime> hour;
  final Value<double> energyWh;
  final Value<double?> avgWatts;
  final Value<int> rowid;
  const CachedRollupsCompanion({
    this.deviceId = const Value.absent(),
    this.hour = const Value.absent(),
    this.energyWh = const Value.absent(),
    this.avgWatts = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedRollupsCompanion.insert({
    required String deviceId,
    required DateTime hour,
    this.energyWh = const Value.absent(),
    this.avgWatts = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : deviceId = Value(deviceId),
       hour = Value(hour);
  static Insertable<CachedRollup> custom({
    Expression<String>? deviceId,
    Expression<DateTime>? hour,
    Expression<double>? energyWh,
    Expression<double>? avgWatts,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (hour != null) 'hour': hour,
      if (energyWh != null) 'energy_wh': energyWh,
      if (avgWatts != null) 'avg_watts': avgWatts,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedRollupsCompanion copyWith({
    Value<String>? deviceId,
    Value<DateTime>? hour,
    Value<double>? energyWh,
    Value<double?>? avgWatts,
    Value<int>? rowid,
  }) {
    return CachedRollupsCompanion(
      deviceId: deviceId ?? this.deviceId,
      hour: hour ?? this.hour,
      energyWh: energyWh ?? this.energyWh,
      avgWatts: avgWatts ?? this.avgWatts,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (hour.present) {
      map['hour'] = Variable<DateTime>(hour.value);
    }
    if (energyWh.present) {
      map['energy_wh'] = Variable<double>(energyWh.value);
    }
    if (avgWatts.present) {
      map['avg_watts'] = Variable<double>(avgWatts.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedRollupsCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('hour: $hour, ')
          ..write('energyWh: $energyWh, ')
          ..write('avgWatts: $avgWatts, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SyncMetaTable syncMeta = $SyncMetaTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $CommandDedupTable commandDedup = $CommandDedupTable(this);
  late final $CachedUsersTable cachedUsers = $CachedUsersTable(this);
  late final $CachedSitesTable cachedSites = $CachedSitesTable(this);
  late final $CachedRoomsTable cachedRooms = $CachedRoomsTable(this);
  late final $CachedSiteMembersTable cachedSiteMembers =
      $CachedSiteMembersTable(this);
  late final $CachedDevicesTable cachedDevices = $CachedDevicesTable(this);
  late final $CachedRollupsTable cachedRollups = $CachedRollupsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    syncMeta,
    outbox,
    commandDedup,
    cachedUsers,
    cachedSites,
    cachedRooms,
    cachedSiteMembers,
    cachedDevices,
    cachedRollups,
  ];
}

typedef $$SyncMetaTableCreateCompanionBuilder =
    SyncMetaCompanion Function({
      required String key,
      Value<DateTime?> lastSyncedAt,
      Value<String?> cursor,
      Value<int> rowid,
    });
typedef $$SyncMetaTableUpdateCompanionBuilder =
    SyncMetaCompanion Function({
      Value<String> key,
      Value<DateTime?> lastSyncedAt,
      Value<String?> cursor,
      Value<int> rowid,
    });

class $$SyncMetaTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);
}

class $$SyncMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetaTable,
          SyncMetaData,
          $$SyncMetaTableFilterComposer,
          $$SyncMetaTableOrderingComposer,
          $$SyncMetaTableAnnotationComposer,
          $$SyncMetaTableCreateCompanionBuilder,
          $$SyncMetaTableUpdateCompanionBuilder,
          (
            SyncMetaData,
            BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaData>,
          ),
          SyncMetaData,
          PrefetchHooks Function()
        > {
  $$SyncMetaTableTableManager(_$AppDatabase db, $SyncMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<String?> cursor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetaCompanion(
                key: key,
                lastSyncedAt: lastSyncedAt,
                cursor: cursor,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<String?> cursor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetaCompanion.insert(
                key: key,
                lastSyncedAt: lastSyncedAt,
                cursor: cursor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetaTable,
      SyncMetaData,
      $$SyncMetaTableFilterComposer,
      $$SyncMetaTableOrderingComposer,
      $$SyncMetaTableAnnotationComposer,
      $$SyncMetaTableCreateCompanionBuilder,
      $$SyncMetaTableUpdateCompanionBuilder,
      (
        SyncMetaData,
        BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaData>,
      ),
      SyncMetaData,
      PrefetchHooks Function()
    >;
typedef $$OutboxTableCreateCompanionBuilder =
    OutboxCompanion Function({
      Value<int> seq,
      required String kind,
      required String payload,
      Value<int> priority,
      Value<String?> idempotencyKey,
      Value<int> attempts,
      required DateTime createdAt,
      Value<DateTime?> nextTryAt,
      Value<DateTime?> expiresAt,
      Value<String?> lastError,
    });
typedef $$OutboxTableUpdateCompanionBuilder =
    OutboxCompanion Function({
      Value<int> seq,
      Value<String> kind,
      Value<String> payload,
      Value<int> priority,
      Value<String?> idempotencyKey,
      Value<int> attempts,
      Value<DateTime> createdAt,
      Value<DateTime?> nextTryAt,
      Value<DateTime?> expiresAt,
      Value<String?> lastError,
    });

class $$OutboxTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextTryAt => $composableBuilder(
    column: $table.nextTryAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextTryAt => $composableBuilder(
    column: $table.nextTryAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get nextTryAt =>
      $composableBuilder(column: $table.nextTryAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$OutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxTable,
          OutboxData,
          $$OutboxTableFilterComposer,
          $$OutboxTableOrderingComposer,
          $$OutboxTableAnnotationComposer,
          $$OutboxTableCreateCompanionBuilder,
          $$OutboxTableUpdateCompanionBuilder,
          (OutboxData, BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>),
          OutboxData,
          PrefetchHooks Function()
        > {
  $$OutboxTableTableManager(_$AppDatabase db, $OutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String?> idempotencyKey = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> nextTryAt = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => OutboxCompanion(
                seq: seq,
                kind: kind,
                payload: payload,
                priority: priority,
                idempotencyKey: idempotencyKey,
                attempts: attempts,
                createdAt: createdAt,
                nextTryAt: nextTryAt,
                expiresAt: expiresAt,
                lastError: lastError,
              ),
          createCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                required String kind,
                required String payload,
                Value<int> priority = const Value.absent(),
                Value<String?> idempotencyKey = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> nextTryAt = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => OutboxCompanion.insert(
                seq: seq,
                kind: kind,
                payload: payload,
                priority: priority,
                idempotencyKey: idempotencyKey,
                attempts: attempts,
                createdAt: createdAt,
                nextTryAt: nextTryAt,
                expiresAt: expiresAt,
                lastError: lastError,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxTable,
      OutboxData,
      $$OutboxTableFilterComposer,
      $$OutboxTableOrderingComposer,
      $$OutboxTableAnnotationComposer,
      $$OutboxTableCreateCompanionBuilder,
      $$OutboxTableUpdateCompanionBuilder,
      (OutboxData, BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>),
      OutboxData,
      PrefetchHooks Function()
    >;
typedef $$CommandDedupTableCreateCompanionBuilder =
    CommandDedupCompanion Function({
      required String idempotencyKey,
      required DateTime appliedAt,
      Value<String?> result,
      Value<int> rowid,
    });
typedef $$CommandDedupTableUpdateCompanionBuilder =
    CommandDedupCompanion Function({
      Value<String> idempotencyKey,
      Value<DateTime> appliedAt,
      Value<String?> result,
      Value<int> rowid,
    });

class $$CommandDedupTableFilterComposer
    extends Composer<_$AppDatabase, $CommandDedupTable> {
  $$CommandDedupTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CommandDedupTableOrderingComposer
    extends Composer<_$AppDatabase, $CommandDedupTable> {
  $$CommandDedupTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CommandDedupTableAnnotationComposer
    extends Composer<_$AppDatabase, $CommandDedupTable> {
  $$CommandDedupTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get appliedAt =>
      $composableBuilder(column: $table.appliedAt, builder: (column) => column);

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);
}

class $$CommandDedupTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CommandDedupTable,
          CommandDedupData,
          $$CommandDedupTableFilterComposer,
          $$CommandDedupTableOrderingComposer,
          $$CommandDedupTableAnnotationComposer,
          $$CommandDedupTableCreateCompanionBuilder,
          $$CommandDedupTableUpdateCompanionBuilder,
          (
            CommandDedupData,
            BaseReferences<_$AppDatabase, $CommandDedupTable, CommandDedupData>,
          ),
          CommandDedupData,
          PrefetchHooks Function()
        > {
  $$CommandDedupTableTableManager(_$AppDatabase db, $CommandDedupTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommandDedupTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CommandDedupTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CommandDedupTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> idempotencyKey = const Value.absent(),
                Value<DateTime> appliedAt = const Value.absent(),
                Value<String?> result = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CommandDedupCompanion(
                idempotencyKey: idempotencyKey,
                appliedAt: appliedAt,
                result: result,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String idempotencyKey,
                required DateTime appliedAt,
                Value<String?> result = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CommandDedupCompanion.insert(
                idempotencyKey: idempotencyKey,
                appliedAt: appliedAt,
                result: result,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CommandDedupTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CommandDedupTable,
      CommandDedupData,
      $$CommandDedupTableFilterComposer,
      $$CommandDedupTableOrderingComposer,
      $$CommandDedupTableAnnotationComposer,
      $$CommandDedupTableCreateCompanionBuilder,
      $$CommandDedupTableUpdateCompanionBuilder,
      (
        CommandDedupData,
        BaseReferences<_$AppDatabase, $CommandDedupTable, CommandDedupData>,
      ),
      CommandDedupData,
      PrefetchHooks Function()
    >;
typedef $$CachedUsersTableCreateCompanionBuilder =
    CachedUsersCompanion Function({
      required String id,
      required String tenantId,
      required String phoneE164,
      Value<String?> email,
      Value<String?> displayName,
      required String role,
      Value<String> locale,
      Value<String> status,
      Value<DateTime?> lastLoginAt,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$CachedUsersTableUpdateCompanionBuilder =
    CachedUsersCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> phoneE164,
      Value<String?> email,
      Value<String?> displayName,
      Value<String> role,
      Value<String> locale,
      Value<String> status,
      Value<DateTime?> lastLoginAt,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$CachedUsersTableFilterComposer
    extends Composer<_$AppDatabase, $CachedUsersTable> {
  $$CachedUsersTableFilterComposer({
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

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneE164 => $composableBuilder(
    column: $table.phoneE164,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedUsersTable> {
  $$CachedUsersTableOrderingComposer({
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

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneE164 => $composableBuilder(
    column: $table.phoneE164,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedUsersTable> {
  $$CachedUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get phoneE164 =>
      $composableBuilder(column: $table.phoneE164, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedUsersTable,
          CachedUser,
          $$CachedUsersTableFilterComposer,
          $$CachedUsersTableOrderingComposer,
          $$CachedUsersTableAnnotationComposer,
          $$CachedUsersTableCreateCompanionBuilder,
          $$CachedUsersTableUpdateCompanionBuilder,
          (
            CachedUser,
            BaseReferences<_$AppDatabase, $CachedUsersTable, CachedUser>,
          ),
          CachedUser,
          PrefetchHooks Function()
        > {
  $$CachedUsersTableTableManager(_$AppDatabase db, $CachedUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> phoneE164 = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> lastLoginAt = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedUsersCompanion(
                id: id,
                tenantId: tenantId,
                phoneE164: phoneE164,
                email: email,
                displayName: displayName,
                role: role,
                locale: locale,
                status: status,
                lastLoginAt: lastLoginAt,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String phoneE164,
                Value<String?> email = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                required String role,
                Value<String> locale = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> lastLoginAt = const Value.absent(),
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedUsersCompanion.insert(
                id: id,
                tenantId: tenantId,
                phoneE164: phoneE164,
                email: email,
                displayName: displayName,
                role: role,
                locale: locale,
                status: status,
                lastLoginAt: lastLoginAt,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedUsersTable,
      CachedUser,
      $$CachedUsersTableFilterComposer,
      $$CachedUsersTableOrderingComposer,
      $$CachedUsersTableAnnotationComposer,
      $$CachedUsersTableCreateCompanionBuilder,
      $$CachedUsersTableUpdateCompanionBuilder,
      (
        CachedUser,
        BaseReferences<_$AppDatabase, $CachedUsersTable, CachedUser>,
      ),
      CachedUser,
      PrefetchHooks Function()
    >;
typedef $$CachedSitesTableCreateCompanionBuilder =
    CachedSitesCompanion Function({
      required String id,
      required String tenantId,
      required String label,
      Value<String> timezone,
      required String meterType,
      Value<String?> kplcAccountNo,
      Value<String?> kplcMeterNo,
      Value<String> supplyPhase,
      Value<int?> occupantCount,
      Value<String> status,
      Value<String?> staticIp,
      Value<int> localApiPort,
      Value<bool> allowLanCommands,
      Value<bool> allowCloudCommands,
      Value<DateTime?> createdAt,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$CachedSitesTableUpdateCompanionBuilder =
    CachedSitesCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> label,
      Value<String> timezone,
      Value<String> meterType,
      Value<String?> kplcAccountNo,
      Value<String?> kplcMeterNo,
      Value<String> supplyPhase,
      Value<int?> occupantCount,
      Value<String> status,
      Value<String?> staticIp,
      Value<int> localApiPort,
      Value<bool> allowLanCommands,
      Value<bool> allowCloudCommands,
      Value<DateTime?> createdAt,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$CachedSitesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedSitesTable> {
  $$CachedSitesTableFilterComposer({
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

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meterType => $composableBuilder(
    column: $table.meterType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kplcAccountNo => $composableBuilder(
    column: $table.kplcAccountNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kplcMeterNo => $composableBuilder(
    column: $table.kplcMeterNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplyPhase => $composableBuilder(
    column: $table.supplyPhase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occupantCount => $composableBuilder(
    column: $table.occupantCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get staticIp => $composableBuilder(
    column: $table.staticIp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localApiPort => $composableBuilder(
    column: $table.localApiPort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowLanCommands => $composableBuilder(
    column: $table.allowLanCommands,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowCloudCommands => $composableBuilder(
    column: $table.allowCloudCommands,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedSitesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedSitesTable> {
  $$CachedSitesTableOrderingComposer({
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

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meterType => $composableBuilder(
    column: $table.meterType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kplcAccountNo => $composableBuilder(
    column: $table.kplcAccountNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kplcMeterNo => $composableBuilder(
    column: $table.kplcMeterNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplyPhase => $composableBuilder(
    column: $table.supplyPhase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occupantCount => $composableBuilder(
    column: $table.occupantCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get staticIp => $composableBuilder(
    column: $table.staticIp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localApiPort => $composableBuilder(
    column: $table.localApiPort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowLanCommands => $composableBuilder(
    column: $table.allowLanCommands,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowCloudCommands => $composableBuilder(
    column: $table.allowCloudCommands,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedSitesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedSitesTable> {
  $$CachedSitesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<String> get meterType =>
      $composableBuilder(column: $table.meterType, builder: (column) => column);

  GeneratedColumn<String> get kplcAccountNo => $composableBuilder(
    column: $table.kplcAccountNo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kplcMeterNo => $composableBuilder(
    column: $table.kplcMeterNo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supplyPhase => $composableBuilder(
    column: $table.supplyPhase,
    builder: (column) => column,
  );

  GeneratedColumn<int> get occupantCount => $composableBuilder(
    column: $table.occupantCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get staticIp =>
      $composableBuilder(column: $table.staticIp, builder: (column) => column);

  GeneratedColumn<int> get localApiPort => $composableBuilder(
    column: $table.localApiPort,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get allowLanCommands => $composableBuilder(
    column: $table.allowLanCommands,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get allowCloudCommands => $composableBuilder(
    column: $table.allowCloudCommands,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedSitesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedSitesTable,
          CachedSite,
          $$CachedSitesTableFilterComposer,
          $$CachedSitesTableOrderingComposer,
          $$CachedSitesTableAnnotationComposer,
          $$CachedSitesTableCreateCompanionBuilder,
          $$CachedSitesTableUpdateCompanionBuilder,
          (
            CachedSite,
            BaseReferences<_$AppDatabase, $CachedSitesTable, CachedSite>,
          ),
          CachedSite,
          PrefetchHooks Function()
        > {
  $$CachedSitesTableTableManager(_$AppDatabase db, $CachedSitesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedSitesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedSitesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedSitesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<String> meterType = const Value.absent(),
                Value<String?> kplcAccountNo = const Value.absent(),
                Value<String?> kplcMeterNo = const Value.absent(),
                Value<String> supplyPhase = const Value.absent(),
                Value<int?> occupantCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> staticIp = const Value.absent(),
                Value<int> localApiPort = const Value.absent(),
                Value<bool> allowLanCommands = const Value.absent(),
                Value<bool> allowCloudCommands = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedSitesCompanion(
                id: id,
                tenantId: tenantId,
                label: label,
                timezone: timezone,
                meterType: meterType,
                kplcAccountNo: kplcAccountNo,
                kplcMeterNo: kplcMeterNo,
                supplyPhase: supplyPhase,
                occupantCount: occupantCount,
                status: status,
                staticIp: staticIp,
                localApiPort: localApiPort,
                allowLanCommands: allowLanCommands,
                allowCloudCommands: allowCloudCommands,
                createdAt: createdAt,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String label,
                Value<String> timezone = const Value.absent(),
                required String meterType,
                Value<String?> kplcAccountNo = const Value.absent(),
                Value<String?> kplcMeterNo = const Value.absent(),
                Value<String> supplyPhase = const Value.absent(),
                Value<int?> occupantCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> staticIp = const Value.absent(),
                Value<int> localApiPort = const Value.absent(),
                Value<bool> allowLanCommands = const Value.absent(),
                Value<bool> allowCloudCommands = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedSitesCompanion.insert(
                id: id,
                tenantId: tenantId,
                label: label,
                timezone: timezone,
                meterType: meterType,
                kplcAccountNo: kplcAccountNo,
                kplcMeterNo: kplcMeterNo,
                supplyPhase: supplyPhase,
                occupantCount: occupantCount,
                status: status,
                staticIp: staticIp,
                localApiPort: localApiPort,
                allowLanCommands: allowLanCommands,
                allowCloudCommands: allowCloudCommands,
                createdAt: createdAt,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedSitesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedSitesTable,
      CachedSite,
      $$CachedSitesTableFilterComposer,
      $$CachedSitesTableOrderingComposer,
      $$CachedSitesTableAnnotationComposer,
      $$CachedSitesTableCreateCompanionBuilder,
      $$CachedSitesTableUpdateCompanionBuilder,
      (
        CachedSite,
        BaseReferences<_$AppDatabase, $CachedSitesTable, CachedSite>,
      ),
      CachedSite,
      PrefetchHooks Function()
    >;
typedef $$CachedRoomsTableCreateCompanionBuilder =
    CachedRoomsCompanion Function({
      required String id,
      required String siteId,
      required String name,
      Value<String?> roomType,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$CachedRoomsTableUpdateCompanionBuilder =
    CachedRoomsCompanion Function({
      Value<String> id,
      Value<String> siteId,
      Value<String> name,
      Value<String?> roomType,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$CachedRoomsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedRoomsTable> {
  $$CachedRoomsTableFilterComposer({
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

  ColumnFilters<String> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roomType => $composableBuilder(
    column: $table.roomType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedRoomsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedRoomsTable> {
  $$CachedRoomsTableOrderingComposer({
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

  ColumnOrderings<String> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roomType => $composableBuilder(
    column: $table.roomType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedRoomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedRoomsTable> {
  $$CachedRoomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get siteId =>
      $composableBuilder(column: $table.siteId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get roomType =>
      $composableBuilder(column: $table.roomType, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedRoomsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedRoomsTable,
          CachedRoom,
          $$CachedRoomsTableFilterComposer,
          $$CachedRoomsTableOrderingComposer,
          $$CachedRoomsTableAnnotationComposer,
          $$CachedRoomsTableCreateCompanionBuilder,
          $$CachedRoomsTableUpdateCompanionBuilder,
          (
            CachedRoom,
            BaseReferences<_$AppDatabase, $CachedRoomsTable, CachedRoom>,
          ),
          CachedRoom,
          PrefetchHooks Function()
        > {
  $$CachedRoomsTableTableManager(_$AppDatabase db, $CachedRoomsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedRoomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedRoomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedRoomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> siteId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> roomType = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedRoomsCompanion(
                id: id,
                siteId: siteId,
                name: name,
                roomType: roomType,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String siteId,
                required String name,
                Value<String?> roomType = const Value.absent(),
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedRoomsCompanion.insert(
                id: id,
                siteId: siteId,
                name: name,
                roomType: roomType,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedRoomsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedRoomsTable,
      CachedRoom,
      $$CachedRoomsTableFilterComposer,
      $$CachedRoomsTableOrderingComposer,
      $$CachedRoomsTableAnnotationComposer,
      $$CachedRoomsTableCreateCompanionBuilder,
      $$CachedRoomsTableUpdateCompanionBuilder,
      (
        CachedRoom,
        BaseReferences<_$AppDatabase, $CachedRoomsTable, CachedRoom>,
      ),
      CachedRoom,
      PrefetchHooks Function()
    >;
typedef $$CachedSiteMembersTableCreateCompanionBuilder =
    CachedSiteMembersCompanion Function({
      Value<int> id,
      required String siteId,
      required String userId,
      Value<String?> phoneE164,
      Value<String?> displayName,
      required String role,
      Value<String?> grantedBy,
      Value<DateTime?> grantedAt,
      Value<DateTime?> revokedAt,
      required DateTime cachedAt,
    });
typedef $$CachedSiteMembersTableUpdateCompanionBuilder =
    CachedSiteMembersCompanion Function({
      Value<int> id,
      Value<String> siteId,
      Value<String> userId,
      Value<String?> phoneE164,
      Value<String?> displayName,
      Value<String> role,
      Value<String?> grantedBy,
      Value<DateTime?> grantedAt,
      Value<DateTime?> revokedAt,
      Value<DateTime> cachedAt,
    });

class $$CachedSiteMembersTableFilterComposer
    extends Composer<_$AppDatabase, $CachedSiteMembersTable> {
  $$CachedSiteMembersTableFilterComposer({
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

  ColumnFilters<String> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneE164 => $composableBuilder(
    column: $table.phoneE164,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grantedBy => $composableBuilder(
    column: $table.grantedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get grantedAt => $composableBuilder(
    column: $table.grantedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get revokedAt => $composableBuilder(
    column: $table.revokedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedSiteMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedSiteMembersTable> {
  $$CachedSiteMembersTableOrderingComposer({
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

  ColumnOrderings<String> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneE164 => $composableBuilder(
    column: $table.phoneE164,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grantedBy => $composableBuilder(
    column: $table.grantedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get grantedAt => $composableBuilder(
    column: $table.grantedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get revokedAt => $composableBuilder(
    column: $table.revokedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedSiteMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedSiteMembersTable> {
  $$CachedSiteMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get siteId =>
      $composableBuilder(column: $table.siteId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get phoneE164 =>
      $composableBuilder(column: $table.phoneE164, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get grantedBy =>
      $composableBuilder(column: $table.grantedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get grantedAt =>
      $composableBuilder(column: $table.grantedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get revokedAt =>
      $composableBuilder(column: $table.revokedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedSiteMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedSiteMembersTable,
          CachedSiteMember,
          $$CachedSiteMembersTableFilterComposer,
          $$CachedSiteMembersTableOrderingComposer,
          $$CachedSiteMembersTableAnnotationComposer,
          $$CachedSiteMembersTableCreateCompanionBuilder,
          $$CachedSiteMembersTableUpdateCompanionBuilder,
          (
            CachedSiteMember,
            BaseReferences<
              _$AppDatabase,
              $CachedSiteMembersTable,
              CachedSiteMember
            >,
          ),
          CachedSiteMember,
          PrefetchHooks Function()
        > {
  $$CachedSiteMembersTableTableManager(
    _$AppDatabase db,
    $CachedSiteMembersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedSiteMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedSiteMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedSiteMembersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> siteId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> phoneE164 = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> grantedBy = const Value.absent(),
                Value<DateTime?> grantedAt = const Value.absent(),
                Value<DateTime?> revokedAt = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
              }) => CachedSiteMembersCompanion(
                id: id,
                siteId: siteId,
                userId: userId,
                phoneE164: phoneE164,
                displayName: displayName,
                role: role,
                grantedBy: grantedBy,
                grantedAt: grantedAt,
                revokedAt: revokedAt,
                cachedAt: cachedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String siteId,
                required String userId,
                Value<String?> phoneE164 = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                required String role,
                Value<String?> grantedBy = const Value.absent(),
                Value<DateTime?> grantedAt = const Value.absent(),
                Value<DateTime?> revokedAt = const Value.absent(),
                required DateTime cachedAt,
              }) => CachedSiteMembersCompanion.insert(
                id: id,
                siteId: siteId,
                userId: userId,
                phoneE164: phoneE164,
                displayName: displayName,
                role: role,
                grantedBy: grantedBy,
                grantedAt: grantedAt,
                revokedAt: revokedAt,
                cachedAt: cachedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedSiteMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedSiteMembersTable,
      CachedSiteMember,
      $$CachedSiteMembersTableFilterComposer,
      $$CachedSiteMembersTableOrderingComposer,
      $$CachedSiteMembersTableAnnotationComposer,
      $$CachedSiteMembersTableCreateCompanionBuilder,
      $$CachedSiteMembersTableUpdateCompanionBuilder,
      (
        CachedSiteMember,
        BaseReferences<
          _$AppDatabase,
          $CachedSiteMembersTable,
          CachedSiteMember
        >,
      ),
      CachedSiteMember,
      PrefetchHooks Function()
    >;
typedef $$CachedDevicesTableCreateCompanionBuilder =
    CachedDevicesCompanion Function({
      required String id,
      required String siteId,
      required String name,
      required String deviceClass,
      Value<String?> roomId,
      Value<String?> roomName,
      Value<bool> relayState,
      Value<bool> reachable,
      Value<bool> switchable,
      Value<double> watts,
      Value<double?> volts,
      Value<double?> amps,
      Value<DateTime?> lastSeenAt,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$CachedDevicesTableUpdateCompanionBuilder =
    CachedDevicesCompanion Function({
      Value<String> id,
      Value<String> siteId,
      Value<String> name,
      Value<String> deviceClass,
      Value<String?> roomId,
      Value<String?> roomName,
      Value<bool> relayState,
      Value<bool> reachable,
      Value<bool> switchable,
      Value<double> watts,
      Value<double?> volts,
      Value<double?> amps,
      Value<DateTime?> lastSeenAt,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$CachedDevicesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedDevicesTable> {
  $$CachedDevicesTableFilterComposer({
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

  ColumnFilters<String> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceClass => $composableBuilder(
    column: $table.deviceClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roomName => $composableBuilder(
    column: $table.roomName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get relayState => $composableBuilder(
    column: $table.relayState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reachable => $composableBuilder(
    column: $table.reachable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get switchable => $composableBuilder(
    column: $table.switchable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get watts => $composableBuilder(
    column: $table.watts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get volts => $composableBuilder(
    column: $table.volts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amps => $composableBuilder(
    column: $table.amps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedDevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedDevicesTable> {
  $$CachedDevicesTableOrderingComposer({
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

  ColumnOrderings<String> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceClass => $composableBuilder(
    column: $table.deviceClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roomName => $composableBuilder(
    column: $table.roomName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get relayState => $composableBuilder(
    column: $table.relayState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reachable => $composableBuilder(
    column: $table.reachable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get switchable => $composableBuilder(
    column: $table.switchable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get watts => $composableBuilder(
    column: $table.watts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get volts => $composableBuilder(
    column: $table.volts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amps => $composableBuilder(
    column: $table.amps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedDevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedDevicesTable> {
  $$CachedDevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get siteId =>
      $composableBuilder(column: $table.siteId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get deviceClass => $composableBuilder(
    column: $table.deviceClass,
    builder: (column) => column,
  );

  GeneratedColumn<String> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<String> get roomName =>
      $composableBuilder(column: $table.roomName, builder: (column) => column);

  GeneratedColumn<bool> get relayState => $composableBuilder(
    column: $table.relayState,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get reachable =>
      $composableBuilder(column: $table.reachable, builder: (column) => column);

  GeneratedColumn<bool> get switchable => $composableBuilder(
    column: $table.switchable,
    builder: (column) => column,
  );

  GeneratedColumn<double> get watts =>
      $composableBuilder(column: $table.watts, builder: (column) => column);

  GeneratedColumn<double> get volts =>
      $composableBuilder(column: $table.volts, builder: (column) => column);

  GeneratedColumn<double> get amps =>
      $composableBuilder(column: $table.amps, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedDevicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedDevicesTable,
          CachedDevice,
          $$CachedDevicesTableFilterComposer,
          $$CachedDevicesTableOrderingComposer,
          $$CachedDevicesTableAnnotationComposer,
          $$CachedDevicesTableCreateCompanionBuilder,
          $$CachedDevicesTableUpdateCompanionBuilder,
          (
            CachedDevice,
            BaseReferences<_$AppDatabase, $CachedDevicesTable, CachedDevice>,
          ),
          CachedDevice,
          PrefetchHooks Function()
        > {
  $$CachedDevicesTableTableManager(_$AppDatabase db, $CachedDevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedDevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedDevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedDevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> siteId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> deviceClass = const Value.absent(),
                Value<String?> roomId = const Value.absent(),
                Value<String?> roomName = const Value.absent(),
                Value<bool> relayState = const Value.absent(),
                Value<bool> reachable = const Value.absent(),
                Value<bool> switchable = const Value.absent(),
                Value<double> watts = const Value.absent(),
                Value<double?> volts = const Value.absent(),
                Value<double?> amps = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedDevicesCompanion(
                id: id,
                siteId: siteId,
                name: name,
                deviceClass: deviceClass,
                roomId: roomId,
                roomName: roomName,
                relayState: relayState,
                reachable: reachable,
                switchable: switchable,
                watts: watts,
                volts: volts,
                amps: amps,
                lastSeenAt: lastSeenAt,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String siteId,
                required String name,
                required String deviceClass,
                Value<String?> roomId = const Value.absent(),
                Value<String?> roomName = const Value.absent(),
                Value<bool> relayState = const Value.absent(),
                Value<bool> reachable = const Value.absent(),
                Value<bool> switchable = const Value.absent(),
                Value<double> watts = const Value.absent(),
                Value<double?> volts = const Value.absent(),
                Value<double?> amps = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedDevicesCompanion.insert(
                id: id,
                siteId: siteId,
                name: name,
                deviceClass: deviceClass,
                roomId: roomId,
                roomName: roomName,
                relayState: relayState,
                reachable: reachable,
                switchable: switchable,
                watts: watts,
                volts: volts,
                amps: amps,
                lastSeenAt: lastSeenAt,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedDevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedDevicesTable,
      CachedDevice,
      $$CachedDevicesTableFilterComposer,
      $$CachedDevicesTableOrderingComposer,
      $$CachedDevicesTableAnnotationComposer,
      $$CachedDevicesTableCreateCompanionBuilder,
      $$CachedDevicesTableUpdateCompanionBuilder,
      (
        CachedDevice,
        BaseReferences<_$AppDatabase, $CachedDevicesTable, CachedDevice>,
      ),
      CachedDevice,
      PrefetchHooks Function()
    >;
typedef $$CachedRollupsTableCreateCompanionBuilder =
    CachedRollupsCompanion Function({
      required String deviceId,
      required DateTime hour,
      Value<double> energyWh,
      Value<double?> avgWatts,
      Value<int> rowid,
    });
typedef $$CachedRollupsTableUpdateCompanionBuilder =
    CachedRollupsCompanion Function({
      Value<String> deviceId,
      Value<DateTime> hour,
      Value<double> energyWh,
      Value<double?> avgWatts,
      Value<int> rowid,
    });

class $$CachedRollupsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedRollupsTable> {
  $$CachedRollupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get hour => $composableBuilder(
    column: $table.hour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get energyWh => $composableBuilder(
    column: $table.energyWh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgWatts => $composableBuilder(
    column: $table.avgWatts,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedRollupsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedRollupsTable> {
  $$CachedRollupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get hour => $composableBuilder(
    column: $table.hour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get energyWh => $composableBuilder(
    column: $table.energyWh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgWatts => $composableBuilder(
    column: $table.avgWatts,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedRollupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedRollupsTable> {
  $$CachedRollupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get hour =>
      $composableBuilder(column: $table.hour, builder: (column) => column);

  GeneratedColumn<double> get energyWh =>
      $composableBuilder(column: $table.energyWh, builder: (column) => column);

  GeneratedColumn<double> get avgWatts =>
      $composableBuilder(column: $table.avgWatts, builder: (column) => column);
}

class $$CachedRollupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedRollupsTable,
          CachedRollup,
          $$CachedRollupsTableFilterComposer,
          $$CachedRollupsTableOrderingComposer,
          $$CachedRollupsTableAnnotationComposer,
          $$CachedRollupsTableCreateCompanionBuilder,
          $$CachedRollupsTableUpdateCompanionBuilder,
          (
            CachedRollup,
            BaseReferences<_$AppDatabase, $CachedRollupsTable, CachedRollup>,
          ),
          CachedRollup,
          PrefetchHooks Function()
        > {
  $$CachedRollupsTableTableManager(_$AppDatabase db, $CachedRollupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedRollupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedRollupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedRollupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> deviceId = const Value.absent(),
                Value<DateTime> hour = const Value.absent(),
                Value<double> energyWh = const Value.absent(),
                Value<double?> avgWatts = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedRollupsCompanion(
                deviceId: deviceId,
                hour: hour,
                energyWh: energyWh,
                avgWatts: avgWatts,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String deviceId,
                required DateTime hour,
                Value<double> energyWh = const Value.absent(),
                Value<double?> avgWatts = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedRollupsCompanion.insert(
                deviceId: deviceId,
                hour: hour,
                energyWh: energyWh,
                avgWatts: avgWatts,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedRollupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedRollupsTable,
      CachedRollup,
      $$CachedRollupsTableFilterComposer,
      $$CachedRollupsTableOrderingComposer,
      $$CachedRollupsTableAnnotationComposer,
      $$CachedRollupsTableCreateCompanionBuilder,
      $$CachedRollupsTableUpdateCompanionBuilder,
      (
        CachedRollup,
        BaseReferences<_$AppDatabase, $CachedRollupsTable, CachedRollup>,
      ),
      CachedRollup,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SyncMetaTableTableManager get syncMeta =>
      $$SyncMetaTableTableManager(_db, _db.syncMeta);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
  $$CommandDedupTableTableManager get commandDedup =>
      $$CommandDedupTableTableManager(_db, _db.commandDedup);
  $$CachedUsersTableTableManager get cachedUsers =>
      $$CachedUsersTableTableManager(_db, _db.cachedUsers);
  $$CachedSitesTableTableManager get cachedSites =>
      $$CachedSitesTableTableManager(_db, _db.cachedSites);
  $$CachedRoomsTableTableManager get cachedRooms =>
      $$CachedRoomsTableTableManager(_db, _db.cachedRooms);
  $$CachedSiteMembersTableTableManager get cachedSiteMembers =>
      $$CachedSiteMembersTableTableManager(_db, _db.cachedSiteMembers);
  $$CachedDevicesTableTableManager get cachedDevices =>
      $$CachedDevicesTableTableManager(_db, _db.cachedDevices);
  $$CachedRollupsTableTableManager get cachedRollups =>
      $$CachedRollupsTableTableManager(_db, _db.cachedRollups);
}
