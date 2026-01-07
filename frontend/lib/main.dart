import 'package:flutter/material.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/screens/order/create_order_screen.dart';
import 'package:frontend/screens/order/order_history_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cinema Booking App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      // Default
      // home: const LoginScreen(),

      /*
        Test Create Order Screen
        home: const OrderHistoryScreen(userId: 2),
        home: const CreateOrder(),
       */
        home: const CreateOrder(),
    );
  }
}
