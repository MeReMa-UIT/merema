import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/features/staffs/presentation/bloc/staffs_state_cubit.dart';
import 'package:merema/features/staffs/presentation/bloc/staff_infos_state_cubit.dart';
import 'package:merema/features/staffs/presentation/widgets/staffs_sidebar.dart';
import 'package:merema/features/staffs/presentation/widgets/staff_info_view.dart';
import 'package:merema/features/staffs/presentation/widgets/staff_register_view.dart';

class StaffsPage extends StatefulWidget {
  final int? staffId;
  final String? staffName;

  const StaffsPage({
    super.key,
    this.staffId,
    this.staffName,
  });

  static Route route({int? staffId, String? staffName}) => MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => StaffsCubit()..getStaffs(),
            ),
            BlocProvider(
              create: (context) => StaffInfosCubit(),
            ),
          ],
          child: StaffsPage(
            staffId: staffId,
            staffName: staffName,
          ),
        ),
      );

  @override
  State<StaffsPage> createState() => _StaffsPageState();
}

class _StaffsPageState extends State<StaffsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int? _selectedStaffId;
  String? _selectedStaffName;
  bool _isShowingRegisterView = false;

  @override
  void initState() {
    super.initState();
    if (widget.staffId != null && widget.staffName != null) {
      _selectedStaffId = widget.staffId;
      _selectedStaffName = widget.staffName;
    }
  }

  void _onStaffSelected(int staffId, String staffName) {
    setState(() {
      _selectedStaffId = staffId;
      _selectedStaffName = staffName;
      _isShowingRegisterView = false;
    });

    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }
  }

  void _onShowRegisterView() {
    setState(() {
      _isShowingRegisterView = true;
      _selectedStaffId = null;
      _selectedStaffName = null;
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
      _selectedStaffId = null;
      _selectedStaffName = null;
    });
    context.read<StaffsCubit>().getStaffs();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Staffs'),
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
              child: StaffsSidebar(
                onStaffSelected: _onStaffSelected,
                onShowRegisterView: _onShowRegisterView,
                selectedStaffId: _selectedStaffId,
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
                    child: StaffsSidebar(
                      onStaffSelected: _onStaffSelected,
                      onShowRegisterView: _onShowRegisterView,
                      selectedStaffId: _selectedStaffId,
                    ),
                  ),
                ),
                Expanded(
                  child: _isShowingRegisterView
                      ? StaffRegisterView(
                          onCancel: _onCancelRegister,
                          onSuccess: _onSuccessRegister,
                        )
                      : _selectedStaffId != null && _selectedStaffName != null
                          ? StaffInfoView(
                              staffId: _selectedStaffId!,
                              staffName: _selectedStaffName!,
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
                                    'Select a staff to view information',
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
              ? StaffRegisterView(
                  onCancel: _onCancelRegister,
                  onSuccess: _onSuccessRegister,
                )
              : _selectedStaffId != null && _selectedStaffName != null
                  ? StaffInfoView(
                      staffId: _selectedStaffId!,
                      staffName: _selectedStaffName!,
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
                            'Open staffs list to select a staff',
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
