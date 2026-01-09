class SeatUtils {
  static String seatLabel(int row, int col) {
    final rowChar = String.fromCharCode('A'.codeUnitAt(0) + row);
    return '$rowChar${col + 1}';
  }

  static List<String> selectedSeatLabels(Set<String> selectedSeats) {
    final labels = <String>[];
    for (final key in selectedSeats) {
      final parts = key.split('-');
      if (parts.length != 2) continue;
      final row = int.tryParse(parts[0]);
      final col = int.tryParse(parts[1]);
      if (row == null || col == null) continue;
      labels.add(seatLabel(row, col));
    }
    labels.sort(_compareSeatLabels);
    return labels;
  }

  static int _compareSeatLabels(String a, String b) {
    if (a.isEmpty || b.isEmpty) return a.compareTo(b);
    final rowA = a.codeUnitAt(0);
    final rowB = b.codeUnitAt(0);
    if (rowA != rowB) return rowA.compareTo(rowB);
    final numA = int.tryParse(a.substring(1)) ?? 0;
    final numB = int.tryParse(b.substring(1)) ?? 0;
    return numA.compareTo(numB);
  }
}
