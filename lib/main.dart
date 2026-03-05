import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/bookings/domain/models/booking_model.dart';
import 'features/rooms/domain/models/room_model.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(RoomModelAdapter());
  Hive.registerAdapter(RoomTypeAdapter());
  Hive.registerAdapter(BookingModelAdapter());
  Hive.registerAdapter(BookingStatusAdapter());

  await Hive.openBox(AppConstants.hiveUserBox);
  await Hive.openBox(AppConstants.hiveBookingsBox);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: RoomBookingApp()));
}

class RoomBookingApp extends ConsumerWidget {
  const RoomBookingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
