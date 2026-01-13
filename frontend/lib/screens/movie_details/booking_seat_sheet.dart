import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../config/app_colors.dart';
import '../../config/api_config.dart';
import '../../model/order/OrderRequest.dart';
import '../../services/order/order_service.dart';
import '../payment/payment_success_screen.dart';
import 'widgets/bookings/date_time_option.dart';
import 'widgets/bookings/seat_map.dart';
import '../../utils/seat_utils.dart';

class _ShowtimeOption {
  final int id;
  final DateTime showDate;
  final DateTime startTime;
  final String roomName;
  final int? cinemaId;
  final String cinemaName;
  final String cinemaAddress;
  final String cinemaCity;
  final String cinemaImageUrl;

  const _ShowtimeOption({
    required this.id,
    required this.showDate,
    required this.startTime,
    required this.roomName,
    required this.cinemaName,
    required this.cinemaId,
    required this.cinemaAddress,
    required this.cinemaCity,
    required this.cinemaImageUrl,
  });

  factory _ShowtimeOption.fromJson(Map<String, dynamic> json) {
    return _ShowtimeOption(
      id: (json['id'] as num?)?.toInt() ?? 0,
      showDate: DateTime.parse(json['showDate'] as String).toLocal(),
      startTime: DateTime.parse(json['startTime'] as String).toLocal(),
      roomName: json['roomName'] as String? ?? '',
      cinemaId: (json['cinemaId'] as num?)?.toInt(),
      cinemaName: json['cinemaName'] as String? ?? '',
      cinemaAddress: json['cinemaAddress'] as String? ?? '',
      cinemaCity: json['cinemaCity'] as String? ?? '',
      cinemaImageUrl: json['cinemaImageUrl'] as String? ?? '',
    );
  }
}

class _CinemaGroup {
  final String key;
  final int? cinemaId;
  final String name;
  final String address;
  final String city;
  final String imageUrl;
  final List<_ShowtimeOption> showtimes;

  const _CinemaGroup({
    required this.key,
    required this.cinemaId,
    required this.name,
    required this.address,
    required this.city,
    required this.imageUrl,
    required this.showtimes,
  });
}

class BookingSeatSheet extends StatefulWidget {
  final int movieId;
  final int userId;
  const BookingSeatSheet({Key? key, required this.movieId, required this.userId}) : super(key: key);

  @override
  State<BookingSeatSheet> createState() => _BookingSeatSheetState();
}

class _BookingSeatSheetState extends State<BookingSeatSheet> {
  final Set<String> selectedSeats = {};
  final int pricePerSeat = 120000;

  // 0: available, 1: booked/held, 2: selected / mine_held
  List<List<int>> seatLayout = [];
  // map 'row-col' -> backend seatId
  final Map<String, int> seatIdMap = {};
  final Map<int, Set<String>> _selectedSeatsByShowtime = {};
  final Map<int, int> _availableSeatsByShowtime = {};
  final Set<int> _loadingSeatCounts = {};
  final Set<String> _favoriteCinemas = {};
  String? _expandedCinemaKey;

  static const String _locationLabelFallback = 'TP. H\u1ed3 Ch\u00ed Minh';
  static const String _unknownCinemaLabel = 'R\u1ea1p ch\u01b0a r\u00f5';
  bool _isLoadingShowtimes = false;
  bool _isLoadingSeats = false;
  bool _isCreatingOrder = false;
  List<_ShowtimeOption> _showtimes = [];
  DateTime? _selectedDate;
  int? _selectedShowtimeId;

