import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImageKitService {
  Future<String?> uploadImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse("https://upload.imagekit.io/api/v1/files/upload"),
        headers: {
          "Authorization":
              "Basic ${base64Encode(utf8.encode("private_cazdR+YIoYB2VDWJ5vxM2zbCJms=:"))}",
        },
        body: {
          "file": "data:image/jpeg;base64,$base64Image",
          "fileName": "profile_${DateTime.now().millisecondsSinceEpoch}.jpg",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'];
      } else {
        return null;
      }
    } catch (e) {
      print("Upload Error: $e");
      return null;
    }
  }
}
