import 'package:flutter/material.dart';
import 'dart:async';
import 'package:timeless_echo/notifier.dart';
// ignore: unused_import
import 'package:provider/provider.dart';

class TypingText extends StatefulWidget {
  final String text;
  final Duration speed;
  final Controller uiController;

  const TypingText(
      {super.key,
      required this.text,
      this.speed = const Duration(milliseconds: 75),
      required this.uiController});

  @override
  State<TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText> {
  String _currentText = '';
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _typeText();
  }

  @override
  void didUpdateWidget(TypingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _currentText = '';
      _typeText();
    }
  }

  void _typeText() {
    _typingTimer?.cancel();
    _typingTimer = Timer.periodic(widget.speed, (timer) {
      if (_currentText.length < widget.text.length) {
        setState(() {
          _currentText += widget.text[_currentText.length];
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft, // Align the text to the left
      child: Text(
        _currentText,
        style: TextStyle(
          fontSize: 24,
          color: widget.uiController.theme.theme.colorScheme.tertiary,
        ),
        overflow: TextOverflow.visible, // No overflow issues
        textAlign: TextAlign.left, // Ensure text starts from the left
      ),
    );
  }
}
