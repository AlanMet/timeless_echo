import 'package:flutter/material.dart';
import 'package:timeless_echo/notifier.dart';

class TextInput extends StatefulWidget {
  const TextInput({super.key});

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  final TextEditingController textController = TextEditingController();
  final _focusNode = FocusNode();
  Controller controller = Controller();

  void _processInput() {
    String input = textController.text.trim();
    textController.clear();
    if (input.isNotEmpty) {
      List<String> commands = input.split(' ');
      print("Processing commands : $commands");
      Controller().game.processCommand(commands);
      textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(100, 0, 100, 0),
      child: Expanded(
        child: TextField(
          controller: textController,
          focusNode: _focusNode,
          onSubmitted: (value) {
            _processInput();
            _focusNode.requestFocus();
          },
          decoration: InputDecoration(
            hintText: 'Enter command',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: controller
                    .theme.theme.colorScheme.onSurface, // Default border color
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: controller
                    .theme.theme.colorScheme.primary, // Focused border color
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: controller.theme.theme.colorScheme
                    .onSurface, // Border color when enabled
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: controller
                    .theme.theme.colorScheme.error, // Error state border color
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: controller.theme.theme.colorScheme
                    .error, // Error state border when focused
              ),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                _processInput();
                _focusNode.requestFocus();
              },
            ),
          ),
          style: TextStyle(
            color: controller.theme.theme.colorScheme
                .onSurface, // Text color matches onSurface color
          ),
        ),
      ),
    );
  }
}
