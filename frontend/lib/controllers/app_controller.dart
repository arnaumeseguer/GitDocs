import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat.dart';
import '../models/app_settings.dart';
import '../services/api_service.dart';

/// Controller — AppController
/// Single ChangeNotifier that holds all app state and business logic.
/// Views listen via Provider<AppController>.
class AppController extends ChangeNotifier {
  final _api = ApiService();

  // ── State ──────────────────────────────────────────────────────────────────
  final Map<String, Chat> _chats = {};
  String? _currentChatId;
  AppSettings _settings = const AppSettings();
  bool _isLoading   = false;
  bool _sidebarOpen = true;

  // ── Getters ────────────────────────────────────────────────────────────────
  Map<String, Chat> get chats        => Map.unmodifiable(_chats);
  String?           get currentChatId => _currentChatId;
  Chat?             get currentChat   =>
      _currentChatId != null ? _chats[_currentChatId] : null;
  AppSettings       get settings      => _settings;
  bool              get isLoading     => _isLoading;
  bool              get sidebarOpen   => _sidebarOpen;

  // ── Init ───────────────────────────────────────────────────────────────────
  AppController() {
    _loadPersistedState();
  }

  // ── Persistence (sessionStorage-like via SharedPreferences) ───────────────
  Future<void> _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();

    final settingsJson = prefs.getString('rmg_settings');
    if (settingsJson != null) {
      _settings = AppSettings.fromJson(
          jsonDecode(settingsJson) as Map<String, dynamic>);
    }

    final chatsJson = prefs.getString('rmg_chats');
    if (chatsJson != null) {
      final raw    = jsonDecode(chatsJson) as Map<String, dynamic>;
      final cId    = raw['currentId'] as String?;
      final cData  = raw['chats']     as Map<String, dynamic>? ?? {};

      for (final entry in cData.entries) {
        final d = entry.value as Map<String, dynamic>;
        _chats[entry.key] = Chat(
          id:        d['id']    as String,
          title:     d['title'] as String,
          createdAt: DateTime.fromMillisecondsSinceEpoch(d['createdAt'] as int),
          messages:  (d['messages'] as List)
              .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
              .toList(),
        );
      }
      if (cId != null && _chats.containsKey(cId)) _currentChatId = cId;
    }

    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();

