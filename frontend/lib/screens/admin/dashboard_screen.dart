import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang Dashboard'),
      ),
      body: const Center(
        child: Text(
          'Đây là trang Dashboard Admin',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}