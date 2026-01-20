import 'package:flutter/material.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/screens/payment/payment_success_screen.dart';

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
      onGenerateRoute: (settings) {
        final rawName = settings.name ?? '/';
        String routeName = rawName;
        final hashIndex = rawName.indexOf('#');
        if (hashIndex != -1 && hashIndex + 1 < rawName.length) {
          routeName = rawName.substring(hashIndex + 1);
        }
        if (!routeName.startsWith('/')) {
          routeName = '/$routeName';
        }
        final uri = Uri.parse(routeName);
        if (uri.path == '/payment-result') {
          final orderId = uri.queryParameters['orderId'];
          final status = uri.queryParameters['status'];
          if (orderId != null && status == 'success') {
            return MaterialPageRoute(
              builder: (_) => PaymentSuccessScreen(orderId: orderId),
            );
          }
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
        return null;
      },
      // home: const MainScreen(),
      // home: const OrderHistoryScreen(userId: 2),
      // home: const CreateOrder(),

      /*
        Test Create Order Screen
        home: const OrderHistoryScreen(userId: 2),
        home: const CreateOrder(),
       */
    );
  }
}
