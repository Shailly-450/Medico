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