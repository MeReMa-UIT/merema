import 'package:flutter/material.dart';
import 'package:merema/core/theme/app_pallete.dart';

class PrescriptionsPatientPage extends StatelessWidget {
  const PrescriptionsPatientPage({super.key});

  static Route route() => MaterialPageRoute(
        builder: (context) => const PrescriptionsPatientPage(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Prescriptions'),
        backgroundColor: AppPallete.backgroundColor,
        foregroundColor: AppPallete.textColor,
      ),
      backgroundColor: AppPallete.backgroundColor,
      body: const Center(
        child: Text(
          'Patient Prescriptions Page\n(Under Development)',
          style: TextStyle(
            fontSize: 18,
            color: AppPallete.textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// TODOL: Implement prescriptions patient page