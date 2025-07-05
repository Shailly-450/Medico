class HealthRecord {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String category;
  final String provider;
  final String providerImage;
  final Map<String, dynamic> data;
  final String? attachmentUrl;
  final bool isImportant;
  final String status;
  final String familyMemberId; // Add this field

  HealthRecord({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.category,
    required this.provider,
    required this.providerImage,
    required this.data,
    this.attachmentUrl,
    this.isImportant = false,
    this.status = 'completed',
    required this.familyMemberId, // Add this parameter
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String,
      provider: json['provider'] as String,
      providerImage: json['providerImage'] as String,
      data: json['data'] as Map<String, dynamic>,
      attachmentUrl: json['attachmentUrl'] as String?,
      isImportant: json['isImportant'] as bool? ?? false,
      status: json['status'] as String? ?? 'completed',
      familyMemberId: json['familyMemberId'] as String, // Add this field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'category': category,
      'provider': provider,
      'providerImage': providerImage,
      'data': data,
      'attachmentUrl': attachmentUrl,
      'isImportant': isImportant,
      'status': status,
      'familyMemberId': familyMemberId, // Add this field
    };
  }

  static List<HealthRecord> dummyList() {
    return [
      // John Doe (Father) - ID: 1
      HealthRecord(
        id: 'rec1',
        title: 'Annual Physical Exam',
        description: 'Routine annual checkup and blood work.',
        date: DateTime.now().subtract(const Duration(days: 30)),
        category: 'Vital Signs',
        provider: 'City Health Clinic',
        providerImage: 'https://randomuser.me/api/portraits/men/10.jpg',
        data: {
          'vitalSigns': {
            'bloodPressureSystolic': 120.0,
            'bloodPressureDiastolic': 80.0,
            'heartRate': 72,
            'temperature': 36.8,
            'oxygenSaturation': 98,
            'weight': 70.5,
            'height': 175.0,
            'date': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
          },
        },
        attachmentUrl: null,
        isImportant: true,
        status: 'completed',
        familyMemberId: '1',
      ),
      HealthRecord(
        id: 'rec2',
        title: 'Blood Test - CBC',
        description: 'Complete blood count lab result.',
        date: DateTime.now().subtract(const Duration(days: 28)),
        category: 'Lab Results',
        provider: 'LabCorp',
        providerImage: 'https://randomuser.me/api/portraits/women/11.jpg',
        data: {
          'labResults': [
            {
              'testName': 'Hemoglobin',
              'result': '13.5',
              'unit': 'g/dL',
              'normalRange': '13.0-17.0',
              'status': 'normal',
              'date': DateTime.now().subtract(const Duration(days: 28)).toIso8601String(),
              'labName': 'LabCorp',
            },
          ],
        },
        attachmentUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        isImportant: false,
        status: 'completed',
        familyMemberId: '1',
      ),
      HealthRecord(
        id: 'rec3',
        title: 'Cholesterol Screening',
        description: 'Annual cholesterol and lipid panel.',
        date: DateTime.now().subtract(const Duration(days: 45)),
        category: 'Lab Results',
        provider: 'Metro Medical Lab',
        providerImage: 'https://randomuser.me/api/portraits/men/20.jpg',
        data: {
          'labResults': [
            {
              'testName': 'Total Cholesterol',
              'result': '210',
              'unit': 'mg/dL',
              'normalRange': '<200',
              'status': 'high',
              'date': DateTime.now().subtract(const Duration(days: 45)).toIso8601String(),
              'labName': 'Metro Medical Lab',
            },
            {
              'testName': 'HDL Cholesterol',
              'result': '45',
              'unit': 'mg/dL',
              'normalRange': '>40',
              'status': 'normal',
              'date': DateTime.now().subtract(const Duration(days: 45)).toIso8601String(),
              'labName': 'Metro Medical Lab',
            },
          ],
        },
        attachmentUrl: null,
        isImportant: true,
        status: 'completed',
        familyMemberId: '1',
      ),
      HealthRecord(
        id: 'rec4',
        title: 'Dental Cleaning',
        description: 'Routine dental cleaning and checkup.',
        date: DateTime.now().subtract(const Duration(days: 60)),
        category: 'Procedures',
        provider: 'Bright Smile Dental',
        providerImage: 'https://randomuser.me/api/portraits/women/21.jpg',
        data: {
          'procedure': 'Dental Cleaning',
          'duration': '45 minutes',
          'notes': 'No cavities found, gums healthy',
        },
        attachmentUrl: null,
        isImportant: false,
        status: 'completed',
        familyMemberId: '1',
      ),
      HealthRecord(
        id: 'rec5',
        title: 'Blood Pressure Medication',
        description: 'Prescribed Lisinopril for hypertension.',
        date: DateTime.now().subtract(const Duration(days: 90)),
        category: 'Medications',
        provider: 'Dr. Michael Brown',
        providerImage: 'https://randomuser.me/api/portraits/men/22.jpg',
        data: {
          'medication': 'Lisinopril',
          'dosage': '10mg',
          'frequency': '1x daily',
          'duration': 'Ongoing',
          'reason': 'Hypertension management',
        },
        attachmentUrl: null,
        isImportant: true,
        status: 'active',
        familyMemberId: '1',
      ),

      // Sara Doe (Mom) - ID: 2
      HealthRecord(
        id: 'rec6',
        title: 'Chest X-Ray',
        description: 'X-ray for persistent cough.',
        date: DateTime.now().subtract(const Duration(days: 15)),
        category: 'Procedures',
        provider: 'Metro Imaging Center',
        providerImage: 'https://randomuser.me/api/portraits/men/12.jpg',
        data: {
          'procedure': 'Chest X-Ray',
          'findings': 'Normal chest X-ray, no abnormalities detected',
          'radiologist': 'Dr. Sarah Wilson',
        },
        attachmentUrl: 'https://dummyimage.com/600x400/000/fff.jpg&text=Chest+X-Ray',
        isImportant: false,
        status: 'completed',
        familyMemberId: '2',
      ),
      HealthRecord(
        id: 'rec7',
        title: 'COVID-19 Vaccination',
        description: 'Second dose of COVID-19 vaccine.',
        date: DateTime.now().subtract(const Duration(days: 90)),
        category: 'Immunizations',
        provider: 'Community Hospital',
        providerImage: 'https://randomuser.me/api/portraits/women/13.jpg',
        data: {
          'vaccine': 'Pfizer',
          'dose': 2,
          'lotNumber': 'PF123456',
        },
        attachmentUrl: null,
        isImportant: false,
        status: 'completed',
        familyMemberId: '2',
      ),
      HealthRecord(
        id: 'rec8',
        title: 'Annual Gynecological Exam',
        description: 'Routine gynecological checkup and Pap smear.',
        date: DateTime.now().subtract(const Duration(days: 120)),
        category: 'Procedures',
        provider: 'Women\'s Health Center',
        providerImage: 'https://randomuser.me/api/portraits/women/23.jpg',
        data: {
          'procedure': 'Pap Smear',
          'result': 'Normal',
          'nextDue': '1 year',
        },
        attachmentUrl: null,
        isImportant: false,
        status: 'completed',
        familyMemberId: '2',
      ),
      HealthRecord(
        id: 'rec9',
        title: 'Thyroid Function Test',
        description: 'TSH and T4 levels check.',
        date: DateTime.now().subtract(const Duration(days: 75)),
        category: 'Lab Results',
        provider: 'City Medical Lab',
        providerImage: 'https://randomuser.me/api/portraits/men/24.jpg',
        data: {
          'labResults': [
            {
              'testName': 'TSH',
              'result': '2.5',
              'unit': 'mIU/L',
              'normalRange': '0.4-4.0',
              'status': 'normal',
              'date': DateTime.now().subtract(const Duration(days: 75)).toIso8601String(),
              'labName': 'City Medical Lab',
            },
          ],
        },
        attachmentUrl: null,
        isImportant: false,
        status: 'completed',
        familyMemberId: '2',
      ),
      HealthRecord(
        id: 'rec10',
        title: 'Flu Shot',
        description: 'Annual influenza vaccination.',
        date: DateTime.now().subtract(const Duration(days: 45)),
        category: 'Immunizations',
        provider: 'Local Pharmacy',
        providerImage: 'https://randomuser.me/api/portraits/men/25.jpg',
        data: {
          'vaccine': 'Influenza',
          'dose': 1,
          'season': '2024-2025',
        },
        attachmentUrl: null,
        isImportant: false,
        status: 'completed',
        familyMemberId: '2',
      ),

      // Jak Doe (First-child) - ID: 3
      HealthRecord(
        id: 'rec11',
        title: 'Prescription - Amoxicillin',
        description: 'Prescribed for sinus infection.',
        date: DateTime.now().subtract(const Duration(days: 10)),
        category: 'Medications',
        provider: 'Dr. Smith',
        providerImage: 'https://randomuser.me/api/portraits/men/14.jpg',
        data: {
          'medication': 'Amoxicillin',
          'dosage': '500mg',
          'frequency': '3x daily',
          'duration': '7 days',
          'reason': 'Sinus infection',
        },
        attachmentUrl: null,
        isImportant: false,
        status: 'active',
        familyMemberId: '3',
      ),
      HealthRecord(
        id: 'rec12',
        title: 'Peanut Allergy',
        description: 'Food allergy diagnosis',
        date: DateTime.now().subtract(const Duration(days: 40)),
        category: 'Allergies',
        provider: 'Dr. Sarah Johnson',
        providerImage: 'https://randomuser.me/api/portraits/men/15.jpg',
        data: {
          'allergen': 'Peanuts',
          'severity': 'Moderate',
          'reaction': 'Hives, difficulty breathing',
          'epipen': 'Prescribed',
        },
        isImportant: true,
        status: 'completed',
        familyMemberId: '3',
      ),
      HealthRecord(
        id: 'rec13',
        title: 'Annual Pediatric Checkup',
        description: 'Routine annual checkup for child.',
        date: DateTime.now().subtract(const Duration(days: 180)),
        category: 'Vital Signs',
        provider: 'Children\'s Medical Center',
        providerImage: 'https://randomuser.me/api/portraits/women/16.jpg',
        data: {
          'vitalSigns': {
            'bloodPressureSystolic': 105.0,
            'bloodPressureDiastolic': 65.0,
            'heartRate': 88,
            'temperature': 36.9,
            'oxygenSaturation': 99,
            'weight': 28.0,
            'height': 125.0,
            'date': DateTime.now().subtract(const Duration(days: 180)).toIso8601String(),
          },
        },
        attachmentUrl: null,
        isImportant: false,
        status: 'completed',
        familyMemberId: '3',
      ),
      HealthRecord(
        id: 'rec14',
        title: 'Dental Checkup',
        description: 'Routine dental examination and cleaning.',
        date: DateTime.now().subtract(const Duration(days: 90)),
        category: 'Procedures',
        provider: 'Kids Dental Care',
        providerImage: 'https://randomuser.me/api/portraits/women/26.jpg',
        data: {
          'procedure': 'Dental Cleaning',
          'findings': 'One small cavity found and filled',
          'nextVisit': '6 months',
        },
        attachmentUrl: null,
        isImportant: false,
        status: 'completed',
        familyMemberId: '3',
      ),
      HealthRecord(
        id: 'rec15',
        title: 'Vision Screening',
        description: 'Annual eye examination.',
        date: DateTime.now().subtract(const Duration(days: 120)),
        category: 'Procedures',
        provider: 'Family Eye Care',
        providerImage: 'https://randomuser.me/api/portraits/men/27.jpg',
        data: {
          'procedure': 'Vision Screening',
          'result': '20/20 vision',
          'recommendations': 'No glasses needed',
        },
        attachmentUrl: null,
        isImportant: false,
        status: 'completed',
        familyMemberId: '3',
      ),
      HealthRecord(
        id: 'rec16',
        title: 'MMR Vaccination',
        description: 'Measles, Mumps, and Rubella vaccine.',
        date: DateTime.now().subtract(const Duration(days: 365)),
        category: 'Immunizations',
        provider: 'Pediatric Associates',
        providerImage: 'https://randomuser.me/api/portraits/women/28.jpg',
        data: {
          'vaccine': 'MMR',
          'dose': 2,
          'age': '4 years',
        },
        attachmentUrl: null,
        isImportant: false,
        status: 'completed',
        familyMemberId: '3',
      ),

      // Ben Doe (Second-child) - ID: 4
      HealthRecord(
        id: 'rec17',
        title: 'Annual Pediatric Checkup',
        description: 'Routine annual checkup for child.',
        date: DateTime.now().subtract(const Duration(days: 20)),
        category: 'Vital Signs',
        provider: 'Children\'s Medical Center',
        providerImage: 'https://randomuser.me/api/portraits/women/16.jpg',
        data: {
          'vitalSigns': {
            'bloodPressureSystolic': 110.0,
            'bloodPressureDiastolic': 70.0,
            'heartRate': 85,
            'temperature': 37.0,
            'oxygenSaturation': 99,
            'weight': 25.0,
            'height': 120.0,
            'date': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
          },
        },
        attachmentUrl: null,
        isImportant: false,
        status: 'completed',
        familyMemberId: '4',
      ),
      HealthRecord(
        id: 'rec18',
        title: 'Flu Shot',
        description: 'Annual flu vaccination.',
        date: DateTime.now().subtract(const Duration(days: 60)),
        category: 'Immunizations',
        provider: 'Community Pharmacy',
        providerImage: 'https://randomuser.me/api/portraits/men/17.jpg',
        data: {
          'vaccine': 'Influenza',
          'dose': 1,
          'season': '2024-2025',
        },
        attachmentUrl: null,
        isImportant: false,
        status: 'completed',
        familyMemberId: '4',
      ),
      HealthRecord(
        id: 'rec19',
        title: 'Ear Infection Treatment',
        description: 'Treatment for middle ear infection.',
        date: DateTime.now().subtract(const Duration(days: 5)),
        category: 'Medications',
        provider: 'Dr. Emily Davis',
        providerImage: 'https://randomuser.me/api/portraits/women/29.jpg',
        data: {
          'medication': 'Amoxicillin',
          'dosage': '400mg',
          'frequency': '2x daily',
          'duration': '10 days',
          'reason': 'Middle ear infection',
        },
        attachmentUrl: null,
        isImportant: false,
        status: 'active',
        familyMemberId: '4',
      ),
      HealthRecord(
        id: 'rec20',
        title: 'Asthma Diagnosis',
        description: 'Diagnosed with mild asthma.',
        date: DateTime.now().subtract(const Duration(days: 200)),
        category: 'Conditions',
        provider: 'Dr. Robert Wilson',
        providerImage: 'https://randomuser.me/api/portraits/men/30.jpg',
        data: {
          'condition': 'Asthma',
          'severity': 'Mild',
          'triggers': 'Exercise, cold air',
          'treatment': 'Albuterol inhaler as needed',
        },
        attachmentUrl: null,
        isImportant: true,
        status: 'completed',
        familyMemberId: '4',
      ),
      HealthRecord(
        id: 'rec21',
        title: 'Dental Cleaning',
        description: 'Routine dental cleaning for toddler.',
        date: DateTime.now().subtract(const Duration(days: 150)),
        category: 'Procedures',
        provider: 'Tiny Teeth Dental',
        providerImage: 'https://randomuser.me/api/portraits/women/31.jpg',
        data: {
          'procedure': 'Dental Cleaning',
          'findings': 'Healthy teeth and gums',
          'nextVisit': '6 months',
        },
        attachmentUrl: null,
        isImportant: false,
        status: 'completed',
        familyMemberId: '4',
      ),
      HealthRecord(
        id: 'rec22',
        title: 'DTaP Vaccination',
        description: 'Diphtheria, Tetanus, and Pertussis vaccine.',
        date: DateTime.now().subtract(const Duration(days: 300)),
        category: 'Immunizations',
        provider: 'Pediatric Associates',
        providerImage: 'https://randomuser.me/api/portraits/women/28.jpg',
        data: {
          'vaccine': 'DTaP',
          'dose': 4,
          'age': '18 months',
        },
        attachmentUrl: null,
        isImportant: false,
        status: 'completed',
        familyMemberId: '4',
      ),
    ];
  }
}

