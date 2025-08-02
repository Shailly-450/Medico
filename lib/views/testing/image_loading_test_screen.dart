import 'package:flutter/material.dart';
import '../../core/widgets/profile_photo_widget.dart';
import '../../core/services/cached_image_service.dart';
import '../../core/theme/app_colors.dart';

class ImageLoadingTestScreen extends StatefulWidget {
  const ImageLoadingTestScreen({Key? key}) : super(key: key);

  @override
  State<ImageLoadingTestScreen> createState() => _ImageLoadingTestScreenState();
}

class _ImageLoadingTestScreenState extends State<ImageLoadingTestScreen> {
  final List<String> testUrls = [
    'https://drive.google.com/uc?id=1lXKbG0wPKtlMeugzVM2NKKQ2NmqgQS54&export=download',
    'https://drive.google.com/file/d/1lXKbG0wPKtlMeugzVM2NKKQ2NmqgQS54/view',
    'https://via.placeholder.com/150/007AFF/FFFFFF?text=Test',
    'https://picsum.photos/200/200',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Loading Test'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              CachedImageService.clearCache();
              setState(() {});
            },
            tooltip: 'Clear Cache',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cache Statistics',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        final stats = CachedImageService.getCacheStats();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cached URLs: ${stats['cachedUrls']}'),
                            Text('Failed URLs: ${stats['failedUrls']}'),
                            Text('Total URLs: ${stats['totalUrls']}'),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Test Images',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...testUrls.map((url) => _buildTestImage(url)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTestImage(String url) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'URL: $url',
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ProfilePhotoWidget(
                  imageUrl: url,
                  name: 'Test User',
                  size: 80,
                  showEditIcon: false,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test User',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'This is a test image to verify Google Drive URL loading',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
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