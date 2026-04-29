import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../l10n/strings_provider.dart';
import '../theme.dart';

class NewReadmeScreen extends StatefulWidget {
  final AppSettings settings;
  final Future<void> Function(
      String readme,
      Map<String, dynamic> repoData,
      Map<String, dynamic> langData,
      AppSettings settings,
      String url,
      Map<String, dynamic> aiMeta) onResult;

  const NewReadmeScreen(
      {super.key, required this.settings, required this.onResult});

  @override
  State<NewReadmeScreen> createState() => _NewReadmeScreenState();
}

class _NewReadmeScreenState extends State<NewReadmeScreen> {
  final _urlCtrl = TextEditingController();
  bool _loading = false;
  String _loadMsg = '';
  String _error = '';
  Map<String, dynamic>? _repoPreview;
  late AppSettings _local;
  String _aiModel = 'gemini';

  @override
  void initState() {
    super.initState();
    _local = widget.settings;
    _urlCtrl.addListener(_onUrlChanged);
  }

  @override
  void dispose() {
    _urlCtrl.removeListener(_onUrlChanged);
    _urlCtrl.dispose();
    super.dispose();
  }

  void _onUrlChanged() {
    setState(() => _repoPreview = null);
    Future.delayed(const Duration(milliseconds: 600), () async {
      if (_urlCtrl.text.isEmpty) return;
      final parsed = parseGithubUrl(_urlCtrl.text);
      if (parsed == null) return;
      try {
        final data =
            await ApiService.fetchRepo(parsed['owner']!, parsed['repo']!);
        if (mounted) setState(() => _repoPreview = data);
      } catch (_) {}
    });
  }

  Future<void> _pickMdFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['md'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;
    final content = utf8.decode(file.bytes!);
    final name = file.name.endsWith('.md')
        ? file.name.substring(0, file.name.length - 3)
        : file.name;
    await widget.onResult(
        content, {'full_name': name}, {}, _local, file.name, {});
  }

