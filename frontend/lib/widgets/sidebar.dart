import 'package:flutter/material.dart';

import '../l10n/strings_provider.dart';
import '../models/models.dart';
import '../theme.dart';

class Sidebar extends StatelessWidget {
  final String currentPath;
  final List<HistoryItem> history;
  final int savedCount;
  final ValueChanged<String> onNavigate;
  final ValueChanged<HistoryItem> onOpenHistory;

  const Sidebar({
    super.key,
    required this.currentPath,
    required this.history,
    required this.savedCount,
    required this.onNavigate,
    required this.onOpenHistory,
  });

  @override
  Widget build(BuildContext context) {
    final s = StringsProvider.of(context);
    final recent = history.reversed.take(5).toList();

    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(right: BorderSide(color: kSurfaceHigh)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kPrimary, kAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.description_outlined,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('GitDocs', style: headline(size: 18)),
                      const SizedBox(height: 2),
                      const Text('AI README generator',
                          style: TextStyle(
                              fontSize: 12, color: kOnSurfaceMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _NavItem(
              icon: Icons.edit_document,
              label: s.get('page_new'),
              selected: currentPath == '/',
              onTap: () => onNavigate('/'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _NavItem(
              icon: Icons.bookmark_border,
              label: s.get('page_saved'),
              selected: currentPath == '/saved',
              trailing: savedCount > 0 ? _CountBadge(savedCount) : null,
              onTap: () => onNavigate('/saved'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _NavItem(
              icon: Icons.layers_outlined,
              label: s.get('page_templates'),
              selected: currentPath == '/templates',
              onTap: () => onNavigate('/templates'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _NavItem(
              icon: Icons.settings_outlined,
              label: s.get('page_settings'),
              selected: currentPath == '/settings',
              onTap: () => onNavigate('/settings'),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              s.get('page_saved'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: kOnSurfaceMuted,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(
            child: recent.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      'No hi ha historial encara.',
                      style: TextStyle(fontSize: 13, color: kOnSurfaceFaint),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    itemCount: recent.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = recent[index];
                      return _HistoryTile(
                        item: item,
                        onTap: () => onOpenHistory(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Widget? trailing;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? kSurfaceLow : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: selected ? kPrimary : kOnSurfaceMuted),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected ? kOnSurface : kOnSurfaceMuted,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final HistoryItem item;
  final VoidCallback onTap;

  const _HistoryTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final title = item.repoData['full_name']?.toString().trim().isNotEmpty == true
        ? item.repoData['full_name'].toString()
        : 'README';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kSurfaceLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              item.url,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: kOnSurfaceFaint),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int value;
  const _CountBadge(this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: kAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$value',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: kAccent,
        ),
      ),
    );
  }
}
