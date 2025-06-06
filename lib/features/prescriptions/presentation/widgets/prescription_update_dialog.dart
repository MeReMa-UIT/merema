import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/core/layers/presentation/widgets/custom_dropdown.dart';
import 'package:merema/core/layers/presentation/widgets/app_field.dart';
import 'package:merema/features/prescriptions/presentation/bloc/medications_state_cubit.dart';
import 'package:merema/features/prescriptions/presentation/bloc/medications_state.dart';
import 'package:merema/features/prescriptions/domain/usecases/update_prescription.dart';
import 'package:merema/features/prescriptions/domain/entities/prescription.dart';
import 'package:merema/core/services/service_locator.dart';

class PrescriptionUpdateDialog extends StatefulWidget {
  final int prescriptionId;
  final List<dynamic> prescriptionDetails;
  final bool isInsuranceCovered;
  final String prescriptionNote;
  final VoidCallback onCancel;
  final VoidCallback onSuccess;

  const PrescriptionUpdateDialog({
    super.key,
    required this.prescriptionId,
    required this.prescriptionDetails,
    required this.isInsuranceCovered,
    required this.prescriptionNote,
    required this.onCancel,
    required this.onSuccess,
  });

  @override
  State<PrescriptionUpdateDialog> createState() =>
      _PrescriptionUpdateDialogState();
}

class _PrescriptionUpdateDialogState extends State<PrescriptionUpdateDialog> {
  final _formKey = GlobalKey<FormState>();
  late bool _isInsuranceCovered;
  late TextEditingController _prescriptionNoteController;
  late List<PrescriptionDetails> _details;
  late List<Map<String, TextEditingController>> _detailControllers;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isInsuranceCovered = widget.isInsuranceCovered;
    _prescriptionNoteController =
        TextEditingController(text: widget.prescriptionNote);

    _details = widget.prescriptionDetails
        .map((detail) => PrescriptionDetails(
              detailId: detail.detailId ?? -1,
              medId: detail.medId,
              morningDosage: detail.morningDosage,
              afternoonDosage: detail.afternoonDosage,
              eveningDosage: detail.eveningDosage,
              totalDosage: detail.totalDosage,
              dosageUnit: detail.dosageUnit,
              durationDays: detail.durationDays,
              instructions: detail.instructions,
            ))
        .toList();

