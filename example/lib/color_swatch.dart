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
        // Use ARGB integer for a stable hex label that doesn't rely on
        // deprecated Color.value.
        final int argb = color.toARGB32();
        final String hex =
            '#${argb.toRadixString(16).padLeft(8, '0').toUpperCase()}';
        return Semantics(
          button: true,
          selected: isSelected,
          label: 'Select color $hex',
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkResponse(
              onTap: () => onChanged(color),
              containedInkWell: true,
              customBorder: const CircleBorder(),
              radius: 20,
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
            ),
          ),
        );
      }).toList(),
    );
  }
}
