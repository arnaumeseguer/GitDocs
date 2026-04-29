import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../l10n/strings_provider.dart';
import '../theme.dart';

class SavedScreen extends StatelessWidget {
  final List<HistoryItem> saved;
  final ValueChanged<HistoryItem> onOpen;
  final ValueChanged<HistoryItem> onUnsave;

  const SavedScreen({
    super.key,
    required this.saved,
    required this.onOpen,
    required this.onUnsave,
  });

  @override
  Widget build(BuildContext context) {
    final s = StringsProvider.of(context);

    if (saved.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bookmark_border, size: 44, color: kSurfaceHigh),
            const SizedBox(height: 14),
            Text(s.get('saved_empty_title'),
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: kOnSurfaceMuted)),
            const SizedBox(height: 4),
            Text(s.get('saved_empty_sub'),
                style: const TextStyle(fontSize: 13, color: kOnSurfaceMuted)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.get('page_saved'),
                  style: GoogleFonts.manrope(
                      fontSize: 24, fontWeight: FontWeight.w800)),
              Text('${saved.length} README${saved.length != 1 ? 's' : ''}',
                  style: const TextStyle(fontSize: 13, color: kOnSurfaceMuted)),
              const SizedBox(height: 24),
              ...saved.reversed.map((item) => _SavedCard(
                    item: item,
                    onTap: () => onOpen(item),
                    onUnsave: () => onUnsave(item),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedCard extends StatefulWidget {
  final HistoryItem item;
  final VoidCallback onTap;
  final VoidCallback onUnsave;

  const _SavedCard({
    required this.item,
    required this.onTap,
    required this.onUnsave,
  });

  @override
  State<_SavedCard> createState() => _SavedCardState();
}

class _SavedCardState extends State<_SavedCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final s = StringsProvider.of(context);
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
                            const Icon(Icons.bookmark,
                                size: 14, color: kAccent),
                            const SizedBox(width: 6),
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
                        Text(item.repoData['description'] ?? item.url,
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
                      const SizedBox(height: 8),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: widget.onUnsave,
                          child: Tooltip(
                            message: s.get('saved_unsave'),
                            child: Icon(Icons.bookmark_remove,
                                size: 18, color: kOnSurfaceFaint),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item.readme.substring(0, item.readme.length.clamp(0, 180)),
                style: const TextStyle(
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
          color: kAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(999)),
      child: Text(label,
          style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700, color: kAccent)));
}
