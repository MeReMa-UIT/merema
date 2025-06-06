import 'package:flutter/material.dart';
import 'package:merema/core/layers/presentation/widgets/app_field.dart';
import 'package:merema/core/layers/presentation/widgets/app_button.dart';
import 'package:merema/core/theme/app_pallete.dart';

class PeopleSidebar<T> extends StatefulWidget {
  final String title;
  final List<T> people;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final Function(T person) onPersonSelected;
  final VoidCallback? onShowRegisterView;
  final VoidCallback onRetry;
  final VoidCallback onSearch;
  final VoidCallback onClearSearch;
  final TextEditingController searchController;
  final T? selectedPerson;
  final String Function(T person) getPersonId;
  final String Function(T person) getPersonName;
  final String Function(T person) getPersonSubtitle;
  final bool showRegisterButton;

  const PeopleSidebar({
    super.key,
    required this.title,
    required this.people,
    required this.isLoading,
    required this.hasError,
    this.errorMessage,
    required this.onPersonSelected,
    this.onShowRegisterView,
    required this.onRetry,
    required this.onSearch,
    required this.onClearSearch,
    required this.searchController,
    this.selectedPerson,
    required this.getPersonId,
    required this.getPersonName,
    required this.getPersonSubtitle,
    this.showRegisterButton = true,
  });

  @override
  State<PeopleSidebar<T>> createState() => _PeopleSidebarState<T>();
}

class _PeopleSidebarState<T> extends State<PeopleSidebar<T>> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppPallete.textColor,
                    ),
                  ),
                  if (widget.showRegisterButton &&
                      widget.onShowRegisterView != null)
                    IconButton(
                      icon: const Icon(
                        Icons.person_add,
                        color: AppPallete.primaryColor,
                      ),
                      tooltip:
                          'Register ${widget.title.substring(0, widget.title.length - 1)}',
                      onPressed: widget.onShowRegisterView,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              AppField(
                labelText: 'Search ${widget.title.toLowerCase()}',
                controller: widget.searchController,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Clear',
                      onPressed: widget.onClearSearch,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Search',
                      onPressed: widget.onSearch,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppPallete.primaryColor,
        ),
      );
    }

    if (widget.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppPallete.errorColor,
              size: 64,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.errorMessage ?? 'An error occurred',
                style: const TextStyle(
                  color: AppPallete.errorColor,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: AppButton(
                text: 'Retry',
                onPressed: widget.onRetry,
              ),
            ),
          ],
        ),
      );
    }

    if (widget.people.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              color: AppPallete.lightGrayColor,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No ${widget.title.toLowerCase()} found',
              style: const TextStyle(
                color: AppPallete.darkGrayColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: widget.people.length,
      itemBuilder: (context, index) {
        final person = widget.people[index];
        final isSelected = widget.selectedPerson != null &&
            widget.getPersonId(person) ==
                widget.getPersonId(widget.selectedPerson!);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          color: isSelected ? AppPallete.primaryColor : Colors.white,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isSelected
                  ? AppPallete.backgroundColor
                  : AppPallete.secondaryColor,
              child: Text(
                widget.getPersonName(person).isNotEmpty
                    ? widget.getPersonName(person)[0].toUpperCase()
                    : '',
                style: TextStyle(
                  color: isSelected
                      ? AppPallete.primaryColor
                      : AppPallete.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              widget.getPersonName(person),
              style: TextStyle(
                color: AppPallete.textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            subtitle: Text(
              widget.getPersonSubtitle(person),
              style: const TextStyle(
                color: AppPallete.darkGrayColor,
                fontSize: 12,
              ),
            ),
            trailing: Icon(
              isSelected ? Icons.keyboard_arrow_right : Icons.arrow_forward_ios,
              color:
                  isSelected ? AppPallete.textColor : AppPallete.lightGrayColor,
            ),
            onTap: () {
              widget.onPersonSelected(person);
            },
          ),
        );
      },
    );
  }
}
