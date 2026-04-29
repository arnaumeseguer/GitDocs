import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/models.dart';
import 'screens/new_readme_screen.dart';
import 'screens/result_screen.dart';
import 'screens/templates_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/saved_screen.dart';
import 'widgets/sidebar.dart';
import 'l10n/strings.dart';
import 'l10n/strings_provider.dart';
import 'theme.dart';

void main() {
  runApp(const GitDocsApp());
}

class GitDocsApp extends StatefulWidget {
  const GitDocsApp({super.key});

  @override
  State<GitDocsApp> createState() => _GitDocsAppState();
}

class _GitDocsAppState extends State<GitDocsApp> {
  AppSettings _settings = const AppSettings();
  List<HistoryItem> _history = [];
  String _uiLang = 'ca';
  HistoryItem? _result;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _router = GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: _buildShell,
          routes: [
            GoRoute(
              path: '/',
              builder: (ctx, state) => NewReadmeScreen(
                settings: _settings,
                onResult:
                    (readme, repoData, langData, settings, url, aiMeta) async {
                  final item = HistoryItem(
                    readme: readme,
                    repoData: repoData,
                    langData: langData,
                    settings: settings,
                    url: url,
                    timestamp: DateTime.now().millisecondsSinceEpoch,
                    aiMeta: aiMeta,
                  );
                  setState(() => _result = item);
                  _addToHistory(item);
                  ctx.go('/result');
                },
              ),
            ),
            GoRoute(
              path: '/result',
              redirect: (ctx, state) => _result == null ? '/' : null,
              builder: (ctx, state) => ResultScreen(
                result: _result!,
                onBack: () => ctx.go('/'),
                onSave: () => _markSaved(_result!),
              ),
            ),
            GoRoute(
              path: '/templates',
              builder: (ctx, state) => TemplatesScreen(
                onSelectTemplate: (id) {
                  _saveSettings(_settings.copyWith(template: id));
                  ctx.go('/');
                },
              ),
            ),
            GoRoute(
              path: '/settings',
              builder: (ctx, state) => SettingsScreen(
                settings: _settings,
                onChanged: _saveSettings,
              ),
            ),
            GoRoute(
              path: '/saved',
              builder: (ctx, state) => SavedScreen(
                saved: _history.where((h) => h.saved).toList(),
                onOpen: (item) {
                  setState(() => _result = item);
                  ctx.go('/result');
                },
                onUnsave: (item) => _unmarkSaved(item),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('gitdocs_settings');
    final historyJson = prefs.getString('gitdocs_history');
    final uiLang = prefs.getString('gitdocs_ui_lang');
    setState(() {
      if (settingsJson != null) {
        _settings = AppSettings.fromJson(jsonDecode(settingsJson));
      }
      if (historyJson != null) {
        final list = jsonDecode(historyJson) as List;
        _history = list.map((e) => HistoryItem.fromJson(e)).toList();
      }
      if (uiLang != null) _uiLang = uiLang;
    });
  }

  Future<void> _saveSettings(AppSettings s) async {
    setState(() => _settings = s);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gitdocs_settings', jsonEncode(s.toJson()));
  }

  Future<void> _saveHistory(List<HistoryItem> h) async {
    setState(() => _history = h);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'gitdocs_history', jsonEncode(h.map((e) => e.toJson()).toList()));
  }

  void _addToHistory(HistoryItem item) {
    final exists = _history.any((x) => x.timestamp == item.timestamp);
    if (!exists) _saveHistory([..._history, item]);
  }

  void _markSaved(HistoryItem item) {
    final updated = _history
        .map((h) => h.timestamp == item.timestamp ? h.copyWith(saved: true) : h)
        .toList();
    if (!_history.any((h) => h.timestamp == item.timestamp)) {
      _saveHistory([..._history, item.copyWith(saved: true)]);
    } else {
      _saveHistory(updated);
    }
    if (_result?.timestamp == item.timestamp) {
      setState(() => _result = _result!.copyWith(saved: true));
    }
  }

  void _unmarkSaved(HistoryItem item) {
    final updated = _history
        .map(
            (h) => h.timestamp == item.timestamp ? h.copyWith(saved: false) : h)
        .toList();
    _saveHistory(updated);
  }

  Future<void> _setUiLang(String lang) async {
    setState(() => _uiLang = lang);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gitdocs_ui_lang', lang);
  }

  Widget _buildShell(BuildContext context, GoRouterState state, Widget child) {
    final strings = StringsProvider.of(context);
    final currentPath = state.fullPath ?? '/';

    final pageTitles = {
      '/': strings.get('page_new'),
      '/result': strings.get('page_result'),
      '/templates': strings.get('page_templates'),
      '/settings': strings.get('page_settings'),
      '/saved': strings.get('page_saved'),
    };

    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            currentPath: currentPath,
            history: _history,
            savedCount: _history.where((h) => h.saved).length,
            onNavigate: (path) => context.go(path),
            onOpenHistory: (item) {
              setState(() => _result = item);
              context.go('/result');
            },
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: kBg.withValues(alpha: 0.9),
                    border:
                        const Border(bottom: BorderSide(color: kSurfaceHigh)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (currentPath == '/')
                        _LangDropdown(value: _uiLang, onChanged: _setUiLang)
                      else
                        Row(
                          children: [
                            Text(pageTitles[currentPath] ?? '',
                                style: GoogleFonts.manrope(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: kOnSurface)),
                            if (currentPath == '/result' &&
                                _result != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22C55E)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(strings.get('badge_generated'),
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF16A34A),
                                        letterSpacing: 0.8)),
                              ),
                            ],
                          ],
                        ),
                      if (currentPath != '/')
                        _LangDropdown(value: _uiLang, onChanged: _setUiLang),
                    ],
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StringsProvider(
      strings: AppStrings(_uiLang),
      child: MaterialApp.router(
        title: 'GitDocs',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        routerConfig: _router,
      ),
    );
  }
}

class _LangDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _LangDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: kSurfaceLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          items: const [
            DropdownMenuItem(value: 'ca', child: Text('Català')),
            DropdownMenuItem(value: 'es', child: Text('Castellano')),
            DropdownMenuItem(value: 'en', child: Text('English')),
          ],
          onChanged: (v) => onChanged(v!),
          style: GoogleFonts.manrope(
              fontSize: 13, fontWeight: FontWeight.w700, color: kOnSurface),
        ),
      ),
    );
  }
}
