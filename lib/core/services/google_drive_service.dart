// TODO Implement this library.
import 'dart:convert';
import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart'; // For downloading files locally
import 'package:googleapis/drive/v3.dart' as drive;
class GoogleDriveService {
  static drive.DriveApi? _driveApi;
  static bool _isInitialized = false;

  /// Initialize Google Drive API with service account credentials
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final credentialsJson = await File('assets/credentials.json').readAsString(); // ✅ Load from secure location
      final credentials = ServiceAccountCredentials.fromJson(
        json.decode(credentialsJson),
      );

      final client = await clientViaServiceAccount(
        credentials,
        [drive.DriveApi.driveScope],
      );

      _driveApi = drive.DriveApi(client);
      _isInitialized = true;

      print('✅ Google Drive API initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize Google Drive API: $e');
      rethrow;
    }
  }

  /// Upload a file to Google Drive
  static Future<String?> uploadFile({
    required File file,
    required String fileName,
    String? folderId,
    String? description,
  }) async {
    try {
      if (!_isInitialized) await initialize();
      if (_driveApi == null) throw Exception('Google Drive API not initialized');

      final fileMetadata = drive.File(
        name: fileName,
        description: description,
        parents: folderId != null ? [folderId] : null,
      );

      final media = drive.Media(file.openRead(), await file.length());

      final uploadedFile = await _driveApi!.files.create(
        fileMetadata,
        uploadMedia: media,
      );

      if (uploadedFile.id != null) {
        // Make file publicly readable
        await _driveApi!.permissions.create(
          drive.Permission(type: 'anyone', role: 'reader'),
          uploadedFile.id!,
        );

        final fileInfo = await _driveApi!.files.get(
          uploadedFile.id!,
          $fields: "webViewLink, webContentLink",
        );

        print('✅ File uploaded: ${uploadedFile.id}');
        print('🔗 Web View Link: ${fileInfo.webViewLink}');
        print('📥 Download Link: ${fileInfo.webContentLink}');

        return fileInfo.webContentLink ?? fileInfo.webViewLink;
      }

      return null;
    } catch (e) {
      print('❌ Failed to upload file: $e');
      rethrow;
    }
  }

  /// Create a folder in Google Drive
  static Future<String?> createFolder({
    required String folderName,
    String? parentFolderId,
    String? description,
  }) async {
    try {
      if (!_isInitialized) await initialize();
      if (_driveApi == null) throw Exception('Google Drive API not initialized');

      final folderMetadata = drive.File(
        name: folderName,
        mimeType: 'application/vnd.google-apps.folder',
        description: description,
        parents: parentFolderId != null ? [parentFolderId] : null,
      );

      final createdFolder = await _driveApi!.files.create(folderMetadata);

      if (createdFolder.id != null) {
        print('✅ Folder created: ${createdFolder.id}');
        return createdFolder.id;
      }

      return null;
    } catch (e) {
      print('❌ Failed to create folder: $e');
      rethrow;
    }
  }

  /// List files in Drive or in a specific folder
  static Future<List<drive.File>> listFiles({
    String? folderId,
    String? query,
    int? pageSize,
  }) async {
    try {
      if (!_isInitialized) await initialize();
      if (_driveApi == null) throw Exception('Google Drive API not initialized');

      String? finalQuery = query;
      if (folderId != null) {
        finalQuery = finalQuery != null
            ? '$finalQuery and \'$folderId\' in parents'
            : '\'$folderId\' in parents';
      }

      final files = await _driveApi!.files.list(
        q: finalQuery,
        pageSize: pageSize ?? 100,
        fields: 'files(id,name,mimeType,webViewLink,webContentLink,createdTime,size)',
      );

      return files.files ?? [];
    } catch (e) {
      print('❌ Failed to list files: $e');
      rethrow;
    }
  }

  /// Delete a file from Google Drive
  static Future<bool> deleteFile(String fileId) async {
    try {
      if (!_isInitialized) await initialize();
      if (_driveApi == null) throw Exception('Google Drive API not initialized');

      await _driveApi!.files.delete(fileId);
      print('✅ File deleted: $fileId');
      return true;
    } catch (e) {
      print('❌ Failed to delete file: $e');
      return false;
    }
  }

  /// Get detailed file info
  static Future<drive.File?> getFileInfo(String fileId) async {
    try {
      if (!_isInitialized) await initialize();
      if (_driveApi == null) throw Exception('Google Drive API not initialized');

      final file = await _driveApi!.files.get(
        fileId,
        $fields: 'id, name, mimeType, size, createdTime, webViewLink, webContentLink',
      );

      return file;
    } catch (e) {
      print('❌ Failed to get file info: $e');
      return null;
    }
  }

  /// Download file locally from Google Drive using webContentLink
  static Future<File?> downloadFile(String fileId) async {
    try {
      final fileInfo = await getFileInfo(fileId);
      final link = fileInfo?.webContentLink;
      if (link == null) return null;

      final response = await http.get(Uri.parse(link));
      if (response.statusCode != 200) throw Exception('Failed to download file');

      final tempDir = await getTemporaryDirectory();
      final localFile = File('${tempDir.path}/${fileInfo!.name}');
      await localFile.writeAsBytes(response.bodyBytes);

      print('✅ File downloaded locally: ${localFile.path}');
      return localFile;
    } catch (e) {
      print('❌ Failed to download file: $e');
      return null;
    }
  }
}
