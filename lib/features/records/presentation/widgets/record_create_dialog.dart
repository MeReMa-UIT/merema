// TODO: Complete record creation dialog implementation

import 'package:flutter/material.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/core/layers/presentation/widgets/app_field.dart';
import 'package:merema/core/layers/presentation/widgets/app_button.dart';
import 'package:merema/core/layers/presentation/widgets/custom_dropdown.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/records/domain/usecases/get_record_types.dart';
import 'package:merema/features/records/domain/usecases/get_record_type_template.dart';
import 'package:merema/features/records/domain/usecases/get_diagnoses.dart';
import 'package:merema/features/records/domain/usecases/add_record.dart';
import 'package:merema/features/records/domain/entities/record_type.dart';
import 'package:merema/features/records/domain/entities/diagnosis.dart';

class RecordCreateDialog extends StatefulWidget {
  final int patientId;
  final String patientName;
  final VoidCallback onCancel;
  final VoidCallback onSuccess;

  const RecordCreateDialog({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.onCancel,
    required this.onSuccess,
  });

  @override
  State<RecordCreateDialog> createState() => _RecordCreateDialogState();
}

class _RecordCreateDialogState extends State<RecordCreateDialog> {
  bool _isLoadingRecordTypes = true;
  bool _isLoadingTemplate = false;
  bool _isLoadingDiagnoses = false;
  bool _isCreating = false;

  List<RecordType> _recordTypes = [];
  RecordType? _selectedRecordType;
  Map<String, dynamic>? _template;
  List<Diagnosis> _diagnoses = [];

  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, dynamic> _formData = {};

  late final GetRecordTypesUseCase _getRecordTypesUseCase;
  late final GetRecordTypeTemplateUseCase _getRecordTypeTemplateUseCase;
  late final GetDiagnosesUseCase _getDiagnosesUseCase;
  late final AddRecordUseCase _addRecordUseCase;

  @override
  void initState() {
    super.initState();
    _initializeUseCases();
    _loadRecordTypes();
  }

  void _initializeUseCases() {
    _getRecordTypesUseCase = sl<GetRecordTypesUseCase>();
    _getRecordTypeTemplateUseCase = sl<GetRecordTypeTemplateUseCase>();
    _getDiagnosesUseCase = sl<GetDiagnosesUseCase>();
    _addRecordUseCase = sl<AddRecordUseCase>();
  }

