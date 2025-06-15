import 'package:equatable/equatable.dart';

class RecordType extends Equatable {
  final String typeId;
  final String typeName;

  const RecordType({
    required this.typeId,
    required this.typeName,
  });

  @override
  List<Object?> get props => [typeId, typeName];
}
