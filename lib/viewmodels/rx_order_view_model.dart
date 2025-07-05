import '../core/viewmodels/base_view_model.dart';
import '../core/services/rx_order_service.dart';
import '../models/rx_order.dart';
import '../models/medicine.dart';

class RxOrderViewModel extends BaseViewModel {
  final RxOrderService _rxOrderService = RxOrderService();

  List<RxOrder> _rxOrders = [];
  List<Pharmacy> _pharmacies = [];
  List<Medicine> _medicines = [];
  RxOrder? _currentOrder;
  List<RxOrderItem> _selectedItems = [];

  // Filter properties
  String _searchQuery = '';
  RxOrderStatus? _statusFilter;
  RxOrderType? _typeFilter;
  String? _pharmacyFilter;

  // Getters
  List<RxOrder> get rxOrders => _rxOrders;
  List<Pharmacy> get pharmacies => _pharmacies;
  List<Medicine> get medicines => _medicines;
  RxOrder? get currentOrder => _currentOrder;
  List<RxOrderItem> get selectedItems => _selectedItems;

  // Filter getters
  String get searchQuery => _searchQuery;
  RxOrderStatus? get statusFilter => _statusFilter;
  RxOrderType? get typeFilter => _typeFilter;
  String? get pharmacyFilter => _pharmacyFilter;

  // Statistics
  int get totalOrders => _rxOrders.length;
  int get pendingOrders => _rxOrders.where((o) => o.isPending).length;
  int get processingOrders => _rxOrders.where((o) => o.isProcessing).length;
  int get readyForPickupOrders => _rxOrders.where((o) => o.isReadyForPickup).length;
  int get completedOrders => _rxOrders.where((o) => o.isDelivered).length;

  // Filtered orders
  List<RxOrder> get filteredOrders {
    List<RxOrder> filtered = _rxOrders;

    // Filter by status
    if (_statusFilter != null) {
      filtered = filtered.where((order) => order.status == _statusFilter).toList();
    }

    // Filter by type
    if (_typeFilter != null) {
      filtered = filtered.where((order) => order.orderType == _typeFilter).toList();
    }

    // Filter by pharmacy
    if (_pharmacyFilter != null) {
      filtered = filtered.where((order) => order.pharmacyId == _pharmacyFilter).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((order) =>
        order.pharmacyName.toLowerCase().contains(query) ||
        order.doctorName?.toLowerCase().contains(query) == true ||
        order.items.any((item) => 
          item.medicine.name.toLowerCase().contains(query)
        )
      ).toList();
    }

    return filtered;
  }

  // Initialize data
  Future<void> initialize() async {
    setBusy(true);
    setError(null);

    try {
      // Initialize mock data
      RxOrderService.initializeMockData();

      // Load data in parallel
      await Future.wait([
        _loadRxOrders(),
        _loadPharmacies(),
        _loadMedicines(),
      ]);

      notifyListeners();
    } catch (e) {
      setError('Failed to initialize: ${e.toString()}');
    } finally {
      setBusy(false);
    }
  }

  // Load Rx orders
  Future<void> _loadRxOrders() async {
    try {
      _rxOrders = await _rxOrderService.getRxOrders(userId: 'user_123');
    } catch (e) {
      setError('Failed to load Rx orders: ${e.toString()}');
    }
  }

  // Load pharmacies
  Future<void> _loadPharmacies() async {
    try {
      _pharmacies = await _rxOrderService.getPharmacies();
    } catch (e) {
      setError('Failed to load pharmacies: ${e.toString()}');
    }
  }

  // Load medicines
  Future<void> _loadMedicines() async {
    try {
      _medicines = await _rxOrderService.getMedicines();
    } catch (e) {
      setError('Failed to load medicines: ${e.toString()}');
    }
  }

  // Search medicines
  Future<List<Medicine>> searchMedicines(String query) async {
    try {
      return await _rxOrderService.searchMedicines(query);
    } catch (e) {
      setError('Failed to search medicines: ${e.toString()}');
      return [];
    }
  }

