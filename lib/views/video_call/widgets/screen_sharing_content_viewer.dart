import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ScreenSharingContentViewer extends StatelessWidget {
  final String contentType;
  final String? contentTitle;
  final List<String>? contentItems;
  final VoidCallback onClose;

  const ScreenSharingContentViewer({
    Key? key,
    required this.contentType,
    this.contentTitle,
    this.contentItems,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Stack(
        children: [
          // Content area
          _buildContentArea(),

          // Top controls
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _getContentTypeTitle(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (contentTitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            contentTitle!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 60),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.screen_share, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'SHARING',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(
                    icon: Icons.arrow_back,
                    label: 'Previous',
                    onTap: () {
                      // TODO: Navigate to previous item
                    },
                  ),
                  const SizedBox(width: 20),
                  _buildControlButton(
                    icon: Icons.zoom_in,
                    label: 'Zoom',
                    onTap: () {
                      // TODO: Toggle zoom
                    },
                  ),
                  const SizedBox(width: 20),
                  _buildControlButton(
                    icon: Icons.arrow_forward,
                    label: 'Next',
                    onTap: () {
                      // TODO: Navigate to next item
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea() {
    switch (contentType) {
      case 'entire_screen':
        return _buildEntireScreenView();
      case 'photo_gallery':
        return _buildPhotoGalleryView();
      case 'documents':
        return _buildDocumentsView();
      case 'camera':
        return _buildCameraView();
      case 'health_records':
        return _buildHealthRecordsView();
      default:
        return _buildDefaultView();
    }
  }

  Widget _buildEntireScreenView() {
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.screen_share,
              size: 64,
              color: Colors.white54,
            ),
            SizedBox(height: 16),
            Text(
              'Entire Screen Sharing',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your complete screen is being shared',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGalleryView() {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 12, // Mock photos
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.photo,
                      color: Colors.white54,
                      size: 32,
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

  Widget _buildDocumentsView() {
    return Container(
      color: Colors.grey[50],
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // Mock documents
        itemBuilder: (context, index) {
          final documents = [
            'Medical Report - Blood Test.pdf',
            'Prescription - Dr. Smith.pdf',
            'Insurance Policy.pdf',
            'Lab Results - X-Ray.pdf',
            'Medical Certificate.pdf',
          ];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.description,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              title: Text(documents[index]),
              subtitle: Text('PDF Document • ${(index + 1) * 2.5} MB'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCameraView() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: 64,
              color: Colors.white54,
            ),
            SizedBox(height: 16),
            Text(
              'Live Camera Feed',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Sharing live camera with doctor',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthRecordsView() {
    return Container(
      color: Colors.grey[50],
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6, // Mock health records
        itemBuilder: (context, index) {
          final records = [
            {
              'title': 'Blood Pressure History',
              'date': '2024-01-15',
              'icon': Icons.favorite
            },
            {
              'title': 'Blood Sugar Levels',
              'date': '2024-01-10',
              'icon': Icons.water_drop
            },
            {
              'title': 'Weight Tracking',
              'date': '2024-01-08',
              'icon': Icons.monitor_weight
            },
            {
              'title': 'Medication History',
              'date': '2024-01-05',
              'icon': Icons.medication
            },
            {
              'title': 'Allergy Information',
              'date': '2024-01-03',
              'icon': Icons.warning
            },
            {
              'title': 'Vaccination Records',
              'date': '2023-12-28',
              'icon': Icons.vaccines
            },
          ];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  records[index]['icon'] as IconData,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              title: Text(records[index]['title'] as String),
              subtitle: Text('Last updated: ${records[index]['date']}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDefaultView() {
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.screen_share,
              size: 64,
              color: Colors.white54,
            ),
            SizedBox(height: 16),
            Text(
              'Screen Sharing Active',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getContentTypeTitle() {
    switch (contentType) {
      case 'entire_screen':
        return 'Entire Screen';
      case 'photo_gallery':
        return 'Photo Gallery';
      case 'documents':
        return 'Documents';
      case 'camera':
        return 'Live Camera';
      case 'health_records':
        return 'Health Records';
      default:
        return 'Screen Sharing';
    }
  }
}
