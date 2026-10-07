class TileEntity {
  final int id;
  int value;
  int row;
  int col;
  bool isNew;
  bool isMerged;

  TileEntity({
    required this.id,
    required this.value,
    required this.row,
    required this.col,
    this.isNew = false,
    this.isMerged = false,
  });
}
