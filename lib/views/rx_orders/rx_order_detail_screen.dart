import 'package:flutter/material.dart';
import '../../core/views/base_view.dart';
import '../../viewmodels/rx_order_view_model.dart';
import '../../core/theme/app_colors.dart';
import '../../models/rx_order.dart';
import 'widgets/rx_order_card.dart';

class RxOrderDetailScreen extends StatefulWidget {
  final RxOrder order;

  const RxOrderDetailScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<RxOrderDetailScreen> createState() => _RxOrderDetailScreenState();
}

class _RxOrderDetailScreenState extends State<RxOrderDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return BaseView<RxOrderViewModel>(
      viewModelBuilder: () => RxOrderViewModel()..initialize(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text('Order #${widget.order.id.substring(widget.order.id.length - 6)}'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            if (widget.order.status != RxOrderStatus.delivered)
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(value, model),
                itemBuilder: (context) => [
                  if (widget.order.status == RxOrderStatus.pending)
                    const PopupMenuItem(
                      value: 'cancel',
                      child: Row(
                        children: [
                          Icon(Icons.cancel, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Cancel Order'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share),
                        SizedBox(width: 8),
                        Text('Share Order'),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderCard(),
              const SizedBox(height: 24),
              _buildPharmacySection(),
              const SizedBox(height: 24),
              _buildMedicinesSection(),
              const SizedBox(height: 24),
              _buildPrescriptionSection(),
              const SizedBox(height: 24),
              _buildDoctorSection(),
              const SizedBox(height: 24),
              _buildInsuranceSection(),
              const SizedBox(height: 24),
              _buildTimelineSection(),
              const SizedBox(height: 24),
              _buildNotesSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard() {
    return RxOrderCard(
      order: widget.order,
      onCancel: null, // No cancel action in detail view
    );
  }

  Widget _buildPharmacySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_pharmacy,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Pharmacy Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', widget.order.pharmacyName),
            if (widget.order.pharmacyAddress != null)
              _buildInfoRow('Address', widget.order.pharmacyAddress!),
            if (widget.order.pharmacyPhone != null)
              _buildInfoRow('Phone', widget.order.pharmacyPhone!, isPhone: true),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicinesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.medication,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Medicines (${widget.order.items.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...widget.order.items.map((item) => _buildMedicineItem(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineItem(RxOrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.medication,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.medicine.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${item.medicine.dosage} • ${item.medicine.medicineType}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${item.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quantity: ${item.quantity}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Text(
                'Unit Price: ₹${item.unitPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (item.dosage != null) ...[
            const SizedBox(height: 8),
            Text(
              'Dosage: ${item.dosage}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
          if (item.instructions != null) ...[
            const SizedBox(height: 8),
            Text(
              'Instructions: ${item.instructions}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrescriptionSection() {
    if (widget.order.prescriptionImageUrl == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.image,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Prescription',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.order.prescriptionImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorSection() {
    if (widget.order.doctorName == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Doctor Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', widget.order.doctorName!),
            if (widget.order.doctorLicense != null)
              _buildInfoRow('License', widget.order.doctorLicense!),
          ],
        ),
      ),
    );
  }

  Widget _buildInsuranceSection() {
    if (!widget.order.requiresInsurance) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.health_and_safety,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Insurance Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.order.insuranceProvider != null)
              _buildInfoRow('Provider', widget.order.insuranceProvider!),
            if (widget.order.insurancePolicyNumber != null)
              _buildInfoRow('Policy Number', widget.order.insurancePolicyNumber!),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timeline,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Order Timeline',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTimelineItem(
              'Order Placed',
              widget.order.orderDate,
              Icons.shopping_cart,
              Colors.blue,
              true,
            ),
            if (widget.order.expectedReadyDate != null)
              _buildTimelineItem(
                'Expected Ready',
                widget.order.expectedReadyDate!,
                Icons.schedule,
                Colors.orange,
                widget.order.status.index >= RxOrderStatus.processing.index,
              ),
            if (widget.order.status == RxOrderStatus.readyForPickup)
              _buildTimelineItem(
                'Ready for Pickup',
                widget.order.expectedReadyDate ?? DateTime.now(),
                Icons.check_circle,
                Colors.green,
                true,
              ),
            if (widget.order.pickupDate != null)
              _buildTimelineItem(
                'Picked Up',
                widget.order.pickupDate!,
                Icons.local_shipping,
                Colors.green,
                true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String title, DateTime date, IconData icon, Color color, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted ? color : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isCompleted ? Colors.white : Colors.grey[600],
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isCompleted ? Colors.black : Colors.grey[600],
                  ),
                ),
                Text(
                  _formatDateTime(date),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    if (widget.order.patientNotes == null && widget.order.pharmacyNotes == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Notes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.order.patientNotes != null) ...[
              const Text(
                'Patient Notes:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.order.patientNotes!,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
              if (widget.order.pharmacyNotes != null) const SizedBox(height: 12),
            ],
            if (widget.order.pharmacyNotes != null) ...[
              const Text(
                'Pharmacy Notes:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.order.pharmacyNotes!,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                if (isPhone)
                  IconButton(
                    icon: const Icon(Icons.phone, size: 16),
                    onPressed: () {
                      // TODO: Implement phone call functionality
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _handleMenuAction(String action, RxOrderViewModel model) {
    switch (action) {
      case 'cancel':
        _showCancelDialog(model);
        break;
      case 'share':
        _shareOrder();
        break;
    }
  }

  void _showCancelDialog(RxOrderViewModel model) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to cancel this order?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for cancellation (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await model.cancelRxOrder(
                widget.order.id,
                reasonController.text.isEmpty ? 'Cancelled by user' : reasonController.text,
              );
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order cancelled successfully')),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _shareOrder() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }
} 