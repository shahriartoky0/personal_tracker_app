// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts
    with TableInfo<$AccountsTable, AccountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteUpdatedAtMeta = const VerificationMeta(
    'remoteUpdatedAt',
  );
  @override
  late final GeneratedColumn<String> remoteUpdatedAt = GeneratedColumn<String>(
    'remote_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingMeta = const VerificationMeta(
    'pending',
  );
  @override
  late final GeneratedColumn<bool> pending = GeneratedColumn<bool>(
    'pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openingBalanceMeta = const VerificationMeta(
    'openingBalance',
  );
  @override
  late final GeneratedColumn<int> openingBalance = GeneratedColumn<int>(
    'opening_balance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteUpdatedAt,
    pending,
    name,
    type,
    openingBalance,
    isArchived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('remote_updated_at')) {
      context.handle(
        _remoteUpdatedAtMeta,
        remoteUpdatedAt.isAcceptableOrUnknown(
          data['remote_updated_at']!,
          _remoteUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('pending')) {
      context.handle(
        _pendingMeta,
        pending.isAcceptableOrUnknown(data['pending']!, _pendingMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('opening_balance')) {
      context.handle(
        _openingBalanceMeta,
        openingBalance.isAcceptableOrUnknown(
          data['opening_balance']!,
          _openingBalanceMeta,
        ),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      remoteUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_updated_at'],
      ),
      pending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      openingBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opening_balance'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }
}

class AccountRow extends DataClass implements Insertable<AccountRow> {
  final String id;
  final String? remoteUpdatedAt;
  final bool pending;
  final String name;
  final String type;
  final int openingBalance;
  final bool isArchived;
  const AccountRow({
    required this.id,
    this.remoteUpdatedAt,
    required this.pending,
    required this.name,
    required this.type,
    required this.openingBalance,
    required this.isArchived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || remoteUpdatedAt != null) {
      map['remote_updated_at'] = Variable<String>(remoteUpdatedAt);
    }
    map['pending'] = Variable<bool>(pending);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['opening_balance'] = Variable<int>(openingBalance);
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      remoteUpdatedAt: remoteUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteUpdatedAt),
      pending: Value(pending),
      name: Value(name),
      type: Value(type),
      openingBalance: Value(openingBalance),
      isArchived: Value(isArchived),
    );
  }

  factory AccountRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountRow(
      id: serializer.fromJson<String>(json['id']),
      remoteUpdatedAt: serializer.fromJson<String?>(json['remoteUpdatedAt']),
      pending: serializer.fromJson<bool>(json['pending']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      openingBalance: serializer.fromJson<int>(json['openingBalance']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'remoteUpdatedAt': serializer.toJson<String?>(remoteUpdatedAt),
      'pending': serializer.toJson<bool>(pending),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'openingBalance': serializer.toJson<int>(openingBalance),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  AccountRow copyWith({
    String? id,
    Value<String?> remoteUpdatedAt = const Value.absent(),
    bool? pending,
    String? name,
    String? type,
    int? openingBalance,
    bool? isArchived,
  }) => AccountRow(
    id: id ?? this.id,
    remoteUpdatedAt: remoteUpdatedAt.present
        ? remoteUpdatedAt.value
        : this.remoteUpdatedAt,
    pending: pending ?? this.pending,
    name: name ?? this.name,
    type: type ?? this.type,
    openingBalance: openingBalance ?? this.openingBalance,
    isArchived: isArchived ?? this.isArchived,
  );
  AccountRow copyWithCompanion(AccountsCompanion data) {
    return AccountRow(
      id: data.id.present ? data.id.value : this.id,
      remoteUpdatedAt: data.remoteUpdatedAt.present
          ? data.remoteUpdatedAt.value
          : this.remoteUpdatedAt,
      pending: data.pending.present ? data.pending.value : this.pending,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      openingBalance: data.openingBalance.present
          ? data.openingBalance.value
          : this.openingBalance,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountRow(')
          ..write('id: $id, ')
          ..write('remoteUpdatedAt: $remoteUpdatedAt, ')
          ..write('pending: $pending, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    remoteUpdatedAt,
    pending,
    name,
    type,
    openingBalance,
    isArchived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountRow &&
          other.id == this.id &&
          other.remoteUpdatedAt == this.remoteUpdatedAt &&
          other.pending == this.pending &&
          other.name == this.name &&
          other.type == this.type &&
          other.openingBalance == this.openingBalance &&
          other.isArchived == this.isArchived);
}

class AccountsCompanion extends UpdateCompanion<AccountRow> {
  final Value<String> id;
  final Value<String?> remoteUpdatedAt;
  final Value<bool> pending;
  final Value<String> name;
  final Value<String> type;
  final Value<int> openingBalance;
  final Value<bool> isArchived;
  final Value<int> rowid;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.remoteUpdatedAt = const Value.absent(),
    this.pending = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsCompanion.insert({
    required String id,
    this.remoteUpdatedAt = const Value.absent(),
    this.pending = const Value.absent(),
    required String name,
    required String type,
    this.openingBalance = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type);
  static Insertable<AccountRow> custom({
    Expression<String>? id,
    Expression<String>? remoteUpdatedAt,
    Expression<bool>? pending,
    Expression<String>? name,
    Expression<String>? type,
    Expression<int>? openingBalance,
    Expression<bool>? isArchived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteUpdatedAt != null) 'remote_updated_at': remoteUpdatedAt,
      if (pending != null) 'pending': pending,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (openingBalance != null) 'opening_balance': openingBalance,
      if (isArchived != null) 'is_archived': isArchived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsCompanion copyWith({
    Value<String>? id,
    Value<String?>? remoteUpdatedAt,
    Value<bool>? pending,
    Value<String>? name,
    Value<String>? type,
    Value<int>? openingBalance,
    Value<bool>? isArchived,
    Value<int>? rowid,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      remoteUpdatedAt: remoteUpdatedAt ?? this.remoteUpdatedAt,
      pending: pending ?? this.pending,
      name: name ?? this.name,
      type: type ?? this.type,
      openingBalance: openingBalance ?? this.openingBalance,
      isArchived: isArchived ?? this.isArchived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (remoteUpdatedAt.present) {
      map['remote_updated_at'] = Variable<String>(remoteUpdatedAt.value);
    }
    if (pending.present) {
      map['pending'] = Variable<bool>(pending.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (openingBalance.present) {
      map['opening_balance'] = Variable<int>(openingBalance.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('remoteUpdatedAt: $remoteUpdatedAt, ')
          ..write('pending: $pending, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('isArchived: $isArchived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteUpdatedAtMeta = const VerificationMeta(
    'remoteUpdatedAt',
  );
  @override
  late final GeneratedColumn<String> remoteUpdatedAt = GeneratedColumn<String>(
    'remote_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingMeta = const VerificationMeta(
    'pending',
  );
  @override
  late final GeneratedColumn<bool> pending = GeneratedColumn<bool>(
    'pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteUpdatedAt,
    pending,
    name,
    icon,
    color,
    type,
    isDefault,
    isArchived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('remote_updated_at')) {
      context.handle(
        _remoteUpdatedAtMeta,
        remoteUpdatedAt.isAcceptableOrUnknown(
          data['remote_updated_at']!,
          _remoteUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('pending')) {
      context.handle(
        _pendingMeta,
        pending.isAcceptableOrUnknown(data['pending']!, _pendingMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      remoteUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_updated_at'],
      ),
      pending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String id;
  final String? remoteUpdatedAt;
  final bool pending;
  final String name;
  final String? icon;
  final String? color;
  final String type;
  final bool isDefault;
  final bool isArchived;
  const CategoryRow({
    required this.id,
    this.remoteUpdatedAt,
    required this.pending,
    required this.name,
    this.icon,
    this.color,
    required this.type,
    required this.isDefault,
    required this.isArchived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || remoteUpdatedAt != null) {
      map['remote_updated_at'] = Variable<String>(remoteUpdatedAt);
    }
    map['pending'] = Variable<bool>(pending);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['type'] = Variable<String>(type);
    map['is_default'] = Variable<bool>(isDefault);
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      remoteUpdatedAt: remoteUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteUpdatedAt),
      pending: Value(pending),
      name: Value(name),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      type: Value(type),
      isDefault: Value(isDefault),
      isArchived: Value(isArchived),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<String>(json['id']),
      remoteUpdatedAt: serializer.fromJson<String?>(json['remoteUpdatedAt']),
      pending: serializer.fromJson<bool>(json['pending']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String?>(json['icon']),
      color: serializer.fromJson<String?>(json['color']),
      type: serializer.fromJson<String>(json['type']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'remoteUpdatedAt': serializer.toJson<String?>(remoteUpdatedAt),
      'pending': serializer.toJson<bool>(pending),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String?>(icon),
      'color': serializer.toJson<String?>(color),
      'type': serializer.toJson<String>(type),
      'isDefault': serializer.toJson<bool>(isDefault),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  CategoryRow copyWith({
    String? id,
    Value<String?> remoteUpdatedAt = const Value.absent(),
    bool? pending,
    String? name,
    Value<String?> icon = const Value.absent(),
    Value<String?> color = const Value.absent(),
    String? type,
    bool? isDefault,
    bool? isArchived,
  }) => CategoryRow(
    id: id ?? this.id,
    remoteUpdatedAt: remoteUpdatedAt.present
        ? remoteUpdatedAt.value
        : this.remoteUpdatedAt,
    pending: pending ?? this.pending,
    name: name ?? this.name,
    icon: icon.present ? icon.value : this.icon,
    color: color.present ? color.value : this.color,
    type: type ?? this.type,
    isDefault: isDefault ?? this.isDefault,
    isArchived: isArchived ?? this.isArchived,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      remoteUpdatedAt: data.remoteUpdatedAt.present
          ? data.remoteUpdatedAt.value
          : this.remoteUpdatedAt,
      pending: data.pending.present ? data.pending.value : this.pending,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      type: data.type.present ? data.type.value : this.type,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('remoteUpdatedAt: $remoteUpdatedAt, ')
          ..write('pending: $pending, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('type: $type, ')
          ..write('isDefault: $isDefault, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    remoteUpdatedAt,
    pending,
    name,
    icon,
    color,
    type,
    isDefault,
    isArchived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.remoteUpdatedAt == this.remoteUpdatedAt &&
          other.pending == this.pending &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.type == this.type &&
          other.isDefault == this.isDefault &&
          other.isArchived == this.isArchived);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> id;
  final Value<String?> remoteUpdatedAt;
  final Value<bool> pending;
  final Value<String> name;
  final Value<String?> icon;
  final Value<String?> color;
  final Value<String> type;
  final Value<bool> isDefault;
  final Value<bool> isArchived;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.remoteUpdatedAt = const Value.absent(),
    this.pending = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.type = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    this.remoteUpdatedAt = const Value.absent(),
    this.pending = const Value.absent(),
    required String name,
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    required String type,
    this.isDefault = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type);
  static Insertable<CategoryRow> custom({
    Expression<String>? id,
    Expression<String>? remoteUpdatedAt,
    Expression<bool>? pending,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<String>? type,
    Expression<bool>? isDefault,
    Expression<bool>? isArchived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteUpdatedAt != null) 'remote_updated_at': remoteUpdatedAt,
      if (pending != null) 'pending': pending,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (type != null) 'type': type,
      if (isDefault != null) 'is_default': isDefault,
      if (isArchived != null) 'is_archived': isArchived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String?>? remoteUpdatedAt,
    Value<bool>? pending,
    Value<String>? name,
    Value<String?>? icon,
    Value<String?>? color,
    Value<String>? type,
    Value<bool>? isDefault,
    Value<bool>? isArchived,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      remoteUpdatedAt: remoteUpdatedAt ?? this.remoteUpdatedAt,
      pending: pending ?? this.pending,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      isArchived: isArchived ?? this.isArchived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (remoteUpdatedAt.present) {
      map['remote_updated_at'] = Variable<String>(remoteUpdatedAt.value);
    }
    if (pending.present) {
      map['pending'] = Variable<bool>(pending.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('remoteUpdatedAt: $remoteUpdatedAt, ')
          ..write('pending: $pending, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('type: $type, ')
          ..write('isDefault: $isDefault, ')
          ..write('isArchived: $isArchived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PayeesTable extends Payees with TableInfo<$PayeesTable, PayeeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PayeesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteUpdatedAtMeta = const VerificationMeta(
    'remoteUpdatedAt',
  );
  @override
  late final GeneratedColumn<String> remoteUpdatedAt = GeneratedColumn<String>(
    'remote_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingMeta = const VerificationMeta(
    'pending',
  );
  @override
  late final GeneratedColumn<bool> pending = GeneratedColumn<bool>(
    'pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteUpdatedAt,
    pending,
    name,
    isArchived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payees';
  @override
  VerificationContext validateIntegrity(
    Insertable<PayeeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('remote_updated_at')) {
      context.handle(
        _remoteUpdatedAtMeta,
        remoteUpdatedAt.isAcceptableOrUnknown(
          data['remote_updated_at']!,
          _remoteUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('pending')) {
      context.handle(
        _pendingMeta,
        pending.isAcceptableOrUnknown(data['pending']!, _pendingMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PayeeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PayeeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      remoteUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_updated_at'],
      ),
      pending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
    );
  }

  @override
  $PayeesTable createAlias(String alias) {
    return $PayeesTable(attachedDatabase, alias);
  }
}

class PayeeRow extends DataClass implements Insertable<PayeeRow> {
  final String id;
  final String? remoteUpdatedAt;
  final bool pending;
  final String name;
  final bool isArchived;
  const PayeeRow({
    required this.id,
    this.remoteUpdatedAt,
    required this.pending,
    required this.name,
    required this.isArchived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || remoteUpdatedAt != null) {
      map['remote_updated_at'] = Variable<String>(remoteUpdatedAt);
    }
    map['pending'] = Variable<bool>(pending);
    map['name'] = Variable<String>(name);
    map['is_archived'] = Variable<bool>(isArchived);
    return map;
  }

  PayeesCompanion toCompanion(bool nullToAbsent) {
    return PayeesCompanion(
      id: Value(id),
      remoteUpdatedAt: remoteUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteUpdatedAt),
      pending: Value(pending),
      name: Value(name),
      isArchived: Value(isArchived),
    );
  }

  factory PayeeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PayeeRow(
      id: serializer.fromJson<String>(json['id']),
      remoteUpdatedAt: serializer.fromJson<String?>(json['remoteUpdatedAt']),
      pending: serializer.fromJson<bool>(json['pending']),
      name: serializer.fromJson<String>(json['name']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'remoteUpdatedAt': serializer.toJson<String?>(remoteUpdatedAt),
      'pending': serializer.toJson<bool>(pending),
      'name': serializer.toJson<String>(name),
      'isArchived': serializer.toJson<bool>(isArchived),
    };
  }

  PayeeRow copyWith({
    String? id,
    Value<String?> remoteUpdatedAt = const Value.absent(),
    bool? pending,
    String? name,
    bool? isArchived,
  }) => PayeeRow(
    id: id ?? this.id,
    remoteUpdatedAt: remoteUpdatedAt.present
        ? remoteUpdatedAt.value
        : this.remoteUpdatedAt,
    pending: pending ?? this.pending,
    name: name ?? this.name,
    isArchived: isArchived ?? this.isArchived,
  );
  PayeeRow copyWithCompanion(PayeesCompanion data) {
    return PayeeRow(
      id: data.id.present ? data.id.value : this.id,
      remoteUpdatedAt: data.remoteUpdatedAt.present
          ? data.remoteUpdatedAt.value
          : this.remoteUpdatedAt,
      pending: data.pending.present ? data.pending.value : this.pending,
      name: data.name.present ? data.name.value : this.name,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PayeeRow(')
          ..write('id: $id, ')
          ..write('remoteUpdatedAt: $remoteUpdatedAt, ')
          ..write('pending: $pending, ')
          ..write('name: $name, ')
          ..write('isArchived: $isArchived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, remoteUpdatedAt, pending, name, isArchived);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PayeeRow &&
          other.id == this.id &&
          other.remoteUpdatedAt == this.remoteUpdatedAt &&
          other.pending == this.pending &&
          other.name == this.name &&
          other.isArchived == this.isArchived);
}

class PayeesCompanion extends UpdateCompanion<PayeeRow> {
  final Value<String> id;
  final Value<String?> remoteUpdatedAt;
  final Value<bool> pending;
  final Value<String> name;
  final Value<bool> isArchived;
  final Value<int> rowid;
  const PayeesCompanion({
    this.id = const Value.absent(),
    this.remoteUpdatedAt = const Value.absent(),
    this.pending = const Value.absent(),
    this.name = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PayeesCompanion.insert({
    required String id,
    this.remoteUpdatedAt = const Value.absent(),
    this.pending = const Value.absent(),
    required String name,
    this.isArchived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<PayeeRow> custom({
    Expression<String>? id,
    Expression<String>? remoteUpdatedAt,
    Expression<bool>? pending,
    Expression<String>? name,
    Expression<bool>? isArchived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteUpdatedAt != null) 'remote_updated_at': remoteUpdatedAt,
      if (pending != null) 'pending': pending,
      if (name != null) 'name': name,
      if (isArchived != null) 'is_archived': isArchived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PayeesCompanion copyWith({
    Value<String>? id,
    Value<String?>? remoteUpdatedAt,
    Value<bool>? pending,
    Value<String>? name,
    Value<bool>? isArchived,
    Value<int>? rowid,
  }) {
    return PayeesCompanion(
      id: id ?? this.id,
      remoteUpdatedAt: remoteUpdatedAt ?? this.remoteUpdatedAt,
      pending: pending ?? this.pending,
      name: name ?? this.name,
      isArchived: isArchived ?? this.isArchived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (remoteUpdatedAt.present) {
      map['remote_updated_at'] = Variable<String>(remoteUpdatedAt.value);
    }
    if (pending.present) {
      map['pending'] = Variable<bool>(pending.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PayeesCompanion(')
          ..write('id: $id, ')
          ..write('remoteUpdatedAt: $remoteUpdatedAt, ')
          ..write('pending: $pending, ')
          ..write('name: $name, ')
          ..write('isArchived: $isArchived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyBudgetsTable extends DailyBudgets
    with TableInfo<$DailyBudgetsTable, DailyBudgetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyBudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteUpdatedAtMeta = const VerificationMeta(
    'remoteUpdatedAt',
  );
  @override
  late final GeneratedColumn<String> remoteUpdatedAt = GeneratedColumn<String>(
    'remote_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingMeta = const VerificationMeta(
    'pending',
  );
  @override
  late final GeneratedColumn<bool> pending = GeneratedColumn<bool>(
    'pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _budgetDateMeta = const VerificationMeta(
    'budgetDate',
  );
  @override
  late final GeneratedColumn<String> budgetDate = GeneratedColumn<String>(
    'budget_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalLimitMeta = const VerificationMeta(
    'totalLimit',
  );
  @override
  late final GeneratedColumn<int> totalLimit = GeneratedColumn<int>(
    'total_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalLimitMeta = const VerificationMeta(
    'originalLimit',
  );
  @override
  late final GeneratedColumn<int> originalLimit = GeneratedColumn<int>(
    'original_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isClosedMeta = const VerificationMeta(
    'isClosed',
  );
  @override
  late final GeneratedColumn<bool> isClosed = GeneratedColumn<bool>(
    'is_closed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_closed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<String> closedAt = GeneratedColumn<String>(
    'closed_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteUpdatedAt,
    pending,
    budgetDate,
    totalLimit,
    originalLimit,
    notes,
    isClosed,
    closedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyBudgetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('remote_updated_at')) {
      context.handle(
        _remoteUpdatedAtMeta,
        remoteUpdatedAt.isAcceptableOrUnknown(
          data['remote_updated_at']!,
          _remoteUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('pending')) {
      context.handle(
        _pendingMeta,
        pending.isAcceptableOrUnknown(data['pending']!, _pendingMeta),
      );
    }
    if (data.containsKey('budget_date')) {
      context.handle(
        _budgetDateMeta,
        budgetDate.isAcceptableOrUnknown(data['budget_date']!, _budgetDateMeta),
      );
    } else if (isInserting) {
      context.missing(_budgetDateMeta);
    }
    if (data.containsKey('total_limit')) {
      context.handle(
        _totalLimitMeta,
        totalLimit.isAcceptableOrUnknown(data['total_limit']!, _totalLimitMeta),
      );
    } else if (isInserting) {
      context.missing(_totalLimitMeta);
    }
    if (data.containsKey('original_limit')) {
      context.handle(
        _originalLimitMeta,
        originalLimit.isAcceptableOrUnknown(
          data['original_limit']!,
          _originalLimitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalLimitMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_closed')) {
      context.handle(
        _isClosedMeta,
        isClosed.isAcceptableOrUnknown(data['is_closed']!, _isClosedMeta),
      );
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyBudgetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyBudgetRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      remoteUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_updated_at'],
      ),
      pending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending'],
      )!,
      budgetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}budget_date'],
      )!,
      totalLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_limit'],
      )!,
      originalLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}original_limit'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isClosed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_closed'],
      )!,
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}closed_at'],
      ),
    );
  }

  @override
  $DailyBudgetsTable createAlias(String alias) {
    return $DailyBudgetsTable(attachedDatabase, alias);
  }
}

class DailyBudgetRow extends DataClass implements Insertable<DailyBudgetRow> {
  final String id;
  final String? remoteUpdatedAt;
  final bool pending;
  final String budgetDate;
  final int totalLimit;
  final int originalLimit;
  final String? notes;
  final bool isClosed;
  final String? closedAt;
  const DailyBudgetRow({
    required this.id,
    this.remoteUpdatedAt,
    required this.pending,
    required this.budgetDate,
    required this.totalLimit,
    required this.originalLimit,
    this.notes,
    required this.isClosed,
    this.closedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || remoteUpdatedAt != null) {
      map['remote_updated_at'] = Variable<String>(remoteUpdatedAt);
    }
    map['pending'] = Variable<bool>(pending);
    map['budget_date'] = Variable<String>(budgetDate);
    map['total_limit'] = Variable<int>(totalLimit);
    map['original_limit'] = Variable<int>(originalLimit);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_closed'] = Variable<bool>(isClosed);
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<String>(closedAt);
    }
    return map;
  }

  DailyBudgetsCompanion toCompanion(bool nullToAbsent) {
    return DailyBudgetsCompanion(
      id: Value(id),
      remoteUpdatedAt: remoteUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteUpdatedAt),
      pending: Value(pending),
      budgetDate: Value(budgetDate),
      totalLimit: Value(totalLimit),
      originalLimit: Value(originalLimit),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isClosed: Value(isClosed),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
    );
  }

  factory DailyBudgetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyBudgetRow(
      id: serializer.fromJson<String>(json['id']),
      remoteUpdatedAt: serializer.fromJson<String?>(json['remoteUpdatedAt']),
      pending: serializer.fromJson<bool>(json['pending']),
      budgetDate: serializer.fromJson<String>(json['budgetDate']),
      totalLimit: serializer.fromJson<int>(json['totalLimit']),
      originalLimit: serializer.fromJson<int>(json['originalLimit']),
      notes: serializer.fromJson<String?>(json['notes']),
      isClosed: serializer.fromJson<bool>(json['isClosed']),
      closedAt: serializer.fromJson<String?>(json['closedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'remoteUpdatedAt': serializer.toJson<String?>(remoteUpdatedAt),
      'pending': serializer.toJson<bool>(pending),
      'budgetDate': serializer.toJson<String>(budgetDate),
      'totalLimit': serializer.toJson<int>(totalLimit),
      'originalLimit': serializer.toJson<int>(originalLimit),
      'notes': serializer.toJson<String?>(notes),
      'isClosed': serializer.toJson<bool>(isClosed),
      'closedAt': serializer.toJson<String?>(closedAt),
    };
  }

  DailyBudgetRow copyWith({
    String? id,
    Value<String?> remoteUpdatedAt = const Value.absent(),
    bool? pending,
    String? budgetDate,
    int? totalLimit,
    int? originalLimit,
    Value<String?> notes = const Value.absent(),
    bool? isClosed,
    Value<String?> closedAt = const Value.absent(),
  }) => DailyBudgetRow(
    id: id ?? this.id,
    remoteUpdatedAt: remoteUpdatedAt.present
        ? remoteUpdatedAt.value
        : this.remoteUpdatedAt,
    pending: pending ?? this.pending,
    budgetDate: budgetDate ?? this.budgetDate,
    totalLimit: totalLimit ?? this.totalLimit,
    originalLimit: originalLimit ?? this.originalLimit,
    notes: notes.present ? notes.value : this.notes,
    isClosed: isClosed ?? this.isClosed,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
  );
  DailyBudgetRow copyWithCompanion(DailyBudgetsCompanion data) {
    return DailyBudgetRow(
      id: data.id.present ? data.id.value : this.id,
      remoteUpdatedAt: data.remoteUpdatedAt.present
          ? data.remoteUpdatedAt.value
          : this.remoteUpdatedAt,
      pending: data.pending.present ? data.pending.value : this.pending,
      budgetDate: data.budgetDate.present
          ? data.budgetDate.value
          : this.budgetDate,
      totalLimit: data.totalLimit.present
          ? data.totalLimit.value
          : this.totalLimit,
      originalLimit: data.originalLimit.present
          ? data.originalLimit.value
          : this.originalLimit,
      notes: data.notes.present ? data.notes.value : this.notes,
      isClosed: data.isClosed.present ? data.isClosed.value : this.isClosed,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyBudgetRow(')
          ..write('id: $id, ')
          ..write('remoteUpdatedAt: $remoteUpdatedAt, ')
          ..write('pending: $pending, ')
          ..write('budgetDate: $budgetDate, ')
          ..write('totalLimit: $totalLimit, ')
          ..write('originalLimit: $originalLimit, ')
          ..write('notes: $notes, ')
          ..write('isClosed: $isClosed, ')
          ..write('closedAt: $closedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    remoteUpdatedAt,
    pending,
    budgetDate,
    totalLimit,
    originalLimit,
    notes,
    isClosed,
    closedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyBudgetRow &&
          other.id == this.id &&
          other.remoteUpdatedAt == this.remoteUpdatedAt &&
          other.pending == this.pending &&
          other.budgetDate == this.budgetDate &&
          other.totalLimit == this.totalLimit &&
          other.originalLimit == this.originalLimit &&
          other.notes == this.notes &&
          other.isClosed == this.isClosed &&
          other.closedAt == this.closedAt);
}

class DailyBudgetsCompanion extends UpdateCompanion<DailyBudgetRow> {
  final Value<String> id;
  final Value<String?> remoteUpdatedAt;
  final Value<bool> pending;
  final Value<String> budgetDate;
  final Value<int> totalLimit;
  final Value<int> originalLimit;
  final Value<String?> notes;
  final Value<bool> isClosed;
  final Value<String?> closedAt;
  final Value<int> rowid;
  const DailyBudgetsCompanion({
    this.id = const Value.absent(),
    this.remoteUpdatedAt = const Value.absent(),
    this.pending = const Value.absent(),
    this.budgetDate = const Value.absent(),
    this.totalLimit = const Value.absent(),
    this.originalLimit = const Value.absent(),
    this.notes = const Value.absent(),
    this.isClosed = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyBudgetsCompanion.insert({
    required String id,
    this.remoteUpdatedAt = const Value.absent(),
    this.pending = const Value.absent(),
    required String budgetDate,
    required int totalLimit,
    required int originalLimit,
    this.notes = const Value.absent(),
    this.isClosed = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       budgetDate = Value(budgetDate),
       totalLimit = Value(totalLimit),
       originalLimit = Value(originalLimit);
  static Insertable<DailyBudgetRow> custom({
    Expression<String>? id,
    Expression<String>? remoteUpdatedAt,
    Expression<bool>? pending,
    Expression<String>? budgetDate,
    Expression<int>? totalLimit,
    Expression<int>? originalLimit,
    Expression<String>? notes,
    Expression<bool>? isClosed,
    Expression<String>? closedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteUpdatedAt != null) 'remote_updated_at': remoteUpdatedAt,
      if (pending != null) 'pending': pending,
      if (budgetDate != null) 'budget_date': budgetDate,
      if (totalLimit != null) 'total_limit': totalLimit,
      if (originalLimit != null) 'original_limit': originalLimit,
      if (notes != null) 'notes': notes,
      if (isClosed != null) 'is_closed': isClosed,
      if (closedAt != null) 'closed_at': closedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyBudgetsCompanion copyWith({
    Value<String>? id,
    Value<String?>? remoteUpdatedAt,
    Value<bool>? pending,
    Value<String>? budgetDate,
    Value<int>? totalLimit,
    Value<int>? originalLimit,
    Value<String?>? notes,
    Value<bool>? isClosed,
    Value<String?>? closedAt,
    Value<int>? rowid,
  }) {
    return DailyBudgetsCompanion(
      id: id ?? this.id,
      remoteUpdatedAt: remoteUpdatedAt ?? this.remoteUpdatedAt,
      pending: pending ?? this.pending,
      budgetDate: budgetDate ?? this.budgetDate,
      totalLimit: totalLimit ?? this.totalLimit,
      originalLimit: originalLimit ?? this.originalLimit,
      notes: notes ?? this.notes,
      isClosed: isClosed ?? this.isClosed,
      closedAt: closedAt ?? this.closedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (remoteUpdatedAt.present) {
      map['remote_updated_at'] = Variable<String>(remoteUpdatedAt.value);
    }
    if (pending.present) {
      map['pending'] = Variable<bool>(pending.value);
    }
    if (budgetDate.present) {
      map['budget_date'] = Variable<String>(budgetDate.value);
    }
    if (totalLimit.present) {
      map['total_limit'] = Variable<int>(totalLimit.value);
    }
    if (originalLimit.present) {
      map['original_limit'] = Variable<int>(originalLimit.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isClosed.present) {
      map['is_closed'] = Variable<bool>(isClosed.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<String>(closedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyBudgetsCompanion(')
          ..write('id: $id, ')
          ..write('remoteUpdatedAt: $remoteUpdatedAt, ')
          ..write('pending: $pending, ')
          ..write('budgetDate: $budgetDate, ')
          ..write('totalLimit: $totalLimit, ')
          ..write('originalLimit: $originalLimit, ')
          ..write('notes: $notes, ')
          ..write('isClosed: $isClosed, ')
          ..write('closedAt: $closedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetAllocationsTable extends BudgetAllocations
    with TableInfo<$BudgetAllocationsTable, BudgetAllocationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetAllocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteUpdatedAtMeta = const VerificationMeta(
    'remoteUpdatedAt',
  );
  @override
  late final GeneratedColumn<String> remoteUpdatedAt = GeneratedColumn<String>(
    'remote_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingMeta = const VerificationMeta(
    'pending',
  );
  @override
  late final GeneratedColumn<bool> pending = GeneratedColumn<bool>(
    'pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dailyBudgetIdMeta = const VerificationMeta(
    'dailyBudgetId',
  );
  @override
  late final GeneratedColumn<String> dailyBudgetId = GeneratedColumn<String>(
    'daily_budget_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedAmountMeta = const VerificationMeta(
    'plannedAmount',
  );
  @override
  late final GeneratedColumn<int> plannedAmount = GeneratedColumn<int>(
    'planned_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalAmountMeta = const VerificationMeta(
    'originalAmount',
  );
  @override
  late final GeneratedColumn<int> originalAmount = GeneratedColumn<int>(
    'original_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteUpdatedAt,
    pending,
    dailyBudgetId,
    categoryId,
    plannedAmount,
    originalAmount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budget_allocations';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetAllocationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('remote_updated_at')) {
      context.handle(
        _remoteUpdatedAtMeta,
        remoteUpdatedAt.isAcceptableOrUnknown(
          data['remote_updated_at']!,
          _remoteUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('pending')) {
      context.handle(
        _pendingMeta,
        pending.isAcceptableOrUnknown(data['pending']!, _pendingMeta),
      );
    }
    if (data.containsKey('daily_budget_id')) {
      context.handle(
        _dailyBudgetIdMeta,
        dailyBudgetId.isAcceptableOrUnknown(
          data['daily_budget_id']!,
          _dailyBudgetIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dailyBudgetIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('planned_amount')) {
      context.handle(
        _plannedAmountMeta,
        plannedAmount.isAcceptableOrUnknown(
          data['planned_amount']!,
          _plannedAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedAmountMeta);
    }
    if (data.containsKey('original_amount')) {
      context.handle(
        _originalAmountMeta,
        originalAmount.isAcceptableOrUnknown(
          data['original_amount']!,
          _originalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalAmountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BudgetAllocationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetAllocationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      remoteUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_updated_at'],
      ),
      pending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending'],
      )!,
      dailyBudgetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}daily_budget_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      plannedAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_amount'],
      )!,
      originalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}original_amount'],
      )!,
    );
  }

  @override
  $BudgetAllocationsTable createAlias(String alias) {
    return $BudgetAllocationsTable(attachedDatabase, alias);
  }
}

class BudgetAllocationRow extends DataClass
    implements Insertable<BudgetAllocationRow> {
  final String id;
  final String? remoteUpdatedAt;
  final bool pending;
  final String dailyBudgetId;
  final String categoryId;
  final int plannedAmount;
  final int originalAmount;
  const BudgetAllocationRow({
    required this.id,
    this.remoteUpdatedAt,
    required this.pending,
    required this.dailyBudgetId,
    required this.categoryId,
    required this.plannedAmount,
    required this.originalAmount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || remoteUpdatedAt != null) {
      map['remote_updated_at'] = Variable<String>(remoteUpdatedAt);
    }
    map['pending'] = Variable<bool>(pending);
    map['daily_budget_id'] = Variable<String>(dailyBudgetId);
    map['category_id'] = Variable<String>(categoryId);
    map['planned_amount'] = Variable<int>(plannedAmount);
    map['original_amount'] = Variable<int>(originalAmount);
    return map;
  }

  BudgetAllocationsCompanion toCompanion(bool nullToAbsent) {
    return BudgetAllocationsCompanion(
      id: Value(id),
      remoteUpdatedAt: remoteUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteUpdatedAt),
      pending: Value(pending),
      dailyBudgetId: Value(dailyBudgetId),
      categoryId: Value(categoryId),
      plannedAmount: Value(plannedAmount),
      originalAmount: Value(originalAmount),
    );
  }

  factory BudgetAllocationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetAllocationRow(
      id: serializer.fromJson<String>(json['id']),
      remoteUpdatedAt: serializer.fromJson<String?>(json['remoteUpdatedAt']),
      pending: serializer.fromJson<bool>(json['pending']),
      dailyBudgetId: serializer.fromJson<String>(json['dailyBudgetId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      plannedAmount: serializer.fromJson<int>(json['plannedAmount']),
      originalAmount: serializer.fromJson<int>(json['originalAmount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'remoteUpdatedAt': serializer.toJson<String?>(remoteUpdatedAt),
      'pending': serializer.toJson<bool>(pending),
      'dailyBudgetId': serializer.toJson<String>(dailyBudgetId),
      'categoryId': serializer.toJson<String>(categoryId),
      'plannedAmount': serializer.toJson<int>(plannedAmount),
      'originalAmount': serializer.toJson<int>(originalAmount),
    };
  }

  BudgetAllocationRow copyWith({
    String? id,
    Value<String?> remoteUpdatedAt = const Value.absent(),
    bool? pending,
    String? dailyBudgetId,
    String? categoryId,
    int? plannedAmount,
    int? originalAmount,
  }) => BudgetAllocationRow(
    id: id ?? this.id,
    remoteUpdatedAt: remoteUpdatedAt.present
        ? remoteUpdatedAt.value
        : this.remoteUpdatedAt,
    pending: pending ?? this.pending,
    dailyBudgetId: dailyBudgetId ?? this.dailyBudgetId,
    categoryId: categoryId ?? this.categoryId,
    plannedAmount: plannedAmount ?? this.plannedAmount,
    originalAmount: originalAmount ?? this.originalAmount,
  );
  BudgetAllocationRow copyWithCompanion(BudgetAllocationsCompanion data) {
    return BudgetAllocationRow(
      id: data.id.present ? data.id.value : this.id,
      remoteUpdatedAt: data.remoteUpdatedAt.present
          ? data.remoteUpdatedAt.value
          : this.remoteUpdatedAt,
      pending: data.pending.present ? data.pending.value : this.pending,
      dailyBudgetId: data.dailyBudgetId.present
          ? data.dailyBudgetId.value
          : this.dailyBudgetId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      plannedAmount: data.plannedAmount.present
          ? data.plannedAmount.value
          : this.plannedAmount,
      originalAmount: data.originalAmount.present
          ? data.originalAmount.value
          : this.originalAmount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetAllocationRow(')
          ..write('id: $id, ')
          ..write('remoteUpdatedAt: $remoteUpdatedAt, ')
          ..write('pending: $pending, ')
          ..write('dailyBudgetId: $dailyBudgetId, ')
          ..write('categoryId: $categoryId, ')
          ..write('plannedAmount: $plannedAmount, ')
          ..write('originalAmount: $originalAmount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    remoteUpdatedAt,
    pending,
    dailyBudgetId,
    categoryId,
    plannedAmount,
    originalAmount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetAllocationRow &&
          other.id == this.id &&
          other.remoteUpdatedAt == this.remoteUpdatedAt &&
          other.pending == this.pending &&
          other.dailyBudgetId == this.dailyBudgetId &&
          other.categoryId == this.categoryId &&
          other.plannedAmount == this.plannedAmount &&
          other.originalAmount == this.originalAmount);
}

class BudgetAllocationsCompanion extends UpdateCompanion<BudgetAllocationRow> {
  final Value<String> id;
  final Value<String?> remoteUpdatedAt;
  final Value<bool> pending;
  final Value<String> dailyBudgetId;
  final Value<String> categoryId;
  final Value<int> plannedAmount;
  final Value<int> originalAmount;
  final Value<int> rowid;
  const BudgetAllocationsCompanion({
    this.id = const Value.absent(),
    this.remoteUpdatedAt = const Value.absent(),
    this.pending = const Value.absent(),
    this.dailyBudgetId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.plannedAmount = const Value.absent(),
    this.originalAmount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetAllocationsCompanion.insert({
    required String id,
    this.remoteUpdatedAt = const Value.absent(),
    this.pending = const Value.absent(),
    required String dailyBudgetId,
    required String categoryId,
    required int plannedAmount,
    required int originalAmount,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       dailyBudgetId = Value(dailyBudgetId),
       categoryId = Value(categoryId),
       plannedAmount = Value(plannedAmount),
       originalAmount = Value(originalAmount);
  static Insertable<BudgetAllocationRow> custom({
    Expression<String>? id,
    Expression<String>? remoteUpdatedAt,
    Expression<bool>? pending,
    Expression<String>? dailyBudgetId,
    Expression<String>? categoryId,
    Expression<int>? plannedAmount,
    Expression<int>? originalAmount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteUpdatedAt != null) 'remote_updated_at': remoteUpdatedAt,
      if (pending != null) 'pending': pending,
      if (dailyBudgetId != null) 'daily_budget_id': dailyBudgetId,
      if (categoryId != null) 'category_id': categoryId,
      if (plannedAmount != null) 'planned_amount': plannedAmount,
      if (originalAmount != null) 'original_amount': originalAmount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetAllocationsCompanion copyWith({
    Value<String>? id,
    Value<String?>? remoteUpdatedAt,
    Value<bool>? pending,
    Value<String>? dailyBudgetId,
    Value<String>? categoryId,
    Value<int>? plannedAmount,
    Value<int>? originalAmount,
    Value<int>? rowid,
  }) {
    return BudgetAllocationsCompanion(
      id: id ?? this.id,
      remoteUpdatedAt: remoteUpdatedAt ?? this.remoteUpdatedAt,
      pending: pending ?? this.pending,
      dailyBudgetId: dailyBudgetId ?? this.dailyBudgetId,
      categoryId: categoryId ?? this.categoryId,
      plannedAmount: plannedAmount ?? this.plannedAmount,
      originalAmount: originalAmount ?? this.originalAmount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (remoteUpdatedAt.present) {
      map['remote_updated_at'] = Variable<String>(remoteUpdatedAt.value);
    }
    if (pending.present) {
      map['pending'] = Variable<bool>(pending.value);
    }
    if (dailyBudgetId.present) {
      map['daily_budget_id'] = Variable<String>(dailyBudgetId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (plannedAmount.present) {
      map['planned_amount'] = Variable<int>(plannedAmount.value);
    }
    if (originalAmount.present) {
      map['original_amount'] = Variable<int>(originalAmount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetAllocationsCompanion(')
          ..write('id: $id, ')
          ..write('remoteUpdatedAt: $remoteUpdatedAt, ')
          ..write('pending: $pending, ')
          ..write('dailyBudgetId: $dailyBudgetId, ')
          ..write('categoryId: $categoryId, ')
          ..write('plannedAmount: $plannedAmount, ')
          ..write('originalAmount: $originalAmount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetTemplatesTable extends BudgetTemplates
    with TableInfo<$BudgetTemplatesTable, BudgetTemplateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteUpdatedAtMeta = const VerificationMeta(
    'remoteUpdatedAt',
  );
  @override
  late final GeneratedColumn<String> remoteUpdatedAt = GeneratedColumn<String>(
    'remote_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingMeta = const VerificationMeta(
    'pending',
  );
  @override
  late final GeneratedColumn<bool> pending = GeneratedColumn<bool>(
    'pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _totalLimitMeta = const VerificationMeta(
    'totalLimit',
  );
  @override
  late final GeneratedColumn<int> totalLimit = GeneratedColumn<int>(
    'total_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _allocationsJsonMeta = const VerificationMeta(
    'allocationsJson',
  );
  @override
  late final GeneratedColumn<String> allocationsJson = GeneratedColumn<String>(
    'allocations_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteUpdatedAt,
    pending,
    totalLimit,
    allocationsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budget_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetTemplateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('remote_updated_at')) {
      context.handle(
        _remoteUpdatedAtMeta,
        remoteUpdatedAt.isAcceptableOrUnknown(
          data['remote_updated_at']!,
          _remoteUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('pending')) {
      context.handle(
        _pendingMeta,
        pending.isAcceptableOrUnknown(data['pending']!, _pendingMeta),
      );
    }
    if (data.containsKey('total_limit')) {
      context.handle(
        _totalLimitMeta,
        totalLimit.isAcceptableOrUnknown(data['total_limit']!, _totalLimitMeta),
      );
    } else if (isInserting) {
      context.missing(_totalLimitMeta);
    }
    if (data.containsKey('allocations_json')) {
      context.handle(
        _allocationsJsonMeta,
        allocationsJson.isAcceptableOrUnknown(
          data['allocations_json']!,
          _allocationsJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BudgetTemplateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetTemplateRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      remoteUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_updated_at'],
      ),
      pending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending'],
      )!,
      totalLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_limit'],
      )!,
      allocationsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allocations_json'],
      )!,
    );
  }

  @override
  $BudgetTemplatesTable createAlias(String alias) {
    return $BudgetTemplatesTable(attachedDatabase, alias);
  }
}

class BudgetTemplateRow extends DataClass
    implements Insertable<BudgetTemplateRow> {
  final String id;
  final String? remoteUpdatedAt;
  final bool pending;
  final int totalLimit;
  final String allocationsJson;
  const BudgetTemplateRow({
    required this.id,
    this.remoteUpdatedAt,
    required this.pending,
    required this.totalLimit,
    required this.allocationsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || remoteUpdatedAt != null) {
      map['remote_updated_at'] = Variable<String>(remoteUpdatedAt);
    }
    map['pending'] = Variable<bool>(pending);
    map['total_limit'] = Variable<int>(totalLimit);
    map['allocations_json'] = Variable<String>(allocationsJson);
    return map;
  }

  BudgetTemplatesCompanion toCompanion(bool nullToAbsent) {
    return BudgetTemplatesCompanion(
      id: Value(id),
      remoteUpdatedAt: remoteUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteUpdatedAt),
      pending: Value(pending),
      totalLimit: Value(totalLimit),
      allocationsJson: Value(allocationsJson),
    );
  }

  factory BudgetTemplateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetTemplateRow(
      id: serializer.fromJson<String>(json['id']),
      remoteUpdatedAt: serializer.fromJson<String?>(json['remoteUpdatedAt']),
      pending: serializer.fromJson<bool>(json['pending']),
      totalLimit: serializer.fromJson<int>(json['totalLimit']),
      allocationsJson: serializer.fromJson<String>(json['allocationsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'remoteUpdatedAt': serializer.toJson<String?>(remoteUpdatedAt),
      'pending': serializer.toJson<bool>(pending),
      'totalLimit': serializer.toJson<int>(totalLimit),
      'allocationsJson': serializer.toJson<String>(allocationsJson),
    };
  }

  BudgetTemplateRow copyWith({
    String? id,
    Value<String?> remoteUpdatedAt = const Value.absent(),
    bool? pending,
    int? totalLimit,
    String? allocationsJson,
  }) => BudgetTemplateRow(
    id: id ?? this.id,
    remoteUpdatedAt: remoteUpdatedAt.present
        ? remoteUpdatedAt.value
        : this.remoteUpdatedAt,
    pending: pending ?? this.pending,
    totalLimit: totalLimit ?? this.totalLimit,
    allocationsJson: allocationsJson ?? this.allocationsJson,
  );
  BudgetTemplateRow copyWithCompanion(BudgetTemplatesCompanion data) {
    return BudgetTemplateRow(
      id: data.id.present ? data.id.value : this.id,
      remoteUpdatedAt: data.remoteUpdatedAt.present
          ? data.remoteUpdatedAt.value
          : this.remoteUpdatedAt,
      pending: data.pending.present ? data.pending.value : this.pending,
      totalLimit: data.totalLimit.present
          ? data.totalLimit.value
          : this.totalLimit,
      allocationsJson: data.allocationsJson.present
          ? data.allocationsJson.value
          : this.allocationsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetTemplateRow(')
          ..write('id: $id, ')
          ..write('remoteUpdatedAt: $remoteUpdatedAt, ')
          ..write('pending: $pending, ')
          ..write('totalLimit: $totalLimit, ')
          ..write('allocationsJson: $allocationsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, remoteUpdatedAt, pending, totalLimit, allocationsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetTemplateRow &&
          other.id == this.id &&
          other.remoteUpdatedAt == this.remoteUpdatedAt &&
          other.pending == this.pending &&
          other.totalLimit == this.totalLimit &&
          other.allocationsJson == this.allocationsJson);
}

class BudgetTemplatesCompanion extends UpdateCompanion<BudgetTemplateRow> {
  final Value<String> id;
  final Value<String?> remoteUpdatedAt;
  final Value<bool> pending;
  final Value<int> totalLimit;
  final Value<String> allocationsJson;
  final Value<int> rowid;
  const BudgetTemplatesCompanion({
    this.id = const Value.absent(),
    this.remoteUpdatedAt = const Value.absent(),
    this.pending = const Value.absent(),
    this.totalLimit = const Value.absent(),
    this.allocationsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetTemplatesCompanion.insert({
    required String id,
    this.remoteUpdatedAt = const Value.absent(),
    this.pending = const Value.absent(),
    required int totalLimit,
    this.allocationsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       totalLimit = Value(totalLimit);
  static Insertable<BudgetTemplateRow> custom({
    Expression<String>? id,
    Expression<String>? remoteUpdatedAt,
    Expression<bool>? pending,
    Expression<int>? totalLimit,
    Expression<String>? allocationsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteUpdatedAt != null) 'remote_updated_at': remoteUpdatedAt,
      if (pending != null) 'pending': pending,
      if (totalLimit != null) 'total_limit': totalLimit,
      if (allocationsJson != null) 'allocations_json': allocationsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetTemplatesCompanion copyWith({
    Value<String>? id,
    Value<String?>? remoteUpdatedAt,
    Value<bool>? pending,
    Value<int>? totalLimit,
    Value<String>? allocationsJson,
    Value<int>? rowid,
  }) {
    return BudgetTemplatesCompanion(
      id: id ?? this.id,
      remoteUpdatedAt: remoteUpdatedAt ?? this.remoteUpdatedAt,
      pending: pending ?? this.pending,
      totalLimit: totalLimit ?? this.totalLimit,
      allocationsJson: allocationsJson ?? this.allocationsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (remoteUpdatedAt.present) {
      map['remote_updated_at'] = Variable<String>(remoteUpdatedAt.value);
    }
    if (pending.present) {
      map['pending'] = Variable<bool>(pending.value);
    }
    if (totalLimit.present) {
      map['total_limit'] = Variable<int>(totalLimit.value);
    }
    if (allocationsJson.present) {
      map['allocations_json'] = Variable<String>(allocationsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('remoteUpdatedAt: $remoteUpdatedAt, ')
          ..write('pending: $pending, ')
          ..write('totalLimit: $totalLimit, ')
          ..write('allocationsJson: $allocationsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlannedExpensesTable extends PlannedExpenses
    with TableInfo<$PlannedExpensesTable, PlannedExpenseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlannedExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteUpdatedAtMeta = const VerificationMeta(
    'remoteUpdatedAt',
  );
  @override
  late final GeneratedColumn<String> remoteUpdatedAt = GeneratedColumn<String>(
    'remote_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingMeta = const VerificationMeta(
    'pending',
  );
  @override
  late final GeneratedColumn<bool> pending = GeneratedColumn<bool>(
    'pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _plannedDateMeta = const VerificationMeta(
    'plannedDate',
  );
  @override
  late final GeneratedColumn<String> plannedDate = GeneratedColumn<String>(
    'planned_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedAmountMeta = const VerificationMeta(
    'expectedAmount',
  );
  @override
  late final GeneratedColumn<int> expectedAmount = GeneratedColumn<int>(
    'expected_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('planned'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteUpdatedAt,
    pending,
    plannedDate,
    categoryId,
    title,
    expectedAmount,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'planned_expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlannedExpenseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('remote_updated_at')) {
      context.handle(
        _remoteUpdatedAtMeta,
        remoteUpdatedAt.isAcceptableOrUnknown(
          data['remote_updated_at']!,
          _remoteUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('pending')) {
      context.handle(
        _pendingMeta,
        pending.isAcceptableOrUnknown(data['pending']!, _pendingMeta),
      );
    }
    if (data.containsKey('planned_date')) {
      context.handle(
        _plannedDateMeta,
        plannedDate.isAcceptableOrUnknown(
          data['planned_date']!,
          _plannedDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedDateMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('expected_amount')) {
      context.handle(
        _expectedAmountMeta,
        expectedAmount.isAcceptableOrUnknown(
          data['expected_amount']!,
          _expectedAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expectedAmountMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlannedExpenseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlannedExpenseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      remoteUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_updated_at'],
      ),
      pending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending'],
      )!,
      plannedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}planned_date'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      expectedAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_amount'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $PlannedExpensesTable createAlias(String alias) {
    return $PlannedExpensesTable(attachedDatabase, alias);
  }
}

class PlannedExpenseRow extends DataClass
    implements Insertable<PlannedExpenseRow> {
  final String id;
  final String? remoteUpdatedAt;
  final bool pending;
  final String plannedDate;
  final String categoryId;
  final String title;
  final int expectedAmount;
  final String status;
  const PlannedExpenseRow({
    required this.id,
    this.remoteUpdatedAt,
    required this.pending,
    required this.plannedDate,
    required this.categoryId,
    required this.title,
    required this.expectedAmount,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || remoteUpdatedAt != null) {
      map['remote_updated_at'] = Variable<String>(remoteUpdatedAt);
    }
    map['pending'] = Variable<bool>(pending);
    map['planned_date'] = Variable<String>(plannedDate);
    map['category_id'] = Variable<String>(categoryId);
    map['title'] = Variable<String>(title);
    map['expected_amount'] = Variable<int>(expectedAmount);
    map['status'] = Variable<String>(status);
    return map;
  }

  PlannedExpensesCompanion toCompanion(bool nullToAbsent) {
    return PlannedExpensesCompanion(
      id: Value(id),
      remoteUpdatedAt: remoteUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteUpdatedAt),
      pending: Value(pending),
      plannedDate: Value(plannedDate),
      categoryId: Value(categoryId),
      title: Value(title),
      expectedAmount: Value(expectedAmount),
      status: Value(status),
    );
  }

  factory PlannedExpenseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlannedExpenseRow(
      id: serializer.fromJson<String>(json['id']),
      remoteUpdatedAt: serializer.fromJson<String?>(json['remoteUpdatedAt']),
      pending: serializer.fromJson<bool>(json['pending']),
      plannedDate: serializer.fromJson<String>(json['plannedDate']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      title: serializer.fromJson<String>(json['title']),
      expectedAmount: serializer.fromJson<int>(json['expectedAmount']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'remoteUpdatedAt': serializer.toJson<String?>(remoteUpdatedAt),
      'pending': serializer.toJson<bool>(pending),
      'plannedDate': serializer.toJson<String>(plannedDate),
      'categoryId': serializer.toJson<String>(categoryId),
      'title': serializer.toJson<String>(title),
      'expectedAmount': serializer.toJson<int>(expectedAmount),
      'status': serializer.toJson<String>(status),
    };
  }

  PlannedExpenseRow copyWith({
    String? id,
    Value<String?> remoteUpdatedAt = const Value.absent(),
    bool? pending,
    String? plannedDate,
    String? categoryId,
    String? title,
    int? expectedAmount,
    String? status,
  }) => PlannedExpenseRow(
    id: id ?? this.id,
    remoteUpdatedAt: remoteUpdatedAt.present
        ? remoteUpdatedAt.value
        : this.remoteUpdatedAt,
    pending: pending ?? this.pending,
    plannedDate: plannedDate ?? this.plannedDate,
    categoryId: categoryId ?? this.categoryId,
    title: title ?? this.title,
    expectedAmount: expectedAmount ?? this.expectedAmount,
    status: status ?? this.status,
  );
  PlannedExpenseRow copyWithCompanion(PlannedExpensesCompanion data) {
    return PlannedExpenseRow(
      id: data.id.present ? data.id.value : this.id,
      remoteUpdatedAt: data.remoteUpdatedAt.present
          ? data.remoteUpdatedAt.value
          : this.remoteUpdatedAt,
      pending: data.pending.present ? data.pending.value : this.pending,
      plannedDate: data.plannedDate.present
          ? data.plannedDate.value
          : this.plannedDate,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      title: data.title.present ? data.title.value : this.title,
      expectedAmount: data.expectedAmount.present
          ? data.expectedAmount.value
          : this.expectedAmount,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlannedExpenseRow(')
          ..write('id: $id, ')
          ..write('remoteUpdatedAt: $remoteUpdatedAt, ')
          ..write('pending: $pending, ')
          ..write('plannedDate: $plannedDate, ')
          ..write('categoryId: $categoryId, ')
          ..write('title: $title, ')
          ..write('expectedAmount: $expectedAmount, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    remoteUpdatedAt,
    pending,
    plannedDate,
    categoryId,
    title,
    expectedAmount,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlannedExpenseRow &&
          other.id == this.id &&
          other.remoteUpdatedAt == this.remoteUpdatedAt &&
          other.pending == this.pending &&
          other.plannedDate == this.plannedDate &&
          other.categoryId == this.categoryId &&
          other.title == this.title &&
          other.expectedAmount == this.expectedAmount &&
          other.status == this.status);
}

class PlannedExpensesCompanion extends UpdateCompanion<PlannedExpenseRow> {
  final Value<String> id;
  final Value<String?> remoteUpdatedAt;
  final Value<bool> pending;
  final Value<String> plannedDate;
  final Value<String> categoryId;
  final Value<String> title;
  final Value<int> expectedAmount;
  final Value<String> status;
  final Value<int> rowid;
  const PlannedExpensesCompanion({
    this.id = const Value.absent(),
    this.remoteUpdatedAt = const Value.absent(),
    this.pending = const Value.absent(),
    this.plannedDate = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.title = const Value.absent(),
    this.expectedAmount = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlannedExpensesCompanion.insert({
    required String id,
    this.remoteUpdatedAt = const Value.absent(),
    this.pending = const Value.absent(),
    required String plannedDate,
    required String categoryId,
    required String title,
    required int expectedAmount,
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       plannedDate = Value(plannedDate),
       categoryId = Value(categoryId),
       title = Value(title),
       expectedAmount = Value(expectedAmount);
  static Insertable<PlannedExpenseRow> custom({
    Expression<String>? id,
    Expression<String>? remoteUpdatedAt,
    Expression<bool>? pending,
    Expression<String>? plannedDate,
    Expression<String>? categoryId,
    Expression<String>? title,
    Expression<int>? expectedAmount,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteUpdatedAt != null) 'remote_updated_at': remoteUpdatedAt,
      if (pending != null) 'pending': pending,
      if (plannedDate != null) 'planned_date': plannedDate,
      if (categoryId != null) 'category_id': categoryId,
      if (title != null) 'title': title,
      if (expectedAmount != null) 'expected_amount': expectedAmount,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlannedExpensesCompanion copyWith({
    Value<String>? id,
    Value<String?>? remoteUpdatedAt,
    Value<bool>? pending,
    Value<String>? plannedDate,
    Value<String>? categoryId,
    Value<String>? title,
    Value<int>? expectedAmount,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return PlannedExpensesCompanion(
      id: id ?? this.id,
      remoteUpdatedAt: remoteUpdatedAt ?? this.remoteUpdatedAt,
      pending: pending ?? this.pending,
      plannedDate: plannedDate ?? this.plannedDate,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      expectedAmount: expectedAmount ?? this.expectedAmount,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (remoteUpdatedAt.present) {
      map['remote_updated_at'] = Variable<String>(remoteUpdatedAt.value);
    }
    if (pending.present) {
      map['pending'] = Variable<bool>(pending.value);
    }
    if (plannedDate.present) {
      map['planned_date'] = Variable<String>(plannedDate.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (expectedAmount.present) {
      map['expected_amount'] = Variable<int>(expectedAmount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlannedExpensesCompanion(')
          ..write('id: $id, ')
          ..write('remoteUpdatedAt: $remoteUpdatedAt, ')
          ..write('pending: $pending, ')
          ..write('plannedDate: $plannedDate, ')
          ..write('categoryId: $categoryId, ')
          ..write('title: $title, ')
          ..write('expectedAmount: $expectedAmount, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, TransactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteUpdatedAtMeta = const VerificationMeta(
    'remoteUpdatedAt',
  );
  @override
  late final GeneratedColumn<String> remoteUpdatedAt = GeneratedColumn<String>(
    'remote_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingMeta = const VerificationMeta(
    'pending',
  );
  @override
  late final GeneratedColumn<bool> pending = GeneratedColumn<bool>(
    'pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payeeIdMeta = const VerificationMeta(
    'payeeId',
  );
  @override
  late final GeneratedColumn<String> payeeId = GeneratedColumn<String>(
    'payee_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transferDirectionMeta = const VerificationMeta(
    'transferDirection',
  );
  @override
  late final GeneratedColumn<String> transferDirection =
      GeneratedColumn<String>(
        'transfer_direction',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _transferGroupIdMeta = const VerificationMeta(
    'transferGroupId',
  );
  @override
  late final GeneratedColumn<String> transferGroupId = GeneratedColumn<String>(
    'transfer_group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMsMeta = const VerificationMeta(
    'occurredAtMs',
  );
  @override
  late final GeneratedColumn<int> occurredAtMs = GeneratedColumn<int>(
    'occurred_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _merchantMeta = const VerificationMeta(
    'merchant',
  );
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
    'merchant',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedStatusMeta = const VerificationMeta(
    'plannedStatus',
  );
  @override
  late final GeneratedColumn<String> plannedStatus = GeneratedColumn<String>(
    'planned_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unplanned'),
  );
  static const VerificationMeta _receiptPathMeta = const VerificationMeta(
    'receiptPath',
  );
  @override
  late final GeneratedColumn<String> receiptPath = GeneratedColumn<String>(
    'receipt_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receiptLocalFileMeta = const VerificationMeta(
    'receiptLocalFile',
  );
  @override
  late final GeneratedColumn<String> receiptLocalFile = GeneratedColumn<String>(
    'receipt_local_file',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteUpdatedAt,
    pending,
    accountId,
    categoryId,
    payeeId,
    type,
    transferDirection,
    transferGroupId,
    amount,
    occurredAtMs,
    merchant,
    note,
    plannedStatus,
    receiptPath,
    receiptLocalFile,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('remote_updated_at')) {
      context.handle(
        _remoteUpdatedAtMeta,
        remoteUpdatedAt.isAcceptableOrUnknown(
          data['remote_updated_at']!,
          _remoteUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('pending')) {
      context.handle(
        _pendingMeta,
        pending.isAcceptableOrUnknown(data['pending']!, _pendingMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('payee_id')) {
      context.handle(
        _payeeIdMeta,
        payeeId.isAcceptableOrUnknown(data['payee_id']!, _payeeIdMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('transfer_direction')) {
      context.handle(
        _transferDirectionMeta,
        transferDirection.isAcceptableOrUnknown(
          data['transfer_direction']!,
          _transferDirectionMeta,
        ),
      );
    }
    if (data.containsKey('transfer_group_id')) {
      context.handle(
        _transferGroupIdMeta,
        transferGroupId.isAcceptableOrUnknown(
          data['transfer_group_id']!,
          _transferGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('occurred_at_ms')) {
      context.handle(
        _occurredAtMsMeta,
        occurredAtMs.isAcceptableOrUnknown(
          data['occurred_at_ms']!,
          _occurredAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMsMeta);
    }
    if (data.containsKey('merchant')) {
      context.handle(
        _merchantMeta,
        merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('planned_status')) {
      context.handle(
        _plannedStatusMeta,
        plannedStatus.isAcceptableOrUnknown(
          data['planned_status']!,
          _plannedStatusMeta,
        ),
      );
    }
    if (data.containsKey('receipt_path')) {
      context.handle(
        _receiptPathMeta,
        receiptPath.isAcceptableOrUnknown(
          data['receipt_path']!,
          _receiptPathMeta,
        ),
      );
    }
    if (data.containsKey('receipt_local_file')) {
      context.handle(
        _receiptLocalFileMeta,
        receiptLocalFile.isAcceptableOrUnknown(
          data['receipt_local_file']!,
          _receiptLocalFileMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      remoteUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_updated_at'],
      ),
      pending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      payeeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payee_id'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      transferDirection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transfer_direction'],
      ),
      transferGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transfer_group_id'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      occurredAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at_ms'],
      )!,
      merchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      plannedStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}planned_status'],
      )!,
      receiptPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_path'],
      ),
      receiptLocalFile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_local_file'],
      ),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class TransactionRow extends DataClass implements Insertable<TransactionRow> {
  final String id;
  final String? remoteUpdatedAt;
  final bool pending;
  final String accountId;
  final String? categoryId;
  final String? payeeId;
  final String type;
  final String? transferDirection;
  final String? transferGroupId;
  final int amount;
  final int occurredAtMs;
  final String? merchant;
  final String? note;
  final String plannedStatus;
  final String? receiptPath;
  final String? receiptLocalFile;
  const TransactionRow({
    required this.id,
    this.remoteUpdatedAt,
    required this.pending,
    required this.accountId,
    this.categoryId,
    this.payeeId,
    required this.type,
    this.transferDirection,
    this.transferGroupId,
    required this.amount,
    required this.occurredAtMs,
    this.merchant,
    this.note,
    required this.plannedStatus,
    this.receiptPath,
    this.receiptLocalFile,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || remoteUpdatedAt != null) {
      map['remote_updated_at'] = Variable<String>(remoteUpdatedAt);
    }
    map['pending'] = Variable<bool>(pending);
    map['account_id'] = Variable<String>(accountId);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || payeeId != null) {
      map['payee_id'] = Variable<String>(payeeId);
    }
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || transferDirection != null) {
      map['transfer_direction'] = Variable<String>(transferDirection);
    }
    if (!nullToAbsent || transferGroupId != null) {
      map['transfer_group_id'] = Variable<String>(transferGroupId);
    }
    map['amount'] = Variable<int>(amount);
    map['occurred_at_ms'] = Variable<int>(occurredAtMs);
    if (!nullToAbsent || merchant != null) {
      map['merchant'] = Variable<String>(merchant);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['planned_status'] = Variable<String>(plannedStatus);
    if (!nullToAbsent || receiptPath != null) {
      map['receipt_path'] = Variable<String>(receiptPath);
    }
    if (!nullToAbsent || receiptLocalFile != null) {
      map['receipt_local_file'] = Variable<String>(receiptLocalFile);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      remoteUpdatedAt: remoteUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteUpdatedAt),
      pending: Value(pending),
      accountId: Value(accountId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      payeeId: payeeId == null && nullToAbsent
          ? const Value.absent()
          : Value(payeeId),
      type: Value(type),
      transferDirection: transferDirection == null && nullToAbsent
          ? const Value.absent()
          : Value(transferDirection),
      transferGroupId: transferGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(transferGroupId),
      amount: Value(amount),
      occurredAtMs: Value(occurredAtMs),
      merchant: merchant == null && nullToAbsent
          ? const Value.absent()
          : Value(merchant),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      plannedStatus: Value(plannedStatus),
      receiptPath: receiptPath == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptPath),
      receiptLocalFile: receiptLocalFile == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptLocalFile),
    );
  }

  factory TransactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionRow(
      id: serializer.fromJson<String>(json['id']),
      remoteUpdatedAt: serializer.fromJson<String?>(json['remoteUpdatedAt']),
      pending: serializer.fromJson<bool>(json['pending']),
      accountId: serializer.fromJson<String>(json['accountId']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      payeeId: serializer.fromJson<String?>(json['payeeId']),
      type: serializer.fromJson<String>(json['type']),
      transferDirection: serializer.fromJson<String?>(
        json['transferDirection'],
      ),
      transferGroupId: serializer.fromJson<String?>(json['transferGroupId']),
      amount: serializer.fromJson<int>(json['amount']),
      occurredAtMs: serializer.fromJson<int>(json['occurredAtMs']),
      merchant: serializer.fromJson<String?>(json['merchant']),
      note: serializer.fromJson<String?>(json['note']),
      plannedStatus: serializer.fromJson<String>(json['plannedStatus']),
      receiptPath: serializer.fromJson<String?>(json['receiptPath']),
      receiptLocalFile: serializer.fromJson<String?>(json['receiptLocalFile']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'remoteUpdatedAt': serializer.toJson<String?>(remoteUpdatedAt),
      'pending': serializer.toJson<bool>(pending),
      'accountId': serializer.toJson<String>(accountId),
      'categoryId': serializer.toJson<String?>(categoryId),
      'payeeId': serializer.toJson<String?>(payeeId),
      'type': serializer.toJson<String>(type),
      'transferDirection': serializer.toJson<String?>(transferDirection),
      'transferGroupId': serializer.toJson<String?>(transferGroupId),
      'amount': serializer.toJson<int>(amount),
      'occurredAtMs': serializer.toJson<int>(occurredAtMs),
      'merchant': serializer.toJson<String?>(merchant),
      'note': serializer.toJson<String?>(note),
      'plannedStatus': serializer.toJson<String>(plannedStatus),
      'receiptPath': serializer.toJson<String?>(receiptPath),
      'receiptLocalFile': serializer.toJson<String?>(receiptLocalFile),
    };
  }

  TransactionRow copyWith({
    String? id,
    Value<String?> remoteUpdatedAt = const Value.absent(),
    bool? pending,
    String? accountId,
    Value<String?> categoryId = const Value.absent(),
    Value<String?> payeeId = const Value.absent(),
    String? type,
    Value<String?> transferDirection = const Value.absent(),
    Value<String?> transferGroupId = const Value.absent(),
    int? amount,
    int? occurredAtMs,
    Value<String?> merchant = const Value.absent(),
    Value<String?> note = const Value.absent(),
    String? plannedStatus,
    Value<String?> receiptPath = const Value.absent(),
    Value<String?> receiptLocalFile = const Value.absent(),
  }) => TransactionRow(
    id: id ?? this.id,
    remoteUpdatedAt: remoteUpdatedAt.present
        ? remoteUpdatedAt.value
        : this.remoteUpdatedAt,
    pending: pending ?? this.pending,
    accountId: accountId ?? this.accountId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    payeeId: payeeId.present ? payeeId.value : this.payeeId,
    type: type ?? this.type,
    transferDirection: transferDirection.present
        ? transferDirection.value
        : this.transferDirection,
    transferGroupId: transferGroupId.present
        ? transferGroupId.value
        : this.transferGroupId,
    amount: amount ?? this.amount,
    occurredAtMs: occurredAtMs ?? this.occurredAtMs,
    merchant: merchant.present ? merchant.value : this.merchant,
    note: note.present ? note.value : this.note,
    plannedStatus: plannedStatus ?? this.plannedStatus,
    receiptPath: receiptPath.present ? receiptPath.value : this.receiptPath,
    receiptLocalFile: receiptLocalFile.present
        ? receiptLocalFile.value
        : this.receiptLocalFile,
  );
  TransactionRow copyWithCompanion(TransactionsCompanion data) {
    return TransactionRow(
      id: data.id.present ? data.id.value : this.id,
      remoteUpdatedAt: data.remoteUpdatedAt.present
          ? data.remoteUpdatedAt.value
          : this.remoteUpdatedAt,
      pending: data.pending.present ? data.pending.value : this.pending,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      payeeId: data.payeeId.present ? data.payeeId.value : this.payeeId,
      type: data.type.present ? data.type.value : this.type,
      transferDirection: data.transferDirection.present
          ? data.transferDirection.value
          : this.transferDirection,
      transferGroupId: data.transferGroupId.present
          ? data.transferGroupId.value
          : this.transferGroupId,
      amount: data.amount.present ? data.amount.value : this.amount,
      occurredAtMs: data.occurredAtMs.present
          ? data.occurredAtMs.value
          : this.occurredAtMs,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      note: data.note.present ? data.note.value : this.note,
      plannedStatus: data.plannedStatus.present
          ? data.plannedStatus.value
          : this.plannedStatus,
      receiptPath: data.receiptPath.present
          ? data.receiptPath.value
          : this.receiptPath,
      receiptLocalFile: data.receiptLocalFile.present
          ? data.receiptLocalFile.value
          : this.receiptLocalFile,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionRow(')
          ..write('id: $id, ')
          ..write('remoteUpdatedAt: $remoteUpdatedAt, ')
          ..write('pending: $pending, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('payeeId: $payeeId, ')
          ..write('type: $type, ')
          ..write('transferDirection: $transferDirection, ')
          ..write('transferGroupId: $transferGroupId, ')
          ..write('amount: $amount, ')
          ..write('occurredAtMs: $occurredAtMs, ')
          ..write('merchant: $merchant, ')
          ..write('note: $note, ')
          ..write('plannedStatus: $plannedStatus, ')
          ..write('receiptPath: $receiptPath, ')
          ..write('receiptLocalFile: $receiptLocalFile')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    remoteUpdatedAt,
    pending,
    accountId,
    categoryId,
    payeeId,
    type,
    transferDirection,
    transferGroupId,
    amount,
    occurredAtMs,
    merchant,
    note,
    plannedStatus,
    receiptPath,
    receiptLocalFile,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionRow &&
          other.id == this.id &&
          other.remoteUpdatedAt == this.remoteUpdatedAt &&
          other.pending == this.pending &&
          other.accountId == this.accountId &&
          other.categoryId == this.categoryId &&
          other.payeeId == this.payeeId &&
          other.type == this.type &&
          other.transferDirection == this.transferDirection &&
          other.transferGroupId == this.transferGroupId &&
          other.amount == this.amount &&
          other.occurredAtMs == this.occurredAtMs &&
          other.merchant == this.merchant &&
          other.note == this.note &&
          other.plannedStatus == this.plannedStatus &&
          other.receiptPath == this.receiptPath &&
          other.receiptLocalFile == this.receiptLocalFile);
}

class TransactionsCompanion extends UpdateCompanion<TransactionRow> {
  final Value<String> id;
  final Value<String?> remoteUpdatedAt;
  final Value<bool> pending;
  final Value<String> accountId;
  final Value<String?> categoryId;
  final Value<String?> payeeId;
  final Value<String> type;
  final Value<String?> transferDirection;
  final Value<String?> transferGroupId;
  final Value<int> amount;
  final Value<int> occurredAtMs;
  final Value<String?> merchant;
  final Value<String?> note;
  final Value<String> plannedStatus;
  final Value<String?> receiptPath;
  final Value<String?> receiptLocalFile;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.remoteUpdatedAt = const Value.absent(),
    this.pending = const Value.absent(),
    this.accountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.payeeId = const Value.absent(),
    this.type = const Value.absent(),
    this.transferDirection = const Value.absent(),
    this.transferGroupId = const Value.absent(),
    this.amount = const Value.absent(),
    this.occurredAtMs = const Value.absent(),
    this.merchant = const Value.absent(),
    this.note = const Value.absent(),
    this.plannedStatus = const Value.absent(),
    this.receiptPath = const Value.absent(),
    this.receiptLocalFile = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    this.remoteUpdatedAt = const Value.absent(),
    this.pending = const Value.absent(),
    required String accountId,
    this.categoryId = const Value.absent(),
    this.payeeId = const Value.absent(),
    required String type,
    this.transferDirection = const Value.absent(),
    this.transferGroupId = const Value.absent(),
    required int amount,
    required int occurredAtMs,
    this.merchant = const Value.absent(),
    this.note = const Value.absent(),
    this.plannedStatus = const Value.absent(),
    this.receiptPath = const Value.absent(),
    this.receiptLocalFile = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       accountId = Value(accountId),
       type = Value(type),
       amount = Value(amount),
       occurredAtMs = Value(occurredAtMs);
  static Insertable<TransactionRow> custom({
    Expression<String>? id,
    Expression<String>? remoteUpdatedAt,
    Expression<bool>? pending,
    Expression<String>? accountId,
    Expression<String>? categoryId,
    Expression<String>? payeeId,
    Expression<String>? type,
    Expression<String>? transferDirection,
    Expression<String>? transferGroupId,
    Expression<int>? amount,
    Expression<int>? occurredAtMs,
    Expression<String>? merchant,
    Expression<String>? note,
    Expression<String>? plannedStatus,
    Expression<String>? receiptPath,
    Expression<String>? receiptLocalFile,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteUpdatedAt != null) 'remote_updated_at': remoteUpdatedAt,
      if (pending != null) 'pending': pending,
      if (accountId != null) 'account_id': accountId,
      if (categoryId != null) 'category_id': categoryId,
      if (payeeId != null) 'payee_id': payeeId,
      if (type != null) 'type': type,
      if (transferDirection != null) 'transfer_direction': transferDirection,
      if (transferGroupId != null) 'transfer_group_id': transferGroupId,
      if (amount != null) 'amount': amount,
      if (occurredAtMs != null) 'occurred_at_ms': occurredAtMs,
      if (merchant != null) 'merchant': merchant,
      if (note != null) 'note': note,
      if (plannedStatus != null) 'planned_status': plannedStatus,
      if (receiptPath != null) 'receipt_path': receiptPath,
      if (receiptLocalFile != null) 'receipt_local_file': receiptLocalFile,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? id,
    Value<String?>? remoteUpdatedAt,
    Value<bool>? pending,
    Value<String>? accountId,
    Value<String?>? categoryId,
    Value<String?>? payeeId,
    Value<String>? type,
    Value<String?>? transferDirection,
    Value<String?>? transferGroupId,
    Value<int>? amount,
    Value<int>? occurredAtMs,
    Value<String?>? merchant,
    Value<String?>? note,
    Value<String>? plannedStatus,
    Value<String?>? receiptPath,
    Value<String?>? receiptLocalFile,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      remoteUpdatedAt: remoteUpdatedAt ?? this.remoteUpdatedAt,
      pending: pending ?? this.pending,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      payeeId: payeeId ?? this.payeeId,
      type: type ?? this.type,
      transferDirection: transferDirection ?? this.transferDirection,
      transferGroupId: transferGroupId ?? this.transferGroupId,
      amount: amount ?? this.amount,
      occurredAtMs: occurredAtMs ?? this.occurredAtMs,
      merchant: merchant ?? this.merchant,
      note: note ?? this.note,
      plannedStatus: plannedStatus ?? this.plannedStatus,
      receiptPath: receiptPath ?? this.receiptPath,
      receiptLocalFile: receiptLocalFile ?? this.receiptLocalFile,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (remoteUpdatedAt.present) {
      map['remote_updated_at'] = Variable<String>(remoteUpdatedAt.value);
    }
    if (pending.present) {
      map['pending'] = Variable<bool>(pending.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (payeeId.present) {
      map['payee_id'] = Variable<String>(payeeId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (transferDirection.present) {
      map['transfer_direction'] = Variable<String>(transferDirection.value);
    }
    if (transferGroupId.present) {
      map['transfer_group_id'] = Variable<String>(transferGroupId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (occurredAtMs.present) {
      map['occurred_at_ms'] = Variable<int>(occurredAtMs.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (plannedStatus.present) {
      map['planned_status'] = Variable<String>(plannedStatus.value);
    }
    if (receiptPath.present) {
      map['receipt_path'] = Variable<String>(receiptPath.value);
    }
    if (receiptLocalFile.present) {
      map['receipt_local_file'] = Variable<String>(receiptLocalFile.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('remoteUpdatedAt: $remoteUpdatedAt, ')
          ..write('pending: $pending, ')
          ..write('accountId: $accountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('payeeId: $payeeId, ')
          ..write('type: $type, ')
          ..write('transferDirection: $transferDirection, ')
          ..write('transferGroupId: $transferGroupId, ')
          ..write('amount: $amount, ')
          ..write('occurredAtMs: $occurredAtMs, ')
          ..write('merchant: $merchant, ')
          ..write('note: $note, ')
          ..write('plannedStatus: $plannedStatus, ')
          ..write('receiptPath: $receiptPath, ')
          ..write('receiptLocalFile: $receiptLocalFile, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReminderPreferencesTable extends ReminderPreferences
    with TableInfo<$ReminderPreferencesTable, ReminderPrefRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteUpdatedAtMeta = const VerificationMeta(
    'remoteUpdatedAt',
  );
  @override
  late final GeneratedColumn<String> remoteUpdatedAt = GeneratedColumn<String>(
    'remote_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingMeta = const VerificationMeta(
    'pending',
  );
  @override
  late final GeneratedColumn<bool> pending = GeneratedColumn<bool>(
    'pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reminderTypeMeta = const VerificationMeta(
    'reminderType',
  );
  @override
  late final GeneratedColumn<String> reminderType = GeneratedColumn<String>(
    'reminder_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _reminderTimeMeta = const VerificationMeta(
    'reminderTime',
  );
  @override
  late final GeneratedColumn<String> reminderTime = GeneratedColumn<String>(
    'reminder_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thresholdPercentMeta = const VerificationMeta(
    'thresholdPercent',
  );
  @override
  late final GeneratedColumn<int> thresholdPercent = GeneratedColumn<int>(
    'threshold_percent',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteUpdatedAt,
    pending,
    reminderType,
    enabled,
    reminderTime,
    thresholdPercent,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderPrefRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('remote_updated_at')) {
      context.handle(
        _remoteUpdatedAtMeta,
        remoteUpdatedAt.isAcceptableOrUnknown(
          data['remote_updated_at']!,
          _remoteUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('pending')) {
      context.handle(
        _pendingMeta,
        pending.isAcceptableOrUnknown(data['pending']!, _pendingMeta),
      );
    }
    if (data.containsKey('reminder_type')) {
      context.handle(
        _reminderTypeMeta,
        reminderType.isAcceptableOrUnknown(
          data['reminder_type']!,
          _reminderTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reminderTypeMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('reminder_time')) {
      context.handle(
        _reminderTimeMeta,
        reminderTime.isAcceptableOrUnknown(
          data['reminder_time']!,
          _reminderTimeMeta,
        ),
      );
    }
    if (data.containsKey('threshold_percent')) {
      context.handle(
        _thresholdPercentMeta,
        thresholdPercent.isAcceptableOrUnknown(
          data['threshold_percent']!,
          _thresholdPercentMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderPrefRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderPrefRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      remoteUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_updated_at'],
      ),
      pending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending'],
      )!,
      reminderType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_type'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      reminderTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_time'],
      ),
      thresholdPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}threshold_percent'],
      ),
    );
  }

  @override
  $ReminderPreferencesTable createAlias(String alias) {
    return $ReminderPreferencesTable(attachedDatabase, alias);
  }
}

class ReminderPrefRow extends DataClass implements Insertable<ReminderPrefRow> {
  final String id;
  final String? remoteUpdatedAt;
  final bool pending;
  final String reminderType;
  final bool enabled;
  final String? reminderTime;
  final int? thresholdPercent;
  const ReminderPrefRow({
    required this.id,
    this.remoteUpdatedAt,
    required this.pending,
    required this.reminderType,
    required this.enabled,
    this.reminderTime,
    this.thresholdPercent,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || remoteUpdatedAt != null) {
      map['remote_updated_at'] = Variable<String>(remoteUpdatedAt);
    }
    map['pending'] = Variable<bool>(pending);
    map['reminder_type'] = Variable<String>(reminderType);
    map['enabled'] = Variable<bool>(enabled);
    if (!nullToAbsent || reminderTime != null) {
      map['reminder_time'] = Variable<String>(reminderTime);
    }
    if (!nullToAbsent || thresholdPercent != null) {
      map['threshold_percent'] = Variable<int>(thresholdPercent);
    }
    return map;
  }

  ReminderPreferencesCompanion toCompanion(bool nullToAbsent) {
    return ReminderPreferencesCompanion(
      id: Value(id),
      remoteUpdatedAt: remoteUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteUpdatedAt),
      pending: Value(pending),
      reminderType: Value(reminderType),
      enabled: Value(enabled),
      reminderTime: reminderTime == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderTime),
      thresholdPercent: thresholdPercent == null && nullToAbsent
          ? const Value.absent()
          : Value(thresholdPercent),
    );
  }

  factory ReminderPrefRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderPrefRow(
      id: serializer.fromJson<String>(json['id']),
      remoteUpdatedAt: serializer.fromJson<String?>(json['remoteUpdatedAt']),
      pending: serializer.fromJson<bool>(json['pending']),
      reminderType: serializer.fromJson<String>(json['reminderType']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      reminderTime: serializer.fromJson<String?>(json['reminderTime']),
      thresholdPercent: serializer.fromJson<int?>(json['thresholdPercent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'remoteUpdatedAt': serializer.toJson<String?>(remoteUpdatedAt),
      'pending': serializer.toJson<bool>(pending),
      'reminderType': serializer.toJson<String>(reminderType),
      'enabled': serializer.toJson<bool>(enabled),
      'reminderTime': serializer.toJson<String?>(reminderTime),
      'thresholdPercent': serializer.toJson<int?>(thresholdPercent),
    };
  }

  ReminderPrefRow copyWith({
    String? id,
    Value<String?> remoteUpdatedAt = const Value.absent(),
    bool? pending,
    String? reminderType,
    bool? enabled,
    Value<String?> reminderTime = const Value.absent(),
    Value<int?> thresholdPercent = const Value.absent(),
  }) => ReminderPrefRow(
    id: id ?? this.id,
    remoteUpdatedAt: remoteUpdatedAt.present
        ? remoteUpdatedAt.value
        : this.remoteUpdatedAt,
    pending: pending ?? this.pending,
    reminderType: reminderType ?? this.reminderType,
    enabled: enabled ?? this.enabled,
    reminderTime: reminderTime.present ? reminderTime.value : this.reminderTime,
    thresholdPercent: thresholdPercent.present
        ? thresholdPercent.value
        : this.thresholdPercent,
  );
  ReminderPrefRow copyWithCompanion(ReminderPreferencesCompanion data) {
    return ReminderPrefRow(
      id: data.id.present ? data.id.value : this.id,
      remoteUpdatedAt: data.remoteUpdatedAt.present
          ? data.remoteUpdatedAt.value
          : this.remoteUpdatedAt,
      pending: data.pending.present ? data.pending.value : this.pending,
      reminderType: data.reminderType.present
          ? data.reminderType.value
          : this.reminderType,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      reminderTime: data.reminderTime.present
          ? data.reminderTime.value
          : this.reminderTime,
      thresholdPercent: data.thresholdPercent.present
          ? data.thresholdPercent.value
          : this.thresholdPercent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderPrefRow(')
          ..write('id: $id, ')
          ..write('remoteUpdatedAt: $remoteUpdatedAt, ')
          ..write('pending: $pending, ')
          ..write('reminderType: $reminderType, ')
          ..write('enabled: $enabled, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('thresholdPercent: $thresholdPercent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    remoteUpdatedAt,
    pending,
    reminderType,
    enabled,
    reminderTime,
    thresholdPercent,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderPrefRow &&
          other.id == this.id &&
          other.remoteUpdatedAt == this.remoteUpdatedAt &&
          other.pending == this.pending &&
          other.reminderType == this.reminderType &&
          other.enabled == this.enabled &&
          other.reminderTime == this.reminderTime &&
          other.thresholdPercent == this.thresholdPercent);
}

class ReminderPreferencesCompanion extends UpdateCompanion<ReminderPrefRow> {
  final Value<String> id;
  final Value<String?> remoteUpdatedAt;
  final Value<bool> pending;
  final Value<String> reminderType;
  final Value<bool> enabled;
  final Value<String?> reminderTime;
  final Value<int?> thresholdPercent;
  final Value<int> rowid;
  const ReminderPreferencesCompanion({
    this.id = const Value.absent(),
    this.remoteUpdatedAt = const Value.absent(),
    this.pending = const Value.absent(),
    this.reminderType = const Value.absent(),
    this.enabled = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.thresholdPercent = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReminderPreferencesCompanion.insert({
    required String id,
    this.remoteUpdatedAt = const Value.absent(),
    this.pending = const Value.absent(),
    required String reminderType,
    this.enabled = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.thresholdPercent = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       reminderType = Value(reminderType);
  static Insertable<ReminderPrefRow> custom({
    Expression<String>? id,
    Expression<String>? remoteUpdatedAt,
    Expression<bool>? pending,
    Expression<String>? reminderType,
    Expression<bool>? enabled,
    Expression<String>? reminderTime,
    Expression<int>? thresholdPercent,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteUpdatedAt != null) 'remote_updated_at': remoteUpdatedAt,
      if (pending != null) 'pending': pending,
      if (reminderType != null) 'reminder_type': reminderType,
      if (enabled != null) 'enabled': enabled,
      if (reminderTime != null) 'reminder_time': reminderTime,
      if (thresholdPercent != null) 'threshold_percent': thresholdPercent,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReminderPreferencesCompanion copyWith({
    Value<String>? id,
    Value<String?>? remoteUpdatedAt,
    Value<bool>? pending,
    Value<String>? reminderType,
    Value<bool>? enabled,
    Value<String?>? reminderTime,
    Value<int?>? thresholdPercent,
    Value<int>? rowid,
  }) {
    return ReminderPreferencesCompanion(
      id: id ?? this.id,
      remoteUpdatedAt: remoteUpdatedAt ?? this.remoteUpdatedAt,
      pending: pending ?? this.pending,
      reminderType: reminderType ?? this.reminderType,
      enabled: enabled ?? this.enabled,
      reminderTime: reminderTime ?? this.reminderTime,
      thresholdPercent: thresholdPercent ?? this.thresholdPercent,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (remoteUpdatedAt.present) {
      map['remote_updated_at'] = Variable<String>(remoteUpdatedAt.value);
    }
    if (pending.present) {
      map['pending'] = Variable<bool>(pending.value);
    }
    if (reminderType.present) {
      map['reminder_type'] = Variable<String>(reminderType.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (reminderTime.present) {
      map['reminder_time'] = Variable<String>(reminderTime.value);
    }
    if (thresholdPercent.present) {
      map['threshold_percent'] = Variable<int>(thresholdPercent.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderPreferencesCompanion(')
          ..write('id: $id, ')
          ..write('remoteUpdatedAt: $remoteUpdatedAt, ')
          ..write('pending: $pending, ')
          ..write('reminderType: $reminderType, ')
          ..write('enabled: $enabled, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('thresholdPercent: $thresholdPercent, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfilesTable extends Profiles
    with TableInfo<$ProfilesTable, ProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteUpdatedAtMeta = const VerificationMeta(
    'remoteUpdatedAt',
  );
  @override
  late final GeneratedColumn<String> remoteUpdatedAt = GeneratedColumn<String>(
    'remote_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingMeta = const VerificationMeta(
    'pending',
  );
  @override
  late final GeneratedColumn<bool> pending = GeneratedColumn<bool>(
    'pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('BDT'),
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
    defaultValue: const Constant('Asia/Dhaka'),
  );
  static const VerificationMeta _preferencesJsonMeta = const VerificationMeta(
    'preferencesJson',
  );
  @override
  late final GeneratedColumn<String> preferencesJson = GeneratedColumn<String>(
    'preferences_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    remoteUpdatedAt,
    pending,
    displayName,
    currency,
    timezone,
    preferencesJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('remote_updated_at')) {
      context.handle(
        _remoteUpdatedAtMeta,
        remoteUpdatedAt.isAcceptableOrUnknown(
          data['remote_updated_at']!,
          _remoteUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('pending')) {
      context.handle(
        _pendingMeta,
        pending.isAcceptableOrUnknown(data['pending']!, _pendingMeta),
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
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    }
    if (data.containsKey('preferences_json')) {
      context.handle(
        _preferencesJsonMeta,
        preferencesJson.isAcceptableOrUnknown(
          data['preferences_json']!,
          _preferencesJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      remoteUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_updated_at'],
      ),
      pending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      preferencesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferences_json'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class ProfileRow extends DataClass implements Insertable<ProfileRow> {
  final String id;
  final String? remoteUpdatedAt;
  final bool pending;
  final String? displayName;
  final String currency;
  final String timezone;
  final String preferencesJson;
  const ProfileRow({
    required this.id,
    this.remoteUpdatedAt,
    required this.pending,
    this.displayName,
    required this.currency,
    required this.timezone,
    required this.preferencesJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || remoteUpdatedAt != null) {
      map['remote_updated_at'] = Variable<String>(remoteUpdatedAt);
    }
    map['pending'] = Variable<bool>(pending);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    map['currency'] = Variable<String>(currency);
    map['timezone'] = Variable<String>(timezone);
    map['preferences_json'] = Variable<String>(preferencesJson);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      remoteUpdatedAt: remoteUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteUpdatedAt),
      pending: Value(pending),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      currency: Value(currency),
      timezone: Value(timezone),
      preferencesJson: Value(preferencesJson),
    );
  }

  factory ProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileRow(
      id: serializer.fromJson<String>(json['id']),
      remoteUpdatedAt: serializer.fromJson<String?>(json['remoteUpdatedAt']),
      pending: serializer.fromJson<bool>(json['pending']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      currency: serializer.fromJson<String>(json['currency']),
      timezone: serializer.fromJson<String>(json['timezone']),
      preferencesJson: serializer.fromJson<String>(json['preferencesJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'remoteUpdatedAt': serializer.toJson<String?>(remoteUpdatedAt),
      'pending': serializer.toJson<bool>(pending),
      'displayName': serializer.toJson<String?>(displayName),
      'currency': serializer.toJson<String>(currency),
      'timezone': serializer.toJson<String>(timezone),
      'preferencesJson': serializer.toJson<String>(preferencesJson),
    };
  }

  ProfileRow copyWith({
    String? id,
    Value<String?> remoteUpdatedAt = const Value.absent(),
    bool? pending,
    Value<String?> displayName = const Value.absent(),
    String? currency,
    String? timezone,
    String? preferencesJson,
  }) => ProfileRow(
    id: id ?? this.id,
    remoteUpdatedAt: remoteUpdatedAt.present
        ? remoteUpdatedAt.value
        : this.remoteUpdatedAt,
    pending: pending ?? this.pending,
    displayName: displayName.present ? displayName.value : this.displayName,
    currency: currency ?? this.currency,
    timezone: timezone ?? this.timezone,
    preferencesJson: preferencesJson ?? this.preferencesJson,
  );
  ProfileRow copyWithCompanion(ProfilesCompanion data) {
    return ProfileRow(
      id: data.id.present ? data.id.value : this.id,
      remoteUpdatedAt: data.remoteUpdatedAt.present
          ? data.remoteUpdatedAt.value
          : this.remoteUpdatedAt,
      pending: data.pending.present ? data.pending.value : this.pending,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      currency: data.currency.present ? data.currency.value : this.currency,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      preferencesJson: data.preferencesJson.present
          ? data.preferencesJson.value
          : this.preferencesJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRow(')
          ..write('id: $id, ')
          ..write('remoteUpdatedAt: $remoteUpdatedAt, ')
          ..write('pending: $pending, ')
          ..write('displayName: $displayName, ')
          ..write('currency: $currency, ')
          ..write('timezone: $timezone, ')
          ..write('preferencesJson: $preferencesJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    remoteUpdatedAt,
    pending,
    displayName,
    currency,
    timezone,
    preferencesJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileRow &&
          other.id == this.id &&
          other.remoteUpdatedAt == this.remoteUpdatedAt &&
          other.pending == this.pending &&
          other.displayName == this.displayName &&
          other.currency == this.currency &&
          other.timezone == this.timezone &&
          other.preferencesJson == this.preferencesJson);
}

class ProfilesCompanion extends UpdateCompanion<ProfileRow> {
  final Value<String> id;
  final Value<String?> remoteUpdatedAt;
  final Value<bool> pending;
  final Value<String?> displayName;
  final Value<String> currency;
  final Value<String> timezone;
  final Value<String> preferencesJson;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.remoteUpdatedAt = const Value.absent(),
    this.pending = const Value.absent(),
    this.displayName = const Value.absent(),
    this.currency = const Value.absent(),
    this.timezone = const Value.absent(),
    this.preferencesJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required String id,
    this.remoteUpdatedAt = const Value.absent(),
    this.pending = const Value.absent(),
    this.displayName = const Value.absent(),
    this.currency = const Value.absent(),
    this.timezone = const Value.absent(),
    this.preferencesJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<ProfileRow> custom({
    Expression<String>? id,
    Expression<String>? remoteUpdatedAt,
    Expression<bool>? pending,
    Expression<String>? displayName,
    Expression<String>? currency,
    Expression<String>? timezone,
    Expression<String>? preferencesJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteUpdatedAt != null) 'remote_updated_at': remoteUpdatedAt,
      if (pending != null) 'pending': pending,
      if (displayName != null) 'display_name': displayName,
      if (currency != null) 'currency': currency,
      if (timezone != null) 'timezone': timezone,
      if (preferencesJson != null) 'preferences_json': preferencesJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith({
    Value<String>? id,
    Value<String?>? remoteUpdatedAt,
    Value<bool>? pending,
    Value<String?>? displayName,
    Value<String>? currency,
    Value<String>? timezone,
    Value<String>? preferencesJson,
    Value<int>? rowid,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      remoteUpdatedAt: remoteUpdatedAt ?? this.remoteUpdatedAt,
      pending: pending ?? this.pending,
      displayName: displayName ?? this.displayName,
      currency: currency ?? this.currency,
      timezone: timezone ?? this.timezone,
      preferencesJson: preferencesJson ?? this.preferencesJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (remoteUpdatedAt.present) {
      map['remote_updated_at'] = Variable<String>(remoteUpdatedAt.value);
    }
    if (pending.present) {
      map['pending'] = Variable<bool>(pending.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (preferencesJson.present) {
      map['preferences_json'] = Variable<String>(preferencesJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('remoteUpdatedAt: $remoteUpdatedAt, ')
          ..write('pending: $pending, ')
          ..write('displayName: $displayName, ')
          ..write('currency: $currency, ')
          ..write('timezone: $timezone, ')
          ..write('preferencesJson: $preferencesJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxRow> {
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
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opMeta = const VerificationMeta('op');
  @override
  late final GeneratedColumn<String> op = GeneratedColumn<String>(
    'op',
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
  static const VerificationMeta _baseUpdatedAtMeta = const VerificationMeta(
    'baseUpdatedAt',
  );
  @override
  late final GeneratedColumn<String> baseUpdatedAt = GeneratedColumn<String>(
    'base_updated_at',
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
  static const VerificationMeta _nextAttemptAtMsMeta = const VerificationMeta(
    'nextAttemptAtMs',
  );
  @override
  late final GeneratedColumn<int> nextAttemptAtMs = GeneratedColumn<int>(
    'next_attempt_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
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
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    seq,
    entity,
    entityId,
    op,
    payload,
    baseUpdatedAt,
    attempts,
    nextAttemptAtMs,
    status,
    lastError,
    createdAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxRow> instance, {
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
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('op')) {
      context.handle(_opMeta, op.isAcceptableOrUnknown(data['op']!, _opMeta));
    } else if (isInserting) {
      context.missing(_opMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('base_updated_at')) {
      context.handle(
        _baseUpdatedAtMeta,
        baseUpdatedAt.isAcceptableOrUnknown(
          data['base_updated_at']!,
          _baseUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('next_attempt_at_ms')) {
      context.handle(
        _nextAttemptAtMsMeta,
        nextAttemptAtMs.isAcceptableOrUnknown(
          data['next_attempt_at_ms']!,
          _nextAttemptAtMsMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  OutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxRow(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      op: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      baseUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_updated_at'],
      ),
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      nextAttemptAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_attempt_at_ms'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }
}

class OutboxRow extends DataClass implements Insertable<OutboxRow> {
  final int seq;
  final String entity;
  final String entityId;
  final String op;
  final String payload;
  final String? baseUpdatedAt;
  final int attempts;
  final int nextAttemptAtMs;
  final String status;
  final String? lastError;
  final int createdAtMs;
  const OutboxRow({
    required this.seq,
    required this.entity,
    required this.entityId,
    required this.op,
    required this.payload,
    this.baseUpdatedAt,
    required this.attempts,
    required this.nextAttemptAtMs,
    required this.status,
    this.lastError,
    required this.createdAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    map['op'] = Variable<String>(op);
    map['payload'] = Variable<String>(payload);
    if (!nullToAbsent || baseUpdatedAt != null) {
      map['base_updated_at'] = Variable<String>(baseUpdatedAt);
    }
    map['attempts'] = Variable<int>(attempts);
    map['next_attempt_at_ms'] = Variable<int>(nextAttemptAtMs);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at_ms'] = Variable<int>(createdAtMs);
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      seq: Value(seq),
      entity: Value(entity),
      entityId: Value(entityId),
      op: Value(op),
      payload: Value(payload),
      baseUpdatedAt: baseUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(baseUpdatedAt),
      attempts: Value(attempts),
      nextAttemptAtMs: Value(nextAttemptAtMs),
      status: Value(status),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAtMs: Value(createdAtMs),
    );
  }

  factory OutboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxRow(
      seq: serializer.fromJson<int>(json['seq']),
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entityId']),
      op: serializer.fromJson<String>(json['op']),
      payload: serializer.fromJson<String>(json['payload']),
      baseUpdatedAt: serializer.fromJson<String?>(json['baseUpdatedAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextAttemptAtMs: serializer.fromJson<int>(json['nextAttemptAtMs']),
      status: serializer.fromJson<String>(json['status']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String>(entityId),
      'op': serializer.toJson<String>(op),
      'payload': serializer.toJson<String>(payload),
      'baseUpdatedAt': serializer.toJson<String?>(baseUpdatedAt),
      'attempts': serializer.toJson<int>(attempts),
      'nextAttemptAtMs': serializer.toJson<int>(nextAttemptAtMs),
      'status': serializer.toJson<String>(status),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
    };
  }

  OutboxRow copyWith({
    int? seq,
    String? entity,
    String? entityId,
    String? op,
    String? payload,
    Value<String?> baseUpdatedAt = const Value.absent(),
    int? attempts,
    int? nextAttemptAtMs,
    String? status,
    Value<String?> lastError = const Value.absent(),
    int? createdAtMs,
  }) => OutboxRow(
    seq: seq ?? this.seq,
    entity: entity ?? this.entity,
    entityId: entityId ?? this.entityId,
    op: op ?? this.op,
    payload: payload ?? this.payload,
    baseUpdatedAt: baseUpdatedAt.present
        ? baseUpdatedAt.value
        : this.baseUpdatedAt,
    attempts: attempts ?? this.attempts,
    nextAttemptAtMs: nextAttemptAtMs ?? this.nextAttemptAtMs,
    status: status ?? this.status,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAtMs: createdAtMs ?? this.createdAtMs,
  );
  OutboxRow copyWithCompanion(OutboxCompanion data) {
    return OutboxRow(
      seq: data.seq.present ? data.seq.value : this.seq,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      op: data.op.present ? data.op.value : this.op,
      payload: data.payload.present ? data.payload.value : this.payload,
      baseUpdatedAt: data.baseUpdatedAt.present
          ? data.baseUpdatedAt.value
          : this.baseUpdatedAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextAttemptAtMs: data.nextAttemptAtMs.present
          ? data.nextAttemptAtMs.value
          : this.nextAttemptAtMs,
      status: data.status.present ? data.status.value : this.status,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRow(')
          ..write('seq: $seq, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('op: $op, ')
          ..write('payload: $payload, ')
          ..write('baseUpdatedAt: $baseUpdatedAt, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAtMs: $nextAttemptAtMs, ')
          ..write('status: $status, ')
          ..write('lastError: $lastError, ')
          ..write('createdAtMs: $createdAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    seq,
    entity,
    entityId,
    op,
    payload,
    baseUpdatedAt,
    attempts,
    nextAttemptAtMs,
    status,
    lastError,
    createdAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxRow &&
          other.seq == this.seq &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.op == this.op &&
          other.payload == this.payload &&
          other.baseUpdatedAt == this.baseUpdatedAt &&
          other.attempts == this.attempts &&
          other.nextAttemptAtMs == this.nextAttemptAtMs &&
          other.status == this.status &&
          other.lastError == this.lastError &&
          other.createdAtMs == this.createdAtMs);
}

class OutboxCompanion extends UpdateCompanion<OutboxRow> {
  final Value<int> seq;
  final Value<String> entity;
  final Value<String> entityId;
  final Value<String> op;
  final Value<String> payload;
  final Value<String?> baseUpdatedAt;
  final Value<int> attempts;
  final Value<int> nextAttemptAtMs;
  final Value<String> status;
  final Value<String?> lastError;
  final Value<int> createdAtMs;
  const OutboxCompanion({
    this.seq = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.op = const Value.absent(),
    this.payload = const Value.absent(),
    this.baseUpdatedAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAtMs = const Value.absent(),
    this.status = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAtMs = const Value.absent(),
  });
  OutboxCompanion.insert({
    this.seq = const Value.absent(),
    required String entity,
    required String entityId,
    required String op,
    required String payload,
    this.baseUpdatedAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAtMs = const Value.absent(),
    this.status = const Value.absent(),
    this.lastError = const Value.absent(),
    required int createdAtMs,
  }) : entity = Value(entity),
       entityId = Value(entityId),
       op = Value(op),
       payload = Value(payload),
       createdAtMs = Value(createdAtMs);
  static Insertable<OutboxRow> custom({
    Expression<int>? seq,
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? op,
    Expression<String>? payload,
    Expression<String>? baseUpdatedAt,
    Expression<int>? attempts,
    Expression<int>? nextAttemptAtMs,
    Expression<String>? status,
    Expression<String>? lastError,
    Expression<int>? createdAtMs,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (op != null) 'op': op,
      if (payload != null) 'payload': payload,
      if (baseUpdatedAt != null) 'base_updated_at': baseUpdatedAt,
      if (attempts != null) 'attempts': attempts,
      if (nextAttemptAtMs != null) 'next_attempt_at_ms': nextAttemptAtMs,
      if (status != null) 'status': status,
      if (lastError != null) 'last_error': lastError,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
    });
  }

  OutboxCompanion copyWith({
    Value<int>? seq,
    Value<String>? entity,
    Value<String>? entityId,
    Value<String>? op,
    Value<String>? payload,
    Value<String?>? baseUpdatedAt,
    Value<int>? attempts,
    Value<int>? nextAttemptAtMs,
    Value<String>? status,
    Value<String?>? lastError,
    Value<int>? createdAtMs,
  }) {
    return OutboxCompanion(
      seq: seq ?? this.seq,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      op: op ?? this.op,
      payload: payload ?? this.payload,
      baseUpdatedAt: baseUpdatedAt ?? this.baseUpdatedAt,
      attempts: attempts ?? this.attempts,
      nextAttemptAtMs: nextAttemptAtMs ?? this.nextAttemptAtMs,
      status: status ?? this.status,
      lastError: lastError ?? this.lastError,
      createdAtMs: createdAtMs ?? this.createdAtMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (op.present) {
      map['op'] = Variable<String>(op.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (baseUpdatedAt.present) {
      map['base_updated_at'] = Variable<String>(baseUpdatedAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextAttemptAtMs.present) {
      map['next_attempt_at_ms'] = Variable<int>(nextAttemptAtMs.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('seq: $seq, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('op: $op, ')
          ..write('payload: $payload, ')
          ..write('baseUpdatedAt: $baseUpdatedAt, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAtMs: $nextAttemptAtMs, ')
          ..write('status: $status, ')
          ..write('lastError: $lastError, ')
          ..write('createdAtMs: $createdAtMs')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTable extends SyncCursors
    with TableInfo<$SyncCursorsTable, SyncCursorRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastIdMeta = const VerificationMeta('lastId');
  @override
  late final GeneratedColumn<String> lastId = GeneratedColumn<String>(
    'last_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSuccessMsMeta = const VerificationMeta(
    'lastSuccessMs',
  );
  @override
  late final GeneratedColumn<int> lastSuccessMs = GeneratedColumn<int>(
    'last_success_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    entity,
    updatedAt,
    lastId,
    lastSuccessMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncCursorRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('last_id')) {
      context.handle(
        _lastIdMeta,
        lastId.isAcceptableOrUnknown(data['last_id']!, _lastIdMeta),
      );
    }
    if (data.containsKey('last_success_ms')) {
      context.handle(
        _lastSuccessMsMeta,
        lastSuccessMs.isAcceptableOrUnknown(
          data['last_success_ms']!,
          _lastSuccessMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entity};
  @override
  SyncCursorRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursorRow(
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
      lastId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_id'],
      ),
      lastSuccessMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_success_ms'],
      ),
    );
  }

  @override
  $SyncCursorsTable createAlias(String alias) {
    return $SyncCursorsTable(attachedDatabase, alias);
  }
}

class SyncCursorRow extends DataClass implements Insertable<SyncCursorRow> {
  final String entity;
  final String? updatedAt;
  final String? lastId;
  final int? lastSuccessMs;
  const SyncCursorRow({
    required this.entity,
    this.updatedAt,
    this.lastId,
    this.lastSuccessMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity'] = Variable<String>(entity);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    if (!nullToAbsent || lastId != null) {
      map['last_id'] = Variable<String>(lastId);
    }
    if (!nullToAbsent || lastSuccessMs != null) {
      map['last_success_ms'] = Variable<int>(lastSuccessMs);
    }
    return map;
  }

  SyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsCompanion(
      entity: Value(entity),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      lastId: lastId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastId),
      lastSuccessMs: lastSuccessMs == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSuccessMs),
    );
  }

  factory SyncCursorRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursorRow(
      entity: serializer.fromJson<String>(json['entity']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
      lastId: serializer.fromJson<String?>(json['lastId']),
      lastSuccessMs: serializer.fromJson<int?>(json['lastSuccessMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entity': serializer.toJson<String>(entity),
      'updatedAt': serializer.toJson<String?>(updatedAt),
      'lastId': serializer.toJson<String?>(lastId),
      'lastSuccessMs': serializer.toJson<int?>(lastSuccessMs),
    };
  }

  SyncCursorRow copyWith({
    String? entity,
    Value<String?> updatedAt = const Value.absent(),
    Value<String?> lastId = const Value.absent(),
    Value<int?> lastSuccessMs = const Value.absent(),
  }) => SyncCursorRow(
    entity: entity ?? this.entity,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    lastId: lastId.present ? lastId.value : this.lastId,
    lastSuccessMs: lastSuccessMs.present
        ? lastSuccessMs.value
        : this.lastSuccessMs,
  );
  SyncCursorRow copyWithCompanion(SyncCursorsCompanion data) {
    return SyncCursorRow(
      entity: data.entity.present ? data.entity.value : this.entity,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastId: data.lastId.present ? data.lastId.value : this.lastId,
      lastSuccessMs: data.lastSuccessMs.present
          ? data.lastSuccessMs.value
          : this.lastSuccessMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorRow(')
          ..write('entity: $entity, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastId: $lastId, ')
          ..write('lastSuccessMs: $lastSuccessMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entity, updatedAt, lastId, lastSuccessMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursorRow &&
          other.entity == this.entity &&
          other.updatedAt == this.updatedAt &&
          other.lastId == this.lastId &&
          other.lastSuccessMs == this.lastSuccessMs);
}

class SyncCursorsCompanion extends UpdateCompanion<SyncCursorRow> {
  final Value<String> entity;
  final Value<String?> updatedAt;
  final Value<String?> lastId;
  final Value<int?> lastSuccessMs;
  final Value<int> rowid;
  const SyncCursorsCompanion({
    this.entity = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastId = const Value.absent(),
    this.lastSuccessMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorsCompanion.insert({
    required String entity,
    this.updatedAt = const Value.absent(),
    this.lastId = const Value.absent(),
    this.lastSuccessMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : entity = Value(entity);
  static Insertable<SyncCursorRow> custom({
    Expression<String>? entity,
    Expression<String>? updatedAt,
    Expression<String>? lastId,
    Expression<int>? lastSuccessMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entity != null) 'entity': entity,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastId != null) 'last_id': lastId,
      if (lastSuccessMs != null) 'last_success_ms': lastSuccessMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorsCompanion copyWith({
    Value<String>? entity,
    Value<String?>? updatedAt,
    Value<String?>? lastId,
    Value<int?>? lastSuccessMs,
    Value<int>? rowid,
  }) {
    return SyncCursorsCompanion(
      entity: entity ?? this.entity,
      updatedAt: updatedAt ?? this.updatedAt,
      lastId: lastId ?? this.lastId,
      lastSuccessMs: lastSuccessMs ?? this.lastSuccessMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (lastId.present) {
      map['last_id'] = Variable<String>(lastId.value);
    }
    if (lastSuccessMs.present) {
      map['last_success_ms'] = Variable<int>(lastSuccessMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsCompanion(')
          ..write('entity: $entity, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastId: $lastId, ')
          ..write('lastSuccessMs: $lastSuccessMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConflictLogTable extends ConflictLog
    with TableInfo<$ConflictLogTable, ConflictLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConflictLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverVersionJsonMeta = const VerificationMeta(
    'serverVersionJson',
  );
  @override
  late final GeneratedColumn<String> serverVersionJson =
      GeneratedColumn<String>(
        'server_version_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _resolutionMeta = const VerificationMeta(
    'resolution',
  );
  @override
  late final GeneratedColumn<String> resolution = GeneratedColumn<String>(
    'resolution',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMsMeta = const VerificationMeta('atMs');
  @override
  late final GeneratedColumn<int> atMs = GeneratedColumn<int>(
    'at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entity,
    entityId,
    serverVersionJson,
    resolution,
    atMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conflict_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConflictLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('server_version_json')) {
      context.handle(
        _serverVersionJsonMeta,
        serverVersionJson.isAcceptableOrUnknown(
          data['server_version_json']!,
          _serverVersionJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serverVersionJsonMeta);
    }
    if (data.containsKey('resolution')) {
      context.handle(
        _resolutionMeta,
        resolution.isAcceptableOrUnknown(data['resolution']!, _resolutionMeta),
      );
    } else if (isInserting) {
      context.missing(_resolutionMeta);
    }
    if (data.containsKey('at_ms')) {
      context.handle(
        _atMsMeta,
        atMs.isAcceptableOrUnknown(data['at_ms']!, _atMsMeta),
      );
    } else if (isInserting) {
      context.missing(_atMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConflictLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConflictLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      serverVersionJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_version_json'],
      )!,
      resolution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution'],
      )!,
      atMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at_ms'],
      )!,
    );
  }

  @override
  $ConflictLogTable createAlias(String alias) {
    return $ConflictLogTable(attachedDatabase, alias);
  }
}

class ConflictLogRow extends DataClass implements Insertable<ConflictLogRow> {
  final int id;
  final String entity;
  final String entityId;
  final String serverVersionJson;
  final String resolution;
  final int atMs;
  const ConflictLogRow({
    required this.id,
    required this.entity,
    required this.entityId,
    required this.serverVersionJson,
    required this.resolution,
    required this.atMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    map['server_version_json'] = Variable<String>(serverVersionJson);
    map['resolution'] = Variable<String>(resolution);
    map['at_ms'] = Variable<int>(atMs);
    return map;
  }

  ConflictLogCompanion toCompanion(bool nullToAbsent) {
    return ConflictLogCompanion(
      id: Value(id),
      entity: Value(entity),
      entityId: Value(entityId),
      serverVersionJson: Value(serverVersionJson),
      resolution: Value(resolution),
      atMs: Value(atMs),
    );
  }

  factory ConflictLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConflictLogRow(
      id: serializer.fromJson<int>(json['id']),
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entityId']),
      serverVersionJson: serializer.fromJson<String>(json['serverVersionJson']),
      resolution: serializer.fromJson<String>(json['resolution']),
      atMs: serializer.fromJson<int>(json['atMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String>(entityId),
      'serverVersionJson': serializer.toJson<String>(serverVersionJson),
      'resolution': serializer.toJson<String>(resolution),
      'atMs': serializer.toJson<int>(atMs),
    };
  }

  ConflictLogRow copyWith({
    int? id,
    String? entity,
    String? entityId,
    String? serverVersionJson,
    String? resolution,
    int? atMs,
  }) => ConflictLogRow(
    id: id ?? this.id,
    entity: entity ?? this.entity,
    entityId: entityId ?? this.entityId,
    serverVersionJson: serverVersionJson ?? this.serverVersionJson,
    resolution: resolution ?? this.resolution,
    atMs: atMs ?? this.atMs,
  );
  ConflictLogRow copyWithCompanion(ConflictLogCompanion data) {
    return ConflictLogRow(
      id: data.id.present ? data.id.value : this.id,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      serverVersionJson: data.serverVersionJson.present
          ? data.serverVersionJson.value
          : this.serverVersionJson,
      resolution: data.resolution.present
          ? data.resolution.value
          : this.resolution,
      atMs: data.atMs.present ? data.atMs.value : this.atMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConflictLogRow(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('serverVersionJson: $serverVersionJson, ')
          ..write('resolution: $resolution, ')
          ..write('atMs: $atMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, entity, entityId, serverVersionJson, resolution, atMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConflictLogRow &&
          other.id == this.id &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.serverVersionJson == this.serverVersionJson &&
          other.resolution == this.resolution &&
          other.atMs == this.atMs);
}

class ConflictLogCompanion extends UpdateCompanion<ConflictLogRow> {
  final Value<int> id;
  final Value<String> entity;
  final Value<String> entityId;
  final Value<String> serverVersionJson;
  final Value<String> resolution;
  final Value<int> atMs;
  const ConflictLogCompanion({
    this.id = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.serverVersionJson = const Value.absent(),
    this.resolution = const Value.absent(),
    this.atMs = const Value.absent(),
  });
  ConflictLogCompanion.insert({
    this.id = const Value.absent(),
    required String entity,
    required String entityId,
    required String serverVersionJson,
    required String resolution,
    required int atMs,
  }) : entity = Value(entity),
       entityId = Value(entityId),
       serverVersionJson = Value(serverVersionJson),
       resolution = Value(resolution),
       atMs = Value(atMs);
  static Insertable<ConflictLogRow> custom({
    Expression<int>? id,
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? serverVersionJson,
    Expression<String>? resolution,
    Expression<int>? atMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (serverVersionJson != null) 'server_version_json': serverVersionJson,
      if (resolution != null) 'resolution': resolution,
      if (atMs != null) 'at_ms': atMs,
    });
  }

  ConflictLogCompanion copyWith({
    Value<int>? id,
    Value<String>? entity,
    Value<String>? entityId,
    Value<String>? serverVersionJson,
    Value<String>? resolution,
    Value<int>? atMs,
  }) {
    return ConflictLogCompanion(
      id: id ?? this.id,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      serverVersionJson: serverVersionJson ?? this.serverVersionJson,
      resolution: resolution ?? this.resolution,
      atMs: atMs ?? this.atMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (serverVersionJson.present) {
      map['server_version_json'] = Variable<String>(serverVersionJson.value);
    }
    if (resolution.present) {
      map['resolution'] = Variable<String>(resolution.value);
    }
    if (atMs.present) {
      map['at_ms'] = Variable<int>(atMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConflictLogCompanion(')
          ..write('id: $id, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('serverVersionJson: $serverVersionJson, ')
          ..write('resolution: $resolution, ')
          ..write('atMs: $atMs')
          ..write(')'))
        .toString();
  }
}

class $LocalKvTable extends LocalKv with TableInfo<$LocalKvTable, KvRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalKvTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_kv';
  @override
  VerificationContext validateIntegrity(
    Insertable<KvRow> instance, {
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
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  KvRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KvRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $LocalKvTable createAlias(String alias) {
    return $LocalKvTable(attachedDatabase, alias);
  }
}

class KvRow extends DataClass implements Insertable<KvRow> {
  final String key;
  final String value;
  const KvRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  LocalKvCompanion toCompanion(bool nullToAbsent) {
    return LocalKvCompanion(key: Value(key), value: Value(value));
  }

  factory KvRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KvRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  KvRow copyWith({String? key, String? value}) =>
      KvRow(key: key ?? this.key, value: value ?? this.value);
  KvRow copyWithCompanion(LocalKvCompanion data) {
    return KvRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KvRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KvRow && other.key == this.key && other.value == this.value);
}

class LocalKvCompanion extends UpdateCompanion<KvRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const LocalKvCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalKvCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<KvRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalKvCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return LocalKvCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalKvCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $PayeesTable payees = $PayeesTable(this);
  late final $DailyBudgetsTable dailyBudgets = $DailyBudgetsTable(this);
  late final $BudgetAllocationsTable budgetAllocations =
      $BudgetAllocationsTable(this);
  late final $BudgetTemplatesTable budgetTemplates = $BudgetTemplatesTable(
    this,
  );
  late final $PlannedExpensesTable plannedExpenses = $PlannedExpensesTable(
    this,
  );
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $ReminderPreferencesTable reminderPreferences =
      $ReminderPreferencesTable(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $SyncCursorsTable syncCursors = $SyncCursorsTable(this);
  late final $ConflictLogTable conflictLog = $ConflictLogTable(this);
  late final $LocalKvTable localKv = $LocalKvTable(this);
  late final Index dailyBudgetsDateIdx = Index(
    'daily_budgets_date_idx',
    'CREATE UNIQUE INDEX daily_budgets_date_idx ON daily_budgets (budget_date)',
  );
  late final Index txOccurredIdx = Index(
    'tx_occurred_idx',
    'CREATE INDEX tx_occurred_idx ON transactions (occurred_at_ms)',
  );
  late final Index txAccountIdx = Index(
    'tx_account_idx',
    'CREATE INDEX tx_account_idx ON transactions (account_id)',
  );
  late final Index txCategoryIdx = Index(
    'tx_category_idx',
    'CREATE INDEX tx_category_idx ON transactions (category_id)',
  );
  late final Index txPayeeIdx = Index(
    'tx_payee_idx',
    'CREATE INDEX tx_payee_idx ON transactions (payee_id)',
  );
  late final Index txTypeIdx = Index(
    'tx_type_idx',
    'CREATE INDEX tx_type_idx ON transactions (type)',
  );
  late final Index outboxStatusIdx = Index(
    'outbox_status_idx',
    'CREATE INDEX outbox_status_idx ON outbox (status, next_attempt_at_ms, seq)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accounts,
    categories,
    payees,
    dailyBudgets,
    budgetAllocations,
    budgetTemplates,
    plannedExpenses,
    transactions,
    reminderPreferences,
    profiles,
    outbox,
    syncCursors,
    conflictLog,
    localKv,
    dailyBudgetsDateIdx,
    txOccurredIdx,
    txAccountIdx,
    txCategoryIdx,
    txPayeeIdx,
    txTypeIdx,
    outboxStatusIdx,
  ];
}

typedef $$AccountsTableCreateCompanionBuilder =
    AccountsCompanion Function({
      required String id,
      Value<String?> remoteUpdatedAt,
      Value<bool> pending,
      required String name,
      required String type,
      Value<int> openingBalance,
      Value<bool> isArchived,
      Value<int> rowid,
    });
typedef $$AccountsTableUpdateCompanionBuilder =
    AccountsCompanion Function({
      Value<String> id,
      Value<String?> remoteUpdatedAt,
      Value<bool> pending,
      Value<String> name,
      Value<String> type,
      Value<int> openingBalance,
      Value<bool> isArchived,
      Value<int> rowid,
    });

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
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

  ColumnFilters<String> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
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

  ColumnOrderings<String> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pending =>
      $composableBuilder(column: $table.pending, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          AccountRow,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (
            AccountRow,
            BaseReferences<_$AppDatabase, $AccountsTable, AccountRow>,
          ),
          AccountRow,
          PrefetchHooks Function()
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> remoteUpdatedAt = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> openingBalance = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                remoteUpdatedAt: remoteUpdatedAt,
                pending: pending,
                name: name,
                type: type,
                openingBalance: openingBalance,
                isArchived: isArchived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> remoteUpdatedAt = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                required String name,
                required String type,
                Value<int> openingBalance = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                remoteUpdatedAt: remoteUpdatedAt,
                pending: pending,
                name: name,
                type: type,
                openingBalance: openingBalance,
                isArchived: isArchived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      AccountRow,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (AccountRow, BaseReferences<_$AppDatabase, $AccountsTable, AccountRow>),
      AccountRow,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      Value<String?> remoteUpdatedAt,
      Value<bool> pending,
      required String name,
      Value<String?> icon,
      Value<String?> color,
      required String type,
      Value<bool> isDefault,
      Value<bool> isArchived,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String?> remoteUpdatedAt,
      Value<bool> pending,
      Value<String> name,
      Value<String?> icon,
      Value<String?> color,
      Value<String> type,
      Value<bool> isDefault,
      Value<bool> isArchived,
      Value<int> rowid,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
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

  ColumnFilters<String> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pending =>
      $composableBuilder(column: $table.pending, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (
            CategoryRow,
            BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>,
          ),
          CategoryRow,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> remoteUpdatedAt = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                remoteUpdatedAt: remoteUpdatedAt,
                pending: pending,
                name: name,
                icon: icon,
                color: color,
                type: type,
                isDefault: isDefault,
                isArchived: isArchived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> remoteUpdatedAt = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                required String name,
                Value<String?> icon = const Value.absent(),
                Value<String?> color = const Value.absent(),
                required String type,
                Value<bool> isDefault = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                remoteUpdatedAt: remoteUpdatedAt,
                pending: pending,
                name: name,
                icon: icon,
                color: color,
                type: type,
                isDefault: isDefault,
                isArchived: isArchived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (
        CategoryRow,
        BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>,
      ),
      CategoryRow,
      PrefetchHooks Function()
    >;
typedef $$PayeesTableCreateCompanionBuilder =
    PayeesCompanion Function({
      required String id,
      Value<String?> remoteUpdatedAt,
      Value<bool> pending,
      required String name,
      Value<bool> isArchived,
      Value<int> rowid,
    });
typedef $$PayeesTableUpdateCompanionBuilder =
    PayeesCompanion Function({
      Value<String> id,
      Value<String?> remoteUpdatedAt,
      Value<bool> pending,
      Value<String> name,
      Value<bool> isArchived,
      Value<int> rowid,
    });

class $$PayeesTableFilterComposer
    extends Composer<_$AppDatabase, $PayeesTable> {
  $$PayeesTableFilterComposer({
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

  ColumnFilters<String> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PayeesTableOrderingComposer
    extends Composer<_$AppDatabase, $PayeesTable> {
  $$PayeesTableOrderingComposer({
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

  ColumnOrderings<String> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PayeesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PayeesTable> {
  $$PayeesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pending =>
      $composableBuilder(column: $table.pending, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );
}

class $$PayeesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PayeesTable,
          PayeeRow,
          $$PayeesTableFilterComposer,
          $$PayeesTableOrderingComposer,
          $$PayeesTableAnnotationComposer,
          $$PayeesTableCreateCompanionBuilder,
          $$PayeesTableUpdateCompanionBuilder,
          (PayeeRow, BaseReferences<_$AppDatabase, $PayeesTable, PayeeRow>),
          PayeeRow,
          PrefetchHooks Function()
        > {
  $$PayeesTableTableManager(_$AppDatabase db, $PayeesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PayeesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PayeesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PayeesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> remoteUpdatedAt = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PayeesCompanion(
                id: id,
                remoteUpdatedAt: remoteUpdatedAt,
                pending: pending,
                name: name,
                isArchived: isArchived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> remoteUpdatedAt = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                required String name,
                Value<bool> isArchived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PayeesCompanion.insert(
                id: id,
                remoteUpdatedAt: remoteUpdatedAt,
                pending: pending,
                name: name,
                isArchived: isArchived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PayeesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PayeesTable,
      PayeeRow,
      $$PayeesTableFilterComposer,
      $$PayeesTableOrderingComposer,
      $$PayeesTableAnnotationComposer,
      $$PayeesTableCreateCompanionBuilder,
      $$PayeesTableUpdateCompanionBuilder,
      (PayeeRow, BaseReferences<_$AppDatabase, $PayeesTable, PayeeRow>),
      PayeeRow,
      PrefetchHooks Function()
    >;
typedef $$DailyBudgetsTableCreateCompanionBuilder =
    DailyBudgetsCompanion Function({
      required String id,
      Value<String?> remoteUpdatedAt,
      Value<bool> pending,
      required String budgetDate,
      required int totalLimit,
      required int originalLimit,
      Value<String?> notes,
      Value<bool> isClosed,
      Value<String?> closedAt,
      Value<int> rowid,
    });
typedef $$DailyBudgetsTableUpdateCompanionBuilder =
    DailyBudgetsCompanion Function({
      Value<String> id,
      Value<String?> remoteUpdatedAt,
      Value<bool> pending,
      Value<String> budgetDate,
      Value<int> totalLimit,
      Value<int> originalLimit,
      Value<String?> notes,
      Value<bool> isClosed,
      Value<String?> closedAt,
      Value<int> rowid,
    });

class $$DailyBudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyBudgetsTable> {
  $$DailyBudgetsTableFilterComposer({
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

  ColumnFilters<String> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get budgetDate => $composableBuilder(
    column: $table.budgetDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalLimit => $composableBuilder(
    column: $table.totalLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originalLimit => $composableBuilder(
    column: $table.originalLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isClosed => $composableBuilder(
    column: $table.isClosed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyBudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyBudgetsTable> {
  $$DailyBudgetsTableOrderingComposer({
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

  ColumnOrderings<String> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get budgetDate => $composableBuilder(
    column: $table.budgetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalLimit => $composableBuilder(
    column: $table.totalLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originalLimit => $composableBuilder(
    column: $table.originalLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isClosed => $composableBuilder(
    column: $table.isClosed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyBudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyBudgetsTable> {
  $$DailyBudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pending =>
      $composableBuilder(column: $table.pending, builder: (column) => column);

  GeneratedColumn<String> get budgetDate => $composableBuilder(
    column: $table.budgetDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalLimit => $composableBuilder(
    column: $table.totalLimit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get originalLimit => $composableBuilder(
    column: $table.originalLimit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isClosed =>
      $composableBuilder(column: $table.isClosed, builder: (column) => column);

  GeneratedColumn<String> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);
}

class $$DailyBudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyBudgetsTable,
          DailyBudgetRow,
          $$DailyBudgetsTableFilterComposer,
          $$DailyBudgetsTableOrderingComposer,
          $$DailyBudgetsTableAnnotationComposer,
          $$DailyBudgetsTableCreateCompanionBuilder,
          $$DailyBudgetsTableUpdateCompanionBuilder,
          (
            DailyBudgetRow,
            BaseReferences<_$AppDatabase, $DailyBudgetsTable, DailyBudgetRow>,
          ),
          DailyBudgetRow,
          PrefetchHooks Function()
        > {
  $$DailyBudgetsTableTableManager(_$AppDatabase db, $DailyBudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyBudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyBudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyBudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> remoteUpdatedAt = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<String> budgetDate = const Value.absent(),
                Value<int> totalLimit = const Value.absent(),
                Value<int> originalLimit = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isClosed = const Value.absent(),
                Value<String?> closedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyBudgetsCompanion(
                id: id,
                remoteUpdatedAt: remoteUpdatedAt,
                pending: pending,
                budgetDate: budgetDate,
                totalLimit: totalLimit,
                originalLimit: originalLimit,
                notes: notes,
                isClosed: isClosed,
                closedAt: closedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> remoteUpdatedAt = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                required String budgetDate,
                required int totalLimit,
                required int originalLimit,
                Value<String?> notes = const Value.absent(),
                Value<bool> isClosed = const Value.absent(),
                Value<String?> closedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyBudgetsCompanion.insert(
                id: id,
                remoteUpdatedAt: remoteUpdatedAt,
                pending: pending,
                budgetDate: budgetDate,
                totalLimit: totalLimit,
                originalLimit: originalLimit,
                notes: notes,
                isClosed: isClosed,
                closedAt: closedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyBudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyBudgetsTable,
      DailyBudgetRow,
      $$DailyBudgetsTableFilterComposer,
      $$DailyBudgetsTableOrderingComposer,
      $$DailyBudgetsTableAnnotationComposer,
      $$DailyBudgetsTableCreateCompanionBuilder,
      $$DailyBudgetsTableUpdateCompanionBuilder,
      (
        DailyBudgetRow,
        BaseReferences<_$AppDatabase, $DailyBudgetsTable, DailyBudgetRow>,
      ),
      DailyBudgetRow,
      PrefetchHooks Function()
    >;
typedef $$BudgetAllocationsTableCreateCompanionBuilder =
    BudgetAllocationsCompanion Function({
      required String id,
      Value<String?> remoteUpdatedAt,
      Value<bool> pending,
      required String dailyBudgetId,
      required String categoryId,
      required int plannedAmount,
      required int originalAmount,
      Value<int> rowid,
    });
typedef $$BudgetAllocationsTableUpdateCompanionBuilder =
    BudgetAllocationsCompanion Function({
      Value<String> id,
      Value<String?> remoteUpdatedAt,
      Value<bool> pending,
      Value<String> dailyBudgetId,
      Value<String> categoryId,
      Value<int> plannedAmount,
      Value<int> originalAmount,
      Value<int> rowid,
    });

class $$BudgetAllocationsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetAllocationsTable> {
  $$BudgetAllocationsTableFilterComposer({
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

  ColumnFilters<String> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dailyBudgetId => $composableBuilder(
    column: $table.dailyBudgetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedAmount => $composableBuilder(
    column: $table.plannedAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originalAmount => $composableBuilder(
    column: $table.originalAmount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetAllocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetAllocationsTable> {
  $$BudgetAllocationsTableOrderingComposer({
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

  ColumnOrderings<String> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dailyBudgetId => $composableBuilder(
    column: $table.dailyBudgetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedAmount => $composableBuilder(
    column: $table.plannedAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originalAmount => $composableBuilder(
    column: $table.originalAmount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetAllocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetAllocationsTable> {
  $$BudgetAllocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pending =>
      $composableBuilder(column: $table.pending, builder: (column) => column);

  GeneratedColumn<String> get dailyBudgetId => $composableBuilder(
    column: $table.dailyBudgetId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedAmount => $composableBuilder(
    column: $table.plannedAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get originalAmount => $composableBuilder(
    column: $table.originalAmount,
    builder: (column) => column,
  );
}

class $$BudgetAllocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetAllocationsTable,
          BudgetAllocationRow,
          $$BudgetAllocationsTableFilterComposer,
          $$BudgetAllocationsTableOrderingComposer,
          $$BudgetAllocationsTableAnnotationComposer,
          $$BudgetAllocationsTableCreateCompanionBuilder,
          $$BudgetAllocationsTableUpdateCompanionBuilder,
          (
            BudgetAllocationRow,
            BaseReferences<
              _$AppDatabase,
              $BudgetAllocationsTable,
              BudgetAllocationRow
            >,
          ),
          BudgetAllocationRow,
          PrefetchHooks Function()
        > {
  $$BudgetAllocationsTableTableManager(
    _$AppDatabase db,
    $BudgetAllocationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetAllocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetAllocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetAllocationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> remoteUpdatedAt = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<String> dailyBudgetId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> plannedAmount = const Value.absent(),
                Value<int> originalAmount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetAllocationsCompanion(
                id: id,
                remoteUpdatedAt: remoteUpdatedAt,
                pending: pending,
                dailyBudgetId: dailyBudgetId,
                categoryId: categoryId,
                plannedAmount: plannedAmount,
                originalAmount: originalAmount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> remoteUpdatedAt = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                required String dailyBudgetId,
                required String categoryId,
                required int plannedAmount,
                required int originalAmount,
                Value<int> rowid = const Value.absent(),
              }) => BudgetAllocationsCompanion.insert(
                id: id,
                remoteUpdatedAt: remoteUpdatedAt,
                pending: pending,
                dailyBudgetId: dailyBudgetId,
                categoryId: categoryId,
                plannedAmount: plannedAmount,
                originalAmount: originalAmount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetAllocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetAllocationsTable,
      BudgetAllocationRow,
      $$BudgetAllocationsTableFilterComposer,
      $$BudgetAllocationsTableOrderingComposer,
      $$BudgetAllocationsTableAnnotationComposer,
      $$BudgetAllocationsTableCreateCompanionBuilder,
      $$BudgetAllocationsTableUpdateCompanionBuilder,
      (
        BudgetAllocationRow,
        BaseReferences<
          _$AppDatabase,
          $BudgetAllocationsTable,
          BudgetAllocationRow
        >,
      ),
      BudgetAllocationRow,
      PrefetchHooks Function()
    >;
typedef $$BudgetTemplatesTableCreateCompanionBuilder =
    BudgetTemplatesCompanion Function({
      required String id,
      Value<String?> remoteUpdatedAt,
      Value<bool> pending,
      required int totalLimit,
      Value<String> allocationsJson,
      Value<int> rowid,
    });
typedef $$BudgetTemplatesTableUpdateCompanionBuilder =
    BudgetTemplatesCompanion Function({
      Value<String> id,
      Value<String?> remoteUpdatedAt,
      Value<bool> pending,
      Value<int> totalLimit,
      Value<String> allocationsJson,
      Value<int> rowid,
    });

class $$BudgetTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetTemplatesTable> {
  $$BudgetTemplatesTableFilterComposer({
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

  ColumnFilters<String> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalLimit => $composableBuilder(
    column: $table.totalLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get allocationsJson => $composableBuilder(
    column: $table.allocationsJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetTemplatesTable> {
  $$BudgetTemplatesTableOrderingComposer({
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

  ColumnOrderings<String> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalLimit => $composableBuilder(
    column: $table.totalLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allocationsJson => $composableBuilder(
    column: $table.allocationsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetTemplatesTable> {
  $$BudgetTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pending =>
      $composableBuilder(column: $table.pending, builder: (column) => column);

  GeneratedColumn<int> get totalLimit => $composableBuilder(
    column: $table.totalLimit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get allocationsJson => $composableBuilder(
    column: $table.allocationsJson,
    builder: (column) => column,
  );
}

class $$BudgetTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetTemplatesTable,
          BudgetTemplateRow,
          $$BudgetTemplatesTableFilterComposer,
          $$BudgetTemplatesTableOrderingComposer,
          $$BudgetTemplatesTableAnnotationComposer,
          $$BudgetTemplatesTableCreateCompanionBuilder,
          $$BudgetTemplatesTableUpdateCompanionBuilder,
          (
            BudgetTemplateRow,
            BaseReferences<
              _$AppDatabase,
              $BudgetTemplatesTable,
              BudgetTemplateRow
            >,
          ),
          BudgetTemplateRow,
          PrefetchHooks Function()
        > {
  $$BudgetTemplatesTableTableManager(
    _$AppDatabase db,
    $BudgetTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> remoteUpdatedAt = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<int> totalLimit = const Value.absent(),
                Value<String> allocationsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetTemplatesCompanion(
                id: id,
                remoteUpdatedAt: remoteUpdatedAt,
                pending: pending,
                totalLimit: totalLimit,
                allocationsJson: allocationsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> remoteUpdatedAt = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                required int totalLimit,
                Value<String> allocationsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetTemplatesCompanion.insert(
                id: id,
                remoteUpdatedAt: remoteUpdatedAt,
                pending: pending,
                totalLimit: totalLimit,
                allocationsJson: allocationsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetTemplatesTable,
      BudgetTemplateRow,
      $$BudgetTemplatesTableFilterComposer,
      $$BudgetTemplatesTableOrderingComposer,
      $$BudgetTemplatesTableAnnotationComposer,
      $$BudgetTemplatesTableCreateCompanionBuilder,
      $$BudgetTemplatesTableUpdateCompanionBuilder,
      (
        BudgetTemplateRow,
        BaseReferences<_$AppDatabase, $BudgetTemplatesTable, BudgetTemplateRow>,
      ),
      BudgetTemplateRow,
      PrefetchHooks Function()
    >;
typedef $$PlannedExpensesTableCreateCompanionBuilder =
    PlannedExpensesCompanion Function({
      required String id,
      Value<String?> remoteUpdatedAt,
      Value<bool> pending,
      required String plannedDate,
      required String categoryId,
      required String title,
      required int expectedAmount,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$PlannedExpensesTableUpdateCompanionBuilder =
    PlannedExpensesCompanion Function({
      Value<String> id,
      Value<String?> remoteUpdatedAt,
      Value<bool> pending,
      Value<String> plannedDate,
      Value<String> categoryId,
      Value<String> title,
      Value<int> expectedAmount,
      Value<String> status,
      Value<int> rowid,
    });

class $$PlannedExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $PlannedExpensesTable> {
  $$PlannedExpensesTableFilterComposer({
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

  ColumnFilters<String> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plannedDate => $composableBuilder(
    column: $table.plannedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedAmount => $composableBuilder(
    column: $table.expectedAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlannedExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlannedExpensesTable> {
  $$PlannedExpensesTableOrderingComposer({
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

  ColumnOrderings<String> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plannedDate => $composableBuilder(
    column: $table.plannedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedAmount => $composableBuilder(
    column: $table.expectedAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlannedExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlannedExpensesTable> {
  $$PlannedExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pending =>
      $composableBuilder(column: $table.pending, builder: (column) => column);

  GeneratedColumn<String> get plannedDate => $composableBuilder(
    column: $table.plannedDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get expectedAmount => $composableBuilder(
    column: $table.expectedAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$PlannedExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlannedExpensesTable,
          PlannedExpenseRow,
          $$PlannedExpensesTableFilterComposer,
          $$PlannedExpensesTableOrderingComposer,
          $$PlannedExpensesTableAnnotationComposer,
          $$PlannedExpensesTableCreateCompanionBuilder,
          $$PlannedExpensesTableUpdateCompanionBuilder,
          (
            PlannedExpenseRow,
            BaseReferences<
              _$AppDatabase,
              $PlannedExpensesTable,
              PlannedExpenseRow
            >,
          ),
          PlannedExpenseRow,
          PrefetchHooks Function()
        > {
  $$PlannedExpensesTableTableManager(
    _$AppDatabase db,
    $PlannedExpensesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlannedExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlannedExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlannedExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> remoteUpdatedAt = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<String> plannedDate = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> expectedAmount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlannedExpensesCompanion(
                id: id,
                remoteUpdatedAt: remoteUpdatedAt,
                pending: pending,
                plannedDate: plannedDate,
                categoryId: categoryId,
                title: title,
                expectedAmount: expectedAmount,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> remoteUpdatedAt = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                required String plannedDate,
                required String categoryId,
                required String title,
                required int expectedAmount,
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlannedExpensesCompanion.insert(
                id: id,
                remoteUpdatedAt: remoteUpdatedAt,
                pending: pending,
                plannedDate: plannedDate,
                categoryId: categoryId,
                title: title,
                expectedAmount: expectedAmount,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlannedExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlannedExpensesTable,
      PlannedExpenseRow,
      $$PlannedExpensesTableFilterComposer,
      $$PlannedExpensesTableOrderingComposer,
      $$PlannedExpensesTableAnnotationComposer,
      $$PlannedExpensesTableCreateCompanionBuilder,
      $$PlannedExpensesTableUpdateCompanionBuilder,
      (
        PlannedExpenseRow,
        BaseReferences<_$AppDatabase, $PlannedExpensesTable, PlannedExpenseRow>,
      ),
      PlannedExpenseRow,
      PrefetchHooks Function()
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String id,
      Value<String?> remoteUpdatedAt,
      Value<bool> pending,
      required String accountId,
      Value<String?> categoryId,
      Value<String?> payeeId,
      required String type,
      Value<String?> transferDirection,
      Value<String?> transferGroupId,
      required int amount,
      required int occurredAtMs,
      Value<String?> merchant,
      Value<String?> note,
      Value<String> plannedStatus,
      Value<String?> receiptPath,
      Value<String?> receiptLocalFile,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<String?> remoteUpdatedAt,
      Value<bool> pending,
      Value<String> accountId,
      Value<String?> categoryId,
      Value<String?> payeeId,
      Value<String> type,
      Value<String?> transferDirection,
      Value<String?> transferGroupId,
      Value<int> amount,
      Value<int> occurredAtMs,
      Value<String?> merchant,
      Value<String?> note,
      Value<String> plannedStatus,
      Value<String?> receiptPath,
      Value<String?> receiptLocalFile,
      Value<int> rowid,
    });

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
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

  ColumnFilters<String> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payeeId => $composableBuilder(
    column: $table.payeeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transferDirection => $composableBuilder(
    column: $table.transferDirection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transferGroupId => $composableBuilder(
    column: $table.transferGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurredAtMs => $composableBuilder(
    column: $table.occurredAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plannedStatus => $composableBuilder(
    column: $table.plannedStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptPath => $composableBuilder(
    column: $table.receiptPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptLocalFile => $composableBuilder(
    column: $table.receiptLocalFile,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
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

  ColumnOrderings<String> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payeeId => $composableBuilder(
    column: $table.payeeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transferDirection => $composableBuilder(
    column: $table.transferDirection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transferGroupId => $composableBuilder(
    column: $table.transferGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurredAtMs => $composableBuilder(
    column: $table.occurredAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plannedStatus => $composableBuilder(
    column: $table.plannedStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptPath => $composableBuilder(
    column: $table.receiptPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptLocalFile => $composableBuilder(
    column: $table.receiptLocalFile,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pending =>
      $composableBuilder(column: $table.pending, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payeeId =>
      $composableBuilder(column: $table.payeeId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get transferDirection => $composableBuilder(
    column: $table.transferDirection,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transferGroupId => $composableBuilder(
    column: $table.transferGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get occurredAtMs => $composableBuilder(
    column: $table.occurredAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get plannedStatus => $composableBuilder(
    column: $table.plannedStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receiptPath => $composableBuilder(
    column: $table.receiptPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receiptLocalFile => $composableBuilder(
    column: $table.receiptLocalFile,
    builder: (column) => column,
  );
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          TransactionRow,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (
            TransactionRow,
            BaseReferences<_$AppDatabase, $TransactionsTable, TransactionRow>,
          ),
          TransactionRow,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> remoteUpdatedAt = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> payeeId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> transferDirection = const Value.absent(),
                Value<String?> transferGroupId = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<int> occurredAtMs = const Value.absent(),
                Value<String?> merchant = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> plannedStatus = const Value.absent(),
                Value<String?> receiptPath = const Value.absent(),
                Value<String?> receiptLocalFile = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                remoteUpdatedAt: remoteUpdatedAt,
                pending: pending,
                accountId: accountId,
                categoryId: categoryId,
                payeeId: payeeId,
                type: type,
                transferDirection: transferDirection,
                transferGroupId: transferGroupId,
                amount: amount,
                occurredAtMs: occurredAtMs,
                merchant: merchant,
                note: note,
                plannedStatus: plannedStatus,
                receiptPath: receiptPath,
                receiptLocalFile: receiptLocalFile,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> remoteUpdatedAt = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                required String accountId,
                Value<String?> categoryId = const Value.absent(),
                Value<String?> payeeId = const Value.absent(),
                required String type,
                Value<String?> transferDirection = const Value.absent(),
                Value<String?> transferGroupId = const Value.absent(),
                required int amount,
                required int occurredAtMs,
                Value<String?> merchant = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> plannedStatus = const Value.absent(),
                Value<String?> receiptPath = const Value.absent(),
                Value<String?> receiptLocalFile = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                remoteUpdatedAt: remoteUpdatedAt,
                pending: pending,
                accountId: accountId,
                categoryId: categoryId,
                payeeId: payeeId,
                type: type,
                transferDirection: transferDirection,
                transferGroupId: transferGroupId,
                amount: amount,
                occurredAtMs: occurredAtMs,
                merchant: merchant,
                note: note,
                plannedStatus: plannedStatus,
                receiptPath: receiptPath,
                receiptLocalFile: receiptLocalFile,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      TransactionRow,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (
        TransactionRow,
        BaseReferences<_$AppDatabase, $TransactionsTable, TransactionRow>,
      ),
      TransactionRow,
      PrefetchHooks Function()
    >;
typedef $$ReminderPreferencesTableCreateCompanionBuilder =
    ReminderPreferencesCompanion Function({
      required String id,
      Value<String?> remoteUpdatedAt,
      Value<bool> pending,
      required String reminderType,
      Value<bool> enabled,
      Value<String?> reminderTime,
      Value<int?> thresholdPercent,
      Value<int> rowid,
    });
typedef $$ReminderPreferencesTableUpdateCompanionBuilder =
    ReminderPreferencesCompanion Function({
      Value<String> id,
      Value<String?> remoteUpdatedAt,
      Value<bool> pending,
      Value<String> reminderType,
      Value<bool> enabled,
      Value<String?> reminderTime,
      Value<int?> thresholdPercent,
      Value<int> rowid,
    });

class $$ReminderPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $ReminderPreferencesTable> {
  $$ReminderPreferencesTableFilterComposer({
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

  ColumnFilters<String> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderType => $composableBuilder(
    column: $table.reminderType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get thresholdPercent => $composableBuilder(
    column: $table.thresholdPercent,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReminderPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReminderPreferencesTable> {
  $$ReminderPreferencesTableOrderingComposer({
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

  ColumnOrderings<String> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderType => $composableBuilder(
    column: $table.reminderType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get thresholdPercent => $composableBuilder(
    column: $table.thresholdPercent,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReminderPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReminderPreferencesTable> {
  $$ReminderPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pending =>
      $composableBuilder(column: $table.pending, builder: (column) => column);

  GeneratedColumn<String> get reminderType => $composableBuilder(
    column: $table.reminderType,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get thresholdPercent => $composableBuilder(
    column: $table.thresholdPercent,
    builder: (column) => column,
  );
}

class $$ReminderPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReminderPreferencesTable,
          ReminderPrefRow,
          $$ReminderPreferencesTableFilterComposer,
          $$ReminderPreferencesTableOrderingComposer,
          $$ReminderPreferencesTableAnnotationComposer,
          $$ReminderPreferencesTableCreateCompanionBuilder,
          $$ReminderPreferencesTableUpdateCompanionBuilder,
          (
            ReminderPrefRow,
            BaseReferences<
              _$AppDatabase,
              $ReminderPreferencesTable,
              ReminderPrefRow
            >,
          ),
          ReminderPrefRow,
          PrefetchHooks Function()
        > {
  $$ReminderPreferencesTableTableManager(
    _$AppDatabase db,
    $ReminderPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReminderPreferencesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ReminderPreferencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> remoteUpdatedAt = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<String> reminderType = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<String?> reminderTime = const Value.absent(),
                Value<int?> thresholdPercent = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderPreferencesCompanion(
                id: id,
                remoteUpdatedAt: remoteUpdatedAt,
                pending: pending,
                reminderType: reminderType,
                enabled: enabled,
                reminderTime: reminderTime,
                thresholdPercent: thresholdPercent,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> remoteUpdatedAt = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                required String reminderType,
                Value<bool> enabled = const Value.absent(),
                Value<String?> reminderTime = const Value.absent(),
                Value<int?> thresholdPercent = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderPreferencesCompanion.insert(
                id: id,
                remoteUpdatedAt: remoteUpdatedAt,
                pending: pending,
                reminderType: reminderType,
                enabled: enabled,
                reminderTime: reminderTime,
                thresholdPercent: thresholdPercent,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReminderPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReminderPreferencesTable,
      ReminderPrefRow,
      $$ReminderPreferencesTableFilterComposer,
      $$ReminderPreferencesTableOrderingComposer,
      $$ReminderPreferencesTableAnnotationComposer,
      $$ReminderPreferencesTableCreateCompanionBuilder,
      $$ReminderPreferencesTableUpdateCompanionBuilder,
      (
        ReminderPrefRow,
        BaseReferences<
          _$AppDatabase,
          $ReminderPreferencesTable,
          ReminderPrefRow
        >,
      ),
      ReminderPrefRow,
      PrefetchHooks Function()
    >;
typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      required String id,
      Value<String?> remoteUpdatedAt,
      Value<bool> pending,
      Value<String?> displayName,
      Value<String> currency,
      Value<String> timezone,
      Value<String> preferencesJson,
      Value<int> rowid,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<String> id,
      Value<String?> remoteUpdatedAt,
      Value<bool> pending,
      Value<String?> displayName,
      Value<String> currency,
      Value<String> timezone,
      Value<String> preferencesJson,
      Value<int> rowid,
    });

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
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

  ColumnFilters<String> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferencesJson => $composableBuilder(
    column: $table.preferencesJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
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

  ColumnOrderings<String> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferencesJson => $composableBuilder(
    column: $table.preferencesJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteUpdatedAt => $composableBuilder(
    column: $table.remoteUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pending =>
      $composableBuilder(column: $table.pending, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<String> get preferencesJson => $composableBuilder(
    column: $table.preferencesJson,
    builder: (column) => column,
  );
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          ProfileRow,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (
            ProfileRow,
            BaseReferences<_$AppDatabase, $ProfilesTable, ProfileRow>,
          ),
          ProfileRow,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> remoteUpdatedAt = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<String> preferencesJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                remoteUpdatedAt: remoteUpdatedAt,
                pending: pending,
                displayName: displayName,
                currency: currency,
                timezone: timezone,
                preferencesJson: preferencesJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> remoteUpdatedAt = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<String> preferencesJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                remoteUpdatedAt: remoteUpdatedAt,
                pending: pending,
                displayName: displayName,
                currency: currency,
                timezone: timezone,
                preferencesJson: preferencesJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      ProfileRow,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (ProfileRow, BaseReferences<_$AppDatabase, $ProfilesTable, ProfileRow>),
      ProfileRow,
      PrefetchHooks Function()
    >;
typedef $$OutboxTableCreateCompanionBuilder =
    OutboxCompanion Function({
      Value<int> seq,
      required String entity,
      required String entityId,
      required String op,
      required String payload,
      Value<String?> baseUpdatedAt,
      Value<int> attempts,
      Value<int> nextAttemptAtMs,
      Value<String> status,
      Value<String?> lastError,
      required int createdAtMs,
    });
typedef $$OutboxTableUpdateCompanionBuilder =
    OutboxCompanion Function({
      Value<int> seq,
      Value<String> entity,
      Value<String> entityId,
      Value<String> op,
      Value<String> payload,
      Value<String?> baseUpdatedAt,
      Value<int> attempts,
      Value<int> nextAttemptAtMs,
      Value<String> status,
      Value<String?> lastError,
      Value<int> createdAtMs,
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

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseUpdatedAt => $composableBuilder(
    column: $table.baseUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextAttemptAtMs => $composableBuilder(
    column: $table.nextAttemptAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
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

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseUpdatedAt => $composableBuilder(
    column: $table.baseUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextAttemptAtMs => $composableBuilder(
    column: $table.nextAttemptAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
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

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get op =>
      $composableBuilder(column: $table.op, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get baseUpdatedAt => $composableBuilder(
    column: $table.baseUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get nextAttemptAtMs => $composableBuilder(
    column: $table.nextAttemptAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );
}

class $$OutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxTable,
          OutboxRow,
          $$OutboxTableFilterComposer,
          $$OutboxTableOrderingComposer,
          $$OutboxTableAnnotationComposer,
          $$OutboxTableCreateCompanionBuilder,
          $$OutboxTableUpdateCompanionBuilder,
          (OutboxRow, BaseReferences<_$AppDatabase, $OutboxTable, OutboxRow>),
          OutboxRow,
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
                Value<String> entity = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> op = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String?> baseUpdatedAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int> nextAttemptAtMs = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
              }) => OutboxCompanion(
                seq: seq,
                entity: entity,
                entityId: entityId,
                op: op,
                payload: payload,
                baseUpdatedAt: baseUpdatedAt,
                attempts: attempts,
                nextAttemptAtMs: nextAttemptAtMs,
                status: status,
                lastError: lastError,
                createdAtMs: createdAtMs,
              ),
          createCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                required String entity,
                required String entityId,
                required String op,
                required String payload,
                Value<String?> baseUpdatedAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int> nextAttemptAtMs = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required int createdAtMs,
              }) => OutboxCompanion.insert(
                seq: seq,
                entity: entity,
                entityId: entityId,
                op: op,
                payload: payload,
                baseUpdatedAt: baseUpdatedAt,
                attempts: attempts,
                nextAttemptAtMs: nextAttemptAtMs,
                status: status,
                lastError: lastError,
                createdAtMs: createdAtMs,
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
      OutboxRow,
      $$OutboxTableFilterComposer,
      $$OutboxTableOrderingComposer,
      $$OutboxTableAnnotationComposer,
      $$OutboxTableCreateCompanionBuilder,
      $$OutboxTableUpdateCompanionBuilder,
      (OutboxRow, BaseReferences<_$AppDatabase, $OutboxTable, OutboxRow>),
      OutboxRow,
      PrefetchHooks Function()
    >;
typedef $$SyncCursorsTableCreateCompanionBuilder =
    SyncCursorsCompanion Function({
      required String entity,
      Value<String?> updatedAt,
      Value<String?> lastId,
      Value<int?> lastSuccessMs,
      Value<int> rowid,
    });
typedef $$SyncCursorsTableUpdateCompanionBuilder =
    SyncCursorsCompanion Function({
      Value<String> entity,
      Value<String?> updatedAt,
      Value<String?> lastId,
      Value<int?> lastSuccessMs,
      Value<int> rowid,
    });

class $$SyncCursorsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastId => $composableBuilder(
    column: $table.lastId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSuccessMs => $composableBuilder(
    column: $table.lastSuccessMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncCursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastId => $composableBuilder(
    column: $table.lastId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSuccessMs => $composableBuilder(
    column: $table.lastSuccessMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncCursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get lastId =>
      $composableBuilder(column: $table.lastId, builder: (column) => column);

  GeneratedColumn<int> get lastSuccessMs => $composableBuilder(
    column: $table.lastSuccessMs,
    builder: (column) => column,
  );
}

class $$SyncCursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncCursorsTable,
          SyncCursorRow,
          $$SyncCursorsTableFilterComposer,
          $$SyncCursorsTableOrderingComposer,
          $$SyncCursorsTableAnnotationComposer,
          $$SyncCursorsTableCreateCompanionBuilder,
          $$SyncCursorsTableUpdateCompanionBuilder,
          (
            SyncCursorRow,
            BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursorRow>,
          ),
          SyncCursorRow,
          PrefetchHooks Function()
        > {
  $$SyncCursorsTableTableManager(_$AppDatabase db, $SyncCursorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entity = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> lastId = const Value.absent(),
                Value<int?> lastSuccessMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion(
                entity: entity,
                updatedAt: updatedAt,
                lastId: lastId,
                lastSuccessMs: lastSuccessMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entity,
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> lastId = const Value.absent(),
                Value<int?> lastSuccessMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion.insert(
                entity: entity,
                updatedAt: updatedAt,
                lastId: lastId,
                lastSuccessMs: lastSuccessMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncCursorsTable,
      SyncCursorRow,
      $$SyncCursorsTableFilterComposer,
      $$SyncCursorsTableOrderingComposer,
      $$SyncCursorsTableAnnotationComposer,
      $$SyncCursorsTableCreateCompanionBuilder,
      $$SyncCursorsTableUpdateCompanionBuilder,
      (
        SyncCursorRow,
        BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursorRow>,
      ),
      SyncCursorRow,
      PrefetchHooks Function()
    >;
typedef $$ConflictLogTableCreateCompanionBuilder =
    ConflictLogCompanion Function({
      Value<int> id,
      required String entity,
      required String entityId,
      required String serverVersionJson,
      required String resolution,
      required int atMs,
    });
typedef $$ConflictLogTableUpdateCompanionBuilder =
    ConflictLogCompanion Function({
      Value<int> id,
      Value<String> entity,
      Value<String> entityId,
      Value<String> serverVersionJson,
      Value<String> resolution,
      Value<int> atMs,
    });

class $$ConflictLogTableFilterComposer
    extends Composer<_$AppDatabase, $ConflictLogTable> {
  $$ConflictLogTableFilterComposer({
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

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverVersionJson => $composableBuilder(
    column: $table.serverVersionJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get atMs => $composableBuilder(
    column: $table.atMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConflictLogTableOrderingComposer
    extends Composer<_$AppDatabase, $ConflictLogTable> {
  $$ConflictLogTableOrderingComposer({
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

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverVersionJson => $composableBuilder(
    column: $table.serverVersionJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get atMs => $composableBuilder(
    column: $table.atMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConflictLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConflictLogTable> {
  $$ConflictLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get serverVersionJson => $composableBuilder(
    column: $table.serverVersionJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => column,
  );

  GeneratedColumn<int> get atMs =>
      $composableBuilder(column: $table.atMs, builder: (column) => column);
}

class $$ConflictLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConflictLogTable,
          ConflictLogRow,
          $$ConflictLogTableFilterComposer,
          $$ConflictLogTableOrderingComposer,
          $$ConflictLogTableAnnotationComposer,
          $$ConflictLogTableCreateCompanionBuilder,
          $$ConflictLogTableUpdateCompanionBuilder,
          (
            ConflictLogRow,
            BaseReferences<_$AppDatabase, $ConflictLogTable, ConflictLogRow>,
          ),
          ConflictLogRow,
          PrefetchHooks Function()
        > {
  $$ConflictLogTableTableManager(_$AppDatabase db, $ConflictLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConflictLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConflictLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConflictLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> serverVersionJson = const Value.absent(),
                Value<String> resolution = const Value.absent(),
                Value<int> atMs = const Value.absent(),
              }) => ConflictLogCompanion(
                id: id,
                entity: entity,
                entityId: entityId,
                serverVersionJson: serverVersionJson,
                resolution: resolution,
                atMs: atMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entity,
                required String entityId,
                required String serverVersionJson,
                required String resolution,
                required int atMs,
              }) => ConflictLogCompanion.insert(
                id: id,
                entity: entity,
                entityId: entityId,
                serverVersionJson: serverVersionJson,
                resolution: resolution,
                atMs: atMs,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConflictLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConflictLogTable,
      ConflictLogRow,
      $$ConflictLogTableFilterComposer,
      $$ConflictLogTableOrderingComposer,
      $$ConflictLogTableAnnotationComposer,
      $$ConflictLogTableCreateCompanionBuilder,
      $$ConflictLogTableUpdateCompanionBuilder,
      (
        ConflictLogRow,
        BaseReferences<_$AppDatabase, $ConflictLogTable, ConflictLogRow>,
      ),
      ConflictLogRow,
      PrefetchHooks Function()
    >;
typedef $$LocalKvTableCreateCompanionBuilder =
    LocalKvCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$LocalKvTableUpdateCompanionBuilder =
    LocalKvCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$LocalKvTableFilterComposer
    extends Composer<_$AppDatabase, $LocalKvTable> {
  $$LocalKvTableFilterComposer({
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

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalKvTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalKvTable> {
  $$LocalKvTableOrderingComposer({
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

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalKvTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalKvTable> {
  $$LocalKvTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$LocalKvTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalKvTable,
          KvRow,
          $$LocalKvTableFilterComposer,
          $$LocalKvTableOrderingComposer,
          $$LocalKvTableAnnotationComposer,
          $$LocalKvTableCreateCompanionBuilder,
          $$LocalKvTableUpdateCompanionBuilder,
          (KvRow, BaseReferences<_$AppDatabase, $LocalKvTable, KvRow>),
          KvRow,
          PrefetchHooks Function()
        > {
  $$LocalKvTableTableManager(_$AppDatabase db, $LocalKvTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalKvTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalKvTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalKvTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalKvCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) =>
                  LocalKvCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalKvTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalKvTable,
      KvRow,
      $$LocalKvTableFilterComposer,
      $$LocalKvTableOrderingComposer,
      $$LocalKvTableAnnotationComposer,
      $$LocalKvTableCreateCompanionBuilder,
      $$LocalKvTableUpdateCompanionBuilder,
      (KvRow, BaseReferences<_$AppDatabase, $LocalKvTable, KvRow>),
      KvRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$PayeesTableTableManager get payees =>
      $$PayeesTableTableManager(_db, _db.payees);
  $$DailyBudgetsTableTableManager get dailyBudgets =>
      $$DailyBudgetsTableTableManager(_db, _db.dailyBudgets);
  $$BudgetAllocationsTableTableManager get budgetAllocations =>
      $$BudgetAllocationsTableTableManager(_db, _db.budgetAllocations);
  $$BudgetTemplatesTableTableManager get budgetTemplates =>
      $$BudgetTemplatesTableTableManager(_db, _db.budgetTemplates);
  $$PlannedExpensesTableTableManager get plannedExpenses =>
      $$PlannedExpensesTableTableManager(_db, _db.plannedExpenses);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$ReminderPreferencesTableTableManager get reminderPreferences =>
      $$ReminderPreferencesTableTableManager(_db, _db.reminderPreferences);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
  $$SyncCursorsTableTableManager get syncCursors =>
      $$SyncCursorsTableTableManager(_db, _db.syncCursors);
  $$ConflictLogTableTableManager get conflictLog =>
      $$ConflictLogTableTableManager(_db, _db.conflictLog);
  $$LocalKvTableTableManager get localKv =>
      $$LocalKvTableTableManager(_db, _db.localKv);
}
