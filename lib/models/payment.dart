class Payment {
  final int? id;
  final int deviceId;
  final double amount;
  final String type; // 'مقدم' أو 'دفعة'
  final String notes;
  final DateTime createdAt;

  Payment({
    this.id,
    required this.deviceId,
    required this.amount,
    required this.type,
    this.notes = '',
    required this.createdAt,
  });

  // تحويل إلى Map للحفظ في قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'device_id': deviceId,
      'amount': amount,
      'type': type,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // إنشاء من Map (من قاعدة البيانات)
  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as int?,
      deviceId: map['device_id'] as int,
      amount: _parseDouble(map['amount']),
      type: map['type'] ?? 'دفعة',
      notes: map['notes'] ?? '',
      createdAt: _parseDateTime(map['created_at']),
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
  Payment copyWith({
    int? id,
    int? deviceId,
    double? amount,
    String? type,
    String? notes,
    DateTime? createdAt,
  }) {
    return Payment(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Payment(id: $id, deviceId: $deviceId, amount: $amount, type: $type, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Payment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
