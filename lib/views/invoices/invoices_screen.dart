import 'package:flutter/material.dart';
import '../../models/invoice.dart';
import '../../viewmodels/invoice_view_model.dart';
import '../../core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'widgets/invoice_card.dart';
import 'invoice_detail_screen.dart';
import 'create_invoice_screen.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({Key? key}) : super(key: key);

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoiceViewModel>().loadInvoices();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Paid'),
          ],
        ),
      ),
      body: Consumer<InvoiceViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${viewModel.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadInvoices(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildInvoiceList(viewModel.invoices),
              _buildInvoiceList(viewModel.pendingInvoices),
              _buildInvoiceList(viewModel.paidInvoices),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createInvoice(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInvoiceList(List<Invoice> invoices) {
    if (invoices.isEmpty) {
      return const Center(
        child: Text(
          'No invoices found',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: InvoiceCard(
            invoice: invoice,
            onTap: () => _showInvoiceDetails(context, invoice),
            onDownload: () => _downloadPdf(context, invoice),
            onMarkAsPaid: invoice.isPaid
                ? null
                : () => _markAsPaid(context, invoice),
          ),
        );
      },
    );
  }

  Future<void> _createInvoice(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateInvoiceScreen()),
    );

    if (result == true && mounted) {
      context.read<InvoiceViewModel>().loadInvoices();
    }
  }

  Future<void> _showInvoiceDetails(
    BuildContext context,
    Invoice invoice,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceDetailScreen(invoice: invoice),
      ),
    );

    if (result == true && mounted) {
      context.read<InvoiceViewModel>().loadInvoices();
    }
  }

  Future<void> _downloadPdf(BuildContext context, Invoice invoice) async {
    try {
      final viewModel = context.read<InvoiceViewModel>();
      await viewModel.downloadPdf(invoice.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download invoice: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAsPaid(BuildContext context, Invoice invoice) async {
    try {
      final viewModel = context.read<InvoiceViewModel>();
      await viewModel.markAsPaid(invoice.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice marked as paid'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark invoice as paid: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