  Future<void> _loadRecordTypes() async {
    setState(() {
      _isLoadingRecordTypes = true;
    });

    try {
      final result = await _getRecordTypesUseCase.call(null);
      result.fold(
        (error) {
          if (mounted) {
            _showErrorSnackBar('Failed to load record types');
          }
        },
        (recordTypes) {
          if (mounted) {
            setState(() {
              _recordTypes = List<RecordType>.from(recordTypes);
              _isLoadingRecordTypes = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error loading record types: $e');
        setState(() {
          _isLoadingRecordTypes = false;
        });
      }
    }
  }

  Future<void> _loadTemplate(String typeId) async {
    setState(() {
      _isLoadingTemplate = true;
      _template = null;
      _controllers.clear();
      _formData.clear();
    });

    try {
      final result = await _getRecordTypeTemplateUseCase.call(typeId);
      result.fold(
        (error) {
          if (mounted) {
            _showErrorSnackBar('Failed to load template');
          }
        },
        (template) {
          if (mounted) {
            setState(() {
              _template = Map<String, dynamic>.from(template);
              _isLoadingTemplate = false;
            });
            _initializeFormControllers();
            _loadDiagnosesIfNeeded();
          }
        },
      );
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error loading template: $e');
        setState(() {
          _isLoadingTemplate = false;
        });
      }
    }
  }

  void _initializeFormControllers() {
    if (_template == null) return;
    _buildControllersFromTemplate(_template!);
  }

  void _buildControllersFromTemplate(Map<String, dynamic> template,
      [String prefix = '']) {
    template.forEach((key, value) {
      final fullKey = prefix.isEmpty ? key : '$prefix.$key';

      if (value is Map<String, dynamic>) {
        _buildControllersFromTemplate(value, fullKey);
      } else {
        _controllers[fullKey] = TextEditingController();
        _formData[fullKey] = '';
      }
    });
  }

  Future<void> _loadDiagnosesIfNeeded() async {
    if (_template == null) return;

    bool needsDiagnoses = _checkIfDiagnosisFieldsExist(_template!);

    if (needsDiagnoses) {
      setState(() {
        _isLoadingDiagnoses = true;
      });

      try {
        final result = await _getDiagnosesUseCase.call(null);
        result.fold(
          (error) {
            if (mounted) {
              _showErrorSnackBar('Failed to load diagnoses');
            }
          },
          (diagnoses) {
            if (mounted) {
              setState(() {
                _diagnoses = List<Diagnosis>.from(diagnoses);
                _isLoadingDiagnoses = false;
              });
            }
          },
        );
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('Error loading diagnoses: $e');
          setState(() {
            _isLoadingDiagnoses = false;
          });
        }
      }
    }
  }

  bool _checkIfDiagnosisFieldsExist(Map<String, dynamic> template,
      [String prefix = '']) {
    for (var entry in template.entries) {
      final key = entry.key;
      final value = entry.value;
      final fullKey = prefix.isEmpty ? key : '$prefix.$key';

      if (key.toLowerCase().contains('chẩn đoán') ||
          fullKey.toLowerCase().contains('chẩn đoán')) {
        return true;
      }

      if (value is Map<String, dynamic>) {
        if (_checkIfDiagnosisFieldsExist(value, fullKey)) {
          return true;
        }
      }
    }
    return false;
  }

  bool _isDiagnosisField(String key) {
    return key.toLowerCase().contains('chẩn đoán');
  }

  String _getFieldType(dynamic exampleValue) {
    if (exampleValue is String) return 'string';
    if (exampleValue is int) return 'int';
    if (exampleValue is double) return 'double';
    if (exampleValue is bool) return 'bool';
    return 'string';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppPallete.backgroundColor,
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            Expanded(
              child: _buildContent(),
            ),
            const SizedBox(height: 20),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(
          Icons.medical_information,
          color: AppPallete.primaryColor,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Create Medical Record - ${widget.patientName}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppPallete.textColor,
            ),
          ),
        ),
        IconButton(
          onPressed: _isCreating ? null : widget.onCancel,
          icon: const Icon(
            Icons.close,
            color: AppPallete.errorColor,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoadingRecordTypes) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppPallete.primaryColor),
            SizedBox(height: 16),
            Text(
              'Loading record types...',
              style: TextStyle(color: AppPallete.textColor),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecordTypeSelector(),
            if (_selectedRecordType != null) ...[
              const SizedBox(height: 20),
              _buildTemplateForm(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecordTypeSelector() {
    return CustomDropdown<RecordType>(
      selectedValue: _selectedRecordType,
      availableItems: _recordTypes,
      onChanged: (recordType) {
        setState(() {
          _selectedRecordType = recordType;
        });
        if (recordType != null) {
          _loadTemplate(recordType.typeId.replaceAll('/', '_'));
        }
      },
      labelText: 'Select Record Type',
      getDisplayText: (recordType) => recordType.typeName,
      width: double.infinity,
    );
  }

  Widget _buildTemplateForm() {
    if (_isLoadingTemplate) {
      return const Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: AppPallete.primaryColor),
            SizedBox(height: 16),
            Text(
              'Loading template...',
              style: TextStyle(color: AppPallete.textColor),
            ),
          ],
        ),
      );
    }

    if (_template == null) {
      return const Center(
        child: Text(
          'No template available for this record type',
          style: TextStyle(color: AppPallete.darkGrayColor),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Record Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppPallete.textColor,
          ),
        ),
        const SizedBox(height: 16),
        if (_isLoadingDiagnoses)
          const Center(
            child: Column(
              children: [
                CircularProgressIndicator(color: AppPallete.primaryColor),
                SizedBox(height: 8),
                Text(
                  'Loading diagnoses...',
                  style: TextStyle(color: AppPallete.textColor, fontSize: 12),
                ),
              ],
            ),
          )
        else
          ..._buildFormFields(_template!),
      ],
    );
  }

  List<Widget> _buildFormFields(Map<String, dynamic> template,
      [String prefix = '']) {
    List<Widget> widgets = [];

    template.forEach((key, value) {
      final fullKey = prefix.isEmpty ? key : '$prefix.$key';

      if (value is Map<String, dynamic>) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              key,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppPallete.primaryColor,
              ),
            ),
          ),
        );
        widgets.addAll(_buildFormFields(value, fullKey));
      } else {
        widgets.add(_buildFormField(fullKey, key, value));
        widgets.add(const SizedBox(height: 12));
      }
    });

    return widgets;
  }

  Widget _buildFormField(
      String fullKey, String displayKey, dynamic exampleValue) {
    final fieldType = _getFieldType(exampleValue);
    final controller = _controllers[fullKey];

    if (controller == null) return const SizedBox.shrink();

    if (_isDiagnosisField(fullKey) &&
        fieldType == 'string' &&
        _diagnoses.isNotEmpty) {
      return _buildDiagnosisDropdown(fullKey, displayKey);
    }

    return AppField(
      labelText: displayKey,
      controller: controller,
      hintText: 'Example: ${exampleValue?.toString() ?? ''}',
      validator: (value) => _validateField(value, fieldType, displayKey),
      required: true,
    );
  }

  Widget _buildDiagnosisDropdown(String fullKey, String displayKey) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayKey,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppPallete.textColor,
          ),
        ),
        const SizedBox(height: 8),
        CustomDropdown<Diagnosis>(
          selectedValue:
              _formData[fullKey] is Diagnosis ? _formData[fullKey] : null,
          availableItems: _diagnoses,
          onChanged: (diagnosis) {
            setState(() {
              _formData[fullKey] = diagnosis;
              _controllers[fullKey]?.text = diagnosis?.name ?? '';
            });
          },
          labelText: 'Select Diagnosis',
          getDisplayText: (diagnosis) =>
              '${diagnosis.name} (${diagnosis.icdCode})',
          width: double.infinity,
        ),
      ],
    );
  }

  String? _validateField(String? value, String fieldType, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }

    switch (fieldType) {
      case 'int':
        if (int.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        break;
      case 'double':
        if (double.tryParse(value) == null) {
          return 'Please enter a valid decimal number';
        }
        break;
      case 'bool':
        if (value.toLowerCase() != 'true' && value.toLowerCase() != 'false') {
          return 'Please enter true or false';
        }
        break;
    }

    return null;
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            text: 'Cancel',
            onPressed: _isCreating ? null : widget.onCancel,
            width: double.infinity,
            showShadow: false,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppButton(
            text: 'Create Record',
            onPressed: _canCreateRecord() ? _createRecord : null,
            width: double.infinity,
            isLoading: _isCreating,
          ),
        ),
      ],
    );
  }

  bool _canCreateRecord() {
    return _selectedRecordType != null &&
        _template != null &&
        !_isLoadingTemplate &&
        !_isLoadingDiagnoses &&
        !_isCreating;
  }

  Future<void> _createRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final recordDetail = <String, dynamic>{};
      _controllers.forEach((key, controller) {
        final value = controller.text;
        final fieldType = _getFieldTypeFromTemplate(key);

        recordDetail[key] = _convertValueToType(value, fieldType);
      });

      final result = await _addRecordUseCase.call((
        widget.patientId,
        recordDetail,
        _selectedRecordType!.typeId.replaceAll('/', '\\/'),
      ));

      result.fold(
        (error) {
          if (mounted) {
            _showErrorSnackBar('Failed to create record');
          }
        },
        (success) {
          if (mounted) {
            _showSuccessSnackBar('Record created successfully');
            widget.onSuccess();
          }
        },
      );
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error creating record: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  String _getFieldTypeFromTemplate(String key) {
    if (_template == null) return 'string';

    final parts = key.split('.');
    dynamic current = _template;

    for (String part in parts) {
      if (current is Map<String, dynamic> && current.containsKey(part)) {
        current = current[part];
      } else {
        return 'string';
      }
    }

    return _getFieldType(current);
  }

  dynamic _convertValueToType(String value, String type) {
    switch (type) {
      case 'int':
        return int.tryParse(value) ?? 0;
      case 'double':
        return double.tryParse(value) ?? 0.0;
      case 'bool':
        return value.toLowerCase() == 'true';
      default:
        return value;
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppPallete.errorColor,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppPallete.primaryColor,
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
