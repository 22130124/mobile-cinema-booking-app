import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../../config/app_colors.dart';
import '../../model/booking/booking_price_models.dart';
import '../../model/order/OrderRequest.dart';
import '../../services/order/order_service.dart';
import '../../utils/seat_utils.dart';
import '../../screens/payment/payment_flow.dart';
import '../../screens/payment/payment_success_screen.dart';
import '../../model/movie_details/booking_seat_models.dart';

class BookingSeatController extends ChangeNotifier {
  BookingSeatController({
    required this.movieId,
    required this.userId,
    required this.showMessage,
  });

  final int movieId;
  final int userId;
  final void Function(String message) showMessage;

  static const int _fallbackPricePerSeat = 120000;
  static const String _fallbackSeatTypeName = 'Standard';
  static const String _unknownCinemaLabel = 'R\u1ea1p ch\u01b0a r\u00f5';
  int? _defaultPricePerSeat;
  int? _confirmedTotal;
  int? _discountAmount;

  final Set<String> _selectedSeats = {};
  List<List<int>> _seatLayout = [];
  final Map<String, int> _seatIdMap = {};
  final Map<String, int> _seatPriceMap = {};
  final Map<String, String> _seatTypeMap = {};
  final Map<int, Set<String>> _selectedSeatsByShowtime = {};
  final Map<int, int> _availableSeatsByShowtime = {};
  final Set<int> _loadingSeatCounts = {};
  final Set<String> _favoriteCinemas = {};
  String? _expandedCinemaKey;

  bool _isLoadingShowtimes = false;
  bool _isLoadingSeats = false;
  bool _isCreatingOrder = false;
  List<ShowtimeOption> _showtimes = [];
  DateTime? _selectedDate;
  int? _selectedShowtimeId;
  bool _disposed = false;

  bool get isLoadingShowtimes => _isLoadingShowtimes;
  bool get isLoadingSeats => _isLoadingSeats;
  bool get isCreatingOrder => _isCreatingOrder;
  List<List<int>> get seatLayout => _seatLayout;
  Set<String> get selectedSeats => _selectedSeats;
  Set<String> get favoriteCinemas => _favoriteCinemas;
  String? get expandedCinemaKey => _expandedCinemaKey;
  Map<int, int> get availableSeatsByShowtime => _availableSeatsByShowtime;
  DateTime? get selectedDate => _selectedDate;
  int? get selectedShowtimeId => _selectedShowtimeId;

  int get subtotalPrice => _calculateSubtotal(allowFallback: true) ?? 0;

  int get discountAmount => _calculateDiscountAmount();

  int get totalPrice {
    final confirmed = _confirmedTotal;
    if (confirmed != null) return confirmed;
    final total = subtotalPrice - discountAmount;
    return total < 0 ? 0 : total;
  }

  bool get isTotalEstimated {
    if (_selectedSeats.isEmpty) return false;
    if (_confirmedTotal != null) return false;
    if (_calculateSeatTotal() != null) return false;
    return _defaultPricePerSeat == null;
  }

  List<SeatTypeSummary> get seatTypeSummaries =>
      _buildSeatTypeSummaries();

  bool get canCreateOrder =>
      _selectedSeats.isNotEmpty &&
      _selectedShowtimeId != null &&
      !_isCreatingOrder;

  List<String> get selectedSeatLabels =>
      SeatUtils.selectedSeatLabels(_selectedSeats);

  List<DateTime> get availableDates {
    final dates = <DateTime>{};
    for (final showtime in _showtimes) {
      dates.add(DateTime(
        showtime.showDate.year,
        showtime.showDate.month,
        showtime.showDate.day,
      ));
    }
    final list = dates.toList();
    list.sort((a, b) => a.compareTo(b));
    return list;
  }

