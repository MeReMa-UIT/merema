import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:merema/core/theme/app_pallete.dart';
import 'package:merema/features/records/presentation/bloc/records_state_cubit.dart';
import 'package:merema/features/records/presentation/bloc/records_state.dart';
import 'package:merema/features/records/presentation/widgets/record_details_view.dart';

class RecordDetailsPage extends StatefulWidget {
  final int recordId;
  final String? title;

  const RecordDetailsPage({
    super.key,
    required this.recordId,
    this.title,
  });

  static Route route({required int recordId, String? title}) =>
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (_) => RecordsCubit()..getRecordDetails(recordId),
          child: RecordDetailsPage(recordId: recordId, title: title),
        ),
      );

  @override
  State<RecordDetailsPage> createState() => _RecordDetailsPageState();
}

class _RecordDetailsPageState extends State<RecordDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Record Details'),
        backgroundColor: AppPallete.backgroundColor,
        foregroundColor: AppPallete.textColor,
      ),
      backgroundColor: AppPallete.backgroundColor,
      body: BlocBuilder<RecordsCubit, RecordsState>(
        builder: (context, state) {
          if (state is RecordDetailsLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppPallete.primaryColor,
              ),
            );
          } else if (state is RecordDetailsLoaded) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: RecordDetailsView(
                    recordDetail: state.recordDetail,
                  ),
                ),
              ),
            );
          } else if (state is RecordsError) {
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
                    'Error: ${state.message}',
                    style: const TextStyle(
                      color: AppPallete.errorColor,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<RecordsCubit>()
                          .getRecordDetails(widget.recordId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPallete.primaryColor,
                      foregroundColor: AppPallete.textColor,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const Center(
            child: Text(
              'Loading record details...',
              style: TextStyle(color: AppPallete.textColor),
            ),
          );
        },
      ),
    );
  }
}
