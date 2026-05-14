import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../l10n/strings_provider.dart';
import '../theme.dart';

class HistoryScreen extends StatelessWidget {
  final List<HistoryItem> history;
  final ValueChanged<HistoryItem> onOpen;
  final VoidCallback onClear;

  const HistoryScreen({
    super.key,
    required this.history,
    required this.onOpen,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final s = StringsProvider.of(context);
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, size: 40, color: kSurfaceHigh),
            const SizedBox(height: 14),
            Text(s.get('history_empty_title'),
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: kOnSurfaceMuted)),
            const SizedBox(height: 4),
            Text(s.get('history_empty_sub'),
                style: const TextStyle(fontSize: 13, color: kOnSurfaceMuted)),
          ],
        ),
      );
    }

    final genWord = history.length != 1
        ? s.get('history_generated_pl')
        : s.get('history_generated');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.get('history_title'),
                          style: GoogleFonts.manrope(
                              fontSize: 24, fontWeight: FontWeight.w800)),
                      Text(
                          '${history.length} README${history.length != 1 ? 's' : ''} $genWord',
                          style: const TextStyle(
                              fontSize: 13, color: kOnSurfaceMuted)),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: onClear,
                    icon: const Icon(Icons.delete_sweep, size: 15),
                    label: Text(s.get('history_clear')),
                    style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ...history.reversed.map((item) => _HistoryCard(
                    item: item,
                    onTap: () => onOpen(item),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatefulWidget {
  final HistoryItem item;
  final VoidCallback onTap;

  const _HistoryCard({required this.item, required this.onTap});

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [_hovered ? kIslandShadowHover : kIslandShadow],
          ),
          transform: _hovered
              ? (Matrix4.identity()..translate(0.0, -1.0))
              : Matrix4.identity(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                  item.repoData['full_name'] ?? item.url,
                                  style: GoogleFonts.manrope(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            if (item.repoData['language'] != null) ...[
                              const SizedBox(width: 8),
                              _badge(item.repoData['language']),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                            item.repoData['description'] ?? item.url,
                            style: const TextStyle(
                                fontSize: 12, color: kOnSurfaceMuted),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                          DateTime.fromMillisecondsSinceEpoch(item.timestamp)
                              .toLocal()
                              .toString()
                              .substring(0, 10),
                          style: const TextStyle(
                              fontSize: 11, color: kOnSurfaceFaint)),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: [
                          _badgeMuted(item.settings.tone),
                          _badgeMuted(item.settings.template),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item.readme.substring(
                    0, item.readme.length.clamp(0, 180)),
                style: TextStyle(
                    fontSize: 12,
                    color: kOnSurfaceMuted,
                    fontFamily: 'JetBrains Mono',
                    height: 1.5),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String label) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
            color: kAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(999)),
        child: Text(label,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: kAccent)));

  Widget _badgeMuted(String label) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
            color: kSurfaceLow, borderRadius: BorderRadius.circular(999)),
        child: Text(label,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: kOnSurfaceMuted)));
}
