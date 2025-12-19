import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiCall {
  // ✅ GET method
  static Future<dynamic> get(String url) async {
    final uri = Uri.parse(url);
    try {
      print("\n📡 [GET] → $uri");

      final response = await http.get(
        uri,
        headers: {"Content-Type": "application/json"},
      );

      print("🔹 Response (${response.statusCode}):\n${response.body}\n");
      return _handleResponse(uri, null, response);
    } catch (e) {
      print("❌ [GET ERROR] $e");
      throw Exception("Network error, please try again later.");
    }
  }

  // ✅ POST Multipart method for file uploads
  static Future<dynamic> postMultipart(
      String url,
      Map<String, String> fields,
          {String? filePath, String? fileField, String? fileType}
      ) async {
    final uri = Uri.parse(url);
    try {
      print("\n📡 [POST MULTIPART] → $uri");
      print("📤 Fields: $fields");
      if (filePath != null) print("📤 File: $fileField at $filePath");

      var request = http.MultipartRequest('POST', uri);

      // Add all textual fields
      request.fields.addAll(fields);

      // Add file if path is provided
      if (filePath != null && fileField != null) {
        final file = await http.MultipartFile.fromPath(
          fileField,
          filePath,
        );
        request.files.add(file);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("🔹 Response (${response.statusCode}):\n${response.body}\n");
      return _handleResponse(uri, fields, response); // Using fields for logging
    } catch (e) {
      print("❌ [POST MULTIPART ERROR] $e");
      throw Exception("Network error, please try again later.");
    }
  }

  // Existing POST method
  static Future<dynamic> post(String url, Map<String, dynamic> body) async {
    final uri = Uri.parse(url);
    try {
      print("\n📡 [POST] → $uri");
      if (body.isNotEmpty) print("📤 Raw Body: ${jsonEncode(body)}");

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: body.isNotEmpty ? jsonEncode(body) : null,
      );

      print("🔹 Response (${response.statusCode}):\n${response.body}\n");
      return _handleResponse(uri, body, response);
    } catch (e) {
      print("❌ [POST ERROR] $e");
      throw Exception("Network error, please try again later.");
    }
  }

  static dynamic _handleResponse(Uri uri, Map<String, dynamic>? body, http.Response response) {
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("⚠️ API Error → URI: $uri");
      if (body != null && body.isNotEmpty) print("📦 Body: $body");
      print("🧾 Raw Response: ${response.body}\n");

      throw Exception("Something went wrong. (${response.statusCode})");
    }
  }
}
