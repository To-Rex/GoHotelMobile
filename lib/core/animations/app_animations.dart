import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/colors.dart';

/// Yagona harakat tili: barcha ekranlar shu konstantalar bilan "nafas oladi".
abstract class AppMotion {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration base = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration count = Duration(milliseconds: 900);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutQuint;
  static const Curve spring = Curves.elasticOut;

  static const double slideOffset = 28;
  static const Duration staggerStep = Duration(milliseconds: 55);
}

/// Fade + yuqoriga siljish bilan kirish. [index] — kaskad tartibi.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final double offset;
  final bool horizontal;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = AppMotion.slow,
    this.offset = AppMotion.slideOffset,
    this.horizontal = false,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _fade = CurvedAnimation(parent: _controller, curve: AppMotion.enter);
    final begin = widget.horizontal
        ? Offset(widget.offset / 100, 0)
        : Offset(0, widget.offset / 100);
    _slide = Tween<Offset>(begin: begin, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: AppMotion.emphasized),
    );
    Future.delayed(AppMotion.staggerStep * widget.index, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

/// Bosilganda yumshoq kichrayadigan interaktiv o'ram.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final bool haptic;

  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.97,
    this.haptic = true,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  void _set(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap == null ? null : (_) => _set(true),
      onTapCancel: () => _set(false),
      onTapUp: (_) => _set(false),
      onTap: widget.onTap == null
          ? null
          : () {
              if (widget.haptic) HapticFeedback.lightImpact();
              widget.onTap!();
            },
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: AppMotion.fast,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Raqamlar sanalib chiqadigan matn.
class AnimatedCount extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final String suffix;

  const AnimatedCount({
    super.key,
    required this.value,
    this.style,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: AppMotion.count,
      curve: AppMotion.emphasized,
      builder: (context, v, child) => Text('${v.round()}$suffix', style: style),
    );
  }
}

/// Yumshoq to'lqin bilan to'ladigan chiziqli progress.
class AnimatedProgressBar extends StatelessWidget {
  final double value; // 0..1
  final double height;
  final Color? color;
  final Color? backgroundColor;

  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: backgroundColor ?? AppColors.surfaceContainer,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
          duration: AppMotion.count,
          curve: AppMotion.emphasized,
          builder: (context, v, child) => Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: v,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(height),
                  gradient: LinearGradient(
                    colors: [
                      color ?? AppColors.primaryContainer,
                      (color ?? AppColors.primaryContainer).withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Sanovchi foiz bilan jonli aylana progress.
class AnimatedProgressRing extends StatelessWidget {
  final double value; // 0..1
  final double size;
  final double strokeWidth;
  final TextStyle? textStyle;

  const AnimatedProgressRing({
    super.key,
    required this.value,
    this.size = 72,
    this.strokeWidth = 7,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: AppMotion.count,
      curve: AppMotion.emphasized,
      builder: (context, v, child) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(v, strokeWidth),
          child: Center(
            child: Text('${(v * 100).round()}%', style: textStyle),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  _RingPainter(this.progress, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.surfaceContainer
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (progress <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
          colors: const [AppColors.primary, AppColors.secondaryContainer],
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.strokeWidth != strokeWidth;
}

/// Belgilanganda sakrab chiqadigan checkbox.
class BouncyCheck extends StatelessWidget {
  final bool checked;
  final double size;

  const BouncyCheck({super.key, required this.checked, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.base,
      curve: Curves.easeOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.36),
        border: Border.all(
          color: checked ? AppColors.primaryContainer : AppColors.outlineVariant,
          width: 2,
        ),
        color: checked ? AppColors.primaryContainer : Colors.transparent,
        boxShadow: checked
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: AnimatedScale(
        scale: checked ? 1 : 0,
        duration: const Duration(milliseconds: 450),
        curve: AppMotion.spring,
        child: Icon(Icons.check_rounded,
            size: size * 0.66, color: AppColors.onPrimary),
      ),
    );
  }
}

/// Diqqatni tortish uchun yumshoq puls (masalan, FAB tayyor bo'lganda).
class SoftPulse extends StatefulWidget {
  final Widget child;
  final bool active;

  const SoftPulse({super.key, required this.child, this.active = true});

  @override
  State<SoftPulse> createState() => _SoftPulseState();
}

class _SoftPulseState extends State<SoftPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.active) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant SoftPulse old) {
    super.didUpdateWidget(old);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.active && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.06)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: widget.child,
    );
  }
}
