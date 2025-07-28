import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config.dart';
import 'auth_service.dart';
import 'notification_sender_service.dart';
import '../../models/notification_item.dart';
import '../../models/order.dart';

class OrderNotificationService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  // Get auth headers
  static Map<String, String> get _authHeaders {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = AuthService.accessToken;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Send order confirmation notification
  static Future<bool> sendOrderConfirmation({
    required String userId,
    required Order order,
  }) async {
    try {
      final title = '✅ Order Confirmed';
      final message = _buildOrderConfirmationMessage(order);

      // Send push notification
      final pushSuccess = await NotificationSenderService.sendToUser(
        userId: userId,
        title: title,
        message: message,
        type: NotificationType.order_confirmed,
        data: {
          'orderId': order.id,
          'orderStatus': order.status.toString().split('.').last,
          'totalAmount': order.total,
          'providerName': order.serviceProviderName,
          'itemCount': order.items.length,
        },
      );

      // Also create notification in backend
      final backendSuccess = await _createOrderNotification(
        title: title,
        message: message,
        type: 'order_confirmed',
        data: {
          'orderId': order.id,
          'orderStatus': order.status.toString().split('.').last,
          'totalAmount': order.total,
          'providerName': order.serviceProviderName,
          'itemCount': order.items.length,
        },
      );

      debugPrint('Order confirmation notification sent - Push: $pushSuccess, Backend: $backendSuccess');
      return pushSuccess && backendSuccess;
    } catch (e) {
      debugPrint('Error sending order confirmation: $e');
      return false;
    }
  }

  // Send order status update notification
  static Future<bool> sendOrderStatusUpdate({
    required String userId,
    required Order order,
    required String previousStatus,
  }) async {
    try {
      final title = '📦 Order Status Updated';
      final message = _buildOrderStatusMessage(order, previousStatus);

      // Send push notification
      final pushSuccess = await NotificationSenderService.sendToUser(
        userId: userId,
        title: title,
        message: message,
        type: NotificationType.order_status_updated,
        data: {
          'orderId': order.id,
          'previousStatus': previousStatus,
          'newStatus': order.status.toString().split('.').last,
          'totalAmount': order.total,
          'providerName': order.serviceProviderName,
        },
      );

      // Also create notification in backend
      final backendSuccess = await _createOrderNotification(
        title: title,
        message: message,
        type: 'order_status_updated',
        data: {
          'orderId': order.id,
          'previousStatus': previousStatus,
          'newStatus': order.status.toString().split('.').last,
          'totalAmount': order.total,
          'providerName': order.serviceProviderName,
        },
      );

      debugPrint('Order status update notification sent - Push: $pushSuccess, Backend: $backendSuccess');
      return pushSuccess && backendSuccess;
    } catch (e) {
      debugPrint('Error sending order status update: $e');
      return false;
    }
  }

  // Send order cancellation notification
  static Future<bool> sendOrderCancellation({
    required String userId,
    required Order order,
    String? reason,
  }) async {
    try {
      final title = '❌ Order Cancelled';
      final message = _buildOrderCancellationMessage(order, reason);

      // Send push notification
      final pushSuccess = await NotificationSenderService.sendToUser(
        userId: userId,
        title: title,
        message: message,
        type: NotificationType.order_status_updated,
        data: {
          'orderId': order.id,
          'status': 'cancelled',
          'reason': reason,
          'totalAmount': order.total,
          'providerName': order.serviceProviderName,
        },
      );

      // Also create notification in backend
      final backendSuccess = await _createOrderNotification(
        title: title,
        message: message,
        type: 'order_status_updated',
        data: {
          'orderId': order.id,
          'status': 'cancelled',
          'reason': reason,
          'totalAmount': order.total,
          'providerName': order.serviceProviderName,
        },
      );

      debugPrint('Order cancellation notification sent - Push: $pushSuccess, Backend: $backendSuccess');
      return pushSuccess && backendSuccess;
    } catch (e) {
      debugPrint('Error sending order cancellation: $e');
      return false;
    }
  }

  // Send order completion notification
  static Future<bool> sendOrderCompletion({
    required String userId,
    required Order order,
  }) async {
    try {
      final title = '🎉 Order Completed';
      final message = _buildOrderCompletionMessage(order);

      // Send push notification
      final pushSuccess = await NotificationSenderService.sendToUser(
        userId: userId,
        title: title,
        message: message,
        type: NotificationType.order_status_updated,
        data: {
          'orderId': order.id,
          'status': 'completed',
          'totalAmount': order.total,
          'providerName': order.serviceProviderName,
        },
      );

      // Also create notification in backend
      final backendSuccess = await _createOrderNotification(
        title: title,
        message: message,
        type: 'order_status_updated',
        data: {
          'orderId': order.id,
          'status': 'completed',
          'totalAmount': order.total,
          'providerName': order.serviceProviderName,
        },
      );

      debugPrint('Order completion notification sent - Push: $pushSuccess, Backend: $backendSuccess');
      return pushSuccess && backendSuccess;
    } catch (e) {
      debugPrint('Error sending order completion: $e');
      return false;
    }
  }

  // Helper method to create notification in backend
  static Future<bool> _createOrderNotification({
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications'),
        headers: _authHeaders,
        body: jsonEncode({
          'title': title,
          'message': message,
          'type': type,
          'data': data,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Error creating order notification in backend: $e');
      return false;
    }
  }

  // Build order confirmation message
  static String _buildOrderConfirmationMessage(Order order) {
    final itemCount = order.items.length;
    final total = order.total.toStringAsFixed(2);
    final provider = order.serviceProviderName;
    
    if (order.scheduledDate != null) {
      final date = order.scheduledDate!.toString().split(' ')[0];
      return 'Your order for $itemCount service(s) at $provider has been confirmed. Total: ₹$total. Scheduled for: $date';
    } else {
      return 'Your order for $itemCount service(s) at $provider has been confirmed. Total: ₹$total';
    }
  }

  // Build order status update message
  static String _buildOrderStatusMessage(Order order, String previousStatus) {
    final status = order.status.toString().split('.').last;
    final provider = order.serviceProviderName;
    
    switch (status) {
      case 'confirmed':
        return 'Your order at $provider has been confirmed and is being processed.';
      case 'inProgress':
        return 'Your order at $provider is now in progress. You will be notified when ready.';
      case 'completed':
        return 'Your order at $provider has been completed successfully!';
      case 'cancelled':
        return 'Your order at $provider has been cancelled.';
      default:
        return 'Your order at $provider status has been updated to: $status';
    }
  }

  // Build order cancellation message
  static String _buildOrderCancellationMessage(Order order, String? reason) {
    final provider = order.serviceProviderName;
    final total = order.total.toStringAsFixed(2);
    
    if (reason != null && reason.isNotEmpty) {
      return 'Your order at $provider (₹$total) has been cancelled. Reason: $reason';
    } else {
      return 'Your order at $provider (₹$total) has been cancelled.';
    }
  }

  // Build order completion message
  static String _buildOrderCompletionMessage(Order order) {
    final provider = order.serviceProviderName;
    final total = order.total.toStringAsFixed(2);
    final itemCount = order.items.length;
    
    return 'Your order for $itemCount service(s) at $provider (₹$total) has been completed successfully! Thank you for choosing our services.';
  }

  // Simple helper method to send order confirmation from anywhere
  static Future<bool> sendSimpleOrderConfirmation({
    required String userId,
    required String orderId,
    required String providerName,
    required double total,
    required int itemCount,
    DateTime? scheduledDate,
  }) async {
    try {
      final title = '✅ Order Confirmed';
      String message;
      
      if (scheduledDate != null) {
        final date = scheduledDate.toString().split(' ')[0];
        message = 'Your order for $itemCount service(s) at $providerName has been confirmed. Total: ₹${total.toStringAsFixed(2)}. Scheduled for: $date';
      } else {
        message = 'Your order for $itemCount service(s) at $providerName has been confirmed. Total: ₹${total.toStringAsFixed(2)}';
      }

      // Send push notification
      final pushSuccess = await NotificationSenderService.sendToUser(
        userId: userId,
        title: title,
        message: message,
        type: NotificationType.order_confirmed,
        data: {
          'orderId': orderId,
          'orderStatus': 'confirmed',
          'totalAmount': total,
          'providerName': providerName,
          'itemCount': itemCount,
        },
      );

      // Also create notification in backend
      final backendSuccess = await _createOrderNotification(
        title: title,
        message: message,
        type: 'order_confirmed',
        data: {
          'orderId': orderId,
          'orderStatus': 'confirmed',
          'totalAmount': total,
          'providerName': providerName,
          'itemCount': itemCount,
        },
      );

      debugPrint('Simple order confirmation sent - Push: $pushSuccess, Backend: $backendSuccess');
      return pushSuccess && backendSuccess;
    } catch (e) {
      debugPrint('Error sending simple order confirmation: $e');
      return false;
    }
  }
} 