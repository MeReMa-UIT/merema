import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:merema/features/patients/presentation/bloc/patient_infos_state_cubit.dart';
import 'package:merema/features/patients/presentation/bloc/patient_infos_state.dart';

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
  dynamic _patientInfo;

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
    _loadPatientInfo();
  }

  void _initializeUseCases() {
    _getRecordTypesUseCase = sl<GetRecordTypesUseCase>();
    _getRecordTypeTemplateUseCase = sl<GetRecordTypeTemplateUseCase>();
    _getDiagnosesUseCase = sl<GetDiagnosesUseCase>();
    _addRecordUseCase = sl<AddRecordUseCase>();
  }

  Future<void> _loadPatientInfo() async {
    try {
      final cubit = context.read<PatientInfosCubit>();
      final state = cubit.state;

      if (state is PatientInfosLoaded) {
        setState(() {
          _patientInfo = state.patientInfo;
        });
      } else {
        cubit.getInfos(widget.patientId);
      }
    } catch (e) {
      debugPrint('Error loading patient info: $e');
    }
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
      } else if (value is List &&
          value.isNotEmpty &&
          value.first is Map<String, dynamic>) {
        for (int i = 0; i < value.length; i++) {
          _buildControllersFromTemplate(
              value[i] as Map<String, dynamic>, '$fullKey[$i]');
        }
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
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppPallete.textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PatientInfosCubit, PatientInfosState>(
      listener: (context, state) {
        if (state is PatientInfosLoaded) {
          setState(() {
            _patientInfo = state.patientInfo;
          });
        }
      },
      child: Dialog(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldTitle('Loại bệnh án'),
        CustomDropdown<RecordType>(
          selectedValue: _selectedRecordType,
          availableItems: _recordTypes,
          onChanged: (recordType) {
            setState(() {
              _selectedRecordType = recordType;
            });
            if (recordType != null) {
              _loadTemplate(recordType.typeId.replaceAll('/', ''));
            }
          },
          labelText: 'Loại bệnh án',
          getDisplayText: (recordType) => recordType.typeName,
          width: double.infinity,
        ),
      ],
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
      [String prefix = '', int depth = 0]) {
    List<Widget> widgets = [];

    template.forEach((key, value) {
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

    String? patientValue =
        _getPatientInfoValueForAdministrativeField(fullKey, displayKey) ??
            _getPatientInfoValueForInsuranceField(fullKey, displayKey);

    if (patientValue != null && controller.text.isEmpty) {
      controller.text = patientValue;
      _formData[fullKey] = patientValue;
      String displayValue = patientValue;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldTitle(displayKey),
          AbsorbPointer(
            child: AppField(
              controller: TextEditingController(text: displayValue),
              hintText: displayKey,
              required: false,
            ),
          ),
        ],
      );
    }

    if (prefix.toLowerCase().endsWith('bệnh án')) {
      if (displayKey.trim().toLowerCase() == 'loại bệnh án' &&
          _selectedRecordType != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldTitle(displayKey),
            AbsorbPointer(
              child: AppField(
                controller:
                    TextEditingController(text: _selectedRecordType!.typeName),
                hintText: displayKey,
                required: false,
              ),
            ),
          ],
        );
      }
      if (displayKey.trim().toLowerCase() == 'ms' &&
          _selectedRecordType != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldTitle(displayKey),
            AbsorbPointer(
              child: AppField(
                controller:
                    TextEditingController(text: _selectedRecordType!.typeId),
                hintText: displayKey,
                required: false,
              ),
            ),
          ],
        );
      }
    }

    if (displayKey.trim() == 'Thời gian') {
      String year = '', month = '', day = '', hour = '', minute = '';
      if (controller.text.isNotEmpty) {
        if (controller.text.contains('T')) {
          final dateTime = controller.text.split('T');
          if (dateTime.length == 2) {
            final dateParts = dateTime[0].split('-');
            if (dateParts.length == 3) {
              year = dateParts[0];
              month = dateParts[1];
              day = dateParts[2];
            }
            final timeParts = dateTime[1].replaceAll('Z', '').split(':');
            if (timeParts.length >= 2) {
              hour = timeParts[0];
              minute = timeParts[1];
            }
          }
        } else {
          final dateTimeParts = controller.text.split(' ');
          if (dateTimeParts.isNotEmpty) {
            final dateParts = dateTimeParts[0].split('/');
            if (dateParts.length == 3) {
              year = dateParts[0];
              month = dateParts[1];
              day = dateParts[2];
            }
            if (dateTimeParts.length > 1) {
              final timeParts = dateTimeParts[1].split(':');
              if (timeParts.length == 2) {
                hour = timeParts[0];
                minute = timeParts[1];
              }
            }
          }
        }
      }
      final yearController = TextEditingController(text: year);
      final monthController = TextEditingController(text: month);
      final dayController = TextEditingController(text: day);
      final hourController = TextEditingController(text: hour);
      final minuteController = TextEditingController(text: minute);

      void updateMainController() {
        final y = yearController.text.padLeft(4, '0');
        final m = monthController.text.padLeft(2, '0');
        final d = dayController.text.padLeft(2, '0');
        final h = hourController.text.padLeft(2, '0');
        final min = minuteController.text.padLeft(2, '0');
        String value = '';
        if (y.isNotEmpty &&
            m.isNotEmpty &&
            d.isNotEmpty &&
            h.isNotEmpty &&
            min.isNotEmpty) {
          value = '$y-$m-${d}T$h:$min:00Z';
        } else if (y.isNotEmpty && m.isNotEmpty && d.isNotEmpty) {
          value = '$y-$m-$d';
        }
        controller.text = value;
        _formData[fullKey] = value;
      }

      yearController.addListener(updateMainController);
      monthController.addListener(updateMainController);
      dayController.addListener(updateMainController);
      hourController.addListener(updateMainController);
      minuteController.addListener(updateMainController);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldTitle(displayKey),
          Row(
            children: [
              Expanded(
                child: AppField(
                  controller: yearController,
                  hintText: 'YYYY',
                  required: false,
                ),
              ),
              const SizedBox(width: 4),
              const Text('-'),
              const SizedBox(width: 4),
              Expanded(
                child: AppField(
                  controller: monthController,
                  hintText: 'MM',
                  required: false,
                ),
              ),
              const SizedBox(width: 4),
              const Text('-'),
              const SizedBox(width: 4),
              Expanded(
                child: AppField(
                  controller: dayController,
                  hintText: 'DD',
                  required: false,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppField(
                  controller: hourController,
                  hintText: 'hh',
                  required: false,
                ),
              ),
              const SizedBox(width: 4),
              const Text(':'),
              const SizedBox(width: 4),
              Expanded(
                child: AppField(
                  controller: minuteController,
                  hintText: 'mm',
                  required: false,
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
          AppField(
            controller: controller,
            hintText: 'Enter text (string)',
            required: false,
          ),
        ],
      );
    }

    if (prefix.toLowerCase().endsWith('chẩn đoán khi vào khoa điều trị') &&
        displayKey.trim().toLowerCase() == 'phân biệt') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldTitle(displayKey),
          AppField(
            controller: controller,
            hintText: 'Enter text (string)',
            required: false,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldTitle(displayKey),
        AppField(
          controller: controller,
          hintText:
              'Enter ${fieldType == 'int' ? 'number' : fieldType == 'double' ? 'decimal number' : 'text'} ($fieldType)',
          validator: null,
          required: false,
        ),
      ],
    );
  }

  Widget _buildDiagnosisDropdown(String fullKey, String displayKey,
      {bool showTitle = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldTitle(displayKey),
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
      Map<String, dynamic> recordDetail =
          _template != null ? _deepCopyMap(_template!) : <String, dynamic>{};

      void fillValues(Map<String, dynamic> map, [String prefix = '']) {
        final keys = List<String>.from(map.keys);
        for (final key in keys) {
          final value = map[key];
          final fullKey = prefix.isEmpty ? key : '$prefix.$key';
          if (value is Map<String, dynamic>) {
            fillValues(value, fullKey);
            continue;
          }
          if (_isDiagnosisField(fullKey) && _formData[fullKey] is Diagnosis) {
            final v = (_formData[fullKey] as Diagnosis).icdCode;
            map[key] = v;
          } else if (_controllers.containsKey(fullKey)) {
            final controller = _controllers[fullKey]!;
            final fieldType = _getFieldTypeFromTemplate(fullKey);
            final v = _convertValueToType(controller.text, fieldType);
            map[key] = v;
          } else {
            final patientVal =
                _getPatientInfoValueForAdministrativeField(fullKey, key);
            final insVal = _getPatientInfoValueForInsuranceField(fullKey, key);
            if (patientVal != null) {
              map[key] = patientVal;
            } else if (insVal != null) {
              map[key] = insVal;
            }
          }
        }
      }

      if (_template != null) {
        fillValues(recordDetail);
      }
      if (_selectedRecordType != null) {
        void setIfExists(
            Map<String, dynamic> map, String searchKey, dynamic value) {
          final keys = List<String>.from(map.keys);
          for (final k in keys) {
            if (k.trim().toLowerCase() == searchKey) {
              map[k] = value;
            } else if (map[k] is Map<String, dynamic>) {
              setIfExists(map[k], searchKey, value);
            }
          }
        }

        setIfExists(
            recordDetail, 'loại bệnh án', _selectedRecordType!.typeName);
        setIfExists(recordDetail, 'ms', _selectedRecordType!.typeId);
      }

      final result = await _addRecordUseCase.call((
        widget.patientId,
        recordDetail,
        _selectedRecordType!.typeId,
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
        return double.tryParse(value) ?? -0.1;
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
      } else {
        copy[key] = value;
      }
    });
    return copy;
  }
}
