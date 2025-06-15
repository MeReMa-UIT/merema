import 'package:equatable/equatable.dart';

class Diagnosis extends Equatable {
  final String description;
  final String icdCode;
  final String name;

  const Diagnosis({
    required this.description,
    required this.icdCode,
    required this.name,
  });

  @override
  List<Object?> get props => [description, icdCode, name];
}
