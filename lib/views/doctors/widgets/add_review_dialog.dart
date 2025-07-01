import 'package:flutter/material.dart';
import '../../../models/doctor_review.dart';
import '../../../core/theme/app_colors.dart';

class AddReviewDialog extends StatefulWidget {
  final String doctorId;
  final Function(DoctorReview) onReviewAdded;

  const AddReviewDialog({
    Key? key,
    required this.doctorId,
    required this.onReviewAdded,
  }) : super(key: key);

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  double _overallRating = 5.0;
  String _consultationType = 'In-person';
  String? _treatmentOutcome;
  bool _wouldRecommend = true;

  // Category ratings
  double _bedsideMannerRating = 5.0;
  double _expertiseRating = 5.0;
  double _communicationRating = 5.0;
  double _treatmentEffectivenessRating = 5.0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.rate_review,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Write a Review',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overall Rating
                      Text(
                        'Overall Rating',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _overallRating = index + 1.0;
                              });
                            },
                            child: Icon(
                              index < _overallRating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 32,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),

                      // Consultation Type
                      Text(
                        'Consultation Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _consultationType,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        items: ['In-person', 'Online', 'Emergency']
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _consultationType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Comment
                      Text(
                        'Your Review',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _commentController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Share your experience with this doctor...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please write a review';
                          }
                          if (value.trim().length < 10) {
                            return 'Review must be at least 10 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Treatment Outcome
                      Text(
                        'Treatment Outcome (Optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        onChanged: (value) {
                          setState(() {
                            _treatmentOutcome = value.isEmpty ? null : value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'e.g., Improved condition, No change, etc.',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Would Recommend
                      Row(
                        children: [
                          Checkbox(
                            value: _wouldRecommend,
                            onChanged: (value) {
                              setState(() {
                                _wouldRecommend = value!;
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                          const Text(
                            'I would recommend this doctor',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Category Ratings
                      Text(
                        'Detailed Ratings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      _buildCategoryRating(
                          'Bedside Manner', _bedsideMannerRating, (value) {
                        setState(() {
                          _bedsideMannerRating = value;
                        });
                      }),
                      _buildCategoryRating('Expertise', _expertiseRating,
                          (value) {
                        setState(() {
                          _expertiseRating = value;
                        });
                      }),
                      _buildCategoryRating(
                          'Communication', _communicationRating, (value) {
                        setState(() {
                          _communicationRating = value;
                        });
                      }),
                      _buildCategoryRating('Treatment Effectiveness',
                          _treatmentEffectivenessRating, (value) {
                        setState(() {
                          _treatmentEffectivenessRating = value;
                        });
                      }),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Submit Review'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRating(
      String category, double rating, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              category,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            child: Slider(
              value: rating,
              min: 1.0,
              max: 5.0,
              divisions: 4,
              activeColor: AppColors.primary,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 30,
            child: Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitReview() {
    if (_formKey.currentState!.validate()) {
      final review = DoctorReview(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        doctorId: widget.doctorId,
        userId: 'current_user_id', // In a real app, get from auth
        userName: 'Current User', // In a real app, get from auth
        rating: _overallRating,
        comment: _commentController.text.trim(),
        timestamp: DateTime.now(),
        isVerified: false,
        consultationType: _consultationType,
        treatmentOutcome: _treatmentOutcome,
        wouldRecommend: _wouldRecommend,
        categoryRatings: {
          'Bedside Manner': _bedsideMannerRating,
          'Expertise': _expertiseRating,
          'Communication': _communicationRating,
          'Treatment Effectiveness': _treatmentEffectivenessRating,
        },
      );

      widget.onReviewAdded(review);
    }
  }
}
