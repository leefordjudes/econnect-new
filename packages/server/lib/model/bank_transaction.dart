// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'txn_status.dart';
import 'send_to_bank_data.dart';

class BankTransaction {
  final String id;
  final String reqRefNum;
  final TxnStatus status;
  final bool completed;
  final String reason;
  final String txnDate;
  final String particulars;
  final num txnAmt;

  BankTransaction({
    required this.id,
    required this.reqRefNum,
    required this.status,
    required this.completed,
    required this.reason,
    required this.txnDate,
    required this.particulars,
    required this.txnAmt,
  });

  static List<BankTransaction> build(SendToBankData data) {
    List<BankTransaction> txns = [];
    for (var d in data.txnDetails) {
      var txn = BankTransaction(
        id: d.id,
        reqRefNum: data.reqRefNum,
        status: d.status,
        completed: d.completed,
        reason: d.reason ?? '',
        txnDate: d.txnDate,
        particulars: d.cpEntityName,
        txnAmt: num.parse(d.entryAmt),
      );
      txns.add(txn);
    }
    return txns;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'reqRefNum': reqRefNum,
      'status': status.toMap(),
      'completed': completed ? 1 : 0,
      'reason': reason,
      'txnDate': txnDate,
      'particulars': particulars,
      'txnAmt': txnAmt,
    };
  }

  factory BankTransaction.fromMap(Map<String, dynamic> map) {
    return BankTransaction(
      id: map['id'] as String,
      reqRefNum: map['reqRefNum'] as String,
      status: TxnStatus.fromMap(map['status']),
      completed: map['completed'] as int == 1 ? true : false,
      reason: map['reason'] as String,
      txnDate: map['txnDate'] as String,
      particulars: map['particulars'] as String,
      txnAmt: map['txnAmt'] as num,
    );
  }

  String toJson() => json.encode(toMap());

  factory BankTransaction.fromJson(String source) =>
      BankTransaction.fromMap(json.decode(source) as Map<String, dynamic>);
}
