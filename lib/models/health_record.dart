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
    };
  }

  static List<HealthRecord> dummyList() {
    return [
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
            {
              'testName': 'WBC',
              'result': '6.2',
              'unit': 'x10^3/uL',
              'normalRange': '4.0-10.0',
              'status': 'normal',
              'date': DateTime.now().subtract(const Duration(days: 28)).toIso8601String(),
              'labName': 'LabCorp',
            },
          ],
        },
        attachmentUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        isImportant: false,
        status: 'completed',
      ),
      HealthRecord(
        id: 'rec3',
        title: 'Chest X-Ray',
        description: 'X-ray for persistent cough.',
        date: DateTime.now().subtract(const Duration(days: 15)),
        category: 'Procedures',
        provider: 'Metro Imaging Center',
        providerImage: 'https://randomuser.me/api/portraits/men/12.jpg',
        data: {},
        attachmentUrl: 'https://dummyimage.com/600x400/000/fff.jpg&text=Chest+X-Ray',
        isImportant: false,
        status: 'completed',
      ),
      HealthRecord(
        id: 'rec4',
        title: 'COVID-19 Vaccination',
        description: 'Second dose of COVID-19 vaccine.',
        date: DateTime.now().subtract(const Duration(days: 90)),
        category: 'Immunizations',
        provider: 'Community Hospital',
        providerImage: 'https://randomuser.me/api/portraits/women/13.jpg',
        data: {
          'vaccine': 'Pfizer',
          'dose': 2,
        },
        attachmentUrl: null,
        isImportant: false,
        status: 'completed',
      ),
      HealthRecord(
        id: 'rec5',
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
        },
        attachmentUrl: null,
        isImportant: false,
        status: 'active',
      ),
      HealthRecord(
        id: 'rec6',
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
        },
        isImportant: true,
        status: 'completed',
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