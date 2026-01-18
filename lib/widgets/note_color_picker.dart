// lib/widgets/note_color_picker.dart
import 'package:flutter/material.dart';

class NoteColorPicker extends StatelessWidget {
  final int selectedColorIndex;
  final Function(int) onColorSelected;

  const NoteColorPicker({
    super.key,
    required this.selectedColorIndex,
    required this.onColorSelected,
  });

  static const List<Color> noteColors = [
    Color(0xFFFFFFFF), // White (default)
    Color(0xFFFFF9C4), // Light Yellow
    Color(0xFFFFCCBC), // Light Orange
    Color(0xFFF8BBD0), // Light Pink
    Color(0xFFE1BEE7), // Light Purple
    Color(0xFFBBDEFB), // Light Blue
    Color(0xFFB2DFDB), // Light Teal
    Color(0xFFC8E6C9), // Light Green
    Color(0xFFD7CCC8), // Light Brown
    Color(0xFFCFD8DC), // Light Gray
  ];

  static Color getColor(int index) {
    if (index < 0 || index >= noteColors.length) return noteColors[0];
    return noteColors[index];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette, color: Color(0xFFC39E18)),
              const SizedBox(width: 10),
              const Text(
                'Note Color',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(noteColors.length, (index) {
              final isSelected = index == selectedColorIndex;
              return GestureDetector(
                onTap: () {
                  onColorSelected(index);
                  Navigator.pop(context);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: noteColors[index],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFC39E18)
                          : Colors.grey.shade300,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFFC39E18).withAlpha(77),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Color(0xFFC39E18),
                          size: 24,
                        )
                      : null,
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
