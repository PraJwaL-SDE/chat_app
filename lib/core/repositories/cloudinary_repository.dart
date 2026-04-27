import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cloudinaryRepositoryProvider =
    Provider((ref) => CloudinaryRepository());

class CloudinaryRepository {
  final String cloudName = "dvenwmf5x";
  final String uploadPreset = "new_chat_app";
// curl \
//   -d "name=my_preset&unsigned=true&categorization=google_tagging&categorization=google_video_tagging&auto_tagging=0.75&background_removal=cloudinary_ai&asset_folder=new-products" \
//   -X POST \
//   https://<API_KEY>:<API_SECRET>@api.cloudinary.com/v1_1/<cloud_name>/upload_presets
  Future<String> uploadFile(
    File file,
    String folder, {
    void Function(int sent, int total)? onProgress,
  }) async {
    print("uploading file to cloudinary...........");

    try {
      final url = Uri.parse(
          'https://api.cloudinary.com/v1_1/$cloudName/auto/upload');

      String fileName = file.path.split('/').last;

      var request = http.MultipartRequest('POST', url);

      // Fields
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = folder;

      // File
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: fileName,
        ),
      );

      // Send request
      var streamedResponse = await request.send();
      print("streamed response : $streamedResponse");

      // Progress tracking (basic)
      // if (onProgress != null) {
      //   streamedResponse.stream.listen((_) {
      //     // http package doesn't give exact progress easily
      //     // You can only approximate or skip this
      //   });
      // }

      // Convert to normal response
      var response = await http.Response.fromStream(streamedResponse);

      print("upload response: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = response.body;
        final secureUrl = RegExp(r'"secure_url":"(.*?)"')
            .firstMatch(responseData)
            ?.group(1)
            ?.replaceAll(r'\/', '/');

        if (secureUrl != null) {
          return secureUrl;
        } else {
          throw Exception("secure_url not found");
        }
      } else {
        throw Exception('Upload failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Cloudinary error: $e');
    }
  }
}