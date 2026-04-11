import 'package:flutter/material.dart';

/// A horizontal row of tappable color swatches.
///
/// [selected] is the currently active color. [onChanged] is called when the
/// user taps a different swatch.
class ColorSwatch extends StatelessWidget {
  const ColorSwatch({
    super.key,
    required this.selected,
    required this.onChanged,
    this.colors = _kDefaultColors,
  });

  final Color selected;
  final ValueChanged<Color> onChanged;
  final List<Color> colors;

  static const List<Color> _kDefaultColors = [
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.green,
    Colors.teal,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((color) {
        final bool isSelected = color == selected;
        return GestureDetector(
          onTap: () => onChanged(color),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.onSurface,
                      width: 3,
                    )
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
