// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Settings {
  const Settings({
    this.recordsPerPage,
    this.oauthUrl,
    this.statusUrl,
    this.paymentUrl,
    this.publicKey,
    this.privateKey,
  }) : id = 1;
  final int id;
  final int? recordsPerPage;
  final String? oauthUrl;
  final String? statusUrl;
  final String? paymentUrl;
  final String? publicKey;
  final String? privateKey;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': 1,
      'recordsPerPage': recordsPerPage ?? 25,
      'oauthUrl': oauthUrl,
      'statusUrl': statusUrl,
      'paymentUrl': paymentUrl,
      'publicKey': publicKey,
      'privateKey': privateKey,
    };
  }

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      recordsPerPage:
          map['recordsPerPage'] != null ? map['recordsPerPage'] as int : 25,
      oauthUrl: map['oauthUrl'] as String,
      statusUrl: map['statusUrl'] as String,
      paymentUrl: map['paymentUrl'] as String,
      publicKey: map['publicKey'] as String,
      privateKey: map['privateKey'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Settings.fromJson(String source) =>
      Settings.fromMap(json.decode(source) as Map<String, dynamic>);

  // bool get isEmpty {
  //   return (oauthUrl != null &&
  //       oauthUrl!.isEmpty &&
  //       statusUrl != null &&
  //       statusUrl!.isEmpty &&
  //       paymentUrl != null &&
  //       paymentUrl!.isEmpty &&
  //       publicKey != null &&
  //       publicKey!.isEmpty &&
  //       privateKey != null &&
  //       privateKey!.isEmpty);
  // }

  // bool get isNotEmpty {
  //   return (oauthUrl != null &&
  //       oauthUrl!.isNotEmpty &&
  //       statusUrl != null &&
  //       statusUrl!.isNotEmpty &&
  //       paymentUrl != null &&
  //       paymentUrl!.isNotEmpty &&
  //       publicKey != null &&
  //       publicKey!.isNotEmpty &&
  //       privateKey != null &&
  //       privateKey!.isNotEmpty);
  // }

  Settings copyWith({
    int? recordsPerPage,
    String? oauthUrl,
    String? statusUrl,
    String? paymentUrl,
    String? publicKey,
    String? privateKey,
  }) {
    return Settings(
      recordsPerPage: recordsPerPage ?? this.recordsPerPage,
      oauthUrl: oauthUrl ?? this.oauthUrl,
      statusUrl: statusUrl ?? this.statusUrl,
      paymentUrl: paymentUrl ?? this.paymentUrl,
      publicKey: publicKey ?? this.publicKey,
      privateKey: privateKey ?? this.privateKey,
    );
  }
}
