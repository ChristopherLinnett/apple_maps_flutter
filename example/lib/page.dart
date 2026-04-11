import 'package:flutter/material.dart';

/// Base class for all demo pages.
abstract class ExamplePage extends StatelessWidget {
  const ExamplePage(this.leading, this.title, {super.key});

  final Widget leading;
  final String title;
}

// ---------------------------------------------------------------------------
// Shared layout helpers used by all map pages.
// ---------------------------------------------------------------------------

/// A map-page scaffold where the [AppleMap] fills the entire screen and
/// [controls] float in a drag-to-reveal panel at the bottom.
///
/// This ensures the map occupies the centre of the screen so simulator
/// pinch-to-zoom (which anchors at the screen centre) always lands inside
/// the map rather than in a controls column below it.
class MapScaffold extends StatelessWidget {
  const MapScaffold({
    super.key,
    required this.title,
    required this.map,
    required this.controls,
    this.initialSheetSize = 0.26,
    this.minSheetSize = 0.08,
    this.maxSheetSize = 0.55,
  });

  final String title;
  final Widget map;
  final List<Widget> controls;
  final double initialSheetSize;
  final double minSheetSize;
  final double maxSheetSize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: colorScheme.surface.withValues(alpha: 0.85),
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        title: Text(title),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: map),
          DraggableScrollableSheet(
            initialChildSize: initialSheetSize,
            minChildSize: minSheetSize,
            maxChildSize: maxSheetSize,
            snap: true,
            snapSizes: [minSheetSize, initialSheetSize, maxSheetSize],
            builder: (context, scrollController) {
              return _ControlsSheet(
                scrollController: scrollController,
                children: controls,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ControlsSheet extends StatelessWidget {
  const _ControlsSheet({
    required this.scrollController,
    required this.children,
  });

  final ScrollController scrollController;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 8,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      color: colorScheme.surface,
      child: ListView(
        controller: scrollController,
        padding: EdgeInsets.zero,
        children: [
          // Drag handle
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          ...children,
          // Bottom padding so last control clears the home indicator on all
          // devices, using the actual safe-area inset rather than a fixed value.
          SizedBox(height: MediaQuery.viewPaddingOf(context).bottom + 8),
        ],
      ),
    );
  }
}
