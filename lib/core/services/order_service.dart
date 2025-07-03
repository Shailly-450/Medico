import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/order.dart';
import '../../models/medical_service.dart';

class OrderService {
  static const String baseUrl = 'https://api.medico.com'; // Mock API base URL
  static const Duration timeout = Duration(seconds: 10);

  // Mock API endpoints
  static const String ordersEndpoint = '/api/v1/orders';
  static const String servicesEndpoint = '/api/v1/services';
  static const String providersEndpoint = '/api/v1/providers';

  // HTTP client
  final http.Client _client = http.Client();

  // Mock data storage (simulating database)
  static List<Order> _mockOrders = [];
  static List<MedicalService> _mockServices = [];
  static List<Map<String, dynamic>> _mockProviders = [];

  // Initialize mock data
  static void initializeMockData() {
    _mockServices = _generateMockServices();
    _mockProviders = _generateMockProviders();
    _mockOrders = _generateMockOrders();
  }

  // Get all orders for a user
  Future<List<Order>> getOrders({String? userId}) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Mock API response
      final response = {
        'success': true,
        'data': _mockOrders.map((order) => order.toJson()).toList(),
        'message': 'Orders retrieved successfully'
      };

      if (response['success'] == true) {
        final List<dynamic> ordersData = response['data'] as List<dynamic>;
        return ordersData.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to load orders');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final order = _mockOrders.firstWhere(
        (order) => order.id == orderId,
        orElse: () => throw Exception('Order not found'),
      );

