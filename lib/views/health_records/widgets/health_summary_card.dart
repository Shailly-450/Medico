import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'vital_signs_card.dart';
import '../../../models/health_record.dart';

class HealthSummaryCard extends StatelessWidget {
  final VitalSigns vitalSigns;
  final List<LabResult> labResults;

  const HealthSummaryCard({
    Key? key,
    required this.vitalSigns,
    required this.labResults,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Vital Signs Card
        VitalSignsCard(vitalSigns: vitalSigns),
        
        const SizedBox(height: 16),
        
        // Lab Results Summary
        if (labResults.isNotEmpty) ...[
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.science,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Recent Lab Results',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textBlack,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        '${labResults.length} tests',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...labResults.take(3).map((result) => _buildLabResultItem(context, result)),
                  if (labResults.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextButton(
                        onPressed: () {
                          // Navigate to full lab results
                        },
                        child: Text(
                          'View all ${labResults.length} results',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLabResultItem(BuildContext context, LabResult result) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              result.testName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textBlack,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              '${result.result} ${result.unit}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getStatusColor(result.status),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              result.status.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return Colors.green;
      case 'high':
      case 'low':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
} 