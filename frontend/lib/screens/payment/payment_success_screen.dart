import 'package:flutter/material.dart';
import 'package:frontend/model/order/Order.dart';
import 'package:frontend/service/order/order_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String orderId;
  const PaymentSuccessScreen({super.key, required this.orderId});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  late Future<OrderDetail> _orderDetailFuture;

  @override
  void initState() {
    super.initState();
    _orderDetailFuture = OrderService().getTicketById(widget.orderId);
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Flexible(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Success"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: _orderDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final order = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 100),
                    SizedBox(height: 20),
                    Text(
                      "Mã đơn: ${widget.orderId}",
                      style: TextStyle(fontSize: 10),
                      selectionColor: Colors.white,
                    ),
                    SizedBox(height: 30),
                    if (order.qrData.isNotEmpty)
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(10),
                        child: QrImageView(
                          data: order.qrData,
                          version: QrVersions.auto,
                          size: 220.0,
                        ),
                      )
                    else
                      Column(
                        children: [
                          CircularProgressIndicator(),
                          Text("Đang tạo mã QR..."),
                        ],
                      ),
                    SizedBox(height: 30),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              "Phim",
                              order.movieTitle,
                            ), 
                            Divider(),
                            _buildInfoRow("Rạp", order.cinemaName),
                            Divider(),
                            _buildInfoRow("Thời gian", order.dateTime),
                            Divider(),
                            _buildInfoRow(
                              "Ghế",
                              order.tickets.map((t) => t.seatInfo).join(", "),
                            ),
                            Divider(),
                            _buildInfoRow("Tổng tiền", "${order.amount} VND"),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/', (route) => false);
                        },
                        child: Text(
                          "Về trang chủ",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('No data found'));
          }
        },
      ),
    );
  }
}
