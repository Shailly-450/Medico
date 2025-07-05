import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/offer_package.dart';

class OfferCard extends StatelessWidget {
  final OfferPackage offer;
  final VoidCallback? onTap;

  const OfferCard({
    Key? key,
    required this.offer,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 270,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image section
              Container(
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(offer.imageUrl),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      // Handle image load error
                    },
                  ),
                ),
                child: Stack(
                  children: [
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                    // Discount badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${offer.discountPercentage}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        offer.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),

                      // Description
                      Expanded(
                        child: Text(
                          offer.description,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Price section
                      Row(
                        children: [
                          Text(
                            '₹${offer.discountedPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '₹${offer.originalPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Services
                      Wrap(
                        spacing: 3,
                        runSpacing: 3,
                        children: offer.includedServices.take(2).map((service) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              service,
                              style: TextStyle(
                                fontSize: 9,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),

                      // Book now button
                      SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Book Now',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
