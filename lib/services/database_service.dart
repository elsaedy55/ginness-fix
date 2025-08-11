import 'package:postgres/postgres.dart';
import 'package:flutter/foundation.dart';
import '../models/device.dart';
import '../models/payment.dart';
import '../models/device_history.dart';

class DatabaseService {
  static Connection? _connection;
  static const String _connectionString =
      'postgresql://neondb_owner:npg_szwaT9pJiOP3@ep-hidden-sound-abt6zp12-pooler.eu-west-2.aws.neon.tech/neondb';

  // إنشاء اتصال بقاعدة البيانات
  static Future<Connection> _getConnection() async {
    if (_connection != null) {
      return _connection!;
    }

    try {
      _connection = await Connection.open(
        Endpoint(
          host: 'ep-hidden-sound-abt6zp12-pooler.eu-west-2.aws.neon.tech',
          database: 'neondb',
          username: 'neondb_owner',
          password: 'npg_szwaT9pJiOP3',
          port: 5432,
        ),
        settings: const ConnectionSettings(sslMode: SslMode.require),
      );

      // إنشاء الجدول إذا لم يكن موجوداً
      await _createTableIfNotExists();

      return _connection!;
    } catch (e) {
      debugPrint('خطأ في الاتصال بقاعدة البيانات: $e');
      rethrow;
    }
  }

  // إنشاء جدول الأجهزة
  static Future<void> _createTableIfNotExists() async {
    try {
      await _connection!.execute('''
        CREATE TABLE IF NOT EXISTS devices (
          id SERIAL PRIMARY KEY,
          device_id VARCHAR(50) UNIQUE NOT NULL,
          client_name VARCHAR(255) NOT NULL,
          client_phone1 VARCHAR(20) NOT NULL,
          client_phone2 VARCHAR(20),
          gender VARCHAR(10) NOT NULL,
          device_category VARCHAR(50) NOT NULL,
          brand VARCHAR(100) NOT NULL,
          model VARCHAR(100) NOT NULL,
          operating_system VARCHAR(50) NOT NULL,
          fault_type VARCHAR(50) NOT NULL,
          fault_description TEXT NOT NULL,
          status VARCHAR(20) DEFAULT 'في الانتظار',
          total_amount DECIMAL(10,2) DEFAULT 0.00,
          advance_amount DECIMAL(10,2) DEFAULT 0.00,
          remaining_amount DECIMAL(10,2) DEFAULT 0.00,
          spare_parts TEXT,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP
        );
      ''');

      // إنشاء فهرس للبحث السريع
      await _connection!.execute(
        'CREATE INDEX IF NOT EXISTS idx_device_id ON devices(device_id);',
      );
      await _connection!.execute(
        'CREATE INDEX IF NOT EXISTS idx_status ON devices(status);',
      );
      await _connection!.execute(
        'CREATE INDEX IF NOT EXISTS idx_created_at ON devices(created_at);',
      );

      // إنشاء جدول الدفعات
      await _connection!.execute('''
        CREATE TABLE IF NOT EXISTS payments (
          id SERIAL PRIMARY KEY,
          device_id INTEGER NOT NULL,
          amount DECIMAL(10,2) NOT NULL,
          type VARCHAR(20) NOT NULL,
          notes TEXT,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE
        );
      ''');

      // إنشاء فهرس للدفعات
      await _connection!.execute(
        'CREATE INDEX IF NOT EXISTS idx_payments_device_id ON payments(device_id);',
      );
      await _connection!.execute(
        'CREATE INDEX IF NOT EXISTS idx_payments_created_at ON payments(created_at);',
      );

      // إنشاء جدول سجل الأجهزة
      await _connection!.execute('''
        CREATE TABLE IF NOT EXISTS device_history (
          id SERIAL PRIMARY KEY,
          device_id VARCHAR(50) NOT NULL,
          device_category VARCHAR(50) NOT NULL,
          brand VARCHAR(100) NOT NULL,
          model VARCHAR(100) NOT NULL,
          operating_system VARCHAR(50) NOT NULL,
          client_name VARCHAR(255) NOT NULL,
          gender VARCHAR(10) NOT NULL,
          client_phone1 VARCHAR(20) NOT NULL,
          client_phone2 VARCHAR(20),
          fault_type VARCHAR(100) NOT NULL,
          fault_description TEXT NOT NULL,
          spare_parts TEXT,
          status VARCHAR(20) NOT NULL DEFAULT 'في الانتظار',
          total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
          advance_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
          remaining_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
          entry_date TIMESTAMP NOT NULL,
          completion_date TIMESTAMP,
          notes TEXT,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
      ''');

      // إنشاء فهرس لسجل الأجهزة
      await _connection!.execute(
        'CREATE INDEX IF NOT EXISTS idx_history_device_id ON device_history(device_id);',
      );
      await _connection!.execute(
        'CREATE INDEX IF NOT EXISTS idx_history_entry_date ON device_history(entry_date);',
      );
      await _connection!.execute(
        'CREATE INDEX IF NOT EXISTS idx_history_status ON device_history(status);',
      );

      debugPrint('تم إنشاء الجدول والفهارس بنجاح');
    } catch (e) {
      debugPrint('خطأ في إنشاء الجدول: $e');
      rethrow;
    }
  }

