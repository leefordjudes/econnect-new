import 'dart:convert';

class BankAccount {
  const BankAccount(
    this.accountName,
    this.accountNumber,
  );

  final String accountName;
  final String accountNumber;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'accountName': accountName,
      'accountNumber': accountNumber,
    };
  }

  factory BankAccount.fromMap(Map<String, dynamic> map) {
    return BankAccount(
      map['accountName'] as String,
      map['accountNumber'] as String,
    );
  }

  bool get isEmpty {
    return (accountName.isEmpty && accountNumber.isEmpty);
  }

  String toJson() => json.encode(toMap());

  factory BankAccount.fromJson(String source) =>
      BankAccount.fromMap(json.decode(source) as Map<String, dynamic>);
}
