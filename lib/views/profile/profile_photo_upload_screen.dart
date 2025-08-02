import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/widgets/profile_photo_widget.dart';
import '../../viewmodels/profile_view_model.dart';
import 'package:provider/provider.dart';

class ProfilePhotoUploadScreen extends StatefulWidget {
  const ProfilePhotoUploadScreen({Key? key}) : super(key: key);

  @override
  _ProfilePhotoUploadScreenState createState() => _ProfilePhotoUploadScreenState();
}

class _ProfilePhotoUploadScreenState extends State<ProfilePhotoUploadScreen> {
  File? _selectedImage;
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _uploadProfilePhoto() async {
    if (_selectedImage == null) {
      _showErrorSnackBar('Please select an image first');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
      final result = await profileVM.updateProfileAvatar(_selectedImage!.path);
      
      if (result['success'] == true) {
        _showSuccessSnackBar('Profile photo updated successfully!');
        Navigator.pop(context, result['webContentLink']);
      } else {
        _showErrorSnackBar('Failed to upload profile photo: ${result['message']}');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to upload profile photo: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile Photo'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Image preview
            ProfilePhotoWidget(
              imageUrl: _selectedImage?.path,
              size: 200,
              showEditIcon: false,
            ),
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Upload button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedImage != null && !_isUploading
                    ? _uploadProfilePhoto
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isUploading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          const Text('Uploading...'),
                        ],
                      )
                    : const Text('Upload Profile Photo'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tips for best results:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('• Use a clear, well-lit photo'),
                  const Text('• Make sure your face is clearly visible'),
                  const Text('• Square photos work best'),
                  const Text('• File size should be under 5MB'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 