import 'package:flutter/material.dart';
import '../../viewmodels/prescriptions_view_model.dart';
import '../../models/prescription.dart';

class TestPrescriptionsScreen extends StatefulWidget {
  const TestPrescriptionsScreen({Key? key}) : super(key: key);

  @override
  State<TestPrescriptionsScreen> createState() =>
      _TestPrescriptionsScreenState();
}

class _TestPrescriptionsScreenState extends State<TestPrescriptionsScreen> {
  late PrescriptionsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PrescriptionsViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Prescriptions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _viewModel.refreshPrescriptions();
              });
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, child) {
          return Column(
            children: [
              // Debug Info
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.yellow[100],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Loading: ${_viewModel.isLoading}'),
                    Text(
                        'Prescriptions Count: ${_viewModel.prescriptions.length}'),
                    Text('Selected Filter: ${_viewModel.selectedFilter}'),
                    Text('Search Query: ${_viewModel.searchQuery}'),
                  ],
                ),
              ),

              // Prescriptions List
              Expanded(
                child: _viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _viewModel.prescriptions.isEmpty
                        ? const Center(child: Text('No prescriptions found'))
                        : ListView.builder(
                            itemCount: _viewModel.prescriptions.length,
                            itemBuilder: (context, index) {
                              final prescription =
                                  _viewModel.prescriptions[index];
                              return Card(
                                margin: const EdgeInsets.all(8),
                                child: ListTile(
                                  title: Text(prescription.doctorName),
                                  subtitle: Text(prescription.diagnosis),
                                  trailing:
                                      Text(prescription.status.toString()),
                                ),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}
