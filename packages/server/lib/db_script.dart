// ignore_for_file: constant_identifier_names

part of 'server.dart';

const List<String> DATABASE_TABLE_SCRIPT = [
  '''CREATE TABLE configuration (
    id INT PRIMARY KEY,
    accountNumber TEXT,
    accountName TEXT,
    corporateId TEXT,
    makerId TEXT,
    userId TEXT,
    password TEXT
  );''',
  '''CREATE TABLE settings (
    id INT PRIMARY KEY,
    recordsPerPage INT,
    oauthUrl TEXT,
    statusUrl TEXT,
    paymentUrl TEXT,
    publicKey TEXT,
    privateKey TEXT
  );''',
  '''CREATE TABLE bank_transaction (
    id TEXT PRIMARY KEY,
    reqRefNum TEXT,
    status TEXT,
    completed INT,
    reason TEXT,
    txnDate TEXT,
    particulars TEXT,
    txnAmt DECIMAL(12,2)
  );''',
  '''INSERT INTO configuration(id) VALUES(1);''',
  '''INSERT INTO settings(id, recordsPerPage) VALUES(1, 25);''',
];