  // Create Rx order
  Future<bool> createRxOrder({
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
    setBusy(true);
    setError(null);

    try {
      final newOrder = await _rxOrderService.createRxOrder(
        userId: 'user_123',
        pharmacyId: pharmacyId,
        items: items,
        orderType: orderType,
        prescriptionImageUrl: prescriptionImageUrl,
        doctorName: doctorName,
        doctorLicense: doctorLicense,
        patientNotes: patientNotes,
        requiresInsurance: requiresInsurance,
        insuranceProvider: insuranceProvider,
        insurancePolicyNumber: insurancePolicyNumber,
      );

      _rxOrders.insert(0, newOrder);
      _currentOrder = newOrder;
      _selectedItems.clear();
      notifyListeners();

      return true;
    } catch (e) {
      setError('Failed to create Rx order: ${e.toString()}');
      return false;
    } finally {
      setBusy(false);
    }
  }

  // Update Rx order status
  Future<bool> updateRxOrderStatus(String orderId, RxOrderStatus newStatus) async {
    setBusy(true);
    setError(null);

    try {
      final success = await _rxOrderService.updateRxOrderStatus(orderId, newStatus);
      if (success) {
        final orderIndex = _rxOrders.indexWhere((order) => order.id == orderId);
        if (orderIndex != -1) {
          _rxOrders[orderIndex] = _rxOrders[orderIndex].copyWith(status: newStatus);
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      setError('Failed to update Rx order status: ${e.toString()}');
      return false;
    } finally {
      setBusy(false);
    }
  }

  // Cancel Rx order
  Future<bool> cancelRxOrder(String orderId, String reason) async {
    setBusy(true);
    setError(null);

    try {
      final success = await _rxOrderService.cancelRxOrder(orderId, reason);
      if (success) {
        final orderIndex = _rxOrders.indexWhere((order) => order.id == orderId);
        if (orderIndex != -1) {
          _rxOrders[orderIndex] = _rxOrders[orderIndex].copyWith(
            status: RxOrderStatus.cancelled,
            pharmacyNotes: reason,
          );
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      setError('Failed to cancel Rx order: ${e.toString()}');
      return false;
    } finally {
      setBusy(false);
    }
  }

  // Get Rx order by ID
  Future<RxOrder?> getRxOrderById(String orderId) async {
    try {
      return await _rxOrderService.getRxOrderById(orderId);
    } catch (e) {
      setError('Failed to get Rx order: ${e.toString()}');
      return null;
    }
  }

  // Set current order
  void setCurrentOrder(RxOrder? order) {
    _currentOrder = order;
    notifyListeners();
  }

  // Add item to selection
  void addItemToSelection(RxOrderItem item) {
    _selectedItems.add(item);
    notifyListeners();
  }

  // Remove item from selection
  void removeItemFromSelection(String itemId) {
    _selectedItems.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  // Update item quantity
  void updateItemQuantity(String itemId, int quantity) {
    final index = _selectedItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final item = _selectedItems[index];
      _selectedItems[index] = item.copyWith(
        quantity: quantity,
        totalPrice: item.unitPrice * quantity,
      );
      notifyListeners();
    }
  }

  // Clear selection
  void clearSelection() {
    _selectedItems.clear();
    notifyListeners();
  }

  // Filter methods
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(RxOrderStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setTypeFilter(RxOrderType? type) {
    _typeFilter = type;
    notifyListeners();
  }

  void setPharmacyFilter(String? pharmacyId) {
    _pharmacyFilter = pharmacyId;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    _typeFilter = null;
    _pharmacyFilter = null;
    notifyListeners();
  }

  // Utility methods
  double getTotalPrice() {
    return _selectedItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int getTotalItems() {
    return _selectedItems.fold(0, (sum, item) => sum + item.quantity);
  }

  List<RxOrder> getOrdersByStatus(RxOrderStatus status) {
    return _rxOrders.where((order) => order.status == status).toList();
  }

  List<RxOrder> getOrdersByType(RxOrderType type) {
    return _rxOrders.where((order) => order.orderType == type).toList();
  }

  List<RxOrder> getOrdersByPharmacy(String pharmacyId) {
    return _rxOrders.where((order) => order.pharmacyId == pharmacyId).toList();
  }

  // Get pharmacy by ID
  Pharmacy? getPharmacyById(String pharmacyId) {
    try {
      return _pharmacies.firstWhere((pharmacy) => pharmacy.id == pharmacyId);
    } catch (e) {
      return null;
    }
  }

  // Get medicine by ID
  Medicine? getMedicineById(String medicineId) {
    try {
      return _medicines.firstWhere((medicine) => medicine.id == medicineId);
    } catch (e) {
      return null;
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await initialize();
  }
} 