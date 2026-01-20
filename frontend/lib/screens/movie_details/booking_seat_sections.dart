import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../utils/seat_utils.dart';
import '../../widgets/movie/bookings/date_time_option.dart';
import '../../widgets/movie/bookings/seat_map.dart';
import '../../model/movie_details/booking_seat_models.dart';

class BookingSeatHandleBar extends StatelessWidget {
  const BookingSeatHandleBar({super.key});

  @override
  Widget build(BuildContext context) {
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
}

class BookingSeatScreenIndicator extends StatelessWidget {
  const BookingSeatScreenIndicator({super.key});

  @override
  Widget build(BuildContext context) {
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
}

class SeatMapSection extends StatelessWidget {
  final bool isLoading;
  final List<List<int>> seatLayout;
  final void Function(int row, int col) onTapSeat;

  const SeatMapSection({
    super.key,
    required this.isLoading,
    required this.seatLayout,
    required this.onTapSeat,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
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
      onTapSeat: onTapSeat,
      seatLabelBuilder: SeatUtils.seatLabel,
    );
  }
}

class ShowtimeSection extends StatelessWidget {
  final List<CinemaGroup> cinemaGroups;
  final String? expandedCinemaKey;
  final Set<String> favoriteCinemas;
  final Map<int, int> availableSeatsByShowtime;
  final int? selectedShowtimeId;
  final ValueChanged<CinemaGroup> onToggleCinema;
  final ValueChanged<String> onToggleFavorite;
  final ValueChanged<ShowtimeOption> onSelectShowtime;

  const ShowtimeSection({
    super.key,
    required this.cinemaGroups,
    required this.expandedCinemaKey,
    required this.favoriteCinemas,
    required this.availableSeatsByShowtime,
    required this.selectedShowtimeId,
    required this.onToggleCinema,
    required this.onToggleFavorite,
    required this.onSelectShowtime,
  });

  @override
  Widget build(BuildContext context) {
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
        ...cinemaGroups.map(
          (group) => _CinemaCard(
            group: group,
            isExpanded: expandedCinemaKey == group.key,
            isFavorite: favoriteCinemas.contains(group.key),
            availableSeatsByShowtime: availableSeatsByShowtime,
            selectedShowtimeId: selectedShowtimeId,
            onToggleCinema: onToggleCinema,
            onToggleFavorite: onToggleFavorite,
            onSelectShowtime: onSelectShowtime,
          ),
        ),
      ],
    );
  }
}

class _CinemaCard extends StatelessWidget {
  final CinemaGroup group;
  final bool isExpanded;
  final bool isFavorite;
  final Map<int, int> availableSeatsByShowtime;
  final int? selectedShowtimeId;
  final ValueChanged<CinemaGroup> onToggleCinema;
  final ValueChanged<String> onToggleFavorite;
  final ValueChanged<ShowtimeOption> onSelectShowtime;

  const _CinemaCard({
    required this.group,
    required this.isExpanded,
    required this.isFavorite,
    required this.availableSeatsByShowtime,
    required this.selectedShowtimeId,
    required this.onToggleCinema,
    required this.onToggleFavorite,
    required this.onSelectShowtime,
  });

  @override
  Widget build(BuildContext context) {
    final showtimeCount = group.showtimes.length;
    final locationLine = _locationLine(group.address, group.city);
    final descriptionLine = group.address;
    return GestureDetector(
      onTap: () => onToggleCinema(group),
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
                _CinemaAvatar(
                  imageUrl: group.imageUrl,
                  cinemaName: group.name,
                ),
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
                  onPressed: () => onToggleFavorite(group.key),
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? AppColors.accent : AppColors.textHint,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                IconButton(
                  onPressed: () => onToggleCinema(group),
                  icon: Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textHint,
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
              _ShowtimeGrid(
                showtimes: group.showtimes,
                availableSeatsByShowtime: availableSeatsByShowtime,
                selectedShowtimeId: selectedShowtimeId,
                onSelectShowtime: onSelectShowtime,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CinemaAvatar extends StatelessWidget {
  final String imageUrl;
  final String cinemaName;

  const _CinemaAvatar({
    required this.imageUrl,
    required this.cinemaName,
  });

  @override
  Widget build(BuildContext context) {
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
}

class _ShowtimeGrid extends StatelessWidget {
  final List<ShowtimeOption> showtimes;
  final Map<int, int> availableSeatsByShowtime;
  final int? selectedShowtimeId;
  final ValueChanged<ShowtimeOption> onSelectShowtime;

  const _ShowtimeGrid({
    required this.showtimes,
    required this.availableSeatsByShowtime,
    required this.selectedShowtimeId,
    required this.onSelectShowtime,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final itemWidth = (constraints.maxWidth - spacing * 2) / 3;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: showtimes
              .map((showtime) {
                final availableSeats = availableSeatsByShowtime[showtime.id];
                final isSoldOut = _isShowtimeSoldOut(availableSeats);
                return SizedBox(
                  width: itemWidth,
                  child: TimeOption(
                    time: _formatTime(showtime.startTime),
                    subtitle: _seatAvailabilityText(availableSeats),
                    isSelected: selectedShowtimeId == showtime.id,
                    isDisabled: isSoldOut,
                    onTap: isSoldOut ? null : () => onSelectShowtime(showtime),
                  ),
                );
              })
              .toList(),
        );
      },
    );
  }
}

const String _locationLabelFallback = 'TP. H\u1ed3 Ch\u00ed Minh';

String _locationLabelForGroups(List<CinemaGroup> groups) {
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

String _formatTime(DateTime time) {
  final local = time.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
