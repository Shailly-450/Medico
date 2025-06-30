import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final BorderRadiusGeometry? borderRadius;
  final BoxBorder? border;

  const AppCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.borderRadius,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color ?? Colors.white,
      elevation: elevation ?? 0,
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        side: border is Border
            ? (border as Border).top // Use the top border as the side for Card
            : BorderSide(
                color: Colors.grey[200]!,
                width: 1,
              ),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(12),
        child: child,
      ),
    );
  }
} 