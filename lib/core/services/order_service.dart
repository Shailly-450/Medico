import 'package:dio/dio.dart';
import '../../models/order.dart';

class OrderService {
  final Dio dio;
  final String jwtToken;

  OrderService(this.dio, this.jwtToken);

  Options get _authHeader =>
      Options(headers: {'Authorization': 'Bearer $jwtToken'});

  // 1. List Orders
  Future<List<Order>> fetchOrders(
      {String? status, int page = 1, int limit = 10}) async {
    try {
      print('🔍 Fetching orders with status: $status, page: $page, limit: $limit');
      print('🔑 Using JWT token: ${jwtToken.isNotEmpty ? "Present" : "Missing"}');
      
      final response = await dio.get(
        '/orders',
        queryParameters: {
          if (status != null) 'status': status,
          'page': page,
          'limit': limit,
        },
        options: _authHeader,
      );
      
      print('📥 Orders API response status: ${response.statusCode}');
      print('📦 Orders API response data: ${response.data}');
      
      if (response.data['success']) {
        return (response.data['data'] as List)
            .map((json) => Order.fromJson(json))
            .toList();
      } else {
        throw Exception(response.data['message']);
      }
    } on DioError catch (e) {
      print('❌ DioError fetching orders: ${e.response?.data}');
      print('❌ DioError status: ${e.response?.statusCode}');
      print('❌ DioError message: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Error fetching orders: $e');
      rethrow;
    }
  }

  // 2. Get Order Details
  Future<Order> fetchOrderDetail(String orderId) async {
    final response = await dio.get('/orders/$orderId', options: _authHeader);
    if (response.data['success']) {
      return Order.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message']);
    }
  }

  // 3. Create Order
  Future<Order> createOrder(Map<String, dynamic> orderData) async {
    try {
      print('➕ Creating order with data: $orderData');
      print('🔑 Using JWT token: ${jwtToken.isNotEmpty ? "Present" : "Missing"}');
      
      final response = await dio.post(
        '/orders',
        data: orderData,
        options: _authHeader,
      );
      
      print('📥 Create order API response status: ${response.statusCode}');
      print('📦 Create order API response data: ${response.data}');
      
      if (response.data['success']) {
        return Order.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message']);
      }
    } on DioError catch (e) {
      print('❌ DioError creating order: ${e.response?.data}');
      print('❌ DioError status: ${e.response?.statusCode}');
      print('❌ DioError message: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Error creating order: $e');
      rethrow;
    }
  }

  // 4. Cancel Order
  Future<void> cancelOrder(String orderId) async {
    final response = await dio.delete('/orders/$orderId', options: _authHeader);
    if (!response.data['success']) {
      throw Exception(response.data['message']);
    }
  }

  // 5. Return Order
  Future<void> returnOrder(String orderId) async {
    final response =
        await dio.post('/orders/$orderId/return', options: _authHeader);
    if (!response.data['success']) {
      throw Exception(response.data['message']);
    }
  }

  // 6. Repeat Order
  Future<Order> repeatOrder(String orderId) async {
    final response =
        await dio.post('/orders/$orderId/repeat', options: _authHeader);
    if (response.data['success']) {
      return Order.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message']);
    }
  }

  // 7. Order Statistics
  Future<Map<String, dynamic>> fetchOrderStatistics() async {
    final response = await dio.get('/orders/statistics', options: _authHeader);
    if (response.data['success']) {
      return response.data['data'];
    } else {
      throw Exception(response.data['message']);
    }
  }

  // 8. Update Order Status
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      final response = await dio.put(
        '/orders/$orderId/status',
        data: {
          'status': newStatus.toString().split('.').last,
        },
        options: _authHeader,
      );

      print(
          'Update Order Status API response: data:${response.data}, status:${response.statusCode}');

      if (response.data['success'] == true) {
        return true;
      } else {
        print('Failed to update order status: ${response.data['message']}');
        return false;
      }
    } on DioError catch (e) {
      print('DioError updating order status: ${e.response?.data}');
      return false;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }
}
