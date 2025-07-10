import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/consent.dart';
import '../../../viewmodels/consent_view_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConsentLogScreen extends StatefulWidget {
  const ConsentLogScreen({Key? key}) : super(key: key);

  @override
  State<ConsentLogScreen> createState() => _ConsentLogScreenState();
}

class _ConsentLogScreenState extends State<ConsentLogScreen> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();
  final List<String> _filterOptions = [
    'All',
    'Granted',
    'Revoked',
    'Expired',
    'Renewed',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchAndFilter(),
        Expanded(
          child: Consumer<ConsentViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final filteredLogs = _getFilteredLogs(viewModel);
              
              if (filteredLogs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No activity found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No consent activity matches your search criteria',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredLogs.length,
                itemBuilder: (context, index) {
                  final log = filteredLogs[index];
                  final consent = viewModel.consentItems
                      .firstWhere((item) => item.id == log.consentId);
                  
                  return _buildLogCard(log, consent);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search consent activity...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 12),
          // Filter Chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                final option = _filterOptions[index];
                final isSelected = _selectedFilter == option;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(option),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = option;
                      });
                    },
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : Colors.grey.shade300,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(ConsentLog log, ConsentItem consent) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildActionIcon(log.action),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        consent.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getActionDescription(log.action),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(log.newStatus),
              ],
            ),
            const SizedBox(height: 12),
            _buildLogDetails(log),
            if (log.reason != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        log.reason!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
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
    );
  }

  Widget _buildActionIcon(String action) {
    IconData icon;
    Color color;

    switch (action.toLowerCase()) {
      case 'granted':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'revoked':
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case 'expired':
        icon = Icons.warning;
        color = Colors.orange;
        break;
      case 'renewed':
        icon = Icons.refresh;
        color = Colors.blue;
        break;
      case 'denied':
        icon = Icons.block;
        color = Colors.red;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildStatusChip(ConsentStatus status) {
    Color color;
    String label;

    switch (status) {
      case ConsentStatus.granted:
        color = Colors.green;
        label = 'Granted';
        break;
      case ConsentStatus.denied:
        color = Colors.red;
        label = 'Denied';
        break;
      case ConsentStatus.pending:
        color = Colors.orange;
        label = 'Pending';
        break;
      case ConsentStatus.expired:
        color = Colors.red;
        label = 'Expired';
        break;
      case ConsentStatus.revoked:
        color = Colors.grey;
        label = 'Revoked';
        break;
      case ConsentStatus.notRequested:
        color = Colors.grey;
        label = 'Not Requested';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildLogDetails(ConsentLog log) {
    return Column(
      children: [
        _buildDetailRow('Performed by', log.performedBy ?? 'System'),
        _buildDetailRow('Time', timeago.format(log.timestamp)),
        if (log.ipAddress != null)
          _buildDetailRow('IP Address', log.ipAddress!),
        if (log.userAgent != null)
          _buildDetailRow('User Agent', log.userAgent!),
        _buildDetailRow('Previous Status', _getStatusText(log.previousStatus)),
        _buildDetailRow('New Status', _getStatusText(log.newStatus)),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<ConsentLog> _getFilteredLogs(ConsentViewModel viewModel) {
    var logs = viewModel.consentLogs;

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      logs = logs.where((log) {
        final consent = viewModel.consentItems
            .firstWhere((item) => item.id == log.consentId);
        return consent.title.toLowerCase().contains(searchTerm) ||
               log.action.toLowerCase().contains(searchTerm) ||
               (log.reason?.toLowerCase().contains(searchTerm) ?? false);
      }).toList();
    }

    // Apply action filter
    if (_selectedFilter != 'All') {
      logs = logs.where((log) {
        switch (_selectedFilter) {
          case 'Granted':
            return log.action.toLowerCase() == 'granted';
          case 'Revoked':
            return log.action.toLowerCase() == 'revoked';
          case 'Expired':
            return log.action.toLowerCase() == 'expired';
          case 'Renewed':
            return log.action.toLowerCase() == 'renewed';
          default:
            return true;
        }
      }).toList();
    }

    return logs;
  }

  String _getActionDescription(String action) {
    switch (action.toLowerCase()) {
      case 'granted':
        return 'Consent was granted by the user';
      case 'revoked':
        return 'Consent was revoked by the user';
      case 'expired':
        return 'Consent expired automatically';
      case 'renewed':
        return 'Consent was renewed automatically';
      case 'denied':
        return 'Consent was denied by the user';
      default:
        return 'Consent status was updated';
    }
  }

  String _getStatusText(ConsentStatus status) {
    switch (status) {
      case ConsentStatus.granted:
        return 'Granted';
      case ConsentStatus.denied:
        return 'Denied';
      case ConsentStatus.pending:
        return 'Pending';
      case ConsentStatus.expired:
        return 'Expired';
      case ConsentStatus.revoked:
        return 'Revoked';
      case ConsentStatus.notRequested:
        return 'Not Requested';
    }
  }
} 