  Future<void> toggleSeat(int row, int col) async {
    if (seatLayout.isEmpty) return;
    if (seatLayout[row][col] == 1) return; // booked or held by others

    final seatKey = '$row-$col';
    final seatId = seatIdMap[seatKey];
    if (seatId == null) {
      _showSnack('Khong tim thay seatId tuong ung');
      return;
    }

    final isSelected = selectedSeats.contains(seatKey);
    final ok = isSelected
        ? await _releaseSelectedSeats([seatId])
        : await _holdSelectedSeats([seatId]);
    if (!ok || !mounted) return;

    setState(() {
      if (isSelected) {
        selectedSeats.remove(seatKey);
        seatLayout[row][col] = 0;
      } else {
        selectedSeats.add(seatKey);
        seatLayout[row][col] = 2;
      }
      final sid = _selectedShowtimeId;
      if (sid != null) {
        _selectedSeatsByShowtime[sid] = Set<String>.from(selectedSeats);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchShowtimes();
  }

  Future<void> _fetchShowtimes() async {
    setState(() {
      _isLoadingShowtimes = true;
    });

    final url = Uri.parse('$BASE_URL/showtimes?movieId=${widget.movieId}');
    try {
      final res = await http.get(url);
      if (res.statusCode != 200) {
        _showSnack('Failed to load showtimes');
        return;
      }
      final data = jsonDecode(res.body) as List<dynamic>;
      final showtimes = data
          .map((item) => _ShowtimeOption.fromJson(item as Map<String, dynamic>))
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

      if (!mounted) return;
      setState(() {
        _showtimes = showtimes;
        _selectedDate = nextDate;
        _selectedShowtimeId = nextShowtimeId;
        _expandedCinemaKey = showtimes.isNotEmpty
            ? _cinemaKeyForShowtime(showtimes.first)
            : null;
        selectedSeats.clear();
        _selectedSeatsByShowtime.clear();
        _availableSeatsByShowtime.clear();
        _loadingSeatCounts.clear();
        seatIdMap.clear();
        seatLayout = [];
      });

      if (nextShowtimeId != null) {
        await _fetchSeatMap(showtimeId: nextShowtimeId);
      }
      if (_expandedCinemaKey != null) {
        _prefetchSeatCountsForCinema(_expandedCinemaKey!);
      }
    } catch (e) {
      _showSnack('Failed to load showtimes');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingShowtimes = false;
        });
      }
    }
  }

