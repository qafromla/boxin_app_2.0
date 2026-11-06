import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// "//" red slashes + BOXING TIMER wordmark.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 30});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(size * 1.9, size * 1.5),
          painter: _SlashesPainter(),
        ),
        SizedBox(width: size * 0.3),
        Text(
          'BOXING\nTIMER',
          style: TextStyle(
            fontSize: size,
            height: 0.95,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: 0.5,
            color: context.textColor,
          ),
        ),
      ],
    );
  }
}

class _SlashesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.red;
    final w = size.width;
    final h = size.height;
    final stripe = w * 0.26;
    for (var i = 0; i < 3; i++) {
      final x = i * w * 0.3;
      final path =
          Path()
            ..moveTo(x + stripe * 1.4, 0)
            ..lineTo(x + stripe * 1.4 + stripe, 0)
            ..lineTo(x + stripe, h)
            ..lineTo(x, h)
            ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Big red button ("Start Workout", "Save & Start").
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.play_arrow_rounded,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [Color(0xFFF0322B), AppColors.redDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.red.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 30),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded card with the right background for light/dark mode.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: context.isDark ? 0 : 1,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// A row in the home screen menu: icon, title, chevron.
class MenuTile extends StatelessWidget {
  const MenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: context.subtleTextColor),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: context.subtleTextColor),
        ],
      ),
    );
  }
}

/// Circle button with an icon and a caption under it (-30s, Pause, Stop...).
class CircleControl extends StatelessWidget {
  const CircleControl({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
    this.size = 60,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  /// Filled color. Null = neutral (card colored) button.
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final filled = color != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: label,
          child: Material(
            color: color ?? context.cardColor,
            shape: const CircleBorder(),
            elevation: filled ? 6 : (context.isDark ? 0 : 2),
            shadowColor: (color ?? Colors.black).withValues(alpha: 0.5),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: SizedBox(
                width: size,
                height: size,
                child: Icon(
                  icon,
                  size: size * 0.5,
                  color: filled ? Colors.white : context.textColor,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: filled ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Row of small squares, one per round.
class RoundSegments extends StatelessWidget {
  const RoundSegments({
    super.key,
    required this.total,
    required this.isDone,
    required this.current,
    required this.activeColor,
  });

  final int total;
  final bool Function(int round) isDone;
  final int current;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: List.generate(total, (i) {
        final round = i + 1;
        final Color color;
        if (round == current && !isDone(round)) {
          color = activeColor;
        } else if (isDone(round)) {
          color = AppColors.red.withValues(alpha: 0.55);
        } else {
          color = context.mutedColor;
        }
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

String formatTime(int seconds) {
  final m = (seconds ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
