import 'package:flutter/material.dart';
import 'package:frontend/screens/auth/login_screen.dart';

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
      home: const LoginScreen(),
    );
  }
}




// ===========================================// Main Test Code By Tai 
// import 'package:flutter/material.dart';
// import 'package:frontend/screens/auth/login_screen.dart';
// import 'package:frontend/screens/order/create_order_screen.dart';
// import 'package:frontend/screens/order/order_history_screen.dart';
// // Deep linking packages
// import 'package:frontend/screens/payment/payment_success_screen.dart';
// import 'dart:async';
// import 'package:app_links/app_links.dart';
// // ===========================================

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
//   final AppLinks _appLinks = AppLinks();
//   StreamSubscription<Uri?>? _sub;

//   @override
//   void initState() {
//     super.initState();
//     // Handle incoming links while the app is running
//     _sub = _appLinks.uriLinkStream.listen((Uri? uri) {
//       if (uri != null) _handleIncomingLink(uri.toString());
//     }, onError: (err) {
//       // handle errors
//     });

//     // Handle initial link if the app was started by the link
//     _checkInitialLink();
//   }

//   Future<void> _checkInitialLink() async {
//     try {
//       final initialUri = await _appLinks.getInitialLink();
//       if (initialUri != null) _handleIncomingLink(initialUri.toString());
//     } catch (e) {
//       // handle error
//     }
//   }

//   void _handleIncomingLink(String link) {
//     try {
//       final uri = Uri.parse(link);
//       if (uri.scheme == 'cinemapp' && uri.host == 'payment-result') {
//         final orderId = uri.queryParameters['orderId'];
//         final status = uri.queryParameters['status'];
//         if (orderId != null && status == 'success') {
//           navigatorKey.currentState?.push(MaterialPageRoute(
//             builder: (_) => PaymentSuccessScreen(orderId: orderId),
//           ));
//         } else if (orderId != null) {
//           // For non-success you can navigate to a failure screen or show dialog
//           // navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => PaymentFailureScreen(orderId: orderId)));
//         }
//       }
//     } catch (e) {
//       // invalid link
//     }
//   }
//   @override
//   void dispose() {
//     _sub?.cancel();
//     super.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Cinema Booking App',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(primarySwatch: Colors.deepPurple),
//       navigatorKey: navigatorKey,
//       home: const CreateOrder(),
//     );
//   }
// }