import 'package:flutter/material.dart';
import '../../../models/service_provider.dart';

class ProviderSelectionDialog extends StatelessWidget {
  final List<ServiceProvider> providers;
  final List<ServiceProvider> selectedProviders;
  final ValueChanged<ServiceProvider> onProviderSelected;

  const ProviderSelectionDialog({
    Key? key,
    required this.providers,
    required this.selectedProviders,
    required this.onProviderSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Implement provider selection UI
    return AlertDialog(
      title: const Text('Select Provider'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: providers.map((provider) {
            final isSelected = selectedProviders.contains(provider);
            return ListTile(
              title: Text(provider.name),
              trailing: isSelected ? const Icon(Icons.check) : null,
              onTap: () {
                if (!isSelected) onProviderSelected(provider);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }
} 