import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/core/layers/presentation/widgets/info_card.dart';
import 'package:merema/features/staffs/presentation/bloc/staff_infos_state.dart';
import 'package:merema/features/staffs/presentation/bloc/staff_infos_state_cubit.dart';
import 'package:merema/features/staffs/presentation/widgets/staff_update_info_view.dart';

class StaffInfoView extends StatefulWidget {
  final int staffId;
  final String staffName;

  const StaffInfoView({
    super.key,
    required this.staffId,
    required this.staffName,
  });

  @override
  State<StaffInfoView> createState() => _StaffInfoViewState();
}

class _StaffInfoViewState extends State<StaffInfoView> {
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    context.read<StaffInfosCubit>().getInfos(widget.staffId);
  }

  @override
  void didUpdateWidget(StaffInfoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.staffId != widget.staffId) {
      context.read<StaffInfosCubit>().getInfos(widget.staffId);
      _isEditing = false;
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _onUpdateSuccess() {
    setState(() {
      _isEditing = false;
    });
    context.read<StaffInfosCubit>().getInfos(widget.staffId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StaffInfosCubit, StaffInfosState>(
      builder: (context, state) {
        if (state is StaffInfosLoaded && _isEditing) {
          return StaffUpdateInfoView(
            staffId: widget.staffId,
            staffName: widget.staffName,
            staffInfo: state.staffInfo,
            onCancel: _toggleEditMode,
            onSuccess: _onUpdateSuccess,
          );
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppPallete.backgroundColor,
                border: Border(
                  bottom: BorderSide(
                    color: AppPallete.lightGrayColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppPallete.primaryColor,
                    radius: 20,
                    child: Text(
                      widget.staffName.isNotEmpty
                          ? widget.staffName[0].toUpperCase()
                          : '',
                      style: const TextStyle(
                        color: AppPallete.backgroundColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.staffName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppPallete.textColor,
                      ),
                    ),
                  ),
                  if (state is StaffInfosLoaded)
                    IconButton(
                      icon: const Icon(Icons.edit,
                          color: AppPallete.primaryColor),
                      tooltip: 'Edit Info',
                      onPressed: _toggleEditMode,
                    ),
                ],
              ),
            ),
            Expanded(
              child: _buildContent(state),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent(StaffInfosState state) {
    if (state is StaffInfosLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppPallete.primaryColor,
        ),
      );
    }

    if (state is StaffInfosError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppPallete.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: const TextStyle(
                fontSize: 18,
                color: AppPallete.errorColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (state is StaffInfosLoaded) {
      final staff = state.staffInfo;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoCard(
                  title: 'Personal Information',
                  icon: Icons.person,
                  fields: [
                    InfoField(label: 'Full Name', value: staff.fullName),
                    InfoField(
                        label: 'Date of Birth',
                        value: staff.dateOfBirth.split('T')[0]),
                    InfoField(label: 'Gender', value: staff.gender),
                  ],
                ),
                const SizedBox(height: 16),
                InfoCard(
                  title: 'Work Information',
                  icon: Icons.work,
                  fields: [
                    InfoField(label: 'Department', value: staff.department),
                    InfoField(
                        label: 'Staff ID', value: staff.staffId.toString()),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const Center(
      child: Text('No staff information available'),
    );
  }
}
