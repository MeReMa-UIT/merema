import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/features/statistics/presentation/bloc/statistics_state_cubit.dart';
import 'package:merema/features/statistics/presentation/bloc/statistics_state.dart';
import 'package:merema/features/statistics/presentation/widgets/statistics_chart.dart';
import 'package:merema/features/statistics/presentation/widgets/time_period_selector.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  static Route route() => MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => StatisticsCubit(),
          child: const StatisticsPage(),
        ),
      );

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String _selectedTimeUnit = 'month';
  String _selectedTimestamp = DateTime.now().toUtc().toIso8601String();
  String? _selectedView;
  String? _selectedKey;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  void _loadStatistics() {
    context.read<StatisticsCubit>().loadStatistics(
          timeUnit: _selectedTimeUnit,
          timestamp: _selectedTimestamp,
        );
  }

  void _onTimeUnitChanged(String timeUnit) {
    setState(() {
      _selectedTimeUnit = timeUnit;
    });
    _loadStatistics();
  }

  void _onTimestampChanged(String timestamp) {
    setState(() {
      _selectedTimestamp = timestamp;
    });
    _loadStatistics();
  }

  void _showDiagnosisDetails(String diagnosisId) {
    setState(() {
      _selectedView = 'diagnosis';
      _selectedKey = diagnosisId;
    });
  }

  void _showDoctorDetails(String doctorId) {
    setState(() {
      _selectedView = 'doctor';
      _selectedKey = doctorId;
    });
  }

  void _backToSummary() {
    setState(() {
      _selectedView = null;
      _selectedKey = null;
    });
  }

  String _getPageTitle() {
    if (_selectedView == 'diagnosis' && _selectedKey != null) {
      return 'Diagnosis Details';
    } else if (_selectedView == 'doctor' && _selectedKey != null) {
      return 'Doctor Details';
    }
    return 'Statistics Overview';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle()),
        backgroundColor: AppPallete.backgroundColor,
        foregroundColor: AppPallete.textColor,
        leading: _selectedView != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _backToSummary,
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
            tooltip: 'Refresh Statistics',
          ),
        ],
      ),
      body: BlocBuilder<StatisticsCubit, StatisticsState>(
        builder: (context, state) {
          return Column(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TimePeriodSelector(
                    selectedTimeUnit: _selectedTimeUnit,
                    selectedTimestamp: _selectedTimestamp,
                    onTimeUnitChanged: _onTimeUnitChanged,
                    onTimestampChanged: _onTimestampChanged,
                  ),
                ),
              ),

              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: _buildContent(state),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(StatisticsState state) {
    if (state is StatisticsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is StatisticsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.message}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStatistics,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is! StatisticsLoaded) {
      return const Center(child: Text('No data available'));
    }

    if (_selectedView != null && _selectedKey != null) {
      return _buildDetailedView(state);
    }

    return _buildSummaryView(state);
  }

  Widget _buildSummaryView(StatisticsLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCards(state),
          const SizedBox(height: 24),

          if (state.recordsStatistics.isNotEmpty) ...[
            const Text(
              'Records Over Time',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            StatisticsChart(
              title: 'Medical Records Timeline',
              data: state.recordsStatistics
                  .map((record) => {
                        'x': record.timestampStart,
                        'y': record.amount,
                        'time': record.timestampStart,
                      })
                  .toList(),
              height: 250,
              showLabelsOnXAxis: true,
              xAxisKey: 'x',
              timeUnit: _selectedTimeUnit,
            ),
            const SizedBox(height: 24),
          ],

          if (state.diagnosisStatistics.isNotEmpty) ...[
            const Text(
              'Top Diagnoses',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            StatisticsChart(
              title: 'Records by Diagnosis',
              data: state.diagnosisStatistics
                  .take(10)
                  .map((diagnosis) => {
                        'x': context
                            .read<StatisticsCubit>()
                            .getDiagnosisName(diagnosis.diagnosisId),
                        'y': diagnosis.totalAmount,
                        'diagnosis_id': diagnosis.diagnosisId,
                      })
                  .toList(),
              height: 250,
              showLabelsOnXAxis: true,
              xAxisKey: 'x',
              onPointTap: (data) => _showDiagnosisDetails(data['diagnosis_id']),
            ),
            const SizedBox(height: 24),
          ],

          if (state.doctorStatistics.isNotEmpty) ...[
            const Text(
              'Top Doctors',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            StatisticsChart(
              title: 'Records by Doctor',
              data: state.doctorStatistics
                  .take(10)
                  .map((doctor) => {
                        'x': context
                            .read<StatisticsCubit>()
                            .getStaffName(doctor.doctorId),
                        'y': doctor.totalAmount,
                        'doctor_id': doctor.doctorId,
                      })
                  .toList(),
              height: 250,
              showLabelsOnXAxis: true,
              xAxisKey: 'x',
              onPointTap: (data) =>
                  _showDoctorDetails(data['doctor_id'].toString()),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverviewCards(StatisticsLoaded state) {
    final totalRecords = state.recordsStatistics.fold<int>(
      0,
      (sum, record) => sum + record.amount,
    );

    final totalDiagnoses = state.diagnosisStatistics.length;
    final totalDoctors = state.doctorStatistics.length;

    final topDiagnosis = state.diagnosisStatistics.isNotEmpty
        ? state.diagnosisStatistics
            .reduce((a, b) => a.totalAmount > b.totalAmount ? a : b)
        : null;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildOverviewCard(
          'Total Records',
          totalRecords.toString(),
          Icons.assignment,
          AppPallete.primaryColor,
        ),
        _buildOverviewCard(
          'Active Diagnoses',
          totalDiagnoses.toString(),
          Icons.medical_services,
          AppPallete.secondaryColor,
        ),
        _buildOverviewCard(
          'Active Doctors',
          totalDoctors.toString(),
          Icons.person,
          AppPallete.darkGrayColor,
        ),
        _buildOverviewCard(
          'Top Diagnosis',
          topDiagnosis != null
              ? context
                  .read<StatisticsCubit>()
                  .getDiagnosisName(topDiagnosis.diagnosisId)
              : 'N/A',
          Icons.trending_up,
          AppPallete.errorColor,
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedView(StatisticsLoaded state) {
    if (_selectedView == 'diagnosis') {
      return _buildDiagnosisDetailView(state);
    } else if (_selectedView == 'doctor') {
      return _buildDoctorDetailView(state);
    }
    return const Center(child: Text('Invalid detail view'));
  }

  Widget _buildDiagnosisDetailView(StatisticsLoaded state) {
    final diagnosis = state.diagnosisStatistics.firstWhere(
      (d) => d.diagnosisId == _selectedKey,
      orElse: () => throw StateError('Diagnosis not found'),
    );

    final diagnosisName =
        context.read<StatisticsCubit>().getDiagnosisName(diagnosis.diagnosisId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.medical_services,
                          color: AppPallete.primaryColor, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              diagnosisName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Diagnosis ID: ${diagnosis.diagnosisId}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                      'Total Records', diagnosis.totalAmount.toString()),
                  if (diagnosis.amountByTime != null &&
                      diagnosis.amountByTime!.isNotEmpty)
                    _buildDetailRow(
                        'Average per Period',
                        (diagnosis.totalAmount / diagnosis.amountByTime!.length)
                            .toStringAsFixed(1)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          if (diagnosis.amountByTime != null &&
              diagnosis.amountByTime!.isNotEmpty) ...[
            const Text(
              'Detailed Timeline for This Diagnosis',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            StatisticsChart(
              title: 'Records Over Time for $diagnosisName',
              data: diagnosis.amountByTime!
                  .map((record) => {
                        'x': record.timestampStart,
                        'y': record.amount,
                        'time': record.timestampStart,
                      })
                  .toList(),
              height: 250,
              showLabelsOnXAxis: true,
              xAxisKey: 'x',
              timeUnit: _selectedTimeUnit,
            ),
            const SizedBox(height: 24),
          ],

          const Text(
            'Comparison with Other Diagnoses',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          StatisticsChart(
            title: 'All Diagnoses Comparison',
            data: state.diagnosisStatistics
                .map((d) => {
                      'x': context
                          .read<StatisticsCubit>()
                          .getDiagnosisName(d.diagnosisId),
                      'y': d.totalAmount,
                      'diagnosis_id': d.diagnosisId,
                      'is_selected': d.diagnosisId == _selectedKey,
                    })
                .toList(),
            height: 300,
            showLabelsOnXAxis: true,
            xAxisKey: 'x',
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorDetailView(StatisticsLoaded state) {
    final doctor = state.doctorStatistics.firstWhere(
      (d) => d.doctorId.toString() == _selectedKey,
      orElse: () => throw StateError('Doctor not found'),
    );

    final doctorName =
        context.read<StatisticsCubit>().getStaffName(doctor.doctorId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person,
                          color: AppPallete.primaryColor, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctorName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Doctor ID: ${doctor.doctorId}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                      'Total Records', doctor.totalAmount.toString()),
                  if (doctor.amountByTime != null &&
                      doctor.amountByTime!.isNotEmpty)
                    _buildDetailRow(
                        'Average per Period',
                        (doctor.totalAmount / doctor.amountByTime!.length)
                            .toStringAsFixed(1)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          if (doctor.amountByTime != null &&
              doctor.amountByTime!.isNotEmpty) ...[
            const Text(
              'Detailed Timeline for This Doctor',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            StatisticsChart(
              title: 'Records Over Time for Dr. $doctorName',
              data: doctor.amountByTime!
                  .map((record) => {
                        'x': record.timestampStart,
                        'y': record.amount,
                        'time': record.timestampStart,
                      })
                  .toList(),
              height: 250,
              showLabelsOnXAxis: true,
              xAxisKey: 'x',
              timeUnit: _selectedTimeUnit,
            ),
            const SizedBox(height: 24),
          ],

          const Text(
            'Comparison with Other Doctors',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          StatisticsChart(
            title: 'All Doctors Comparison',
            data: state.doctorStatistics
                .map((d) => {
                      'x': context
                          .read<StatisticsCubit>()
                          .getStaffName(d.doctorId),
                      'y': d.totalAmount,
                      'doctor_id': d.doctorId,
                      'is_selected': d.doctorId.toString() == _selectedKey,
                    })
                .toList(),
            height: 300,
            showLabelsOnXAxis: true,
            xAxisKey: 'x',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppPallete.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
