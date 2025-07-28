import 'package:flutter/material.dart';
import '../../core/services/order_notification_service.dart';
import '../../core/services/auth_service.dart';
import '../../models/order.dart';
import '../../models/medical_service.dart';

/// Demo class showing how to use OrderNotificationService
/// This is for demonstration purposes - you can use these methods anywhere in your app
class OrderNotificationDemo {
  
  /// Example 1: Send notification when order is created (automatic)
  /// This is already integrated in OrderViewModel.createOrder()
  static void example1_OrderCreated() {
    // This happens automatically when you call:
    // orderViewModel.createOrder(orderData);
    // The notification is sent automatically in the ViewModel
  }

  /// Example 2: Send notification manually from anywhere
  static Future<void> example2_ManualNotification() async {
    final userId = AuthService.currentUserId;
    if (userId == null) return;

    // Send a simple order confirmation
    await OrderNotificationService.sendSimpleOrderConfirmation(
      userId: userId,
      orderId: 'order_123',
      providerName: 'City General Hospital',
      total: 2500.0,
      itemCount: 2,
      scheduledDate: DateTime.now().add(Duration(days: 1)),
    );
  }

  /// Example 3: Send notification for order status update
  static Future<void> example3_StatusUpdate() async {
    final userId = AuthService.currentUserId;
    if (userId == null) return;

    // Create a mock order
    final order = Order(
      id: 'order_456',
      userId: userId,
      serviceProviderId: 'hospital_001',
      serviceProviderName: 'Mount Sinai Medical Center',
      items: [
        OrderItem(
          id: 'item_001',
          service: MedicalService(
            id: 'service_001',
            name: 'Blood Test',
            description: 'Complete blood count',
            price: 1500.0,
            category: 'Laboratory',
            duration: 30,
            isAvailable: true,
          ),
          quantity: 1,
          unitPrice: 1500.0,
          totalPrice: 1500.0,
        ),
      ],
      subtotal: 1500.0,
      tax: 270.0,
      discount: 0.0,
      total: 1770.0,
      orderDate: DateTime.now(),
    );

    // Send status update notification
    await OrderNotificationService.sendOrderStatusUpdate(
      userId: userId,
      order: order,
      previousStatus: 'pending',
    );
  }

  /// Example 4: Send notification for order completion
  static Future<void> example4_OrderCompletion() async {
    final userId = AuthService.currentUserId;
    if (userId == null) return;

    // Create a mock completed order
    final order = Order(
      id: 'order_789',
      userId: userId,
      serviceProviderId: 'hospital_002',
      serviceProviderName: 'City General Hospital',
      items: [
        OrderItem(
          id: 'item_002',
          service: MedicalService(
            id: 'service_002',
            name: 'X-Ray',
            description: 'Chest X-Ray examination',
            price: 2000.0,
            category: 'Radiology',
            duration: 45,
            isAvailable: true,
          ),
          quantity: 1,
          unitPrice: 2000.0,
          totalPrice: 2000.0,
        ),
      ],
      subtotal: 2000.0,
      tax: 360.0,
      discount: 100.0,
      total: 2260.0,
      status: OrderStatus.completed,
      orderDate: DateTime.now(),
    );

    // Send completion notification
    await OrderNotificationService.sendOrderCompletion(
      userId: userId,
      order: order,
    );
  }

  /// Example 5: Send notification for order cancellation
  static Future<void> example5_OrderCancellation() async {
    final userId = AuthService.currentUserId;
    if (userId == null) return;

    // Create a mock cancelled order
    final order = Order(
      id: 'order_101',
      userId: userId,
      serviceProviderId: 'hospital_003',
      serviceProviderName: 'Metro Medical Center',
      items: [
        OrderItem(
          id: 'item_003',
          service: MedicalService(
            id: 'service_003',
            name: 'MRI Scan',
            description: 'Magnetic Resonance Imaging',
            price: 5000.0,
            category: 'Radiology',
            duration: 60,
            isAvailable: true,
          ),
          quantity: 1,
          unitPrice: 5000.0,
          totalPrice: 5000.0,
        ),
      ],
      subtotal: 5000.0,
      tax: 900.0,
      discount: 0.0,
      total: 5900.0,
      status: OrderStatus.cancelled,
      orderDate: DateTime.now(),
    );

    // Send cancellation notification
    await OrderNotificationService.sendOrderCancellation(
      userId: userId,
      order: order,
      reason: 'Patient requested cancellation',
    );
  }

  /// Example 6: Test OneSignal API directly
  static Future<void> example6_TestOneSignalAPI() async {
    final userId = AuthService.currentUserId;
    if (userId == null) return;

    try {
      // Test direct OneSignal API call
      final success = await OrderNotificationService.sendSimpleOrderConfirmation(
        userId: userId,
        orderId: 'test_order_${DateTime.now().millisecondsSinceEpoch}',
        providerName: 'Test Hospital',
        total: 1000.0,
        itemCount: 1,
      );

      print('OneSignal API test result: $success');
    } catch (e) {
      print('OneSignal API test error: $e');
    }
  }
}

/// Demo Widget to test notifications
class OrderNotificationDemoWidget extends StatelessWidget {
  const OrderNotificationDemoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Notification Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Order Notification Examples',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: () => OrderNotificationDemo.example2_ManualNotification(),
              child: const Text('Send Manual Order Confirmation'),
            ),
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: () => OrderNotificationDemo.example3_StatusUpdate(),
              child: const Text('Send Status Update Notification'),
            ),
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: () => OrderNotificationDemo.example4_OrderCompletion(),
              child: const Text('Send Order Completion Notification'),
            ),
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: () => OrderNotificationDemo.example5_OrderCancellation(),
              child: const Text('Send Order Cancellation Notification'),
            ),
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: () => OrderNotificationDemo.example6_TestOneSignalAPI(),
              child: const Text('Test OneSignal API'),
            ),
            const SizedBox(height: 20),
            
            const Text(
              'Note: These notifications will be sent to the current user and also saved in the backend.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
} 