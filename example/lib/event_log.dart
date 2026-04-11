import 'package:flutter/material.dart';

/// A compact, auto-scrolling event log widget.
///
/// Obtain a [GlobalKey<EventLogState>] and call [EventLogState.add] to append
/// entries from outside the widget tree.
class EventLog extends StatefulWidget {
  const EventLog({super.key, this.maxEntries = 20, this.height = 120});

  final int maxEntries;
  final double height;

  @override
  State<EventLog> createState() => EventLogState();
}

class EventLogState extends State<EventLog> {
  final List<String> _entries = [];
  final ScrollController _scroll = ScrollController();

  void add(String message) {
    setState(() {
      _entries.insert(0, message);
      if (_entries.length > widget.maxEntries) {
        _entries.removeLast();
      }
    });
  }

  void clear() {
    setState(() => _entries.clear());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: widget.height,
      child: _entries.isEmpty
          ? Center(
              child: Text(
                'No events yet',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: _entries.length,
              itemBuilder: (_, i) => Text(
                _entries[i],
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontFamily: 'monospace',
                ),
              ),
            ),
    );
  }
}
