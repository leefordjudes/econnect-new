import 'dart:convert';

class Configuration {
  const Configuration({
    this.id,
    required this.accountNumber,
    required this.accountName,
    required this.corporateId,
    required this.makerId,
    required this.userId,
    required this.password,
  });
  final int? id;
  final String accountNumber;
  final String accountName;
  final String corporateId;
  final String makerId;
  final String userId;
  final String password;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': 1,
      'accountNumber': accountNumber,
      'accountName': accountName,
      'corporateId': corporateId,
      'makerId': makerId,
      'userId': userId,
      'password': password,
    };
  }

  factory Configuration.fromMap(Map<String, dynamic> map) {
    return Configuration(
      id: 1,
      accountNumber: map['accountNumber'] as String,
      accountName: map['accountName'] as String,
      corporateId: map['corporateId'] as String,
      makerId: map['makerId'] as String,
      userId: map['userId'] as String,
      password: map['password'] as String,
    );
  }

  bool get isEmpty {
    return (accountNumber.isEmpty &&
        accountName.isEmpty &&
        corporateId.isEmpty &&
        makerId.isEmpty &&
        userId.isEmpty &&
        password.isEmpty);
  }

  bool get isNotEmpty {
    return (accountNumber.isNotEmpty &&
        accountName.isNotEmpty &&
        corporateId.isNotEmpty &&
        makerId.isNotEmpty &&
        userId.isNotEmpty &&
        password.isNotEmpty);
  }

  String toJson() => json.encode(toMap());

  factory Configuration.fromJson(String source) =>
      Configuration.fromMap(json.decode(source) as Map<String, dynamic>);
}
