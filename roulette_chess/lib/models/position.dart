class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  bool get isValid => row >= 0 && row < 8 && col >= 0 && col < 8;

  Position operator +(Position other) => Position(row + other.row, col + other.col);

  @override
  bool operator ==(Object other) =>
      other is Position && other.row == row && other.col == col;

  @override
  int get hashCode => row * 8 + col;

  String get algebraic {
    const cols = 'abcdefgh';
    return '${cols[col]}${8 - row}';
  }

  @override
  String toString() => algebraic;
}
