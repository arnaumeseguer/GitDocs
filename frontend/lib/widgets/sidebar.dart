import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../l10n/strings_provider.dart';
import '../theme.dart';

class Sidebar extends StatelessWidget {
  final String currentPath;
  final List<HistoryItem> history;
  final ValueChanged<String> onNavigate;
  final ValueChanged<HistoryItem> onOpenHistory;

  const Sidebar({
    super.key,
    required this.currentPath,
    required this.history,
    required this.onNavigate,
    required this.onOpenHistory,
  });

  @override
  Widget build(BuildContext context) {
    final s = StringsProvider.of(context);

    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(right: BorderSide(color: kSurfaceHigh)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E293B), Color(0xFF334155)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome,
                      size: 18, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('GitDocs',
                        style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: kOnSurface,
                            letterSpacing: -0.3)),
                    const Text('v1.0 · Beta',
                        style: TextStyle(
                            fontSize: 10,
                            color: kOnSurfaceFaint,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1)),
                  ],
                ),
              ],
            ),
          ),

          // Nav items (Nou + Plantilles)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                _NavButton(
                  icon: Icons.add_circle_outline,
                  label: s.get('nav_new'),
                  active: currentPath == '/' || currentPath == '/result',
                  onTap: () => onNavigate('/'),
                ),
                _NavButton(
                  icon: Icons.grid_view,
                  label: s.get('nav_templates'),
                  active: currentPath == '/templates',
                  onTap: () => onNavigate('/templates'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: kSurfaceHigh),
          ),
          const SizedBox(height: 10),

          // History header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.history, size: 13, color: kOnSurfaceFaint),
                const SizedBox(width: 6),
                Text(s.get('nav_history').toUpperCase(),
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: kOnSurfaceFaint,
                        letterSpacing: 0.8)),
                if (history.isNotEmpty) ...[
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                        color: kSurfaceLow,
                        borderRadius: BorderRadius.circular(999)),
                    child: Text('${history.length}',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: kOnSurfaceFaint)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Scrollable history list
          Expanded(
            child: history.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Text(s.get('history_empty_sub'),
                        style: const TextStyle(
                            fontSize: 11, color: kOnSurfaceFaint, height: 1.5)),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    itemCount: history.length,
                    itemBuilder: (ctx, i) {
                      final item = history[history.length - 1 - i];
                      return _HistoryTile(
                        item: item,
                        onTap: () => onOpenHistory(item),
                      );
                    },
                  ),
          ),

          // Upgrade card
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kSurfaceLow,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [kIslandShadow],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.get('upgrade_title'),
                      style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: kOnSurface)),
                  const SizedBox(height: 3),
                  Text(s.get('upgrade_desc'),
                      style: const TextStyle(
                          fontSize: 10, color: kOnSurfaceMuted, height: 1.5)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {},
                      child: Text(s.get('upgrade_btn'),
                          style: GoogleFonts.manrope(
                              fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // User row + settings
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 8, 14),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: kSurfaceHigh)),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Center(
                      child: Text('U',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700))),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Invitado',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      Text(s.get('plan_free'),
                          style: const TextStyle(
                              fontSize: 10, color: kOnSurfaceMuted)),
                    ],
                  ),
                ),
                // Settings button (like Claude Code's gear icon)
                _IconNavButton(
                  icon: Icons.settings_outlined,
                  active: currentPath == '/settings',
                  tooltip: s.get('nav_settings'),
                  onTap: () => onNavigate('/settings'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.active
        ? kSurfaceLow
        : _hovered
            ? kSurfaceLow.withValues(alpha: 0.6)
            : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration:
              BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              Icon(widget.icon,
                  size: 18,
                  color: widget.active ? kOnSurface : kOnSurfaceMuted),
              const SizedBox(width: 9),
              Text(widget.label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          widget.active ? FontWeight.w600 : FontWeight.w500,
                      color: widget.active ? kOnSurface : kOnSurfaceMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconNavButton extends StatefulWidget {
  final IconData icon;
  final bool active;
  final String tooltip;
  final VoidCallback onTap;

  const _IconNavButton({
    required this.icon,
    required this.active,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_IconNavButton> createState() => _IconNavButtonState();
}

class _IconNavButtonState extends State<_IconNavButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color:
                  widget.active || _hovered ? kSurfaceLow : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              widget.icon,
              size: 17,
              color: widget.active ? kOnSurface : kOnSurfaceMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryTile extends StatefulWidget {
  final HistoryItem item;
  final VoidCallback onTap;

  const _HistoryTile({required this.item, required this.onTap});

  @override
  State<_HistoryTile> createState() => _HistoryTileState();
}

class _HistoryTileState extends State<_HistoryTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final name = item.repoData['full_name'] as String? ?? item.url;
    final lang = item.repoData['language'] as String?;
    final date = DateTime.fromMillisecondsSinceEpoch(item.timestamp)
        .toLocal()
        .toString()
        .substring(0, 10);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.only(bottom: 1),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: _hovered ? kSurfaceLow : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(date,
                      style: const TextStyle(
                          fontSize: 10, color: kOnSurfaceFaint)),
                  if (lang != null) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                          color: kAccent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999)),
                      child: Text(lang,
                          style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: kAccent)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
