import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/core/layers/presentation/widgets/app_field.dart';
import 'package:merema/core/layers/presentation/widgets/app_button.dart';
import 'package:merema/core/layers/presentation/widgets/custom_dropdown.dart';
import 'package:merema/core/services/service_locator.dart';
import 'package:merema/features/records/domain/usecases/get_diagnoses.dart';
import 'package:merema/features/records/domain/usecases/update_record.dart';
import 'package:merema/features/records/domain/entities/diagnosis.dart';
import 'package:merema/features/patients/presentation/bloc/patient_infos_state_cubit.dart';
import 'package:merema/features/patients/presentation/bloc/patient_infos_state.dart';
import 'package:merema/core/layers/domain/entities/user_role.dart';

class RecordUpdateDialog extends StatefulWidget {
  final dynamic recordDetail;
  final UserRole userRole;
  final VoidCallback onCancel;
  final VoidCallback onSuccess;

  const RecordUpdateDialog({
    super.key,
    required this.recordDetail,
    required this.userRole,
    required this.onCancel,
    required this.onSuccess,
  });

  @override
  State<RecordUpdateDialog> createState() => _RecordUpdateDialogState();
}

class _RecordUpdateDialogState extends State<RecordUpdateDialog> {
  bool _isLoadingDiagnoses = false;
  bool _isUpdating = false;

  List<Diagnosis> _diagnoses = [];
  dynamic _patientInfo;

  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, dynamic> _formData = {};

  late final GetDiagnosesUseCase _getDiagnosesUseCase;
  late final UpdateRecordUseCase _updateRecordUseCase;

  @override
  void initState() {
    super.initState();
    _initializeUseCases();
    _loadPatientInfo();
    _initializeWithExistingData();
    _loadDiagnosesIfNeeded();
  }

  void _initializeUseCases() {
    _getDiagnosesUseCase = sl<GetDiagnosesUseCase>();
    _updateRecordUseCase = sl<UpdateRecordUseCase>();
  }

  void _initializeWithExistingData() {
    if (widget.recordDetail?.recordDetail != null) {
      _populateFormFromExistingData(widget.recordDetail.recordDetail);
      _buildControllersFromData(widget.recordDetail.recordDetail);
    }
  }

  void _populateFormFromExistingData(Map<String, dynamic> data,
      [String prefix = '']) {
    data.forEach((key, value) {
      final fullKey = prefix.isEmpty ? key : '$prefix.$key';

      if (value is Map<String, dynamic>) {
        _populateFormFromExistingData(value, fullKey);
      } else if (value is List &&
          value.isNotEmpty &&
          value.first is Map<String, dynamic>) {
        for (int i = 0; i < value.length; i++) {
          _populateFormFromExistingData(
              value[i] as Map<String, dynamic>, '$fullKey[$i]');
        }
      } else {
        _formData[fullKey] = value;
      }
    });
  }

  void _buildControllersFromData(Map<String, dynamic> data,
      [String prefix = '']) {
    data.forEach((key, value) {
      final fullKey = prefix.isEmpty ? key : '$prefix.$key';

      if (value is Map<String, dynamic>) {
        _buildControllersFromData(value, fullKey);
      } else if (value is List &&
          value.isNotEmpty &&
          value.first is Map<String, dynamic>) {
        for (int i = 0; i < value.length; i++) {
          _buildControllersFromData(
              value[i] as Map<String, dynamic>, '$fullKey[$i]');
        }
      } else {
        // Initialize controller with the existing value
        final existingValue = value?.toString() ?? '';
        final controller = TextEditingController(text: existingValue);

        // Add listener only for non-diagnosis fields to avoid overwriting Diagnosis objects
        if (!_isDiagnosisField(fullKey)) {
          controller.addListener(() {
            _formData[fullKey] = controller.text;
          });
        }

        _controllers[fullKey] = controller;

        // For diagnosis fields, try to find the Diagnosis object by ICD code
        if (_isDiagnosisField(fullKey) && existingValue.isNotEmpty) {
          // We'll set this after diagnoses are loaded
          _formData[fullKey] =
              existingValue; // Store original value temporarily
        } else {
          _formData[fullKey] = existingValue;
        }
      }
    });
  }

