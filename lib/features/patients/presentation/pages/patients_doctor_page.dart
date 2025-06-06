// TODO: Add records management

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/features/patients/presentation/bloc/patients_state_cubit.dart';
import 'package:merema/features/patients/presentation/bloc/patient_infos_state_cubit.dart';
import 'package:merema/features/patients/presentation/widgets/patients_sidebar.dart';
import 'package:merema/features/patients/presentation/widgets/patient_info_doctor_view.dart';
import 'package:merema/features/prescriptions/presentation/bloc/prescriptions_state_cubit.dart';
import 'package:merema/features/prescriptions/presentation/bloc/medications_state_cubit.dart';
import 'package:merema/features/prescriptions/presentation/bloc/prescriptions_state.dart';
import 'package:merema/features/prescriptions/presentation/widgets/prescription_card.dart';
import 'package:merema/features/prescriptions/presentation/widgets/prescription_details_dialog.dart';
import 'dart:io';
import 'package:window_size/window_size.dart';

class PatientsDoctorPage extends StatefulWidget {
  final int? patientId;
  final String? patientName;

  const PatientsDoctorPage({
    super.key,
    this.patientId,
    this.patientName,
  });

  static Route route({int? patientId, String? patientName}) =>
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => PatientsCubit()..getPatients(),
            ),
            BlocProvider(
              create: (context) => PatientInfosCubit(),
            ),
            BlocProvider(
              create: (context) => PrescriptionsCubit(),
            ),
            BlocProvider(
              create: (context) => MedicationsCubit(),
            ),
          ],
          child: PatientsDoctorPage(
            patientId: patientId,
            patientName: patientName,
          ),
        ),
      );

  @override
  State<PatientsDoctorPage> createState() => _PatientsDoctorPageState();
}

class _PatientsDoctorPageState extends State<PatientsDoctorPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int? _selectedPatientId;
  String? _selectedPatientName;
  bool _showSidebar = true;
  bool _isEditingPatientInfo = false;
  Size? _originalWindowSize;

  @override
  void initState() {
    super.initState();

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final currentSize = await getWindowInfo();
        _originalWindowSize =
            Size(currentSize.frame.width, currentSize.frame.height);

        setWindowMinSize(const Size(1280, 720));
      });
    }

    if (widget.patientId != null && widget.patientName != null) {
      _selectedPatientId = widget.patientId;
      _selectedPatientName = widget.patientName;
      _showSidebar = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context
              .read<PrescriptionsCubit>()
              .getPrescriptionsByPatient(widget.patientId!);
        }
      });
    } else {
      _showSidebar = true;
    }
  }

  @override
  void dispose() {
    if ((Platform.isWindows || Platform.isLinux || Platform.isMacOS) &&
        _originalWindowSize != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setWindowMinSize(const Size(600, 800));
      });
    }

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onPatientSelected(int patientId, String patientName) {
    setState(() {
      _selectedPatientId = patientId;
      _selectedPatientName = patientName;
      _showSidebar = false;
      _isEditingPatientInfo = false;
    });
    context.read<PrescriptionsCubit>().getPrescriptionsByPatient(patientId);

    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }
  }

  void _toggleSidebar() {
    setState(() {
      _showSidebar = !_showSidebar;
    });
  }

  Widget _buildPrescriptionsList() {
    if (_selectedPatientId == null) {
      return const Center(
          child: Text('Select a patient to see prescriptions.'));
    }
    return BlocBuilder<PrescriptionsCubit, PrescriptionsState>(
      builder: (context, state) {
        if (state is PrescriptionsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PrescriptionsLoaded) {
          final prescriptions = state.prescriptions;
          if (prescriptions.isEmpty) {
            return Center(
              child: Text(
                'No prescriptions found for $_selectedPatientName',
                style:
                    const TextStyle(color: AppPallete.textColor, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.builder(
            itemCount: prescriptions.length,
            itemBuilder: (context, index) {
              final prescription = prescriptions[index];
              return Padding(
                padding:
                    const EdgeInsets.only(bottom: 16.0, left: 8.0, right: 8.0),
                child: PrescriptionCard(
                  prescription: prescription,
                  onViewDetails: () =>
                      _showPrescriptionDetails(prescription.prescriptionId),
                ),
              );
            },
          );
        } else if (state is PrescriptionsError) {
          return Center(
            child: Text(
              'Error: ${state.message}',
              style:
                  const TextStyle(color: AppPallete.errorColor, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showPrescriptionDetails(int prescriptionId) {
    showDialog(
      context: context,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => PrescriptionsCubit()),
          BlocProvider(create: (_) => MedicationsCubit()),
        ],
        child: Dialog(
          backgroundColor: AppPallete.backgroundColor,
          child: Container(
            width: 600,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16),
            child: Builder(
              builder: (context) {
                context
                    .read<PrescriptionsCubit>()
                    .getPrescriptionDetails(prescriptionId);

                return BlocBuilder<PrescriptionsCubit, PrescriptionsState>(
                  builder: (context, state) {
                    if (state is PrescriptionDetailsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is PrescriptionDetailsLoaded) {
                      return PrescriptionDetailsDialog(
                          prescriptionDetails: state.details);
                    } else if (state is PrescriptionsError) {
                      return Center(
                        child: Text(
                          'Error loading details: ${state.message}',
                          style: const TextStyle(color: AppPallete.errorColor),
                        ),
                      );
                    }
                    return const Center(child: Text('Loading...'));
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLargeScreenContent(BuildContext context) {
    if (_selectedPatientId != null && _selectedPatientName != null) {
      return Column(
        children: [
          PatientInfoDoctorView(
            patientId: _selectedPatientId!,
            patientName: _selectedPatientName!,
            onEditingChanged: (isEditing) {
              setState(() {
                _isEditingPatientInfo = isEditing;
              });
              if (!isEditing) {
                context.read<PatientsCubit>().getPatients();
              }
            },
          ),
          if (!_isEditingPatientInfo)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    flex: 2,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "Medical Records Placeholder: Patient's medical history and records will be displayed here.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppPallete.darkGrayColor, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: AppPallete.lightGrayColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: _buildPrescriptionsList(),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    } else {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search_outlined,
              color: AppPallete.lightGrayColor,
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              'Select a patient from the sidebar to view their information, medical records, and prescriptions.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppPallete.darkGrayColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppPallete.backgroundColor,
      appBar: AppBar(
        title: const Text('Patients'),
        backgroundColor: AppPallete.backgroundColor,
        foregroundColor: AppPallete.textColor,
        leading: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            IconButton(
              icon: Icon(_showSidebar ? Icons.close : Icons.menu),
              onPressed: _toggleSidebar,
              tooltip:
                  _showSidebar ? 'Hide Patients List' : 'Show Patients List',
            ),
          ],
        ),
        leadingWidth: 96,
      ),
      body: Row(
        children: [
          if (_showSidebar)
            SizedBox(
              width: 350,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: AppPallete.lightGrayColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: PatientsSidebar(
                  onPatientSelected: _onPatientSelected,
                  onShowRegisterView: null,
                  selectedPatientId: _selectedPatientId,
                ),
              ),
            ),
          Expanded(
            child: _buildLargeScreenContent(context),
          ),
        ],
      ),
    );
  }
}
