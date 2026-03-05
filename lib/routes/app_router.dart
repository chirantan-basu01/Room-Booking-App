import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/bookings/presentation/screens/booking_confirmation_screen.dart';
import '../features/bookings/presentation/screens/my_bookings_screen.dart';
import '../features/rooms/presentation/screens/dashboard_screen.dart';
import '../features/rooms/presentation/screens/room_detail_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/rooms/:id',
        builder: (context, state) {
          final roomId = state.pathParameters['id']!;
          return RoomDetailScreen(roomId: roomId);
        },
      ),
      GoRoute(
        path: '/booking/confirm',
        builder: (context, state) => const BookingConfirmationScreen(),
      ),
      GoRoute(
        path: '/bookings',
        builder: (context, state) => const MyBookingsScreen(),
      ),
    ],
  );
});