  List<ShowtimeOption> get showtimesForSelectedDate {
    final date = _selectedDate;
    if (date == null) return [];
    final list = _showtimes.where((s) => _isSameDate(s.showDate, date)).toList();
    list.sort((a, b) => a.startTime.compareTo(b.startTime));
    final unique = <ShowtimeOption>[];
    final seen = <String>{};
    final seenIds = <int>{};
    for (final showtime in list) {
      if (!seenIds.add(showtime.id)) continue;
      final key =
          '${showtime.startTime.toIso8601String()}|${showtime.roomName}|${showtime.cinemaName}';
      if (seen.add(key)) {
        unique.add(showtime);
      }
    }
    return unique;
  }

  List<CinemaGroup> get cinemaGroupsForSelectedDate {
    final list = showtimesForSelectedDate;
    final grouped = <String, List<ShowtimeOption>>{};
    for (final showtime in list) {
      final key = _cinemaKeyForShowtime(showtime);
      grouped.putIfAbsent(key, () => <ShowtimeOption>[]).add(showtime);
    }
    return grouped.entries.map((entry) {
      final items = List<ShowtimeOption>.from(entry.value)
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
      final first = items.first;
      final name = first.cinemaName.isNotEmpty
          ? first.cinemaName
          : _unknownCinemaLabel;
      return CinemaGroup(
        key: entry.key,
        cinemaId: first.cinemaId,
        name: name,
        address: first.cinemaAddress,
        city: first.cinemaCity,
        imageUrl: first.cinemaImageUrl,
        showtimes: items,
      );
    }).toList();
  }

  String formattedPrice(int price) {
    final s = price.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(reg, (Match m) => '${m[1]}.');
  }

  Future<void> init() async {
    await _fetchShowtimes();
  }

  Future<void> toggleSeat(int row, int col) async {
    if (_seatLayout.isEmpty) return;
    if (_seatLayout[row][col] == 1) return; // booked or held by others

    final seatKey = '$row-$col';
    final seatId = _seatIdMap[seatKey];
    if (seatId == null) {
      showMessage('Khong tim thay seatId tuong ung');
      return;
    }

    final isSelected = _selectedSeats.contains(seatKey);
    final ok = isSelected
        ? await _releaseSelectedSeats([seatId])
        : await _holdSelectedSeats([seatId]);
    if (!ok || _disposed) return;

    if (isSelected) {
      _selectedSeats.remove(seatKey);
      _seatLayout[row][col] = 0;
    } else {
      _selectedSeats.add(seatKey);
      _seatLayout[row][col] = 2;
    }
    final sid = _selectedShowtimeId;
    if (sid != null) {
      _selectedSeatsByShowtime[sid] = Set<String>.from(_selectedSeats);
    }
    _clearConfirmedTotal();
    _notify();
  }

  void toggleCinema(CinemaGroup group) {
    final isExpanded = _expandedCinemaKey == group.key;
    _expandedCinemaKey = isExpanded ? null : group.key;
    _notify();
    if (!isExpanded) {
      _prefetchSeatCountsForShowtimes(group.showtimes);
    }
  }

  void toggleFavorite(String cinemaKey) {
    if (_favoriteCinemas.contains(cinemaKey)) {
      _favoriteCinemas.remove(cinemaKey);
    } else {
      _favoriteCinemas.add(cinemaKey);
    }
    _notify();
  }

  void selectDate(DateTime date) {
    final showtimes = _showtimes.where((s) => _isSameDate(s.showDate, date)).toList();
    if (showtimes.isEmpty) return;
    showtimes.sort((a, b) => a.startTime.compareTo(b.startTime));
    final next = showtimes.first;
    final previousSelection = Set<String>.from(_selectedSeats);
    final previousShowtimeId = _selectedShowtimeId;
    if (previousShowtimeId != null) {
      _selectedSeatsByShowtime[previousShowtimeId] =
          Set<String>.from(_selectedSeats);
    }
    _selectedDate = date;
    _selectedShowtimeId = next.id;
    _expandedCinemaKey = _cinemaKeyForShowtime(next);
    _selectedSeats.clear();
    _seatIdMap.clear();
    _seatLayout = [];
    _seatPriceMap.clear();
    _seatTypeMap.clear();
    _defaultPricePerSeat = null;
    _discountAmount = null;
    _clearConfirmedTotal();
    _notify();
    _fetchSeatMap(showtimeId: next.id, carrySelection: previousSelection);
    _prefetchSeatCountsForCinema(_cinemaKeyForShowtime(next));
  }

