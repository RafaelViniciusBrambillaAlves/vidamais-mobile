import 'package:vidamais/models/Agreement.dart';
import 'package:vidamais/models/Exam.dart';
import 'package:vidamais/models/Unit.dart';

class Labor {
  final int id;
  final String name;
  final String corporateName;
  final String cnpj;
  final String mainPhone;
  final String? website;
  final List<Exam> exams;
  final List<Unit> units;
  final List<Agreement> agreements;

  Labor({
    required this.id,
    required this.name,
    required this.corporateName,
    required this.cnpj,
    required this.mainPhone,
    this.website,
    required this.exams,
    required this.units,
    required this.agreements,
  });

  factory Labor.fromJson(Map<String, dynamic> json) {
    return Labor(
      id: json['id'],
      name: json['name'],
      corporateName: json['corporateName'],
      cnpj: json['cnpj'],
      mainPhone: json['mainPhone'],
      website: json['website'],
      exams: (json['exams'] as List?)?.map((e) => Exam.fromJson(e)).toList() ?? [],
      agreements: (json['agreements'] as List?)?.map((a) => Agreement.fromJson(a)).toList() ?? [],
      units: (json['units'] as List?)?.map((u) => Unit.fromJson(u)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'corporateName': corporateName,
      'cnpj': cnpj,
      'mainPhone': mainPhone,
      'website': website,
      'exams': exams,
      'agreements': agreements,
      'units': units,
    };
  }

  @override
  String toString() {
    return name;
  }
}
