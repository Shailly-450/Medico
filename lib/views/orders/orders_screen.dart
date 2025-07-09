import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/order_view_model.dart';
import '../../models/order.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/order_card.dart';
import 'widgets/order_status_filter.dart';
import 'order_detail_screen.dart';
import 'create_order_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderViewModel>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'My Orders',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt),
            tooltip: 'Invoices',
            onPressed: () {
              Navigator.pushNamed(context, '/invoices');
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateOrderScreen(
                    serviceProviderId: 'default',
                    serviceProviderName: 'Select Provider',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8F5E8), // Light mint green
              Color(0xFFF0F8F0), // Very light sage
              Color(0xFFE6F3E6), // Soft green tint
              Color(0xFFF5F9F5), // Almost white with green tint
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Consumer<OrderViewModel>(
          builder: (context, orderViewModel, child) {
            if (orderViewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (orderViewModel.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading orders',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      orderViewModel.errorMessage!,
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => orderViewModel.loadOrders(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (orderViewModel.orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No orders yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your medical service orders will appear here',
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/home');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Browse Services'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Order statistics
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                   color: Colors.white.withOpacity(0.9),
                   borderRadius: BorderRadius.circular(24),
                   border: Border.all(
                     color: Colors.white.withOpacity(0.3),
                     width: 1.5,
                   ),
                   boxShadow: [
                     BoxShadow(
                       color: Colors.black.withOpacity(0.08),
                       blurRadius: 20,
                       offset: const Offset(0, 4),
                     ),
                     BoxShadow(
                       color: const Color(0xFF4CAF50).withOpacity(0.1),
                       blurRadius: 40,
                       offset: const Offset(0, 8),
                     ),
                   ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Spent',
                          '₹${orderViewModel.totalSpent.toStringAsFixed(2)}',
                          Icons.account_balance_wallet,
                         const Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Active Orders',
                          orderViewModel.activeOrdersCount.toString(),
                          Icons.pending_actions,
                         const Color(0xFF4CAF50),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Pending',
                          orderViewModel.pendingOrdersCount.toString(),
                          Icons.schedule,
                         const Color(0xFF66BB6A),
                        ),
                      ),
                    ],
                  ),
                ),

                // Status filter
                OrderStatusFilter(
                  selectedStatus: orderViewModel.selectedStatusFilter,
                  onStatusChanged: orderViewModel.updateStatusFilter,
                ),

                // Orders list
                Expanded(
                  child: orderViewModel.filteredOrders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.filter_list,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No orders with this status',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: orderViewModel.filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = orderViewModel.filteredOrders[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: OrderCard(
                                order: order,
                                onTap: () {
                                  orderViewModel.setCurrentOrder(order);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderDetailScreen(
                                        order: order,
                                      ),
                                    ),
                                  );
                                },
                                onRepeatOrder: (order) => _repeatOrder(context, order),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2E7D32),
              Color(0xFF4CAF50),
              Color(0xFF66BB6A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E7D32).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: const Color(0xFF4CAF50).withOpacity(0.2),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateOrderScreen(
                  serviceProviderId: 'default',
                  serviceProviderName: 'Select Provider',
                ),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _repeatOrder(BuildContext context, Order order) {
    // Extract services from the order
    final services = order.items.map((item) => item.service).toList();
    
    // Navigate to create order screen with pre-filled services
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateOrderScreen(
          serviceProviderId: order.serviceProviderId,
          serviceProviderName: order.serviceProviderName,
          initialServices: services,
        ),
      ),
    );
  }
} 