import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/medical_service.dart';
import '../core/viewmodels/base_view_model.dart';
import '../core/services/order_service.dart';

class OrderViewModel extends BaseViewModel {
  final OrderService _orderService = OrderService();
  
  List<Order> _orders = [];
  Order? _currentOrder;
  bool _isLoading = false;
  String? _errorMessage;
  OrderStatus _selectedStatusFilter = OrderStatus.pending;

  // Getters
  List<Order> get orders => _orders;
  Order? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  OrderStatus get selectedStatusFilter => _selectedStatusFilter;

  // Filtered orders based on status
  List<Order> get filteredOrders {
    if (_selectedStatusFilter == OrderStatus.pending) {
      return _orders; // Show all orders when "All" is selected
    }
    return _orders.where((order) => order.status == _selectedStatusFilter).toList();
  }

  // Computed properties
  double get totalSpent {
    return _orders
        .where((order) => order.paymentStatus == PaymentStatus.paid)
        .fold(0.0, (sum, order) => sum + order.total);
  }

  int get pendingOrdersCount {
    return _orders.where((order) => order.status == OrderStatus.pending).length;
  }

  int get activeOrdersCount {
    return _orders
        .where((order) => 
            order.status == OrderStatus.confirmed || 
            order.status == OrderStatus.inProgress)
        .length;
  }

  // Initialize orders from backend
  Future<void> loadOrders() async {
    setLoading(true);
    setError(null);

    try {
      _orders = await _orderService.getOrders(userId: 'user_123');
      notifyListeners();
    } catch (e) {
      setError('Failed to load orders: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  // Create new order
  Future<bool> createOrder({
    required String serviceProviderId,
    required String serviceProviderName,
    required List<MedicalService> services,
    required DateTime scheduledDate,
    String? notes,
  }) async {
    setLoading(true);
    setError(null);

    try {
      final newOrder = await _orderService.createOrder(
        userId: 'user_123',
        serviceProviderId: serviceProviderId,
        serviceProviderName: serviceProviderName,
        services: services,
        scheduledDate: scheduledDate,
        notes: notes,
      );

      _orders.insert(0, newOrder);
      _currentOrder = newOrder;
      notifyListeners();

      return true;
    } catch (e) {
      setError('Failed to create order: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    setLoading(true);
    setError(null);

    try {
      final success = await _orderService.updateOrderStatus(orderId, newStatus);
      if (success) {
        final orderIndex = _orders.indexWhere((order) => order.id == orderId);
        if (orderIndex != -1) {
          _orders[orderIndex] = _orders[orderIndex].copyWith(status: newStatus);
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      setError('Failed to update order status: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Cancel order
  Future<bool> cancelOrder(String orderId, String reason) async {
    setLoading(true);
    setError(null);

    try {
      final success = await _orderService.cancelOrder(orderId, reason);
      if (success) {
        final orderIndex = _orders.indexWhere((order) => order.id == orderId);
        if (orderIndex != -1) {
          _orders[orderIndex] = _orders[orderIndex].copyWith(
            status: OrderStatus.cancelled,
            cancellationReason: reason,
          );
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      setError('Failed to cancel order: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Request return/refund
  Future<bool> requestReturn(String orderId, String returnType, String reason) async {
    setLoading(true);
    setError(null);

    try {
      final success = await _orderService.requestReturn(orderId, returnType, reason);
      if (success) {
        final orderIndex = _orders.indexWhere((order) => order.id == orderId);
        if (orderIndex != -1) {
          _orders[orderIndex] = _orders[orderIndex].copyWith(
            status: OrderStatus.refunded,
            cancellationReason: '${returnType.toUpperCase()}: $reason',
          );
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      setError('Failed to request return: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Set current order for detail view
  void setCurrentOrder(Order order) {
    _currentOrder = order;
    notifyListeners();
  }

  // Update status filter
  void updateStatusFilter(OrderStatus status) {
    _selectedStatusFilter = status;
    notifyListeners();
  }

  // Get services from backend
  Future<List<MedicalService>> getServices() async {
    try {
      return await _orderService.getServices();
    } catch (e) {
      setError('Failed to load services: ${e.toString()}');
      return [];
    }
  }

  // Get services by category
  Future<List<MedicalService>> getServicesByCategory(String category) async {
    try {
      return await _orderService.getServicesByCategory(category);
    } catch (e) {
      setError('Failed to load services by category: ${e.toString()}');
      return [];
    }
  }

  // Get service providers
  Future<List<Map<String, dynamic>>> getServiceProviders() async {
    try {
      return await _orderService.getServiceProviders();
    } catch (e) {
      setError('Failed to load service providers: ${e.toString()}');
      return [];
    }
  }

  // Search orders
  Future<List<Order>> searchOrders(String query) async {
    try {
      return await _orderService.searchOrders(query);
    } catch (e) {
      setError('Failed to search orders: ${e.toString()}');
      return [];
    }
  }

  // Get order statistics
  Future<Map<String, dynamic>> getOrderStatistics() async {
    try {
      return await _orderService.getOrderStatistics();
    } catch (e) {
      setError('Failed to get statistics: ${e.toString()}');
      return {};
    }
  }

  // Clear current order
  void clearCurrentOrder() {
    _currentOrder = null;
    notifyListeners();
  }

  // Helper methods
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }


} 