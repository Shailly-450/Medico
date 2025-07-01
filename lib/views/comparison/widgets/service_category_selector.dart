import 'package:flutter/material.dart';

class ServiceCategorySelector extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  const ServiceCategorySelector({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with chips or dropdown as needed
    return DropdownButton<String>(
      value: selectedCategory,
      items: categories.map((cat) => DropdownMenuItem(
        value: cat,
        child: Text(cat),
      )).toList(),
      onChanged: (val) {
        if (val != null) onCategoryChanged(val);
      },
    );
  }
} 