import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';

/// The README code block shown inside the AI message bubble.
/// Matches the stitch_ai snippet: 3 traffic-light dots, monospace content, pulsing line.
class ReadmeBlock extends StatefulWidget {
  final String content;
  const ReadmeBlock({super.key, required this.content});
  @override
  State<ReadmeBlock> createState() => _ReadmeBlockState();
}

class _ReadmeBlockState extends State<ReadmeBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _pulseAnim;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.04, end: 0.18).animate(_pulse);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.outlineVariant.withOpacity(0.12),
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildBody(),
          _buildPulsingLine(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Traffic-light dots
          Row(
            children: [
              _dot(AppColors.errorContainer.withOpacity(0.4)),
              const SizedBox(width: 5),
              _dot(AppColors.secondaryContainer.withOpacity(0.6)),
              const SizedBox(width: 5),
              _dot(AppColors.primaryContainer.withOpacity(0.6)),
            ],
          ),
          Row(
            children: [
              Text(
                'README.md',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.outline,
                  letterSpacing: 0.06,
                ),
              ),
              const SizedBox(width: 8),
              // Copy button
              InkWell(
                onTap: _copy,
                borderRadius: BorderRadius.circular(6),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _copied
                        ? Colors.green.withOpacity(0.1)
                        : Colors.transparent,
                    border: Border.all(
                      color: _copied
                          ? Colors.green.withOpacity(0.4)
                          : AppColors.outlineVariant.withOpacity(0.4),
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _copied ? 'Copiat!' : 'Copiar',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color:
                          _copied ? Colors.green : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 360),
      child: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: SelectableText(
            widget.content,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              height: 1.65,
              color: AppColors.onSecondaryFixedVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPulsingLine() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) => Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:        AppColors.primary.withOpacity(_pulseAnim.value),
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }

  Widget _dot(Color color) => Container(
        width: 10, height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.content));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2),
        () { if (mounted) setState(() => _copied = false); });
  }
}