  void selectShowtime(ShowtimeOption showtime) {
    if (_selectedShowtimeId == showtime.id) return;
    final nextDate = DateTime(
      showtime.showDate.year,
      showtime.showDate.month,
      showtime.showDate.day,
    );
    final previousSelection = Set<String>.from(_selectedSeats);
    final previousShowtimeId = _selectedShowtimeId;
    if (previousShowtimeId != null) {
      _selectedSeatsByShowtime[previousShowtimeId] =
          Set<String>.from(_selectedSeats);
    }
    _selectedDate = nextDate;
    _selectedShowtimeId = showtime.id;
    _expandedCinemaKey = _cinemaKeyForShowtime(showtime);
    _selectedSeats.clear();
    _seatIdMap.clear();
    _seatLayout = [];
    _seatPriceMap.clear();
    _seatTypeMap.clear();
    _defaultPricePerSeat = null;
    _discountAmount = null;
    _clearConfirmedTotal();
    _notify();
    _fetchSeatMap(showtimeId: showtime.id, carrySelection: previousSelection);
    _prefetchSeatCountsForCinema(_cinemaKeyForShowtime(showtime));
  }

  Future<void> createOrderAndPay(BuildContext context) async {
    if (_isCreatingOrder) return;
    if (_selectedShowtimeId == null) {
      showMessage('Select a showtime first');
      return;
    }
    if (_selectedSeats.isEmpty) {
      showMessage('Select seats first');
      return;
    }

    final seatIds =
        _selectedSeats.map((k) => _seatIdMap[k]).whereType<int>().toList();
    if (seatIds.isEmpty) {
      showMessage('Seat selection is invalid');
      return;
    }

    _isCreatingOrder = true;
    _notify();

    final request = OrderRequest(
      showTimeId: _selectedShowtimeId!,
      userId: userId,
      seatIds: seatIds,
      userInfor: UserInforRequest(
        userEmail: 'user_profile@example.com',
        userPhone: '0000000000',
        userName: 'Guest',
      ),
      seatTypeName: 'Standard',
    );

    try {
      final order = await OrderService().createOrder(request);
      if (order.amount != null) {
        _confirmedTotal = order.amount!.round();
      }
      if (order.discountAmount != null) {
        _discountAmount = order.discountAmount!.round();
      }
      _notify();
      String? client;
      String? redirect;
      if (kIsWeb) {
        client = 'web';
        redirect = '${Uri.base.origin}/#/payment-result';
      }
      final paymentData = await OrderService().createPaymentUrl(
        order.id,
        client: client,
        redirect: redirect,
      );
      final paymentUrl = paymentData['paymentUrl'];
      if (paymentUrl == null || paymentUrl.isEmpty) {
        showMessage('Payment URL missing');
        return;
      }
      await openPaymentUrl(
        context,
        paymentUrl,
        order.id,
        onMessage: showMessage,
        dialogStyle: const PaymentDialogStyle(
          backgroundColor: AppColors.backgroundLight,
          titleStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          closeIconColor: AppColors.textPrimary,
        ),
        canNavigate: () => !_disposed,
        onSuccess: (successOrderId) {
          if (_disposed) return;
          final navigator = Navigator.of(context);
          navigator.pop();
          navigator.push(
            MaterialPageRoute(
              builder: (_) => PaymentSuccessScreen(orderId: successOrderId),
            ),
          );
        },
      );
    } catch (e) {
      showMessage('Order failed');
    } finally {
      _isCreatingOrder = false;
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> _fetchShowtimes() async {
    _isLoadingShowtimes = true;
    _notify();

    final url = Uri.parse('$BASE_URL/showtimes?movieId=$movieId');
    try {
      final res = await http.get(url);
      if (res.statusCode != 200) {
        showMessage('Failed to load showtimes');
        return;
      }
      final data = jsonDecode(res.body) as List<dynamic>;
      final showtimes = data
          .map((item) => ShowtimeOption.fromJson(item as Map<String, dynamic>))
          .toList();
      showtimes.sort((a, b) {
        final dateCompare = a.showDate.compareTo(b.showDate);
        if (dateCompare != 0) return dateCompare;
        return a.startTime.compareTo(b.startTime);
      });

      DateTime? nextDate;
      int? nextShowtimeId;
      if (showtimes.isNotEmpty) {
        nextDate = DateTime(
          showtimes.first.showDate.year,
          showtimes.first.showDate.month,
          showtimes.first.showDate.day,
        );
        nextShowtimeId = showtimes.first.id;
      }

      _showtimes = showtimes;
      _selectedDate = nextDate;
      _selectedShowtimeId = nextShowtimeId;
      _expandedCinemaKey =
          showtimes.isNotEmpty ? _cinemaKeyForShowtime(showtimes.first) : null;
      _selectedSeats.clear();
      _selectedSeatsByShowtime.clear();
      _availableSeatsByShowtime.clear();
      _loadingSeatCounts.clear();
      _seatIdMap.clear();
      _seatLayout = [];
      _seatPriceMap.clear();
      _seatTypeMap.clear();
      _defaultPricePerSeat = null;
      _discountAmount = null;
      _clearConfirmedTotal();
      _notify();

      if (nextShowtimeId != null) {
        await _fetchSeatMap(showtimeId: nextShowtimeId);
      }
      if (_expandedCinemaKey != null) {
        _prefetchSeatCountsForCinema(_expandedCinemaKey!);
      }
    } catch (e) {
      showMessage('Failed to load showtimes');
    } finally {
      _isLoadingShowtimes = false;
      _notify();
    }
  }

  Future<void> _fetchSeatMap({
    int? showtimeId,
    Set<String>? carrySelection,
  }) async {
    final sid = showtimeId ?? _selectedShowtimeId;
    if (sid == null) return;
    final url = Uri.parse('$BASE_URL/showtimes/$sid/seats?userId=$userId');
    _isLoadingSeats = true;
    _notify();
    try {
      final res = await http.get(url);
      if (res.statusCode != 200) {
        return;
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final seats = (data['seats'] as List<dynamic>?) ?? [];
      _discountAmount = null;
      final basePrice = _parseSeatPrice(
        data['price'] ?? data['pricePerSeat'] ?? data['basePrice'],
      );
      if (basePrice != null) {
        _defaultPricePerSeat = basePrice;
      }
      final discount = _parseSeatPrice(
        data['discount'] ??
            data['discountAmount'] ??
            data['totalDiscount'] ??
            data['promotionAmount'] ??
            data['promotion'],
      );
      if (discount != null) {
        _discountAmount = discount;
      }

      int maxRow = 0;
      int maxCol = 0;
      for (final s in seats) {
        final rowName = (s['rowName'] ?? 'A') as String;
        final seatNumber = (s['seatNumber'] ?? 1) as int;
        final r = rowName.codeUnitAt(0) - 'A'.codeUnitAt(0);
        final c = seatNumber - 1;
        if (r > maxRow) maxRow = r;
        if (c > maxCol) maxCol = c;
      }

      final layout =
          List.generate(maxRow + 1, (_) => List<int>.filled(maxCol + 1, 0));
      final savedSelection = _selectedSeatsByShowtime[sid] ?? <String>{};
      final preferredSelection = savedSelection.isNotEmpty
          ? savedSelection
          : (carrySelection ?? <String>{});
      _seatIdMap.clear();
      _selectedSeats.clear();
      _seatPriceMap.clear();
      _seatTypeMap.clear();
      _clearConfirmedTotal();

      int availableCount = 0;
      for (final s in seats) {
        final seatId = (s['seatId'] as num?)?.toInt();
        final rowName = (s['rowName'] ?? 'A') as String;
        final seatNumber = (s['seatNumber'] ?? 1) as int;
        final status = (s['status'] as String?) ?? 'AVAILABLE';
        final r = rowName.codeUnitAt(0) - 'A'.codeUnitAt(0);
        final c = seatNumber - 1;
        if (seatId != null) _seatIdMap['$r-$c'] = seatId;
        final seatPrice = _parseSeatPrice(
          s['price'] ?? s['seatPrice'] ?? s['ticketPrice'],
        );
        if (seatPrice != null) {
          _seatPriceMap['$r-$c'] = seatPrice;
        }
        final seatTypeName = _parseSeatTypeName(
          s['seatTypeName'] ??
              s['seatType'] ??
              s['typeName'] ??
              s['ticketType'] ??
              s['type'],
        );
        if (seatTypeName != null) {
          _seatTypeMap['$r-$c'] = seatTypeName;
        }

        if (status == 'BOOKED' || status == 'HELD') {
          layout[r][c] = 1;
        } else if (status == 'MINE_HELD') {
          layout[r][c] = 2;
          _selectedSeats.add('$r-$c');
        } else {
          layout[r][c] = 0;
          availableCount++;
        }
      }

      for (final seatKey in preferredSelection) {
        final parts = seatKey.split('-');
        if (parts.length != 2) continue;
        final row = int.tryParse(parts[0]);
        final col = int.tryParse(parts[1]);
        if (row == null || col == null) continue;
        if (row < 0 || col < 0) continue;
        if (row >= layout.length || col >= layout[row].length) continue;
        if (layout[row][col] == 0) {
          layout[row][col] = 2;
          _selectedSeats.add(seatKey);
        }
      }

      _seatLayout = layout;
      _availableSeatsByShowtime[sid] = availableCount;
      _selectedSeatsByShowtime[sid] = Set<String>.from(_selectedSeats);
      _notify();
    } catch (e) {
      // ignore or show error
    } finally {
      _isLoadingSeats = false;
      _notify();
    }
  }

  void _prefetchSeatCountsForCinema(String cinemaKey) {
    for (final group in cinemaGroupsForSelectedDate) {
      if (group.key == cinemaKey) {
        _prefetchSeatCountsForShowtimes(group.showtimes);
        break;
      }
    }
  }

  void _prefetchSeatCountsForShowtimes(List<ShowtimeOption> showtimes) {
    for (final showtime in showtimes) {
      if (_availableSeatsByShowtime.containsKey(showtime.id)) continue;
      _fetchShowtimeSeatCount(showtime.id);
    }
  }

  Future<void> _fetchShowtimeSeatCount(int showtimeId) async {
    if (_loadingSeatCounts.contains(showtimeId)) return;
    _loadingSeatCounts.add(showtimeId);
    final url =
        Uri.parse('$BASE_URL/showtimes/$showtimeId/seats?userId=$userId');
    try {
      final res = await http.get(url);
      if (res.statusCode != 200) return;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final seats = (data['seats'] as List<dynamic>?) ?? [];
      int available = 0;
      for (final seat in seats) {
        final status = (seat['status'] as String?) ?? 'AVAILABLE';
        if (status == 'AVAILABLE') {
          available++;
        }
      }
      _availableSeatsByShowtime[showtimeId] = available;
      _notify();
    } catch (e) {
      // ignore
    } finally {
      _loadingSeatCounts.remove(showtimeId);
    }
  }

  Future<bool> _holdSelectedSeats(List<int> seatIds) async {
    final sid = _selectedShowtimeId;
    if (sid == null) {
      showMessage('Select a showtime first');
      return false;
    }
    if (seatIds.isEmpty) {
      showMessage('Khong tim thay seatId tuong ung');
      return false;
    }

    final url = Uri.parse('$BASE_URL/showtimes/$sid/holds/release');
    final body = jsonEncode({'userId': userId, 'seatIds': seatIds});
    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (res.statusCode == 200) {
        return true;
      }
      if (res.statusCode == 409) {
        showMessage('Ghế đang được đặt');
        await _fetchSeatMap();
        return false;
      }
      showMessage('Lỗi: ${res.statusCode}');
      return false;
    } catch (e) {
      showMessage('Lỗi mạng');
      return false;
    }
  }

  Future<bool> _releaseSelectedSeats(List<int> seatIds) async {
    final sid = _selectedShowtimeId;
    if (sid == null) {
      showMessage('Select a showtime first');
      return false;
    }
    if (seatIds.isEmpty) {
      showMessage('Khong tim thay seatId tuong ung');
      return false;
    }

    final url = Uri.parse('$BASE_URL/showtimes/$sid/holds/release');
    final body = jsonEncode({'userId': userId, 'seatIds': seatIds});
    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return true;
      }
      showMessage('Loi: ${res.statusCode}');
      return false;
    } catch (e) {
      showMessage('Loi mang');
      return false;
    }
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int get _effectivePricePerSeat =>
      _defaultPricePerSeat ?? _fallbackPricePerSeat;

  int? _calculateSubtotal({required bool allowFallback}) {
    if (_selectedSeats.isEmpty) return 0;
    final seatTotal = _calculateSeatTotal();
    if (seatTotal != null) return seatTotal;
    if (!allowFallback) {
      if (_defaultPricePerSeat == null) return null;
      return _selectedSeats.length * _defaultPricePerSeat!;
    }
    return _selectedSeats.length * _effectivePricePerSeat;
  }

  int _calculateDiscountAmount() {
    if (_selectedSeats.isEmpty) return 0;
    final explicit = _discountAmount;
    if (explicit != null) return explicit;
    final confirmed = _confirmedTotal;
    if (confirmed == null) return 0;
    final subtotal = _calculateSubtotal(allowFallback: false);
    if (subtotal == null) return 0;
    final diff = subtotal - confirmed;
    return diff > 0 ? diff : 0;
  }

  List<SeatTypeSummary> _buildSeatTypeSummaries() {
    if (_selectedSeats.isEmpty) return const [];
    final summaryMap = <String, _SeatTypeAccumulator>{};
    for (final seatKey in _selectedSeats) {
      final typeName = _seatTypeMap[seatKey] ?? _fallbackSeatTypeName;
      final price = _seatPriceMap[seatKey] ?? _effectivePricePerSeat;
      final bucket =
          summaryMap.putIfAbsent(typeName, () => _SeatTypeAccumulator());
      bucket.count += 1;
      bucket.total += price;
      if (!bucket.unitPriceLocked) {
        if (bucket.unitPrice == null) {
          bucket.unitPrice = price;
        } else if (bucket.unitPrice != price) {
          bucket.unitPrice = null;
          bucket.unitPriceLocked = true;
        }
      }
    }
    final result = <SeatTypeSummary>[];
    for (final entry in summaryMap.entries) {
      final bucket = entry.value;
      result.add(
        SeatTypeSummary(
          typeName: entry.key,
          count: bucket.count,
          total: bucket.total,
          unitPrice: bucket.unitPrice,
        ),
      );
    }
    result.sort((a, b) => a.typeName.compareTo(b.typeName));
    return result;
  }

  int? _calculateSeatTotal() {
    if (_selectedSeats.isEmpty) return 0;
    int total = 0;
    for (final seatKey in _selectedSeats) {
      final seatPrice = _seatPriceMap[seatKey];
      if (seatPrice == null) return null;
      total += seatPrice;
    }
    return total;
  }

  String? _parseSeatTypeName(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    if (value is num) {
      return 'Type ${value.toInt()}';
    }
    if (value is Map<String, dynamic>) {
      final name =
          value['name'] ?? value['typeName'] ?? value['seatTypeName'];
      if (name is String) {
        final trimmed = name.trim();
        return trimmed.isEmpty ? null : trimmed;
      }
    }
    return null;
  }

  int? _parseSeatPrice(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }

  void _clearConfirmedTotal() {
    _confirmedTotal = null;
  }

  String _cinemaKeyForShowtime(ShowtimeOption showtime) {
    final id = showtime.cinemaId;
    if (id != null && id > 0) return id.toString();
    if (showtime.cinemaName.isNotEmpty) return showtime.cinemaName;
    return 'unknown';
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }
}

class _SeatTypeAccumulator {
  int count = 0;
  int total = 0;
  int? unitPrice;
  bool unitPriceLocked = false;
}
