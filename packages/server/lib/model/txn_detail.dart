// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:server/model.dart';

class TxnDetail {
  final String id;
  final TxnStatus status;
  final bool completed;
  final String reqRefNum;
  final String slno;
  final String networkType;
  final String txnDate;
  final String txnCrn;
  final String entryAmt;
  final String erpTranRef;
  final String debitAcct;
  final String bankCode;
  final String branchCode;
  final String entryRemarks;
  final String adhocPayeeFlg;
  final String cpEntityId;
  final String cpEntityName;
  final String cpEntityAcctType;
  final String? cpEntityRoutingNumber;
  final String? reason;
  final String? bankDate;
  final String? bankRef;
  final String? bnfName;

  TxnDetail({
    required this.id,
    required this.status,
    required this.completed,
    required this.reqRefNum,
    required this.slno,
    required this.networkType,
    required this.txnDate,
    required this.entryAmt,
    required this.erpTranRef,
    required this.debitAcct,
    required this.adhocPayeeFlg,
    required this.cpEntityId,
    required this.cpEntityName,
    this.cpEntityRoutingNumber,
    this.reason,
    this.bankDate,
    this.bankRef,
    this.bnfName,
  })  : txnCrn = "INR",
        bankCode = "TMB",
        branchCode = "",
        entryRemarks = "",
        cpEntityAcctType = "SBA";

  static List<TxnDetail> buildDetails(
    List<TallyTransaction> txns,
    String reqRefNum,
    String bankAcNo,
  ) {
    List<TxnDetail> txnDetails = [];
    for (var (idx, txn) in txns.indexed) {
      var dt = txn.date.toString();
      var txnDate =
          '${dt.substring(6, 8)}/${dt.substring(4, 6)}/${dt.substring(2, 4)}';

      // var d = DateTime.parse(dt);
      // print(
      //     '${d.year % 100}/${d.month.toStringAsFixed(2)}/${d.day.toStringAsFixed(2)}');
      // print('DateTime.parse(dt): $d');

      var txnDetail = TxnDetail(
        id: txn.id.toUpperCase(),
        status: TxnStatus.submitted,
        completed: false,
        reqRefNum: reqRefNum,
        slno: (idx + 1).toString(),
        networkType: txn.transfermode,
        txnDate: txnDate, //change format "dd/mm/yy"
        entryAmt: txn.amount.toStringAsFixed(2),
        erpTranRef: txn.id.toUpperCase(),
        debitAcct: bankAcNo,
        adhocPayeeFlg: txn.adhoc,
        cpEntityId: txn.beneficiaryCode,
        cpEntityName: txn.particulars,
        cpEntityRoutingNumber: txn.ifscode,
      );
      print('FullTxnDetail: ${txnDetail.toJson()}');
      txnDetails.add(txnDetail);
    }
    return txnDetails;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'status': status.toMap(),
      'completed': completed,
      'reqRefNum': reqRefNum,
      'slno': slno,
      'networkType': networkType,
      'txnDate': txnDate,
      'txnCrn': txnCrn,
      'entryAmt': entryAmt,
      'erpTranRef': erpTranRef,
      'debitAcct': debitAcct,
      'bankCode': bankCode,
      'branchCode': branchCode,
      'entryRemarks': entryRemarks,
      'adhocPayeeFlg': adhocPayeeFlg,
      'cpEntityId': cpEntityId,
      'cpEntityName': cpEntityName,
      'cpEntityAcctType': cpEntityAcctType,
      'cpEntityRoutingNumber': cpEntityRoutingNumber,
      'reason': reason,
      'bankDate': bankDate,
      'bankRef': bankRef,
      'bnfName': bnfName,
    };
  }

  Map<String, dynamic> toApiMap() {
    return <String, dynamic>{
      'slno': slno,
      'networkType': networkType,
      'txnDate': txnDate,
      'txnCrn': txnCrn,
      'entryAmt': entryAmt,
      'erpTranRef': erpTranRef,
      'debitAcct': debitAcct,
      'bankCode': bankCode,
      'branchCode': branchCode,
      'entryRemarks': entryRemarks,
      'adhocPayeeFlg': adhocPayeeFlg,
      'cpEntityId': cpEntityId,
      'cpEntityName': cpEntityName,
      'cpEntityAcctType': cpEntityAcctType,
      'cpEntityRoutingNumber': cpEntityRoutingNumber,
    };
  }

  factory TxnDetail.fromMap(Map<String, dynamic> map) {
    return TxnDetail(
      id: map['id'] as String,
      status: TxnStatus.fromMap(map['status'] as String),
      completed: map['completed'] as bool,
      reqRefNum: map['reqRefNum'] as String,
      slno: map['slno'] as String,
      networkType: map['networkType'] as String,
      txnDate: map['txnDate'] as String,
      entryAmt: map['entryAmt'] as String,
      erpTranRef: map['erpTranRef'] as String,
      debitAcct: map['debitAcct'] as String,
      adhocPayeeFlg: map['adhocPayeeFlg'] as String,
      cpEntityId: map['cpEntityId'] as String,
      cpEntityName: map['cpEntityName'] as String,
      cpEntityRoutingNumber: map['cpEntityRoutingNumber'] as String,
      reason: map['reason'] != null ? map['reason'] as String : null,
      bankDate: map['bankDate'] != null ? map['bankDate'] as String : null,
      bankRef: map['bankRef'] != null ? map['bankRef'] as String : null,
      bnfName: map['bnfName'] != null ? map['bnfName'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());
  String toApiJson() => json.encode(toApiMap());

  factory TxnDetail.fromJson(String source) =>
      TxnDetail.fromMap(json.decode(source) as Map<String, dynamic>);
}