  Future<void> _loadPatientInfo() async {
    try {
      final cubit = context.read<PatientInfosCubit>();
      final state = cubit.state;

      if (state is PatientInfosLoaded) {
        setState(() {
          _patientInfo = state.patientInfo;
        });
      } else if (widget.recordDetail?.patientId != null) {
        cubit.getInfos(widget.recordDetail.patientId);
      }
    } catch (e) {
      debugPrint('Error loading patient info: $e');
    }
  }

  Future<void> _loadDiagnosesIfNeeded() async {
    if (widget.recordDetail?.recordDetail == null) return;

    bool needsDiagnoses =
        _checkIfDiagnosisFieldsExist(widget.recordDetail.recordDetail);

    if (needsDiagnoses) {
      setState(() {
        _isLoadingDiagnoses = true;
      });

      try {
        final result = await _getDiagnosesUseCase.call(null);
        result.fold(
          (error) {
            if (mounted) {
              _showErrorSnackBar('Error loading diagnoses: $error');
              setState(() {
                _isLoadingDiagnoses = false;
              });
            }
          },
          (diagnoses) {
            if (mounted) {
              setState(() {
                _diagnoses = diagnoses;
                _isLoadingDiagnoses = false;
              });
              // After diagnoses are loaded, convert existing ICD codes to Diagnosis objects
              _convertExistingDiagnosisFields();
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

  void _convertExistingDiagnosisFields() {
    // Convert existing ICD codes to Diagnosis objects
    _formData.forEach((key, value) {
      if (_isDiagnosisField(key) && value is String && value.isNotEmpty) {
        // Try to find the diagnosis by ICD code or name
        final diagnosis = _diagnoses
            .where((d) => d.icdCode == value || d.name == value)
            .firstOrNull;

        if (diagnosis != null) {
          _formData[key] = diagnosis;
          // Update the controller text to show the diagnosis name
          _controllers[key]?.text = diagnosis.name;
        }
      }
    });
  }

  bool _checkIfDiagnosisFieldsExist(Map<String, dynamic> data,
      [String prefix = '']) {
    for (var entry in data.entries) {
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

  String _getFieldType(dynamic value) {
    if (value is String) return 'string';
    if (value is int) return 'int';
    if (value is double) return 'double';
    if (value is bool) return 'bool';
    return 'string';
  }

  String? _getPatientInfoValueForAdministrativeField(
      String fullKey, String displayKey) {
    if (_patientInfo == null) return null;

    final lowerFullKey = fullKey.toLowerCase();
    if (!lowerFullKey.contains('hành chính') ||
        lowerFullKey.contains('hành chính.liên hệ')) {
      return null;
    }

    final fieldName = displayKey.toLowerCase();

    switch (fieldName) {
      case 'họ và tên':
        return _patientInfo.fullName;

      case 'sinh ngày':
        return _patientInfo.dateOfBirth;

      case 'giới':
        return _patientInfo.gender;

      case 'dân tộc':
        return _patientInfo.ethnicity;

      case 'ngoại kiều':
        return _patientInfo.nationality;

      default:
        return null;
    }
  }

  String? _getPatientInfoValueForInsuranceField(
      String fullKey, String displayKey) {
    if (_patientInfo == null) return null;

    if (!fullKey.toLowerCase().contains('bhyt')) {
      return null;
    }

    final fieldName = displayKey.toLowerCase();

    switch (fieldName) {
      case 'số thẻ':
        return _patientInfo.healthInsuranceNumber;

      case 'giá trị đến ngày':
        return _patientInfo.healthInsuranceExpiredDate;

      default:
        return null;
    }
  }

  Widget _fieldTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppPallete.textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userRole != UserRole.doctor) {
      return Container();
    }

    return BlocListener<PatientInfosCubit, PatientInfosState>(
      listener: (context, state) {
        if (state is PatientInfosLoaded) {
          setState(() {
            _patientInfo = state.patientInfo;
          });
        }
      },
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
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(
          Icons.edit,
          color: AppPallete.primaryColor,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Update Medical Record #${widget.recordDetail.recordId}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppPallete.textColor,
            ),
          ),
        ),
        IconButton(
          onPressed: widget.onCancel,
          icon: const Icon(
            Icons.close,
            color: AppPallete.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
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
                      style:
                          TextStyle(color: AppPallete.textColor, fontSize: 12),
                    ),
                  ],
                ),
              )
            else if (widget.recordDetail?.recordDetail != null)
              ..._buildFormFields(widget.recordDetail.recordDetail),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFormFields(Map<String, dynamic> data,
      [String prefix = '', int depth = 0]) {
    List<Widget> widgets = [];

    data.forEach((key, value) {
      final fullKey = prefix.isEmpty ? key : '$prefix.$key';
      final isAllCaps = key == key.toUpperCase();
      final isFirstLevel = depth == 0;
      final isSecondLevel = depth == 1;

      if (value is Map<String, dynamic>) {
        widgets.add(
          Padding(
            padding: EdgeInsets.zero,
            child: Text(
              key,
              style: TextStyle(
                fontSize: isFirstLevel
                    ? 24
                    : isSecondLevel
                        ? 17
                        : 15,
                fontWeight: isFirstLevel
                    ? FontWeight.bold
                    : isSecondLevel
                        ? FontWeight.w600
                        : FontWeight.w500,
                color: AppPallete.primaryColor,
                letterSpacing: isAllCaps ? 1.5 : 0.5,
              ),
            ),
          ),
        );
        widgets.addAll(_buildFormFields(value, fullKey, depth + 1));
      } else if (value is List &&
          value.isNotEmpty &&
          value.first is Map<String, dynamic>) {
        widgets.add(
          Padding(
            padding: EdgeInsets.zero,
            child: Text(
              key,
              style: TextStyle(
                fontSize: isFirstLevel ? 24 : 17,
                fontWeight: FontWeight.bold,
                color: AppPallete.primaryColor,
                letterSpacing: isAllCaps ? 1.5 : 0.5,
              ),
            ),
          ),
        );
        for (int i = 0; i < value.length; i++) {
          widgets.addAll(_buildFormFields(
              value[i] as Map<String, dynamic>, '$fullKey[$i]', depth + 1));
        }
      } else {
        widgets.add(
          Padding(
            padding: EdgeInsets.zero,
            child: _buildFormField(fullKey, key, value, prefix, depth),
          ),
        );
        widgets.add(const SizedBox(height: 12));
      }
    });

    return widgets;
  }

  Widget _buildFormField(
      String fullKey, String displayKey, dynamic exampleValue,
      [String prefix = '', int depth = 0]) {
    final fieldType = _getFieldType(exampleValue);
    final controller = _controllers[fullKey];

    if (controller == null) return const SizedBox.shrink();

    // Check if this field should be pre-filled with patient info and made read-only
    String? patientValue =
        _getPatientInfoValueForAdministrativeField(fullKey, displayKey) ??
            _getPatientInfoValueForInsuranceField(fullKey, displayKey);

    if (patientValue != null) {
      // If controller doesn't have the patient value, update it
      if (controller.text != patientValue) {
        controller.text = patientValue;
        _formData[fullKey] = patientValue;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldTitle(displayKey),
          AbsorbPointer(
            child: AppField(
              controller: TextEditingController(text: patientValue),
              hintText: displayKey,
              required: false,
            ),
          ),
        ],
      );
    }

    if (_isDiagnosisField(fullKey) &&
        fieldType == 'string' &&
        _diagnoses.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDiagnosisDropdown(fullKey, displayKey, showTitle: false),
        ],
      );
    }

    if (fieldType == 'bool') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldTitle(displayKey),
          Row(
            children: [
              Switch(
                value: controller.text.toLowerCase() == 'true',
                onChanged: (val) {
                  setState(() {
                    controller.text = val.toString();
                    _formData[fullKey] = val;
                  });
                },
                activeColor: AppPallete.primaryColor,
                inactiveThumbColor: AppPallete.darkGrayColor,
                inactiveTrackColor: AppPallete.lightGrayColor,
              ),
              const SizedBox(width: 8),
              Text(
                controller.text.toLowerCase() == 'true' ? 'Có' : 'Không',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppPallete.textColor,
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (fullKey.trim().toLowerCase().endsWith(
        'tóm tắt kết quả xét nghiệm cận lâm sàng có giá trị chẩn đoán')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldTitle(displayKey),
          TextFormField(
            controller: controller,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _formData[fullKey] = value;
            },
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldTitle(displayKey),
        AppField(
          controller: controller,
          hintText:
              'Enter ${fieldType == 'int' ? 'number' : fieldType == 'double' ? 'decimal number' : 'text'} ($fieldType)',
          required: false,
        ),
      ],
    );
  }

  Widget _buildDiagnosisDropdown(String fullKey, String displayKey,
      {bool showTitle = true}) {
    final controller = _controllers[fullKey];
    if (controller == null) return const SizedBox.shrink();

    Diagnosis? selectedDiagnosis;
    // Check if we have a Diagnosis object stored in form data
    if (_formData[fullKey] is Diagnosis) {
      selectedDiagnosis = _formData[fullKey] as Diagnosis;
    } else if (controller.text.isNotEmpty) {
      // Try to find diagnosis by name or ICD code from the current value
      selectedDiagnosis = _diagnoses
          .where(
              (d) => d.name == controller.text || d.icdCode == controller.text)
          .firstOrNull;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldTitle(displayKey),
        CustomDropdown<Diagnosis>(
          width: double.infinity,
          selectedValue: selectedDiagnosis,
          availableItems: _diagnoses,
          onChanged: (diagnosis) {
            if (diagnosis != null) {
              setState(() {
                // Store the Diagnosis object in form data like create dialog
                _formData[fullKey] = diagnosis;
                // Update controller text with diagnosis name for display
                controller.text = diagnosis.name;
              });
            }
          },
          getDisplayText: (diagnosis) =>
              '${diagnosis.name} (${diagnosis.icdCode})',
          labelText: 'Select Diagnosis',
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            text: 'Cancel',
            onPressed: _isUpdating ? null : widget.onCancel,
            width: double.infinity,
            showShadow: false,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppButton(
            text: 'Update Record',
            onPressed: _canUpdateRecord() ? _updateRecord : null,
            width: double.infinity,
            isLoading: _isUpdating,
          ),
        ),
      ],
    );
  }

  bool _canUpdateRecord() {
    return !_isLoadingDiagnoses && !_isUpdating;
  }

  Future<void> _updateRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      Map<String, dynamic> recordDetail =
          _deepCopyMap(widget.recordDetail.recordDetail);
      _fillValues(recordDetail);

      final result = await _updateRecordUseCase.call((
        widget.recordDetail.recordId,
        recordDetail,
      ));

      result.fold(
        (error) {
          if (mounted) {
            _showErrorSnackBar('Failed to update record');
          }
        },
        (updatedRecord) {
          if (mounted) {
            _showSuccessSnackBar('Record updated successfully');
            widget.onSuccess();
          }
        },
      );
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error updating record: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  void _fillValues(Map<String, dynamic> map, [String prefix = '']) {
    final keys = List<String>.from(map.keys);
    for (final key in keys) {
      final value = map[key];
      final fullKey = prefix.isEmpty ? key : '$prefix.$key';

      if (value is Map<String, dynamic>) {
        _fillValues(value, fullKey);
        continue;
      }

      // Handle diagnosis fields first - use ICD code like in create dialog
      if (_isDiagnosisField(fullKey)) {
        if (_formData[fullKey] is Diagnosis) {
          final diagnosis = _formData[fullKey] as Diagnosis;
          map[key] = diagnosis.icdCode;
        }
        // Skip controller handling for diagnosis fields to avoid sending name
        continue;
      }

      if (_controllers.containsKey(fullKey)) {
        final controller = _controllers[fullKey]!;
        final fieldType = _getFieldType(value);
        final convertedValue = _convertValueToType(controller.text, fieldType);
        map[key] = convertedValue;
      }
    }
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
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
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

  Map<String, dynamic> _deepCopyMap(Map<String, dynamic> original) {
    final copy = <String, dynamic>{};
    original.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        copy[key] = _deepCopyMap(value);
      } else if (value is List) {
        copy[key] = List.from(value);
      } else {
        copy[key] = value;
      }
    });
    return copy;
  }
}
