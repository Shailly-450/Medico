class Insurance {
  final String id;
  final String userId;
  final String insuranceProvider;
  final String policyNumber;
  final String policyHolderName;
  final DateTime validFrom;
  final DateTime validTo;
  final String? insuranceCard;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Insurance({
    required this.id,
    required this.userId,
    required this.insuranceProvider,
    required this.policyNumber,
    required this.policyHolderName,
    required this.validFrom,
    required this.validTo,
    this.insuranceCard,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Insurance.fromJson(Map<String, dynamic> json) {
    return Insurance(
      id: json['_id'] as String,
      userId: json['user'] as String, // API uses 'user' instead of 'userId'
      insuranceProvider: json['insuranceProvider'] as String,
      policyNumber: json['policyNumber'] as String,
      policyHolderName: json['policyHolderName'] as String,
      validFrom: DateTime.parse(json['validFrom'] as String),
      validTo: DateTime.parse(json['validTo'] as String),
      insuranceCard: json['insuranceCard'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'user': userId, // API expects 'user' instead of 'userId'
    'insuranceProvider': insuranceProvider,
    'policyNumber': policyNumber,
    'policyHolderName': policyHolderName,
    'validFrom': validFrom.toIso8601String().split('T')[0],
    'validTo': validTo.toIso8601String().split('T')[0],
    'status': status,
    if (insuranceCard != null) 'insuranceCard': insuranceCard,
  };

  bool get isValid {
    final now = DateTime.now();
    return now.isAfter(validFrom) && now.isBefore(validTo);
  }

  int get daysUntilExpiry {
    return validTo.difference(DateTime.now()).inDays;
  }

  bool get isExpiringSoon {
    final daysLeft = daysUntilExpiry;
    return daysLeft >= 0 && daysLeft <= 30;
  }
}
