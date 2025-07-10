import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/consent.dart';
import '../../viewmodels/consent_view_model.dart';
import 'widgets/consent_card.dart';
import 'widgets/consent_detail_dialog.dart';
import 'widgets/consent_log_screen.dart';
import 'widgets/consent_settings_screen.dart';

class ConsentManagementScreen extends StatefulWidget {
  const ConsentManagementScreen({Key? key}) : super(key: key);

  @override
  State<ConsentManagementScreen> createState() => _ConsentManagementScreenState();
}

class _ConsentManagementScreenState extends State<ConsentManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';

  final List<String> _filterOptions = [
    'All',
    'Active',
    'Pending',
    'Expired',
    'Revoked',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() =>
      Provider.of<ConsentViewModel>(context, listen: false).loadConsentData()
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilterChips(),
          _buildStatisticsCards(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildConsentsList(),
                _buildConsentLogs(),
                _buildConsentSettings(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Consent Management',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _showHelpDialog(context),
          icon: const Icon(Icons.help_outline),
          tooltip: 'Help',
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const [
          Tab(text: 'Consents'),
          Tab(text: 'Activity Log'),
          Tab(text: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Consumer<ConsentViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _filterOptions.length,
            itemBuilder: (context, index) {
              final option = _filterOptions[index];
              final isSelected = _selectedFilter == option;
              final count = _getCountForFilter(option, viewModel);
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text('$option ($count)'),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = option;
                    });
                  },
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.grey.shade300,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatisticsCards() {
    return Consumer<ConsentViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Active',
                  viewModel.activeConsentsCount.toString(),
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  viewModel.pendingConsentsCount.toString(),
                  Colors.orange,
                  Icons.pending,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Expired',
                  viewModel.expiredConsentsCount.toString(),
                  Colors.red,
                  Icons.warning,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentsList() {
    return Consumer<ConsentViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading consents',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade300,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  viewModel.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.loadConsentData(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final filteredConsents = _getFilteredConsents(viewModel);
        
        if (filteredConsents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.privacy_tip_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No consents found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No consents match the selected filter',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredConsents.length,
          itemBuilder: (context, index) {
            final consent = filteredConsents[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ConsentCard(
                consent: consent,
                onTap: () => _showConsentDetail(consent),
                onGrant: () => _grantConsent(consent),
                onRevoke: () => _revokeConsent(consent),
                onRenew: () => _renewConsent(consent),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildConsentLogs() {
    return const ConsentLogScreen();
  }

  Widget _buildConsentSettings() {
    return const ConsentSettingsScreen();
  }

  List<ConsentItem> _getFilteredConsents(ConsentViewModel viewModel) {
    switch (_selectedFilter) {
      case 'Active':
        return viewModel.activeConsents;
      case 'Pending':
        return viewModel.pendingConsents;
      case 'Expired':
        return viewModel.expiredConsents;
      case 'Revoked':
        return viewModel.revokedConsents;
      default:
        return viewModel.consentItems;
    }
  }

  int _getCountForFilter(String filter, ConsentViewModel viewModel) {
    switch (filter) {
      case 'Active':
        return viewModel.activeConsentsCount;
      case 'Pending':
        return viewModel.pendingConsentsCount;
      case 'Expired':
        return viewModel.expiredConsentsCount;
      case 'Revoked':
        return viewModel.revokedConsentsCount;
      default:
        return viewModel.totalConsents;
    }
  }

  void _showConsentDetail(ConsentItem consent) {
    showDialog(
      context: context,
      builder: (context) => ConsentDetailDialog(consent: consent),
    );
  }

  void _grantConsent(ConsentItem consent) async {
    final viewModel = context.read<ConsentViewModel>();
    await viewModel.grantConsent(consent.id);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Consent granted for ${consent.title}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _revokeConsent(ConsentItem consent) async {
    final viewModel = context.read<ConsentViewModel>();
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Consent'),
        content: Text(
          'Are you sure you want to revoke consent for "${consent.title}"? '
          'This may affect some app functionality.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await viewModel.revokeConsent(consent.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Consent revoked for ${consent.title}'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _renewConsent(ConsentItem consent) async {
    final viewModel = context.read<ConsentViewModel>();
    await viewModel.renewConsent(consent.id);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Consent renewed for ${consent.title}'),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Consent Management Help'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This screen helps you manage your data privacy preferences:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('• Grant or revoke consent for different data uses'),
            Text('• View your consent history and activity log'),
            Text('• Manage privacy settings and preferences'),
            Text('• Monitor consent expiry and renewal dates'),
            SizedBox(height: 12),
            Text(
              'Essential consents cannot be revoked as they are required for app functionality.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
} 