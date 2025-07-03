import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/medical_service.dart';
import '../../models/order.dart';
import '../../viewmodels/order_view_model.dart';
import '../../core/theme/app_colors.dart';
import 'service_selection_screen.dart';

class CreateOrderScreen extends StatefulWidget {
  final String serviceProviderId;
  final String serviceProviderName;
  final List<MedicalService>? initialServices;

  const CreateOrderScreen({
    Key? key,
    required this.serviceProviderId,
    required this.serviceProviderName,
    this.initialServices,
  }) : super(key: key);

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final List<MedicalService> _selectedServices = [];
  final TextEditingController _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    if (widget.initialServices != null) {
      _selectedServices.addAll(widget.initialServices!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Create Order',
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service provider info
            _buildProviderCard(),
            const SizedBox(height: 16),

            // Selected services
            _buildSelectedServicesSection(),
            const SizedBox(height: 16),

            // Schedule section
            _buildScheduleSection(),
            const SizedBox(height: 16),

            // Notes section
            _buildNotesSection(),
            const SizedBox(height: 24),

            // Order summary
            _buildOrderSummary(),
            const SizedBox(height: 24),

            // Create order button
            _buildCreateOrderButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.local_hospital,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service Provider',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.serviceProviderName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedServicesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected Services (${_selectedServices.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceSelectionScreen(
                        selectedServices: _selectedServices,
                      ),
                    ),
                  );
                  
                  if (result != null && result is List<MedicalService>) {
                    setState(() {
                      _selectedServices.clear();
                      _selectedServices.addAll(result);
                    });
                  }
                },
                child: const Text('Add More'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectedServices.isEmpty)
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ServiceSelectionScreen(
                      selectedServices: _selectedServices,
                    ),
                  ),
                );
                
                if (result != null && result is List<MedicalService>) {
                  setState(() {
                    _selectedServices.clear();
                    _selectedServices.addAll(result);
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, color: Colors.grey[400]),
                    const SizedBox(width: 8),
                    Text(
                      'Tap to select services',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._selectedServices.map((service) => _buildServiceItem(service)),
        ],
      ),
    );
  }

  Widget _buildServiceItem(MedicalService service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (service.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    service.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '₹${service.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
            onPressed: () {
              setState(() {
                _selectedServices.remove(service);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDatePicker(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimePicker(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          setState(() {
            _selectedDate = date;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
            const SizedBox(width: 8),
            Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
        );
        if (time != null) {
          setState(() {
            _selectedTime = time;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: Colors.grey[600], size: 20),
            const SizedBox(width: 8),
            Text(
              _selectedTime.format(context),
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Notes (Optional)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add any special instructions or notes...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    final subtotal = _selectedServices.fold<double>(
      0.0,
      (sum, service) => sum + service.price,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
          _buildSummaryRow('Tax', '₹0.00'),
          _buildSummaryRow('Discount', '₹0.00'),
          const Divider(height: 24),
          _buildSummaryRow(
            'Total',
            '₹${subtotal.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: isTotal ? AppColors.textPrimary : Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: isTotal ? AppColors.primary : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateOrderButton() {
    return Consumer<OrderViewModel>(
      builder: (context, orderViewModel, child) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedServices.isEmpty || orderViewModel.isLoading
                ? null
                : () => _createOrder(orderViewModel),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: orderViewModel.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Create Order',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
    );
  }

  void _createOrder(OrderViewModel orderViewModel) async {
    final scheduledDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final success = await orderViewModel.createOrder(
      serviceProviderId: widget.serviceProviderId,
      serviceProviderName: widget.serviceProviderName,
      services: _selectedServices,
      scheduledDate: scheduledDateTime,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order created successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
} 