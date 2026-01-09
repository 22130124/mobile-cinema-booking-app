class OrderHistoryItem {
  final String id;
  final String title;
  final String posterUrl;
  final String date;
  final String time;
  final String cinemaName;
  final String seats;
  final double amount;
  final int status;
  final String qrData;

  OrderHistoryItem({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.date,
    required this.time,
    required this.cinemaName,
    required this.seats,
    required this.amount,
    required this.status,
    required this.qrData,
  });
  factory OrderHistoryItem.fromJson(Map<String, dynamic> json) {
    return OrderHistoryItem(
      id: json['id'],
      title: json['title'] ?? "Unknown Movie",
      posterUrl: json['posterUrl'] ?? "",
      date: json['date'] ?? "",
      time: json['time'] ?? "",
      cinemaName: json['cinema'] ?? "",
      seats: json['seats'] ?? "",
      amount: _parseAmount(json['amount']),
      status: json['status'] ?? 0,
      qrData: json['qrData'] ?? "",
    );
  }
}

class Ticket {
  final int id;
  final String seatInfo;

  Ticket({required this.id, required this.seatInfo});

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      seatInfo: json['seatInfo'] ?? "Ghế ${json['seatId'] ?? '?'}",
    );
  }
}

class OrderDetail {
  final String id;
  final String qrData;
  final double amount;
  final String movieTitle;
  final String cinemaName;
  final String dateTime;
  final List<Ticket> tickets;

  OrderDetail({
    required this.id,
    required this.qrData,
    required this.amount,
    required this.movieTitle,
    required this.cinemaName,
    required this.dateTime,
    required this.tickets,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    var ticketList = json['tickets'] as List? ?? [];
    List<Ticket> ticketsObjs = ticketList
        .map((i) => Ticket.fromJson(i))
        .toList();

    return OrderDetail(
      id: json['id'] ?? "",
      qrData: json['qrData'] ?? "",
      amount: _parseAmount(json['amount']),

      movieTitle: json['title'] ?? "Unknown Movie",
      cinemaName: json['cinema'] ?? "",
      dateTime: "${json['date'] ?? ""} • ${json['time'] ?? ""}",

      tickets: ticketsObjs,
    );
  }
}

double _parseAmount(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value.toDouble();
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}