  // إضافة جهاز جديد
  static Future<int> addDevice(Device device) async {
    try {
      final connection = await _getConnection();

      final result = await connection.execute(
        Sql.named('''
          INSERT INTO devices (
            device_id, client_name, client_phone1, client_phone2, gender,
            device_category, brand, model, operating_system, fault_type,
            fault_description, status, total_amount, advance_amount,
            remaining_amount, spare_parts, created_at
          ) VALUES (
            @device_id, @client_name, @client_phone1, @client_phone2, @gender,
            @device_category, @brand, @model, @operating_system, @fault_type,
            @fault_description, @status, @total_amount, @advance_amount,
            @remaining_amount, @spare_parts, @created_at
          ) RETURNING id
        '''),
        parameters: {
          'device_id': device.deviceId,
          'client_name': device.clientName,
          'client_phone1': device.clientPhone1,
          'client_phone2':
              device.clientPhone2.isEmpty ? null : device.clientPhone2,
          'gender': device.gender,
          'device_category': device.deviceCategory,
          'brand': device.brand,
          'model': device.model,
          'operating_system': device.operatingSystem,
          'fault_type': device.faultType,
          'fault_description': device.faultDescription,
          'status': device.status,
          'total_amount': device.totalAmount,
          'advance_amount': device.advanceAmount,
          'remaining_amount': device.remainingAmount,
          'spare_parts': device.spareParts.isEmpty ? null : device.spareParts,
          'created_at': device.createdAt.toIso8601String(),
        },
      );

      // تحويل القيمة بأمان من String إلى int
      final value = result[0][0];
      int deviceId;
      if (value is int) {
        deviceId = value;
      } else if (value is String) {
        deviceId = int.tryParse(value) ?? 0;
      } else {
        deviceId = 0;
      }

      // إضافة دفعة المقدم تلقائياً إذا كان أكبر من 0
      if (device.advanceAmount > 0) {
        final advancePayment = Payment(
          deviceId: deviceId,
          amount: device.advanceAmount,
          type: 'مقدم',
          notes: 'دفعة المقدم التلقائية عند إضافة الجهاز',
          createdAt: device.createdAt,
        );

        await addPayment(advancePayment);
      }

      return deviceId;
    } catch (e) {
      debugPrint('خطأ في إضافة الجهاز: $e');
      throw Exception('فشل في إضافة الجهاز: $e');
    }
  }

  // جلب جميع الأجهزة
  static Future<List<Device>> getAllDevices() async {
    try {
      final connection = await _getConnection();

      final result = await connection.execute('''
        SELECT * FROM devices 
        ORDER BY created_at DESC
      ''');

      return result.map((row) => Device.fromMap(row.toColumnMap())).toList();
    } catch (e) {
      debugPrint('خطأ في جلب الأجهزة: $e');
      throw Exception('فشل في جلب الأجهزة: $e');
    }
  }

