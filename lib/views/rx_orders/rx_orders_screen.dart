import 'package:flutter/material.dart';
import '../../core/views/base_view.dart';
import '../../viewmodels/rx_order_view_model.dart';
import '../../core/theme/app_colors.dart';
import '../../models/rx_order.dart';
import 'widgets/rx_order_card.dart';
import 'widgets/rx_order_stats_card.dart';
import 'create_rx_order_screen.dart';
import 'rx_order_detail_screen.dart';

class RxOrdersScreen extends StatefulWidget {
  const RxOrdersScreen({Key? key}) : super(key: key);

  @override
  State<RxOrdersScreen> createState() => _RxOrdersScreenState();
}

class _RxOrdersScreenState extends State<RxOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<RxOrderViewModel>(
      viewModelBuilder: () => RxOrderViewModel()..initialize(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Rx Orders'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _showSearchDialog(context, model),
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterDialog(context, model),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            isScrollable: true,
            tabs: [
              Tab(
                text: 'All',
                icon: Badge.count(
                  count: model.totalOrders,
                  isLabelVisible: model.totalOrders > 0,
                  child: const Icon(Icons.medication),
                ),
              ),
              Tab(
                text: 'Pending',
                icon: Badge.count(
                  count: model.pendingOrders,
                  isLabelVisible: model.pendingOrders > 0,
                  child: const Icon(Icons.schedule),
                ),
              ),
              Tab(
                text: 'Processing',
                icon: Badge.count(
                  count: model.processingOrders,
                  isLabelVisible: model.processingOrders > 0,
                  child: const Icon(Icons.build),
                ),
              ),
              Tab(
                text: 'Ready',
                icon: Badge.count(
                  count: model.readyForPickupOrders,
                  isLabelVisible: model.readyForPickupOrders > 0,
                  child: const Icon(Icons.check_circle),
                ),
              ),
              Tab(
                text: 'Completed',
                icon: Badge.count(
                  count: model.completedOrders,
                  isLabelVisible: model.completedOrders > 0,
                  child: const Icon(Icons.done_all),
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // Stats Cards
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: RxOrderStatsCard(model: model),
            ),
            // SizedBox(height: 2,),
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllTab(context, model),
                  _buildPendingTab(context, model),
                  _buildProcessingTab(context, model),
                  _buildReadyTab(context, model),
                  _buildCompletedTab(context, model),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _navigateToCreateOrder(context, model),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAllTab(BuildContext context, RxOrderViewModel model) {
    if (model.filteredOrders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.medication_outlined,
        title: 'No Rx Orders',
        subtitle: 'Start by creating your first prescription order.',
      );
    }

    return RefreshIndicator(
      onRefresh: model.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: model.filteredOrders.length,
        itemBuilder: (context, index) {
          final order = model.filteredOrders[index];
          return RxOrderCard(
            order: order,
            onTap: () => _navigateToDetail(context, order),
            onCancel: () => _showCancelDialog(context, model, order),
          );
        },
      ),
    );
  }

  Widget _buildPendingTab(BuildContext context, RxOrderViewModel model) {
    final pendingOrders = model.getOrdersByStatus(RxOrderStatus.pending);
    
    if (pendingOrders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline,
        title: 'No pending orders',
        subtitle: 'All your orders are being processed!',
      );
    }

    return RefreshIndicator(
      onRefresh: model.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: pendingOrders.length,
        itemBuilder: (context, index) {
          final order = pendingOrders[index];
          return RxOrderCard(
            order: order,
            onTap: () => _navigateToDetail(context, order),
            onCancel: () => _showCancelDialog(context, model, order),
          );
        },
      ),
    );
  }

  Widget _buildProcessingTab(BuildContext context, RxOrderViewModel model) {
    final processingOrders = model.getOrdersByStatus(RxOrderStatus.processing);
    
    if (processingOrders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.build_outlined,
        title: 'No processing orders',
        subtitle: 'Your orders are either pending or ready!',
      );
    }

    return RefreshIndicator(
      onRefresh: model.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: processingOrders.length,
        itemBuilder: (context, index) {
          final order = processingOrders[index];
          return RxOrderCard(
            order: order,
            onTap: () => _navigateToDetail(context, order),
            onCancel: () => _showCancelDialog(context, model, order),
          );
        },
      ),
    );
  }

  Widget _buildReadyTab(BuildContext context, RxOrderViewModel model) {
    final readyOrders = model.getOrdersByStatus(RxOrderStatus.readyForPickup);
    
    if (readyOrders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline,
        title: 'No ready orders',
        subtitle: 'Your orders will appear here when ready for pickup.',
      );
    }

    return RefreshIndicator(
      onRefresh: model.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: readyOrders.length,
        itemBuilder: (context, index) {
          final order = readyOrders[index];
          return RxOrderCard(
            order: order,
            onTap: () => _navigateToDetail(context, order),
            onCancel: () => _showCancelDialog(context, model, order),
          );
        },
      ),
    );
  }

  Widget _buildCompletedTab(BuildContext context, RxOrderViewModel model) {
    final completedOrders = model.getOrdersByStatus(RxOrderStatus.delivered);
    
    if (completedOrders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.done_all_outlined,
        title: 'No completed orders',
        subtitle: 'Your completed orders will appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: model.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: completedOrders.length,
        itemBuilder: (context, index) {
          final order = completedOrders[index];
          return RxOrderCard(
            order: order,
            onTap: () => _navigateToDetail(context, order),
            onCancel: null, // Can't cancel completed orders
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToCreateOrder(BuildContext context, RxOrderViewModel model) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateRxOrderScreen(),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, RxOrder order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RxOrderDetailScreen(order: order),
      ),
    );
  }

  void _showSearchDialog(BuildContext context, RxOrderViewModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Orders'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Search by pharmacy, doctor, or medicine...',
            border: OutlineInputBorder(),
          ),
          onChanged: model.setSearchQuery,
        ),
        actions: [
          TextButton(
            onPressed: () {
              model.clearFilters();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context, RxOrderViewModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Orders'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status filter
            DropdownButtonFormField<RxOrderStatus?>(
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              value: model.statusFilter,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Statuses'),
                ),
                ...RxOrderStatus.values.map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status.displayName),
                )),
              ],
              onChanged: model.setStatusFilter,
            ),
            const SizedBox(height: 16),
            
            // Type filter
            DropdownButtonFormField<RxOrderType?>(
              decoration: const InputDecoration(
                labelText: 'Order Type',
                border: OutlineInputBorder(),
              ),
              value: model.typeFilter,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Types'),
                ),
                ...RxOrderType.values.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                )),
              ],
              onChanged: model.setTypeFilter,
            ),
            const SizedBox(height: 16),
            
            // Pharmacy filter
            DropdownButtonFormField<String?>(
              decoration: const InputDecoration(
                labelText: 'Pharmacy',
                border: OutlineInputBorder(),
              ),
              value: model.pharmacyFilter,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Pharmacies'),
                ),
                ...model.pharmacies.map((pharmacy) => DropdownMenuItem(
                  value: pharmacy.id,
                  child: Text(pharmacy.name),
                )),
              ],
              onChanged: model.setPharmacyFilter,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              model.clearFilters();
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, RxOrderViewModel model, RxOrder order) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to cancel this order?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for cancellation (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await model.cancelRxOrder(
                order.id,
                reasonController.text.isEmpty ? 'Cancelled by user' : reasonController.text,
              );
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order cancelled successfully')),
                );
              }
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
} 