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

class $UserStatsTable extends UserStats
    with TableInfo<$UserStatsTable, UserStat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ingredientCountMeta =
      const VerificationMeta('ingredientCount');
  @override
  late final GeneratedColumn<int> ingredientCount = GeneratedColumn<int>(
      'ingredient_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _recipeCountMeta =
      const VerificationMeta('recipeCount');
  @override
  late final GeneratedColumn<int> recipeCount = GeneratedColumn<int>(
      'recipe_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _favoriteRecipeCountMeta =
      const VerificationMeta('favoriteRecipeCount');
  @override
  late final GeneratedColumn<int> favoriteRecipeCount = GeneratedColumn<int>(
      'favorite_recipe_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _friendCountMeta =
      const VerificationMeta('friendCount');
  @override
  late final GeneratedColumn<int> friendCount = GeneratedColumn<int>(
      'friend_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _mostPopularIngredientsMeta =
      const VerificationMeta('mostPopularIngredients');
  @override
  late final GeneratedColumn<String> mostPopularIngredients =
      GeneratedColumn<String>('most_popular_ingredients', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        userId,
        ingredientCount,
        recipeCount,
        favoriteRecipeCount,
        friendCount,
        mostPopularIngredients
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_stats';
  @override
  VerificationContext validateIntegrity(Insertable<UserStat> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('ingredient_count')) {
      context.handle(
          _ingredientCountMeta,
          ingredientCount.isAcceptableOrUnknown(
              data['ingredient_count']!, _ingredientCountMeta));
    }
    if (data.containsKey('recipe_count')) {
      context.handle(
          _recipeCountMeta,
          recipeCount.isAcceptableOrUnknown(
              data['recipe_count']!, _recipeCountMeta));
    }
    if (data.containsKey('favorite_recipe_count')) {
      context.handle(
          _favoriteRecipeCountMeta,
          favoriteRecipeCount.isAcceptableOrUnknown(
              data['favorite_recipe_count']!, _favoriteRecipeCountMeta));
    }
    if (data.containsKey('friend_count')) {
      context.handle(
          _friendCountMeta,
          friendCount.isAcceptableOrUnknown(
              data['friend_count']!, _friendCountMeta));
    }
    if (data.containsKey('most_popular_ingredients')) {
      context.handle(
          _mostPopularIngredientsMeta,
          mostPopularIngredients.isAcceptableOrUnknown(
              data['most_popular_ingredients']!, _mostPopularIngredientsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  UserStat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserStat(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      ingredientCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ingredient_count']),
      recipeCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}recipe_count']),
      favoriteRecipeCount: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}favorite_recipe_count']),
      friendCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}friend_count']),
      mostPopularIngredients: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}most_popular_ingredients']),
    );
  }

  @override
  $UserStatsTable createAlias(String alias) {
    return $UserStatsTable(attachedDatabase, alias);
  }
}

class UserStat extends DataClass implements Insertable<UserStat> {
  final String userId;
  final int? ingredientCount;
  final int? recipeCount;
  final int? favoriteRecipeCount;
  final int? friendCount;
  final String? mostPopularIngredients;
  const UserStat(
      {required this.userId,
      this.ingredientCount,
      this.recipeCount,
      this.favoriteRecipeCount,
      this.friendCount,
      this.mostPopularIngredients});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || ingredientCount != null) {
      map['ingredient_count'] = Variable<int>(ingredientCount);
    }
    if (!nullToAbsent || recipeCount != null) {
      map['recipe_count'] = Variable<int>(recipeCount);
    }
    if (!nullToAbsent || favoriteRecipeCount != null) {
      map['favorite_recipe_count'] = Variable<int>(favoriteRecipeCount);
    }
    if (!nullToAbsent || friendCount != null) {
      map['friend_count'] = Variable<int>(friendCount);
    }
    if (!nullToAbsent || mostPopularIngredients != null) {
      map['most_popular_ingredients'] =
          Variable<String>(mostPopularIngredients);
    }
    return map;
  }

  UserStatsCompanion toCompanion(bool nullToAbsent) {
    return UserStatsCompanion(
      userId: Value(userId),
      ingredientCount: ingredientCount == null && nullToAbsent
          ? const Value.absent()
          : Value(ingredientCount),
      recipeCount: recipeCount == null && nullToAbsent
          ? const Value.absent()
          : Value(recipeCount),
      favoriteRecipeCount: favoriteRecipeCount == null && nullToAbsent
          ? const Value.absent()
          : Value(favoriteRecipeCount),
      friendCount: friendCount == null && nullToAbsent
          ? const Value.absent()
          : Value(friendCount),
      mostPopularIngredients: mostPopularIngredients == null && nullToAbsent
          ? const Value.absent()
          : Value(mostPopularIngredients),
    );
  }

  factory UserStat.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserStat(
      userId: serializer.fromJson<String>(json['userId']),
      ingredientCount: serializer.fromJson<int?>(json['ingredientCount']),
      recipeCount: serializer.fromJson<int?>(json['recipeCount']),
      favoriteRecipeCount:
          serializer.fromJson<int?>(json['favoriteRecipeCount']),
      friendCount: serializer.fromJson<int?>(json['friendCount']),
      mostPopularIngredients:
          serializer.fromJson<String?>(json['mostPopularIngredients']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'ingredientCount': serializer.toJson<int?>(ingredientCount),
      'recipeCount': serializer.toJson<int?>(recipeCount),
      'favoriteRecipeCount': serializer.toJson<int?>(favoriteRecipeCount),
      'friendCount': serializer.toJson<int?>(friendCount),
      'mostPopularIngredients':
          serializer.toJson<String?>(mostPopularIngredients),
    };
  }

  UserStat copyWith(
          {String? userId,
          Value<int?> ingredientCount = const Value.absent(),
          Value<int?> recipeCount = const Value.absent(),
          Value<int?> favoriteRecipeCount = const Value.absent(),
          Value<int?> friendCount = const Value.absent(),
          Value<String?> mostPopularIngredients = const Value.absent()}) =>
      UserStat(
        userId: userId ?? this.userId,
        ingredientCount: ingredientCount.present
            ? ingredientCount.value
            : this.ingredientCount,
        recipeCount: recipeCount.present ? recipeCount.value : this.recipeCount,
        favoriteRecipeCount: favoriteRecipeCount.present
            ? favoriteRecipeCount.value
            : this.favoriteRecipeCount,
        friendCount: friendCount.present ? friendCount.value : this.friendCount,
        mostPopularIngredients: mostPopularIngredients.present
            ? mostPopularIngredients.value
            : this.mostPopularIngredients,
      );
  UserStat copyWithCompanion(UserStatsCompanion data) {
    return UserStat(
      userId: data.userId.present ? data.userId.value : this.userId,
      ingredientCount: data.ingredientCount.present
          ? data.ingredientCount.value
          : this.ingredientCount,
      recipeCount:
          data.recipeCount.present ? data.recipeCount.value : this.recipeCount,
      favoriteRecipeCount: data.favoriteRecipeCount.present
          ? data.favoriteRecipeCount.value
          : this.favoriteRecipeCount,
      friendCount:
          data.friendCount.present ? data.friendCount.value : this.friendCount,
      mostPopularIngredients: data.mostPopularIngredients.present
          ? data.mostPopularIngredients.value
          : this.mostPopularIngredients,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserStat(')
          ..write('userId: $userId, ')
          ..write('ingredientCount: $ingredientCount, ')
          ..write('recipeCount: $recipeCount, ')
          ..write('favoriteRecipeCount: $favoriteRecipeCount, ')
          ..write('friendCount: $friendCount, ')
          ..write('mostPopularIngredients: $mostPopularIngredients')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, ingredientCount, recipeCount,
      favoriteRecipeCount, friendCount, mostPopularIngredients);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserStat &&
          other.userId == this.userId &&
          other.ingredientCount == this.ingredientCount &&
          other.recipeCount == this.recipeCount &&
          other.favoriteRecipeCount == this.favoriteRecipeCount &&
          other.friendCount == this.friendCount &&
          other.mostPopularIngredients == this.mostPopularIngredients);
}

class UserStatsCompanion extends UpdateCompanion<UserStat> {
  final Value<String> userId;
  final Value<int?> ingredientCount;
  final Value<int?> recipeCount;
  final Value<int?> favoriteRecipeCount;
  final Value<int?> friendCount;
  final Value<String?> mostPopularIngredients;
  final Value<int> rowid;
  const UserStatsCompanion({
    this.userId = const Value.absent(),
    this.ingredientCount = const Value.absent(),
    this.recipeCount = const Value.absent(),
    this.favoriteRecipeCount = const Value.absent(),
    this.friendCount = const Value.absent(),
    this.mostPopularIngredients = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserStatsCompanion.insert({
    required String userId,
    this.ingredientCount = const Value.absent(),
    this.recipeCount = const Value.absent(),
    this.favoriteRecipeCount = const Value.absent(),
    this.friendCount = const Value.absent(),
    this.mostPopularIngredients = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId);
  static Insertable<UserStat> custom({
    Expression<String>? userId,
    Expression<int>? ingredientCount,
    Expression<int>? recipeCount,
    Expression<int>? favoriteRecipeCount,
    Expression<int>? friendCount,
    Expression<String>? mostPopularIngredients,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (ingredientCount != null) 'ingredient_count': ingredientCount,
      if (recipeCount != null) 'recipe_count': recipeCount,
      if (favoriteRecipeCount != null)
        'favorite_recipe_count': favoriteRecipeCount,
      if (friendCount != null) 'friend_count': friendCount,
      if (mostPopularIngredients != null)
        'most_popular_ingredients': mostPopularIngredients,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserStatsCompanion copyWith(
      {Value<String>? userId,
      Value<int?>? ingredientCount,
      Value<int?>? recipeCount,
      Value<int?>? favoriteRecipeCount,
      Value<int?>? friendCount,
      Value<String?>? mostPopularIngredients,
      Value<int>? rowid}) {
    return UserStatsCompanion(
      userId: userId ?? this.userId,
      ingredientCount: ingredientCount ?? this.ingredientCount,
      recipeCount: recipeCount ?? this.recipeCount,
      favoriteRecipeCount: favoriteRecipeCount ?? this.favoriteRecipeCount,
      friendCount: friendCount ?? this.friendCount,
      mostPopularIngredients:
          mostPopularIngredients ?? this.mostPopularIngredients,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (ingredientCount.present) {
      map['ingredient_count'] = Variable<int>(ingredientCount.value);
    }
    if (recipeCount.present) {
      map['recipe_count'] = Variable<int>(recipeCount.value);
    }
    if (favoriteRecipeCount.present) {
      map['favorite_recipe_count'] = Variable<int>(favoriteRecipeCount.value);
    }
    if (friendCount.present) {
      map['friend_count'] = Variable<int>(friendCount.value);
    }
    if (mostPopularIngredients.present) {
      map['most_popular_ingredients'] =
          Variable<String>(mostPopularIngredients.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserStatsCompanion(')
          ..write('userId: $userId, ')
          ..write('ingredientCount: $ingredientCount, ')
          ..write('recipeCount: $recipeCount, ')
          ..write('favoriteRecipeCount: $favoriteRecipeCount, ')
          ..write('friendCount: $friendCount, ')
          ..write('mostPopularIngredients: $mostPopularIngredients, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IngredientsTable extends Ingredients
    with TableInfo<$IngredientsTable, Ingredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageURLMeta =
      const VerificationMeta('imageURL');
  @override
  late final GeneratedColumn<String> imageURL = GeneratedColumn<String>(
      'image_u_r_l', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, name, category, imageURL];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingredients';
  @override
  VerificationContext validateIntegrity(Insertable<Ingredient> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('image_u_r_l')) {
      context.handle(_imageURLMeta,
          imageURL.isAcceptableOrUnknown(data['image_u_r_l']!, _imageURLMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Ingredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ingredient(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      imageURL: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_u_r_l']),
    );
  }

  @override
  $IngredientsTable createAlias(String alias) {
    return $IngredientsTable(attachedDatabase, alias);
  }
}

class Ingredient extends DataClass implements Insertable<Ingredient> {
  final String id;
  final String name;
  final String? category;
  final String? imageURL;
  const Ingredient(
      {required this.id, required this.name, this.category, this.imageURL});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || imageURL != null) {
      map['image_u_r_l'] = Variable<String>(imageURL);
    }
    return map;
  }

  IngredientsCompanion toCompanion(bool nullToAbsent) {
    return IngredientsCompanion(
      id: Value(id),
      name: Value(name),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      imageURL: imageURL == null && nullToAbsent
          ? const Value.absent()
          : Value(imageURL),
    );
  }

  factory Ingredient.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ingredient(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String?>(json['category']),
      imageURL: serializer.fromJson<String?>(json['imageURL']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String?>(category),
      'imageURL': serializer.toJson<String?>(imageURL),
    };
  }

  Ingredient copyWith(
          {String? id,
          String? name,
          Value<String?> category = const Value.absent(),
          Value<String?> imageURL = const Value.absent()}) =>
      Ingredient(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category.present ? category.value : this.category,
        imageURL: imageURL.present ? imageURL.value : this.imageURL,
      );
  Ingredient copyWithCompanion(IngredientsCompanion data) {
    return Ingredient(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      imageURL: data.imageURL.present ? data.imageURL.value : this.imageURL,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ingredient(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('imageURL: $imageURL')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, category, imageURL);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ingredient &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.imageURL == this.imageURL);
}

class IngredientsCompanion extends UpdateCompanion<Ingredient> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> category;
  final Value<String?> imageURL;
  final Value<int> rowid;
  const IngredientsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.imageURL = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IngredientsCompanion.insert({
    required String id,
    required String name,
    this.category = const Value.absent(),
    this.imageURL = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Ingredient> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? imageURL,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (imageURL != null) 'image_u_r_l': imageURL,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IngredientsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? category,
      Value<String?>? imageURL,
      Value<int>? rowid}) {
    return IngredientsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      imageURL: imageURL ?? this.imageURL,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (imageURL.present) {
      map['image_u_r_l'] = Variable<String>(imageURL.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IngredientsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('imageURL: $imageURL, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FridgeIngredientsTable extends FridgeIngredients
    with TableInfo<$FridgeIngredientsTable, FridgeIngredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FridgeIngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
      'count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _imageURLMeta =
      const VerificationMeta('imageURL');
  @override
  late final GeneratedColumn<String> imageURL = GeneratedColumn<String>(
      'image_u_r_l', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isInFridgeMeta =
      const VerificationMeta('isInFridge');
  @override
  late final GeneratedColumn<bool> isInFridge = GeneratedColumn<bool>(
      'is_in_fridge', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_in_fridge" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _fridgeIdMeta =
      const VerificationMeta('fridgeId');
  @override
  late final GeneratedColumn<String> fridgeId = GeneratedColumn<String>(
      'fridge_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, category, count, imageURL, isInFridge, fridgeId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fridge_ingredients';
  @override
  VerificationContext validateIntegrity(Insertable<FridgeIngredient> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('count')) {
      context.handle(
          _countMeta, count.isAcceptableOrUnknown(data['count']!, _countMeta));
    }
    if (data.containsKey('image_u_r_l')) {
      context.handle(_imageURLMeta,
          imageURL.isAcceptableOrUnknown(data['image_u_r_l']!, _imageURLMeta));
    }
    if (data.containsKey('is_in_fridge')) {
      context.handle(
          _isInFridgeMeta,
          isInFridge.isAcceptableOrUnknown(
              data['is_in_fridge']!, _isInFridgeMeta));
    }
    if (data.containsKey('fridge_id')) {
      context.handle(_fridgeIdMeta,
          fridgeId.isAcceptableOrUnknown(data['fridge_id']!, _fridgeIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FridgeIngredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FridgeIngredient(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      count: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}count'])!,
      imageURL: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_u_r_l']),
      isInFridge: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_in_fridge'])!,
      fridgeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fridge_id']),
    );
  }

  @override
  $FridgeIngredientsTable createAlias(String alias) {
    return $FridgeIngredientsTable(attachedDatabase, alias);
  }
}

class FridgeIngredient extends DataClass
    implements Insertable<FridgeIngredient> {
  final String id;
  final String name;
  final String? category;
  final int count;
  final String? imageURL;
  final bool isInFridge;
  final String? fridgeId;
  const FridgeIngredient(
      {required this.id,
      required this.name,
      this.category,
      required this.count,
      this.imageURL,
      required this.isInFridge,
      this.fridgeId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['count'] = Variable<int>(count);
    if (!nullToAbsent || imageURL != null) {
      map['image_u_r_l'] = Variable<String>(imageURL);
    }
    map['is_in_fridge'] = Variable<bool>(isInFridge);
    if (!nullToAbsent || fridgeId != null) {
      map['fridge_id'] = Variable<String>(fridgeId);
    }
    return map;
  }

  FridgeIngredientsCompanion toCompanion(bool nullToAbsent) {
    return FridgeIngredientsCompanion(
      id: Value(id),
      name: Value(name),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      count: Value(count),
      imageURL: imageURL == null && nullToAbsent
          ? const Value.absent()
          : Value(imageURL),
      isInFridge: Value(isInFridge),
      fridgeId: fridgeId == null && nullToAbsent
          ? const Value.absent()
          : Value(fridgeId),
    );
  }

  factory FridgeIngredient.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FridgeIngredient(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String?>(json['category']),
      count: serializer.fromJson<int>(json['count']),
      imageURL: serializer.fromJson<String?>(json['imageURL']),
      isInFridge: serializer.fromJson<bool>(json['isInFridge']),
      fridgeId: serializer.fromJson<String?>(json['fridgeId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String?>(category),
      'count': serializer.toJson<int>(count),
      'imageURL': serializer.toJson<String?>(imageURL),
      'isInFridge': serializer.toJson<bool>(isInFridge),
      'fridgeId': serializer.toJson<String?>(fridgeId),
    };
  }

  FridgeIngredient copyWith(
          {String? id,
          String? name,
          Value<String?> category = const Value.absent(),
          int? count,
          Value<String?> imageURL = const Value.absent(),
          bool? isInFridge,
          Value<String?> fridgeId = const Value.absent()}) =>
      FridgeIngredient(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category.present ? category.value : this.category,
        count: count ?? this.count,
        imageURL: imageURL.present ? imageURL.value : this.imageURL,
        isInFridge: isInFridge ?? this.isInFridge,
        fridgeId: fridgeId.present ? fridgeId.value : this.fridgeId,
      );
  FridgeIngredient copyWithCompanion(FridgeIngredientsCompanion data) {
    return FridgeIngredient(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      count: data.count.present ? data.count.value : this.count,
      imageURL: data.imageURL.present ? data.imageURL.value : this.imageURL,
      isInFridge:
          data.isInFridge.present ? data.isInFridge.value : this.isInFridge,
      fridgeId: data.fridgeId.present ? data.fridgeId.value : this.fridgeId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FridgeIngredient(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('count: $count, ')
          ..write('imageURL: $imageURL, ')
          ..write('isInFridge: $isInFridge, ')
          ..write('fridgeId: $fridgeId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, category, count, imageURL, isInFridge, fridgeId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FridgeIngredient &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.count == this.count &&
          other.imageURL == this.imageURL &&
          other.isInFridge == this.isInFridge &&
          other.fridgeId == this.fridgeId);
}

class FridgeIngredientsCompanion extends UpdateCompanion<FridgeIngredient> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> category;
  final Value<int> count;
  final Value<String?> imageURL;
  final Value<bool> isInFridge;
  final Value<String?> fridgeId;
  final Value<int> rowid;
  const FridgeIngredientsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.count = const Value.absent(),
    this.imageURL = const Value.absent(),
    this.isInFridge = const Value.absent(),
    this.fridgeId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FridgeIngredientsCompanion.insert({
    required String id,
    required String name,
    this.category = const Value.absent(),
    this.count = const Value.absent(),
    this.imageURL = const Value.absent(),
    this.isInFridge = const Value.absent(),
    this.fridgeId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<FridgeIngredient> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<int>? count,
    Expression<String>? imageURL,
    Expression<bool>? isInFridge,
    Expression<String>? fridgeId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (count != null) 'count': count,
      if (imageURL != null) 'image_u_r_l': imageURL,
      if (isInFridge != null) 'is_in_fridge': isInFridge,
      if (fridgeId != null) 'fridge_id': fridgeId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FridgeIngredientsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? category,
      Value<int>? count,
      Value<String?>? imageURL,
      Value<bool>? isInFridge,
      Value<String?>? fridgeId,
      Value<int>? rowid}) {
    return FridgeIngredientsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      count: count ?? this.count,
      imageURL: imageURL ?? this.imageURL,
      isInFridge: isInFridge ?? this.isInFridge,
      fridgeId: fridgeId ?? this.fridgeId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (imageURL.present) {
      map['image_u_r_l'] = Variable<String>(imageURL.value);
    }
    if (isInFridge.present) {
      map['is_in_fridge'] = Variable<bool>(isInFridge.value);
    }
    if (fridgeId.present) {
      map['fridge_id'] = Variable<String>(fridgeId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FridgeIngredientsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('count: $count, ')
          ..write('imageURL: $imageURL, ')
          ..write('isInFridge: $isInFridge, ')
          ..write('fridgeId: $fridgeId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipesTable extends Recipes with TableInfo<$RecipesTable, Recipe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mealTypeMeta =
      const VerificationMeta('mealType');
  @override
  late final GeneratedColumn<String> mealType = GeneratedColumn<String>(
      'meal_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cuisineTypeMeta =
      const VerificationMeta('cuisineType');
  @override
  late final GeneratedColumn<String> cuisineType = GeneratedColumn<String>(
      'cuisine_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _difficultyMeta =
      const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
      'difficulty', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _prepTimeMeta =
      const VerificationMeta('prepTime');
  @override
  late final GeneratedColumn<int> prepTime = GeneratedColumn<int>(
      'prep_time', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _cookingTimeMeta =
      const VerificationMeta('cookingTime');
  @override
  late final GeneratedColumn<int> cookingTime = GeneratedColumn<int>(
      'cooking_time', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _ingredientsJsonMeta =
      const VerificationMeta('ingredientsJson');
  @override
  late final GeneratedColumn<String> ingredientsJson = GeneratedColumn<String>(
      'ingredients_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _instructionsJsonMeta =
      const VerificationMeta('instructionsJson');
  @override
  late final GeneratedColumn<String> instructionsJson = GeneratedColumn<String>(
      'instructions_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imageURLMeta =
      const VerificationMeta('imageURL');
  @override
  late final GeneratedColumn<String> imageURL = GeneratedColumn<String>(
      'image_u_r_l', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
      'rating', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
      'order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        title,
        description,
        mealType,
        cuisineType,
        difficulty,
        prepTime,
        cookingTime,
        ingredientsJson,
        instructionsJson,
        imageURL,
        rating,
        isFavorite,
        source,
        order
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipes';
  @override
  VerificationContext validateIntegrity(Insertable<Recipe> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('meal_type')) {
      context.handle(_mealTypeMeta,
          mealType.isAcceptableOrUnknown(data['meal_type']!, _mealTypeMeta));
    } else if (isInserting) {
      context.missing(_mealTypeMeta);
    }
    if (data.containsKey('cuisine_type')) {
      context.handle(
          _cuisineTypeMeta,
          cuisineType.isAcceptableOrUnknown(
              data['cuisine_type']!, _cuisineTypeMeta));
    } else if (isInserting) {
      context.missing(_cuisineTypeMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
          _difficultyMeta,
          difficulty.isAcceptableOrUnknown(
              data['difficulty']!, _difficultyMeta));
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('prep_time')) {
      context.handle(_prepTimeMeta,
          prepTime.isAcceptableOrUnknown(data['prep_time']!, _prepTimeMeta));
    } else if (isInserting) {
      context.missing(_prepTimeMeta);
    }
    if (data.containsKey('cooking_time')) {
      context.handle(
          _cookingTimeMeta,
          cookingTime.isAcceptableOrUnknown(
              data['cooking_time']!, _cookingTimeMeta));
    } else if (isInserting) {
      context.missing(_cookingTimeMeta);
    }
    if (data.containsKey('ingredients_json')) {
      context.handle(
          _ingredientsJsonMeta,
          ingredientsJson.isAcceptableOrUnknown(
              data['ingredients_json']!, _ingredientsJsonMeta));
    } else if (isInserting) {
      context.missing(_ingredientsJsonMeta);
    }
    if (data.containsKey('instructions_json')) {
      context.handle(
          _instructionsJsonMeta,
          instructionsJson.isAcceptableOrUnknown(
              data['instructions_json']!, _instructionsJsonMeta));
    } else if (isInserting) {
      context.missing(_instructionsJsonMeta);
    }
    if (data.containsKey('image_u_r_l')) {
      context.handle(_imageURLMeta,
          imageURL.isAcceptableOrUnknown(data['image_u_r_l']!, _imageURLMeta));
    }
    if (data.containsKey('rating')) {
      context.handle(_ratingMeta,
          rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('order')) {
      context.handle(
          _orderMeta, order.isAcceptableOrUnknown(data['order']!, _orderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Recipe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recipe(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      mealType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meal_type'])!,
      cuisineType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cuisine_type'])!,
      difficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}difficulty'])!,
      prepTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}prep_time'])!,
      cookingTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cooking_time'])!,
      ingredientsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}ingredients_json'])!,
      instructionsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}instructions_json'])!,
      imageURL: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_u_r_l']),
      rating: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rating']),
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      order: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order'])!,
    );
  }

  @override
  $RecipesTable createAlias(String alias) {
    return $RecipesTable(attachedDatabase, alias);
  }
}

class Recipe extends DataClass implements Insertable<Recipe> {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String mealType;
  final String cuisineType;
  final String difficulty;
  final int prepTime;
  final int cookingTime;
  final String ingredientsJson;
  final String instructionsJson;
  final String? imageURL;
  final double? rating;
  final bool isFavorite;
  final String source;
  final int order;
  const Recipe(
      {required this.id,
      required this.userId,
      required this.title,
      required this.description,
      required this.mealType,
      required this.cuisineType,
      required this.difficulty,
      required this.prepTime,
      required this.cookingTime,
      required this.ingredientsJson,
      required this.instructionsJson,
      this.imageURL,
      this.rating,
      required this.isFavorite,
      required this.source,
      required this.order});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['meal_type'] = Variable<String>(mealType);
    map['cuisine_type'] = Variable<String>(cuisineType);
    map['difficulty'] = Variable<String>(difficulty);
    map['prep_time'] = Variable<int>(prepTime);
    map['cooking_time'] = Variable<int>(cookingTime);
    map['ingredients_json'] = Variable<String>(ingredientsJson);
    map['instructions_json'] = Variable<String>(instructionsJson);
    if (!nullToAbsent || imageURL != null) {
      map['image_u_r_l'] = Variable<String>(imageURL);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<double>(rating);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['source'] = Variable<String>(source);
    map['order'] = Variable<int>(order);
    return map;
  }

  RecipesCompanion toCompanion(bool nullToAbsent) {
    return RecipesCompanion(
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      description: Value(description),
      mealType: Value(mealType),
      cuisineType: Value(cuisineType),
      difficulty: Value(difficulty),
      prepTime: Value(prepTime),
      cookingTime: Value(cookingTime),
      ingredientsJson: Value(ingredientsJson),
      instructionsJson: Value(instructionsJson),
      imageURL: imageURL == null && nullToAbsent
          ? const Value.absent()
          : Value(imageURL),
      rating:
          rating == null && nullToAbsent ? const Value.absent() : Value(rating),
      isFavorite: Value(isFavorite),
      source: Value(source),
      order: Value(order),
    );
  }

  factory Recipe.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recipe(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      mealType: serializer.fromJson<String>(json['mealType']),
      cuisineType: serializer.fromJson<String>(json['cuisineType']),
      difficulty: serializer.fromJson<String>(json['difficulty']),
      prepTime: serializer.fromJson<int>(json['prepTime']),
      cookingTime: serializer.fromJson<int>(json['cookingTime']),
      ingredientsJson: serializer.fromJson<String>(json['ingredientsJson']),
      instructionsJson: serializer.fromJson<String>(json['instructionsJson']),
      imageURL: serializer.fromJson<String?>(json['imageURL']),
      rating: serializer.fromJson<double?>(json['rating']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      source: serializer.fromJson<String>(json['source']),
      order: serializer.fromJson<int>(json['order']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'mealType': serializer.toJson<String>(mealType),
      'cuisineType': serializer.toJson<String>(cuisineType),
      'difficulty': serializer.toJson<String>(difficulty),
      'prepTime': serializer.toJson<int>(prepTime),
      'cookingTime': serializer.toJson<int>(cookingTime),
      'ingredientsJson': serializer.toJson<String>(ingredientsJson),
      'instructionsJson': serializer.toJson<String>(instructionsJson),
      'imageURL': serializer.toJson<String?>(imageURL),
      'rating': serializer.toJson<double?>(rating),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'source': serializer.toJson<String>(source),
      'order': serializer.toJson<int>(order),
    };
  }

  Recipe copyWith(
          {String? id,
          String? userId,
          String? title,
          String? description,
          String? mealType,
          String? cuisineType,
          String? difficulty,
          int? prepTime,
          int? cookingTime,
          String? ingredientsJson,
          String? instructionsJson,
          Value<String?> imageURL = const Value.absent(),
          Value<double?> rating = const Value.absent(),
          bool? isFavorite,
          String? source,
          int? order}) =>
      Recipe(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        description: description ?? this.description,
        mealType: mealType ?? this.mealType,
        cuisineType: cuisineType ?? this.cuisineType,
        difficulty: difficulty ?? this.difficulty,
        prepTime: prepTime ?? this.prepTime,
        cookingTime: cookingTime ?? this.cookingTime,
        ingredientsJson: ingredientsJson ?? this.ingredientsJson,
        instructionsJson: instructionsJson ?? this.instructionsJson,
        imageURL: imageURL.present ? imageURL.value : this.imageURL,
        rating: rating.present ? rating.value : this.rating,
        isFavorite: isFavorite ?? this.isFavorite,
        source: source ?? this.source,
        order: order ?? this.order,
      );
  Recipe copyWithCompanion(RecipesCompanion data) {
    return Recipe(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      mealType: data.mealType.present ? data.mealType.value : this.mealType,
      cuisineType:
          data.cuisineType.present ? data.cuisineType.value : this.cuisineType,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      prepTime: data.prepTime.present ? data.prepTime.value : this.prepTime,
      cookingTime:
          data.cookingTime.present ? data.cookingTime.value : this.cookingTime,
      ingredientsJson: data.ingredientsJson.present
          ? data.ingredientsJson.value
          : this.ingredientsJson,
      instructionsJson: data.instructionsJson.present
          ? data.instructionsJson.value
          : this.instructionsJson,
      imageURL: data.imageURL.present ? data.imageURL.value : this.imageURL,
      rating: data.rating.present ? data.rating.value : this.rating,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      source: data.source.present ? data.source.value : this.source,
      order: data.order.present ? data.order.value : this.order,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Recipe(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('mealType: $mealType, ')
          ..write('cuisineType: $cuisineType, ')
          ..write('difficulty: $difficulty, ')
          ..write('prepTime: $prepTime, ')
          ..write('cookingTime: $cookingTime, ')
          ..write('ingredientsJson: $ingredientsJson, ')
          ..write('instructionsJson: $instructionsJson, ')
          ..write('imageURL: $imageURL, ')
          ..write('rating: $rating, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('source: $source, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      userId,
      title,
      description,
      mealType,
      cuisineType,
      difficulty,
      prepTime,
      cookingTime,
      ingredientsJson,
      instructionsJson,
      imageURL,
      rating,
      isFavorite,
      source,
      order);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recipe &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.description == this.description &&
          other.mealType == this.mealType &&
          other.cuisineType == this.cuisineType &&
          other.difficulty == this.difficulty &&
          other.prepTime == this.prepTime &&
          other.cookingTime == this.cookingTime &&
          other.ingredientsJson == this.ingredientsJson &&
          other.instructionsJson == this.instructionsJson &&
          other.imageURL == this.imageURL &&
          other.rating == this.rating &&
          other.isFavorite == this.isFavorite &&
          other.source == this.source &&
          other.order == this.order);
}

class RecipesCompanion extends UpdateCompanion<Recipe> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> title;
  final Value<String> description;
  final Value<String> mealType;
  final Value<String> cuisineType;
  final Value<String> difficulty;
  final Value<int> prepTime;
  final Value<int> cookingTime;
  final Value<String> ingredientsJson;
  final Value<String> instructionsJson;
  final Value<String?> imageURL;
  final Value<double?> rating;
  final Value<bool> isFavorite;
  final Value<String> source;
  final Value<int> order;
  final Value<int> rowid;
  const RecipesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.mealType = const Value.absent(),
    this.cuisineType = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.prepTime = const Value.absent(),
    this.cookingTime = const Value.absent(),
    this.ingredientsJson = const Value.absent(),
    this.instructionsJson = const Value.absent(),
    this.imageURL = const Value.absent(),
    this.rating = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.source = const Value.absent(),
    this.order = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipesCompanion.insert({
    required String id,
    required String userId,
    required String title,
    required String description,
    required String mealType,
    required String cuisineType,
    required String difficulty,
    required int prepTime,
    required int cookingTime,
    required String ingredientsJson,
    required String instructionsJson,
    this.imageURL = const Value.absent(),
    this.rating = const Value.absent(),
    this.isFavorite = const Value.absent(),
    required String source,
    this.order = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        title = Value(title),
        description = Value(description),
        mealType = Value(mealType),
        cuisineType = Value(cuisineType),
        difficulty = Value(difficulty),
        prepTime = Value(prepTime),
        cookingTime = Value(cookingTime),
        ingredientsJson = Value(ingredientsJson),
        instructionsJson = Value(instructionsJson),
        source = Value(source);
  static Insertable<Recipe> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? mealType,
    Expression<String>? cuisineType,
    Expression<String>? difficulty,
    Expression<int>? prepTime,
    Expression<int>? cookingTime,
    Expression<String>? ingredientsJson,
    Expression<String>? instructionsJson,
    Expression<String>? imageURL,
    Expression<double>? rating,
    Expression<bool>? isFavorite,
    Expression<String>? source,
    Expression<int>? order,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (mealType != null) 'meal_type': mealType,
      if (cuisineType != null) 'cuisine_type': cuisineType,
      if (difficulty != null) 'difficulty': difficulty,
      if (prepTime != null) 'prep_time': prepTime,
      if (cookingTime != null) 'cooking_time': cookingTime,
      if (ingredientsJson != null) 'ingredients_json': ingredientsJson,
      if (instructionsJson != null) 'instructions_json': instructionsJson,
      if (imageURL != null) 'image_u_r_l': imageURL,
      if (rating != null) 'rating': rating,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (source != null) 'source': source,
      if (order != null) 'order': order,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipesCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? title,
      Value<String>? description,
      Value<String>? mealType,
      Value<String>? cuisineType,
      Value<String>? difficulty,
      Value<int>? prepTime,
      Value<int>? cookingTime,
      Value<String>? ingredientsJson,
      Value<String>? instructionsJson,
      Value<String?>? imageURL,
      Value<double?>? rating,
      Value<bool>? isFavorite,
      Value<String>? source,
      Value<int>? order,
      Value<int>? rowid}) {
    return RecipesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      mealType: mealType ?? this.mealType,
      cuisineType: cuisineType ?? this.cuisineType,
      difficulty: difficulty ?? this.difficulty,
      prepTime: prepTime ?? this.prepTime,
      cookingTime: cookingTime ?? this.cookingTime,
      ingredientsJson: ingredientsJson ?? this.ingredientsJson,
      instructionsJson: instructionsJson ?? this.instructionsJson,
      imageURL: imageURL ?? this.imageURL,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
      source: source ?? this.source,
      order: order ?? this.order,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (mealType.present) {
      map['meal_type'] = Variable<String>(mealType.value);
    }
    if (cuisineType.present) {
      map['cuisine_type'] = Variable<String>(cuisineType.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (prepTime.present) {
      map['prep_time'] = Variable<int>(prepTime.value);
    }
    if (cookingTime.present) {
      map['cooking_time'] = Variable<int>(cookingTime.value);
    }
    if (ingredientsJson.present) {
      map['ingredients_json'] = Variable<String>(ingredientsJson.value);
    }
    if (instructionsJson.present) {
      map['instructions_json'] = Variable<String>(instructionsJson.value);
    }
    if (imageURL.present) {
      map['image_u_r_l'] = Variable<String>(imageURL.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('mealType: $mealType, ')
          ..write('cuisineType: $cuisineType, ')
          ..write('difficulty: $difficulty, ')
          ..write('prepTime: $prepTime, ')
          ..write('cookingTime: $cookingTime, ')
          ..write('ingredientsJson: $ingredientsJson, ')
          ..write('instructionsJson: $instructionsJson, ')
          ..write('imageURL: $imageURL, ')
          ..write('rating: $rating, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('source: $source, ')
          ..write('order: $order, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SharedRecipesTable extends SharedRecipes
    with TableInfo<$SharedRecipesTable, SharedRecipe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SharedRecipesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recipeIdMeta =
      const VerificationMeta('recipeId');
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
      'recipe_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fromUserMeta =
      const VerificationMeta('fromUser');
  @override
  late final GeneratedColumn<String> fromUser = GeneratedColumn<String>(
      'from_user', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _toUserMeta = const VerificationMeta('toUser');
  @override
  late final GeneratedColumn<String> toUser = GeneratedColumn<String>(
      'to_user', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sharedAtMeta =
      const VerificationMeta('sharedAt');
  @override
  late final GeneratedColumn<String> sharedAt = GeneratedColumn<String>(
      'shared_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, recipeId, fromUser, toUser, sharedAt, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shared_recipes';
  @override
  VerificationContext validateIntegrity(Insertable<SharedRecipe> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('recipe_id')) {
      context.handle(_recipeIdMeta,
          recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta));
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('from_user')) {
      context.handle(_fromUserMeta,
          fromUser.isAcceptableOrUnknown(data['from_user']!, _fromUserMeta));
    } else if (isInserting) {
      context.missing(_fromUserMeta);
    }
    if (data.containsKey('to_user')) {
      context.handle(_toUserMeta,
          toUser.isAcceptableOrUnknown(data['to_user']!, _toUserMeta));
    } else if (isInserting) {
      context.missing(_toUserMeta);
    }
    if (data.containsKey('shared_at')) {
      context.handle(_sharedAtMeta,
          sharedAt.isAcceptableOrUnknown(data['shared_at']!, _sharedAtMeta));
    } else if (isInserting) {
      context.missing(_sharedAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SharedRecipe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SharedRecipe(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      recipeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recipe_id'])!,
      fromUser: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}from_user'])!,
      toUser: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}to_user'])!,
      sharedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shared_at'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $SharedRecipesTable createAlias(String alias) {
    return $SharedRecipesTable(attachedDatabase, alias);
  }
}

class SharedRecipe extends DataClass implements Insertable<SharedRecipe> {
  final String id;
  final String recipeId;
  final String fromUser;
  final String toUser;
  final String sharedAt;
  final String status;
  const SharedRecipe(
      {required this.id,
      required this.recipeId,
      required this.fromUser,
      required this.toUser,
      required this.sharedAt,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['recipe_id'] = Variable<String>(recipeId);
    map['from_user'] = Variable<String>(fromUser);
    map['to_user'] = Variable<String>(toUser);
    map['shared_at'] = Variable<String>(sharedAt);
    map['status'] = Variable<String>(status);
    return map;
  }

  SharedRecipesCompanion toCompanion(bool nullToAbsent) {
    return SharedRecipesCompanion(
      id: Value(id),
      recipeId: Value(recipeId),
      fromUser: Value(fromUser),
      toUser: Value(toUser),
      sharedAt: Value(sharedAt),
      status: Value(status),
    );
  }

  factory SharedRecipe.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SharedRecipe(
      id: serializer.fromJson<String>(json['id']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      fromUser: serializer.fromJson<String>(json['fromUser']),
      toUser: serializer.fromJson<String>(json['toUser']),
      sharedAt: serializer.fromJson<String>(json['sharedAt']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'recipeId': serializer.toJson<String>(recipeId),
      'fromUser': serializer.toJson<String>(fromUser),
      'toUser': serializer.toJson<String>(toUser),
      'sharedAt': serializer.toJson<String>(sharedAt),
      'status': serializer.toJson<String>(status),
    };
  }

  SharedRecipe copyWith(
          {String? id,
          String? recipeId,
          String? fromUser,
          String? toUser,
          String? sharedAt,
          String? status}) =>
      SharedRecipe(
        id: id ?? this.id,
        recipeId: recipeId ?? this.recipeId,
        fromUser: fromUser ?? this.fromUser,
        toUser: toUser ?? this.toUser,
        sharedAt: sharedAt ?? this.sharedAt,
        status: status ?? this.status,
      );
  SharedRecipe copyWithCompanion(SharedRecipesCompanion data) {
    return SharedRecipe(
      id: data.id.present ? data.id.value : this.id,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      fromUser: data.fromUser.present ? data.fromUser.value : this.fromUser,
      toUser: data.toUser.present ? data.toUser.value : this.toUser,
      sharedAt: data.sharedAt.present ? data.sharedAt.value : this.sharedAt,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SharedRecipe(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('fromUser: $fromUser, ')
          ..write('toUser: $toUser, ')
          ..write('sharedAt: $sharedAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, recipeId, fromUser, toUser, sharedAt, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SharedRecipe &&
          other.id == this.id &&
          other.recipeId == this.recipeId &&
          other.fromUser == this.fromUser &&
          other.toUser == this.toUser &&
          other.sharedAt == this.sharedAt &&
          other.status == this.status);
}

class SharedRecipesCompanion extends UpdateCompanion<SharedRecipe> {
  final Value<String> id;
  final Value<String> recipeId;
  final Value<String> fromUser;
  final Value<String> toUser;
  final Value<String> sharedAt;
  final Value<String> status;
  final Value<int> rowid;
  const SharedRecipesCompanion({
    this.id = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.fromUser = const Value.absent(),
    this.toUser = const Value.absent(),
    this.sharedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SharedRecipesCompanion.insert({
    required String id,
    required String recipeId,
    required String fromUser,
    required String toUser,
    required String sharedAt,
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        recipeId = Value(recipeId),
        fromUser = Value(fromUser),
        toUser = Value(toUser),
        sharedAt = Value(sharedAt);
  static Insertable<SharedRecipe> custom({
    Expression<String>? id,
    Expression<String>? recipeId,
    Expression<String>? fromUser,
    Expression<String>? toUser,
    Expression<String>? sharedAt,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recipeId != null) 'recipe_id': recipeId,
      if (fromUser != null) 'from_user': fromUser,
      if (toUser != null) 'to_user': toUser,
      if (sharedAt != null) 'shared_at': sharedAt,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SharedRecipesCompanion copyWith(
      {Value<String>? id,
      Value<String>? recipeId,
      Value<String>? fromUser,
      Value<String>? toUser,
      Value<String>? sharedAt,
      Value<String>? status,
      Value<int>? rowid}) {
    return SharedRecipesCompanion(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      fromUser: fromUser ?? this.fromUser,
      toUser: toUser ?? this.toUser,
      sharedAt: sharedAt ?? this.sharedAt,
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
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (fromUser.present) {
      map['from_user'] = Variable<String>(fromUser.value);
    }
    if (toUser.present) {
      map['to_user'] = Variable<String>(toUser.value);
    }
    if (sharedAt.present) {
      map['shared_at'] = Variable<String>(sharedAt.value);
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
    return (StringBuffer('SharedRecipesCompanion(')
          ..write('id: $id, ')
          ..write('recipeId: $recipeId, ')
          ..write('fromUser: $fromUser, ')
          ..write('toUser: $toUser, ')
          ..write('sharedAt: $sharedAt, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FriendsTable extends Friends with TableInfo<$FriendsTable, Friend> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FriendsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _friendIdMeta =
      const VerificationMeta('friendId');
  @override
  late final GeneratedColumn<String> friendId = GeneratedColumn<String>(
      'friend_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _friendNameMeta =
      const VerificationMeta('friendName');
  @override
  late final GeneratedColumn<String> friendName = GeneratedColumn<String>(
      'friend_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _friendEmailMeta =
      const VerificationMeta('friendEmail');
  @override
  late final GeneratedColumn<String> friendEmail = GeneratedColumn<String>(
      'friend_email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _friendProfilePictureMeta =
      const VerificationMeta('friendProfilePicture');
  @override
  late final GeneratedColumn<String> friendProfilePicture =
      GeneratedColumn<String>('friend_profile_picture', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _friendJoinDateMeta =
      const VerificationMeta('friendJoinDate');
  @override
  late final GeneratedColumn<String> friendJoinDate = GeneratedColumn<String>(
      'friend_join_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        friendId,
        friendName,
        friendEmail,
        friendProfilePicture,
        friendJoinDate
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'friends';
  @override
  VerificationContext validateIntegrity(Insertable<Friend> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('friend_id')) {
      context.handle(_friendIdMeta,
          friendId.isAcceptableOrUnknown(data['friend_id']!, _friendIdMeta));
    } else if (isInserting) {
      context.missing(_friendIdMeta);
    }
    if (data.containsKey('friend_name')) {
      context.handle(
          _friendNameMeta,
          friendName.isAcceptableOrUnknown(
              data['friend_name']!, _friendNameMeta));
    } else if (isInserting) {
      context.missing(_friendNameMeta);
    }
    if (data.containsKey('friend_email')) {
      context.handle(
          _friendEmailMeta,
          friendEmail.isAcceptableOrUnknown(
              data['friend_email']!, _friendEmailMeta));
    } else if (isInserting) {
      context.missing(_friendEmailMeta);
    }
    if (data.containsKey('friend_profile_picture')) {
      context.handle(
          _friendProfilePictureMeta,
          friendProfilePicture.isAcceptableOrUnknown(
              data['friend_profile_picture']!, _friendProfilePictureMeta));
    }
    if (data.containsKey('friend_join_date')) {
      context.handle(
          _friendJoinDateMeta,
          friendJoinDate.isAcceptableOrUnknown(
              data['friend_join_date']!, _friendJoinDateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Friend map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Friend(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      friendId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}friend_id'])!,
      friendName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}friend_name'])!,
      friendEmail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}friend_email'])!,
      friendProfilePicture: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}friend_profile_picture']),
      friendJoinDate: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}friend_join_date']),
    );
  }

  @override
  $FriendsTable createAlias(String alias) {
    return $FriendsTable(attachedDatabase, alias);
  }
}

class Friend extends DataClass implements Insertable<Friend> {
  final int id;
  final String userId;
  final String friendId;
  final String friendName;
  final String friendEmail;
  final String? friendProfilePicture;
  final String? friendJoinDate;
  const Friend(
      {required this.id,
      required this.userId,
      required this.friendId,
      required this.friendName,
      required this.friendEmail,
      this.friendProfilePicture,
      this.friendJoinDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['friend_id'] = Variable<String>(friendId);
    map['friend_name'] = Variable<String>(friendName);
    map['friend_email'] = Variable<String>(friendEmail);
    if (!nullToAbsent || friendProfilePicture != null) {
      map['friend_profile_picture'] = Variable<String>(friendProfilePicture);
    }
    if (!nullToAbsent || friendJoinDate != null) {
      map['friend_join_date'] = Variable<String>(friendJoinDate);
    }
    return map;
  }

  FriendsCompanion toCompanion(bool nullToAbsent) {
    return FriendsCompanion(
      id: Value(id),
      userId: Value(userId),
      friendId: Value(friendId),
      friendName: Value(friendName),
      friendEmail: Value(friendEmail),
      friendProfilePicture: friendProfilePicture == null && nullToAbsent
          ? const Value.absent()
          : Value(friendProfilePicture),
      friendJoinDate: friendJoinDate == null && nullToAbsent
          ? const Value.absent()
          : Value(friendJoinDate),
    );
  }

  factory Friend.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Friend(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      friendId: serializer.fromJson<String>(json['friendId']),
      friendName: serializer.fromJson<String>(json['friendName']),
      friendEmail: serializer.fromJson<String>(json['friendEmail']),
      friendProfilePicture:
          serializer.fromJson<String?>(json['friendProfilePicture']),
      friendJoinDate: serializer.fromJson<String?>(json['friendJoinDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'friendId': serializer.toJson<String>(friendId),
      'friendName': serializer.toJson<String>(friendName),
      'friendEmail': serializer.toJson<String>(friendEmail),
      'friendProfilePicture': serializer.toJson<String?>(friendProfilePicture),
      'friendJoinDate': serializer.toJson<String?>(friendJoinDate),
    };
  }

  Friend copyWith(
          {int? id,
          String? userId,
          String? friendId,
          String? friendName,
          String? friendEmail,
          Value<String?> friendProfilePicture = const Value.absent(),
          Value<String?> friendJoinDate = const Value.absent()}) =>
      Friend(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        friendId: friendId ?? this.friendId,
        friendName: friendName ?? this.friendName,
        friendEmail: friendEmail ?? this.friendEmail,
        friendProfilePicture: friendProfilePicture.present
            ? friendProfilePicture.value
            : this.friendProfilePicture,
        friendJoinDate:
            friendJoinDate.present ? friendJoinDate.value : this.friendJoinDate,
      );
  Friend copyWithCompanion(FriendsCompanion data) {
    return Friend(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      friendId: data.friendId.present ? data.friendId.value : this.friendId,
      friendName:
          data.friendName.present ? data.friendName.value : this.friendName,
      friendEmail:
          data.friendEmail.present ? data.friendEmail.value : this.friendEmail,
      friendProfilePicture: data.friendProfilePicture.present
          ? data.friendProfilePicture.value
          : this.friendProfilePicture,
      friendJoinDate: data.friendJoinDate.present
          ? data.friendJoinDate.value
          : this.friendJoinDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Friend(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('friendId: $friendId, ')
          ..write('friendName: $friendName, ')
          ..write('friendEmail: $friendEmail, ')
          ..write('friendProfilePicture: $friendProfilePicture, ')
          ..write('friendJoinDate: $friendJoinDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, friendId, friendName, friendEmail,
      friendProfilePicture, friendJoinDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Friend &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.friendId == this.friendId &&
          other.friendName == this.friendName &&
          other.friendEmail == this.friendEmail &&
          other.friendProfilePicture == this.friendProfilePicture &&
          other.friendJoinDate == this.friendJoinDate);
}

class FriendsCompanion extends UpdateCompanion<Friend> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> friendId;
  final Value<String> friendName;
  final Value<String> friendEmail;
  final Value<String?> friendProfilePicture;
  final Value<String?> friendJoinDate;
  const FriendsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.friendId = const Value.absent(),
    this.friendName = const Value.absent(),
    this.friendEmail = const Value.absent(),
    this.friendProfilePicture = const Value.absent(),
    this.friendJoinDate = const Value.absent(),
  });
  FriendsCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required String friendId,
    required String friendName,
    required String friendEmail,
    this.friendProfilePicture = const Value.absent(),
    this.friendJoinDate = const Value.absent(),
  })  : userId = Value(userId),
        friendId = Value(friendId),
        friendName = Value(friendName),
        friendEmail = Value(friendEmail);
  static Insertable<Friend> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? friendId,
    Expression<String>? friendName,
    Expression<String>? friendEmail,
    Expression<String>? friendProfilePicture,
    Expression<String>? friendJoinDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (friendId != null) 'friend_id': friendId,
      if (friendName != null) 'friend_name': friendName,
      if (friendEmail != null) 'friend_email': friendEmail,
      if (friendProfilePicture != null)
        'friend_profile_picture': friendProfilePicture,
      if (friendJoinDate != null) 'friend_join_date': friendJoinDate,
    });
  }

  FriendsCompanion copyWith(
      {Value<int>? id,
      Value<String>? userId,
      Value<String>? friendId,
      Value<String>? friendName,
      Value<String>? friendEmail,
      Value<String?>? friendProfilePicture,
      Value<String?>? friendJoinDate}) {
    return FriendsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      friendId: friendId ?? this.friendId,
      friendName: friendName ?? this.friendName,
      friendEmail: friendEmail ?? this.friendEmail,
      friendProfilePicture: friendProfilePicture ?? this.friendProfilePicture,
      friendJoinDate: friendJoinDate ?? this.friendJoinDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (friendId.present) {
      map['friend_id'] = Variable<String>(friendId.value);
    }
    if (friendName.present) {
      map['friend_name'] = Variable<String>(friendName.value);
    }
    if (friendEmail.present) {
      map['friend_email'] = Variable<String>(friendEmail.value);
    }
    if (friendProfilePicture.present) {
      map['friend_profile_picture'] =
          Variable<String>(friendProfilePicture.value);
    }
    if (friendJoinDate.present) {
      map['friend_join_date'] = Variable<String>(friendJoinDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FriendsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('friendId: $friendId, ')
          ..write('friendName: $friendName, ')
          ..write('friendEmail: $friendEmail, ')
          ..write('friendProfilePicture: $friendProfilePicture, ')
          ..write('friendJoinDate: $friendJoinDate')
          ..write(')'))
        .toString();
  }
}

class $NotificationsTable extends Notifications
    with TableInfo<$NotificationsTable, Notification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dataJsonMeta =
      const VerificationMeta('dataJson');
  @override
  late final GeneratedColumn<String> dataJson = GeneratedColumn<String>(
      'data_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
      'is_read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_read" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, type, title, body, dataJson, isRead, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notifications';
  @override
  VerificationContext validateIntegrity(Insertable<Notification> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('data_json')) {
      context.handle(_dataJsonMeta,
          dataJson.isAcceptableOrUnknown(data['data_json']!, _dataJsonMeta));
    }
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta,
          isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Notification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Notification(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      dataJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data_json']),
      isRead: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_read'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at']),
    );
  }

  @override
  $NotificationsTable createAlias(String alias) {
    return $NotificationsTable(attachedDatabase, alias);
  }
}

class Notification extends DataClass implements Insertable<Notification> {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final String? dataJson;
  final bool isRead;
  final String? createdAt;
  const Notification(
      {required this.id,
      required this.userId,
      required this.type,
      required this.title,
      required this.body,
      this.dataJson,
      required this.isRead,
      this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || dataJson != null) {
      map['data_json'] = Variable<String>(dataJson);
    }
    map['is_read'] = Variable<bool>(isRead);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    return map;
  }

  NotificationsCompanion toCompanion(bool nullToAbsent) {
    return NotificationsCompanion(
      id: Value(id),
      userId: Value(userId),
      type: Value(type),
      title: Value(title),
      body: Value(body),
      dataJson: dataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(dataJson),
      isRead: Value(isRead),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory Notification.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Notification(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      dataJson: serializer.fromJson<String?>(json['dataJson']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'dataJson': serializer.toJson<String?>(dataJson),
      'isRead': serializer.toJson<bool>(isRead),
      'createdAt': serializer.toJson<String?>(createdAt),
    };
  }

  Notification copyWith(
          {String? id,
          String? userId,
          String? type,
          String? title,
          String? body,
          Value<String?> dataJson = const Value.absent(),
          bool? isRead,
          Value<String?> createdAt = const Value.absent()}) =>
      Notification(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        type: type ?? this.type,
        title: title ?? this.title,
        body: body ?? this.body,
        dataJson: dataJson.present ? dataJson.value : this.dataJson,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
      );
  Notification copyWithCompanion(NotificationsCompanion data) {
    return Notification(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      dataJson: data.dataJson.present ? data.dataJson.value : this.dataJson,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Notification(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('dataJson: $dataJson, ')
          ..write('isRead: $isRead, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, type, title, body, dataJson, isRead, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Notification &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.type == this.type &&
          other.title == this.title &&
          other.body == this.body &&
          other.dataJson == this.dataJson &&
          other.isRead == this.isRead &&
          other.createdAt == this.createdAt);
}

class NotificationsCompanion extends UpdateCompanion<Notification> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> type;
  final Value<String> title;
  final Value<String> body;
  final Value<String?> dataJson;
  final Value<bool> isRead;
  final Value<String?> createdAt;
  final Value<int> rowid;
  const NotificationsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.dataJson = const Value.absent(),
    this.isRead = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationsCompanion.insert({
    required String id,
    required String userId,
    required String type,
    required String title,
    required String body,
    this.dataJson = const Value.absent(),
    this.isRead = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        type = Value(type),
        title = Value(title),
        body = Value(body);
  static Insertable<Notification> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? dataJson,
    Expression<bool>? isRead,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (dataJson != null) 'data_json': dataJson,
      if (isRead != null) 'is_read': isRead,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? type,
      Value<String>? title,
      Value<String>? body,
      Value<String?>? dataJson,
      Value<bool>? isRead,
      Value<String?>? createdAt,
      Value<int>? rowid}) {
    return NotificationsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      dataJson: dataJson ?? this.dataJson,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (dataJson.present) {
      map['data_json'] = Variable<String>(dataJson.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('dataJson: $dataJson, ')
          ..write('isRead: $isRead, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $UserStatsTable userStats = $UserStatsTable(this);
  late final $IngredientsTable ingredients = $IngredientsTable(this);
  late final $FridgeIngredientsTable fridgeIngredients =
      $FridgeIngredientsTable(this);
  late final $RecipesTable recipes = $RecipesTable(this);
  late final $SharedRecipesTable sharedRecipes = $SharedRecipesTable(this);
  late final $FriendsTable friends = $FriendsTable(this);
  late final $NotificationsTable notifications = $NotificationsTable(this);
  late final UserDao userDao = UserDao(this as AppDatabase);
  late final UserStatsDao userStatsDao = UserStatsDao(this as AppDatabase);
  late final IngredientDao ingredientDao = IngredientDao(this as AppDatabase);
  late final FridgeIngredientDao fridgeIngredientDao =
      FridgeIngredientDao(this as AppDatabase);
  late final RecipeDao recipeDao = RecipeDao(this as AppDatabase);
  late final SharedRecipeDao sharedRecipeDao =
      SharedRecipeDao(this as AppDatabase);
  late final FriendDao friendDao = FriendDao(this as AppDatabase);
  late final NotificationDao notificationDao =
      NotificationDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        users,
        userStats,
        ingredients,
        fridgeIngredients,
        recipes,
        sharedRecipes,
        friends,
        notifications
      ];
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
typedef $$UserStatsTableCreateCompanionBuilder = UserStatsCompanion Function({
  required String userId,
  Value<int?> ingredientCount,
  Value<int?> recipeCount,
  Value<int?> favoriteRecipeCount,
  Value<int?> friendCount,
  Value<String?> mostPopularIngredients,
  Value<int> rowid,
});
typedef $$UserStatsTableUpdateCompanionBuilder = UserStatsCompanion Function({
  Value<String> userId,
  Value<int?> ingredientCount,
  Value<int?> recipeCount,
  Value<int?> favoriteRecipeCount,
  Value<int?> friendCount,
  Value<String?> mostPopularIngredients,
  Value<int> rowid,
});

class $$UserStatsTableFilterComposer
    extends Composer<_$AppDatabase, $UserStatsTable> {
  $$UserStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ingredientCount => $composableBuilder(
      column: $table.ingredientCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recipeCount => $composableBuilder(
      column: $table.recipeCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get favoriteRecipeCount => $composableBuilder(
      column: $table.favoriteRecipeCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get friendCount => $composableBuilder(
      column: $table.friendCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mostPopularIngredients => $composableBuilder(
      column: $table.mostPopularIngredients,
      builder: (column) => ColumnFilters(column));
}

class $$UserStatsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserStatsTable> {
  $$UserStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ingredientCount => $composableBuilder(
      column: $table.ingredientCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recipeCount => $composableBuilder(
      column: $table.recipeCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get favoriteRecipeCount => $composableBuilder(
      column: $table.favoriteRecipeCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get friendCount => $composableBuilder(
      column: $table.friendCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mostPopularIngredients => $composableBuilder(
      column: $table.mostPopularIngredients,
      builder: (column) => ColumnOrderings(column));
}

class $$UserStatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserStatsTable> {
  $$UserStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get ingredientCount => $composableBuilder(
      column: $table.ingredientCount, builder: (column) => column);

  GeneratedColumn<int> get recipeCount => $composableBuilder(
      column: $table.recipeCount, builder: (column) => column);

  GeneratedColumn<int> get favoriteRecipeCount => $composableBuilder(
      column: $table.favoriteRecipeCount, builder: (column) => column);

  GeneratedColumn<int> get friendCount => $composableBuilder(
      column: $table.friendCount, builder: (column) => column);

  GeneratedColumn<String> get mostPopularIngredients => $composableBuilder(
      column: $table.mostPopularIngredients, builder: (column) => column);
}

class $$UserStatsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserStatsTable,
    UserStat,
    $$UserStatsTableFilterComposer,
    $$UserStatsTableOrderingComposer,
    $$UserStatsTableAnnotationComposer,
    $$UserStatsTableCreateCompanionBuilder,
    $$UserStatsTableUpdateCompanionBuilder,
    (UserStat, BaseReferences<_$AppDatabase, $UserStatsTable, UserStat>),
    UserStat,
    PrefetchHooks Function()> {
  $$UserStatsTableTableManager(_$AppDatabase db, $UserStatsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserStatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> userId = const Value.absent(),
            Value<int?> ingredientCount = const Value.absent(),
            Value<int?> recipeCount = const Value.absent(),
            Value<int?> favoriteRecipeCount = const Value.absent(),
            Value<int?> friendCount = const Value.absent(),
            Value<String?> mostPopularIngredients = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserStatsCompanion(
            userId: userId,
            ingredientCount: ingredientCount,
            recipeCount: recipeCount,
            favoriteRecipeCount: favoriteRecipeCount,
            friendCount: friendCount,
            mostPopularIngredients: mostPopularIngredients,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String userId,
            Value<int?> ingredientCount = const Value.absent(),
            Value<int?> recipeCount = const Value.absent(),
            Value<int?> favoriteRecipeCount = const Value.absent(),
            Value<int?> friendCount = const Value.absent(),
            Value<String?> mostPopularIngredients = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserStatsCompanion.insert(
            userId: userId,
            ingredientCount: ingredientCount,
            recipeCount: recipeCount,
            favoriteRecipeCount: favoriteRecipeCount,
            friendCount: friendCount,
            mostPopularIngredients: mostPopularIngredients,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserStatsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserStatsTable,
    UserStat,
    $$UserStatsTableFilterComposer,
    $$UserStatsTableOrderingComposer,
    $$UserStatsTableAnnotationComposer,
    $$UserStatsTableCreateCompanionBuilder,
    $$UserStatsTableUpdateCompanionBuilder,
    (UserStat, BaseReferences<_$AppDatabase, $UserStatsTable, UserStat>),
    UserStat,
    PrefetchHooks Function()>;
typedef $$IngredientsTableCreateCompanionBuilder = IngredientsCompanion
    Function({
  required String id,
  required String name,
  Value<String?> category,
  Value<String?> imageURL,
  Value<int> rowid,
});
typedef $$IngredientsTableUpdateCompanionBuilder = IngredientsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> category,
  Value<String?> imageURL,
  Value<int> rowid,
});

class $$IngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageURL => $composableBuilder(
      column: $table.imageURL, builder: (column) => ColumnFilters(column));
}

class $$IngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageURL => $composableBuilder(
      column: $table.imageURL, builder: (column) => ColumnOrderings(column));
}

class $$IngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get imageURL =>
      $composableBuilder(column: $table.imageURL, builder: (column) => column);
}

class $$IngredientsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $IngredientsTable,
    Ingredient,
    $$IngredientsTableFilterComposer,
    $$IngredientsTableOrderingComposer,
    $$IngredientsTableAnnotationComposer,
    $$IngredientsTableCreateCompanionBuilder,
    $$IngredientsTableUpdateCompanionBuilder,
    (Ingredient, BaseReferences<_$AppDatabase, $IngredientsTable, Ingredient>),
    Ingredient,
    PrefetchHooks Function()> {
  $$IngredientsTableTableManager(_$AppDatabase db, $IngredientsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IngredientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> imageURL = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              IngredientsCompanion(
            id: id,
            name: name,
            category: category,
            imageURL: imageURL,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> category = const Value.absent(),
            Value<String?> imageURL = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              IngredientsCompanion.insert(
            id: id,
            name: name,
            category: category,
            imageURL: imageURL,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$IngredientsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $IngredientsTable,
    Ingredient,
    $$IngredientsTableFilterComposer,
    $$IngredientsTableOrderingComposer,
    $$IngredientsTableAnnotationComposer,
    $$IngredientsTableCreateCompanionBuilder,
    $$IngredientsTableUpdateCompanionBuilder,
    (Ingredient, BaseReferences<_$AppDatabase, $IngredientsTable, Ingredient>),
    Ingredient,
    PrefetchHooks Function()>;
typedef $$FridgeIngredientsTableCreateCompanionBuilder
    = FridgeIngredientsCompanion Function({
  required String id,
  required String name,
  Value<String?> category,
  Value<int> count,
  Value<String?> imageURL,
  Value<bool> isInFridge,
  Value<String?> fridgeId,
  Value<int> rowid,
});
typedef $$FridgeIngredientsTableUpdateCompanionBuilder
    = FridgeIngredientsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> category,
  Value<int> count,
  Value<String?> imageURL,
  Value<bool> isInFridge,
  Value<String?> fridgeId,
  Value<int> rowid,
});

class $$FridgeIngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $FridgeIngredientsTable> {
  $$FridgeIngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get count => $composableBuilder(
      column: $table.count, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageURL => $composableBuilder(
      column: $table.imageURL, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isInFridge => $composableBuilder(
      column: $table.isInFridge, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fridgeId => $composableBuilder(
      column: $table.fridgeId, builder: (column) => ColumnFilters(column));
}

class $$FridgeIngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $FridgeIngredientsTable> {
  $$FridgeIngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get count => $composableBuilder(
      column: $table.count, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageURL => $composableBuilder(
      column: $table.imageURL, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isInFridge => $composableBuilder(
      column: $table.isInFridge, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fridgeId => $composableBuilder(
      column: $table.fridgeId, builder: (column) => ColumnOrderings(column));
}

class $$FridgeIngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FridgeIngredientsTable> {
  $$FridgeIngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<String> get imageURL =>
      $composableBuilder(column: $table.imageURL, builder: (column) => column);

  GeneratedColumn<bool> get isInFridge => $composableBuilder(
      column: $table.isInFridge, builder: (column) => column);

  GeneratedColumn<String> get fridgeId =>
      $composableBuilder(column: $table.fridgeId, builder: (column) => column);
}

class $$FridgeIngredientsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FridgeIngredientsTable,
    FridgeIngredient,
    $$FridgeIngredientsTableFilterComposer,
    $$FridgeIngredientsTableOrderingComposer,
    $$FridgeIngredientsTableAnnotationComposer,
    $$FridgeIngredientsTableCreateCompanionBuilder,
    $$FridgeIngredientsTableUpdateCompanionBuilder,
    (
      FridgeIngredient,
      BaseReferences<_$AppDatabase, $FridgeIngredientsTable, FridgeIngredient>
    ),
    FridgeIngredient,
    PrefetchHooks Function()> {
  $$FridgeIngredientsTableTableManager(
      _$AppDatabase db, $FridgeIngredientsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FridgeIngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FridgeIngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FridgeIngredientsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<int> count = const Value.absent(),
            Value<String?> imageURL = const Value.absent(),
            Value<bool> isInFridge = const Value.absent(),
            Value<String?> fridgeId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FridgeIngredientsCompanion(
            id: id,
            name: name,
            category: category,
            count: count,
            imageURL: imageURL,
            isInFridge: isInFridge,
            fridgeId: fridgeId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> category = const Value.absent(),
            Value<int> count = const Value.absent(),
            Value<String?> imageURL = const Value.absent(),
            Value<bool> isInFridge = const Value.absent(),
            Value<String?> fridgeId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FridgeIngredientsCompanion.insert(
            id: id,
            name: name,
            category: category,
            count: count,
            imageURL: imageURL,
            isInFridge: isInFridge,
            fridgeId: fridgeId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FridgeIngredientsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FridgeIngredientsTable,
    FridgeIngredient,
    $$FridgeIngredientsTableFilterComposer,
    $$FridgeIngredientsTableOrderingComposer,
    $$FridgeIngredientsTableAnnotationComposer,
    $$FridgeIngredientsTableCreateCompanionBuilder,
    $$FridgeIngredientsTableUpdateCompanionBuilder,
    (
      FridgeIngredient,
      BaseReferences<_$AppDatabase, $FridgeIngredientsTable, FridgeIngredient>
    ),
    FridgeIngredient,
    PrefetchHooks Function()>;
typedef $$RecipesTableCreateCompanionBuilder = RecipesCompanion Function({
  required String id,
  required String userId,
  required String title,
  required String description,
  required String mealType,
  required String cuisineType,
  required String difficulty,
  required int prepTime,
  required int cookingTime,
  required String ingredientsJson,
  required String instructionsJson,
  Value<String?> imageURL,
  Value<double?> rating,
  Value<bool> isFavorite,
  required String source,
  Value<int> order,
  Value<int> rowid,
});
typedef $$RecipesTableUpdateCompanionBuilder = RecipesCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> title,
  Value<String> description,
  Value<String> mealType,
  Value<String> cuisineType,
  Value<String> difficulty,
  Value<int> prepTime,
  Value<int> cookingTime,
  Value<String> ingredientsJson,
  Value<String> instructionsJson,
  Value<String?> imageURL,
  Value<double?> rating,
  Value<bool> isFavorite,
  Value<String> source,
  Value<int> order,
  Value<int> rowid,
});

class $$RecipesTableFilterComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mealType => $composableBuilder(
      column: $table.mealType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cuisineType => $composableBuilder(
      column: $table.cuisineType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get prepTime => $composableBuilder(
      column: $table.prepTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cookingTime => $composableBuilder(
      column: $table.cookingTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ingredientsJson => $composableBuilder(
      column: $table.ingredientsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get instructionsJson => $composableBuilder(
      column: $table.instructionsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageURL => $composableBuilder(
      column: $table.imageURL, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnFilters(column));
}

class $$RecipesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mealType => $composableBuilder(
      column: $table.mealType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cuisineType => $composableBuilder(
      column: $table.cuisineType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get prepTime => $composableBuilder(
      column: $table.prepTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cookingTime => $composableBuilder(
      column: $table.cookingTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ingredientsJson => $composableBuilder(
      column: $table.ingredientsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get instructionsJson => $composableBuilder(
      column: $table.instructionsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageURL => $composableBuilder(
      column: $table.imageURL, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnOrderings(column));
}

class $$RecipesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get mealType =>
      $composableBuilder(column: $table.mealType, builder: (column) => column);

  GeneratedColumn<String> get cuisineType => $composableBuilder(
      column: $table.cuisineType, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<int> get prepTime =>
      $composableBuilder(column: $table.prepTime, builder: (column) => column);

  GeneratedColumn<int> get cookingTime => $composableBuilder(
      column: $table.cookingTime, builder: (column) => column);

  GeneratedColumn<String> get ingredientsJson => $composableBuilder(
      column: $table.ingredientsJson, builder: (column) => column);

  GeneratedColumn<String> get instructionsJson => $composableBuilder(
      column: $table.instructionsJson, builder: (column) => column);

  GeneratedColumn<String> get imageURL =>
      $composableBuilder(column: $table.imageURL, builder: (column) => column);

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);
}

class $$RecipesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecipesTable,
    Recipe,
    $$RecipesTableFilterComposer,
    $$RecipesTableOrderingComposer,
    $$RecipesTableAnnotationComposer,
    $$RecipesTableCreateCompanionBuilder,
    $$RecipesTableUpdateCompanionBuilder,
    (Recipe, BaseReferences<_$AppDatabase, $RecipesTable, Recipe>),
    Recipe,
    PrefetchHooks Function()> {
  $$RecipesTableTableManager(_$AppDatabase db, $RecipesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> mealType = const Value.absent(),
            Value<String> cuisineType = const Value.absent(),
            Value<String> difficulty = const Value.absent(),
            Value<int> prepTime = const Value.absent(),
            Value<int> cookingTime = const Value.absent(),
            Value<String> ingredientsJson = const Value.absent(),
            Value<String> instructionsJson = const Value.absent(),
            Value<String?> imageURL = const Value.absent(),
            Value<double?> rating = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<int> order = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecipesCompanion(
            id: id,
            userId: userId,
            title: title,
            description: description,
            mealType: mealType,
            cuisineType: cuisineType,
            difficulty: difficulty,
            prepTime: prepTime,
            cookingTime: cookingTime,
            ingredientsJson: ingredientsJson,
            instructionsJson: instructionsJson,
            imageURL: imageURL,
            rating: rating,
            isFavorite: isFavorite,
            source: source,
            order: order,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String title,
            required String description,
            required String mealType,
            required String cuisineType,
            required String difficulty,
            required int prepTime,
            required int cookingTime,
            required String ingredientsJson,
            required String instructionsJson,
            Value<String?> imageURL = const Value.absent(),
            Value<double?> rating = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            required String source,
            Value<int> order = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecipesCompanion.insert(
            id: id,
            userId: userId,
            title: title,
            description: description,
            mealType: mealType,
            cuisineType: cuisineType,
            difficulty: difficulty,
            prepTime: prepTime,
            cookingTime: cookingTime,
            ingredientsJson: ingredientsJson,
            instructionsJson: instructionsJson,
            imageURL: imageURL,
            rating: rating,
            isFavorite: isFavorite,
            source: source,
            order: order,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RecipesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecipesTable,
    Recipe,
    $$RecipesTableFilterComposer,
    $$RecipesTableOrderingComposer,
    $$RecipesTableAnnotationComposer,
    $$RecipesTableCreateCompanionBuilder,
    $$RecipesTableUpdateCompanionBuilder,
    (Recipe, BaseReferences<_$AppDatabase, $RecipesTable, Recipe>),
    Recipe,
    PrefetchHooks Function()>;
typedef $$SharedRecipesTableCreateCompanionBuilder = SharedRecipesCompanion
    Function({
  required String id,
  required String recipeId,
  required String fromUser,
  required String toUser,
  required String sharedAt,
  Value<String> status,
  Value<int> rowid,
});
typedef $$SharedRecipesTableUpdateCompanionBuilder = SharedRecipesCompanion
    Function({
  Value<String> id,
  Value<String> recipeId,
  Value<String> fromUser,
  Value<String> toUser,
  Value<String> sharedAt,
  Value<String> status,
  Value<int> rowid,
});

class $$SharedRecipesTableFilterComposer
    extends Composer<_$AppDatabase, $SharedRecipesTable> {
  $$SharedRecipesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recipeId => $composableBuilder(
      column: $table.recipeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fromUser => $composableBuilder(
      column: $table.fromUser, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get toUser => $composableBuilder(
      column: $table.toUser, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sharedAt => $composableBuilder(
      column: $table.sharedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$SharedRecipesTableOrderingComposer
    extends Composer<_$AppDatabase, $SharedRecipesTable> {
  $$SharedRecipesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recipeId => $composableBuilder(
      column: $table.recipeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fromUser => $composableBuilder(
      column: $table.fromUser, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get toUser => $composableBuilder(
      column: $table.toUser, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sharedAt => $composableBuilder(
      column: $table.sharedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$SharedRecipesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SharedRecipesTable> {
  $$SharedRecipesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<String> get fromUser =>
      $composableBuilder(column: $table.fromUser, builder: (column) => column);

  GeneratedColumn<String> get toUser =>
      $composableBuilder(column: $table.toUser, builder: (column) => column);

  GeneratedColumn<String> get sharedAt =>
      $composableBuilder(column: $table.sharedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$SharedRecipesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SharedRecipesTable,
    SharedRecipe,
    $$SharedRecipesTableFilterComposer,
    $$SharedRecipesTableOrderingComposer,
    $$SharedRecipesTableAnnotationComposer,
    $$SharedRecipesTableCreateCompanionBuilder,
    $$SharedRecipesTableUpdateCompanionBuilder,
    (
      SharedRecipe,
      BaseReferences<_$AppDatabase, $SharedRecipesTable, SharedRecipe>
    ),
    SharedRecipe,
    PrefetchHooks Function()> {
  $$SharedRecipesTableTableManager(_$AppDatabase db, $SharedRecipesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SharedRecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SharedRecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SharedRecipesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> recipeId = const Value.absent(),
            Value<String> fromUser = const Value.absent(),
            Value<String> toUser = const Value.absent(),
            Value<String> sharedAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SharedRecipesCompanion(
            id: id,
            recipeId: recipeId,
            fromUser: fromUser,
            toUser: toUser,
            sharedAt: sharedAt,
            status: status,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String recipeId,
            required String fromUser,
            required String toUser,
            required String sharedAt,
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SharedRecipesCompanion.insert(
            id: id,
            recipeId: recipeId,
            fromUser: fromUser,
            toUser: toUser,
            sharedAt: sharedAt,
            status: status,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SharedRecipesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SharedRecipesTable,
    SharedRecipe,
    $$SharedRecipesTableFilterComposer,
    $$SharedRecipesTableOrderingComposer,
    $$SharedRecipesTableAnnotationComposer,
    $$SharedRecipesTableCreateCompanionBuilder,
    $$SharedRecipesTableUpdateCompanionBuilder,
    (
      SharedRecipe,
      BaseReferences<_$AppDatabase, $SharedRecipesTable, SharedRecipe>
    ),
    SharedRecipe,
    PrefetchHooks Function()>;
typedef $$FriendsTableCreateCompanionBuilder = FriendsCompanion Function({
  Value<int> id,
  required String userId,
  required String friendId,
  required String friendName,
  required String friendEmail,
  Value<String?> friendProfilePicture,
  Value<String?> friendJoinDate,
});
typedef $$FriendsTableUpdateCompanionBuilder = FriendsCompanion Function({
  Value<int> id,
  Value<String> userId,
  Value<String> friendId,
  Value<String> friendName,
  Value<String> friendEmail,
  Value<String?> friendProfilePicture,
  Value<String?> friendJoinDate,
});

class $$FriendsTableFilterComposer
    extends Composer<_$AppDatabase, $FriendsTable> {
  $$FriendsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get friendId => $composableBuilder(
      column: $table.friendId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get friendName => $composableBuilder(
      column: $table.friendName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get friendEmail => $composableBuilder(
      column: $table.friendEmail, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get friendProfilePicture => $composableBuilder(
      column: $table.friendProfilePicture,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get friendJoinDate => $composableBuilder(
      column: $table.friendJoinDate,
      builder: (column) => ColumnFilters(column));
}

class $$FriendsTableOrderingComposer
    extends Composer<_$AppDatabase, $FriendsTable> {
  $$FriendsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get friendId => $composableBuilder(
      column: $table.friendId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get friendName => $composableBuilder(
      column: $table.friendName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get friendEmail => $composableBuilder(
      column: $table.friendEmail, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get friendProfilePicture => $composableBuilder(
      column: $table.friendProfilePicture,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get friendJoinDate => $composableBuilder(
      column: $table.friendJoinDate,
      builder: (column) => ColumnOrderings(column));
}

class $$FriendsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FriendsTable> {
  $$FriendsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get friendId =>
      $composableBuilder(column: $table.friendId, builder: (column) => column);

  GeneratedColumn<String> get friendName => $composableBuilder(
      column: $table.friendName, builder: (column) => column);

  GeneratedColumn<String> get friendEmail => $composableBuilder(
      column: $table.friendEmail, builder: (column) => column);

  GeneratedColumn<String> get friendProfilePicture => $composableBuilder(
      column: $table.friendProfilePicture, builder: (column) => column);

  GeneratedColumn<String> get friendJoinDate => $composableBuilder(
      column: $table.friendJoinDate, builder: (column) => column);
}

class $$FriendsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FriendsTable,
    Friend,
    $$FriendsTableFilterComposer,
    $$FriendsTableOrderingComposer,
    $$FriendsTableAnnotationComposer,
    $$FriendsTableCreateCompanionBuilder,
    $$FriendsTableUpdateCompanionBuilder,
    (Friend, BaseReferences<_$AppDatabase, $FriendsTable, Friend>),
    Friend,
    PrefetchHooks Function()> {
  $$FriendsTableTableManager(_$AppDatabase db, $FriendsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FriendsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FriendsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FriendsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> friendId = const Value.absent(),
            Value<String> friendName = const Value.absent(),
            Value<String> friendEmail = const Value.absent(),
            Value<String?> friendProfilePicture = const Value.absent(),
            Value<String?> friendJoinDate = const Value.absent(),
          }) =>
              FriendsCompanion(
            id: id,
            userId: userId,
            friendId: friendId,
            friendName: friendName,
            friendEmail: friendEmail,
            friendProfilePicture: friendProfilePicture,
            friendJoinDate: friendJoinDate,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String userId,
            required String friendId,
            required String friendName,
            required String friendEmail,
            Value<String?> friendProfilePicture = const Value.absent(),
            Value<String?> friendJoinDate = const Value.absent(),
          }) =>
              FriendsCompanion.insert(
            id: id,
            userId: userId,
            friendId: friendId,
            friendName: friendName,
            friendEmail: friendEmail,
            friendProfilePicture: friendProfilePicture,
            friendJoinDate: friendJoinDate,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FriendsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FriendsTable,
    Friend,
    $$FriendsTableFilterComposer,
    $$FriendsTableOrderingComposer,
    $$FriendsTableAnnotationComposer,
    $$FriendsTableCreateCompanionBuilder,
    $$FriendsTableUpdateCompanionBuilder,
    (Friend, BaseReferences<_$AppDatabase, $FriendsTable, Friend>),
    Friend,
    PrefetchHooks Function()>;
typedef $$NotificationsTableCreateCompanionBuilder = NotificationsCompanion
    Function({
  required String id,
  required String userId,
  required String type,
  required String title,
  required String body,
  Value<String?> dataJson,
  Value<bool> isRead,
  Value<String?> createdAt,
  Value<int> rowid,
});
typedef $$NotificationsTableUpdateCompanionBuilder = NotificationsCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<String> type,
  Value<String> title,
  Value<String> body,
  Value<String?> dataJson,
  Value<bool> isRead,
  Value<String?> createdAt,
  Value<int> rowid,
});

class $$NotificationsTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dataJson => $composableBuilder(
      column: $table.dataJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$NotificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dataJson => $composableBuilder(
      column: $table.dataJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$NotificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationsTable> {
  $$NotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get dataJson =>
      $composableBuilder(column: $table.dataJson, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$NotificationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NotificationsTable,
    Notification,
    $$NotificationsTableFilterComposer,
    $$NotificationsTableOrderingComposer,
    $$NotificationsTableAnnotationComposer,
    $$NotificationsTableCreateCompanionBuilder,
    $$NotificationsTableUpdateCompanionBuilder,
    (
      Notification,
      BaseReferences<_$AppDatabase, $NotificationsTable, Notification>
    ),
    Notification,
    PrefetchHooks Function()> {
  $$NotificationsTableTableManager(_$AppDatabase db, $NotificationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<String?> dataJson = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<String?> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NotificationsCompanion(
            id: id,
            userId: userId,
            type: type,
            title: title,
            body: body,
            dataJson: dataJson,
            isRead: isRead,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String type,
            required String title,
            required String body,
            Value<String?> dataJson = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<String?> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NotificationsCompanion.insert(
            id: id,
            userId: userId,
            type: type,
            title: title,
            body: body,
            dataJson: dataJson,
            isRead: isRead,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NotificationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NotificationsTable,
    Notification,
    $$NotificationsTableFilterComposer,
    $$NotificationsTableOrderingComposer,
    $$NotificationsTableAnnotationComposer,
    $$NotificationsTableCreateCompanionBuilder,
    $$NotificationsTableUpdateCompanionBuilder,
    (
      Notification,
      BaseReferences<_$AppDatabase, $NotificationsTable, Notification>
    ),
    Notification,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$UserStatsTableTableManager get userStats =>
      $$UserStatsTableTableManager(_db, _db.userStats);
  $$IngredientsTableTableManager get ingredients =>
      $$IngredientsTableTableManager(_db, _db.ingredients);
  $$FridgeIngredientsTableTableManager get fridgeIngredients =>
      $$FridgeIngredientsTableTableManager(_db, _db.fridgeIngredients);
  $$RecipesTableTableManager get recipes =>
      $$RecipesTableTableManager(_db, _db.recipes);
  $$SharedRecipesTableTableManager get sharedRecipes =>
      $$SharedRecipesTableTableManager(_db, _db.sharedRecipes);
  $$FriendsTableTableManager get friends =>
      $$FriendsTableTableManager(_db, _db.friends);
  $$NotificationsTableTableManager get notifications =>
      $$NotificationsTableTableManager(_db, _db.notifications);
}
