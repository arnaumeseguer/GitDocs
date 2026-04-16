import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/app_controller.dart';
import '../../core/app_colors.dart';
import '../../models/chat.dart';
import '../widgets/glass_island.dart';
import 'readme_block.dart';
import 'typing_indicator.dart';

/// View — ChatView
/// Scrollable area that renders the welcome hero, chat messages, and typing indicator.
class ChatView extends StatefulWidget {
  const ChatView({super.key});
  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(builder: (ctx, ctrl, _) {
      final chat = ctrl.currentChat;
      _scrollToBottom();

      return ListView(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 140),
        children: [
          // ── Welcome hero ──────────────────────────────────────────────────
          if (chat == null || chat.messages.isEmpty)
            const _WelcomeHero()
          else ...[
            const SizedBox(height: 32),
            ...chat.messages.map((m) => _MessageRow(message: m)),
          ],

          // ── Typing indicator ──────────────────────────────────────────────
          if (ctrl.isLoading) ...[
            const SizedBox(height: 32),
            _AiTypingRow(),
          ],
        ],
      );
    });
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Welcome Hero
// ══════════════════════════════════════════════════════════════════════════════
class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 768),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Generate perfect documentation',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                  letterSpacing: -0.8,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Paste a GitHub URL below to analyze your codebase and '
                'generate a comprehensive README.md file in seconds.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                  height: 1.65,
                ),
              ),
              const SizedBox(height: 32),
              // Feature badges
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 24,
                children: const [
                  _FeatureBadge(icon: Icons.bolt,    label: 'Instant Analysis'),
                  _FeatureBadge(icon: Icons.shield,  label: 'Public & Private'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.6,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
              letterSpacing: -0.01,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Message Rows
// ══════════════════════════════════════════════════════════════════════════════
class _MessageRow extends StatelessWidget {
  final ChatMessage message;
  const _MessageRow({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: message.role == 'user'
          ? _UserMessageCard(message: message)
          : _AiMessageCard(message: message),
    );
  }
}

// ── User bubble ───────────────────────────────────────────────────────────────
class _UserMessageCard extends StatelessWidget {
  final ChatMessage message;
  const _UserMessageCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 512),
      child: Align(
        alignment: Alignment.centerRight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GlassIsland(
              borderRadius: const BorderRadius.only(
                topLeft:     Radius.circular(16),
                bottomLeft:  Radius.circular(16),
                bottomRight: Radius.circular(16),
                // topRight intentionally 0 → rounded-tr-none
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.link_rounded,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Analyze repository',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message.content,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.onSurface,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _timeLabel(message.timestamp),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.outlineVariant,
                letterSpacing: 0.08,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── AI bubble ─────────────────────────────────────────────────────────────────
class _AiMessageCard extends StatelessWidget {
  final ChatMessage message;
  const _AiMessageCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 768),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GlassIsland(
          borderRadius: const BorderRadius.only(
            topRight:    Radius.circular(16),
            bottomLeft:  Radius.circular(16),
            bottomRight: Radius.circular(16),
            // topLeft intentionally 0 → rounded-tl-none
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: avatar + name ─────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color:        AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded,
                        size: 15, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'README AI',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      if (message.readme != null)
                        Text(
                          'GENERATING DOCUMENTATION...',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDim,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Body text ─────────────────────────────────────────────────
              _RichText(text: message.content),

              // ── README code block ─────────────────────────────────────────
              if (message.readme != null) ...[
                const SizedBox(height: 14),
                ReadmeBlock(content: message.readme!),
                const SizedBox(height: 12),
                // Status chips
                Wrap(
                  spacing: 6,
                  children: const [
                    _Chip(label: 'Analysis complete', primary: true),
                    _Chip(label: 'Done'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AiTypingRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GlassIsland(
        borderRadius: const BorderRadius.only(
          topRight:    Radius.circular(16),
          bottomLeft:  Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(99),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  size: 13, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            const TypingIndicator(),
          ],
        ),
      ),
    );
  }
}

// ── Small helpers ─────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String label;
  final bool primary;
  const _Chip({required this.label, this.primary = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: primary
            ? AppColors.secondaryContainer
            : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.06,
          color: primary
              ? AppColors.onSecondaryContainer
              : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Simple bold-aware text: renders **bold** markdown.
class _RichText extends StatelessWidget {
  final String text;
  const _RichText({required this.text});

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    final re    = RegExp(r'\*\*(.+?)\*\*');
    int   last  = 0;
    for (final m in re.allMatches(text)) {
      if (m.start > last) {
        spans.add(TextSpan(text: text.substring(last, m.start)));
      }
      spans.add(TextSpan(
        text:  m.group(1),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ));
      last = m.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));

    return Text.rich(
      TextSpan(children: spans),
      style: GoogleFonts.inter(
          fontSize: 13,
          color: AppColors.onSurfaceVariant,
          height: 1.65),
    );
  }
}

String _timeLabel(DateTime t) {
  final h = t.hour.toString().padLeft(2, '0');
  final m = t.minute.toString().padLeft(2, '0');
  return 'Sent $h:$m';
}
