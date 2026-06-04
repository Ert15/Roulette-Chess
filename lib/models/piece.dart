enum PieceType { king, queen, rook, bishop, knight, pawn }

enum PieceColor { white, black }

class ChessPiece {
  final PieceType type;
  final PieceColor color;

  const ChessPiece({required this.type, required this.color});

  bool get isImmune => type == PieceType.king || type == PieceType.queen;

  // Белые — контурные символы (♔♕♖♗♘♙)
  // Чёрные — залитые символы (♚♛♜♝♞♟)
  String get symbol {
    if (color == PieceColor.white) {
      switch (type) {
        case PieceType.king:   return '♔';
        case PieceType.queen:  return '♕';
        case PieceType.rook:   return '♖';
        case PieceType.bishop: return '♗';
        case PieceType.knight: return '♘';
        case PieceType.pawn:   return '♙';
      }
    } else {
      switch (type) {
        case PieceType.king:   return '♚';
        case PieceType.queen:  return '♛';
        case PieceType.rook:   return '♜';
        case PieceType.bishop: return '♝';
        case PieceType.knight: return '♞';
        case PieceType.pawn:   return '♟';
      }
    }
  }

  String get name {
    switch (type) {
      case PieceType.king:   return 'Король';
      case PieceType.queen:  return 'Ферзь';
      case PieceType.rook:   return 'Ладья';
      case PieceType.bishop: return 'Слон';
      case PieceType.knight: return 'Конь';
      case PieceType.pawn:   return 'Пешка';
    }
  }

  @override
  String toString() => '${color.name} ${type.name}';
}
