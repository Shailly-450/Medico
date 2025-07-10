import 'package:flutter/material.dart';
import '../../core/views/base_view.dart';
import '../../viewmodels/invoice_view_model.dart';
import '../../core/theme/app_colors.dart';
import '../../models/invoice.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class InvoiceDetailScreen extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDetailScreen({
    Key? key,
    required this.invoice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<InvoiceViewModel>(
      viewModelBuilder: () => InvoiceViewModel()..initialize(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Invoice #${invoice.invoiceNumber}',
            style: const TextStyle(
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
          actions: [
            IconButton(
              icon: const Icon(Icons.share, color: AppColors.textPrimary),
              onPressed: () {
                // TODO: Implement share functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share feature coming soon!')),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status and amount card
              _buildStatusCard(context),
              const SizedBox(height: 16),

              // Tax and claim eligibility section
              _buildTaxClaimSection(context),
              const SizedBox(height: 16),

              // Provider and patient info
              _buildInfoSection(context),
              const SizedBox(height: 16),

              // Linked entity information
              if (invoice.orderId != null || invoice.rxOrderId != null || invoice.appointmentId != null) ...[
                _buildLinkedEntitySection(context),
                const SizedBox(height: 16),
              ],

              // Invoice items
              _buildItemsSection(context),
              const SizedBox(height: 16),

              // Payment summary
              _buildPaymentSummary(context),
              const SizedBox(height: 16),

              // Notes and terms
              if (invoice.notes != null) ...[
                _buildNotesSection(context),
                const SizedBox(height: 16),
              ],

              if (invoice.paymentInstructions != null) ...[
                _buildPaymentInstructions(context),
                const SizedBox(height: 16),
              ],

              if (invoice.terms != null) ...[
                _buildTermsSection(context),
                const SizedBox(height: 16),
              ],

              // Action buttons
              _buildActionButtons(context, model),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Amount',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${invoice.currency} ${invoice.total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),
              _buildStatusChip(context),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Issue Date',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy').format(invoice.issueDate),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Due Date',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy').format(invoice.dueDate),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: invoice.isOverdue ? Colors.red : AppColors.textBlack,
                        ),
                  ),
                ],
              ),
            ],
          ),
          if (invoice.paidDate != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Paid Date',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(invoice.paidDate!),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color chipColor;
    Color textColor;
    IconData? icon;

    switch (invoice.status) {
      case InvoiceStatus.paid:
        chipColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        icon = Icons.check_circle;
        break;
      case InvoiceStatus.overdue:
        chipColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        icon = Icons.warning;
        break;
      case InvoiceStatus.sent:
        chipColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        icon = Icons.send;
        break;
      case InvoiceStatus.draft:
        chipColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        icon = Icons.edit;
        break;
      case InvoiceStatus.cancelled:
        chipColor = Colors.grey[200]!;
        textColor = Colors.grey[600]!;
        icon = Icons.cancel;
        break;
      case InvoiceStatus.refunded:
        chipColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        icon = Icons.refresh;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            invoice.statusDisplayName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxClaimSection(BuildContext context) {
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
          Text(
            'Tax & Claim Eligibility',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
          ),
          const SizedBox(height: 12),
          _buildTaxClaimRow('Tax Deductible', invoice.isTaxDeductible, Icons.receipt),
          _buildTaxClaimRow('Claimable', invoice.isClaimable, Icons.medical_services),
          if (invoice.isTaxDeductible) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green[700], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tax deductible amount: ${invoice.currency} ${invoice.taxDeductibleAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (invoice.isClaimable) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Claimable amount: ${invoice.currency} ${invoice.claimableAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTaxClaimRow(String label, bool isEligible, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: isEligible ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isEligible ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isEligible ? 'Eligible' : 'Not Eligible',
              style: TextStyle(
                color: isEligible ? Colors.green[700] : Colors.red[700],
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
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
          Text(
            'Provider Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Name', invoice.providerName),
          if (invoice.providerAddress != null)
            _buildInfoRow('Address', invoice.providerAddress!),
          if (invoice.providerPhone != null)
            _buildInfoRow('Phone', invoice.providerPhone!),
          if (invoice.providerEmail != null)
            _buildInfoRow('Email', invoice.providerEmail!),
          if (invoice.providerTaxId != null)
            _buildInfoRow('Tax ID', invoice.providerTaxId!),
          const SizedBox(height: 16),
          Text(
            'Patient Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Name', invoice.patientName),
          _buildInfoRow('Email', invoice.patientEmail),
          _buildInfoRow('Phone', invoice.patientPhone),
          if (invoice.patientAddress != null)
            _buildInfoRow('Address', invoice.patientAddress!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection(BuildContext context) {
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
          Text(
            'Invoice Items',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
          ),
          const SizedBox(height: 16),
          ...invoice.items.map((item) => _buildItemRow(context, item)),
        ],
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, InvoiceItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textBlack,
                      ),
                ),
              ),
              Text(
                '${invoice.currency} ${item.totalPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Qty: ${item.quantity}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(width: 16),
              Text(
                'Unit Price: ${invoice.currency} ${item.unitPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          if (item.notes != null) ...[
            const SizedBox(height: 8),
            Text(
              'Notes: ${item.notes}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(BuildContext context) {
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
          Text(
            'Payment Summary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Subtotal', invoice.subtotal),
          if (invoice.tax > 0) _buildSummaryRow('Tax', invoice.tax),
          if (invoice.discount > 0) _buildSummaryRow('Discount', -invoice.discount),
          const Divider(),
          _buildSummaryRow('Total', invoice.total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              fontSize: isTotal ? 16 : 14,
              color: AppColors.textBlack,
            ),
          ),
          Text(
            '${invoice.currency} ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? AppColors.primary : AppColors.textBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context) {
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
          Text(
            'Notes',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            invoice.notes!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textBlack,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInstructions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'Payment Instructions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            invoice.paymentInstructions!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.blue[800],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkedEntitySection(BuildContext context) {
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
              Icon(Icons.link, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Linked Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (invoice.orderId != null) ...[
            _buildLinkedItem(context, 'Order ID', invoice.orderId!, Icons.shopping_cart),
            const SizedBox(height: 8),
          ],
          if (invoice.rxOrderId != null) ...[
            _buildLinkedItem(context, 'Prescription Order ID', invoice.rxOrderId!, Icons.medication),
            const SizedBox(height: 8),
          ],
          if (invoice.appointmentId != null) ...[
            _buildLinkedItem(context, 'Appointment ID', invoice.appointmentId!, Icons.calendar_today),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildLinkedItem(BuildContext context, String label, String id, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              Text(
                id,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlack,
                    ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            // TODO: Navigate to the linked entity detail screen
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('View $label details coming soon!')),
            );
          },
          icon: Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 16),
        ),
      ],
    );
  }

  Widget _buildTermsSection(BuildContext context) {
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
          Text(
            'Terms & Conditions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            invoice.terms!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textBlack,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, InvoiceViewModel model) {
    return Column(
      children: [
        if (!invoice.isPaid && !invoice.isCancelled) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _markAsPaid(context, model),
              icon: const Icon(Icons.check_circle),
              label: const Text('Mark as Paid'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _downloadInvoice(context, model),
            icon: const Icon(Icons.download),
            label: const Text('Download PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _markAsPaid(BuildContext context, InvoiceViewModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Paid'),
        content: Text('Are you sure you want to mark invoice #${invoice.invoiceNumber} as paid?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              model.markAsPaid(invoice.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invoice marked as paid'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Mark as Paid'),
          ),
        ],
      ),
    );
  }

  void _downloadInvoice(BuildContext context, InvoiceViewModel model) async {
    final file = await model.downloadInvoice(invoice);
    if (file != null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Invoice downloaded successfully!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () async {
                try {
                  await model.openPdf(file);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error opening PDF: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download invoice: ${model.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 