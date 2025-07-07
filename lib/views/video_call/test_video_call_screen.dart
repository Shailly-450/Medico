import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'video_call_screen.dart';

class TestVideoCallScreen extends StatelessWidget {
  const TestVideoCallScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Video Calls'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Video Call Demo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Test the video call interface with different scenarios',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            // Test scenarios
            _buildTestCard(
              context,
              'Dr. Sarah Johnson',
              'Cardiologist',
              'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400',
              'Test with a cardiologist',
            ),

            const SizedBox(height: 16),

            _buildTestCard(
              context,
              'Dr. Michael Chen',
              'Dermatologist',
              'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400',
              'Test with a dermatologist',
            ),

            const SizedBox(height: 16),

            _buildTestCard(
              context,
              'Dr. Emily Rodriguez',
              'Pediatrician',
              null,
              'Test without doctor image',
            ),

            const SizedBox(height: 16),

            _buildTestCard(
              context,
              'Dr. James Wilson',
              'Neurologist',
              'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400',
              'Test with a neurologist',
            ),

            const Spacer(),

            // Features list
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Video Call Features:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                      '📹 Incoming call overlay with accept/decline'),
                  _buildFeatureItem(
                      '🎥 Main video view and local camera preview'),
                  _buildFeatureItem('🎤 Mute/unmute microphone'),
                  _buildFeatureItem('📷 Turn camera on/off'),
                  _buildFeatureItem('🔊 Speaker/earpiece toggle'),
                  _buildFeatureItem('⏺️ Recording functionality'),
                  _buildFeatureItem('🖥️ Screen sharing option'),
                  _buildFeatureItem('💬 In-call chat panel'),
                  _buildFeatureItem('📞 End call with confirmation'),
                  _buildFeatureItem('⚙️ More options menu'),
                  _buildFeatureItem('🖥️ Screen sharing with multiple options'),
                  _buildFeatureItem('📱 Full-screen content viewer'),
                  _buildFeatureItem('📸 Photo gallery sharing'),
                  _buildFeatureItem('📄 Document sharing'),
                  _buildFeatureItem('📊 Health records sharing'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard(
    BuildContext context,
    String doctorName,
    String specialty,
    String? imageUrl,
    String description,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoCallScreen(
                doctorName: doctorName,
                doctorSpecialty: specialty,
                doctorImage: imageUrl,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Doctor avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.medical_services,
                              color: Colors.white,
                              size: 24,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.medical_services,
                        color: Colors.white,
                        size: 24,
                      ),
              ),

              const SizedBox(width: 16),

              // Doctor info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      specialty,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),

              // Video call icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.video_call,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