    _initializeControllers();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicationsCubit>().getAllMedications();
    });
  }

  @override
  void didUpdateWidget(covariant PrescriptionUpdateDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isInsuranceCovered != oldWidget.isInsuranceCovered) {
      setState(() {
        _isInsuranceCovered = widget.isInsuranceCovered;
      });
    }
  }

  void _initializeControllers() {
    _detailControllers = _details
        .map((detail) => {
              'morningDosage': TextEditingController(
                  text: detail.morningDosage.toStringAsFixed(1)),
              'afternoonDosage': TextEditingController(
                  text: detail.afternoonDosage.toStringAsFixed(1)),
              'eveningDosage': TextEditingController(
                  text: detail.eveningDosage.toStringAsFixed(1)),
              'dosageUnit': TextEditingController(text: detail.dosageUnit),
              'durationDays':
                  TextEditingController(text: detail.durationDays.toString()),
              'instructions': TextEditingController(text: detail.instructions),
              'totalDosage': TextEditingController(
                  text: detail.totalDosage.toStringAsFixed(1)),
            })
        .toList();

    for (int i = 0; i < _detailControllers.length; i++) {
      _detailControllers[i]['morningDosage']!.addListener(() {
        final value =
            double.tryParse(_detailControllers[i]['morningDosage']!.text) ??
                0.0;
        setState(() {
          _details[i] = _details[i].copyWith(morningDosage: value);
          _updateTotalDosage(i);
        });
      });

      _detailControllers[i]['afternoonDosage']!.addListener(() {
        final value =
            double.tryParse(_detailControllers[i]['afternoonDosage']!.text) ??
                0.0;
        setState(() {
          _details[i] = _details[i].copyWith(afternoonDosage: value);
          _updateTotalDosage(i);
        });
      });

      _detailControllers[i]['eveningDosage']!.addListener(() {
        final value =
            double.tryParse(_detailControllers[i]['eveningDosage']!.text) ??
                0.0;
        setState(() {
          _details[i] = _details[i].copyWith(eveningDosage: value);
          _updateTotalDosage(i);
        });
      });

      _detailControllers[i]['durationDays']!.addListener(() {
        final value =
            int.tryParse(_detailControllers[i]['durationDays']!.text) ?? 1;
        setState(() {
          _details[i] = _details[i].copyWith(durationDays: value);
          _updateTotalDosage(i);
        });
      });

      _detailControllers[i]['dosageUnit']!.addListener(() {
        setState(() {
          _details[i] = _details[i]
              .copyWith(dosageUnit: _detailControllers[i]['dosageUnit']!.text);
        });
      });

      _detailControllers[i]['instructions']!.addListener(() {
        setState(() {
          _details[i] = _details[i].copyWith(
              instructions: _detailControllers[i]['instructions']!.text);
        });
      });
    }
  }

  @override
  void dispose() {
    _prescriptionNoteController.dispose();
    for (var controllers in _detailControllers) {
      for (var controller in controllers.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  void _removeDetail(int index) {
    setState(() {
      _details.removeAt(index);
    });
  }

  void _updateTotalDosage(int index) {
    final detail = _details[index];
    final dailyDosage =
        detail.morningDosage + detail.afternoonDosage + detail.eveningDosage;
    final total = dailyDosage * detail.durationDays;
    setState(() {
      _details[index] = detail.copyWith(totalDosage: total);
      _detailControllers[index]['totalDosage']!.text = total.toStringAsFixed(1);
    });
  }

  void _addNewMedication() {
    setState(() {
      _details.add(
        const PrescriptionDetails(
          detailId: null,
          medId: 0,
          morningDosage: 0.0,
          afternoonDosage: 0.0,
          eveningDosage: 0.0,
          totalDosage: 0.0,
          dosageUnit: '',
          durationDays: 0,
          instructions: '',
        ),
      );
    });

    _initializeControllers();
  }

  Future<void> _savePrescription() async {
    if (!_formKey.currentState!.validate()) return;

    final formState = _formKey.currentState!;
    formState.save();

    for (int i = 0; i < _details.length; i++) {
      if (_details[i].medId == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a medication for detail ${i + 1}'),
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final noteText = _prescriptionNoteController.text.trim();
      final updateData = {
        'details': _details.asMap().entries.map((entry) {
          final i = entry.key;
          final detail = entry.value;
          final orig = i < widget.prescriptionDetails.length
              ? widget.prescriptionDetails[i]
              : null;

          return {
            'detail_id': detail.detailId,
            'med_id': orig == null || detail.medId != orig.medId
                ? detail.medId
                : orig.medId,
            'morning_dosage':
                orig == null || detail.morningDosage != orig.morningDosage
                    ? detail.morningDosage
                    : orig.morningDosage,
            'afternoon_dosage':
                orig == null || detail.afternoonDosage != orig.afternoonDosage
                    ? detail.afternoonDosage
                    : orig.afternoonDosage,
            'evening_dosage':
                orig == null || detail.eveningDosage != orig.eveningDosage
                    ? detail.eveningDosage
                    : orig.eveningDosage,
            'total_dosage':
                orig == null || detail.totalDosage != orig.totalDosage
                    ? detail.totalDosage
                    : orig.totalDosage,
            'dosage_unit': orig == null || detail.dosageUnit != orig.dosageUnit
                ? detail.dosageUnit
                : orig.dosageUnit,
            'duration_days':
                orig == null || detail.durationDays != orig.durationDays
                    ? detail.durationDays
                    : orig.durationDays,
            'instructions':
                orig == null || detail.instructions != orig.instructions
                    ? detail.instructions
                    : orig.instructions,
          };
        }).toList(),
        'is_insurance_covered': _isInsuranceCovered,
        'prescription_note': noteText,
      };

      final updateUseCase = sl<UpdatePrescriptionUseCase>();
      final result = await updateUseCase((widget.prescriptionId, updateData));

      result.fold(
        (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.toString()),
              ),
            );
          }
        },
        (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Prescription updated successfully'),
              ),
            );
            widget.onSuccess();
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      appBar: AppBar(
        title: const Text('Update Prescription'),
        backgroundColor: AppPallete.backgroundColor,
        foregroundColor: AppPallete.textColor,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel,
          tooltip: 'Close',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _savePrescription,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save, size: 18),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPallete.primaryColor,
                foregroundColor: AppPallete.backgroundColor,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: AppPallete.backgroundColor,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Prescription Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppPallete.textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text(
                          'Insurance Covered',
                          style: TextStyle(color: AppPallete.textColor),
                        ),
                        value: _isInsuranceCovered,
                        onChanged: (value) {
                          setState(() {
                            _isInsuranceCovered = value;
                          });
                        },
                        activeColor: AppPallete.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      AppField(
                        labelText: 'Prescription Note',
                        hintText: _prescriptionNoteController.text.isEmpty
                            ? widget.prescriptionNote
                            : null,
                        controller: _prescriptionNoteController,
                        alwaysShowLabel:
                            _prescriptionNoteController.text.isNotEmpty,
                        required: false,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: AppPallete.backgroundColor,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Medication Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppPallete.textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._details.asMap().entries.map((entry) {
                        final index = entry.key;
                        final detail = entry.value;
                        return _buildDetailCard(index, detail);
                      }),
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _addNewMedication,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Medication'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppPallete.primaryColor,
                            foregroundColor: AppPallete.backgroundColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(int index, PrescriptionDetails detail) {
    return Card(
      color: AppPallete.backgroundColor,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Medication ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppPallete.textColor,
                  ),
                ),
                if (_details.length > 1)
                  IconButton(
                    onPressed: () => _removeDetail(index),
                    icon:
                        const Icon(Icons.delete, color: AppPallete.errorColor),
                    tooltip: 'Remove medication',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<MedicationsCubit, MedicationsState>(
              builder: (context, medicationState) {
                if (medicationState is MedicationsLoaded) {
                  final selectedMedication = detail.medId != 0
                      ? medicationState.medications
                          .where((med) => med.medId == detail.medId)
                          .firstOrNull
                      : null;

                  return CustomDropdown<dynamic>(
                    selectedValue: selectedMedication,
                    availableItems: medicationState.medications,
                    onChanged: (medication) {
                      if (medication != null) {
                        setState(() {
                          _details[index] =
                              detail.copyWith(medId: medication.medId);
                        });
                      }
                    },
                    getDisplayText: (medication) =>
                        '${medication.name} (${medication.strength}) - ${medication.genericName}',
                    labelText: 'Select Medication',
                  );
                } else if (medicationState is MedicationError) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppPallete.errorColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Error loading medications: ${medicationState.message}',
                    ),
                  );
                } else {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Loading medications...',
                          style: TextStyle(color: AppPallete.textColor),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppField(
                    labelText: 'Morning',
                    controller: _detailControllers[index]['morningDosage']!,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null ||
                          double.parse(value) < 0) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppField(
                    labelText: 'Afternoon',
                    controller: _detailControllers[index]['afternoonDosage']!,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null ||
                          double.parse(value) < 0) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppField(
                    labelText: 'Evening',
                    controller: _detailControllers[index]['eveningDosage']!,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null ||
                          double.parse(value) < 0) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppField(
                    labelText: 'Dosage Unit',
                    controller: _detailControllers[index]['dosageUnit']!,
                    required: false,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppField(
                    labelText: 'Duration (days)',
                    controller: _detailControllers[index]['durationDays']!,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (int.tryParse(value) == null ||
                          int.parse(value) <= 0) {
                        return 'Enter valid days';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppField(
              labelText: 'Instructions',
              controller: _detailControllers[index]['instructions']!,
              required: false,
            ),
          ],
        ),
      ),
    );
  }
}
