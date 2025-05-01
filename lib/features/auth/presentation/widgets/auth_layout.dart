import 'package:flutter/material.dart';

class AuthLayout extends StatelessWidget {
  final List<Widget> children;
  final double fieldWidth;
  final double sidePadding;
  final bool showBackButton;

  const AuthLayout({
    super.key,
    required this.children,
    this.fieldWidth = 400,
    this.sidePadding = 24.0,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showBackButton
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;

          final contentWidth = availableWidth > (fieldWidth + 2 * sidePadding)
              ? fieldWidth
              : availableWidth - 2 * sidePadding;

          return Center(
            child: SizedBox(
              width: contentWidth,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: sidePadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: children,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
