import 'package:flutter/material.dart';
import '../../core/views/base_view.dart';
import '../../viewmodels/invoice_view_model.dart';
import '../../core/theme/app_colors.dart';
import '../../models/invoice.dart';
import '../../models/order.dart';
import '../../models/rx_order.dart';
import '../../models/appointment.dart';
import '../../models/medical_service.dart';
import '../../models/medicine.dart';
import 'invoice_detail_screen.dart';

class CreateInvoiceDemoScreen extends StatefulWidget {
  const CreateInvoiceDemoScreen({Key? key}) : super(key: key);

  @override
  State<CreateInvoiceDemoScreen> createState() => _CreateInvoiceDemoScreenState();
}

class _CreateInvoiceDemoScreenState extends State<CreateInvoiceDemoScreen> {
  Invoice? _createdInvoice;

  @override
  Widget build(BuildContext context) {
    return BaseView<InvoiceViewModel>(
      viewModelBuilder: () => InvoiceViewModel()..initialize(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Create Invoice Demo',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                      'Invoice Creation Demo',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBlack,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This demo shows how to create invoices from different entities like orders, prescription orders, and appointments.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Create from Order
              _buildDemoSection(
                context,
                'Create from Order',
                'Generate an invoice from a medical service order',
                Icons.shopping_cart,
                Colors.blue,
                () => _createInvoiceFromOrder(model),
              ),
              const SizedBox(height: 16),

              // Create from Prescription Order
              _buildDemoSection(
                context,
                'Create from Prescription',
                'Generate an invoice from a prescription order',
                Icons.medication,
                Colors.green,
                () => _createInvoiceFromRxOrder(model),
              ),
              const SizedBox(height: 16),

              // Create from Appointment
              _buildDemoSection(
                context,
                'Create from Appointment',
                'Generate an invoice from a medical appointment',
                Icons.calendar_today,
                Colors.orange,
                () => _createInvoiceFromAppointment(model),
              ),
              const SizedBox(height: 24),

              // Created Invoice Display
              if (_createdInvoice != null) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Invoice Created Successfully!',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInvoiceSummary(context, _createdInvoice!),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InvoiceDetailScreen(
                                  invoice: _createdInvoice!,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.visibility),
                          label: const Text('View Invoice Details'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoSection(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBlack,
                          ),
                    ),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add),
              label: Text('Create $title Invoice'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceSummary(BuildContext context, Invoice invoice) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Invoice #${invoice.invoiceNumber}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  invoice.statusDisplayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            invoice.providerName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                '${invoice.currency} ${invoice.total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
            ],
          ),
          if (invoice.orderId != null || invoice.rxOrderId != null || invoice.appointmentId != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.link, color: AppColors.primary, size: 16),
                const SizedBox(width: 4),
                Text(
                  _getLinkedEntityText(invoice),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getLinkedEntityText(Invoice invoice) {
    if (invoice.orderId != null) return 'Linked to Order';
    if (invoice.rxOrderId != null) return 'Linked to Prescription';
    if (invoice.appointmentId != null) return 'Linked to Appointment';
    return '';
  }

  void _createInvoiceFromOrder(InvoiceViewModel model) {
    // Create a mock order
    final order = Order(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_001',
      serviceProviderId: 'hospital_001',
      serviceProviderName: 'City General Hospital',
      items: [
        OrderItem(
          id: 'item_001',
          service: MedicalService(
            id: 'service_001',
            name: 'General Consultation',
            description: 'Comprehensive health checkup',
            price: 1500.0,
            category: 'Consultation',
            duration: 30,
            isAvailable: true,
          ),
          quantity: 1,
          unitPrice: 1500.0,
          totalPrice: 1500.0,
        ),
        OrderItem(
          id: 'item_002',
          service: MedicalService(
            id: 'service_002',
            name: 'Blood Test Package',
            description: 'Complete blood count and biochemistry',
            price: 2500.0,
            category: 'Laboratory',
            duration: 60,
            isAvailable: true,
          ),
          quantity: 1,
          unitPrice: 2500.0,
          totalPrice: 2500.0,
        ),
      ],
      subtotal: 4000.0,
      tax: 720.0,
      discount: 200.0,
      total: 4520.0,
      currency: 'INR',
      orderDate: DateTime.now(),
    );

    final invoice = model.createInvoiceFromOrder(
      order,
      'John Doe',
      'john.doe@email.com',
      '+91 98765 43210',
    );

    setState(() {
      _createdInvoice = invoice;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invoice created from order: ${invoice.invoiceNumber}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _createInvoiceFromRxOrder(InvoiceViewModel model) {
    // Create a mock prescription order
    final rxOrder = RxOrder(
      id: 'rx_order_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_001',
      pharmacyId: 'pharmacy_001',
      pharmacyName: 'MedPlus Pharmacy',
      pharmacyAddress: '789 Pharmacy Lane, Mumbai',
      pharmacyPhone: '+91 22 9876 5432',
      items: [
        RxOrderItem(
          id: 'rx_item_001',
          medicine: Medicine(
            id: 'med_001',
            name: 'Paracetamol 500mg',
            dosage: '500mg',
            medicineType: 'Tablet',
            manufacturer: 'Generic Pharma',
            totalQuantity: 30,
            remainingQuantity: 20,
          ),
          quantity: 2,
          unitPrice: 150.0,
          totalPrice: 300.0,
          notes: 'Take 1 tablet every 6 hours',
        ),
        RxOrderItem(
          id: 'rx_item_002',
          medicine: Medicine(
            id: 'med_002',
            name: 'Vitamin D3 1000IU',
            dosage: '1000IU',
            medicineType: 'Capsule',
            manufacturer: 'Health Supplements Ltd',
            totalQuantity: 10,
            remainingQuantity: 8,
          ),
          quantity: 1,
          unitPrice: 450.0,
          totalPrice: 450.0,
          notes: 'Take 1 capsule daily',
        ),
      ],
      subtotal: 750.0,
      tax: 135.0,
      discount: 0.0,
      total: 885.0,
      currency: 'INR',
      orderDate: DateTime.now(),
      patientNotes: 'Prescription verified by Dr. Smith',
    );

    final invoice = model.createInvoiceFromRxOrder(
      rxOrder,
      'John Doe',
      'john.doe@email.com',
      '+91 98765 43210',
    );

    setState(() {
      _createdInvoice = invoice;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invoice created from prescription: ${invoice.invoiceNumber}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _createInvoiceFromAppointment(InvoiceViewModel model) {
    // Create a mock appointment
    final appointment = Appointment(
      id: 'appt_${DateTime.now().millisecondsSinceEpoch}',
      doctorName: 'Dr. Sarah Johnson',
      doctorImage: 'assets/images/doctor.jpg',
      specialty: 'Cardiology',
      isVideoCall: true,
      date: '2024-01-15',
      time: '10:00 AM', appointmentType: 'scheduled',
    );

    final invoice = model.createInvoiceFromAppointment(
      appointment,
      'John Doe',
      'john.doe@email.com',
      '+91 98765 43210',
      providerId: 'hospital_003',
      providerName: 'Cardiology Specialists',
      providerAddress: '456 Heart Street, Mumbai, Maharashtra 400006',
      providerPhone: '+91 22 9999 0000',
      providerEmail: 'billing@cardiology.com',
      consultationFee: 2500.0,
      tax: 450.0,
      discount: 0.0,
    );

    setState(() {
      _createdInvoice = invoice;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invoice created from appointment: ${invoice.invoiceNumber}'),
        backgroundColor: Colors.green,
      ),
    );
  }
} 