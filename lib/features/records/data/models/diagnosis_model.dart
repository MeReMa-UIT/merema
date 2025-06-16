import 'package:merema/features/records/domain/entities/diagnosis.dart';

class DiagnosisModel extends Diagnosis {
  const DiagnosisModel({
    required super.description,
    required super.icdCode,
    required super.name,
  });

  factory DiagnosisModel.fromJson(Map<String, dynamic> json) {
    return DiagnosisModel(
      description: json['description'] as String? ?? 'No description available',
      icdCode: json['icd_code'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'icd_code': icdCode,
      'name': name,
    };
  }
}
