import 'dart:ui';

import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../controller/booking/booking_seat_controller.dart';
import 'booking_seat_sections.dart';
import '../../widgets/movie/bookings/booking_seat_widgets.dart';

class BookingSeatSheet extends StatefulWidget {
  final int movieId;
  final int userId;
  const BookingSeatSheet({super.key, required this.movieId, required this.userId});

  @override
  State<BookingSeatSheet> createState() => _BookingSeatSheetState();
}

class _BookingSeatSheetState extends State<BookingSeatSheet> {
  late final BookingSeatController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BookingSeatController(
      movieId: widget.movieId,
      userId: widget.userId,
      showMessage: _showSnack,
    );
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
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
                const BookingSeatHandleBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const BookingSeatScreenIndicator(),
                        SeatMapSection(
                          isLoading: _controller.isLoadingSeats,
                          seatLayout: _controller.seatLayout,
                          onTapSeat: _controller.toggleSeat,
                        ),
                        const SizedBox(height: 24),
                        const BookingSeatLegend(),
                        const SizedBox(height: 24),
                        if (_controller.selectedSeats.isNotEmpty) ...[
                          SelectedSeatsSummary(
                            seatLabels: _controller.selectedSeatLabels,
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (_controller.isLoadingShowtimes) ...[
                          const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        BookingDateSelector(
                          dates: _controller.availableDates,
                          selectedDate: _controller.selectedDate,
                          onSelect: _controller.selectDate,
                        ),
                        const SizedBox(height: 24),
                        ShowtimeSection(
                          cinemaGroups: _controller.cinemaGroupsForSelectedDate,
                          expandedCinemaKey: _controller.expandedCinemaKey,
                          favoriteCinemas: _controller.favoriteCinemas,
                          availableSeatsByShowtime:
                              _controller.availableSeatsByShowtime,
                          selectedShowtimeId: _controller.selectedShowtimeId,
                          onToggleCinema: _controller.toggleCinema,
                          onToggleFavorite: _controller.toggleFavorite,
                          onSelectShowtime: _controller.selectShowtime,
                        ),
                        const SizedBox(height: 32),
                        TotalAndBuyBar(
                          formattedTotal: _controller
                              .formattedPrice(_controller.totalPrice),
                          isEnabled: _controller.canCreateOrder,
                          onPressed: () =>
                              _controller.createOrderAndPay(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
