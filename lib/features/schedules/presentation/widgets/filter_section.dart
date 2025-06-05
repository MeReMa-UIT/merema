import 'package:flutter/material.dart';
import 'package:merema/core/layers/domain/entities/user_role.dart';
import 'package:merema/core/theme/app_pallete.dart';

class FilterSection extends StatelessWidget {
  final UserRole userRole;
  final TextEditingController searchController;
  final String searchQuery;
  final List<int> selectedTypes;
  final List<int> selectedStatuses;
  final Function(String) onSearchChanged;
  final Function(int) onTypeToggle;
  final Function(int) onStatusToggle;

  const FilterSection({
    super.key,
    required this.userRole,
    required this.searchController,
    required this.searchQuery,
    required this.selectedTypes,
    required this.selectedStatuses,
    required this.onSearchChanged,
    required this.onTypeToggle,
    required this.onStatusToggle,
  });

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected ? AppPallete.primaryColor : AppPallete.backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppPallete.primaryColor
                : AppPallete.lightGrayColor,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                isSelected ? AppPallete.backgroundColor : AppPallete.textColor,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppPallete.backgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                if (userRole == UserRole.receptionist) ...[
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search schedule ID',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: onSearchChanged,
                  ),
                  const SizedBox(height: 8),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFilterChip(
                      label: 'Regular',
                      isSelected: selectedTypes.contains(1),
                      onTap: () => onTypeToggle(1),
                    ),
                    _buildFilterChip(
                      label: 'Service',
                      isSelected: selectedTypes.contains(2),
                      onTap: () => onTypeToggle(2),
                    ),
                    Container(
                      height: 32,
                      width: 1,
                      color: AppPallete.lightGrayColor,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    _buildFilterChip(
                      label: 'Waiting',
                      isSelected: selectedStatuses.contains(1),
                      onTap: () => onStatusToggle(1),
                    ),
                    _buildFilterChip(
                      label: 'Completed',
                      isSelected: selectedStatuses.contains(2),
                      onTap: () => onStatusToggle(2),
                    ),
                    _buildFilterChip(
                      label: 'Cancelled',
                      isSelected: selectedStatuses.contains(3),
                      onTap: () => onStatusToggle(3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