    final cData = <String, dynamic>{};
    for (final e in _chats.entries) {
      cData[e.key] = {
        'id':        e.value.id,
        'title':     e.value.title,
        'createdAt': e.value.createdAt.millisecondsSinceEpoch,
        'messages':  e.value.messages.map((m) => m.toJson()).toList(),
      };
    }
    await prefs.setString('rmg_chats',
        jsonEncode({'currentId': _currentChatId, 'chats': cData}));
  }

  Future<void> _persistSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rmg_settings', jsonEncode(_settings.toJson()));
  }

  // ── Chat management ────────────────────────────────────────────────────────
  String _genId() =>
      '${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}'
      '${DateTime.now().microsecond.toRadixString(36)}';

  void createChat({String title = 'Nou xat'}) {
    final id = _genId();
    _chats[id] = Chat(
        id: id, title: title, messages: [], createdAt: DateTime.now());
    _currentChatId = id;
    _persist();
    notifyListeners();
  }

  void deleteChat(String id) {
    _chats.remove(id);
    if (_currentChatId == id) {
      _currentChatId = _chats.isEmpty ? null : _chats.keys.last;
    }
    _persist();
    notifyListeners();
  }

  void switchChat(String id) {
    if (_chats.containsKey(id)) {
      _currentChatId = id;
      _persist();
      notifyListeners();
    }
  }

  void toggleSidebar() {
    _sidebarOpen = !_sidebarOpen;
    notifyListeners();
  }

  void updateSettings(AppSettings s) {
    _settings = s;
    _persistSettings();
    notifyListeners();
  }

  // ── Send message ───────────────────────────────────────────────────────────
  Future<void> sendMessage(String text) async {
    if (_currentChatId == null) createChat();
    final chat = _chats[_currentChatId]!;

    // Persist user message
    final userMsg = ChatMessage(
        id: _genId(), role: 'user', content: text,
        timestamp: DateTime.now());
    chat.messages.add(userMsg);
    if (chat.messages.where((m) => m.role == 'user').length == 1) {
      chat.title = text.length > 46 ? '${text.substring(0, 46)}…' : text;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final url = _detectGithubUrl(text);
      if (url != null) {
        await _handleGithubFlow(text, url, chat);
      } else {
        await _handleGeneralChat(text, chat);
      }
    } catch (e) {
      chat.messages.add(ChatMessage(
          id: _genId(), role: 'bot',
          content: 'Error: $e', timestamp: DateTime.now()));
    } finally {
      _isLoading = false;
      _persist();
      notifyListeners();
    }
  }

  // ── Business logic ─────────────────────────────────────────────────────────
  String? _detectGithubUrl(String text) {
    final m = RegExp(r'https?://github\.com/\S+').firstMatch(text);
    return m?.group(0);
  }

  Map<String, String>? _parseGithubUrl(String url) {
    final m =
        RegExp(r'github\.com/([^/\s]+)/([^/\s#?]+)').firstMatch(url);
    if (m == null) return null;
    return {'owner': m.group(1)!, 'repo': m.group(2)!};
  }

  String? _detectLanguage(String text) {
    final t = text.toLowerCase();
    if (RegExp(r'\bcatal[aà]\b').hasMatch(t))              return 'catalan (català)';
    if (RegExp(r'\b(castellan[o]|espanyol|spanish)\b').hasMatch(t)) return 'Spanish (español)';
    if (RegExp(r'\bengl[eè]s\b|\benglish\b').hasMatch(t)) return 'English';
    if (RegExp(r'\bfrancés\b|\bfrench\b').hasMatch(t))    return 'French (français)';
    if (RegExp(r'\balemany\b|\bgerman\b|\bdeutsch\b').hasMatch(t)) return 'German (Deutsch)';
    if (RegExp(r'\bitalian[o]?\b').hasMatch(t))            return 'Italian (italiano)';
    if (RegExp(r'\bportuguese\b|\bportugués\b').hasMatch(t)) return 'Portuguese (português)';
    return null;
  }

  Future<void> _handleGithubFlow(
      String text, String githubUrl, Chat chat) async {
    if (_settings.apiKey.isEmpty) {
      throw Exception(
          'Cal configurar una API Key a Configuració (icona ⚙️).');
    }
    final parsed = _parseGithubUrl(githubUrl);
    if (parsed == null) {
      throw Exception(
          'URL de GitHub invàlida. Format: https://github.com/usuari/repo');
    }

    final lang = _detectLanguage(text) ?? 'English';

    final repoData = await _api.fetchRepo(
      owner: parsed['owner']!,
      repo:  parsed['repo']!,
      token: _settings.githubToken.isEmpty ? null : _settings.githubToken,
    );

    final info     = repoData['info']     as Map<String, dynamic>;
    final files    = (repoData['files']   as List).cast<String>();
    final contents = repoData['contents'] as Map<String, dynamic>;

    final fileList     = files.take(60).join('\n');
    final fileContents = contents.entries
        .map((e) => '--- ${e.key} ---\n${e.value}')
        .join('\n\n');

    const systemPrompt =
        'You are an expert technical writer. Generate a comprehensive, '
        'well-structured README.md for a GitHub repository. '
        'Use proper Markdown (headings, code blocks, tables, badges). '
        'Include: title, description, features, prerequisites, installation, '
        'usage, configuration, contributing, license. '
        'Output ONLY the raw README.md content — no explanation, no preamble.';

    final userPrompt = '''Generate a README.md in $lang for:

Repository: ${info['full_name']}
Description: ${info['description'] ?? 'N/A'}
Language: ${info['language'] ?? 'N/A'}
Stars: ${info['stargazers_count']} · Forks: ${info['forks_count']}
License: ${(info['license'] as Map?)?['name'] ?? 'N/A'}
Topics: ${(info['topics'] as List?)?.join(', ') ?? 'N/A'}
Default branch: ${info['default_branch']}

File tree:
$fileList

Key files:
$fileContents''';

    final readme = await _api.chat(
      messages: [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user',   'content': userPrompt},
      ],
      apiKey:   _settings.apiKey,
      provider: _settings.provider,
      model:    _settings.model,
    );

    chat.messages.add(ChatMessage(
      id:        _genId(),
      role:      'bot',
      content:   'He generat el README per a **${info['full_name']}** en $lang:',
      readme:    readme,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> _handleGeneralChat(String text, Chat chat) async {
    if (_settings.apiKey.isEmpty) {
      throw Exception(
          'Cal configurar una API Key a Configuració (icona ⚙️).');
    }

    const system =
        "Ets un assistent expert en documentació tècnica. La teva funció és "
        "generar fitxers README.md per a repositoris GitHub. Si l'usuari no "
        "proporciona una URL de GitHub, demana-li que en comparteixi una i "
        "que indiqui l'idioma.";

    final messages = [
      {'role': 'system', 'content': system},
      ...chat.messages.map((m) => {
            'role':    m.role == 'bot' ? 'assistant' : 'user',
            'content': m.content,
          }),
    ];

    final reply = await _api.chat(
      messages: messages,
      apiKey:   _settings.apiKey,
      provider: _settings.provider,
      model:    _settings.model,
    );

    chat.messages.add(ChatMessage(
        id:        _genId(),
        role:      'bot',
        content:   reply,
        timestamp: DateTime.now()));
  }
}
