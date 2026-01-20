String formatVnd(num amount) {
  final int value = amount.round();
  final String s = value.toString();
  final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return s.replaceAllMapped(reg, (Match m) => '${m[1]}.');
}
