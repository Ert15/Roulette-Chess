enum LogType { move, capture, rouletteAlive, rouletteDead, check, gameOver }

class LogEntry {
  final String message;
  final LogType type;

  const LogEntry(this.message, this.type);
}
