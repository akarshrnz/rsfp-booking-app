import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:innerspace_booking_app/core/app_constants.dart';
import 'package:innerspace_booking_app/features/auth/presentation/pages/login_page.dart';
import 'package:innerspace_booking_app/features/auth/presentation/pages/signup_page.dart';
import 'package:innerspace_booking_app/features/auth/presentation/pages/splash_screen.dart';
import 'package:innerspace_booking_app/features/product/presentation/pages/my_bookings_page.dart';
import 'package:innerspace_booking_app/features/product/presentation/pages/product_detail_page.dart';
import 'package:innerspace_booking_app/features/notification/presentation/page/notifications_page.dart';
import 'package:innerspace_booking_app/features/product/presentation/pages/warehouse_scan_page.dart';


import '../../features/product/presentation/pages/home_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.splashRoute:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppConstants.registerRoute:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppConstants.loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppConstants.homeRoute:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case AppConstants.warehouseRoute:
        return MaterialPageRoute(builder: (_) => const WarehouseScanPage());
   
      case AppConstants.productDetailRoute:
        final prodId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ProductDetailPage(productId: prodId),
        );
  
      case AppConstants.myBookingsRoute:
        return MaterialPageRoute(builder: (_) => const MyBookingsPage());
      case AppConstants.notificationsRoute:
        return MaterialPageRoute(builder: (_) =>  NotificationListPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}