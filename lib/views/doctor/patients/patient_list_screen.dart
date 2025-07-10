import 'package:flutter/material.dart';
import 'package:medico/models/patient_record.dart';
import 'package:medico/views/auth/login_screen.dart';
import 'package:medico/views/doctor/patients/patient_summary_screen.dart';
import 'package:medico/views/doctor/patients/widgets/patient_card.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  // Mock data for patient list
  final List<PatientRecord> _patients = [
    const PatientRecord(
      name: 'John Doe',
      age: 45,
      gender: 'Male',
      email: 'john.doe@example.com',
      phone: '555-1234',
      address: '123 Main St, Anytown, USA',
      insuranceProvider: 'HealthCo',
      insuranceNumber: 'HC123456789',
      emergencyContact: 'Jane Doe (555-4321)',
      medicalHistory: ['Hypertension', 'Type 2 Diabetes'],
      currentMedications: ['Lisinopril 10mg', 'Metformin 500mg'],
      allergies: ['Pollen'],
      vitals: {'Blood Pressure': '130/85 mmHg', 'Heart Rate': '72 bpm'},
      labResults: [
        {'Test': 'HbA1c', 'Result': '6.5%'}
      ],
      recentAppointments: ['2023-03-20: Dr. Smith'],
      recentPrescriptions: ['Lisinopril (2023-03-20)'],
    ),
    const PatientRecord(
      name: 'Jane Smith',
      age: 34,
      gender: 'Female',
      email: 'jane.smith@example.com',
      phone: '555-5678',
      address: '456 Oak Ave, Anytown, USA',
      insuranceProvider: 'MediCare',
      insuranceNumber: 'MC987654321',
      emergencyContact: 'John Smith (555-8765)',
      medicalHistory: ['Asthma'],
      currentMedications: ['Albuterol Inhaler'],
      allergies: ['Peanuts'],
      vitals: {'Blood Pressure': '120/80 mmHg', 'Heart Rate': '68 bpm'},
      labResults: [],
      recentAppointments: ['2023-04-10: Dr. Emily'],
      recentPrescriptions: ['Albuterol (2023-04-10)'],
    ),
    const PatientRecord(
      name: 'Peter Jones',
      age: 62,
      gender: 'Male',
      email: 'peter.jones@example.com',
      phone: '555-9876',
      address: '789 Pine Ln, Anytown, USA',
      insuranceProvider: 'WellLife',
      insuranceNumber: 'WL555555555',
      emergencyContact: 'Mary Jones (555-6789)',
      medicalHistory: ['Arthritis'],
      currentMedications: ['Ibuprofen 200mg'],
      allergies: [],
      vitals: {'Blood Pressure': '128/82 mmHg', 'Heart Rate': '75 bpm'},
      labResults: [],
      recentAppointments: ['2023-02-15: Follow-up'],
      recentPrescriptions: [],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Patients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _patients.length,
        itemBuilder: (context, index) {
          final patient = _patients[index];
          return PatientCard(
            patient: patient,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PatientSummaryScreen(record: patient),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
