class SeatUtils {
  static String seatLabel(int row, int col) {
    final rowChar = String.fromCharCode('A'.codeUnitAt(0) + row);
    return '$rowChar${col + 1}';
  }

  static List<String> selectedSeatLabels(Set<String> selectedSeats) {
    final labels = selectedSeats.map((id) {
      final parts = id.split('-');
      final r = int.parse(parts[0]);
      final c = int.parse(parts[1]);
      return seatLabel(r, c);
    }).toList();

    labels.sort((a, b) {
      final rowA = a.codeUnitAt(0);
      final rowB = b.codeUnitAt(0);
      if (rowA != rowB) return rowA.compareTo(rowB);
      final numA = int.parse(a.substring(1));
      final numB = int.parse(b.substring(1));
      return numA.compareTo(numB);
    });

    return labels;
  }
}
