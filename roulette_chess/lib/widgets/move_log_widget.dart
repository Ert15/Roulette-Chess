import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/log_entry.dart';
import '../providers/game_state.dart';

class MoveLogWidget extends StatelessWidget {
  const MoveLogWidget({super.key});

  Color _colorForType(LogType type, BuildContext context) {
    switch (type) {
      case LogType.rouletteDead: return Colors.red.shade600;
      case LogType.rouletteAlive: return Colors.green.shade600;
      case LogType.capture: return Colors.orange.shade700;
      case LogType.check: return Colors.red.shade400;
      case LogType.gameOver: return Colors.purple.shade600;
      default: return Theme.of(context).colorScheme.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final log = context.select<GameState, List<LogEntry>>((g) => g.log);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Text(
              'Журнал ходов',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: log.isEmpty
                ? Center(
                    child: Text(
                      'Игра началась',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: log.length,
                    itemBuilder: (context, i) {
                      final entry = log[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        child: Text(
                          entry.message,
                          style: TextStyle(
                            fontSize: 12,
                            color: _colorForType(entry.type, context),
                            fontWeight: (entry.type == LogType.gameOver ||
                                    entry.type == LogType.rouletteDead ||
                                    entry.type == LogType.check)
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
