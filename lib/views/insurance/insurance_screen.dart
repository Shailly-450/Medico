import 'package:flutter/material.dart';
import '../../models/insurance.dart';
import '../../viewmodels/insurance_view_model.dart';
import '../../core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'widgets/insurance_card.dart';
import 'create_insurance_screen.dart';
import 'insurance_detail_screen.dart';
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
          title: const Text(
            'Insurance',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            tabs: const [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 16),
                    SizedBox(width: 4),
                    Text('Active'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning, size: 16),
                    SizedBox(width: 4),
                    Text('Expiring Soon'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 16),
                    SizedBox(width: 4),
                    Text('Expired'),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: model.busy
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading insurances...',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            : model.errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error Loading Insurances',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      model.errorMessage!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => model.loadInsurances(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
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
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          child: const Icon(Icons.add, size: 24),
        ),
      ),
    );
  }

  Widget _buildInsuranceList(List<Insurance> insurances) {
    if (insurances.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.health_and_safety_outlined,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Insurance Policies',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first insurance policy to get started',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _addInsurance(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Insurance'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InsuranceDetailScreen(insurance: insurance),
      ),
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
