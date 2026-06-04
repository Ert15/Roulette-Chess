import 'piece.dart';
import 'position.dart';

class ChessRules {
  // Возвращает легальные ходы (с фильтром на шах своему королю)
  static List<Position> getValidMoves(
    List<List<ChessPiece?>> board,
    Position from,
  ) {
    final piece = board[from.row][from.col];
    if (piece == null) return [];

    final pseudoMoves = _getPseudoMoves(board, from, piece);

    // Фильтруем ходы, которые оставляют своего короля под шахом
    return pseudoMoves.where((to) {
      final simBoard = _simulateMove(board, from, to);
      return !isInCheck(simBoard, piece.color);
    }).toList();
  }

  // Проверить, стоит ли цвет color под шахом
  static bool isInCheck(List<List<ChessPiece?>> board, PieceColor color) {
    final kingPos = _findKing(board, color);
    if (kingPos == null) return false;

    final opponent = color == PieceColor.white ? PieceColor.black : PieceColor.white;

    for (var r = 0; r < 8; r++) {
      for (var c = 0; c < 8; c++) {
        final p = board[r][c];
        if (p != null && p.color == opponent) {
          final attacks = _getPseudoMoves(board, Position(r, c), p);
          if (attacks.contains(kingPos)) return true;
        }
      }
    }
    return false;
  }

  // Есть ли у цвета хоть один легальный ход
  static bool hasAnyLegalMove(List<List<ChessPiece?>> board, PieceColor color) {
    for (var r = 0; r < 8; r++) {
      for (var c = 0; c < 8; c++) {
        final p = board[r][c];
        if (p != null && p.color == color) {
          if (getValidMoves(board, Position(r, c)).isNotEmpty) return true;
        }
      }
    }
    return false;
  }

  static Position? _findKing(List<List<ChessPiece?>> board, PieceColor color) {
    for (var r = 0; r < 8; r++) {
      for (var c = 0; c < 8; c++) {
        final p = board[r][c];
        if (p != null && p.type == PieceType.king && p.color == color) {
          return Position(r, c);
        }
      }
    }
    return null;
  }

  // Симулировать ход и вернуть новую доску
  static List<List<ChessPiece?>> _simulateMove(
    List<List<ChessPiece?>> board,
    Position from,
    Position to,
  ) {
    final sim = List.generate(8, (r) => List<ChessPiece?>.from(board[r]));
    sim[to.row][to.col] = sim[from.row][from.col];
    sim[from.row][from.col] = null;
    return sim;
  }

  // Псевдо-ходы без проверки шаха (для расчёта атак)
  static List<Position> _getPseudoMoves(
    List<List<ChessPiece?>> board,
    Position from,
    ChessPiece piece,
  ) {
    final moves = <Position>[];
    switch (piece.type) {
      case PieceType.pawn:
        _getPawnMoves(board, from, piece, moves);
        break;
      case PieceType.rook:
        _getSlidingMoves(board, from, piece, moves, [
          const Position(1, 0), const Position(-1, 0),
          const Position(0, 1), const Position(0, -1),
        ]);
        break;
      case PieceType.bishop:
        _getSlidingMoves(board, from, piece, moves, [
          const Position(1, 1), const Position(1, -1),
          const Position(-1, 1), const Position(-1, -1),
        ]);
        break;
      case PieceType.queen:
        _getSlidingMoves(board, from, piece, moves, [
          const Position(1, 0), const Position(-1, 0),
          const Position(0, 1), const Position(0, -1),
          const Position(1, 1), const Position(1, -1),
          const Position(-1, 1), const Position(-1, -1),
        ]);
        break;
      case PieceType.knight:
        _getKnightMoves(board, from, piece, moves);
        break;
      case PieceType.king:
        _getKingMoves(board, from, piece, moves);
        break;
    }
    return moves;
  }

  static void _getPawnMoves(
    List<List<ChessPiece?>> board,
    Position from,
    ChessPiece piece,
    List<Position> moves,
  ) {
    final dir = piece.color == PieceColor.white ? -1 : 1;
    final startRow = piece.color == PieceColor.white ? 6 : 1;

    final oneStep = Position(from.row + dir, from.col);
    if (oneStep.isValid && board[oneStep.row][oneStep.col] == null) {
      moves.add(oneStep);
      if (from.row == startRow) {
        final twoStep = Position(from.row + 2 * dir, from.col);
        if (board[twoStep.row][twoStep.col] == null) moves.add(twoStep);
      }
    }

    for (final dc in [-1, 1]) {
      final capture = Position(from.row + dir, from.col + dc);
      if (capture.isValid) {
        final target = board[capture.row][capture.col];
        if (target != null && target.color != piece.color) {
          moves.add(capture);
        }
      }
    }
  }

  static void _getSlidingMoves(
    List<List<ChessPiece?>> board,
    Position from,
    ChessPiece piece,
    List<Position> moves,
    List<Position> directions,
  ) {
    for (final dir in directions) {
      var pos = from + dir;
      while (pos.isValid) {
        final target = board[pos.row][pos.col];
        if (target != null) {
          if (target.color != piece.color) moves.add(pos);
          break;
        }
        moves.add(pos);
        pos = pos + dir;
      }
    }
  }

  static void _getKnightMoves(
    List<List<ChessPiece?>> board,
    Position from,
    ChessPiece piece,
    List<Position> moves,
  ) {
    const offsets = [
      Position(-2, -1), Position(-2, 1),
      Position(-1, -2), Position(-1, 2),
      Position(1, -2),  Position(1, 2),
      Position(2, -1),  Position(2, 1),
    ];
    for (final offset in offsets) {
      final pos = from + offset;
      if (pos.isValid) {
        final target = board[pos.row][pos.col];
        if (target == null || target.color != piece.color) moves.add(pos);
      }
    }
  }

  static void _getKingMoves(
    List<List<ChessPiece?>> board,
    Position from,
    ChessPiece piece,
    List<Position> moves,
  ) {
    const offsets = [
      Position(-1, -1), Position(-1, 0), Position(-1, 1),
      Position(0, -1),                   Position(0, 1),
      Position(1, -1),  Position(1, 0),  Position(1, 1),
    ];
    for (final offset in offsets) {
      final pos = from + offset;
      if (pos.isValid) {
        final target = board[pos.row][pos.col];
        if (target == null || target.color != piece.color) moves.add(pos);
      }
    }
  }

  static bool isKingAlive(List<List<ChessPiece?>> board, PieceColor color) {
    return _findKing(board, color) != null;
  }
}
