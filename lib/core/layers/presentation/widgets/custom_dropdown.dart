import 'package:flutter/material.dart';
import 'package:merema/core/theme/app_pallete.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? selectedValue;
  final List<T> availableItems;
  final Function(T?) onChanged;
  final String? labelText;
  final String Function(T) getDisplayText;
  final String Function(T)? getValueKey;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const CustomDropdown({
    super.key,
    required this.selectedValue,
    required this.availableItems,
    required this.onChanged,
    required this.getDisplayText,
    this.labelText = 'Select Item',
    this.getValueKey,
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? EdgeInsets.zero,
      child: DropdownButtonFormField<T>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: AppPallete.textColor),
        ),
        dropdownColor: AppPallete.backgroundColor,
        style: const TextStyle(color: AppPallete.textColor),
        icon: const Icon(Icons.arrow_drop_down, color: AppPallete.textColor),
        onChanged: onChanged,
        items: availableItems.map<DropdownMenuItem<T>>((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              getDisplayText(item),
              style: const TextStyle(color: AppPallete.textColor),
            ),
          );
        }).toList(),
      ),
    );
  }
}
