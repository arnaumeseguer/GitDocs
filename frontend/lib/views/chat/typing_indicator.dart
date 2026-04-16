import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

/// Three bouncing dots that replicate the typing indicator from the design.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});
  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      final c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1350),
      );
      Future.delayed(Duration(milliseconds: i * 160), () {
        if (mounted) c.repeat();
      });
      return c;
    });

    _anims = _controllers.map((c) {
      return Tween<double>(begin: 0, end: -6).animate(
        CurvedAnimation(
          parent: c,
          curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Padding(
          padding: EdgeInsets.only(right: i < 2 ? 5 : 0),
          child: AnimatedBuilder(
            animation: _anims[i],
            builder: (_, __) => Transform.translate(
              offset: Offset(0, _anims[i].value),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color:        AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
