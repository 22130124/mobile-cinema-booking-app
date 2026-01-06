class UserInforRequest {
  final String userEmail;
  final String userPhone;
  final String userName;

  UserInforRequest({required this.userEmail, required this.userPhone, required this.userName});

  Map<String, dynamic> toJson() => {
    'userEmail': userEmail,
    'userPhone': userPhone,
    'userName': userName,
  };
}

class OrderRequest {
  final int userId;
  final int showTimeId;
  final List<int> seatIds;
  final UserInforRequest userInfor;
  final String seatTypeName;

  OrderRequest({
    required this.userId,
    required this.showTimeId,
    required this.seatIds,
    required this.userInfor,
    required this.seatTypeName,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'showTimeId': showTimeId,
      'seatIds': seatIds,
      'userInfor': userInfor.toJson(),
      'seatTypeName': seatTypeName,
    };
  }
}



