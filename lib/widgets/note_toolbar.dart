import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../core/constants.dart';

class NoteToolbar extends StatelessWidget {
  const NoteToolbar({
    required this.controller,
    super.key,
  });

  final QuillController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: white,
        border: Border.all(
          color: primary,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: primary,
            offset: Offset(4, 4),
          ),
        ],
      ),
      // Simple toolbar with basic buttons
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Add your custom toolbar buttons here
            _buildToolbarButton(Icons.format_bold, () {
              controller.formatSelection(Attribute.bold);
            }),
            _buildToolbarButton(Icons.format_italic, () {
              controller.formatSelection(Attribute.italic);
            }),
            _buildToolbarButton(Icons.format_underlined, () {
              controller.formatSelection(Attribute.underline);
            }),
            _buildToolbarButton(Icons.format_strikethrough, () {
              controller.formatSelection(Attribute.strikeThrough);
            }),
            _buildToolbarButton(Icons.format_list_bulleted, () {
              controller.formatSelection(Attribute.ul);
            }),
            _buildToolbarButton(Icons.format_list_numbered, () {
              controller.formatSelection(Attribute.ol);
            }),
            _buildToolbarButton(Icons.undo, () {
              controller.undo();
            }),
            _buildToolbarButton(Icons.redo, () {
              controller.redo();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      iconSize: 20,
      constraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 40,
      ),
    );
  }
}