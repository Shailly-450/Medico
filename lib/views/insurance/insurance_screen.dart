import 'package:flutter/material.dart';
import '../../models/insurance.dart';
import '../../viewmodels/insurance_view_model.dart';
import '../../core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'widgets/insurance_card.dart';
import 'create_insurance_screen.dart';
import '../../core/views/base_view.dart';

class InsuranceScreen extends StatefulWidget {
  const InsuranceScreen({Key? key}) : super(key: key);

  @override
  State<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends State<InsuranceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<InsuranceViewModel>(
      viewModelBuilder: () => InsuranceViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Insurance'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Expiring Soon'),
              Tab(text: 'Expired'),
            ],
          ),
        ),
        body: model.busy
            ? const Center(child: CircularProgressIndicator())
            : model.errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${model.errorMessage}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => model.loadInsurances(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () => model.loadInsurances(),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildInsuranceList(model.validInsurances),
                    _buildInsuranceList(model.expiringSoonInsurances),
                    _buildInsuranceList(model.expiredInsurances),
                  ],
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _addInsurance(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildInsuranceList(List<Insurance> insurances) {
    if (insurances.isEmpty) {
      return const Center(
        child: Text(
          'No insurances found',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: insurances.length,
      itemBuilder: (context, index) {
        final insurance = insurances[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: InsuranceCard(
            insurance: insurance,
            onTap: () => _viewInsurance(context, insurance),
            onEdit: () => _editInsurance(context, insurance),
            onDelete: () => _deleteInsurance(context, insurance),
          ),
        );
      },
    );
  }

  Future<void> _addInsurance(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateInsuranceScreen()),
    );

    if (result == true && mounted) {
      context.read<InsuranceViewModel>().loadInsurances();
    }
  }

  Future<void> _editInsurance(BuildContext context, Insurance insurance) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateInsuranceScreen(insurance: insurance),
      ),
    );

    if (result == true && mounted) {
      context.read<InsuranceViewModel>().loadInsurances();
    }
  }

  Future<void> _viewInsurance(BuildContext context, Insurance insurance) async {
    // TODO: Implement insurance detail view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Insurance detail view coming soon!')),
    );
  }

  Future<void> _deleteInsurance(
    BuildContext context,
    Insurance insurance,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Insurance'),
        content: Text(
          'Are you sure you want to delete the insurance policy from ${insurance.insuranceProvider}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final viewModel = context.read<InsuranceViewModel>();
      final success = await viewModel.deleteInsurance(insurance.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insurance deleted successfully')),
        );
      }
    }
  }
}
