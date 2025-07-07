import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class IncomingCallOverlay extends StatelessWidget {
  final String doctorName;
  final String doctorSpecialty;
  final String? doctorImage;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const IncomingCallOverlay({
    Key? key,
    required this.doctorName,
    required this.doctorSpecialty,
    this.doctorImage,
    required this.onAccept,
    required this.onDecline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Doctor avatar
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: doctorImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.network(
                        doctorImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.medical_services,
                            color: Colors.white,
                            size: 48,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.medical_services,
                      color: Colors.white,
                      size: 48,
                    ),
            ),

            const SizedBox(height: 24),

            Text(
              doctorName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              doctorSpecialty,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 32),

            Text(
              'Incoming Video Call',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 40),

            // Call action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Decline button
                GestureDetector(
                  onTap: onDecline,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.call_end,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),

                const SizedBox(width: 40),

                // Accept button
                GestureDetector(
                  onTap: onAccept,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.call,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
