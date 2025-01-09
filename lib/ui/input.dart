import 'package:flutter/material.dart';
import 'package:timeless_echo/notifier.dart';
import 'package:provider/provider.dart';

class TextInput extends StatefulWidget {
  const TextInput({super.key});

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  final TextEditingController textController = TextEditingController();
  final _focusNode = FocusNode();

  void _processInput() {
    String input = textController.text.trim();
    textController.clear();
    if (input.isNotEmpty) {
      List<String> commands = input.split(' ');
      Controller().game.processCommand(commands);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(100, 0, 100, 0),
      child: Consumer<Controller>(
        builder: (context, controller, child) {
          return Expanded(
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
                    color: controller.theme.theme.colorScheme.onSurface,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: controller.theme.theme.colorScheme.primary,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: controller.theme.theme.colorScheme.onSurface,
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
                color: controller.theme.theme.colorScheme.onSurface,
              ),
            ),
          );
        },
      ),
    );
  }
}
