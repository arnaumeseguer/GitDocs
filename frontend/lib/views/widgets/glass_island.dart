import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

/// Reusable "floating island" widget that replicates the glass morphism effect
/// from stitch_ai: white/80% opacity + backdrop blur + ambient shadow.
class GlassIsland extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool border;
  final bool ambientShadow;
  final Color? color;

  const GlassIsland({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.border       = true,
    this.ambientShadow = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final r = borderRadius ?? BorderRadius.circular(16);
    return Container(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: ambientShadow
            ? const [
                BoxShadow(
                  color:       AppColors.ambientShadow,
                  blurRadius:  60,
                  spreadRadius: -15,
                  offset:      Offset(0, 40),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color:        color ?? Colors.white.withOpacity(0.8),
              borderRadius: r,
              border: border
                  ? Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1,
                    )
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
