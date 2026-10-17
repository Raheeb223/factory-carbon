import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Gradient hero block with soft decorative circles. Used at the top of the main
/// screens so each one has a clear, friendly identity.
class HeroHeader extends StatelessWidget {
  const HeroHeader({
    super.key,
    required this.child,
    this.gradient = BrandGradients.primary,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 24),
    this.safeTop = true,
    this.radius = 28,
  });

  final Widget child;
  final Gradient gradient;
  final EdgeInsets padding;
  final bool safeTop;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final top = safeTop ? MediaQuery.paddingOf(context).top : 0.0;
    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(radius)),
      child: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: Stack(
          children: [
            const Positioned(right: -40, top: -50, child: _Circle(size: 180, alpha: 0.10)),
            const Positioned(right: 60, bottom: -70, child: _Circle(size: 140, alpha: 0.07)),
            const Positioned(left: -30, bottom: -40, child: _Circle(size: 100, alpha: 0.06)),
            Padding(
              padding: padding.copyWith(top: padding.top + top),
              child: DefaultTextStyle.merge(
                style: const TextStyle(color: Colors.white),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.alpha});
  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: alpha),
    ),
  );
}

/// Title + subtitle + big icon, for the top of a tab (Bills, Reports, Solar, Settings).
class PageHero extends StatelessWidget {
  const PageHero({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.gradient = BrandGradients.primary,
    this.trailing,
    this.bottom,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final Widget? trailing;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return HeroHeader(
      gradient: gradient,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: t.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: t.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.88))),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              trailing ??
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(16)),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
            ],
          ),
          if (bottom != null) ...[const SizedBox(height: 16), bottom!],
        ],
      ),
    );
  }
}

/// Rounded square with a tinted background and a coloured icon.
class IconBlob extends StatelessWidget {
  const IconBlob(this.icon, {super.key, required this.color, this.size = 44, this.filled = false});
  final IconData icon;
  final Color color;
  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: filled ? color : color.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(size * 0.32)),
    child: Icon(icon, color: filled ? Colors.white : color, size: size * 0.52),
  );
}

/// White rounded card with a soft shadow. Optional tap and gradient.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(vertical: 6),
    this.onTap,
    this.color,
    this.gradient,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final VoidCallback? onTap;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(22);
    return Padding(
      padding: margin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: gradient == null ? (color ?? scheme.surface) : null,
          gradient: gradient,
          borderRadius: radius,
          border: Border.all(color: borderColor ?? scheme.outlineVariant.withValues(alpha: dark ? 0.35 : 0.35)),
          boxShadow: dark ? null : [BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.05), blurRadius: 18, offset: const Offset(0, 6))],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

/// A feature shortcut: coloured icon, title and one-line explanation.
class FeatureTile extends StatelessWidget {
  const FeatureTile({super.key, required this.icon, required this.color, required this.title, this.subtitle, required this.onTap});
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SoftCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconBlob(icon, color: color, size: 42),
          const SizedBox(height: 10),
          Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: t.titleSmall?.copyWith(height: 1.2)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: t.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

/// Translucent stat chip for use on top of a gradient.
class GlassStat extends StatelessWidget {
  const GlassStat({super.key, required this.value, required this.label, this.onTap});
  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Material(
      color: Colors.white.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Small rounded label with icon, e.g. "Connected".
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.text, required this.color, this.icon, this.onDark = false});
  final String text;
  final Color color;
  final IconData? icon;
  final bool onDark;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: onDark ? Colors.white.withValues(alpha: 0.18) : color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 14, color: onDark ? Colors.white : color), const SizedBox(width: 5)],
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: onDark ? Colors.white : color),
          ),
        ),
      ],
    ),
  );
}

/// Section heading with optional trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.text, {super.key, this.action, this.padding = const EdgeInsets.fromLTRB(4, 20, 4, 8)});
  final String text;
  final Widget? action;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: Row(
      children: [
        Expanded(child: Text(text, style: Theme.of(context).textTheme.titleMedium)),
        ?action,
      ],
    ),
  );
}

/// Big gradient call-to-action button card.
class ActionBanner extends StatelessWidget {
  const ActionBanner({super.key, required this.icon, required this.title, required this.subtitle, required this.onTap, this.gradient = BrandGradients.bills});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GradientSurface(
        gradient: gradient,
        radius: 24,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(18)),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: t.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.arrow_forward_rounded, color: gradient.colors[1], size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tappable gradient surface with a soft coloured glow. The glow is painted outside
/// the ink layer so it is never clipped into a visible rectangle.
class GradientSurface extends StatelessWidget {
  const GradientSurface({super.key, required this.gradient, required this.child, this.onTap, this.radius = 22, this.inkKey});
  final Gradient gradient;
  final Widget child;
  final VoidCallback? onTap;
  final double radius;
  final Key? inkKey;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: r,
        boxShadow: dark ? null : [BoxShadow(color: gradient.colors[1].withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: r,
        clipBehavior: Clip.antiAlias,
        child: InkWell(key: inkKey, onTap: onTap, child: child),
      ),
    );
  }
}

/// Horizontal bar split into coloured parts (e.g. Scope 1 vs Scope 2).
class SplitBar extends StatelessWidget {
  const SplitBar({super.key, required this.parts, this.height = 10});
  final List<(double, Color)> parts;
  final double height;

  @override
  Widget build(BuildContext context) {
    final total = parts.fold<double>(0, (s, p) => s + p.$1);
    if (total <= 0) return SizedBox(height: height);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (v, c) in parts)
              if (v > 0)
                Expanded(
                  flex: (v / total * 1000).round().clamp(1, 1000),
                  child: ColoredBox(color: c),
                ),
          ],
        ),
      ),
    );
  }
}

/// Legend dot + label.
class LegendDot extends StatelessWidget {
  const LegendDot({super.key, required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
      ),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
    ],
  );
}

/// Slide-up + fade-in on first build, for a lively first impression.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.child, this.delayMs = 0});
  final Widget child;
  final int delayMs;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: Duration(milliseconds: 420 + delayMs),
    curve: Interval(delayMs / (420 + delayMs), 1, curve: Curves.easeOutCubic),
    builder: (context, v, child) => Opacity(
      opacity: v,
      child: Transform.translate(offset: Offset(0, (1 - v) * 18), child: child),
    ),
    child: child,
  );
}

/// Keeps the phone's status bar readable on pages whose hero header scrolls away: a band
/// in the brand colours stays behind the clock and battery icons. At the top of the page
/// it blends into the header.
class StatusBarScrim extends StatelessWidget {
  const StatusBarScrim({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Stack(children: [
      child,
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: top,
        child: const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF064E3B), Color(0xFF0F766E), Color(0xFF14B8A6)])),
          ),
        ),
      ),
    ]);
  }
}
