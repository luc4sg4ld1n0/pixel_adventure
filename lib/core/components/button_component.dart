import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class ButtonComponent extends Component with TapCallbacks {
  final String text;
  final VoidCallback onPressed;
  final Vector2 position;
  final Vector2 size;
  final Color normalColor;
  final Color pressedColor;
  final double opacity;
  final double borderRadius;
  bool _isPressed = false;

  ButtonComponent({
    required this.position,
    required this.size,
    required this.text,
    required this.onPressed,
    this.normalColor = const Color(0xFF1a535c),
    this.pressedColor = const Color(0xFF0f3a42),
    this.opacity = 0.8,
    this.borderRadius = 16.0,
  });

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(
      position.x - size.x / 2,
      position.y - size.y / 2,
      size.x,
      size.y,
    );

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    final currentColor = _isPressed ? pressedColor : normalColor;
    final paint = Paint()..color = _withOpacity(currentColor, opacity);

    canvas.drawRRect(rrect, paint);

    final textPaint = TextPaint(
      style: const TextStyle(
        fontSize: 20,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );

    textPaint.render(canvas, text, position, anchor: Anchor.center);
  }

  Color _withOpacity(Color color, double opacity) {
    return Color.lerp(Colors.transparent, color, opacity)!;
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    final rect = Rect.fromCenter(
      center: Offset(position.x, position.y),
      width: size.x,
      height: size.y,
    );

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    return rrect.contains(Offset(point.x, point.y));
  }

  @override
  void onTapDown(TapDownEvent event) {
    _isPressed = true;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPressed = false;
    onPressed();
    super.onTapUp(event);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _isPressed = false;
    super.onTapCancel(event);
  }
}
