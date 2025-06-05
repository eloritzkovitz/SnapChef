// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _firstNameMeta =
      const VerificationMeta('firstName');
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
      'first_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastNameMeta =
      const VerificationMeta('lastName');
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
      'last_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _passwordMeta =
      const VerificationMeta('password');
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
      'password', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _profilePictureMeta =
      const VerificationMeta('profilePicture');
  @override
  late final GeneratedColumn<String> profilePicture = GeneratedColumn<String>(
      'profile_picture', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _joinDateMeta =
      const VerificationMeta('joinDate');
  @override
  late final GeneratedColumn<String> joinDate = GeneratedColumn<String>(
      'join_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fridgeIdMeta =
      const VerificationMeta('fridgeId');
  @override
  late final GeneratedColumn<String> fridgeId = GeneratedColumn<String>(
      'fridge_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cookbookIdMeta =
      const VerificationMeta('cookbookId');
  @override
  late final GeneratedColumn<String> cookbookId = GeneratedColumn<String>(
      'cookbook_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _preferencesJsonMeta =
      const VerificationMeta('preferencesJson');
  @override
  late final GeneratedColumn<String> preferencesJson = GeneratedColumn<String>(
      'preferences_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _friendsJsonMeta =
      const VerificationMeta('friendsJson');
  @override
  late final GeneratedColumn<String> friendsJson = GeneratedColumn<String>(
      'friends_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fcmTokenMeta =
      const VerificationMeta('fcmToken');
  @override
  late final GeneratedColumn<String> fcmToken = GeneratedColumn<String>(
      'fcm_token', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        firstName,
        lastName,
        email,
        password,
        profilePicture,
        joinDate,
        fridgeId,
        cookbookId,
        preferencesJson,
        friendsJson,
        fcmToken
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(_firstNameMeta,
          firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta));
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(_lastNameMeta,
          lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta));
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('password')) {
      context.handle(_passwordMeta,
          password.isAcceptableOrUnknown(data['password']!, _passwordMeta));
    }
    if (data.containsKey('profile_picture')) {
      context.handle(
          _profilePictureMeta,
          profilePicture.isAcceptableOrUnknown(
              data['profile_picture']!, _profilePictureMeta));
    }
    if (data.containsKey('join_date')) {
      context.handle(_joinDateMeta,
          joinDate.isAcceptableOrUnknown(data['join_date']!, _joinDateMeta));
    }
    if (data.containsKey('fridge_id')) {
      context.handle(_fridgeIdMeta,
          fridgeId.isAcceptableOrUnknown(data['fridge_id']!, _fridgeIdMeta));
    } else if (isInserting) {
      context.missing(_fridgeIdMeta);
    }
    if (data.containsKey('cookbook_id')) {
      context.handle(
          _cookbookIdMeta,
          cookbookId.isAcceptableOrUnknown(
              data['cookbook_id']!, _cookbookIdMeta));
    } else if (isInserting) {
      context.missing(_cookbookIdMeta);
    }
    if (data.containsKey('preferences_json')) {
      context.handle(
          _preferencesJsonMeta,
          preferencesJson.isAcceptableOrUnknown(
              data['preferences_json']!, _preferencesJsonMeta));
    }
    if (data.containsKey('friends_json')) {
      context.handle(
          _friendsJsonMeta,
          friendsJson.isAcceptableOrUnknown(
              data['friends_json']!, _friendsJsonMeta));
    }
    if (data.containsKey('fcm_token')) {
      context.handle(_fcmTokenMeta,
          fcmToken.isAcceptableOrUnknown(data['fcm_token']!, _fcmTokenMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      firstName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}first_name'])!,
      lastName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_name'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      password: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password']),
      profilePicture: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_picture']),
      joinDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}join_date']),
      fridgeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fridge_id'])!,
      cookbookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cookbook_id'])!,
      preferencesJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}preferences_json']),
      friendsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}friends_json']),
      fcmToken: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fcm_token']),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? password;
  final String? profilePicture;
  final String? joinDate;
  final String fridgeId;
  final String cookbookId;
  final String? preferencesJson;
  final String? friendsJson;
  final String? fcmToken;
  const User(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.email,
      this.password,
      this.profilePicture,
      this.joinDate,
      required this.fridgeId,
      required this.cookbookId,
      this.preferencesJson,
      this.friendsJson,
      this.fcmToken});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || password != null) {
      map['password'] = Variable<String>(password);
    }
    if (!nullToAbsent || profilePicture != null) {
      map['profile_picture'] = Variable<String>(profilePicture);
    }
    if (!nullToAbsent || joinDate != null) {
      map['join_date'] = Variable<String>(joinDate);
    }
    map['fridge_id'] = Variable<String>(fridgeId);
    map['cookbook_id'] = Variable<String>(cookbookId);
    if (!nullToAbsent || preferencesJson != null) {
      map['preferences_json'] = Variable<String>(preferencesJson);
    }
    if (!nullToAbsent || friendsJson != null) {
      map['friends_json'] = Variable<String>(friendsJson);
    }
    if (!nullToAbsent || fcmToken != null) {
      map['fcm_token'] = Variable<String>(fcmToken);
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      firstName: Value(firstName),
      lastName: Value(lastName),
      email: Value(email),
      password: password == null && nullToAbsent
          ? const Value.absent()
          : Value(password),
      profilePicture: profilePicture == null && nullToAbsent
          ? const Value.absent()
          : Value(profilePicture),
      joinDate: joinDate == null && nullToAbsent
          ? const Value.absent()
          : Value(joinDate),
      fridgeId: Value(fridgeId),
      cookbookId: Value(cookbookId),
      preferencesJson: preferencesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(preferencesJson),
      friendsJson: friendsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(friendsJson),
      fcmToken: fcmToken == null && nullToAbsent
          ? const Value.absent()
          : Value(fcmToken),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      email: serializer.fromJson<String>(json['email']),
      password: serializer.fromJson<String?>(json['password']),
      profilePicture: serializer.fromJson<String?>(json['profilePicture']),
      joinDate: serializer.fromJson<String?>(json['joinDate']),
      fridgeId: serializer.fromJson<String>(json['fridgeId']),
      cookbookId: serializer.fromJson<String>(json['cookbookId']),
      preferencesJson: serializer.fromJson<String?>(json['preferencesJson']),
      friendsJson: serializer.fromJson<String?>(json['friendsJson']),
      fcmToken: serializer.fromJson<String?>(json['fcmToken']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'email': serializer.toJson<String>(email),
      'password': serializer.toJson<String?>(password),
      'profilePicture': serializer.toJson<String?>(profilePicture),
      'joinDate': serializer.toJson<String?>(joinDate),
      'fridgeId': serializer.toJson<String>(fridgeId),
      'cookbookId': serializer.toJson<String>(cookbookId),
      'preferencesJson': serializer.toJson<String?>(preferencesJson),
      'friendsJson': serializer.toJson<String?>(friendsJson),
      'fcmToken': serializer.toJson<String?>(fcmToken),
    };
  }

  User copyWith(
          {String? id,
          String? firstName,
          String? lastName,
          String? email,
          Value<String?> password = const Value.absent(),
          Value<String?> profilePicture = const Value.absent(),
          Value<String?> joinDate = const Value.absent(),
          String? fridgeId,
          String? cookbookId,
          Value<String?> preferencesJson = const Value.absent(),
          Value<String?> friendsJson = const Value.absent(),
          Value<String?> fcmToken = const Value.absent()}) =>
      User(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        email: email ?? this.email,
        password: password.present ? password.value : this.password,
        profilePicture:
            profilePicture.present ? profilePicture.value : this.profilePicture,
        joinDate: joinDate.present ? joinDate.value : this.joinDate,
        fridgeId: fridgeId ?? this.fridgeId,
        cookbookId: cookbookId ?? this.cookbookId,
        preferencesJson: preferencesJson.present
            ? preferencesJson.value
            : this.preferencesJson,
        friendsJson: friendsJson.present ? friendsJson.value : this.friendsJson,
        fcmToken: fcmToken.present ? fcmToken.value : this.fcmToken,
      );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      email: data.email.present ? data.email.value : this.email,
      password: data.password.present ? data.password.value : this.password,
      profilePicture: data.profilePicture.present
          ? data.profilePicture.value
          : this.profilePicture,
      joinDate: data.joinDate.present ? data.joinDate.value : this.joinDate,
      fridgeId: data.fridgeId.present ? data.fridgeId.value : this.fridgeId,
      cookbookId:
          data.cookbookId.present ? data.cookbookId.value : this.cookbookId,
      preferencesJson: data.preferencesJson.present
          ? data.preferencesJson.value
          : this.preferencesJson,
      friendsJson:
          data.friendsJson.present ? data.friendsJson.value : this.friendsJson,
      fcmToken: data.fcmToken.present ? data.fcmToken.value : this.fcmToken,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('email: $email, ')
          ..write('password: $password, ')
          ..write('profilePicture: $profilePicture, ')
          ..write('joinDate: $joinDate, ')
          ..write('fridgeId: $fridgeId, ')
          ..write('cookbookId: $cookbookId, ')
          ..write('preferencesJson: $preferencesJson, ')
          ..write('friendsJson: $friendsJson, ')
          ..write('fcmToken: $fcmToken')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      firstName,
      lastName,
      email,
      password,
      profilePicture,
      joinDate,
      fridgeId,
      cookbookId,
      preferencesJson,
      friendsJson,
      fcmToken);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.email == this.email &&
          other.password == this.password &&
          other.profilePicture == this.profilePicture &&
          other.joinDate == this.joinDate &&
          other.fridgeId == this.fridgeId &&
          other.cookbookId == this.cookbookId &&
          other.preferencesJson == this.preferencesJson &&
          other.friendsJson == this.friendsJson &&
          other.fcmToken == this.fcmToken);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<String> email;
  final Value<String?> password;
  final Value<String?> profilePicture;
  final Value<String?> joinDate;
  final Value<String> fridgeId;
  final Value<String> cookbookId;
  final Value<String?> preferencesJson;
  final Value<String?> friendsJson;
  final Value<String?> fcmToken;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.email = const Value.absent(),
    this.password = const Value.absent(),
    this.profilePicture = const Value.absent(),
    this.joinDate = const Value.absent(),
    this.fridgeId = const Value.absent(),
    this.cookbookId = const Value.absent(),
    this.preferencesJson = const Value.absent(),
    this.friendsJson = const Value.absent(),
    this.fcmToken = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    this.password = const Value.absent(),
    this.profilePicture = const Value.absent(),
    this.joinDate = const Value.absent(),
    required String fridgeId,
    required String cookbookId,
    this.preferencesJson = const Value.absent(),
    this.friendsJson = const Value.absent(),
    this.fcmToken = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        firstName = Value(firstName),
        lastName = Value(lastName),
        email = Value(email),
        fridgeId = Value(fridgeId),
        cookbookId = Value(cookbookId);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? email,
    Expression<String>? password,
    Expression<String>? profilePicture,
    Expression<String>? joinDate,
    Expression<String>? fridgeId,
    Expression<String>? cookbookId,
    Expression<String>? preferencesJson,
    Expression<String>? friendsJson,
    Expression<String>? fcmToken,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
      if (profilePicture != null) 'profile_picture': profilePicture,
      if (joinDate != null) 'join_date': joinDate,
      if (fridgeId != null) 'fridge_id': fridgeId,
      if (cookbookId != null) 'cookbook_id': cookbookId,
      if (preferencesJson != null) 'preferences_json': preferencesJson,
      if (friendsJson != null) 'friends_json': friendsJson,
      if (fcmToken != null) 'fcm_token': fcmToken,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? id,
      Value<String>? firstName,
      Value<String>? lastName,
      Value<String>? email,
      Value<String?>? password,
      Value<String?>? profilePicture,
      Value<String?>? joinDate,
      Value<String>? fridgeId,
      Value<String>? cookbookId,
      Value<String?>? preferencesJson,
      Value<String?>? friendsJson,
      Value<String?>? fcmToken,
      Value<int>? rowid}) {
    return UsersCompanion(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      profilePicture: profilePicture ?? this.profilePicture,
      joinDate: joinDate ?? this.joinDate,
      fridgeId: fridgeId ?? this.fridgeId,
      cookbookId: cookbookId ?? this.cookbookId,
      preferencesJson: preferencesJson ?? this.preferencesJson,
      friendsJson: friendsJson ?? this.friendsJson,
      fcmToken: fcmToken ?? this.fcmToken,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (profilePicture.present) {
      map['profile_picture'] = Variable<String>(profilePicture.value);
    }
    if (joinDate.present) {
      map['join_date'] = Variable<String>(joinDate.value);
    }
    if (fridgeId.present) {
      map['fridge_id'] = Variable<String>(fridgeId.value);
    }
    if (cookbookId.present) {
      map['cookbook_id'] = Variable<String>(cookbookId.value);
    }
    if (preferencesJson.present) {
      map['preferences_json'] = Variable<String>(preferencesJson.value);
    }
    if (friendsJson.present) {
      map['friends_json'] = Variable<String>(friendsJson.value);
    }
    if (fcmToken.present) {
      map['fcm_token'] = Variable<String>(fcmToken.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('email: $email, ')
          ..write('password: $password, ')
          ..write('profilePicture: $profilePicture, ')
          ..write('joinDate: $joinDate, ')
          ..write('fridgeId: $fridgeId, ')
          ..write('cookbookId: $cookbookId, ')
          ..write('preferencesJson: $preferencesJson, ')
          ..write('friendsJson: $friendsJson, ')
          ..write('fcmToken: $fcmToken, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [users];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  required String firstName,
  required String lastName,
  required String email,
  Value<String?> password,
  Value<String?> profilePicture,
  Value<String?> joinDate,
  required String fridgeId,
  required String cookbookId,
  Value<String?> preferencesJson,
  Value<String?> friendsJson,
  Value<String?> fcmToken,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String> firstName,
  Value<String> lastName,
  Value<String> email,
  Value<String?> password,
  Value<String?> profilePicture,
  Value<String?> joinDate,
  Value<String> fridgeId,
  Value<String> cookbookId,
  Value<String?> preferencesJson,
  Value<String?> friendsJson,
  Value<String?> fcmToken,
  Value<int> rowid,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get password => $composableBuilder(
      column: $table.password, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get profilePicture => $composableBuilder(
      column: $table.profilePicture,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get joinDate => $composableBuilder(
      column: $table.joinDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fridgeId => $composableBuilder(
      column: $table.fridgeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cookbookId => $composableBuilder(
      column: $table.cookbookId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get preferencesJson => $composableBuilder(
      column: $table.preferencesJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get friendsJson => $composableBuilder(
      column: $table.friendsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fcmToken => $composableBuilder(
      column: $table.fcmToken, builder: (column) => ColumnFilters(column));
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get firstName => $composableBuilder(
      column: $table.firstName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastName => $composableBuilder(
      column: $table.lastName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get password => $composableBuilder(
      column: $table.password, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get profilePicture => $composableBuilder(
      column: $table.profilePicture,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get joinDate => $composableBuilder(
      column: $table.joinDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fridgeId => $composableBuilder(
      column: $table.fridgeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cookbookId => $composableBuilder(
      column: $table.cookbookId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get preferencesJson => $composableBuilder(
      column: $table.preferencesJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get friendsJson => $composableBuilder(
      column: $table.friendsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fcmToken => $composableBuilder(
      column: $table.fcmToken, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumn<String> get profilePicture => $composableBuilder(
      column: $table.profilePicture, builder: (column) => column);

  GeneratedColumn<String> get joinDate =>
      $composableBuilder(column: $table.joinDate, builder: (column) => column);

  GeneratedColumn<String> get fridgeId =>
      $composableBuilder(column: $table.fridgeId, builder: (column) => column);

  GeneratedColumn<String> get cookbookId => $composableBuilder(
      column: $table.cookbookId, builder: (column) => column);

  GeneratedColumn<String> get preferencesJson => $composableBuilder(
      column: $table.preferencesJson, builder: (column) => column);

  GeneratedColumn<String> get friendsJson => $composableBuilder(
      column: $table.friendsJson, builder: (column) => column);

  GeneratedColumn<String> get fcmToken =>
      $composableBuilder(column: $table.fcmToken, builder: (column) => column);
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> firstName = const Value.absent(),
            Value<String> lastName = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String?> password = const Value.absent(),
            Value<String?> profilePicture = const Value.absent(),
            Value<String?> joinDate = const Value.absent(),
            Value<String> fridgeId = const Value.absent(),
            Value<String> cookbookId = const Value.absent(),
            Value<String?> preferencesJson = const Value.absent(),
            Value<String?> friendsJson = const Value.absent(),
            Value<String?> fcmToken = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
            profilePicture: profilePicture,
            joinDate: joinDate,
            fridgeId: fridgeId,
            cookbookId: cookbookId,
            preferencesJson: preferencesJson,
            friendsJson: friendsJson,
            fcmToken: fcmToken,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String firstName,
            required String lastName,
            required String email,
            Value<String?> password = const Value.absent(),
            Value<String?> profilePicture = const Value.absent(),
            Value<String?> joinDate = const Value.absent(),
            required String fridgeId,
            required String cookbookId,
            Value<String?> preferencesJson = const Value.absent(),
            Value<String?> friendsJson = const Value.absent(),
            Value<String?> fcmToken = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
            profilePicture: profilePicture,
            joinDate: joinDate,
            fridgeId: fridgeId,
            cookbookId: cookbookId,
            preferencesJson: preferencesJson,
            friendsJson: friendsJson,
            fcmToken: fcmToken,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
}
