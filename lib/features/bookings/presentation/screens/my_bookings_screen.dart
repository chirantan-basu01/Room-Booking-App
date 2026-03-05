import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_error_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../widgets/booking_card.dart';
import '../widgets/section_header.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(userBookingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return EmptyStateWidget(
              title: 'No Bookings Yet',
              message: 'Start exploring rooms and make your first booking!',
              icon: Icons.calendar_today_outlined,
              buttonText: 'Browse Rooms',
              onAction: () => context.go('/dashboard'),
            );
          }

          final upcomingBookings =
              bookings.where((b) => b.isUpcoming).toList();
          final ongoingBookings =
              bookings.where((b) => b.isOngoing).toList();
          final pastBookings = bookings
              .where((b) =>
                  b.isPast || b.status == BookingStatus.cancelled)
              .toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userBookingsProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (ongoingBookings.isNotEmpty) ...[
                  SectionHeader(
                    title: 'Current Stay',
                    count: ongoingBookings.length,
                  ),
                  const SizedBox(height: 12),
                  ...ongoingBookings.map((booking) => BookingCard(
                        booking: booking,
                        onCancel: () => _showCancelDialog(context, ref, booking),
                      )),
                  const SizedBox(height: 24),
                ],
                if (upcomingBookings.isNotEmpty) ...[
                  SectionHeader(
                    title: 'Upcoming',
                    count: upcomingBookings.length,
                  ),
                  const SizedBox(height: 12),
                  ...upcomingBookings.map((booking) => BookingCard(
                        booking: booking,
                        onCancel: () => _showCancelDialog(context, ref, booking),
                      )),
                  const SizedBox(height: 24),
                ],
                if (pastBookings.isNotEmpty) ...[
                  SectionHeader(
                    title: 'Past Bookings',
                    count: pastBookings.length,
                  ),
                  const SizedBox(height: 12),
                  ...pastBookings.map((booking) => BookingCard(
                        booking: booking,
                        isPast: true,
                      )),
                ],
              ],
            ),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (error, stack) => CustomErrorWidget(
          message: error.toString(),
          onRetry: () => ref.refresh(userBookingsProvider),
        ),
      ),
    );
  }

  void _showCancelDialog(
    BuildContext context,
    WidgetRef ref,
    BookingModel booking,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Cancel Booking?'),
        content: Text(
          'Are you sure you want to cancel your booking at ${booking.roomName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Booking'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(bookingRepositoryProvider)
                  .cancelBooking(booking.id);
              ref.invalidate(userBookingsProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Booking cancelled successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }
}