  // جلب الأجهزة حسب الحالة
  static Future<List<Device>> getDevicesByStatus(String status) async {
    try {
      final connection = await _getConnection();

      final result = await connection.execute(
        Sql.named(
          'SELECT * FROM devices WHERE status = @status ORDER BY created_at DESC',
        ),
        parameters: {'status': status},
      );

      return result.map((row) => Device.fromMap(row.toColumnMap())).toList();
    } catch (e) {
      debugPrint('خطأ في جلب الأجهزة حسب الحالة: $e');
      throw Exception('فشل في جلب الأجهزة: $e');
    }
  }

  // البحث في الأجهزة
  static Future<List<Device>> searchDevices(String searchTerm) async {
    try {
      final connection = await _getConnection();

      final result = await connection.execute(
        Sql.named('''
          SELECT * FROM devices 
          WHERE device_id ILIKE @search 
             OR client_name ILIKE @search 
             OR brand ILIKE @search 
             OR model ILIKE @search
          ORDER BY created_at DESC
        '''),
        parameters: {'search': '%$searchTerm%'},
      );

      return result.map((row) => Device.fromMap(row.toColumnMap())).toList();
    } catch (e) {
      debugPrint('خطأ في البحث: $e');
      throw Exception('فشل في البحث: $e');
    }
  }

  // تحديث حالة الجهاز
  static Future<void> updateDeviceStatus(int deviceId, String status) async {
    try {
      final connection = await _getConnection();

      await connection.execute(
        Sql.named('''
          UPDATE devices 
          SET status = @status, updated_at = CURRENT_TIMESTAMP 
          WHERE id = @id
        '''),
        parameters: {'status': status, 'id': deviceId},
      );
    } catch (e) {
      debugPrint('خطأ في تحديث الحالة: $e');
      throw Exception('فشل في تحديث الحالة: $e');
    }
  }

  // حذف جهاز
  static Future<void> deleteDevice(int deviceId) async {
    try {
      final connection = await _getConnection();

      await connection.execute(
        Sql.named('DELETE FROM devices WHERE id = @id'),
        parameters: {'id': deviceId},
      );
    } catch (e) {
      debugPrint('خطأ في حذف الجهاز: $e');
      throw Exception('فشل في حذف الجهاز: $e');
    }
  }

  // تحديث بيانات الجهاز
  static Future<void> updateDevice(Device device) async {
    try {
      final connection = await _getConnection();

      await connection.execute(
        Sql.named('''
          UPDATE devices SET
            client_name = @client_name,
            client_phone1 = @client_phone1,
            client_phone2 = @client_phone2,
            gender = @gender,
            device_category = @device_category,
            brand = @brand,
            model = @model,
            operating_system = @operating_system,
            fault_type = @fault_type,
            fault_description = @fault_description,
            status = @status,
            total_amount = @total_amount,
            advance_amount = @advance_amount,
            remaining_amount = @remaining_amount,
            spare_parts = @spare_parts,
            updated_at = CURRENT_TIMESTAMP
          WHERE id = @id
        '''),
        parameters: {
          'id': device.id,
          'client_name': device.clientName,
          'client_phone1': device.clientPhone1,
          'client_phone2':
              device.clientPhone2.isEmpty ? null : device.clientPhone2,
          'gender': device.gender,
          'device_category': device.deviceCategory,
          'brand': device.brand,
          'model': device.model,
          'operating_system': device.operatingSystem,
          'fault_type': device.faultType,
          'fault_description': device.faultDescription,
          'status': device.status,
          'total_amount': device.totalAmount,
          'advance_amount': device.advanceAmount,
          'remaining_amount': device.remainingAmount,
          'spare_parts': device.spareParts.isEmpty ? null : device.spareParts,
        },
      );
    } catch (e) {
      debugPrint('خطأ في تحديث الجهاز: $e');
      throw Exception('فشل في تحديث الجهاز: $e');
    }
  }

