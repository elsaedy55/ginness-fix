// استيراد Device model
import 'device.dart';

class DeviceHistory {
  final int? id;
  final String deviceId; // رقم الجهاز (يمكن تكراره)
  final String deviceCategory;
  final String brand;
  final String model;
  final String operatingSystem;
  final String clientName;
  final String gender;
  final String clientPhone1;
  final String clientPhone2;
  final String faultType;
  final String faultDescription;
  final String spareParts;
  final String status;
  final double totalAmount;
  final double advanceAmount;
  final double remainingAmount;
  final DateTime entryDate; // تاريخ دخول هذا العطل
  final DateTime? completionDate; // تاريخ إكمال الإصلاح
  final String notes; // ملاحظات إضافية
  final DateTime createdAt;

  DeviceHistory({
    this.id,
    required this.deviceId,
    required this.deviceCategory,
    required this.brand,
    required this.model,
    required this.operatingSystem,
    required this.clientName,
    required this.gender,
    required this.clientPhone1,
    this.clientPhone2 = '',
    required this.faultType,
    required this.faultDescription,
    this.spareParts = '',
    required this.status,
    required this.totalAmount,
    required this.advanceAmount,
    required this.remainingAmount,
    required this.entryDate,
    this.completionDate,
    this.notes = '',
    required this.createdAt,
  });

  // تحويل إلى Map للحفظ في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'device_id': deviceId,
      'device_category': deviceCategory,
      'brand': brand,
      'model': model,
      'operating_system': operatingSystem,
      'client_name': clientName,
      'gender': gender,
      'client_phone1': clientPhone1,
      'client_phone2': clientPhone2.isEmpty ? null : clientPhone2,
      'fault_type': faultType,
      'fault_description': faultDescription,
      'spare_parts': spareParts.isEmpty ? null : spareParts,
      'status': status,
      'total_amount': totalAmount,
      'advance_amount': advanceAmount,
      'remaining_amount': remainingAmount,
      'entry_date': entryDate.toIso8601String(),
      'completion_date': completionDate?.toIso8601String(),
      'notes': notes.isEmpty ? null : notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // إنشاء من Map (من قاعدة البيانات)
  factory DeviceHistory.fromMap(Map<String, dynamic> map) {
    return DeviceHistory(
      id: map['id'] as int?,
      deviceId: map['device_id'] ?? '',
      deviceCategory: map['device_category'] ?? '',
      brand: map['brand'] ?? '',
      model: map['model'] ?? '',
      operatingSystem: map['operating_system'] ?? '',
      clientName: map['client_name'] ?? '',
      gender: map['gender'] ?? '',
      clientPhone1: map['client_phone1'] ?? '',
      clientPhone2: map['client_phone2'] ?? '',
      faultType: map['fault_type'] ?? '',
      faultDescription: map['fault_description'] ?? '',
      spareParts: map['spare_parts'] ?? '',
      status: map['status'] ?? 'في الانتظار',
      totalAmount: _parseDouble(map['total_amount']),
      advanceAmount: _parseDouble(map['advance_amount']),
      remainingAmount: _parseDouble(map['remaining_amount']),
      entryDate: _parseDateTime(map['entry_date']),
      completionDate:
          map['completion_date'] != null
              ? _parseDateTime(map['completion_date'])
              : null,
      notes: map['notes'] ?? '',
      createdAt: _parseDateTime(map['created_at']),
    );
  }

  // إنشاء من Device (للسجل الحالي)
  factory DeviceHistory.fromDevice(Device device, {String notes = ''}) {
    return DeviceHistory(
      deviceId: device.deviceId,
      deviceCategory: device.deviceCategory,
      brand: device.brand,
      model: device.model,
      operatingSystem: device.operatingSystem,
      clientName: device.clientName,
      gender: device.gender,
      clientPhone1: device.clientPhone1,
      clientPhone2: device.clientPhone2,
      faultType: device.faultType,
      faultDescription: device.faultDescription,
      spareParts: device.spareParts,
      status: device.status,
      totalAmount: device.totalAmount,
      advanceAmount: device.advanceAmount,
      remainingAmount: device.remainingAmount,
      entryDate: device.createdAt,
      completionDate: device.status == 'مكتمل' ? DateTime.now() : null,
      notes: notes,
      createdAt: DateTime.now(),
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
  DeviceHistory copyWith({
    int? id,
    String? deviceId,
    String? deviceCategory,
    String? brand,
    String? model,
    String? operatingSystem,
    String? clientName,
    String? gender,
    String? clientPhone1,
    String? clientPhone2,
    String? faultType,
    String? faultDescription,
    String? spareParts,
    String? status,
    double? totalAmount,
    double? advanceAmount,
    double? remainingAmount,
    DateTime? entryDate,
    DateTime? completionDate,
    String? notes,
    DateTime? createdAt,
  }) {
    return DeviceHistory(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      deviceCategory: deviceCategory ?? this.deviceCategory,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      operatingSystem: operatingSystem ?? this.operatingSystem,
      clientName: clientName ?? this.clientName,
      gender: gender ?? this.gender,
      clientPhone1: clientPhone1 ?? this.clientPhone1,
      clientPhone2: clientPhone2 ?? this.clientPhone2,
      faultType: faultType ?? this.faultType,
      faultDescription: faultDescription ?? this.faultDescription,
      spareParts: spareParts ?? this.spareParts,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      advanceAmount: advanceAmount ?? this.advanceAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      entryDate: entryDate ?? this.entryDate,
      completionDate: completionDate ?? this.completionDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'DeviceHistory(id: $id, deviceId: $deviceId, faultType: $faultType, status: $status, entryDate: $entryDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeviceHistory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
