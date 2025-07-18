import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import '../../core/theme/app_colors.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final Appointment appointment;
  final String appointmentId;
  final String patientName;
  final String gender;
  final int age;
  final String problem;
  final String duration;
  final double price;
  final bool isPaid;

  const AppointmentDetailScreen({
    Key? key,
    required this.appointment,
    required this.appointmentId,
    required this.patientName,
    required this.gender,
    required this.age,
    required this.problem,
    this.duration = '30 minutes',
    this.price = 60.0,
    this.isPaid = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF2E7D32), // Dark green for back button
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Appointment #$appointmentId',
          style: const TextStyle(
            color: Color(0xFF2E7D32), // Dark green for title
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFE8F5E8), // Light mint green
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8F5E8), // Light mint green
              Color(0xFFF0F8F0), // Very light sage
              Color(0xFFE6F3E6), // Soft green tint
              Color(0xFFF5F9F5), // Almost white with green tint
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Doctor Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF2E7D32).withOpacity(0.1),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF2E7D32).withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF2E7D32)
                                        .withOpacity(0.1),
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 28,
                                  backgroundImage:
                                      NetworkImage(appointment.doctorImage),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appointment.doctorName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Color(0xFF2E7D32), // Dark green
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    appointment.specialty,
                                    style: TextStyle(
                                      color: const Color(0xFF2E7D32)
                                          .withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Appointment Details
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF2E7D32).withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _detailRow('Date', appointment.date,
                                  highlight: true),
                              _detailRow('Time', appointment.time),
                              _detailRow('Duration', duration),
                              _detailRow('Name', patientName, highlight: true),
                              _detailRow('Gender', gender),
                              _detailRow('Age', age.toString()),
                              _detailRow('Problem', problem, isProblem: true),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Video Call Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF2E7D32).withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E8),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF2E7D32)
                                        .withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: const Icon(Icons.videocam,
                                    color: Color(0xFF2E7D32), size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Video Call',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF2E7D32),
                                        )),
                                    const SizedBox(height: 2),
                                    Text('Video call with doctor',
                                        style: TextStyle(
                                            color: const Color(0xFF2E7D32)
                                                .withOpacity(0.7),
                                            fontSize: 13)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(' 24${price.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Color(0xFF2E7D32))),
                                  Text(isPaid ? '(paid)' : '',
                                      style: TextStyle(
                                          color: const Color(0xFF2E7D32)
                                              .withOpacity(0.7),
                                          fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Message Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                            onPressed: () {},
                            child: Text(
                                'Message (Start at ${appointment.time.split('-').first.trim()})',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value,
      {bool highlight = false, bool isProblem = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment:
            isProblem ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: const Color(0xFF2E7D32).withOpacity(0.7),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: highlight || isProblem
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFF2E7D32).withOpacity(0.9),
                fontWeight:
                    highlight || isProblem ? FontWeight.bold : FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
