import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/app_controller.dart';
import '../../core/app_colors.dart';
import '../widgets/glass_island.dart';

/// View — InputIsland
/// Floating bottom bar: link icon + text input + divider + Generate button.
/// Matches the stitch_ai floating input area exactly.
class InputIsland extends StatefulWidget {
  const InputIsland({super.key});
  @override
  State<InputIsland> createState() => _InputIslandState();
}

class _InputIslandState extends State<InputIsland> {
  final _controller = TextEditingController();
  final _focus      = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _send(AppController ctrl) {
    final text = _controller.text.trim();
    if (text.isEmpty || ctrl.isLoading) return;
    _controller.clear();
    ctrl.sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (ctx, ctrl, _) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 768),
              child: GlassIsland(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    // Link icon button
                    _IconBtn(
                      icon: Icons.link_rounded,
                      onTap: () {},
                    ),
                    const SizedBox(width: 4),

                    // Text input
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode:  _focus,
                        maxLines:   4,
                        minLines:   1,
                        enabled:   !ctrl.isLoading,
                        onSubmitted: (_) => _send(ctrl),
                        decoration: InputDecoration(
                          hintText: 'Paste GitHub repository URL...',
                          hintStyle: GoogleFonts.inter(
                            fontSize:  14,
                            color:     AppColors.outlineVariant,
                          ),
                          border:         InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 4),
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color:    AppColors.onSurface,
                        ),
                      ),
                    ),

                    // Divider
                    Container(
                      width:  1,
                      height: 28,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color:  AppColors.surfaceContainerHigh,
                    ),

                    // Generate button
                    _GenerateBtn(
                      loading: ctrl.isLoading,
                      onTap:   () => _send(ctrl),
                    ),
                  ],
                ),
              ),
            ),

            // Feature indicators
            const SizedBox(height: 10),
            Opacity(
              opacity: 0.6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _FeatureHint(icon: Icons.bolt,   label: 'Instant Analysis'),
                  const SizedBox(width: 24),
                  _FeatureHint(icon: Icons.shield, label: 'Public & Private'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
      ),
    );
  }
}

class _GenerateBtn extends StatefulWidget {
  final bool loading;
  final VoidCallback onTap;
  const _GenerateBtn({required this.loading, required this.onTap});
  @override
  State<_GenerateBtn> createState() => _GenerateBtnState();
}

class _GenerateBtnState extends State<_GenerateBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scale;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scale = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.93).animate(
        CurvedAnimation(parent: _scale, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scale.forward(),
      onTapUp:   (_) { _scale.reverse(); widget.onTap(); },
      onTapCancel: () => _scale.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            gradient: widget.loading
                ? null
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end:   Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDim],
                  ),
            color: widget.loading ? AppColors.surfaceContainerHigh : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: widget.loading
              ? const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Generate',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.send_rounded,
                        size: 14, color: Colors.white),
                  ],
                ),
        ),
      ),
    );
  }
}

class _FeatureHint extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureHint({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
