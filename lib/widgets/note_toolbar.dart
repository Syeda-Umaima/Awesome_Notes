import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../core/constants.dart';

class NoteToolbar extends StatelessWidget {
  const NoteToolbar({
    required this.controller,
    super.key,
  });

  final quill.QuillController controller;

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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            quill.QuillToolbarToggleStyleButton(
              attribute: quill.Attribute.bold,
              controller: controller,
            ),
            quill.QuillToolbarToggleStyleButton(
              attribute: quill.Attribute.italic,
              controller: controller,
            ),
            quill.QuillToolbarToggleStyleButton(
              attribute: quill.Attribute.underline,
              controller: controller,
            ),
            quill.QuillToolbarToggleStyleButton(
              attribute: quill.Attribute.strikeThrough,
              controller: controller,
            ),
            const VerticalDivider(),
            quill.QuillToolbarColorButton(
              controller: controller,
              isBackground: false,
            ),
            quill.QuillToolbarColorButton(
              controller: controller,
              isBackground: true,
            ),
            const VerticalDivider(),
            quill.QuillToolbarToggleStyleButton(
              attribute: quill.Attribute.ul,
              controller: controller,
            ),
            quill.QuillToolbarToggleStyleButton(
              attribute: quill.Attribute.ol,
              controller: controller,
            ),
            const VerticalDivider(),
            quill.QuillToolbarHistoryButton(
              controller: controller,
              isUndo: true,
            ),
            quill.QuillToolbarHistoryButton(
              controller: controller,
              isUndo: false,
            ),
            const VerticalDivider(),
            quill.QuillToolbarClearFormatButton(
              controller: controller,
            ),
            quill.QuillToolbarSearchButton(
              controller: controller,
            ),
          ],
        ),
      ),
    );
  }
}