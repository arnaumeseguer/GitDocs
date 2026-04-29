import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown/markdown.dart' as md;
import '../l10n/strings_provider.dart';
import '../models/models.dart';
import '../theme.dart';

class ResultScreen extends StatefulWidget {
  final HistoryItem result;
  final VoidCallback onBack;
  final VoidCallback onSave;

  const ResultScreen({
    super.key,
    required this.result,
    required this.onBack,
    required this.onSave,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String _tab = 'preview';
  bool _copied = false;
  late bool _saved;

  @override
  void initState() {
    super.initState();
    _saved = widget.result.saved;
  }

  @override
  void didUpdateWidget(ResultScreen old) {
    super.didUpdateWidget(old);
    if (widget.result.saved != old.result.saved) {
      _saved = widget.result.saved;
    }
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.result.readme));
    setState(() => _copied = true);
    Future.delayed(
        const Duration(seconds: 2), () => setState(() => _copied = false));
  }

  void _save() {
    widget.onSave();
    setState(() => _saved = true);
  }

  @override
  Widget build(BuildContext context) {
    final s = StringsProvider.of(context);
    final r = widget.result;
    final langs = (r.langData.entries.toList()
          ..sort((a, b) => (b.value as int).compareTo(a.value as int)))
        .take(4)
        .toList();
    final total = r.langData.values.fold<int>(0, (acc, v) => acc + (v as int));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: Text(s.get('back')),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: kOnSurface,
                        side: const BorderSide(color: kSurfaceHigh)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.repoData['full_name'] ?? 'README',
                            style: headline(size: 20),
                            overflow: TextOverflow.ellipsis),
                        Text(
                            DateTime.fromMillisecondsSinceEpoch(r.timestamp)
                                .toLocal()
                                .toString()
                                .substring(0, 16),
                            style: const TextStyle(
                                fontSize: 12, color: kOnSurfaceMuted)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _outBtn(
                          _saved ? Icons.check_circle : Icons.bookmark,
                          _saved ? s.get('saved') : s.get('save'),
                          _saved ? Colors.green : null,
                          _save),
                      const SizedBox(width: 8),
                      _outBtn(
                          _copied ? Icons.check : Icons.content_copy,
                          _copied ? s.get('copied') : s.get('copy'),
                          null,
                          _copy),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // AI parsed metadata (title, description, features...)
              if (r.aiMeta.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [kIslandShadow]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (r.aiMeta['title'] != null)
                        Text(r.aiMeta['title'],
                            style: headline(size: 18)),
                      if (r.aiMeta['description'] != null) ...[
                        const SizedBox(height: 6),
                        Text(r.aiMeta['description'],
                            style: const TextStyle(
                                fontSize: 13, color: kOnSurfaceMuted)),
                      ],
                      const SizedBox(height: 10),
                      if (r.aiMeta['key_features'] is List &&
                          (r.aiMeta['key_features'] as List).isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: (r.aiMeta['key_features'] as List)
                              .map<Widget>((f) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 9, vertical: 6),
                                    decoration: BoxDecoration(
                                        color:
                                            kSurfaceLow, // subtle chip
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Text(f.toString(),
                                        style: const TextStyle(fontSize: 12)),
                                  ))
                              .toList(),
                        ),
                      if (r.aiMeta['tech_stack'] is List &&
                          (r.aiMeta['tech_stack'] as List).isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          children: (r.aiMeta['tech_stack'] as List)
                              .map<Widget>((t) => _badge(t.toString()))
                              .toList(),
                        ),
                      ],
                      if (r.aiMeta['complexity'] != null) ...[
                        const SizedBox(height: 8),
                        Text('Complexity: ${r.aiMeta['complexity']}',
                            style: const TextStyle(
                                fontSize: 12, color: kOnSurfaceMuted)),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 12),
              ],

              // Stats
              if (r.repoData.isNotEmpty && r.repoData.length > 1)
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    if (r.repoData['stargazers_count'] != null)
                      _stat(Icons.star_outline,
                          '${r.repoData['stargazers_count']}', 'Stars'),
                    if (r.repoData['forks_count'] != null)
                      _stat(Icons.fork_right, '${r.repoData['forks_count']}',
                          'Forks'),
                    if (r.repoData['watchers_count'] != null)
                      _stat(Icons.visibility, '${r.repoData['watchers_count']}',
                          'Watchers'),
                    if (r.repoData['open_issues_count'] != null)
                      _stat(Icons.bug_report,
                          '${r.repoData['open_issues_count']}', 'Issues'),
                    if (langs.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                            color: kSurface,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [kIslandShadow]),
                        child: Wrap(
                          spacing: 6,
                          children: langs
                              .map((e) => _badge(
                                  '${e.key} ${total > 0 ? ((e.value as int) / total * 100).round() : 0}%'))
                              .toList(),
                        ),
                      ),
                  ],
                ),

              const SizedBox(height: 20),

              // Tab bar
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: kSurfaceLow,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _tabBtn('preview', s.get('preview')),
                    _tabBtn('raw', 'Markdown'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Content
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [kIslandShadow],
                ),
                child: _tab == 'preview'
                    ? MarkdownBody(
                        data: r.readme,
                        builders: {'pre': _FencedCodeBuilder()},
                        styleSheet: _markdownStyle(context),
                        imageBuilder: (uri, title, alt) => Image.network(
                          uri.toString(),
                          errorBuilder: (_, __, ___) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                                color: kSurfaceLow,
                                borderRadius: BorderRadius.circular(6)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.broken_image_outlined,
                                    size: 14, color: kOnSurfaceFaint),
                                const SizedBox(width: 6),
                                Text(alt ?? uri.toString(),
                                    style: const TextStyle(
                                        fontSize: 11, color: kOnSurfaceFaint)),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SelectableText(
                        r.readme,
                        style: GoogleFonts.jetBrainsMono(
                            fontSize: 12.5, height: 1.7),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  MarkdownStyleSheet _markdownStyle(BuildContext context) {
    final base = MarkdownStyleSheet.fromTheme(Theme.of(context));
    return base.copyWith(
      code: GoogleFonts.jetBrainsMono(
        fontSize: 12.5,
        backgroundColor: const Color(0xFFF1F5F9),
        color: const Color(0xFF7C3AED),
      ),
      codeblockDecoration: const BoxDecoration(),
      codeblockPadding: EdgeInsets.zero,
    );
  }

  Widget _tabBtn(String id, String label) {
    final active = _tab == id;
    return GestureDetector(
      onTap: () => setState(() => _tab = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: active ? kSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: active ? [kIslandShadow] : null,
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? kOnSurface : kOnSurfaceMuted)),
      ),
    );
  }

  Widget _stat(IconData icon, String val, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [kIslandShadow],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: kOnSurfaceMuted),
            const SizedBox(width: 6),
            Text(val,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(fontSize: 12, color: kOnSurfaceMuted)),
          ],
        ),
      );

  Widget _badge(String label) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
          color: kAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(999)),
      child: Text(label,
          style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: kAccent,
              letterSpacing: 0.8)));

  Widget _outBtn(
          IconData icon, String label, Color? color, VoidCallback onTap) =>
      OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 15),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color ?? kOnSurface,
          side: const BorderSide(color: kSurfaceHigh),
        ),
      );
}

