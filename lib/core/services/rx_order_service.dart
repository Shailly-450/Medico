import 'package:http/http.dart' as http;
import '../../models/rx_order.dart';
import '../../models/medicine.dart';

class RxOrderService {
  static const String baseUrl = 'https://api.medico.com'; // Mock API base URL
  static const Duration timeout = Duration(seconds: 10);

  // Mock API endpoints
  static const String rxOrdersEndpoint = '/api/v1/rx-orders';
  static const String pharmaciesEndpoint = '/api/v1/pharmacies';
  static const String medicinesEndpoint = '/api/v1/medicines';

  // HTTP client
  final http.Client _client = http.Client();

  // Mock data storage (simulating database)
  static List<RxOrder> _mockRxOrders = [];
  static List<Pharmacy> _mockPharmacies = [];
  static List<Medicine> _mockMedicines = [];

  // Initialize mock data
  static void initializeMockData() {
    _mockPharmacies = _generateMockPharmacies();
    _mockMedicines = _generateMockMedicines();
    _mockRxOrders = _generateMockRxOrders();
  }

  // Get all Rx orders for a user
  Future<List<RxOrder>> getRxOrders({String? userId}) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Mock API response
      final response = {
        'success': true,
        'data': _mockRxOrders.map((order) => order.toJson()).toList(),
        'message': 'Rx orders retrieved successfully'
      };

