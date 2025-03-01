library server;

import 'dart:async';

import 'package:nanoid/nanoid.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import 'model.dart';

part 'db_script.dart';

const idAlphabet = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
final DateFormat parseDt = DateFormat('dd/MM/yy hh:mm:ss');

class Server {
  final Database db;
  Server._(this.db);

  static Future<Server> init() async {
    // await Future.delayed(const Duration(seconds: 1));
    await GetStorage.init();
    final directory = await getApplicationCacheDirectory();
    const dbName = 'econnect.db';
    final dbPath = path.join(directory.path, dbName);
    sqfliteFfiInit();
    var database = await databaseFactoryFfi.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _initTable,
      ),
    );
    return Server._(database);
  }

  static FutureOr<void> _initTable(Database db, int version) async {
    for (String sql in DATABASE_TABLE_SCRIPT) {
      await db.execute(sql);
    }
  }

  Future<bool> setConfiguration(Configuration configuration) async {
    var data = configuration.toMap();
    final result = await db.insert(
      'configuration',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return result > 0;
  }

  Future<Configuration?> getConfiguration() async {
    final result = await db.query(
      'configuration',
      where: 'id = ?',
      whereArgs: [1],
    );
    if (result.isNotEmpty) {
      var configuration = Configuration.fromMap(result.first);
      return configuration;
    }
    return null;
  }

  Future<bool> setSettings(Settings settings) async {
    var data = settings.toMap();
    final result = await db.insert(
      'settings',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return result > 0;
  }

  Future<Settings?> getSettings() async {
    final result = await db.query(
      'settings',
      where: 'id = ?',
      whereArgs: [1],
    );
    if (result.isNotEmpty) {
      var settings = Settings.fromMap(result.first);
      return settings;
    }
    return null;
  }

  Future<List<BankTransaction>> getIncompleteBankTransaction() async {
    final result = await db.query(
      'bank_transaction',
      where: 'completed = ?',
      whereArgs: [0],
    );
    List<BankTransaction> bankTransactions = [];
    if (result.isNotEmpty) {
      for (var res in result) {
        var btxn = BankTransaction.fromMap(res);
        bankTransactions.add(btxn);
      }
    }
    return bankTransactions;
  }

  Future<bool> resetSendToBank(
    List<TallyTransaction> tallyTransactions,
  ) async {
    var ids = tallyTransactions
        .map((e) => "'${e.id.toUpperCase()}'")
        .toList()
        .join(",");
    var result = await db.rawDelete(
      'delete from bank_transaction where id in ($ids)',
    );
    return result > 0;
  }

  Future<bool> sendToBank(
    List<TallyTransaction> tallyTransactions,
    String bankAcNo,
    Settings setting,
    Configuration configuration,
  ) async {
    // print(tallyTransactions.length);

    final totalAmount = tallyTransactions.fold(0.0, (s, x) => s + x.amount);
    final String reqRefNum = customAlphabet(idAlphabet, 12);
    final String requestTimeStamp = parseDt.format(DateTime.now());
    final txnDetails =
        TxnDetail.buildDetails(tallyTransactions, reqRefNum, bankAcNo);
    final sendToBankData = SendToBankData(
      uniqueUserId: configuration.userId,
      userPassword: configuration.password,
      makerId: configuration.makerId,
      totalNoEntries: tallyTransactions.length.toString(),
      totalAmount: totalAmount.toStringAsFixed(2),
      requestTimeStamp: requestTimeStamp,
      reqRefNum: reqRefNum,
      txnDetails: txnDetails,
    );
    List<BankTransaction> bankTransactions =
        BankTransaction.build(sendToBankData);
    final String apiInput = sendToBankData.toJson();
    print('apiInput: $apiInput');

    // Store data in sqlite
    for (var txn in bankTransactions) {
      var data = txn.toMap();
      await db.insert(
        'bank_transaction',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    return true;
  }
}
