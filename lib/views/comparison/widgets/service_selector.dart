import 'package:flutter/material.dart';

class ServiceSelector extends StatelessWidget {
  final List<String> services;
  final String selectedService;
  final ValueChanged<String> onServiceChanged;

  const ServiceSelector({
    Key? key,
    required this.services,
    required this.selectedService,
    required this.onServiceChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 6.0),
          child: Text(
            'Select Service',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButton<String>(
            value: selectedService,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down),
            items: services.map((service) => DropdownMenuItem(
              value: service,
              child: Text(service),
            )).toList(),
            onChanged: (val) {
              if (val != null) onServiceChanged(val);
            },
          ),
        ),
      ],
    );
  }
} 