import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class ButtonComponent extends PositionComponent with TapCallbacks {
  final String text;
  final VoidCallback onPressed;
  final RectangleComponent background;
  final TextComponent textComponent;
  final Color normalColor;
  final Color pressedColor;

  ButtonComponent({
    required Vector2 position,
    required Vector2 size,
    required this.text,
    required this.onPressed,
    this.normalColor = const Color(0xFF1a535c),
    this.pressedColor = const Color(0xFF0f3a42),
  }) : background = RectangleComponent(
         size: size,
         paint: Paint()..color = normalColor,
       ),
       textComponent = TextComponent(
         text: text,
         textRenderer: TextPaint(
           style: const TextStyle(
             fontSize: 20,
             color: Colors.white,
             fontWeight: FontWeight.bold,
           ),
         ),
       ),
       super(position: position, size: size) {
    anchor = Anchor.center;

    // Centraliza o texto
    textComponent.anchor = Anchor.center;
    textComponent.position = Vector2(size.x / 2, size.y / 2);
  }

  @override
  FutureOr<void> onLoad() {
    add(background);
    add(textComponent);
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    background.paint.color = pressedColor;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    background.paint.color = normalColor;
    onPressed();
    super.onTapUp(event);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    background.paint.color = normalColor;
    super.onTapCancel(event);
  }
}