  Future<void> _fetchSeatMap({int? showtimeId, Set<String>? carrySelection}) async {
    final sid = showtimeId ?? _selectedShowtimeId;
    if (sid == null) return;
    final uid = widget.userId;
    final url = Uri.parse('$BASE_URL/showtimes/$sid/seats?userId=$uid');
    setState(() {
      _isLoadingSeats = true;
    });
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

      final layout = List.generate(maxRow + 1, (_) => List<int>.filled(maxCol + 1, 0));
      final savedSelection = _selectedSeatsByShowtime[sid] ?? <String>{};
      final preferredSelection = savedSelection.isNotEmpty
          ? savedSelection
          : (carrySelection ?? <String>{});
      seatIdMap.clear();
      selectedSeats.clear();

      int availableCount = 0;
      for (final s in seats) {
        final seatId = (s['seatId'] as num?)?.toInt();
        final rowName = (s['rowName'] ?? 'A') as String;
        final seatNumber = (s['seatNumber'] ?? 1) as int;
        final status = (s['status'] as String?) ?? 'AVAILABLE';
        final r = rowName.codeUnitAt(0) - 'A'.codeUnitAt(0);
        final c = seatNumber - 1;
        if (seatId != null) seatIdMap['$r-$c'] = seatId;

        if (status == 'BOOKED' || status == 'HELD') {
          layout[r][c] = 1;
        } else if (status == 'MINE_HELD') {
          layout[r][c] = 2;
          selectedSeats.add('$r-$c');
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
          selectedSeats.add(seatKey);
        }
      }

      if (!mounted) return;
      setState(() {
        seatLayout = layout;
        _availableSeatsByShowtime[sid] = availableCount;
      });
      _selectedSeatsByShowtime[sid] = Set<String>.from(selectedSeats);
    } catch (e) {
      // ignore or show error
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSeats = false;
        });
      }
    }
  }

  int getTotalPrice() => selectedSeats.length * pricePerSeat;

  String formattedPrice(int price) {
    final s = price.toString();
    final reg = RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))");
    return s.replaceAllMapped(reg, (Match m) => '${m[1]}.');
  }

  List<String> get selectedSeatLabels =>
      SeatUtils.selectedSeatLabels(selectedSeats);

  List<DateTime> get _availableDates {
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

  List<_ShowtimeOption> get _showtimesForSelectedDate {
    final date = _selectedDate;
    if (date == null) return [];
    final list = _showtimes
        .where((s) => _isSameDate(s.showDate, date))
        .toList();
    list.sort((a, b) => a.startTime.compareTo(b.startTime));
    final unique = <_ShowtimeOption>[];
    final seen = <String>{};
    final seenIds = <int>{};
    for (final showtime in list) {
      if (!seenIds.add(showtime.id)) continue;
      final key = '${showtime.startTime.toIso8601String()}|${showtime.roomName}|${showtime.cinemaName}';
      if (seen.add(key)) {
        unique.add(showtime);
      }
    }
    return unique;
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    if (_isSameDate(date, now)) return 'Hôm nay';
    switch (date.weekday) {
      case DateTime.monday:
        return 'Thứ 2';
      case DateTime.tuesday:
        return 'Thứ 3';
      case DateTime.wednesday:
        return 'Thứ 4';
      case DateTime.thursday:
        return 'Thứ 5';
      case DateTime.friday:
        return 'Thứ 6';
      case DateTime.saturday:
        return 'Thứ 7';
      case DateTime.sunday:
        return 'C.Nhật';
      default:
        return '';
    }
  }

  String _formatTime(DateTime time) {
    final local = time.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _cinemaKeyForShowtime(_ShowtimeOption showtime) {
    final id = showtime.cinemaId;
    if (id != null && id > 0) return id.toString();
    if (showtime.cinemaName.isNotEmpty) return showtime.cinemaName;
    return 'unknown';
  }

  List<_CinemaGroup> get _cinemaGroupsForSelectedDate {
    final list = _showtimesForSelectedDate;
    final grouped = <String, List<_ShowtimeOption>>{};
    for (final showtime in list) {
      final key = _cinemaKeyForShowtime(showtime);
      grouped.putIfAbsent(key, () => <_ShowtimeOption>[]).add(showtime);
    }
    return grouped.entries.map((entry) {
      final items = List<_ShowtimeOption>.from(entry.value)
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
      final first = items.first;
      final name = first.cinemaName.isNotEmpty
          ? first.cinemaName
          : _unknownCinemaLabel;
      return _CinemaGroup(
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

  String _locationLabelForGroups(List<_CinemaGroup> groups) {
    final cities = groups
        .map((group) => group.city.trim())
        .where((city) => city.isNotEmpty)
        .toSet();
    if (cities.length == 1) {
      final city = cities.first;
      if (city == 'H\u1ed3 Ch\u00ed Minh' || city == 'Ho Chi Minh') {
        return _locationLabelFallback;
      }
      return city;
    }
    if (cities.isEmpty) return _locationLabelFallback;
    return 'Nhi\u1ec1u khu v\u1ef1c';
  }

  String _extractDistrict(String address) {
    if (address.isEmpty) return '';
    final parts = address.split(',');
    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.contains('Qu\u1eadn') ||
          trimmed.contains('Huy\u1ec7n') ||
          trimmed.contains('Q.')) {
        return trimmed;
      }
    }
    return '';
  }

  String _locationLine(String address, String city) {
    final district = _extractDistrict(address);
    final parts = <String>[];
    if (district.isNotEmpty) parts.add(district);
    if (city.isNotEmpty) parts.add(city);
    if (parts.isEmpty) return '';
    return parts.join(' \u2022 ');
  }

  String _seatAvailabilityText(int? availableSeats) {
    if (availableSeats == null) {
      return 'C\u00f2n -- gh\u1ebf';
    }
    if (availableSeats <= 0) {
      return 'H\u1ebft ch\u1ed7';
    }
    return 'C\u00f2n $availableSeats gh\u1ebf';
  }

  bool _isShowtimeSoldOut(int? availableSeats) {
    return availableSeats != null && availableSeats <= 0;
  }

  void _toggleCinema(_CinemaGroup group) {
    final isExpanded = _expandedCinemaKey == group.key;
    setState(() {
      _expandedCinemaKey = isExpanded ? null : group.key;
    });
    if (!isExpanded) {
      _prefetchSeatCountsForShowtimes(group.showtimes);
    }
  }

  void _toggleFavorite(String cinemaKey) {
    setState(() {
      if (_favoriteCinemas.contains(cinemaKey)) {
        _favoriteCinemas.remove(cinemaKey);
      } else {
        _favoriteCinemas.add(cinemaKey);
      }
    });
  }

  void _prefetchSeatCountsForCinema(String cinemaKey) {
    for (final group in _cinemaGroupsForSelectedDate) {
      if (group.key == cinemaKey) {
        _prefetchSeatCountsForShowtimes(group.showtimes);
        break;
      }
    }
  }

  void _prefetchSeatCountsForShowtimes(List<_ShowtimeOption> showtimes) {
    for (final showtime in showtimes) {
      if (_availableSeatsByShowtime.containsKey(showtime.id)) continue;
      _fetchShowtimeSeatCount(showtime.id);
    }
  }

  Future<void> _fetchShowtimeSeatCount(int showtimeId) async {
    if (_loadingSeatCounts.contains(showtimeId)) return;
    _loadingSeatCounts.add(showtimeId);
    final uid = widget.userId;
    final url = Uri.parse('$BASE_URL/showtimes/$showtimeId/seats?userId=$uid');
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
      if (!mounted) return;
      setState(() {
        _availableSeatsByShowtime[showtimeId] = available;
      });
    } catch (e) {
      // ignore
    } finally {
      _loadingSeatCounts.remove(showtimeId);
    }
  }

  Widget _showtimeSection() {
    final cinemaGroups = _cinemaGroupsForSelectedDate;
    final locationLabel = _locationLabelForGroups(cinemaGroups);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'R\u1ea1p Phim (${cinemaGroups.length})',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            const Icon(Icons.location_on, size: 14, color: AppColors.accent),
            const SizedBox(width: 4),
            Text(
              locationLabel,
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (cinemaGroups.isEmpty)
          const Text(
            'Kh\u00f4ng c\u00f3 su\u1ea5t chi\u1ebfu',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ...cinemaGroups.map(_buildCinemaCard),
      ],
    );
  }

  Widget _buildCinemaCard(_CinemaGroup group) {
    final isExpanded = _expandedCinemaKey == group.key;
    final isFavorite = _favoriteCinemas.contains(group.key);
    final showtimeCount = group.showtimes.length;
    final locationLine = _locationLine(group.address, group.city);
    final descriptionLine = group.address;
    return GestureDetector(
      onTap: () => _toggleCinema(group),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCinemaAvatar(group.imageUrl, group.name),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (locationLine.isNotEmpty)
                        Text(
                          locationLine,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                if (!isExpanded)
                  Padding(
                    padding: const EdgeInsets.only(top: 2, right: 6),
                    child: Text(
                      '$showtimeCount su\u1ea5t chi\u1ebfu',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                IconButton(
                  onPressed: () => _toggleFavorite(group.key),
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? AppColors.accent : AppColors.textHint,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                IconButton(
                  onPressed: () => _toggleCinema(group),
                  icon: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textHint,
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
            if (descriptionLine.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                descriptionLine,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (isExpanded) ...[
              const SizedBox(height: 10),
              _buildShowtimeGrid(group.showtimes),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCinemaAvatar(String imageUrl, String cinemaName) {
    final trimmed = cinemaName.trim();
    final initial = trimmed.isNotEmpty ? trimmed[0].toUpperCase() : '?';
    final fallback = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
    if (imageUrl.isEmpty) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
      ),
    );
  }

  Widget _buildShowtimeGrid(List<_ShowtimeOption> showtimes) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final itemWidth = (constraints.maxWidth - spacing * 2) / 3;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: showtimes
              .map((showtime) {
                final availableSeats = _availableSeatsByShowtime[showtime.id];
                final isSoldOut = _isShowtimeSoldOut(availableSeats);
                return SizedBox(
                  width: itemWidth,
                  child: TimeOption(
                    time: _formatTime(showtime.startTime),
                    subtitle: _seatAvailabilityText(availableSeats),
                    isSelected: _selectedShowtimeId == showtime.id,
                    isDisabled: isSoldOut,
                    onTap: isSoldOut ? null : () => _selectShowtime(showtime),
                  ),
                );
              })
              .toList(),
        );
      },
    );
  }

  void _selectDate(DateTime date) {
    final showtimes = _showtimes
        .where((s) => _isSameDate(s.showDate, date))
        .toList();
    if (showtimes.isEmpty) return;
    showtimes.sort((a, b) => a.startTime.compareTo(b.startTime));
    final next = showtimes.first;
    final previousSelection = Set<String>.from(selectedSeats);
    final previousShowtimeId = _selectedShowtimeId;
    if (previousShowtimeId != null) {
      _selectedSeatsByShowtime[previousShowtimeId] = Set<String>.from(selectedSeats);
    }
    setState(() {
      _selectedDate = date;
      _selectedShowtimeId = next.id;
      _expandedCinemaKey = _cinemaKeyForShowtime(next);
      selectedSeats.clear();
      seatIdMap.clear();
      seatLayout = [];
    });
    _fetchSeatMap(showtimeId: next.id, carrySelection: previousSelection);
    _prefetchSeatCountsForCinema(_cinemaKeyForShowtime(next));
  }

  void _selectShowtime(_ShowtimeOption showtime) {
    if (_selectedShowtimeId == showtime.id) return;
    final nextDate = DateTime(
      showtime.showDate.year,
      showtime.showDate.month,
      showtime.showDate.day,
    );
    final previousSelection = Set<String>.from(selectedSeats);
    final previousShowtimeId = _selectedShowtimeId;
    if (previousShowtimeId != null) {
      _selectedSeatsByShowtime[previousShowtimeId] = Set<String>.from(selectedSeats);
    }
    setState(() {
      _selectedDate = nextDate;
      _selectedShowtimeId = showtime.id;
      _expandedCinemaKey = _cinemaKeyForShowtime(showtime);
      selectedSeats.clear();
      seatIdMap.clear();
      seatLayout = [];
    });
    _fetchSeatMap(showtimeId: showtime.id, carrySelection: previousSelection);
    _prefetchSeatCountsForCinema(_cinemaKeyForShowtime(showtime));
  }

  Widget _seatMapSection() {
    if (_isLoadingSeats) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }
    if (seatLayout.isEmpty) {
      return const Text(
        'No seats available',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }
    return SeatMap(
      seatLayout: seatLayout,
      onTapSeat: toggleSeat,
      seatLabelBuilder: SeatUtils.seatLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.77,
        decoration: const BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            _handleBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _screenIndicator(context),
                    _seatMapSection(),
                    const SizedBox(height: 24),
                    _legend(),
                    const SizedBox(height: 24),

                    if (selectedSeats.isNotEmpty) ...[
                      _selectedSeatsSummary(),
                      const SizedBox(height: 16),
                    ],
                    if (_isLoadingShowtimes) ...[
                      const Center(
                        child: CircularProgressIndicator(color: AppColors.accent),
                      ),
                      const SizedBox(height: 24),
                    ],

                    const SizedBox(height: 8),
                    const Text(
                      'Chọn Ngày',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _availableDates
                            .map(
                              (date) => Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: SizedBox(
                                  width: 80,
                                  child: DateOption(
                                    day: date.day,
                                    month: date.month,
                                    dayName: _dayLabel(date),
                                    isSelected: _selectedDate != null &&
                                        _isSameDate(_selectedDate!, date),
                                    onTap: () => _selectDate(date),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    const SizedBox(height: 24),
                    _showtimeSection(),

                    const SizedBox(height: 32),
                    _totalAndBuy(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _handleBar() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _screenIndicator(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: 80,
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=600',
                ),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _legend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegend(AppColors.surface, 'Ghế trống'),
        const SizedBox(width: 16),
        _buildLegend(AppColors.border, 'Ghế đã đặt'),
        const SizedBox(width: 16),
        _buildLegend(AppColors.accent, 'Ghế đã chọn'),
      ],
    );
  }

  Widget _selectedSeatsSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accent.withAlpha((0.08 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accent.withAlpha((0.25 * 255).round()),
        ),
      ),
      child: Text(
        'Ghế đã chọn: ${selectedSeatLabels.join(', ')}',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _totalAndBuy() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thành Tiền',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${formattedPrice(getTotalPrice())} VND',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: (selectedSeats.isEmpty || _selectedShowtimeId == null || _isCreatingOrder)
                ? null
                : () async {
                    await _createOrderAndPay();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              disabledBackgroundColor: AppColors.surface,
              disabledForegroundColor: AppColors.textHint,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Mua Vé',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _createOrderAndPay() async {
    if (_isCreatingOrder) return;
    if (_selectedShowtimeId == null) {
      _showSnack('Select a showtime first');
      return;
    }
    if (selectedSeats.isEmpty) {
      _showSnack('Select seats first');
      return;
    }

    final seatIds = selectedSeats
        .map((k) => seatIdMap[k])
        .whereType<int>()
        .toList();
    if (seatIds.isEmpty) {
      _showSnack('Seat selection is invalid');
      return;
    }

    setState(() {
      _isCreatingOrder = true;
    });

    final request = OrderRequest(
      showTimeId: _selectedShowtimeId!,
      userId: widget.userId,
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
        _showSnack('Payment URL missing');
        return;
      }
      await _openPaymentUrl(context, paymentUrl, order.id);
    } catch (e) {
      _showSnack('Order failed');
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingOrder = false;
        });
      }
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
      _showSnack('Invalid payment URL');
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
      _showSnack('Khong the mo trang thanh toan tren web');
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
                final status =
                    uri.queryParameters['status'] ??
                    (uri.queryParameters['vnp_ResponseCode'] == '00'
                        ? 'success'
                        : 'fail');
                if (status == 'success' && resultOrderId != null) {
                  paymentCompleted = true;
                  if (!mounted) return NavigationDecision.prevent;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PaymentSuccessScreen(orderId: resultOrderId),
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
                      icon: const Icon(Icons.close, color: AppColors.textPrimary),
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

    if (paymentCompleted && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<bool> _holdSelectedSeats(List<int> seatIds) async {
    final sid = _selectedShowtimeId;
    if (sid == null) {
      _showSnack('Select a showtime first');
      return false;
    }
    if (seatIds.isEmpty) {
      _showSnack('Khong tim thay seatId tuong ung');
      return false;
    }

    final uid = widget.userId;
    final url = Uri.parse('$BASE_URL/showtimes/$sid/holds/release');
    final body = jsonEncode({'userId': uid, 'seatIds': seatIds});
    try {
      final res = await http.post(url, headers: {'Content-Type': 'application/json'}, body: body);
      if (res.statusCode == 200) {
        return true;
      }
      if (res.statusCode == 409) {
        _showSnack('Ghe da duoc giu hoac dat');
        await _fetchSeatMap();
        return false;
      }
      _showSnack('Loi: ${res.statusCode}');
      return false;
    } catch (e) {
      _showSnack('Loi mang');
      return false;
    }
  }

  Future<bool> _releaseSelectedSeats(List<int> seatIds) async {
    final sid = _selectedShowtimeId;
    if (sid == null) {
      _showSnack('Select a showtime first');
      return false;
    }
    if (seatIds.isEmpty) {
      _showSnack('Khong tim thay seatId tuong ung');
      return false;
    }

    final uid = widget.userId;
    final url = Uri.parse('$BASE_URL/showtimes/$sid/holds/release');
    final body = jsonEncode({'userId': uid, 'seatIds': seatIds});
    try {
      final res = await http.post(url, headers: {'Content-Type': 'application/json'}, body: body);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return true;
      }
      _showSnack('Loi: ${res.statusCode}');
      return false;
    } catch (e) {
      _showSnack('Loi mang');
      return false;
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildLegend(Color color, String label) {
    final isAvailable = color == AppColors.surface;
    final iconColor = color == AppColors.accent
        ? Colors.black
        : color == AppColors.border
            ? AppColors.textHint
            : AppColors.textSecondary;
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isAvailable
                  ? AppColors.border.withAlpha((0.25 * 255).round())
                  : Colors.transparent,
            ),
          ),
          child: Icon(
            Icons.event_seat,
            size: 12,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}


