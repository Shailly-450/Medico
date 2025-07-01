import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StarRatingWidget extends StatelessWidget {
  final double rating;
  final int starCount;
  final double size;
  final Color? color;
  final bool allowHalfRating;
  final double spacing;

  const StarRatingWidget({
    Key? key,
    required this.rating,
    this.starCount = 5,
    this.size = 20,
    this.color,
    this.allowHalfRating = true,
    this.spacing = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        double starValue = index + 1.0;
        Icon icon;

        if (rating >= starValue) {
          // Full star
          icon = Icon(
            Icons.star,
            size: size,
            color: color ?? Colors.amber,
          );
        } else if (allowHalfRating && rating >= starValue - 0.5) {
          // Half star
          icon = Icon(
            Icons.star_half,
            size: size,
            color: color ?? Colors.amber,
          );
        } else {
          // Empty star
          icon = Icon(
            Icons.star_border,
            size: size,
            color: color ?? Colors.grey[400],
          );
        }

        return Padding(
          padding: EdgeInsets.only(right: index < starCount - 1 ? spacing : 0),
          child: icon,
        );
      }),
    );
  }
}

class InteractiveStarRating extends StatefulWidget {
  final double rating;
  final int starCount;
  final double size;
  final Color? color;
  final ValueChanged<double>? onRatingChanged;
  final double spacing;

  const InteractiveStarRating({
    Key? key,
    required this.rating,
    this.starCount = 5,
    this.size = 30,
    this.color,
    this.onRatingChanged,
    this.spacing = 4.0,
  }) : super(key: key);

  @override
  State<InteractiveStarRating> createState() => _InteractiveStarRatingState();
}

class _InteractiveStarRatingState extends State<InteractiveStarRating> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.starCount, (index) {
        return Padding(
          padding: EdgeInsets.only(
              right: index < widget.starCount - 1 ? widget.spacing : 0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _currentRating = index + 1.0;
              });
              widget.onRatingChanged?.call(_currentRating);
            },
            child: Icon(
              _currentRating > index ? Icons.star : Icons.star_border,
              size: widget.size,
              color: _currentRating > index
                  ? (widget.color ?? Colors.amber)
                  : Colors.grey[400],
            ),
          ),
        );
      }),
    );
  }
}

class RatingBreakdown extends StatelessWidget {
  final Map<String, int> ratingDistribution;
  final int totalReviews;

  const RatingBreakdown({
    Key? key,
    required this.ratingDistribution,
    required this.totalReviews,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 5; i >= 1; i--)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                SizedBox(
                  width: 12,
                  child: Text('$i', style: const TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                StarRatingWidget(rating: i.toDouble(), starCount: 1, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressIndicator(
                    value: totalReviews > 0
                        ? (ratingDistribution[i.toString()] ?? 0) / totalReviews
                        : 0,
                    backgroundColor: Colors.grey[300],
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 30,
                  child: Text(
                    '${ratingDistribution[i.toString()] ?? 0}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
