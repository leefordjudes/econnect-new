import 'dart:convert';

class CompanyInfo {
  const CompanyInfo(
    this.name,
    this.serialNumber,
  );

  final String name;
  final String serialNumber;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'serialNumber': serialNumber,
    };
  }

  factory CompanyInfo.fromMap(Map<String, dynamic> map) {
    return CompanyInfo(
      map['name'] as String,
      map['serialNumber'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory CompanyInfo.fromJson(String source) =>
      CompanyInfo.fromMap(json.decode(source) as Map<String, dynamic>);
}