  // تحديث المبلغ المتبقي للجهاز بناءً على إجمالي الدفعات
  static Future<void> updateDeviceRemainingAmount(int deviceId) async {
    try {
      final connection = await _getConnection();

      // حساب إجمالي المدفوع
      final totalPaid = await getDeviceTotalPaid(deviceId);

      // تحديث المبلغ المتبقي في قاعدة البيانات
      await connection.execute(
        Sql.named('''
          UPDATE devices 
          SET remaining_amount = GREATEST(0, total_amount - @total_paid),
              updated_at = CURRENT_TIMESTAMP
          WHERE id = @id
        '''),
        parameters: {'id': deviceId, 'total_paid': totalPaid},
      );
    } catch (e) {
      debugPrint('خطأ في تحديث المبلغ المتبقي: $e');
      throw Exception('فشل في تحديث المبلغ المتبقي: $e');
    }
  }

  // ========== دوال إدارة الدفعات ==========

  // إضافة دفعة جديدة
  static Future<int> addPayment(Payment payment) async {
    try {
      final connection = await _getConnection();

      final result = await connection.execute(
        Sql.named('''
          INSERT INTO payments (device_id, amount, type, notes, created_at)
          VALUES (@device_id, @amount, @type, @notes, @created_at)
          RETURNING id
        '''),
        parameters: {
          'device_id': payment.deviceId,
          'amount': payment.amount,
          'type': payment.type,
          'notes': payment.notes.isEmpty ? null : payment.notes,
          'created_at': payment.createdAt.toIso8601String(),
        },
      );

      // تحويل القيمة بأمان من String إلى int
      final value = result[0][0];
      int paymentId;
      if (value is int) {
        paymentId = value;
      } else if (value is String) {
        paymentId = int.tryParse(value) ?? 0;
      } else {
        paymentId = 0;
      }

      // تحديث المبلغ المتبقي للجهاز تلقائياً بعد إضافة الدفعة
      await updateDeviceRemainingAmount(payment.deviceId);

      return paymentId;
    } catch (e) {
      debugPrint('خطأ في إضافة الدفعة: $e');
      throw Exception('فشل في إضافة الدفعة: $e');
    }
  }

  // جلب دفعات جهاز معين
  static Future<List<Payment>> getDevicePayments(int deviceId) async {
    try {
      final connection = await _getConnection();

      final result = await connection.execute(
        Sql.named(
          'SELECT * FROM payments WHERE device_id = @device_id ORDER BY created_at DESC',
        ),
        parameters: {'device_id': deviceId},
      );

      return result.map((row) => Payment.fromMap(row.toColumnMap())).toList();
    } catch (e) {
      debugPrint('خطأ في جلب الدفعات: $e');
      throw Exception('فشل في جلب الدفعات: $e');
    }
  }

  // حساب إجمالي المدفوع لجهاز معين
  static Future<double> getDeviceTotalPaid(int deviceId) async {
    try {
      final connection = await _getConnection();

      final result = await connection.execute(
        Sql.named(
          'SELECT COALESCE(SUM(amount), 0) as total FROM payments WHERE device_id = @device_id',
        ),
        parameters: {'device_id': deviceId},
      );

      // تحويل القيمة بأمان من String إلى double
      final value = result[0][0];
      if (value == null) return 0.0;

      if (value is num) {
        return value.toDouble();
      } else if (value is String) {
        return double.tryParse(value) ?? 0.0;
      } else {
        return 0.0;
      }
    } catch (e) {
      debugPrint('خطأ في حساب إجمالي المدفوع: $e');
      throw Exception('فشل في حساب إجمالي المدفوع: $e');
    }
  }

  // حذف دفعة
  static Future<void> deletePayment(int paymentId) async {
    try {
      final connection = await _getConnection();

      await connection.execute(
        Sql.named('DELETE FROM payments WHERE id = @id'),
        parameters: {'id': paymentId},
      );
    } catch (e) {
      debugPrint('خطأ في حذف الدفعة: $e');
      throw Exception('فشل في حذف الدفعة: $e');
    }
  }

