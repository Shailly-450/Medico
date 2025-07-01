import 'package:flutter/material.dart';
import '../../../models/service_provider.dart';
import '../../../models/medical_service.dart';

class ProviderComparisonCard extends StatelessWidget {
  final ServiceProvider provider;
  final List<MedicalService> services;
  final String selectedCategory;

  const ProviderComparisonCard({
    Key? key,
    required this.provider,
    required this.services,
    required this.selectedCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Implement detailed UI for provider and services
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(provider.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Category: $selectedCategory'),
            const SizedBox(height: 8),
            ...services.map((service) => Text(service.name)).toList(),
          ],
        ),
      ),
    );
  }
} 