      return order;
    } catch (e) {
      throw Exception('Failed to get order: ${e.toString()}');
    }
  }

  // Create new order
  Future<Order> createOrder({
    required String userId,
    required String serviceProviderId,
    required String serviceProviderName,
    required List<MedicalService> services,
    required DateTime scheduledDate,
    String? notes,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      // Calculate order totals
      double subtotal = 0.0;
      List<OrderItem> orderItems = [];

      for (var service in services) {
        double itemTotal = service.price;
        subtotal += itemTotal;

        orderItems.add(OrderItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          service: service,
          quantity: 1,
          unitPrice: service.price,
          totalPrice: itemTotal,
        ));
      }

      // Create new order
      final newOrder = Order(
        id: 'ORD${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        serviceProviderId: serviceProviderId,
        serviceProviderName: serviceProviderName,
        items: orderItems,
        subtotal: subtotal,
        total: subtotal,
        orderDate: DateTime.now(),
        scheduledDate: scheduledDate,
        notes: notes,
        status: OrderStatus.pending,
        paymentStatus: PaymentStatus.pending,
      );

      // Add to mock data
      _mockOrders.insert(0, newOrder);

      // Mock API response
      return newOrder;
    } catch (e) {
      throw Exception('Failed to create order: ${e.toString()}');
    }
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final orderIndex = _mockOrders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        _mockOrders[orderIndex] = _mockOrders[orderIndex].copyWith(status: newStatus);
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to update order status: ${e.toString()}');
    }
  }

  // Cancel order
  Future<bool> cancelOrder(String orderId, String reason) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final orderIndex = _mockOrders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        _mockOrders[orderIndex] = _mockOrders[orderIndex].copyWith(
          status: OrderStatus.cancelled,
          cancellationReason: reason,
        );
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to cancel order: ${e.toString()}');
    }
  }

  // Request return/refund
  Future<bool> requestReturn(String orderId, String returnType, String reason) async {
    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      final orderIndex = _mockOrders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        _mockOrders[orderIndex] = _mockOrders[orderIndex].copyWith(
          status: OrderStatus.refunded,
          cancellationReason: '${returnType.toUpperCase()}: $reason',
        );
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to request return: ${e.toString()}');
    }
  }

  // Get all medical services
  Future<List<MedicalService>> getServices() async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      return _mockServices;
    } catch (e) {
      throw Exception('Failed to load services: ${e.toString()}');
    }
  }

  // Get services by category
  Future<List<MedicalService>> getServicesByCategory(String category) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockServices.where((service) => service.category == category).toList();
    } catch (e) {
      throw Exception('Failed to load services by category: ${e.toString()}');
    }
  }

  // Get service providers
  Future<List<Map<String, dynamic>>> getServiceProviders() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockProviders;
    } catch (e) {
      throw Exception('Failed to load service providers: ${e.toString()}');
    }
  }

  // Search orders
  Future<List<Order>> searchOrders(String query) async {
    try {
      await Future.delayed(const Duration(milliseconds: 700));
      
      return _mockOrders.where((order) =>
        order.serviceProviderName.toLowerCase().contains(query.toLowerCase()) ||
        order.items.any((item) => 
          item.service.name.toLowerCase().contains(query.toLowerCase())
        )
      ).toList();
    } catch (e) {
      throw Exception('Failed to search orders: ${e.toString()}');
    }
  }

  // Get order statistics
  Future<Map<String, dynamic>> getOrderStatistics() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      final totalSpent = _mockOrders
          .where((order) => order.paymentStatus == PaymentStatus.paid)
          .fold(0.0, (sum, order) => sum + order.total);

      final pendingOrders = _mockOrders
          .where((order) => order.status == OrderStatus.pending)
          .length;

      final activeOrders = _mockOrders
          .where((order) => 
              order.status == OrderStatus.confirmed || 
              order.status == OrderStatus.inProgress)
          .length;

      return {
        'totalSpent': totalSpent,
        'pendingOrders': pendingOrders,
        'activeOrders': activeOrders,
        'totalOrders': _mockOrders.length,
      };
    } catch (e) {
      throw Exception('Failed to get statistics: ${e.toString()}');
    }
  }

  // Mock data generators
  static List<MedicalService> _generateMockServices() {
    return [
      // Radiology
      MedicalService(
        id: 'rad_001',
        name: 'MRI Scan',
        description: 'Magnetic Resonance Imaging for detailed body scans',
        category: 'Radiology',
        price: 450.0,
        currency: 'INR',
        duration: 45,
        includedTests: ['Brain MRI', 'Spine MRI'],
        requirements: ['Fasting 4 hours'],
        notes: 'Bring previous reports',
        isAvailable: true,
        rating: 4.7,
        reviewCount: 120,
      ),
      MedicalService(
        id: 'rad_002',
        name: 'CT Scan',
        description: 'Computed Tomography scan for cross-sectional imaging',
        category: 'Radiology',
        price: 350.0,
        currency: 'INR',
        duration: 30,
        includedTests: ['Abdomen CT'],
        requirements: ['No metal objects'],
        notes: null,
        isAvailable: true,
        rating: 4.5,
        reviewCount: 80,
      ),
      MedicalService(
        id: 'rad_003',
        name: 'X-Ray',
        description: 'Standard X-ray imaging for bone and chest examination',
        category: 'Radiology',
        price: 80.0,
        currency: 'INR',
        duration: 15,
        includedTests: ['Chest X-Ray'],
        requirements: [],
        notes: null,
        isAvailable: true,
        rating: 4.2,
        reviewCount: 60,
      ),
      MedicalService(
        id: 'rad_004',
        name: 'Ultrasound',
        description: 'Ultrasound imaging for soft tissue examination',
        category: 'Radiology',
        price: 120.0,
        currency: 'INR',
        duration: 20,
        includedTests: ['Abdominal Ultrasound'],
        requirements: ['Full bladder'],
        notes: null,
        isAvailable: true,
        rating: 4.3,
        reviewCount: 70,
      ),

      // Dental
      MedicalService(
        id: 'den_001',
        name: 'Root Canal',
        description: 'Endodontic treatment for infected tooth pulp',
        category: 'Dental',
        price: 800.0,
        currency: 'INR',
        duration: 90,
        includedTests: [],
        requirements: [],
        notes: null,
        isAvailable: true,
        rating: 4.8,
        reviewCount: 150,
      ),
      MedicalService(
        id: 'den_002',
        name: 'Dental Implants',
        description: 'Surgical placement of artificial tooth roots',
        category: 'Dental',
        price: 2500.0,
        currency: 'INR',
        duration: 120,
        includedTests: [],
        requirements: ['Blood test'],
        notes: null,
        isAvailable: true,
        rating: 4.6,
        reviewCount: 90,
      ),
      MedicalService(
        id: 'den_003',
        name: 'Braces/Invisalign',
        description: 'Orthodontic treatment for teeth alignment',
        category: 'Dental',
        price: 3500.0,
        currency: 'INR',
        duration: 60,
        includedTests: [],
        requirements: [],
        notes: null,
        isAvailable: true,
        rating: 4.4,
        reviewCount: 110,
      ),
      MedicalService(
        id: 'den_004',
        name: 'Wisdom Tooth Extraction',
        description: 'Surgical removal of impacted wisdom teeth',
        category: 'Dental',
        price: 600.0,
        currency: 'INR',
        duration: 45,
        includedTests: [],
        requirements: [],
        notes: null,
        isAvailable: true,
        rating: 4.5,
        reviewCount: 95,
      ),

      // Ophthalmology
      MedicalService(
        id: 'oph_001',
        name: 'LASIK Surgery',
        description: 'Laser eye surgery for vision correction',
        category: 'Ophthalmology',
        price: 2000.0,
        currency: 'INR',
        duration: 30,
        includedTests: [],
        requirements: ['No contact lenses for 1 week'],
        notes: null,
        isAvailable: true,
        rating: 4.9,
        reviewCount: 200,
      ),
      MedicalService(
        id: 'oph_002',
        name: 'Cataract Surgery',
        description: 'Surgical removal of cloudy eye lens',
        category: 'Ophthalmology',
        price: 3000.0,
        currency: 'INR',
        duration: 60,
        includedTests: [],
        requirements: [],
        notes: null,
        isAvailable: true,
        rating: 4.7,
        reviewCount: 130,
      ),
      MedicalService(
        id: 'oph_003',
        name: 'Eye Checkup',
        description: 'Comprehensive eye examination and vision test',
        category: 'Ophthalmology',
        price: 100.0,
        currency: 'INR',
        duration: 30,
        includedTests: ['Vision Test'],
        requirements: [],
        notes: null,
        isAvailable: true,
        rating: 4.3,
        reviewCount: 60,
      ),
      MedicalService(
        id: 'oph_004',
        name: 'Glaucoma Screening',
        description: 'Eye pressure test for glaucoma detection',
        category: 'Ophthalmology',
        price: 80.0,
        currency: 'INR',
        duration: 20,
        includedTests: [],
        requirements: [],
        notes: null,
        isAvailable: true,
        rating: 4.1,
        reviewCount: 40,
      ),

      // Orthopedics
      MedicalService(
        id: 'ort_001',
        name: 'Physiotherapy',
        description: 'Physical therapy for injury rehabilitation',
        category: 'Orthopedics',
        price: 80.0,
        currency: 'INR',
        duration: 45,
        includedTests: [],
        requirements: [],
        notes: null,
        isAvailable: true,
        rating: 4.6,
        reviewCount: 100,
      ),
      MedicalService(
        id: 'ort_002',
        name: 'Knee Replacement',
        description: 'Surgical replacement of damaged knee joint',
        category: 'Orthopedics',
        price: 15000.0,
        currency: 'INR',
        duration: 180,
        includedTests: [],
        requirements: ['Pre-surgery blood test'],
        notes: null,
        isAvailable: true,
        rating: 4.8,
        reviewCount: 70,
      ),
      MedicalService(
        id: 'ort_003',
        name: 'Fracture Treatment',
        description: 'Treatment and casting for bone fractures',
        category: 'Orthopedics',
        price: 500.0,
        currency: 'INR',
        duration: 60,
        includedTests: ['X-Ray'],
        requirements: [],
        notes: null,
        isAvailable: true,
        rating: 4.4,
        reviewCount: 55,
      ),
      MedicalService(
        id: 'ort_004',
        name: 'Spine Consultation',
        description: 'Specialist consultation for spine-related issues',
        category: 'Orthopedics',
        price: 150.0,
        currency: 'INR',
        duration: 30,
        includedTests: [],
        requirements: [],
        notes: null,
        isAvailable: true,
        rating: 4.2,
        reviewCount: 30,
      ),

      // Gynecology
      MedicalService(
        id: 'gyn_001',
        name: 'Gynecology Consultation',
        description: 'Women\'s health consultation and examination',
        category: 'Gynecology',
        price: 120.0,
        currency: 'INR',
        duration: 30,
        includedTests: [],
        requirements: [],
        notes: null,
        isAvailable: true,
        rating: 4.5,
        reviewCount: 60,
      ),

      // Dermatology
      MedicalService(
        id: 'der_001',
        name: 'Hair Transplant',
        description: 'Surgical hair restoration procedure',
        category: 'Dermatology',
        price: 5000.0,
        currency: 'INR',
        duration: 240,
        includedTests: [],
        requirements: [],
        notes: null,
        isAvailable: true,
        rating: 4.7,
        reviewCount: 40,
      ),
      MedicalService(
        id: 'der_002',
        name: 'Skin Laser Treatments',
        description: 'Laser therapy for skin conditions',
        category: 'Dermatology',
        price: 300.0,
        currency: 'INR',
        duration: 45,
        includedTests: [],
        requirements: [],
        notes: null,
        isAvailable: true,
        rating: 4.3,
        reviewCount: 35,
      ),
      MedicalService(
        id: 'der_003',
        name: 'Cosmetic Surgery',
        description: 'Plastic surgery for aesthetic improvements',
        category: 'Dermatology',
        price: 8000.0,
        currency: 'INR',
        duration: 180,
        includedTests: [],
        requirements: [],
        notes: null,
        isAvailable: true,
        rating: 4.6,
        reviewCount: 25,
      ),

      // Telemedicine
      MedicalService(
        id: 'tel_001',
        name: 'Online Doctor Consultation',
        description: 'Virtual consultation with healthcare professionals',
        category: 'Telemedicine',
        price: 50.0,
        currency: 'INR',
        duration: 20,
        includedTests: [],
        requirements: [],
        notes: null,
        isAvailable: true,
        rating: 4.4,
        reviewCount: 90,
      ),

      // General Surgery
      MedicalService(
        id: 'sur_001',
        name: 'Gallbladder Removal',
        description: 'Laparoscopic cholecystectomy surgery',
        category: 'General Surgery',
        price: 8000.0,
        currency: 'INR',
        duration: 120,
        includedTests: [],
        requirements: ['Fasting 8 hours'],
        notes: null,
        isAvailable: true,
        rating: 4.7,
        reviewCount: 20,
      ),
      MedicalService(
        id: 'sur_002',
        name: 'Appendix Surgery',
        description: 'Appendectomy for inflamed appendix',
        category: 'General Surgery',
        price: 6000.0,
        currency: 'INR',
        duration: 90,
        includedTests: [],
        requirements: ['Blood test'],
        notes: null,
        isAvailable: true,
        rating: 4.5,
        reviewCount: 18,
      ),
    ];
  }

  static List<Map<String, dynamic>> _generateMockProviders() {
    return [
      {
        'id': 'prov_001',
        'name': 'Apollo Hospitals',
        'type': 'Hospital',
        'address': '123 Medical Center, Mumbai',
        'rating': 4.5,
        'imageUrl': 'https://example.com/apollo.jpg',
      },
      {
        'id': 'prov_002',
        'name': 'Fortis Healthcare',
        'type': 'Hospital',
        'address': '456 Health Street, Delhi',
        'rating': 4.3,
        'imageUrl': 'https://example.com/fortis.jpg',
      },
      {
        'id': 'prov_003',
        'name': 'Max Healthcare',
        'type': 'Hospital',
        'address': '789 Wellness Road, Bangalore',
        'rating': 4.4,
        'imageUrl': 'https://example.com/max.jpg',
      },
      {
        'id': 'prov_004',
        'name': 'Dr. Smith\'s Clinic',
        'type': 'Clinic',
        'address': '321 Doctor Lane, Chennai',
        'rating': 4.2,
        'imageUrl': 'https://example.com/smith.jpg',
      },
    ];
  }

  static List<Order> _generateMockOrders() {
    final services = _mockServices;
    
    return [
      Order(
        id: 'ORD001',
        userId: 'user_123',
        serviceProviderId: 'prov_001',
        serviceProviderName: 'Apollo Hospitals',
        items: [
          OrderItem(
            id: 'item_001',
            service: services.firstWhere((s) => s.name == 'MRI Scan'),
            quantity: 1,
            unitPrice: 450.0,
            totalPrice: 450.0,
          ),
        ],
        subtotal: 450.0,
        total: 450.0,
        orderDate: DateTime.now().subtract(const Duration(days: 2)),
        scheduledDate: DateTime.now().add(const Duration(days: 1)),
        status: OrderStatus.confirmed,
        paymentStatus: PaymentStatus.paid,
        notes: 'Please arrive 15 minutes before appointment',
      ),
      Order(
        id: 'ORD002',
        userId: 'user_123',
        serviceProviderId: 'prov_002',
        serviceProviderName: 'Fortis Healthcare',
        items: [
          OrderItem(
            id: 'item_002',
            service: services.firstWhere((s) => s.name == 'Dental Implants'),
            quantity: 1,
            unitPrice: 2500.0,
            totalPrice: 2500.0,
          ),
        ],
        subtotal: 2500.0,
        total: 2500.0,
        orderDate: DateTime.now().subtract(const Duration(days: 5)),
        scheduledDate: DateTime.now().add(const Duration(days: 7)),
        status: OrderStatus.completed,
        paymentStatus: PaymentStatus.paid,
        notes: 'Surgery completed successfully',
      ),
      Order(
        id: 'ORD003',
        userId: 'user_123',
        serviceProviderId: 'prov_003',
        serviceProviderName: 'Max Healthcare',
        items: [
          OrderItem(
            id: 'item_003',
            service: services.firstWhere((s) => s.name == 'Eye Checkup'),
            quantity: 1,
            unitPrice: 100.0,
            totalPrice: 100.0,
          ),
        ],
        subtotal: 100.0,
        total: 100.0,
        orderDate: DateTime.now().subtract(const Duration(hours: 2)),
        scheduledDate: DateTime.now().add(const Duration(days: 3)),
        status: OrderStatus.pending,
        paymentStatus: PaymentStatus.pending,
        notes: 'Regular eye examination',
      ),
    ];
  }

  // Dispose resources
  void dispose() {
    _client.close();
  }
} 