  // الحصول على معلومات مالية شاملة للجهاز
  static Future<Map<String, double>> getDeviceFinancialInfo(
    int deviceId,
  ) async {
    try {
      final connection = await _getConnection();

      // جلب معلومات الجهاز والدفعات في استعلام واحد
      final result = await connection.execute(
        Sql.named('''
          SELECT 
            d.total_amount,
            COALESCE(SUM(p.amount), 0) as total_paid
          FROM devices d
          LEFT JOIN payments p ON d.id = p.device_id
          WHERE d.id = @device_id
          GROUP BY d.total_amount
        '''),
        parameters: {'device_id': deviceId},
      );

      if (result.isNotEmpty) {
        final row = result.first.toColumnMap();
        final totalAmount =
            double.tryParse(row['total_amount'].toString()) ?? 0.0;
        final totalPaid = double.tryParse(row['total_paid'].toString()) ?? 0.0;
        final remaining = (totalAmount - totalPaid).clamp(0.0, double.infinity);

        return {
          'total_amount': totalAmount,
          'total_paid': totalPaid,
          'remaining': remaining,
          'progress':
              totalAmount > 0 ? (totalPaid / totalAmount).clamp(0.0, 1.0) : 0.0,
        };
      }

      return {
        'total_amount': 0.0,
        'total_paid': 0.0,
        'remaining': 0.0,
        'progress': 0.0,
      };
    } catch (e) {
      debugPrint('خطأ في جلب المعلومات المالية: $e');
      throw Exception('فشل في جلب المعلومات المالية: $e');
    }
  }

  // إحصائيات الأجهزة
  static Future<Map<String, int>> getDeviceStats() async {
    try {
      final connection = await _getConnection();

      final result = await connection.execute('''
        SELECT 
          COUNT(*) as total,
          COUNT(CASE WHEN status = 'في الانتظار' THEN 1 END) as pending,
          COUNT(CASE WHEN status = 'قيد الإصلاح' THEN 1 END) as in_progress,
          COUNT(CASE WHEN status = 'مكتمل' THEN 1 END) as completed,
          COUNT(CASE WHEN status = 'ملغي' THEN 1 END) as cancelled
        FROM devices
      ''');

      final row = result.first.toColumnMap();

      // دالة مساعدة لتحويل القيم بأمان
      int _parseInt(dynamic value) {
        if (value is int) return value;
        if (value is String) return int.tryParse(value) ?? 0;
        return 0;
      }

      return {
        'total': _parseInt(row['total']),
        'في الانتظار': _parseInt(row['pending']),
        'قيد الإصلاح': _parseInt(row['in_progress']),
        'مكتمل': _parseInt(row['completed']),
        'ملغي': _parseInt(row['cancelled']),
      };
    } catch (e) {
      debugPrint('خطأ في جلب الإحصائيات: $e');
      throw Exception('فشل في جلب الإحصائيات: $e');
    }
  }

  // ==================== طرق سجل الأجهزة ====================