// ── Code block builder ────────────────────────────────────────────────────────

class _FencedCodeBuilder extends MarkdownElementBuilder {
  @override
  bool isBlockElement() => true;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    String language = '';
    String code = element.textContent;

    if (element.children != null) {
      for (final child in element.children!) {
        if (child is md.Element && child.tag == 'code') {
          final cls = child.attributes['class'] ?? '';
          if (cls.startsWith('language-')) language = cls.substring(9);
          code = child.textContent;
          break;
        }
      }
    }

    return _CodeBlock(code: code.trimRight(), language: language);
  }
}

class _CodeBlock extends StatefulWidget {
  final String code;
  final String language;
  const _CodeBlock({required this.code, required this.language});

  @override
  State<_CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<_CodeBlock> {
  bool _copied = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.code));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF21262D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: language + copy button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF21262D))),
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(
              children: [
                if (widget.language.isNotEmpty)
                  Text(
                    widget.language,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8B949E),
                      fontFamily: 'JetBrains Mono',
                      letterSpacing: 0.4,
                    ),
                  ),
                const Spacer(),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: _copy,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      child: Row(
                        key: ValueKey(_copied),
                        children: [
                          Icon(
                            _copied ? Icons.check : Icons.content_copy,
                            size: 13,
                            color: _copied
                                ? const Color(0xFF3FB950)
                                : const Color(0xFF6E7681),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _copied ? 'Copiat' : 'Copiar',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _copied
                                  ? const Color(0xFF3FB950)
                                  : const Color(0xFF6E7681),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Code content
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(18),
            child: SelectableText(
              widget.code,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'JetBrains Mono',
                color: Color(0xFFE6EDF3),
                height: 1.65,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
