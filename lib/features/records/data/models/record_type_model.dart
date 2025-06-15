import 'package:merema/features/records/domain/entities/record_type.dart';

class RecordTypeModel extends RecordType {
  const RecordTypeModel({
    required super.typeId,
    required super.typeName,
  });

  factory RecordTypeModel.fromJson(Map<String, dynamic> json) {
    return RecordTypeModel(
      typeId: json['type_id'] as String,
      typeName: json['type_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type_id': typeId,
      'type_name': typeName,
    };
  }
}
