import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../home/widgets/appointment_card.dart';
import '../../core/services/pre_approval_service.dart';

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
    final RRect rRect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
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
  List<Appointment> allAppointments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // TODO: Replace with real data source
    allAppointments = _dummyAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Appointment> _filterAppointments(String status) {
    final now = DateTime.now();
    if (status == 'Upcoming') {
      return allAppointments.where((a) => _parseDate(a.date, a.time).isAfter(now) && a.preApprovalStatus != PreApprovalStatus.rejected).toList();
    } else if (status == 'Completed') {
      return allAppointments.where((a) => _parseDate(a.date, a.time).isBefore(now) && a.preApprovalStatus != PreApprovalStatus.rejected).toList();
    } else {
      // Canceled (dummy: rejected pre-approval)
      return allAppointments.where((a) => a.preApprovalStatus == PreApprovalStatus.rejected).toList();
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
    final tabPadding = screenWidth / 3; // 1/3 of screen for each tab, so 1/9 padding on each side
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
    final filtered = _filterAppointments(status);
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
                          backgroundImage: NetworkImage(appointment.doctorImage),
                          child: appointment.doctorImage.isEmpty
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.secondary.withOpacity(0.3),
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
                                        Text(
                                          'In Person',
                                          style: TextStyle(
                                            color: AppColors.secondary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
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
                                      '${appointment.date} · ${appointment.time}',
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
                            icon: const Icon(Icons.close, color: AppColors.error),
                            label: const Text('Cancel', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.error, width: 1.5),
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
                            icon: const Icon(Icons.calendar_month, color: Colors.white),
                            label: const Text('Reschedule', style: TextStyle(fontWeight: FontWeight.bold)),
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
  }

  Widget _buildActionButton(String text, Color bg, Color fg, VoidCallback onTap) {
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

  List<Appointment> _dummyAppointments() {
    // TODO: Replace with real data source
    return [
      Appointment(
        id: '1',
        doctorName: 'Dr. Doctor Name',
        doctorImage: 'https://randomuser.me/api/portraits/men/11.jpg',
        specialty: 'Therapist',
        isVideoCall: false,
        date: '2024-10-05',
        time: '21:00',
        preApprovalStatus: PreApprovalStatus.approved,
      ),
      Appointment(
        id: '2',
        doctorName: 'Dr. Doctor Name',
        doctorImage: 'https://randomuser.me/api/portraits/men/11.jpg',
        specialty: 'Therapist',
        isVideoCall: false,
        date: '2024-10-05',
        time: '21:00',
        preApprovalStatus: PreApprovalStatus.approved,
      ),
      Appointment(
        id: '3',
        doctorName: 'Dr. Doctor Name',
        doctorImage: 'https://randomuser.me/api/portraits/men/11.jpg',
        specialty: 'Therapist',
        isVideoCall: false,
        date: '2024-10-05',
        time: '21:00',
        preApprovalStatus: PreApprovalStatus.rejected,
      ),
    ];
  }
} 