import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImageKitService {
  Future<String?> uploadImage(File imageFile) async {
    try {
      final bytes = await imageFile
          .readAsBytes(); //Computers understand bytes, not images.
      final base64Image = base64Encode(
        bytes,
      ); /*HTTP requests can't easily send raw image bytes in a simple form body.
      So image becomes text. */

      final response = await http.post(
        Uri.parse("https://upload.imagekit.io/api/v1/files/upload"),
        headers: {
          "Authorization":
              "Basic ${base64Encode(utf8.encode("private_cazdR+YIoYB2VDWJ5vxM2zbCJms=:"))}",
        },
        body: {
          "file": "data:image/jpeg;base64,$base64Image",
          "fileName":
              "profile_${DateTime.now().millisecondsSinceEpoch}.jpg", //Generates unique names.
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); //convert json ->dart map
        return data['url']; //return imagekit url
      } else {
        return null;
      }
    } catch (e) {
      print("Upload Error: $e");
      return null;
    }
  }
}
