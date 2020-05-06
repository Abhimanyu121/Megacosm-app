// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DBHelper.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String name;

  final List<Migration> _migrations = [];

  Callback _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? join(await sqflite.getDatabasesPath(), name)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String> listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  NetworkDao _networkDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback callback]) async {
    return sqflite.openDatabase(
      path,
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Network` (`name` TEXT, `url` TEXT, `denom` TEXT, `active` INTEGER, `nick` TEXT, PRIMARY KEY (`url`))');

        await callback?.onCreate?.call(database, version);
      },
    );
  }

  @override
  NetworkDao get networkDao {
    return _networkDaoInstance ??= _$NetworkDao(database, changeListener);
  }
}

class _$NetworkDao extends NetworkDao {
  _$NetworkDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _networkInsertionAdapter = InsertionAdapter(
            database,
            'Network',
            (Network item) => <String, dynamic>{
                  'name': item.name,
                  'url': item.url,
                  'denom': item.denom,
                  'active': item.active ? 1 : 0,
                  'nick': item.nick
                },
            changeListener),
        _networkUpdateAdapter = UpdateAdapter(
            database,
            'Network',
            ['url'],
            (Network item) => <String, dynamic>{
                  'name': item.name,
                  'url': item.url,
                  'denom': item.denom,
                  'active': item.active ? 1 : 0,
                  'nick': item.nick
                },
            changeListener),
        _networkDeletionAdapter = DeletionAdapter(
            database,
            'Network',
            ['url'],
            (Network item) => <String, dynamic>{
                  'name': item.name,
                  'url': item.url,
                  'denom': item.denom,
                  'active': item.active ? 1 : 0,
                  'nick': item.nick
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _networkMapper = (Map<String, dynamic> row) => Network(
      row['name'] as String,
      row['url'] as String,
      row['denom'] as String,
      row['nick'] as String,
      (row['active'] as int) != 0);

  final InsertionAdapter<Network> _networkInsertionAdapter;

  final UpdateAdapter<Network> _networkUpdateAdapter;

  final DeletionAdapter<Network> _networkDeletionAdapter;

  @override
  Future<List<Network>> allNetworks() async {
    return _queryAdapter.queryList('SELECT * FROM Network',
        mapper: _networkMapper);
  }

  @override
  Stream<Network> findNetworkById(int id) {
    return _queryAdapter.queryStream('SELECT * FROM Network WHERE id = ?',
        arguments: <dynamic>[id], tableName: 'Network', mapper: _networkMapper);
  }

  @override
  Future<List<Network>> findActiveNetwork() async {
    return _queryAdapter.queryList('SELECT * FROM Network WHERE active = 1',
        mapper: _networkMapper);
  }

  @override
  Future<void> insertNetwork(Network network) async {
    await _networkInsertionAdapter.insert(
        network, sqflite.ConflictAlgorithm.abort);
  }

  @override
  Future<void> insertNetworkList(List<Network> network) async {
    await _networkInsertionAdapter.insertList(
        network, sqflite.ConflictAlgorithm.abort);
  }

  @override
  Future<int> updateNetwork(List<Network> networks) {
    return _networkUpdateAdapter.updateListAndReturnChangedRows(
        networks, sqflite.ConflictAlgorithm.abort);
  }

  @override
  Future<int> deleteNetworks(List<Network> network) {
    return _networkDeletionAdapter.deleteListAndReturnChangedRows(network);
  }
}
