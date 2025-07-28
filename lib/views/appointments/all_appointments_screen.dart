import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../home/widgets/appointment_card.dart';
import '../../core/services/pre_approval_service.dart';
import '../../viewmodels/appointment_view_model.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/doctors_view_model.dart';
import '../../models/doctor.dart';

class _CustomTabIndicator extends Decoration {
  final double indicatorHeight;
  final Color color;
  final double horizontalPadding;
  const _CustomTabIndicator({
    this.indicatorHeight = 36,
    required this.color,
    required this.horizontalPadding,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomTabIndicatorPainter(
      color: color,
      indicatorHeight: indicatorHeight,
      horizontalPadding: horizontalPadding,
    );
  }
}

class _CustomTabIndicatorPainter extends BoxPainter {
  final double indicatorHeight;
  final Color color;
  final double horizontalPadding;
  _CustomTabIndicatorPainter({
    required this.color,
    required this.indicatorHeight,
    required this.horizontalPadding,
  });

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Paint paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.fill;
    final double width = configuration.size!.width - 2 * horizontalPadding;
    final double left = offset.dx + horizontalPadding;
    final double top = offset.dy + configuration.size!.height - indicatorHeight;
    final Rect rect = Rect.fromLTWH(left, top, width, indicatorHeight);
    final RRect rRect =
        RRect.fromRectAndRadius(rect, const Radius.circular(12));
    canvas.drawRRect(rRect, paint);
  }
}

class AllAppointmentsScreen extends StatefulWidget {
  const AllAppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AllAppointmentsScreen> createState() => _AllAppointmentsScreenState();
}

class _AllAppointmentsScreenState extends State<AllAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Initialize appointment view model
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<AppointmentViewModel>(context, listen: false);
      viewModel.initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Appointment> _filterAppointments(String status) {
    final viewModel = Provider.of<AppointmentViewModel>(context, listen: false);
    switch (status) {
      case 'Upcoming':
        return viewModel.upcomingAppointments;
      case 'Completed':
        return viewModel.completedAppointments;
      case 'Canceled':
        return viewModel.cancelledAppointments;
      default:
        return viewModel.appointments;
    }
  }

  DateTime _parseDate(String date, String time) {
    // date: YYYY-MM-DD or MMM dd, yyyy, time: HH:MM AM/PM


    try {
      if (date.contains('-')) {
        // Format: YYYY-MM-DD
        final parts = date.split('-');
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        final timeOfDay = TimeOfDay(
          hour: int.parse(time.split(':')[0]),
          minute: int.parse(time.split(':')[1].split(' ')[0]),
        );
        return DateTime(year, month, day, timeOfDay.hour, timeOfDay.minute);
      } else {
        // Format: MMM dd, yyyy
        return DateTime.parse(date);
      }
    } catch (e) {
      return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tabPadding = screenWidth /
        3; // 1/3 of screen for each tab, so 1/9 padding on each side
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicator: _CustomTabIndicator(
            color: AppColors.error,
            indicatorHeight: 46,
            horizontalPadding: tabPadding,
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.background,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'Canceled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppointmentList('Upcoming'),
          _buildAppointmentList('Completed'),
          _buildAppointmentList('Canceled'),
        ],
      ),
    );
  }

  Widget _buildAppointmentList(String status) {
    return Consumer2<AppointmentViewModel, DoctorsViewModel>(
      builder: (context, viewModel, doctorsViewModel, child) {
        if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (viewModel.errorMessage != null) {
          return Center(
            child: Text(
              viewModel.errorMessage!,
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          );
        }
        List<Appointment> filtered;
        switch (status) {
          case 'Upcoming':
            filtered = viewModel.upcomingAppointments;
            break;
          case 'Completed':
            filtered = viewModel.completedAppointments;
            break;
          case 'Canceled':
            filtered = viewModel.cancelledAppointments;
            break;
          default:
            filtered = viewModel.appointments;
        }
        if (filtered.isEmpty) {
          return Center(
            child: Text('No $status appointments'),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final appointment = filtered[index];
            // Lookup doctor image by ID
            String doctorImage = '';
            final doctor = doctorsViewModel.allDoctors.firstWhere(
              (d) => d.id == appointment.doctorId,
              orElse: () => Doctor(
                id: '',
                name: '',
                specialty: '',
                hospital: '',
                imageUrl: '',
                rating: 0.0,
                reviews: 0,
                isAvailable: false,
                price: 0.0,
                isOnline: false,
                experience: 0,
                education: '',
                languages: const [],
                specializations: const [],
                about: '',
                availability: const {},
                awards: const [],
                consultationFee: '',
                acceptsInsurance: false,
                insuranceProviders: const [],
                location: '',
                distance: 0.0,
                isVerified: false,
                phoneNumber: '',
                email: '',
                symptoms: const [],
                videoCall: false,
              ),
            );
            if (doctor != null) {
              doctorImage = doctor.imageUrl;
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About Doctor',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.secondary.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Appointment details (reuse AppointmentCard's content if possible)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: AppColors.secondary.withOpacity(0.1),
                              backgroundImage: (doctorImage.isNotEmpty)
                                  ? NetworkImage(doctorImage)
                                  : null,
                              child: (doctorImage.isEmpty)
                                  ? Icon(
                                      Icons.person,
                                      size: 32,
                                      color: AppColors.primary,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          appointment.doctorName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textBlack,
                                                fontSize: 18,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                AppColors.secondary.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: AppColors.secondary
                                                  .withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.person_rounded,
                                                size: 16,
                                                color: AppColors.secondary,
                                              ),
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  'In Person',
                                                  style: TextStyle(
                                                    color: AppColors.secondary,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      appointment.specialty,
                                      style: TextStyle(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.paleBackground,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.calendar_today,
                                            size: 18, color: AppColors.primary),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${appointment.date}',
                                          style: TextStyle(
                                            color: AppColors.textBlack,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // TODO: Cancel logic
                                },
                                icon:
                                    const Icon(Icons.close, color: AppColors.error),
                                label: const Text('Cancel',
                                    style: TextStyle(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.bold)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: AppColors.error, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // TODO: Reschedule logic
                                },
                                icon: const Icon(Icons.calendar_month,
                                    color: Colors.white),
                                label: const Text('Reschedule',
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton(
      String text, Color bg, Color fg, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

    // Remove dummy data method - now using real API data
  }