class VitalSigns {
  final double bloodPressureSystolic;
  final double bloodPressureDiastolic;
  final int heartRate;
  final double temperature;
  final int oxygenSaturation;
  final double weight;
  final double height;
  final DateTime date;

  VitalSigns({
    required this.bloodPressureSystolic,
    required this.bloodPressureDiastolic,
    required this.heartRate,
    required this.temperature,
    required this.oxygenSaturation,
    required this.weight,
    required this.height,
    required this.date,
  });

  factory VitalSigns.fromJson(Map<String, dynamic> json) {
    return VitalSigns(
      bloodPressureSystolic: json['bloodPressureSystolic'] as double,
      bloodPressureDiastolic: json['bloodPressureDiastolic'] as double,
      heartRate: json['heartRate'] as int,
      temperature: json['temperature'] as double,
      oxygenSaturation: json['oxygenSaturation'] as int,
      weight: json['weight'] as double,
      height: json['height'] as double,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bloodPressureSystolic': bloodPressureSystolic,
      'bloodPressureDiastolic': bloodPressureDiastolic,
      'heartRate': heartRate,
      'temperature': temperature,
      'oxygenSaturation': oxygenSaturation,
      'weight': weight,
      'height': height,
      'date': date.toIso8601String(),
    };
  }
}

class LabResult {
  final String testName;
  final String result;
  final String unit;
  final String normalRange;
  final String status; // normal, high, low, critical
  final DateTime date;
  final String labName;

  LabResult({
    required this.testName,
    required this.result,
    required this.unit,
    required this.normalRange,
    required this.status,
    required this.date,
    required this.labName,
  });

  factory LabResult.fromJson(Map<String, dynamic> json) {
    return LabResult(
      testName: json['testName'] as String,
      result: json['result'] as String,
      unit: json['unit'] as String,
      normalRange: json['normalRange'] as String,
      status: json['status'] as String,
      date: DateTime.parse(json['date'] as String),
      labName: json['labName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'testName': testName,
      'result': result,
      'unit': unit,
      'normalRange': normalRange,
      'status': status,
      'date': date.toIso8601String(),
      'labName': labName,
    };
  }
} 