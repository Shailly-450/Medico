import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../theme/app_colors.dart';
import '../services/google_drive_service.dart';
import '../services/cached_image_service.dart';
import '../services/google_drive_image_loader.dart';

class ProfilePhotoWidget extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final VoidCallback? onTap;
  final bool showEditIcon;
  final bool showBorder;

  const ProfilePhotoWidget({
    Key? key,
    this.imageUrl,
    this.name,
    this.size = 100,
    this.onTap,
    this.showEditIcon = false,
    this.showBorder = true,
  }) : super(key: key);

  String getInitials() {
    if (name == null || name!.trim().isEmpty) return '';
    final parts = name!.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: showBorder ? Border.all(color: Colors.grey.shade300, width: 2) : null,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? _buildImageWidget()
                  : _buildPlaceholder(),
            ),
          ),
          if (showEditIcon && onTap != null)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageWidget() {
    // Handle local file paths
    if (imageUrl!.startsWith('file://')) {
      final filePath = imageUrl!.substring(7); // Remove 'file://' prefix
      debugPrint('📁 Loading local file: $filePath');
      return Image.file(
        File(filePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ Failed to load local file: $error');
          return _buildPlaceholder();
        },
      );
    }
    
    // Handle Google Drive URLs and other network images
    debugPrint('🌐 Loading network image: $imageUrl');
    return _CachedNetworkImageWidget(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      placeholder: _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.15),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              getInitials(),
              style: TextStyle(
                fontSize: size * 0.4,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            if (imageUrl != null && imageUrl!.contains('drive.google.com'))
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  children: [
                    Icon(
                      Icons.lock,
                      size: size * 0.15,
                      color: AppColors.primary.withOpacity(0.6),
                    ),
                    if (size > 80) // Only show text for larger avatars
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Private',
                          style: TextStyle(
                            fontSize: size * 0.08,
                            color: AppColors.primary.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
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
}

class _CachedNetworkImageWidget extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget placeholder;

  const _CachedNetworkImageWidget({
    required this.imageUrl,
    required this.fit,
    required this.placeholder,
  });

  @override
  State<_CachedNetworkImageWidget> createState() => _CachedNetworkImageWidgetState();
}

class _CachedNetworkImageWidgetState extends State<_CachedNetworkImageWidget> {
  String? _workingUrl;
  bool _isLoading = true;
  bool _hasError = false;
  bool _useCustomLoader = false;

  @override
  void initState() {
    super.initState();
    _findWorkingUrl();
  }

  Future<void> _findWorkingUrl() async {
    try {
      debugPrint('🔍 Finding working URL for: ${widget.imageUrl}');
      
      // Try authenticated URL first, then fallback to regular method
      String? workingUrl;
      if (widget.imageUrl.contains('drive.google.com')) {
        workingUrl = await CachedImageService.getWorkingUrlWithAuth(widget.imageUrl);
      } else {
        workingUrl = await CachedImageService.getWorkingUrl(widget.imageUrl);
      }
      
      if (mounted) {
        setState(() {
          _workingUrl = workingUrl;
          _isLoading = false;
          _hasError = workingUrl == null;
        });
      }
    } catch (e) {
      debugPrint('❌ Error finding working URL: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (_hasError || _workingUrl == null) {
      return widget.placeholder;
    }

    // For Google Drive URLs, try custom loader first
    if (_workingUrl!.contains('drive.google.com') && !_useCustomLoader) {
      return _GoogleDriveImageWidget(
        imageUrl: _workingUrl!,
        fit: widget.fit,
        placeholder: widget.placeholder,
        onFallback: () {
          setState(() {
            _useCustomLoader = true;
          });
        },
      );
    }

    // Standard network image loading
    return Image.network(
      _workingUrl!,
      fit: widget.fit,
      headers: GoogleDriveService.getHeaders(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ Failed to load image from working URL $_workingUrl: $error');
        
        // If this is a Google Drive URL that failed, try to clear cache and retry once
        if (_workingUrl!.contains('drive.google.com') && !_hasError) {
          debugPrint('🔄 Google Drive URL failed, clearing cache and retrying...');
          CachedImageService.clearCache();
          _hasError = true;
          _findWorkingUrl();
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }
        
        return widget.placeholder;
      },
    );
  }
}

class _GoogleDriveImageWidget extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget placeholder;
  final VoidCallback onFallback;

  const _GoogleDriveImageWidget({
    required this.imageUrl,
    required this.fit,
    required this.placeholder,
    required this.onFallback,
  });

  @override
  State<_GoogleDriveImageWidget> createState() => _GoogleDriveImageWidgetState();
}

class _GoogleDriveImageWidgetState extends State<_GoogleDriveImageWidget> {
  bool _isLoading = true;
  bool _hasError = false;
  Image? _image;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      debugPrint('🔄 Loading Google Drive image with custom loader: ${widget.imageUrl}');
      
      // Try authenticated loading first
      final bytes = await GoogleDriveImageLoader.loadImageWithAuth(widget.imageUrl);
      
      if (mounted) {
        if (bytes != null) {
          final image = GoogleDriveImageLoader.createImageFromBytes(bytes);
          setState(() {
            _image = image;
            _isLoading = false;
            _hasError = image == null;
          });
        } else {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading Google Drive image: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (_hasError || _image == null) {
      // Try fallback to standard network image
      widget.onFallback();
      return widget.placeholder;
    }

    return _image!;
  }
} 