import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/health_record.dart';

class VitalSignsCard extends StatelessWidget {
  final VitalSigns vitalSigns;

  const VitalSignsCard({
    Key? key,
    required this.vitalSigns,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  Icons.favorite,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Latest Vital Signs',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                ),
                const Spacer(),
                Text(
                  _formatDate(vitalSigns.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildVitalSignItem(
                    context,
                    'Blood Pressure',
                    '${vitalSigns.bloodPressureSystolic}/${vitalSigns.bloodPressureDiastolic}',
                    'mmHg',
                    _getBloodPressureStatus(vitalSigns.bloodPressureSystolic, vitalSigns.bloodPressureDiastolic),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVitalSignItem(
                    context,
                    'Heart Rate',
                    '${vitalSigns.heartRate}',
                    'bpm',
                    _getHeartRateStatus(vitalSigns.heartRate),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildVitalSignItem(
                    context,
                    'Temperature',
                    '${vitalSigns.temperature}',
                    '°F',
                    _getTemperatureStatus(vitalSigns.temperature),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVitalSignItem(
                    context,
                    'O₂ Saturation',
                    '${vitalSigns.oxygenSaturation}',
                    '%',
                    _getOxygenStatus(vitalSigns.oxygenSaturation),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildVitalSignItem(
                    context,
                    'Weight',
                    '${vitalSigns.weight}',
                    'kg',
                    'normal',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildVitalSignItem(
                    context,
                    'Height',
                    '${vitalSigns.height}',
                    'cm',
                    'normal',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalSignItem(
    BuildContext context,
    String label,
    String value,
    String unit,
    String status,
  ) {
    Color statusColor = _getStatusColor(status);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status.toUpperCase(),
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

  String _getBloodPressureStatus(double systolic, double diastolic) {
    if (systolic < 120 && diastolic < 80) return 'normal';
    if (systolic >= 120 && systolic < 130 && diastolic < 80) return 'elevated';
    if (systolic >= 130 || diastolic >= 80) return 'high';
    return 'normal';
  }

  String _getHeartRateStatus(int heartRate) {
    if (heartRate >= 60 && heartRate <= 100) return 'normal';
    if (heartRate < 60) return 'low';
    return 'high';
  }

  String _getTemperatureStatus(double temperature) {
    if (temperature >= 97.0 && temperature <= 99.0) return 'normal';
    if (temperature > 99.0) return 'high';
    return 'low';
  }

  String _getOxygenStatus(int oxygen) {
    if (oxygen >= 95) return 'normal';
    if (oxygen >= 90) return 'low';
    return 'critical';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return Colors.green;
      case 'elevated':
      case 'low':
      case 'high':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
} 