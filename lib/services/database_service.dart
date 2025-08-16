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

  // عدد الأجهزة المضافة لنطاق زمني معين (بناءً على created_at)
  static Future<int> getDevicesCountForRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final connection = await _getConnection();

      final result = await connection.execute(
        Sql.named('''
            SELECT COUNT(*) as devices_count
            FROM devices
            WHERE DATE(created_at) >= DATE(@start)
              AND DATE(created_at) <= DATE(@end)
          '''),
        parameters: {
          'start': start.toIso8601String(),
          'end': end.toIso8601String(),
        },
      );

      final val = result.first[0];
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    } catch (e) {
      debugPrint('خطأ في جلب عدد الأجهزة لنطاق التواريخ: $e');
      return 0;
    }
  }

  // إنشاء جدول الأجهزة
  static Future<void> _createTableIfNotExists() async {
    try {
      await _connection!.execute('''
        CREATE TABLE IF NOT EXISTS devices (
          id SERIAL PRIMARY KEY,
          device_id VARCHAR(50) UNIQUE NOT NULL,
          serial_number VARCHAR(100) UNIQUE,
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

      // إضافة عمود serial_number للجداول الموجودة إذا لم يكن موجود
      try {
        await _connection!.execute('''
          ALTER TABLE devices ADD COLUMN serial_number VARCHAR(100) UNIQUE;
        ''');
      } catch (e) {
        // العمود موجود بالفعل أو خطأ آخر
        if (kDebugMode) print('Serial number column may already exist: $e');
      }

      // إنشاء فهارس للبحث السريع
      await _connection!.execute(
        'CREATE INDEX IF NOT EXISTS idx_device_id ON devices(device_id);',
      );
      await _connection!.execute(
        'CREATE INDEX IF NOT EXISTS idx_serial_number ON devices(serial_number);',
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

      // إنشاء جدول الإعدادات البسيط لتخزين القيم مثل العداد الابتدائي لـ device_id
      await _connection!.execute('''
        CREATE TABLE IF NOT EXISTS app_settings (
          key VARCHAR(100) PRIMARY KEY,
          value TEXT
        );
      ''');

      // تأكد من وجود مفاتيح الإعدادات اللازمة: device counter و device prefix
      try {
        final res = await _connection!.execute(
          Sql.named("SELECT value FROM app_settings WHERE key = @key"),
          parameters: {'key': 'device_start_counter'},
        );
        if (res.isEmpty) {
          await _connection!.execute(
            Sql.named(
              "INSERT INTO app_settings (key, value) VALUES (@key, @value)",
            ),
            parameters: {'key': 'device_start_counter', 'value': '1'},
          );
        }

        final res2 = await _connection!.execute(
          Sql.named("SELECT value FROM app_settings WHERE key = @key"),
          parameters: {'key': 'device_prefix'},
        );
        if (res2.isEmpty) {
          await _connection!.execute(
            Sql.named(
              "INSERT INTO app_settings (key, value) VALUES (@key, @value)",
            ),
            parameters: {'key': 'device_prefix', 'value': 'GF'},
          );
        }
      } catch (e) {
        if (kDebugMode) print('Could not ensure device settings exist: $e');
      }

      debugPrint('تم إنشاء الجدول والفهارس بنجاح');
    } catch (e) {
      debugPrint('خطأ في إنشاء الجدول: $e');
      rethrow;
    }
  }

  // التحقق من وجود Serial Number
  static Future<bool> isSerialNumberExists(String? serialNumber) async {
    try {
      if (serialNumber == null || serialNumber.trim().isEmpty) return false;
      final connection = await _getConnection();

      final result = await connection.execute(
        Sql.named(
          'SELECT COUNT(*) FROM devices WHERE serial_number = @serialNumber',
        ),
        parameters: {'serialNumber': serialNumber},
      );

      final count = result.first[0] as int;
      return count > 0;
    } catch (e) {
      debugPrint('خطأ في فحص Serial Number: $e');
      return false;
    }
  }

  // البحث عن جهاز بواسطة Serial Number
  static Future<Device?> getDeviceBySerialNumber(String? serialNumber) async {
    try {
      if (serialNumber == null || serialNumber.trim().isEmpty) return null;
      final connection = await _getConnection();

      final result = await connection.execute(
        Sql.named('SELECT * FROM devices WHERE serial_number = @serialNumber'),
        parameters: {'serialNumber': serialNumber},
      );

      if (result.isNotEmpty) {
        final row = result.first;
        final Map<String, dynamic> map = {
          'id': row[0],
          'device_id': row[1],
          'serial_number': row[2],
          'client_name': row[3],
          'client_phone1': row[4],
          'client_phone2': row[5],
          'gender': row[6],
          'device_category': row[7],
          'brand': row[8],
          'model': row[9],
          'operating_system': row[10],
          'fault_type': row[11],
          'fault_description': row[12],
          'status': row[13],
          'total_amount': row[14],
          'advance_amount': row[15],
          'remaining_amount': row[16],
          'spare_parts': row[17],
          'created_at': row[18],
          'updated_at': row[19],
        };
        return Device.fromMap(map);
      }

      return null;
    } catch (e) {
      debugPrint('خطأ في البحث عن الجهاز بواسطة Serial Number: $e');
      return null;
    }
  }

  // إضافة جهاز جديد
  static Future<int> addDevice(Device device) async {
    try {
      // التحقق من وجود Serial Number مسبقاً
      if (await isSerialNumberExists(device.serialNumber)) {
        throw Exception('رقم السريال موجود بالفعل: ${device.serialNumber}');
      }

      final connection = await _getConnection();

      final result = await connection.execute(
        Sql.named('''
          INSERT INTO devices (
            device_id, serial_number, client_name, client_phone1, client_phone2, gender,
            device_category, brand, model, operating_system, fault_type,
            fault_description, status, total_amount, advance_amount,
            remaining_amount, spare_parts, created_at
          ) VALUES (
            @device_id, @serial_number, @client_name, @client_phone1, @client_phone2, @gender,
            @device_category, @brand, @model, @operating_system, @fault_type,
            @fault_description, @status, @total_amount, @advance_amount,
            @remaining_amount, @spare_parts, @created_at
          ) RETURNING id
        '''),
        parameters: {
          'device_id': device.deviceId,
          'serial_number':
              device.serialNumber == null || device.serialNumber!.isEmpty
                  ? null
                  : device.serialNumber,
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

  // جلب الأجهزة بطريقة مجزأة (pagination) مع دعم عوامل التصفية والبحث على مستوى قاعدة البيانات
  static Future<List<Device>> getDevicesPaged({
    required int limit,
    required int offset,
    String? searchTerm,
    String? status,
    String? deviceCategory,
    String? faultType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final connection = await _getConnection();

      final whereClauses = <String>[];
      final params = <String, dynamic>{};

      if (searchTerm != null && searchTerm.trim().isNotEmpty) {
        whereClauses.add(
          "(device_id ILIKE @search OR serial_number ILIKE @search OR client_name ILIKE @search OR brand ILIKE @search OR model ILIKE @search)",
        );
        params['search'] = '%${searchTerm.trim()}%';
      }

      if (status != null && status.isNotEmpty && status != 'الكل') {
        whereClauses.add('status = @status');
        params['status'] = status;
      }

      if (deviceCategory != null &&
          deviceCategory.isNotEmpty &&
          deviceCategory != 'الكل') {
        whereClauses.add('device_category = @device_category');
        params['device_category'] = deviceCategory;
      }

      if (faultType != null && faultType.isNotEmpty && faultType != 'الكل') {
        whereClauses.add('fault_type = @fault_type');
        params['fault_type'] = faultType;
      }

      if (startDate != null && endDate != null) {
        whereClauses.add(
          'DATE(created_at) >= DATE(@start) AND DATE(created_at) <= DATE(@end)',
        );
        params['start'] = startDate.toIso8601String();
        params['end'] = endDate.toIso8601String();
      }

      final where =
          whereClauses.isNotEmpty ? 'WHERE ${whereClauses.join(' AND ')}' : '';

      final sql = '''
        SELECT * FROM devices
        $where
        ORDER BY created_at DESC
        LIMIT @limit OFFSET @offset
      ''';

      params['limit'] = limit;
      params['offset'] = offset;

      final result = await connection.execute(
        Sql.named(sql),
        parameters: params,
      );

      return result.map((row) => Device.fromMap(row.toColumnMap())).toList();
    } catch (e) {
      debugPrint('خطأ في جلب الأجهزة (مجزأة): $e');
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
             OR serial_number ILIKE @search 
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
            serial_number = @serial_number,
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
          'serial_number':
              device.serialNumber == null || device.serialNumber!.isEmpty
                  ? null
                  : device.serialNumber,
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

  // ======== إحصائيات الإيرادات ========

  // إجمالي الإيرادات (مجموع جميع الدفعات)
  static Future<double> getTotalRevenue() async {
    try {
      final connection = await _getConnection();

      final result = await connection.execute(
        Sql.named('SELECT COALESCE(SUM(amount), 0) as total FROM payments'),
      );

      final val = result.first[0];
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    } catch (e) {
      debugPrint('خطأ في جلب إجمالي الإيرادات: $e');
      return 0.0;
    }
  }

  // إجمالي الإيرادات لليوم الحالي
  static Future<double> getTotalRevenueToday() async {
    try {
      final connection = await _getConnection();

      final result = await connection.execute(
        Sql.named(
          "SELECT COALESCE(SUM(amount), 0) as total FROM payments WHERE DATE(created_at) = CURRENT_DATE",
        ),
      );

      final val = result.first[0];
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    } catch (e) {
      debugPrint('خطأ في جلب إجمالي الإيرادات اليوم: $e');
      return 0.0;
    }
  }

  // إجمالي الإيرادات لنطاق زمني محدد (start و end بالتوقيت المحلي للعميل)
  static Future<double> getTotalRevenueForRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final connection = await _getConnection();

      // استخدم ISO strings لنقل التواريخ إلى SQL
      final result = await connection.execute(
        Sql.named('''
            SELECT COALESCE(SUM(amount), 0) as total
            FROM payments
            WHERE created_at >= @start AND created_at <= @end
          '''),
        parameters: {
          'start': start.toIso8601String(),
          'end': end.toIso8601String(),
        },
      );

      final val = result.first[0];
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    } catch (e) {
      debugPrint('خطأ في جلب إجمالي الإيرادات لنطاق التواريخ: $e');
      return 0.0;
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
      int parseInt(dynamic value) {
        if (value is int) return value;
        if (value is String) return int.tryParse(value) ?? 0;
        return 0;
      }

      return {
        'total': parseInt(row['total']),
        'في الانتظار': parseInt(row['pending']),
        'قيد الإصلاح': parseInt(row['in_progress']),
        'مكتمل': parseInt(row['completed']),
        'ملغي': parseInt(row['cancelled']),
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
      int parseInt(dynamic value) {
        if (value is int) return value;
        if (value is String) return int.tryParse(value) ?? 0;
        return 0;
      }

      return {
        'total': parseInt(row['total']),
        'unique_devices': parseInt(row['unique_devices']),
        'completed': parseInt(row['completed']),
        'last_month': parseInt(row['last_month']),
      };
    } catch (e) {
      debugPrint('خطأ في جلب إحصائيات السجل: $e');
      return {'total': 0, 'unique_devices': 0, 'completed': 0, 'last_month': 0};
    }
  }

  // عدد الأجهزة المكتملة اليوم
  static Future<int> getCompletedTodayCount() async {
    try {
      final connection = await _getConnection();

      final result = await connection.execute(
        Sql.named('''
          SELECT COUNT(*) as completed_today 
          FROM devices 
          WHERE status = @status 
            AND DATE(updated_at) = CURRENT_DATE
        '''),
        parameters: {'status': 'مكتمل'},
      );

      final val = result.first[0];
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    } catch (e) {
      debugPrint('خطأ في جلب عدد المكتملة اليوم: $e');
      return 0;
    }
  }

  // عدد الأجهزة المكتملة لنطاق زمني معين (بناءً على updated_at)
  static Future<int> getCompletedCountForRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final connection = await _getConnection();

      final result = await connection.execute(
        Sql.named('''
            SELECT COUNT(*) as completed_count
            FROM devices
            WHERE status = @status
              AND DATE(updated_at) >= DATE(@start)
              AND DATE(updated_at) <= DATE(@end)
          '''),
        parameters: {
          'status': 'مكتمل',
          'start': start.toIso8601String(),
          'end': end.toIso8601String(),
        },
      );

      final val = result.first[0];
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    } catch (e) {
      debugPrint('خطأ في جلب عدد المكتملة لنطاق التواريخ: $e');
      return 0;
    }
  }

  // توزيع الحالات للأجهزة المضافة/المتعلقة بنطاق زمني معين (بناءً على created_at)
  static Future<Map<String, int>> getStatusDistributionForRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final connection = await _getConnection();

      final result = await connection.execute(
        Sql.named('''
            SELECT status, COUNT(*) as cnt
            FROM devices
            WHERE DATE(created_at) >= DATE(@start)
              AND DATE(created_at) <= DATE(@end)
            GROUP BY status
          '''),
        parameters: {
          'start': start.toIso8601String(),
          'end': end.toIso8601String(),
        },
      );

      final Map<String, int> map = {};
      for (final row in result) {
        final r = row.toColumnMap();
        final status = (r['status'] ?? 'غير معروف').toString();
        final cntVal = r['cnt'];
        int cnt = 0;
        if (cntVal is int)
          cnt = cntVal;
        else if (cntVal is String)
          cnt = int.tryParse(cntVal) ?? 0;
        map[status] = cnt;
      }

      return map;
    } catch (e) {
      debugPrint('خطأ في جلب توزيع الحالات لنطاق التواريخ: $e');
      return {};
    }
  }

  // إغلاق الاتصال
  static Future<void> closeConnection() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
    }
  }

  // الحصول على القيمة العددية لبداية ترقيم الأجهزة (الجذر للـ GF-...)
  static Future<int> getDeviceStartCounter() async {
    try {
      final connection = await _getConnection();
      final result = await connection.execute(
        Sql.named('SELECT value FROM app_settings WHERE key = @key'),
        parameters: {'key': 'device_start_counter'},
      );

      if (result.isNotEmpty) {
        final val = result.first[0];
        if (val is String) return int.tryParse(val) ?? 1;
        if (val is int) return val;
      }
      return 1;
    } catch (e) {
      debugPrint('خطأ في جلب device_start_counter: $e');
      return 1;
    }
  }

  // تحديث القيمة العددية لبداية ترقيم الأجهزة
  static Future<void> setDeviceStartCounter(int counter) async {
    try {
      final connection = await _getConnection();
      await connection.execute(
        Sql.named(
          "INSERT INTO app_settings (key, value) VALUES (@key, @value) ON CONFLICT (key) DO UPDATE SET value = @value",
        ),
        parameters: {
          'key': 'device_start_counter',
          'value': counter.toString(),
        },
      );
    } catch (e) {
      debugPrint('خطأ في تحديث device_start_counter: $e');
      throw Exception('فشل في تحديث إعدادات التطبيق: $e');
    }
  }

  // الحصول على بادئة Device ID (مثال: GF-1 أو GF-2)
  static Future<String> getDevicePrefix() async {
    try {
      final connection = await _getConnection();
      final result = await connection.execute(
        Sql.named('SELECT value FROM app_settings WHERE key = @key'),
        parameters: {'key': 'device_prefix'},
      );

      if (result.isNotEmpty) {
        final val = result.first[0];
        if (val is String) return val;
        return val.toString();
      }
      return 'GF-1';
    } catch (e) {
      debugPrint('خطأ في جلب device_prefix: $e');
      return 'GF-1';
    }
  }

  // تحديث بادئة Device ID
  static Future<void> setDevicePrefix(String prefix) async {
    try {
      final connection = await _getConnection();
      await connection.execute(
        Sql.named(
          "INSERT INTO app_settings (key, value) VALUES (@key, @value) ON CONFLICT (key) DO UPDATE SET value = @value",
        ),
        parameters: {'key': 'device_prefix', 'value': prefix},
      );
    } catch (e) {
      debugPrint('خطأ في تحديث device_prefix: $e');
      throw Exception('فشل في تحديث إعدادات التطبيق: $e');
    }
  }
}
