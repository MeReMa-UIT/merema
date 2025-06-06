import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/features/patients/presentation/bloc/patients_state_cubit.dart';
import 'package:merema/features/patients/presentation/bloc/patient_infos_state_cubit.dart';
import 'package:merema/features/patients/presentation/widgets/patients_sidebar.dart';
import 'package:merema/features/patients/presentation/widgets/patient_info_receptionist_view.dart';
import 'package:merema/features/patients/presentation/widgets/patient_register_view.dart';

class PatientsReceptionistPage extends StatefulWidget {
  final int? patientId;
  final String? patientName;

  const PatientsReceptionistPage({
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
          ],
          child: PatientsReceptionistPage(
            patientId: patientId,
            patientName: patientName,
          ),
        ),
      );

  @override
  State<PatientsReceptionistPage> createState() =>
      _PatientsReceptionistPageState();
}

class _PatientsReceptionistPageState extends State<PatientsReceptionistPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int? _selectedPatientId;
  String? _selectedPatientName;
  bool _isShowingRegisterView = false;

  @override
  void initState() {
    super.initState();
    if (widget.patientId != null && widget.patientName != null) {
      _selectedPatientId = widget.patientId;
      _selectedPatientName = widget.patientName;
    }
  }

  void _onPatientSelected(int patientId, String patientName) {
    setState(() {
      _selectedPatientId = patientId;
      _selectedPatientName = patientName;
      _isShowingRegisterView = false;
    });

    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }
  }

  void _onShowRegisterView() {
    setState(() {
      _isShowingRegisterView = true;
      _selectedPatientId = null;
      _selectedPatientName = null;
    });
  }

  void _onCancelRegister() {
    setState(() {
      _isShowingRegisterView = false;
    });
  }

  void _onSuccessRegister() {
    setState(() {
      _isShowingRegisterView = false;
      _selectedPatientId = null;
      _selectedPatientName = null;
    });
    context.read<PatientsCubit>().getPatients();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Patients'),
        backgroundColor: AppPallete.backgroundColor,
        foregroundColor: AppPallete.textColor,
        leading: isLargeScreen
            ? (Navigator.of(context).canPop()
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: BackButton(),
                  )
                : null)
            : (Navigator.of(context).canPop()
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: BackButton(),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                  )),
        automaticallyImplyLeading: false,
        actions: !isLargeScreen
            ? [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.people),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                ),
              ]
            : null,
      ),
      drawer: isLargeScreen
          ? null
          : Drawer(
              backgroundColor: AppPallete.backgroundColor,
              child: PatientsSidebar(
                onPatientSelected: _onPatientSelected,
                onShowRegisterView: _onShowRegisterView,
                selectedPatientId: _selectedPatientId,
              ),
            ),
      backgroundColor: AppPallete.backgroundColor,
      body: isLargeScreen
          ? Row(
              children: [
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
                      onShowRegisterView: _onShowRegisterView,
                      selectedPatientId: _selectedPatientId,
                    ),
                  ),
                ),
                Expanded(
                  child: _isShowingRegisterView
                      ? PatientRegisterView(
                          onCancel: _onCancelRegister,
                          onSuccess: _onSuccessRegister,
                        )
                      : _selectedPatientId != null &&
                              _selectedPatientName != null
                          ? PatientInfoReceptionistView(
                              patientId: _selectedPatientId!,
                              patientName: _selectedPatientName!,
                            )
                          : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    color: AppPallete.lightGrayColor,
                                    size: 64,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Select a patient to view information',
                                    style: TextStyle(
                                      color: AppPallete.darkGrayColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                ),
              ],
            )
          : _isShowingRegisterView
              ? PatientRegisterView(
                  onCancel: _onCancelRegister,
                  onSuccess: _onSuccessRegister,
                )
              : _selectedPatientId != null && _selectedPatientName != null
                  ? PatientInfoReceptionistView(
                      patientId: _selectedPatientId!,
                      patientName: _selectedPatientName!,
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            color: AppPallete.lightGrayColor,
                            size: 64,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Open patients list to select a patient',
                            style: TextStyle(
                              color: AppPallete.darkGrayColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
