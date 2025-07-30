import 'package:flutter/material.dart';
import '../../viewmodels/invoice_view_model.dart';
import '../../models/invoice.dart';
import '../../core/theme/app_colors.dart';
import 'package:provider/provider.dart';

class InvoiceApiTestScreen extends StatefulWidget {
  const InvoiceApiTestScreen({Key? key}) : super(key: key);

  @override
  State<InvoiceApiTestScreen> createState() => _InvoiceApiTestScreenState();
}

class _InvoiceApiTestScreenState extends State<InvoiceApiTestScreen> {
  final Map<String, bool> _testResults = {};
  final Map<String, String> _testMessages = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runAllTests();
    });
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isLoading = true;
      _testResults.clear();
      _testMessages.clear();
    });

    await _testGetInvoices();
    await _testGetInvoiceSummary();
    await _testCreateInvoice();
    await _testGetInvoiceById();
    await _testUpdateInvoice();
    await _testMarkAsPaid();
    await _testDownloadPdf();
    await _testDeleteInvoice();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testGetInvoices() async {
    try {
      final viewModel = context.read<InvoiceViewModel>();
      await viewModel.loadInvoices();
      
      setState(() {
        _testResults['Get Invoices'] = viewModel.error == null;
        _testMessages['Get Invoices'] = viewModel.error ?? 
            'Success: Loaded ${viewModel.invoices.length} invoices';
      });
    } catch (e) {
      setState(() {
        _testResults['Get Invoices'] = false;
        _testMessages['Get Invoices'] = 'Error: $e';
      });
    }
  }

  Future<void> _testGetInvoiceSummary() async {
    try {
      final viewModel = context.read<InvoiceViewModel>();
      await viewModel.loadInvoiceSummary();
      
      setState(() {
        _testResults['Get Invoice Summary'] = viewModel.error == null;
        _testMessages['Get Invoice Summary'] = viewModel.error ?? 
            'Success: Summary loaded - ${viewModel.summary?.toString() ?? 'No data'}';
      });
    } catch (e) {
      setState(() {
        _testResults['Get Invoice Summary'] = false;
        _testMessages['Get Invoice Summary'] = 'Error: $e';
      });
    }
  }

  Future<void> _testCreateInvoice() async {
    try {
      final viewModel = context.read<InvoiceViewModel>();
      final invoice = await viewModel.createInvoice(
        type: 'Consultation',
        provider: 'Test Provider',
        amount: 1000.0,
        dueDate: DateTime.now().add(const Duration(days: 30)),
        items: [
          {'name': 'Test Service', 'price': 1000.0}
        ],
      );
      
      setState(() {
        _testResults['Create Invoice'] = invoice != null;
        _testMessages['Create Invoice'] = invoice != null ? 
            'Success: Created invoice ${invoice.invoiceNumber}' : 
            'Error: Failed to create invoice';
      });
    } catch (e) {
      setState(() {
        _testResults['Create Invoice'] = false;
        _testMessages['Create Invoice'] = 'Error: $e';
      });
    }
  }

  Future<void> _testGetInvoiceById() async {
    try {
      final viewModel = context.read<InvoiceViewModel>();
      if (viewModel.invoices.isNotEmpty) {
        final firstInvoice = viewModel.invoices.first;
        final invoice = await viewModel.getInvoiceById(firstInvoice.id);
        
        setState(() {
          _testResults['Get Invoice By ID'] = invoice != null;
          _testMessages['Get Invoice By ID'] = invoice != null ? 
              'Success: Retrieved invoice ${invoice.invoiceNumber}' : 
              'Error: Failed to get invoice';
        });
      } else {
        setState(() {
          _testResults['Get Invoice By ID'] = false;
          _testMessages['Get Invoice By ID'] = 'Error: No invoices available to test';
        });
      }
    } catch (e) {
      setState(() {
        _testResults['Get Invoice By ID'] = false;
        _testMessages['Get Invoice By ID'] = 'Error: $e';
      });
    }
  }

  Future<void> _testUpdateInvoice() async {
    try {
      final viewModel = context.read<InvoiceViewModel>();
      if (viewModel.invoices.isNotEmpty) {
        final firstInvoice = viewModel.invoices.first;
        final updatedInvoice = await viewModel.updateInvoice(
          invoiceId: firstInvoice.id,
          type: 'Prescription',
          provider: 'Updated Provider',
          amount: 1500.0,
          dueDate: DateTime.now().add(const Duration(days: 45)),
          items: [
            {'name': 'Updated Service', 'price': 1500.0}
          ],
        );
        
        setState(() {
          _testResults['Update Invoice'] = updatedInvoice != null;
          _testMessages['Update Invoice'] = updatedInvoice != null ? 
              'Success: Updated invoice ${updatedInvoice.invoiceNumber}' : 
              'Error: Failed to update invoice';
        });
      } else {
        setState(() {
          _testResults['Update Invoice'] = false;
          _testMessages['Update Invoice'] = 'Error: No invoices available to test';
        });
      }
    } catch (e) {
      setState(() {
        _testResults['Update Invoice'] = false;
        _testMessages['Update Invoice'] = 'Error: $e';
      });
    }
  }

  Future<void> _testMarkAsPaid() async {
    try {
      final viewModel = context.read<InvoiceViewModel>();
      final pendingInvoices = viewModel.pendingInvoices;
      
      if (pendingInvoices.isNotEmpty) {
        final pendingInvoice = pendingInvoices.first;
        await viewModel.markAsPaid(pendingInvoice.id);
        
        setState(() {
          _testResults['Mark As Paid'] = viewModel.error == null;
          _testMessages['Mark As Paid'] = viewModel.error ?? 
              'Success: Marked invoice ${pendingInvoice.invoiceNumber} as paid';
        });
      } else {
        setState(() {
          _testResults['Mark As Paid'] = false;
          _testMessages['Mark As Paid'] = 'Error: No pending invoices available to test';
        });
      }
    } catch (e) {
      setState(() {
        _testResults['Mark As Paid'] = false;
        _testMessages['Mark As Paid'] = 'Error: $e';
      });
    }
  }

  Future<void> _testDownloadPdf() async {
    try {
      final viewModel = context.read<InvoiceViewModel>();
      if (viewModel.invoices.isNotEmpty) {
        final firstInvoice = viewModel.invoices.first;
        await viewModel.downloadPdf(firstInvoice.id);
        
        setState(() {
          _testResults['Download PDF'] = viewModel.error == null;
          _testMessages['Download PDF'] = viewModel.error ?? 
              'Success: Downloaded PDF for invoice ${firstInvoice.invoiceNumber}';
        });
      } else {
        setState(() {
          _testResults['Download PDF'] = false;
          _testMessages['Download PDF'] = 'Error: No invoices available to test';
        });
      }
    } catch (e) {
      setState(() {
        _testResults['Download PDF'] = false;
        _testMessages['Download PDF'] = 'Error: $e';
      });
    }
  }

  Future<void> _testDeleteInvoice() async {
    try {
      final viewModel = context.read<InvoiceViewModel>();
      if (viewModel.invoices.isNotEmpty) {
        final firstInvoice = viewModel.invoices.first;
        final success = await viewModel.deleteInvoice(firstInvoice.id);
        
        setState(() {
          _testResults['Delete Invoice'] = success;
          _testMessages['Delete Invoice'] = success ? 
              'Success: Deleted invoice ${firstInvoice.invoiceNumber}' : 
              'Error: Failed to delete invoice';
        });
      } else {
        setState(() {
          _testResults['Delete Invoice'] = false;
          _testMessages['Delete Invoice'] = 'Error: No invoices available to test';
        });
      }
    } catch (e) {
      setState(() {
        _testResults['Delete Invoice'] = false;
        _testMessages['Delete Invoice'] = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice API Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _runAllTests,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummaryCard(),
                const SizedBox(height: 16),
                ..._testResults.entries.map((entry) => _buildTestCard(entry.key, entry.value, _testMessages[entry.key] ?? '')),
              ],
            ),
    );
  }

  Widget _buildSummaryCard() {
    final totalTests = _testResults.length;
    final passedTests = _testResults.values.where((result) => result).length;
    final failedTests = totalTests - passedTests;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice API Test Results',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatusChip('Total: $totalTests', Colors.blue),
                const SizedBox(width: 8),
                _buildStatusChip('Passed: $passedTests', Colors.green),
                const SizedBox(width: 8),
                _buildStatusChip('Failed: $failedTests', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard(String testName, bool passed, String message) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          passed ? Icons.check_circle : Icons.error,
          color: passed ? Colors.green : Colors.red,
        ),
        title: Text(
          testName,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: passed ? Colors.green : Colors.red,
          ),
        ),
        subtitle: Text(
          message,
          style: TextStyle(
            color: passed ? AppColors.textSecondary : Colors.red[700],
          ),
        ),
        trailing: Icon(
          passed ? Icons.check : Icons.close,
          color: passed ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
} 