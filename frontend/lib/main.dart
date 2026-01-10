import 'package:flutter/material.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/screens/home/main_screen.dart';
import 'package:frontend/screens/order/create_order_screen.dart';
import 'package:frontend/screens/order/order_history_screen.dart';
import 'package:frontend/screens/movie_details/movie_details_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cinema Booking App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const LoginScreen(),
      // home: const MainScreen(),
      // home: const OrderHistoryScreen(userId: 2),
      // home: const CreateOrder(),

      /*
        Test Create Order Screen
        home: const OrderHistoryScreen(userId: 2),
        home: const CreateOrder(),
       */
      // Test Movie Detail Screen
      // home: const MovieDetailScreen(movieId: '1'),

    );
  }
}
