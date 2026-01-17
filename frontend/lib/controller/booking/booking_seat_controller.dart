import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../config/api_config.dart';
import '../../config/app_colors.dart';
import '../../model/order/OrderRequest.dart';
import '../../services/order/order_service.dart';
import '../../utils/seat_utils.dart';
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

  static const int _pricePerSeat = 120000;
  static const String _unknownCinemaLabel = 'R\u1ea1p ch\u01b0a r\u00f5';

  final Set<String> _selectedSeats = {};
  List<List<int>> _seatLayout = [];
  final Map<String, int> _seatIdMap = {};
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

  int get totalPrice => _selectedSeats.length * _pricePerSeat;

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
        userEmail: 'user@example.com',
        userPhone: '0000000000',
        userName: 'Guest',
      ),
      seatTypeName: 'Standard',
    );

    try {
      final order = await OrderService().createOrder(request);
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
      await _openPaymentUrl(context, paymentUrl, order.id);
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

      int availableCount = 0;
      for (final s in seats) {
        final seatId = (s['seatId'] as num?)?.toInt();
        final rowName = (s['rowName'] ?? 'A') as String;
        final seatNumber = (s['seatNumber'] ?? 1) as int;
        final status = (s['status'] as String?) ?? 'AVAILABLE';
        final r = rowName.codeUnitAt(0) - 'A'.codeUnitAt(0);
        final c = seatNumber - 1;
        if (seatId != null) _seatIdMap['$r-$c'] = seatId;

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
        showMessage('Ghe da duoc giu hoac dat');
        await _fetchSeatMap();
        return false;
      }
      showMessage('Loi: ${res.statusCode}');
      return false;
    } catch (e) {
      showMessage('Loi mang');
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

  Future<void> _openPaymentUrl(
    BuildContext context,
    String paymentUrl,
    String orderId,
  ) async {
    final url = paymentUrl.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.tryParse(url);
    if (uri == null) {
      showMessage('Invalid payment URL');
      return;
    }

    bool paymentCompleted = false;

    if (kIsWeb) {
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (_) {}
      showMessage('Khong the mo trang thanh toan tren web');
      return;
    }

    final WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest req) async {
            final url = req.url;
            if (url.startsWith('cinemapp://')) {
              Navigator.of(context).pop();
              try {
                final uri = Uri.parse(url);
                final resultOrderId =
                    uri.queryParameters['orderId'] ??
                        uri.queryParameters['vnp_TxnRef'];
                final status = uri.queryParameters['status'] ??
                    (uri.queryParameters['vnp_ResponseCode'] == '00'
                        ? 'success'
                        : 'fail');
                if (status == 'success' && resultOrderId != null) {
                  paymentCompleted = true;
                  if (_disposed) return NavigationDecision.prevent;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          PaymentSuccessScreen(orderId: resultOrderId),
                    ),
                  );
                }
              } catch (_) {}
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(uri, headers: {'ngrok-skip-browser-warning': 'true'});

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.all(12),
          backgroundColor: AppColors.backgroundLight,
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.85,
            child: Column(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 8),
                    const Text(
                      'Payment',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon:
                          const Icon(Icons.close, color: AppColors.textPrimary),
                      onPressed: () async {
                        await OrderService().deleteSeatHoldByUser(orderId);
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),
                Expanded(child: WebViewWidget(controller: controller)),
              ],
            ),
          ),
        );
      },
    );

    if (paymentCompleted && !_disposed) {
      Navigator.of(context).pop();
    }
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
