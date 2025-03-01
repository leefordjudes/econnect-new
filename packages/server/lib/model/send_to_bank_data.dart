// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import './txn_detail.dart';

class SendToBankData {
  final String uniqueUserId;
  final String userPassword;
  final String makerId;
  final String totalNoEntries;
  final String totalAmount;
  final String requestTimeStamp;
  final String reqRefNum;
  final List<TxnDetail> txnDetails;

  SendToBankData({
    required this.uniqueUserId,
    required this.userPassword,
    required this.makerId,
    required this.totalNoEntries,
    required this.totalAmount,
    required this.requestTimeStamp,
    required this.reqRefNum,
    required this.txnDetails,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uniqueUserId': uniqueUserId,
      'userPassword': userPassword,
      'makerId': makerId,
      'totalNoEntries': totalNoEntries,
      'totalAmount': totalAmount,
      'requestTimeStamp': requestTimeStamp,
      'reqRefNum': reqRefNum,
      'txnDetails': txnDetails.map((x) => x.toApiMap()).toList(),
    };
  }

  String toJson() => json.encode(toMap());
}
