import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service — ApiService
/// Calls the Express backend. Never accessed by Views directly.
class ApiService {
  /// In production the Flutter build is served by the same Express server,
  /// so we use a relative path. In debug we point to localhost:3000.
  static String get _base {
    if (kReleaseMode) return '';
    return const String.fromEnvironment('API_BASE',
        defaultValue: 'http://localhost:3000');
  }

  Future<Map<String, dynamic>> _post(
      String path, Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('${_base}$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      throw Exception(data['error'] ?? 'HTTP ${res.statusCode}');
    }
    return data;
  }

  /// Fetches GitHub repo metadata, file tree and key file contents.
  Future<Map<String, dynamic>> fetchRepo({
    required String owner,
    required String repo,
    String? token,
  }) =>
      _post('/api/github/repo', {'owner': owner, 'repo': repo, 'token': token});

  /// Sends a chat request to the configured AI provider.
  Future<String> chat({
    required List<Map<String, String>> messages,
    required String apiKey,
    required String provider,
    required String model,
  }) async {
    final data = await _post('/api/ai/chat', {
      'messages': messages,
      'apiKey':   apiKey,
      'provider': provider,
      'model':    model,
    });
    return data['content'] as String;
  }
}
