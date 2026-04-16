import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/app_controller.dart';
import '../../core/app_colors.dart';
import '../../models/chat.dart';
import '../settings/settings_dialog.dart';

/// View — SidebarView
/// Left sidebar: logo + nav + chat history + pro card + user profile.
/// Matches the stitch_ai aside element (glass, 256px, slate-50/80 bg).
class SidebarView extends StatefulWidget {
  const SidebarView({super.key});
  @override
  State<SidebarView> createState() => _SidebarViewState();
}

class _SidebarViewState extends State<SidebarView> {
  _NavSection _active = _NavSection.newReadme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogo(),
          _buildNav(),
          const SizedBox(height: 4),
          _buildRecentLabel(),
          Expanded(child: _buildChatList()),
          _buildProCard(),
          _buildUserProfile(),
        ],
      ),
    );
  }

  // ── Logo ───────────────────────────────────────────────────────────────────
  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            'README AI',
            style: GoogleFonts.manrope(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'v1.0',
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.outline,
            ),
          ),
        ],
      ),
    );
  }

  // ── Navigation ─────────────────────────────────────────────────────────────
  Widget _buildNav() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          _NavItem(
            icon: Icons.add_circle_outline_rounded,
            label: 'New Readme',
            active: _active == _NavSection.newReadme,
            onTap: () {
              setState(() => _active = _NavSection.newReadme);
              context.read<AppController>().createChat();
            },
          ),
          _NavItem(
            icon: Icons.history_rounded,
            label: 'History',
            active: _active == _NavSection.history,
            onTap: () => setState(() => _active = _NavSection.history),
          ),
          _NavItem(
            icon: Icons.description_outlined,
            label: 'Templates',
            active: _active == _NavSection.templates,
            onTap: () => setState(() => _active = _NavSection.templates),
          ),
          _NavItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            active: _active == _NavSection.settings,
            onTap: () {
              setState(() => _active = _NavSection.settings);
              showDialog(
                context: context,
                builder: (_) => const SettingsDialog(),
              ).then((_) {
                if (mounted) setState(() => _active = _NavSection.newReadme);
              });
            },
          ),
        ],
      ),
    );
  }

  // ── Recent label ───────────────────────────────────────────────────────────
  Widget _buildRecentLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
      child: Text(
        'RECENT',
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.outlineVariant,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  // ── Chat list ──────────────────────────────────────────────────────────────
  Widget _buildChatList() {
    return Consumer<AppController>(
      builder: (ctx, ctrl, _) {
        final chats = ctrl.chats.values.toList().reversed.toList();
        if (chats.isEmpty) {
          return Center(
            child: Text(
              'Cap xat encara',
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.outlineVariant),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: chats.length,
          itemBuilder: (_, i) => _ChatItem(
            chat:     chats[i],
            isActive: chats[i].id == ctrl.currentChatId,
          ),
        );
      },
    );
  }

  // ── Pro upgrade card ───────────────────────────────────────────────────────
  Widget _buildProCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:        AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PRO FEATURES',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Advanced templates and private repo support.',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.slate600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'Upgrade to Pro',
                  style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── User profile ───────────────────────────────────────────────────────────
  Widget _buildUserProfile() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.surfaceContainerHigh,
            child: const Icon(Icons.person_rounded,
                size: 17, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Developer',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate900,
                ),
              ),
              Text(
                'Free Tier',
                style: GoogleFonts.inter(
                    fontSize: 10, color: const Color(0xFF64748B)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────

enum _NavSection { newReadme, history, templates, settings }

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color:        active ? AppColors.primary.withOpacity(0.07) : null,
          borderRadius: BorderRadius.circular(12),
          border: active
              ? Border(
                  right: BorderSide(
                    color: AppColors.primary, width: 2))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: active
                    ? AppColors.primary
                    : const Color(0xFF64748B)),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? AppColors.primary : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatItem extends StatelessWidget {
  final Chat chat;
  final bool isActive;

  const _ChatItem({required this.chat, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<AppController>();
    return InkWell(
      onTap: () => ctrl.switchChat(chat.id),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color:        isActive ? AppColors.primary.withOpacity(0.08) : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                chat.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: () => ctrl.deleteChat(chat.id),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Icon(Icons.close_rounded,
                    size: 14, color: AppColors.outlineVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
