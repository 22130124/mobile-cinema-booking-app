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
      amount: (json['amount'] is int)
          ? (json['amount'] as int).toDouble()
          : (json['amount'] as double),
      status: json['status'] ?? "",
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
  final int amount;
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
      amount: json['amount'] ?? 0,

      movieTitle: json['title'] ?? "Unknown Movie",
      cinemaName: json['cinema'] ?? "",
      dateTime: "${json['date'] ?? ""} • ${json['time'] ?? ""}",

      tickets: ticketsObjs,
    );
  }
}
