import 'package:flutter/material.dart';
import 'package:frontend/model/order/Order.dart';
import 'package:frontend/service/order/order_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketDetailScreen extends StatefulWidget {
  final String bookingId; 

  const TicketDetailScreen({super.key, required this.bookingId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreen();
}

class _TicketDetailScreen extends State<TicketDetailScreen> {
  late Future<OrderDetail> _bookingFuture;
  final OrderService _bookingService = OrderService();
  @override
  void initState() {
    super.initState();
    _bookingFuture = _bookingService.getTicketById(widget.bookingId); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Chi tiết vé"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<OrderDetail>(
        future: _bookingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
          }

          final booking = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 1. THE TICKET CARD
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      // Header: Movie Info
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              booking.movieTitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${booking.cinemaName} • ${booking.dateTime}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      
                      const Divider(thickness: 1, height: 1, color: Colors.grey),

                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: QrImageView(
                          data: booking.qrData,
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                      ),
                      
                      const Text(
                        "Quét mã này tại quầy vé",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 20),

                      // 3. LOGIC TO SHOW MANY TICKETS (SEATS)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: Colors.grey[100],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Ghế đã đặt (${booking.tickets.length})",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            
                            // USING WRAP TO SHOW MULTIPLE SEATS NICELY
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: booking.tickets.map((ticket) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black, // Dark seat badge
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                        "Vị Trí: ${ticket.seatInfo}",
                                    style: const TextStyle(
                                      color: Colors.white, 
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      
                      // Footer: Total Amount
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Tổng tiền:", style: TextStyle(fontSize: 16)),
                            Text(
                              "${booking.amount} đ",
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}