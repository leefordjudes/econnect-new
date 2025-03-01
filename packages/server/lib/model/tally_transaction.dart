// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:server/model.dart';

class TallyTransaction {
  final String id;
  final TxnStatus status;
  final String date;
  final String particulars;
  final String vchType;
  final String vchId;
  final String vchNo;
  final String adhoc;
  final String beneficiaryCode;
  final String transfermode;
  final num amount;
  final String? narration;
  final String? email;
  final String? ifscode;
  final String? bankName;
  bool selected;

  TallyTransaction({
    required this.id,
    required this.status,
    required this.date,
    required this.particulars,
    required this.vchType,
    required this.vchId,
    required this.vchNo,
    required this.adhoc,
    required this.beneficiaryCode,
    required this.transfermode,
    required this.amount,
    this.narration,
    this.email,
    this.ifscode,
    this.bankName,
  }) : selected = false;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'date': date,
      'particulars': particulars,
      'vchType': vchType,
      'vchId': vchId,
      'vchNo': vchNo,
      'adhoc': adhoc,
      'beneficiaryCode': beneficiaryCode,
      'transfermode': transfermode,
      'amount': amount,
      'narration': narration,
      'email': email,
      'ifscode': ifscode,
      'bankName': bankName,
    };
  }

  factory TallyTransaction.fromMap(Map<String, dynamic> map) {
    return TallyTransaction(
      id: map['id'] as String,
      status: TxnStatus.fromMap(map['status']),
      date: map['date'] as String,
      particulars: map['particulars'] as String,
      vchType: map['vchType'] as String,
      vchId: map['vchId'] as String,
      vchNo: map['vchNo'] as String,
      adhoc: map['adhoc'] as String,
      beneficiaryCode: map['beneficiaryCode'] as String,
      transfermode: map['transfermode'] as String,
      amount: map['amount'] as num,
      narration: map['narration'] != null ? map['narration'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      ifscode: map['ifscode'] != null ? map['ifscode'] as String : null,
      bankName: map['bankName'] != null ? map['bankName'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TallyTransaction.fromJson(String source) =>
      TallyTransaction.fromMap(json.decode(source) as Map<String, dynamic>);

  TallyTransaction copyWith({
    String? id,
    TxnStatus? status,
    String? date,
    String? particulars,
    String? vchType,
    String? vchId,
    String? vchNo,
    String? adhoc,
    String? beneficiaryCode,
    String? transfermode,
    num? amount,
    String? narration,
    String? email,
    String? ifscode,
    String? bankName,
    bool? selected,
  }) {
    return TallyTransaction(
      id: id ?? this.id,
      status: status ?? this.status,
      date: date ?? this.date,
      particulars: particulars ?? this.particulars,
      vchType: vchType ?? this.vchType,
      vchId: vchId ?? this.vchId,
      vchNo: vchNo ?? this.vchNo,
      adhoc: adhoc ?? this.adhoc,
      beneficiaryCode: beneficiaryCode ?? this.beneficiaryCode,
      transfermode: transfermode ?? this.transfermode,
      amount: amount ?? this.amount,
      narration: narration ?? this.narration,
      email: email ?? this.email,
      ifscode: ifscode ?? this.ifscode,
      bankName: bankName ?? this.bankName,
    );
  }
}
