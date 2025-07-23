import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/medical_service.dart';
import '../core/viewmodels/base_view_model.dart';
import '../core/services/order_service.dart';
import 'package:dio/dio.dart';

class OrderViewModel extends BaseViewModel {
  final OrderService orderService;
  OrderViewModel(this.orderService);
  
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
  Future<void> loadOrders({String? status, int page = 1, int limit = 10}) async {
    setLoading(true);
    setError(null);
    try {
      _orders = await orderService.fetchOrders(status: status, page: page, limit: limit);
      notifyListeners();
    } catch (e) {
      setError('Failed to load orders: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  // Get order details
  Future<void> loadOrderDetail(String orderId) async {
    setLoading(true);
    setError(null);
    try {
      _currentOrder = await orderService.fetchOrderDetail(orderId);
      notifyListeners();
    } catch (e) {
      setError('Failed to load order detail: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  // Create new order
  Future<bool> createOrder(Map<String, dynamic> orderData) async {
    setLoading(true);
    setError(null);
    try {
      final newOrder = await orderService.createOrder(orderData);
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

  // Cancel order
  Future<bool> cancelOrder(String orderId) async {
    setLoading(true);
    setError(null);
    try {
      await orderService.cancelOrder(orderId);
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        _orders[orderIndex] = _orders[orderIndex].copyWith(status: OrderStatus.cancelled);
        notifyListeners();
      }
      return true;
    } catch (e) {
      setError('Failed to cancel order: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Request return/refund
  Future<bool> returnOrder(String orderId) async {
    setLoading(true);
    setError(null);
    try {
      await orderService.returnOrder(orderId);
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        _orders[orderIndex] = _orders[orderIndex].copyWith(status: OrderStatus.refunded);
        notifyListeners();
      }
      return true;
    } catch (e) {
      setError('Failed to return order: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Repeat order
  Future<bool> repeatOrder(String orderId) async {
    setLoading(true);
    setError(null);
    try {
      final newOrder = await orderService.repeatOrder(orderId);
      _orders.insert(0, newOrder);
      notifyListeners();
      return true;
    } catch (e) {
      setError('Failed to repeat order: ${e.toString()}');
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Get order statistics
  Future<Map<String, dynamic>> getOrderStatistics() async {
    try {
      return await orderService.fetchOrderStatistics();
    } catch (e) {
      setError('Failed to get statistics: ${e.toString()}');
      return {};
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