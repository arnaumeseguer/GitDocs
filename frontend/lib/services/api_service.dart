import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

final _backendUrl =
    kReleaseMode ? 'https://gitdocs.up.railway.app' : 'http://localhost:8000';

class ApiService {
  static Future<Map<String, dynamic>> fetchRepo(
      String owner, String repo) async {
    final res =
        await http.get(Uri.parse('$_backendUrl/github/repo/$owner/$repo'));
    if (res.statusCode == 404) {
      throw Exception('Repositorio no encontrado o privado.');
    }
    if (res.statusCode == 429) {
      throw Exception(
          'Límit de GitHub API superat. Afegeix un GITHUB_TOKEN al .env');
    }
    if (res.statusCode != 200) {
      throw Exception('Error GitHub: ${res.statusCode}');
    }
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> fetchLanguages(
      String owner, String repo) async {
    try {
      final res = await http
          .get(Uri.parse('$_backendUrl/github/repo/$owner/$repo/languages'));
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return {};
  }

  static Future<List<dynamic>> fetchContents(String owner, String repo) async {
    try {
      final res = await http
          .get(Uri.parse('$_backendUrl/github/repo/$owner/$repo/contents'));
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return [];
  }

  static Future<String> fetchReadme(String owner, String repo) async {
    try {
      final res = await http
          .get(Uri.parse('$_backendUrl/github/repo/$owner/$repo/readme'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['content'] == null) return '';
        final encoded = (data['content'] as String).replaceAll('\n', '');
        return utf8.decode(base64Decode(encoded));
      }
    } catch (_) {}
    return '';
  }

  static Future<Map<String, dynamic>> generateReadme({
    required String prompt,
    required Map<String, dynamic> repoData,
    required Map<String, dynamic> langData,
    required AppSettings settings,
    required String aiModel,
  }) async {
    final res = await http.post(
      Uri.parse('$_backendUrl/api/generate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'prompt': prompt,
        'repoData': repoData,
        'langData': langData,
        'settings': settings.toJson(),
        'ai_model': aiModel,
      }),
    );
    if (res.statusCode != 200) {
      final body = jsonDecode(res.body);
      throw Exception(body['detail'] ?? 'API error ${res.statusCode}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (!data.containsKey('readme')) {
      throw Exception('La resposta de la IA no conté el camp readme.');
    }
    return data;
  }

  static String buildPrompt({
    required Map<String, dynamic> repoData,
    required Map<String, dynamic> langData,
    required List<dynamic> contents,
    required String existingReadme,
    required AppSettings settings,
  }) {
    final langs = langData.keys.take(8).join(', ').isEmpty
        ? 'No detectado'
        : langData.keys.take(8).join(', ');
    final files = contents.map((f) => f['name'] as String? ?? '').join(', ');

    const toneMap = {
      'professional': 'profesional y técnico',
      'playful': 'amigable y entretenido',
      'academic': 'formal y académico',
    };
    const lengthMap = {
      'concise': 'conciso (máx 200 palabras)',
      'balanced': 'equilibrado (300-500 palabras)',
      'detailed': 'detallado y completo (600+ palabras)',
    };
    const emojiMap = {
      'none': 'sin emojis',
      'minimal': 'emojis mínimos (solo en títulos)',
      'vibrant': 'emojis en cada sección',
    };
    const templateMap = {
      'standard': 'estándar',
      'minimal': 'minimalista',
      'library': 'librería/SDK',
      'cli': 'herramienta CLI',
      'saas': 'SaaS/App Web',
      'research': 'investigación',
    };
    const langOut = {
      'en': 'English',
      'es': 'Spanish',
      'ca': 'Catalan',
      'fr': 'French',
      'pt': 'Portuguese',
      'de': 'German',
      'ja': 'Japanese',
    };

    final readmeSection = existingReadme.isNotEmpty
        ? '\nEXISTING README (for reference/improvement):\n${existingReadme.substring(0, existingReadme.length.clamp(0, 1500))}'
        : '';

    return '''You are a professional README writer. Generate a high-quality README.md for this GitHub repository.

REPOSITORY INFO:
- Name: ${repoData['full_name']}
- Description: ${repoData['description'] ?? 'No description provided'}
- Stars: ${repoData['stargazers_count']} | Forks: ${repoData['forks_count']} | Language: ${repoData['language'] ?? 'N/A'}
- Topics: ${((repoData['topics'] as List?)?.join(', ')) ?? 'none'}
- License: ${repoData['license']?['name'] ?? 'None'}
- Languages used: $langs
- Root files: $files
- Created: ${(repoData['created_at'] as String?)?.split('T')[0]} | Updated: ${(repoData['updated_at'] as String?)?.split('T')[0]}
$readmeSection

GENERATION SETTINGS:
- Language: Write the README in ${langOut[settings.language] ?? 'English'}
- Tone: ${toneMap[settings.tone] ?? 'profesional y técnico'}
- Length: ${lengthMap[settings.length] ?? 'equilibrado'}
- Emoji usage: ${emojiMap[settings.emoji] ?? 'mínimos'}
- Template style: ${templateMap[settings.template] ?? 'estándar'}

INSTRUCTIONS:
- Start the readme with the repo name as H1 (with a fitting emoji if emoji setting allows)
- Include relevant badges (shields.io) for: build status, version, license, language
- Write a clear, compelling description paragraph
- Include sections appropriate for the template style (Installation, Usage, Features, Contributing, License, etc.)
- For code examples, use proper fenced code blocks with language identifiers
- Make it genuinely useful, not generic boilerplate
- Do NOT add placeholder text like "[Your description here]"
- Base all content on the actual repo data provided

Return ONLY a valid JSON object with exactly this structure (no markdown wrapping, no extra text):
{
  "title": "repository title (short, human-readable)",
  "description": "one clear paragraph describing what this project does and why it matters",
  "key_features": ["feature 1", "feature 2", "feature 3"],
  "tech_stack": ["technology 1", "technology 2", "technology 3"],
  "complexity": "beginner | intermediate | advanced",
  "readme": "FULL MARKDOWN README CONTENT HERE"
}''';
  }
}

Map<String, String>? parseGithubUrl(String url) {
  final match = RegExp(r'github\.com/([^/]+)/([^/\s?#]+)').firstMatch(url);
  if (match == null) return null;
  return {
    'owner': match.group(1)!,
    'repo': match.group(2)!.replaceAll(RegExp(r'\.git$'), ''),
  };
}