  Future<void> _generate() async {
    final s = StringsProvider.of(context);
    setState(() => _error = '');
    final parsed = parseGithubUrl(_urlCtrl.text);
    if (parsed == null) {
      setState(() => _error = s.get('error_url'));
      return;
    }
    setState(() {
      _loading = true;
      _loadMsg = s.get('loading_repo');
    });

    try {
      final results = await Future.wait([
        ApiService.fetchRepo(parsed['owner']!, parsed['repo']!),
        ApiService.fetchLanguages(parsed['owner']!, parsed['repo']!),
        ApiService.fetchContents(parsed['owner']!, parsed['repo']!),
      ]);
      final repoData = results[0] as Map<String, dynamic>;
      final langData = results[1] as Map<String, dynamic>;
      final contents = results[2] as List<dynamic>;

      final existingReadme =
          await ApiService.fetchReadme(parsed['owner']!, parsed['repo']!);

      setState(() => _loadMsg = s.get('loading_ai'));

      final prompt = ApiService.buildPrompt(
        repoData: repoData,
        langData: langData,
        contents: contents,
        existingReadme: existingReadme,
        settings: _local,
      );

      final aiResponse = await ApiService.generateReadme(
        prompt: prompt,
        repoData: repoData,
        langData: langData,
        settings: _local,
        aiModel: _aiModel,
      );

      final readme = aiResponse['readme'] as String;
      await widget.onResult(
          readme, repoData, langData, _local, _urlCtrl.text, aiResponse);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = StringsProvider.of(context);
    final examples = [
      'https://github.com/facebook/react',
      'https://github.com/vercel/next.js',
      'https://github.com/tailwindlabs/tailwindcss',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.get('page_new'), style: headline(size: 28)),
              const SizedBox(height: 6),
              Text(s.get('new_subtitle'),
                  style: const TextStyle(color: kOnSurfaceMuted, fontSize: 14)),
              const SizedBox(height: 32),

              // URL card
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.get('url_label'),
                        style: GoogleFonts.manrope(
                            fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _urlCtrl,
                            decoration: InputDecoration(
                              hintText: s.get('url_placeholder'),
                              prefixIcon: const Icon(Icons.link, size: 18),
                              filled: true,
                              fillColor: kSurfaceLow,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: kAccent.withValues(alpha: 0.3),
                                    width: 1.5),
                              ),
                            ),
                            onSubmitted: (_) => _generate(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Model dropdown
                        Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: kSurfaceLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _aiModel,
                              items: const [
                                DropdownMenuItem(
                                    value: 'gemini', child: Text('Gemini')),
                                DropdownMenuItem(
                                    value: 'grok', child: Text('Grok')),
                                DropdownMenuItem(
                                    value: 'claude', child: Text('Claude')),
                              ],
                              onChanged: _loading
                                  ? null
                                  : (v) => setState(() => _aiModel = v!),
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: kOnSurface,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _loading || _urlCtrl.text.isEmpty
                              ? null
                              : _generate,
                          icon: _loading
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.auto_awesome, size: 16),
                          label: Text(
                              _loading
                                  ? s.get('generating')
                                  : s.get('generate'),
                              style: GoogleFonts.manrope(
                                  fontWeight: FontWeight.w700, fontSize: 14)),
                        ),
                      ],
                    ),

                    // Repo preview
                    if (_repoPreview != null && !_loading) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            color: kSurfaceLow,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            const Icon(Icons.folder_outlined,
                                size: 20, color: kAccent),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_repoPreview!['full_name'] ?? '',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis),
                                  Text(
                                      _repoPreview!['description'] ??
                                          s.get('no_description'),
                                      style: const TextStyle(
                                          fontSize: 11, color: kOnSurfaceMuted),
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star_outline, size: 14),
                                const SizedBox(width: 3),
                                Text(
                                    '${_repoPreview!['stargazers_count'] ?? 0}',
                                    style: const TextStyle(
                                        fontSize: 11, color: kOnSurfaceMuted)),
                                if (_repoPreview!['language'] != null) ...[
                                  const SizedBox(width: 8),
                                  _badge(_repoPreview!['language'],
                                      kAccent.withValues(alpha: 0.1), kAccent),
                                ]
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Examples
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        Text(s.get('examples'),
                            style: const TextStyle(
                                fontSize: 11,
                                color: kOnSurfaceFaint,
                                fontWeight: FontWeight.w500)),
                        ...examples.map((ex) => GestureDetector(
                              onTap: () => _urlCtrl.text = ex,
                              child: Text(
                                  ex.replaceAll('https://github.com/', ''),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: kAccent,
                                      fontFamily: 'JetBrains Mono')),
                            )),
                      ],
                    ),

                    if (_error.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color:
                                const Color(0xFFEF4444).withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                size: 16, color: Color(0xFFDC2626)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_error,
                                  style: const TextStyle(
                                      fontSize: 13, color: Color(0xFFDC2626))),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Open .md file
              if (!_loading) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(child: Divider(color: kSurfaceHigh)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text('o',
                          style:
                              TextStyle(fontSize: 12, color: kOnSurfaceFaint)),
                    ),
                    const Expanded(child: Divider(color: kSurfaceHigh)),
                  ],
                ),
                const SizedBox(height: 16),
                _card(
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: kSurfaceLow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.description_outlined,
                            size: 18, color: kOnSurfaceMuted),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.get('open_md_title'),
                                style: GoogleFonts.manrope(
                                    fontSize: 13, fontWeight: FontWeight.w700)),
                            Text(s.get('open_md_sub'),
                                style: const TextStyle(
                                    fontSize: 11, color: kOnSurfaceMuted)),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _pickMdFile,
                        icon: const Icon(Icons.folder_open_outlined, size: 15),
                        label: Text(s.get('open_md_btn')),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kOnSurface,
                          side: const BorderSide(color: kSurfaceHigh),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Loading
              if (_loading) ...[
                const SizedBox(height: 20),
                _card(
                  child: Column(
                    children: [
                      const Icon(Icons.auto_awesome, size: 32, color: kAccent),
                      const SizedBox(height: 14),
                      Text(_loadMsg,
                          style: GoogleFonts.manrope(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(s.get('loading_wait'),
                          style: const TextStyle(
                              fontSize: 13, color: kOnSurfaceMuted)),
                      const SizedBox(height: 16),
                      const LinearProgressIndicator(
                          color: kAccent, backgroundColor: kSurfaceLow),
                    ],
                  ),
                ),
              ],

              // Settings grid
              if (!_loading) ...[
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionLabel(Icons.segment, s.get('length_label')),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              children: [
                                ['concise', s.get('concise')],
                                ['balanced', s.get('balanced')],
                                ['detailed', s.get('detailed')],
                              ]
                                  .map((v) =>
                                      _chip(v[0], v[1], _local.length == v[0],
                                          () {
                                        setState(() => _local =
                                            _local.copyWith(length: v[0]));
                                      }))
                                  .toList(),
                            ),
                            const SizedBox(height: 16),
                            _sectionLabel(
                                Icons.record_voice_over, s.get('tone_label')),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              children: [
                                ['professional', s.get('professional')],
                                ['playful', s.get('playful')],
                                ['academic', s.get('academic')],
                              ]
                                  .map((v) => _chip(
                                          v[0], v[1], _local.tone == v[0], () {
                                        setState(() => _local =
                                            _local.copyWith(tone: v[0]));
                                      }))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionLabel(Icons.mood, s.get('emoji_label')),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              children: [
                                ['none', s.get('none')],
                                ['minimal', s.get('minimal')],
                                ['vibrant', s.get('vibrant')],
                              ]
                                  .map((v) => _chip(
                                          v[0], v[1], _local.emoji == v[0], () {
                                        setState(() => _local =
                                            _local.copyWith(emoji: v[0]));
                                      }))
                                  .toList(),
                            ),
                            const SizedBox(height: 16),
                            _sectionLabel(
                                Icons.grid_view, s.get('template_label')),
                            const SizedBox(height: 10),
                            DropdownButton<String>(
                              value: _local.template,
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: kTemplates
                                  .map((t) => DropdownMenuItem(
                                      value: t.id, child: Text(t.label)))
                                  .toList(),
                              onChanged: (v) => setState(
                                  () => _local = _local.copyWith(template: v)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.all(28),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [kIslandShadow],
        ),
        child: child,
      );

  Widget _sectionLabel(IconData icon, String label) => Row(
        children: [
          Icon(icon, size: 16, color: kOnSurfaceMuted),
          const SizedBox(width: 6),
          Text(label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: kOnSurfaceMuted,
                  letterSpacing: 0.8)),
        ],
      );

  Widget _chip(String id, String label, bool active, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: active ? kPrimary : kSurfaceLow,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : kOnSurfaceMuted)),
        ),
      );

  Widget _badge(String label, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Text(label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: fg,
                letterSpacing: 0.8)),
      );
}
