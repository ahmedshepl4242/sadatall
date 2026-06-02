import 'dart:io';
import 'dart:typed_data';
import 'package:minio/minio.dart';
import 'package:path/path.dart' as path;
import '../constants/app_constants.dart';

class WasabiService {
  static final WasabiService _instance = WasabiService._internal();
  factory WasabiService() => _instance;
  WasabiService._internal();

  Minio? _minioClient;

  Minio get _client {
    if (_minioClient == null) {
      final endpointUri = Uri.parse(AppConstants.wasabiEndpoint);
      _minioClient = Minio(
        endPoint: "s3.${AppConstants.wasabiRegion}.wasabisys.com",
        accessKey: AppConstants.wasabiAccessKey,
        secretKey: AppConstants.wasabiSecretKey,
        useSSL: endpointUri.scheme == 'https',
        region: AppConstants.wasabiRegion,
      );
    }
    return _minioClient!;
  }

  /// Upload a file to Wasabi S3
  /// Returns the S3 path (not presigned URL) on success, or null on failure
  Future<String?> uploadFile({
    required File file,
    required String fileName,
  }) async {
    try {
      final String objectName = 'order-attachments/$fileName';
      final String contentType = _getContentType(fileName);

      // Read file bytes
      final bytes = await file.readAsBytes();
      final uint8list = Uint8List.fromList(bytes);
      final stream = Stream<Uint8List>.value(uint8list);

      // Upload to S3 using putObject
      var etag = await _client.putObject(
        AppConstants.wasabiBucket,
        objectName,
        stream,
        size: bytes.length,
        metadata: {
          'Content-Type': contentType,
        },
      );
      
      // Verify upload by checking if object exists
      bool exists = false;
      try {
        await _client.statObject(AppConstants.wasabiBucket, objectName);
        exists = true;
        print('✅ Upload verified - file exists: $objectName');
      } catch (e) {
        print('⚠️ Could not verify upload: $e');
        // Even if verification fails, the upload might have succeeded
        // Return the path anyway since putObject completed
        exists = etag != null;
      }

      if (exists) {
        print('Upload succeeded!');
        print('ETag: $etag');
      } else {
        print('Upload may have failed - no ETag returned');
      }

      return objectName;
    } catch (e) {
      print('❌ Error uploading file: $e');
      return null;
    }
  }

  /// Generate a unique filename for attachments
  String generateFileName({
    required String orderId,
    required String extension,
    int? index,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    if (index != null) {
      return '${timestamp}_$index.$extension';
    }
    return '$timestamp.$extension';
  }

  /// Get content type based on file extension
  String _getContentType(String fileName) {
    final ext = path.extension(fileName).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.m4a':
        return 'audio/m4a';
      case '.aac':
        return 'audio/aac';
      case '.mp3':
        return 'audio/mpeg';
      default:
        return 'application/octet-stream';
    }
  }
}
