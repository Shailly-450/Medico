class PatientRecord {
  final String name;
  final int age;
  final String gender;
  final String email;
  final String phone;
  final String address;
  final String insuranceProvider;
  final String insuranceNumber;
  final String emergencyContact;
  final List<String> medicalHistory;
  final List<String> currentMedications;
  final List<String> allergies;
  final Map<String, String>
      vitals; // e.g. {'Blood Pressure': '120/80', 'HR': '72 bpm'}
  final List<Map<String, String>> labResults; // {'Test': 'Result'}
  final List<String> recentAppointments; // could be IDs or descriptions
  final List<String> recentPrescriptions; // IDs or brief desc

  const PatientRecord({
    required this.name,
    required this.age,
    required this.gender,
    required this.email,
    required this.phone,
    required this.address,
    required this.insuranceProvider,
    required this.insuranceNumber,
    required this.emergencyContact,
    required this.medicalHistory,
    required this.currentMedications,
    required this.allergies,
    required this.vitals,
    required this.labResults,
    required this.recentAppointments,
    required this.recentPrescriptions,
  });
}
