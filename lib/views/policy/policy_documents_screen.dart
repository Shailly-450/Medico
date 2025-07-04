import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../core/theme/app_colors.dart';

class PolicyDocumentsScreen extends StatefulWidget {
  const PolicyDocumentsScreen({Key? key}) : super(key: key);

  @override
  State<PolicyDocumentsScreen> createState() => _PolicyDocumentsScreenState();
}

class _PolicyDocumentsScreenState extends State<PolicyDocumentsScreen> {
  final List<PolicyDocument> _documents = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingDocuments();
  }

  void _loadExistingDocuments() {
    _documents.addAll([
      PolicyDocument(
        name: 'Insurance Policy.pdf',
        type: DocumentType.insurance,
        uploadDate: DateTime.now().subtract(const Duration(days: 5)),
        status: DocumentStatus.approved,
        fileSize: '2.5 MB',
      ),
      PolicyDocument(
        name: 'Medical Certificate.pdf',
        type: DocumentType.medical,
        uploadDate: DateTime.now().subtract(const Duration(days: 3)),
        status: DocumentStatus.pending,
        fileSize: '1.8 MB',
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Policy Documents'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _showUploadDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildUploadSection(),
          Expanded(child: _buildDocumentsList()),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.accent.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.cloud_upload_outlined,
                size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          const Text(
            'Upload Policy Documents',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your insurance policies and medical certificates',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showUploadDialog,
              icon: const Icon(Icons.add),
              label: const Text('Upload Document'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _testSimpleUpload(),
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Test Simple'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _uploadDocument(
                      DocumentType.medical, 'Test Medical', 'camera'),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Test Camera'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _documents.length,
      itemBuilder: (context, index) => _buildDocumentCard(_documents[index]),
    );
  }

  Widget _buildDocumentCard(PolicyDocument document) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getDocumentTypeColor(document.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_getDocumentTypeIcon(document.type),
              color: _getDocumentTypeColor(document.type), size: 24),
        ),
        title: Text(document.name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${document.fileSize} • ${_formatDate(document.uploadDate)}',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(document.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _getStatusColor(document.status).withOpacity(0.3)),
              ),
              child: Text(
                _getStatusText(document.status),
                style: TextStyle(
                    color: _getStatusColor(document.status),
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleDocumentAction(value, document),
          itemBuilder: (context) => [
            const PopupMenuItem(
                value: 'view',
                child: Row(children: [
                  Icon(Icons.visibility, size: 18),
                  SizedBox(width: 8),
                  Text('View')
                ])),
            const PopupMenuItem(
                value: 'download',
                child: Row(children: [
                  Icon(Icons.download, size: 18),
                  SizedBox(width: 8),
                  Text('Download')
                ])),
            const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red))
                ])),
          ],
        ),
      ),
    );
  }

  void _showUploadDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _buildUploadDialog(),
    );
  }

  Widget _buildUploadDialog() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upload Document',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 24),
                ),
              ],
            ),
          ),

          // Upload options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Folder option
                _buildUploadOption(
                  icon: Icons.folder_open,
                  title: 'Choose from Files',
                  subtitle: 'Select PDF, images, or documents from your device',
                  color: Colors.blue,
                  onTap: () => _handleUploadOption('file'),
                ),

                const SizedBox(height: 16),

                // Camera option
                _buildUploadOption(
                  icon: Icons.camera_alt,
                  title: 'Take Photo',
                  subtitle: 'Use camera to capture document',
                  color: Colors.green,
                  onTap: () => _handleUploadOption('camera'),
                ),

                const SizedBox(height: 16),

                // Gallery option
                _buildUploadOption(
                  icon: Icons.photo_library,
                  title: 'Choose from Gallery',
                  subtitle: 'Select from your photo gallery',
                  color: Colors.orange,
                  onTap: () => _handleUploadOption('gallery'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleUploadOption(String option) async {
    Navigator.pop(context);

    // Show document type selection dialog
    final selectedType = await _showDocumentTypeDialog();
    if (selectedType == null) return;

    // Show file name input dialog
    final fileName = await _showFileNameDialog();
    if (fileName == null) return;

    // Proceed with upload
    await _uploadDocument(selectedType, fileName, option);
  }

  Future<DocumentType?> _showDocumentTypeDialog() async {
    return showDialog<DocumentType>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Document Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: DocumentType.values
              .map((type) => ListTile(
                    leading: Icon(_getDocumentTypeIcon(type),
                        color: _getDocumentTypeColor(type)),
                    title: Text(_getDocumentTypeText(type)),
                    onTap: () => Navigator.pop(context, type),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Future<String?> _showFileNameDialog() async {
    String fileName = '';
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Document Name'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter document name (optional)',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => fileName = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, fileName),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadDocument(DocumentType type, String fileName,
      [String? uploadOption]) async {
    print('Starting upload process...');
    setState(() => _isUploading = true);

    try {
      print('Requesting permissions...');
      // Request permissions for different Android versions
      List<Permission> permissions = [Permission.camera];

      // Add storage permissions based on Android version
      if (await Permission.storage.status == PermissionStatus.denied) {
        permissions.add(Permission.storage);
      }
      if (await Permission.photos.status == PermissionStatus.denied) {
        permissions.add(Permission.photos);
      }
      if (await Permission.videos.status == PermissionStatus.denied) {
        permissions.add(Permission.videos);
      }
      if (await Permission.audio.status == PermissionStatus.denied) {
        permissions.add(Permission.audio);
      }

      Map<Permission, PermissionStatus> statuses = await permissions.request();

      print('Permission status: $statuses');

      // Check if we have necessary permissions
      bool hasStoragePermission =
          statuses[Permission.storage] == PermissionStatus.granted ||
              statuses[Permission.photos] == PermissionStatus.granted ||
              statuses[Permission.videos] == PermissionStatus.granted;

      if (!hasStoragePermission) {
        print('Storage permission denied');
        // Show a more helpful error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please grant storage permission to upload files'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        setState(() => _isUploading = false);
        return;
      }

      print('Processing upload option: $uploadOption');

      File? selectedFile;

      // Use the upload option parameter if provided, otherwise show dialog
      String? result = uploadOption;
      if (result == null) {
        // Show file picker options with better UI
        result = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Select File Source'),
            content: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    child: ListTile(
                      leading:
                          const Icon(Icons.folder_open, color: Colors.blue),
                      title: const Text('Choose from Files'),
                      subtitle: const Text('Select PDF, images, or documents'),
                      onTap: () => Navigator.pop(context, 'file'),
                      tileColor: Colors.blue.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    child: ListTile(
                      leading:
                          const Icon(Icons.camera_alt, color: Colors.green),
                      title: const Text('Take Photo'),
                      subtitle: const Text('Use camera to capture document'),
                      onTap: () => Navigator.pop(context, 'camera'),
                      tileColor: Colors.green.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    child: ListTile(
                      leading:
                          const Icon(Icons.photo_library, color: Colors.orange),
                      title: const Text('Choose from Gallery'),
                      subtitle: const Text('Select from your photos'),
                      onTap: () => Navigator.pop(context, 'gallery'),
                      tileColor: Colors.orange.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() => _isUploading = false);
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      }

      switch (result) {
        case 'file':
          selectedFile = await _pickFile();
          break;
        case 'camera':
          selectedFile = await _takePhoto();
          break;
        case 'gallery':
          selectedFile = await _pickImage();
          break;
        default:
          setState(() => _isUploading = false);
          return;
      }

      if (selectedFile != null) {
        final fileSize = await selectedFile.length();
        final fileSizeMB = fileSize / (1024 * 1024);

        // Check file size limit (10MB)
        if (fileSizeMB > 10) {
          setState(() => _isUploading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File size must be less than 10MB'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final newDocument = PolicyDocument(
          name: fileName.isNotEmpty
              ? '$fileName${_getFileExtension(selectedFile.path)}'
              : selectedFile.path.split('/').last,
          type: type,
          uploadDate: DateTime.now(),
          status: DocumentStatus.pending,
          fileSize: '${fileSizeMB.toStringAsFixed(1)} MB',
        );

        setState(() {
          _documents.add(newDocument);
          _isUploading = false;
        });

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Document uploaded successfully'),
            backgroundColor: Colors.green));
      } else {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('No file selected'), backgroundColor: Colors.orange));
      }
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error uploading file: ${e.toString()}'),
          backgroundColor: Colors.red));
    }
  }

  Future<File?> _pickFile() async {
    print('Picking file...');
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        allowMultiple: false,
        withData: false,
        withReadStream: false,
        lockParentWindow: true,
      );

      print('File picker result: $result');
      if (result != null &&
          result.files.isNotEmpty &&
          result.files.single.path != null) {
        print('Selected file path: ${result.files.single.path}');
        final file = File(result.files.single.path!);
        if (await file.exists()) {
          print('File exists, returning: $file');
          return file;
        } else {
          print('File does not exist: $file');
        }
      } else {
        print('No file selected or result is null');
      }
      return null;
    } catch (e) {
      print('Error picking file: $e');
      return null;
    }
  }

  Future<File?> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);

      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e) {
      print('Error taking photo: $e');
      return null;
    }
  }

  Future<File?> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  String _getFileExtension(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    return '.$extension';
  }

  Future<void> _testSimpleUpload() async {
    print('Testing simple upload...');
    try {
      // Try to pick a file without complex permission handling
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        print('File selected: ${result.files.first.name}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File selected: ${result.files.first.name}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print('No file selected');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No file selected'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Error in simple upload: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleDocumentAction(String action, PolicyDocument document) {
    switch (action) {
      case 'view':
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Opening ${document.name}'),
            backgroundColor: AppColors.primary));
        break;
      case 'download':
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Downloading ${document.name}'),
            backgroundColor: AppColors.primary));
        break;
      case 'delete':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Document'),
            content: Text('Are you sure you want to delete ${document.name}?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  setState(() => _documents.remove(document));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Document deleted successfully'),
                      backgroundColor: Colors.green));
                },
                child:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        break;
    }
  }

  Color _getDocumentTypeColor(DocumentType type) {
    switch (type) {
      case DocumentType.insurance:
        return Colors.blue;
      case DocumentType.medical:
        return Colors.green;
      case DocumentType.identification:
        return Colors.orange;
      case DocumentType.other:
        return Colors.grey;
    }
  }

  IconData _getDocumentTypeIcon(DocumentType type) {
    switch (type) {
      case DocumentType.insurance:
        return Icons.security;
      case DocumentType.medical:
        return Icons.medical_information;
      case DocumentType.identification:
        return Icons.badge;
      case DocumentType.other:
        return Icons.description;
    }
  }

  String _getDocumentTypeText(DocumentType type) {
    switch (type) {
      case DocumentType.insurance:
        return 'Insurance Policy';
      case DocumentType.medical:
        return 'Medical Certificate';
      case DocumentType.identification:
        return 'ID Card';
      case DocumentType.other:
        return 'Other Document';
    }
  }

  Color _getStatusColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.approved:
        return Colors.green;
      case DocumentStatus.pending:
        return Colors.orange;
      case DocumentStatus.rejected:
        return Colors.red;
    }
  }

  String _getStatusText(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.approved:
        return 'Approved';
      case DocumentStatus.pending:
        return 'Pending Review';
      case DocumentStatus.rejected:
        return 'Rejected';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

enum DocumentType { insurance, medical, identification, other }

enum DocumentStatus { approved, pending, rejected }

class PolicyDocument {
  final String name;
  final DocumentType type;
  final DateTime uploadDate;
  final DocumentStatus status;
  final String fileSize;

  PolicyDocument({
    required this.name,
    required this.type,
    required this.uploadDate,
    required this.status,
    required this.fileSize,
  });
}
