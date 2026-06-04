import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/piece.dart';
import '../models/position.dart';
import '../models/chess_rules.dart';
import '../models/log_entry.dart';

enum GamePhase { selecting, roulette, gameOver }

class GameState extends ChangeNotifier {
  late List<List<ChessPiece?>> board;
  PieceColor turn = PieceColor.white;
  GamePhase phase = GamePhase.selecting;
  Position? selectedPos;
  List<Position> validMoves = [];
  List<ChessPiece> capturedByWhite = [];
  List<ChessPiece> capturedByBlack = [];
  List<LogEntry> log = [];
  Position? lastFrom;
  Position? lastTo;
  bool rouletteResult = false;
  ChessPiece? roulettePiece;
  Position? roulettePos;
  int rouletteDieNumber = 1;
  String? winner;
  bool isInCheck = false;
  final _random = Random();

  // Вероятность смерти 1/3
  static const int _rouletteChance = 3;

  GameState() {
    _initBoard();
  }

  void _initBoard() {
    board = List.generate(8, (_) => List.filled(8, null));
    final backRow = [
      PieceType.rook, PieceType.knight, PieceType.bishop, PieceType.queen,
      PieceType.king, PieceType.bishop, PieceType.knight, PieceType.rook
    ];
    for (var c = 0; c < 8; c++) {
      board[0][c] = ChessPiece(type: backRow[c], color: PieceColor.black);
      board[1][c] = ChessPiece(type: PieceType.pawn, color: PieceColor.black);
      board[6][c] = ChessPiece(type: PieceType.pawn, color: PieceColor.white);
      board[7][c] = ChessPiece(type: backRow[c], color: PieceColor.white);
    }
  }

  void selectOrMove(Position pos) {
    if (phase != GamePhase.selecting) return;
    final piece = board[pos.row][pos.col];

    if (selectedPos != null && validMoves.contains(pos)) {
      _executeMove(selectedPos!, pos);
      return;
    }

    if (piece != null && piece.color == turn) {
      selectedPos = pos;
      validMoves = ChessRules.getValidMoves(board, pos);
    } else {
      selectedPos = null;
      validMoves = [];
    }
    notifyListeners();
  }

  void _executeMove(Position from, Position to) {
    final piece = board[from.row][from.col]!;
    final target = board[to.row][to.col];

    if (target != null) {
      if (turn == PieceColor.white) capturedByWhite.add(target);
      else capturedByBlack.add(target);
      log.insert(0, LogEntry('${piece.symbol} берёт ${target.symbol} на ${to.algebraic}', LogType.capture));
    } else {
      log.insert(0, LogEntry('${piece.symbol} ${from.algebraic} → ${to.algebraic}', LogType.move));
    }

    // Пешка в ферзя
    ChessPiece movedPiece = piece;
    if (piece.type == PieceType.pawn) {
      if ((piece.color == PieceColor.white && to.row == 0) ||
          (piece.color == PieceColor.black && to.row == 7)) {
        movedPiece = ChessPiece(type: PieceType.queen, color: piece.color);
        log.insert(0, LogEntry('Пешка → Ферзь! ${movedPiece.symbol}', LogType.move));
      }
    }

    board[to.row][to.col] = movedPiece;
    board[from.row][from.col] = null;
    lastFrom = from;
    lastTo = to;
    selectedPos = null;
    validMoves = [];

    if (movedPiece.isImmune) {
      log.insert(0, LogEntry('${movedPiece.symbol} иммунитет — рулетка пропущена', LogType.rouletteAlive));
      _afterMove();
    } else {
      phase = GamePhase.roulette;
      roulettePiece = movedPiece;
      roulettePos = to;
    }
    notifyListeners();
  }

  void resolveRoulette() {
    if (roulettePos == null || roulettePiece == null) return;
    // 1/3 шанс смерти
    final roll = _random.nextInt(_rouletteChance);
    rouletteDieNumber = roll + 1;
    rouletteResult = roll == 0;

    if (rouletteResult) {
      board[roulettePos!.row][roulettePos!.col] = null;
      log.insert(0, LogEntry(
        '☠️ ${roulettePiece!.symbol} выпало $rouletteDieNumber/$_rouletteChance — ПОГИБЛА!',
        LogType.rouletteDead,
      ));
    } else {
      log.insert(0, LogEntry(
        '✅ ${roulettePiece!.symbol} выпало $rouletteDieNumber/$_rouletteChance — выжила',
        LogType.rouletteAlive,
      ));
    }

    // Проверка: король жив?
    if (!ChessRules.isKingAlive(board, PieceColor.white) ||
        !ChessRules.isKingAlive(board, PieceColor.black)) {
      final whiteAlive = ChessRules.isKingAlive(board, PieceColor.white);
      winner = whiteAlive ? 'Белые' : 'Чёрные';
      phase = GamePhase.gameOver;
      log.insert(0, LogEntry('🏆 Победа: $winner! (король убит рулеткой)', LogType.gameOver));
      notifyListeners();
      return;
    }

    _afterMove();
    notifyListeners();
  }

  void _afterMove() {
    final nextTurn = turn == PieceColor.white ? PieceColor.black : PieceColor.white;

    // Проверка шаха для следующего игрока
    final nextInCheck = ChessRules.isInCheck(board, nextTurn);
    final hasLegal = ChessRules.hasAnyLegalMove(board, nextTurn);

    if (!hasLegal) {
      if (nextInCheck) {
        // Мат
        winner = turn == PieceColor.white ? 'Белые' : 'Чёрные';
        phase = GamePhase.gameOver;
        log.insert(0, LogEntry('🏆 МАТ! Победа: $winner!', LogType.gameOver));
      } else {
        // Пат — ничья
        winner = 'Ничья (пат)';
        phase = GamePhase.gameOver;
        log.insert(0, LogEntry('🤝 Пат — ничья!', LogType.gameOver));
      }
      notifyListeners();
      return;
    }

    turn = nextTurn;
    isInCheck = nextInCheck;

    if (nextInCheck) {
      log.insert(0, LogEntry('⚠️ ШАХ! ${turn == PieceColor.white ? "Белый" : "Чёрный"} король под атакой', LogType.check));
    }

    phase = GamePhase.selecting;
    roulettePiece = null;
    roulettePos = null;
    notifyListeners();
  }

  void resetGame() {
    board = List.generate(8, (_) => List.filled(8, null));
    turn = PieceColor.white;
    phase = GamePhase.selecting;
    selectedPos = null;
    validMoves = [];
    capturedByWhite = [];
    capturedByBlack = [];
    log = [];
    lastFrom = null;
    lastTo = null;
    rouletteResult = false;
    roulettePiece = null;
    roulettePos = null;
    winner = null;
    isInCheck = false;
    _initBoard();
    notifyListeners();
  }
}
