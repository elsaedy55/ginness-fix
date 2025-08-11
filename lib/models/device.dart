class Device {
  final int? id;
  final String deviceId;
  final String serialNumber;
  final String clientName;
  final String clientPhone1;
  final String clientPhone2;
  final String gender;
  final String deviceCategory;
  final String brand;
  final String model;
  final String operatingSystem;
  final String faultType;
  final String faultDescription;
  final String status;
  final double totalAmount;
  final double advanceAmount;
  final double remainingAmount;
  final String spareParts;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Device({
    this.id,
    required this.deviceId,
    required this.serialNumber,
    required this.clientName,
    required this.clientPhone1,
    this.clientPhone2 = '',
    required this.gender,
    required this.deviceCategory,
    required this.brand,
    required this.model,
    required this.operatingSystem,
    required this.faultType,
    required this.faultDescription,
    this.status = 'في الانتظار',
    this.totalAmount = 0.0,
    this.advanceAmount = 0.0,
    this.remainingAmount = 0.0,
    this.spareParts = '',
    required this.createdAt,
    this.updatedAt,
  });

  // تحويل إلى Map للحفظ في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'device_id': deviceId,
      'serial_number': serialNumber,
      'client_name': clientName,
      'client_phone1': clientPhone1,
      'client_phone2': clientPhone2,
      'gender': gender,
      'device_category': deviceCategory,
      'brand': brand,
      'model': model,
      'operating_system': operatingSystem,
      'fault_type': faultType,
      'fault_description': faultDescription,
      'status': status,
      'total_amount': totalAmount,
      'advance_amount': advanceAmount,
      'remaining_amount': remainingAmount,
      'spare_parts': spareParts,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // إنشاء من Map (من قاعدة البيانات)
  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      id: map['id'] as int?,
      deviceId: map['device_id'] ?? '',
      serialNumber: map['serial_number'] ?? '',
      clientName: map['client_name'] ?? '',
      clientPhone1: map['client_phone1'] ?? '',
      clientPhone2: map['client_phone2'] ?? '',
      gender: map['gender'] ?? '',
      deviceCategory: map['device_category'] ?? '',
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      operatingSystem: map['operating_system'] ?? '',
      faultType: map['fault_type'] ?? '',
      faultDescription: map['fault_description'] ?? '',
      status: map['status'] ?? 'في الانتظار',
      totalAmount: _parseDouble(map['total_amount']),
      advanceAmount: _parseDouble(map['advance_amount']),
      remainingAmount: _parseDouble(map['remaining_amount']),
      spareParts: map['spare_parts'] ?? '',
      createdAt: _parseDateTime(map['created_at']),
      updatedAt:
          map['updated_at'] != null ? _parseDateTime(map['updated_at']) : null,
    );
  }

  // مساعد لتحويل التاريخ
  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  // مساعد لتحويل الأرقام
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // نسخة محدثة من الكائن
  Device copyWith({
    int? id,
    String? deviceId,
    String? serialNumber,
    String? clientName,
    String? clientPhone1,
    String? clientPhone2,
    String? gender,
    String? deviceCategory,
    String? brand,
    String? model,
    String? operatingSystem,
    String? faultType,
    String? faultDescription,
    String? status,
    double? totalAmount,
    double? advanceAmount,
    double? remainingAmount,
    String? spareParts,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Device(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      serialNumber: serialNumber ?? this.serialNumber,
      clientName: clientName ?? this.clientName,
      clientPhone1: clientPhone1 ?? this.clientPhone1,
      clientPhone2: clientPhone2 ?? this.clientPhone2,
      gender: gender ?? this.gender,
      deviceCategory: deviceCategory ?? this.deviceCategory,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      operatingSystem: operatingSystem ?? this.operatingSystem,
      faultType: faultType ?? this.faultType,
      faultDescription: faultDescription ?? this.faultDescription,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      advanceAmount: advanceAmount ?? this.advanceAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      spareParts: spareParts ?? this.spareParts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Device(id: $id, deviceId: $deviceId, clientName: $clientName, brand: $brand, model: $model, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Device && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