      if (response['success'] == true) {
        final List<dynamic> ordersData = response['data'] as List<dynamic>;
        return ordersData.map((json) => RxOrder.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to load Rx orders');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get Rx order by ID
  Future<RxOrder?> getRxOrderById(String orderId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final order = _mockRxOrders.firstWhere(
        (order) => order.id == orderId,
        orElse: () => throw Exception('Order not found'),
      );

      return order;
    } catch (e) {
      throw Exception('Failed to get Rx order: ${e.toString()}');
    }
  }

  // Create new Rx order
  Future<RxOrder> createRxOrder({
    required String userId,
    required String pharmacyId,
    required List<RxOrderItem> items,
    required RxOrderType orderType,
    String? prescriptionImageUrl,
    String? doctorName,
    String? doctorLicense,
    String? patientNotes,
    bool requiresInsurance = false,
    String? insuranceProvider,
    String? insurancePolicyNumber,
  }) async {
    try {
      setLoading(true);
      setError(null);

      await Future.delayed(const Duration(milliseconds: 1000));

      final pharmacy = _mockPharmacies.firstWhere(
        (p) => p.id == pharmacyId,
        orElse: () => throw Exception('Pharmacy not found'),
      );

      // Calculate totals
      double subtotal = 0.0;
      for (final item in items) {
        subtotal += item.totalPrice;
      }

      const double tax = 0.08; // 8% tax
      const double discount = 0.0;
      final double total = subtotal + (subtotal * tax) - discount;

      final newOrder = RxOrder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        pharmacyId: pharmacyId,
        pharmacyName: pharmacy.name,
        pharmacyAddress: pharmacy.address,
        pharmacyPhone: pharmacy.phone,
        items: items,
        subtotal: subtotal,
        tax: subtotal * tax,
        discount: discount,
        total: total,
        orderType: orderType,
        orderDate: DateTime.now(),
        expectedReadyDate: DateTime.now().add(const Duration(days: 1)),
        prescriptionImageUrl: prescriptionImageUrl,
        doctorName: doctorName,
        doctorLicense: doctorLicense,
        patientNotes: patientNotes,
        requiresInsurance: requiresInsurance,
        insuranceProvider: insuranceProvider,
        insurancePolicyNumber: insurancePolicyNumber,
      );

      _mockRxOrders.insert(0, newOrder);
      return newOrder;
    } catch (e) {
      throw Exception('Failed to create Rx order: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  // Update Rx order status
  Future<bool> updateRxOrderStatus(String orderId, RxOrderStatus newStatus) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final orderIndex = _mockRxOrders.indexWhere((order) => order.id == orderId);
      if (orderIndex == -1) {
        throw Exception('Order not found');
      }

      _mockRxOrders[orderIndex] = _mockRxOrders[orderIndex].copyWith(status: newStatus);
      return true;
    } catch (e) {
      throw Exception('Failed to update Rx order status: ${e.toString()}');
    }
  }

  // Cancel Rx order
  Future<bool> cancelRxOrder(String orderId, String reason) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final orderIndex = _mockRxOrders.indexWhere((order) => order.id == orderId);
      if (orderIndex == -1) {
        throw Exception('Order not found');
      }

      _mockRxOrders[orderIndex] = _mockRxOrders[orderIndex].copyWith(
        status: RxOrderStatus.cancelled,
        pharmacyNotes: reason,
      );
      return true;
    } catch (e) {
      throw Exception('Failed to cancel Rx order: ${e.toString()}');
    }
  }

  // Get pharmacies
  Future<List<Pharmacy>> getPharmacies() async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      return _mockPharmacies;
    } catch (e) {
      throw Exception('Failed to load pharmacies: ${e.toString()}');
    }
  }

  // Get medicines
  Future<List<Medicine>> getMedicines() async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      return _mockMedicines;
    } catch (e) {
      throw Exception('Failed to load medicines: ${e.toString()}');
    }
  }

  // Search medicines
  Future<List<Medicine>> searchMedicines(String query) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      
      final lowercaseQuery = query.toLowerCase();
      return _mockMedicines.where((medicine) =>
        medicine.name.toLowerCase().contains(lowercaseQuery) ||
        medicine.manufacturer.toLowerCase().contains(lowercaseQuery)
      ).toList();
    } catch (e) {
      throw Exception('Failed to search medicines: ${e.toString()}');
    }
  }

  // Mock data generators
  static List<Pharmacy> _generateMockPharmacies() {
    return [
      Pharmacy(
        id: 'pharm1',
        name: 'MediCare Pharmacy',
        address: '123 Main St, Downtown, NY 10001',
        phone: '+1 (555) 123-4567',
        email: 'info@medicare-pharmacy.com',
        rating: 4.5,
        reviewCount: 128,
        isOpen: true,
        services: ['Prescriptions', 'Immunizations', 'Health Screenings', 'Delivery'],
        operatingHours: 'Mon-Fri: 8AM-9PM, Sat: 9AM-6PM, Sun: 10AM-4PM',
        deliveryFee: 5.99,
        offersDelivery: true,
        offersPickup: true,
      ),
      Pharmacy(
        id: 'pharm2',
        name: 'HealthFirst Pharmacy',
        address: '456 Oak Ave, Midtown, NY 10002',
        phone: '+1 (555) 234-5678',
        email: 'contact@healthfirst-pharmacy.com',
        rating: 4.2,
        reviewCount: 89,
        isOpen: true,
        services: ['Prescriptions', 'Compounding', 'Consultations'],
        operatingHours: 'Mon-Fri: 7AM-8PM, Sat: 8AM-5PM',
        deliveryFee: 3.99,
        offersDelivery: true,
        offersPickup: true,
      ),
      Pharmacy(
        id: 'pharm3',
        name: 'Community Drug Store',
        address: '789 Pine St, Uptown, NY 10003',
        phone: '+1 (555) 345-6789',
        email: 'hello@community-drug.com',
        rating: 4.7,
        reviewCount: 156,
        isOpen: true,
        services: ['Prescriptions', 'Immunizations', 'Health Screenings', 'Delivery', 'Compounding'],
        operatingHours: 'Mon-Sun: 24/7',
        deliveryFee: 7.99,
        offersDelivery: true,
        offersPickup: true,
      ),
    ];
  }

  static List<Medicine> _generateMockMedicines() {
    return [
      Medicine(
        id: 'med1',
        name: 'Lisinopril',
        dosage: '10mg',
        medicineType: 'Tablet',
        manufacturer: 'Teva Pharmaceuticals',
        expiryDate: DateTime.now().add(const Duration(days: 365)),
        totalQuantity: 30,
        remainingQuantity: 30,
        notes: 'ACE inhibitor for hypertension',
      ),
      Medicine(
        id: 'med2',
        name: 'Metformin',
        dosage: '500mg',
        medicineType: 'Tablet',
        manufacturer: 'Mylan Pharmaceuticals',
        expiryDate: DateTime.now().add(const Duration(days: 400)),
        totalQuantity: 60,
        remainingQuantity: 60,
        notes: 'Oral diabetes medication',
      ),
      Medicine(
        id: 'med3',
        name: 'Atorvastatin',
        dosage: '20mg',
        medicineType: 'Tablet',
        manufacturer: 'Pfizer',
        expiryDate: DateTime.now().add(const Duration(days: 500)),
        totalQuantity: 30,
        remainingQuantity: 30,
        notes: 'Statin for cholesterol management',
      ),
      Medicine(
        id: 'med4',
        name: 'Omeprazole',
        dosage: '20mg',
        medicineType: 'Capsule',
        manufacturer: 'AstraZeneca',
        expiryDate: DateTime.now().add(const Duration(days: 300)),
        totalQuantity: 30,
        remainingQuantity: 30,
        notes: 'Proton pump inhibitor for acid reflux',
      ),
      Medicine(
        id: 'med5',
        name: 'Amlodipine',
        dosage: '5mg',
        medicineType: 'Tablet',
        manufacturer: 'Novartis',
        expiryDate: DateTime.now().add(const Duration(days: 450)),
        totalQuantity: 30,
        remainingQuantity: 30,
        notes: 'Calcium channel blocker for hypertension',
      ),
    ];
  }

  static List<RxOrder> _generateMockRxOrders() {
    final now = DateTime.now();
    
    return [
      RxOrder(
        id: 'rx1',
        userId: 'user_123',
        pharmacyId: 'pharm1',
        pharmacyName: 'MediCare Pharmacy',
        pharmacyAddress: '123 Main St, Downtown, NY 10001',
        pharmacyPhone: '+1 (555) 123-4567',
        items: [
          RxOrderItem(
            id: 'item1',
            medicine: _mockMedicines[0], // Lisinopril
            quantity: 30,
            unitPrice: 15.99,
            totalPrice: 479.70,
            dosage: '10mg once daily',
            instructions: 'Take with or without food',
          ),
        ],
        subtotal: 479.70,
        tax: 38.38,
        total: 518.08,
        orderType: RxOrderType.newPrescription,
        orderDate: now.subtract(const Duration(days: 2)),
        expectedReadyDate: now.subtract(const Duration(days: 1)),
        status: RxOrderStatus.readyForPickup,
        doctorName: 'Dr. Sarah Johnson',
        doctorLicense: 'MD123456',
      ),
      RxOrder(
        id: 'rx2',
        userId: 'user_123',
        pharmacyId: 'pharm2',
        pharmacyName: 'HealthFirst Pharmacy',
        pharmacyAddress: '456 Oak Ave, Midtown, NY 10002',
        pharmacyPhone: '+1 (555) 234-5678',
        items: [
          RxOrderItem(
            id: 'item2',
            medicine: _mockMedicines[1], // Metformin
            quantity: 60,
            unitPrice: 12.50,
            totalPrice: 750.00,
            dosage: '500mg twice daily',
            instructions: 'Take with meals',
          ),
        ],
        subtotal: 750.00,
        tax: 60.00,
        total: 810.00,
        orderType: RxOrderType.refill,
        orderDate: now.subtract(const Duration(days: 5)),
        expectedReadyDate: now.subtract(const Duration(days: 4)),
        status: RxOrderStatus.delivered,
        doctorName: 'Dr. Michael Brown',
        doctorLicense: 'MD789012',
      ),
    ];
  }

  // State management (simplified for service)
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void setLoading(bool loading) {
    _isLoading = loading;
  }

  void setError(String? error) {
    _error = error;
  }
} 