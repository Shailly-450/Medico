import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class QuickSymptomButtons extends StatelessWidget {
  final Function(String) onSymptomSelected;

  const QuickSymptomButtons({
    Key? key,
    required this.onSymptomSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.medical_services,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Quick Symptom Check',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Select your symptoms to get started:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 16),
          _buildSymptomCategories(context),
        ],
      ),
    );
  }

  Widget _buildSymptomCategories(BuildContext context) {
    return Column(
      children: [
        _buildCategorySection(
          context,
          'Common Symptoms',
          [
            _SymptomButton(
              icon: Icons.psychology,
              label: 'Headache',
              color: Colors.red,
              onTap: () => onSymptomSelected('I have a headache'),
            ),
            _SymptomButton(
              icon: Icons.thermostat,
              label: 'Fever',
              color: Colors.orange,
              onTap: () => onSymptomSelected('I have a fever'),
            ),
            _SymptomButton(
              icon: Icons.sick,
              label: 'Cough',
              color: Colors.blue,
              onTap: () => onSymptomSelected('I have a cough'),
            ),
            _SymptomButton(
              icon: Icons.sentiment_very_dissatisfied,
              label: 'Nausea',
              color: Colors.green,
              onTap: () => onSymptomSelected('I feel nauseous'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCategorySection(
          context,
          'Pain & Discomfort',
          [
            _SymptomButton(
              icon: Icons.favorite,
              label: 'Chest Pain',
              color: Colors.red[700]!,
              onTap: () => onSymptomSelected('I have chest pain'),
            ),
            _SymptomButton(
              icon: Icons.local_pharmacy,
              label: 'Stomach Pain',
              color: Colors.teal,
              onTap: () => onSymptomSelected('I have stomach pain'),
            ),
            _SymptomButton(
              icon: Icons.accessibility,
              label: 'Joint Pain',
              color: Colors.purple,
              onTap: () => onSymptomSelected('I have joint pain'),
            ),
            _SymptomButton(
              icon: Icons.back_hand,
              label: 'Back Pain',
              color: Colors.indigo,
              onTap: () => onSymptomSelected('I have back pain'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCategorySection(
          context,
          'Other Symptoms',
          [
            _SymptomButton(
              icon: Icons.battery_0_bar,
              label: 'Fatigue',
              color: Colors.purple,
              onTap: () => onSymptomSelected('I feel fatigued'),
            ),
            _SymptomButton(
              icon: Icons.air,
              label: 'Breathing Issues',
              color: Colors.cyan,
              onTap: () => onSymptomSelected('I have difficulty breathing'),
            ),
            _SymptomButton(
              icon: Icons.visibility,
              label: 'Vision Problems',
              color: Colors.amber,
              onTap: () => onSymptomSelected('I have vision problems'),
            ),
            _SymptomButton(
              icon: Icons.water_drop,
              label: 'Dizziness',
              color: Colors.pink,
              onTap: () => onSymptomSelected('I feel dizzy'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    String title,
    List<_SymptomButton> symptoms,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 3.2,
          ),
          itemCount: symptoms.length,
          itemBuilder: (context, index) => symptoms[index],
        ),
      ],
    );
  }
}

class _SymptomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SymptomButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 18,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
