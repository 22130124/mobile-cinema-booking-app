import 'package:flutter/material.dart';
import 'seat_tile.dart';

typedef SeatLabelBuilder = String Function(int row, int col);

class SeatMap extends StatelessWidget {
  final List<List<int>> seatLayout;
  final void Function(int row, int col) onTapSeat;
  final SeatLabelBuilder seatLabelBuilder;

  const SeatMap({
    Key? key,
    required this.seatLayout,
    required this.onTapSeat,
    required this.seatLabelBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double availableWidth = constraints.maxWidth * 0.9;
          final int cols = seatLayout.isNotEmpty ? seatLayout[0].length : 10;
          const double gap = 8.0;

          double seatSize = (availableWidth - (cols - 1) * gap) / cols;
          seatSize = seatSize.clamp(22.0, 40.0);

          return Column(
            children: List.generate(
              seatLayout.length,
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      seatLayout[row].length,
                      (col) {
                        final status = seatLayout[row][col];
                        return SeatTile(
                          status: status,
                          label: seatLabelBuilder(row, col),
                          size: seatSize,
                          gap: gap,
                          onTap: () => onTapSeat(row, col),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