  // إضافة سجل جديد للجهاز (نسخ الجهاز إلى السجل)
  static Future<int> addDeviceHistory(DeviceHistory history) async {
    try {
      final connection = await _getConnection();

      final result = await connection.execute(
        Sql.named('''
          INSERT INTO device_history (
            device_id, device_category, brand, model, operating_system,
            client_name, gender, client_phone1, client_phone2,
            fault_type, fault_description, spare_parts, status,
            total_amount, advance_amount, remaining_amount,
            entry_date, completion_date, notes, created_at
          ) VALUES (
            @device_id, @device_category, @brand, @model, @operating_system,
            @client_name, @gender, @client_phone1, @client_phone2,
            @fault_type, @fault_description, @spare_parts, @status,
            @total_amount, @advance_amount, @remaining_amount,
            @entry_date, @completion_date, @notes, @created_at
          ) RETURNING id
        '''),
        parameters: {
          'device_id': history.deviceId,
          'device_category': history.deviceCategory,
          'brand': history.brand,
          'model': history.model,
          'operating_system': history.operatingSystem,
          'client_name': history.clientName,
          'gender': history.gender,
          'client_phone1': history.clientPhone1,
          'client_phone2':
              history.clientPhone2.isEmpty ? null : history.clientPhone2,
          'fault_type': history.faultType,
          'fault_description': history.faultDescription,
          'spare_parts': history.spareParts.isEmpty ? null : history.spareParts,
          'status': history.status,
          'total_amount': history.totalAmount,
          'advance_amount': history.advanceAmount,
          'remaining_amount': history.remainingAmount,
          'entry_date': history.entryDate.toIso8601String(),
          'completion_date': history.completionDate?.toIso8601String(),
          'notes': history.notes.isEmpty ? null : history.notes,
          'created_at': history.createdAt.toIso8601String(),
        },
      );

      // تحويل القيمة بأمان من String إلى int
      final value = result[0][0];
      if (value is int) {
        return value;
      } else if (value is String) {
        return int.tryParse(value) ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      debugPrint('خطأ في إضافة سجل الجهاز: $e');
      throw Exception('فشل في إضافة سجل الجهاز: $e');
    }
  }

  // جلب سجل جهاز بالرقم
  static Future<List<DeviceHistory>> getDeviceHistory(String deviceId) async {
    try {
      final connection = await _getConnection();

      final result = await connection.execute(
        Sql.named(
          'SELECT * FROM device_history WHERE device_id = @device_id ORDER BY entry_date DESC',
        ),
        parameters: {'device_id': deviceId},
      );

      return result.map((row) {
        final map = row.toColumnMap();
        return DeviceHistory.fromMap(map);
      }).toList();
    } catch (e) {
      debugPrint('خطأ في جلب سجل الجهاز: $e');
      throw Exception('فشل في جلب سجل الجهاز: $e');
    }
  }

  // جلب جميع السجلات
  static Future<List<DeviceHistory>> getAllDeviceHistory() async {
    try {
      final connection = await _getConnection();

      final result = await connection.execute(
        'SELECT * FROM device_history ORDER BY entry_date DESC',
      );

      return result.map((row) {
        final map = row.toColumnMap();
        return DeviceHistory.fromMap(map);
      }).toList();
    } catch (e) {
      debugPrint('خطأ في جلب جميع السجلات: $e');
      throw Exception('فشل في جلب جميع السجلات: $e');
    }
  }

  // تحديث حالة سجل معين (عند إكمال الإصلاح)
  static Future<void> updateDeviceHistoryStatus(
    int historyId,
    String status, {
    DateTime? completionDate,
  }) async {
    try {
      final connection = await _getConnection();

      await connection.execute(
        Sql.named('''
          UPDATE device_history 
          SET status = @status, completion_date = @completion_date
          WHERE id = @id
        '''),
        parameters: {
          'status': status,
          'completion_date': completionDate?.toIso8601String(),
          'id': historyId,
        },
      );
    } catch (e) {
      debugPrint('خطأ في تحديث حالة السجل: $e');
      throw Exception('فشل في تحديث حالة السجل: $e');
    }
  }

  // نسخ جهاز موجود إلى السجل (عند إكمال الإصلاح)
  static Future<void> archiveDevice(Device device, {String notes = ''}) async {
    try {
      final history = DeviceHistory.fromDevice(device, notes: notes);
      await addDeviceHistory(history);
    } catch (e) {
      debugPrint('خطأ في أرشفة الجهاز: $e');
      throw Exception('فشل في أرشفة الجهاز: $e');
    }
  }

  // إحصائيات السجل
  static Future<Map<String, int>> getHistoryStats() async {
    try {
      final connection = await _getConnection();

      final result = await connection.execute('''
        SELECT 
          COUNT(*) as total,
          COUNT(DISTINCT device_id) as unique_devices,
          COUNT(CASE WHEN status = 'مكتمل' THEN 1 END) as completed,
          COUNT(CASE WHEN entry_date >= CURRENT_DATE - INTERVAL '30 days' THEN 1 END) as last_month
        FROM device_history
      ''');

      final row = result.first.toColumnMap();

      // دالة مساعدة لتحويل القيم بأمان
      int _parseInt(dynamic value) {
        if (value is int) return value;
        if (value is String) return int.tryParse(value) ?? 0;
        return 0;
      }

      return {
        'total': _parseInt(row['total']),
        'unique_devices': _parseInt(row['unique_devices']),
        'completed': _parseInt(row['completed']),
        'last_month': _parseInt(row['last_month']),
      };
    } catch (e) {
      debugPrint('خطأ في جلب إحصائيات السجل: $e');
      return {'total': 0, 'unique_devices': 0, 'completed': 0, 'last_month': 0};
    }
  }

  // إغلاق الاتصال
  static Future<void> closeConnection() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
    }
  }
}
