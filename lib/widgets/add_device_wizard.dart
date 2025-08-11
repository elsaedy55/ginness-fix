import 'package:flutter/material.dart';

class AddDeviceWizard extends StatefulWidget {
  const AddDeviceWizard({super.key});

  @override
  State<AddDeviceWizard> createState() => _AddDeviceWizardState();
}

class _AddDeviceWizardState extends State<AddDeviceWizard> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  // Controllers
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _clientPhone1Controller = TextEditingController();
  final TextEditingController _clientPhone2Controller = TextEditingController();
  final TextEditingController _brandSearchController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _accessoriesController = TextEditingController();
  final TextEditingController _materialsController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _advanceAmountController =
      TextEditingController();
  final TextEditingController _remainingAmountController =
      TextEditingController();

  // Selected values
  String _selectedGender = '';
  String _selectedBrand = '';
  String _selectedModel = '';
  String _selectedOS = '';
  String _selectedDeviceCategory = '';
  String _selectedFaultType = '';
  String _selectedStatus = 'في الانتظار';
  bool _showBrandList = false;

  // Device ID - generated once and displayed throughout
  late String _deviceId;

  // Options
  final List<String> _genders = ['ذكر', 'أنثى'];

  final List<String> _deviceCategories = [
    'هاتف ذكي',
    'لاب توب',
    'تابلت',
    'ساعة ذكية',
    'سماعات',
    'كمبيوتر',
    'جهاز ألعاب',
  ];

  final Map<String, List<String>> _brandsByCategory = {
    'هاتف ذكي': [
      'Apple (iPhone)',
      'Samsung',
      'Xiaomi',
      'Huawei',
      'OnePlus',
      'Google (Pixel)',
      'Oppo',
      'Vivo',
      'Honor',
      'Realme',
      'Nothing',
      'Motorola',
    ],
    'لاب توب': [
      'Apple (MacBook)',
      'Dell',
      'HP',
      'Lenovo',
      'ASUS',
      'Acer',
      'MSI',
      'Microsoft Surface',
      'Alienware',
      'Razer',
      'ThinkPad',
      'Framework',
    ],
    'تابلت': [
      'Apple',
      'Samsung',
      'Huawei',
      'Lenovo',
      'Microsoft',
      'Amazon',
      'Xiaomi',
      'Honor',
      'Realme',
      'Nokia',
      'Asus',
      'TCL',
      'OnePlus',
      'Nothing',
    ],
    'ساعة ذكية': [
      'Apple',
      'Samsung',
      'Huawei',
      'Garmin',
      'Fitbit',
      'Amazfit',
      'Honor',
      'Xiaomi',
      'OnePlus',
      'Nothing',
      'Fossil',
      'Tag Heuer',
      'Suunto',
      'Polar',
      'Withings',
      'TicWatch',
      'Oppo',
      'Realme',
    ],
    'سماعات': [
      'Apple',
      'Samsung',
      'Sony',
      'Bose',
      'JBL',
      'Beats',
      'Sennheiser',
      'Audio-Technica',
      'Nothing',
      'OnePlus',
      'Xiaomi',
      'Anker',
      'Jabra',
      'Marshall',
      'Bang & Olufsen',
      'Focal',
      'Beyerdynamic',
      'Shure',
      'AKG',
      'Grado',
      'Philips',
      'Skullcandy',
    ],
    'كمبيوتر': [
      'Dell',
      'HP',
      'Lenovo',
      'Asus',
      'MSI',
      'Alienware',
      'Apple',
      'Acer',
      'Origin PC',
      'Corsair',
      'NZXT',
      'CyberPowerPC',
      'iBUYPOWER',
      'Maingear',
      'Digital Storm',
      'Falcon Northwest',
      'System76',
      'Puget Systems',
    ],
    'جهاز ألعاب': [
      'Sony PlayStation',
      'Microsoft Xbox',
      'Nintendo',
      'Steam Deck',
      'Asus ROG Ally',
      'Logitech G Cloud',
      'Razer Edge',
      'AYN Odin',
    ],
  };

  final Map<String, List<String>> _modelsByBrand = {
    // Apple
    'Apple': [
      // iPhones
      'iPhone 15 Pro Max', 'iPhone 15 Pro', 'iPhone 15 Plus', 'iPhone 15',
      'iPhone 14 Pro Max', 'iPhone 14 Pro', 'iPhone 14 Plus', 'iPhone 14',
      'iPhone 13 Pro Max', 'iPhone 13 Pro', 'iPhone 13 mini', 'iPhone 13',
      'iPhone 12 Pro Max', 'iPhone 12 Pro', 'iPhone 12 mini', 'iPhone 12',
      'iPhone 11 Pro Max', 'iPhone 11 Pro', 'iPhone 11',
      'iPhone XS Max', 'iPhone XS', 'iPhone XR',
      'iPhone X', 'iPhone 8 Plus', 'iPhone 8', 'iPhone 7 Plus', 'iPhone 7',
      // MacBooks
      'MacBook Pro 16" M3 Max', 'MacBook Pro 14" M3 Pro', 'MacBook Pro 13" M2',
      'MacBook Air 15" M2', 'MacBook Air 13" M2', 'MacBook Air M1',
      // iPads
      'iPad Pro 12.9" M2', 'iPad Pro 11" M2', 'iPad Air 5th Gen',
      'iPad 10th Gen', 'iPad mini 6th Gen',
      // Watches
      'Apple Watch Ultra 2', 'Apple Watch Series 9', 'Apple Watch SE 2nd Gen',
      // Audio
      'AirPods Pro 2nd Gen', 'AirPods 3rd Gen', 'AirPods Max',
    ],

    // Samsung
    'Samsung': [
      // Galaxy S Series
      'Galaxy S24 Ultra', 'Galaxy S24+', 'Galaxy S24',
      'Galaxy S23 Ultra', 'Galaxy S23+', 'Galaxy S23', 'Galaxy S23 FE',
      'Galaxy S22 Ultra', 'Galaxy S22+', 'Galaxy S22',
      'Galaxy S21 Ultra', 'Galaxy S21+', 'Galaxy S21', 'Galaxy S21 FE',
      // Galaxy Note
      'Galaxy Note 20 Ultra',
      'Galaxy Note 20',
      'Galaxy Note 10+',
      'Galaxy Note 10',
      // Galaxy A Series
      'Galaxy A54 5G', 'Galaxy A34 5G', 'Galaxy A24', 'Galaxy A14',
      'Galaxy A73 5G', 'Galaxy A53 5G', 'Galaxy A33 5G', 'Galaxy A23',
      // Galaxy Z Series
      'Galaxy Z Fold 5',
      'Galaxy Z Flip 5',
      'Galaxy Z Fold 4',
      'Galaxy Z Flip 4',
      // Tablets
      'Galaxy Tab S9 Ultra', 'Galaxy Tab S9+', 'Galaxy Tab S9',
      'Galaxy Tab S8 Ultra', 'Galaxy Tab A8',
      // Watches
      'Galaxy Watch 6 Classic', 'Galaxy Watch 6', 'Galaxy Watch 5 Pro',
      // Audio
      'Galaxy Buds 2 Pro', 'Galaxy Buds 2', 'Galaxy Buds Live',
      // Laptops
      'Galaxy Book 3 Pro', 'Galaxy Book 3', 'Galaxy Book 2 Pro',
    ],

    // Huawei
    'Huawei': [
      // P Series
      'P60 Pro', 'P60', 'P50 Pro', 'P50', 'P40 Pro', 'P40',
      // Mate Series
      'Mate 60 Pro', 'Mate 60', 'Mate 50 Pro', 'Mate 50',
      'Mate 40 Pro', 'Mate 40',
      // Nova Series
      'Nova 11 Pro', 'Nova 11', 'Nova 10 Pro', 'Nova 10',
      // Y Series
      'Y90', 'Y70', 'Y60',
      // Laptops
      'MateBook X Pro', 'MateBook 16s', 'MateBook 14',
      'MateBook D16', 'MateBook D15',
      // Tablets
      'MatePad Pro 12.6', 'MatePad Pro 11', 'MatePad 11',
      'MatePad T10s', 'MatePad T8',
      // Watches
      'Watch GT 4', 'Watch GT 3 Pro', 'Watch GT 3',
      'Watch Fit 2', 'Watch D',
      // Audio
      'FreeBuds Pro 3', 'FreeBuds 5i', 'FreeBuds SE 2',
    ],

    // Xiaomi
    'Xiaomi': [
      // Mi/Xiaomi Series
      'Xiaomi 14 Ultra', 'Xiaomi 14 Pro', 'Xiaomi 14',
      'Xiaomi 13 Ultra', 'Xiaomi 13 Pro', 'Xiaomi 13',
      'Xiaomi 12S Ultra', 'Xiaomi 12 Pro', 'Xiaomi 12',
      // Redmi Series
      'Redmi Note 13 Pro+', 'Redmi Note 13 Pro', 'Redmi Note 13',
      'Redmi Note 12 Pro+', 'Redmi Note 12 Pro', 'Redmi Note 12',
      'Redmi K70 Pro', 'Redmi K70', 'Redmi K60 Ultra',
      // POCO Series
      'POCO X6 Pro', 'POCO X6', 'POCO F6 Pro', 'POCO F6',
      'POCO M6 Pro', 'POCO C65',
      // Laptops
      'Mi Laptop Pro X', 'RedmiBook Pro 15', 'RedmiBook 16',
      // Tablets
      'Xiaomi Pad 6 Max', 'Xiaomi Pad 6 Pro', 'Xiaomi Pad 6',
      'Redmi Pad Pro', 'Redmi Pad SE',
      // Watches
      'Watch S3', 'Watch S2', 'Redmi Watch 3',
      'Mi Band 8 Pro', 'Mi Band 8',
      // Audio
      'Buds 4 Pro', 'Buds 4', 'Redmi Buds 5 Pro',
    ],

    // Dell
    'Dell': [
      // XPS Series
      'XPS 17 9730', 'XPS 15 9530', 'XPS 13 Plus 9320', 'XPS 13 9315',
      // Inspiron Series
      'Inspiron 16 7635', 'Inspiron 15 3530', 'Inspiron 14 5430',
      'Inspiron 13 5330', 'Inspiron 15 3000',
      // Latitude Series
      'Latitude 9540', 'Latitude 7540', 'Latitude 5540', 'Latitude 3540',
      'Latitude 7430', 'Latitude 5430', 'Latitude 3430',
      // Precision Series
      'Precision 5680', 'Precision 3581', 'Precision 7680',
      // Vostro Series
      'Vostro 16 5630', 'Vostro 15 3530', 'Vostro 14 3430',
      // G Series Gaming
      'G15 5530', 'G16 7630', 'G14 2404',
      // Desktop
      'OptiPlex 7010', 'OptiPlex 5000', 'Vostro 3910',
      'Inspiron 3910', 'XPS Desktop 8960',
    ],

    // HP
    'HP': [
      // Spectre Series
      'Spectre x360 16', 'Spectre x360 14', 'Spectre x360 13.5',
      // Envy Series
      'Envy x360 15.6', 'Envy x360 13.3', 'Envy 16', 'Envy 17',
      // Pavilion Series
      'Pavilion Plus 16', 'Pavilion 15', 'Pavilion x360 14',
      'Pavilion Aero 13', 'Pavilion Gaming 15',
      // EliteBook Series
      'EliteBook 1040 G10', 'EliteBook 840 G10', 'EliteBook 650 G10',
      'EliteBook x360 1040 G10', 'EliteBook Dragonfly G4',
      // ProBook Series
      'ProBook 450 G10', 'ProBook 440 G10', 'ProBook 430 G10',
      // Omen Gaming
      'Omen 16', 'Omen 17', 'Omen 25L Desktop', 'Omen 45L Desktop',
      // Victus Gaming
      'Victus 15', 'Victus 16', 'Victus 15L Desktop',
      // Desktop
      'Elite Desktop 800 G9', 'ProDesk 400 G9', 'All-in-One 24-cb1005ne',
    ],

    // Lenovo
    'Lenovo': [
      // ThinkPad Series
      'ThinkPad X1 Carbon Gen 11', 'ThinkPad X1 Yoga Gen 8',
      'ThinkPad T14s Gen 4', 'ThinkPad T14 Gen 4', 'ThinkPad L14 Gen 4',
      'ThinkPad E14 Gen 5', 'ThinkPad P1 Gen 6',
      // IdeaPad Series
      'IdeaPad Pro 5i 16', 'IdeaPad Flex 5i 14', 'IdeaPad 3i 15',
      'IdeaPad Gaming 3i', 'IdeaPad Duet 5i',
      // Yoga Series
      'Yoga 9i 14', 'Yoga 7i 16', 'Yoga 6 13', 'Yoga Pro 9i 16',
      // Legion Gaming
      'Legion Pro 7i 16', 'Legion Slim 5i 16', 'Legion Tower 7i',
      // ThinkCentre Desktop
      'ThinkCentre M90a Pro', 'ThinkCentre M70s', 'ThinkCentre M75q',
      // Tablets
      'Tab P11 Plus', 'Tab M10 Plus', 'Tab M8',
      // Phones (Motorola - owned by Lenovo)
      'Moto G Power', 'Moto G Stylus', 'Motorola Edge 40 Pro',
    ],

    // OnePlus
    'OnePlus': [
      // OnePlus Series
      'OnePlus 12', 'OnePlus 11', 'OnePlus 10 Pro', 'OnePlus 10T',
      'OnePlus 9 Pro', 'OnePlus 9', 'OnePlus 8T', 'OnePlus 8 Pro',
      // OnePlus Nord Series
      'OnePlus Nord 3', 'OnePlus Nord CE 3', 'OnePlus Nord N30',
      'OnePlus Nord 2T', 'OnePlus Nord CE 2 Lite',
      // OnePlus Pad
      'OnePlus Pad', 'OnePlus Pad Go',
      // OnePlus Watch
      'OnePlus Watch 2', 'OnePlus Watch',
      // OnePlus Buds
      'OnePlus Buds Pro 2', 'OnePlus Buds 3', 'OnePlus Buds Z2',
    ],

    // Sony
    'Sony': [
      // Xperia Phones
      'Xperia 1 V', 'Xperia 5 V', 'Xperia 10 V',
      'Xperia 1 IV', 'Xperia 5 IV', 'Xperia 10 IV',
      'Xperia Pro-I', 'Xperia 1 III', 'Xperia 5 III',
      // PlayStation
      'PlayStation 5', 'PlayStation 5 Slim', 'PlayStation Portal',
      'PlayStation 4 Pro', 'PlayStation 4 Slim',
      // Audio
      'WH-1000XM5', 'WH-1000XM4', 'WH-CH720N', 'WH-CH520',
      'WF-1000XM4', 'WF-1000XM3', 'WF-C700N', 'WF-C500',
      // Cameras
      'Alpha A7R V', 'Alpha A7 IV', 'Alpha A6700', 'FX30',
    ],

    // Asus
    'Asus': [
      // Phones
      'ROG Phone 7 Ultimate', 'ROG Phone 7', 'ROG Phone 6 Pro',
      'Zenfone 10', 'Zenfone 9', 'Zenfone 8',
      // Laptops
      'ROG Zephyrus G16', 'ROG Strix G18', 'ROG Flow X13',
      'ZenBook Pro 16X', 'ZenBook 14X', 'VivoBook Pro 16X',
      'TUF Gaming A15', 'ExpertBook B9',
      // Tablets
      'ZenPad 3S 10', 'ZenPad 10',
    ],

    // Oppo
    'Oppo': [
      // Find Series
      'Find X7 Ultra', 'Find X6 Pro', 'Find X5 Pro', 'Find N3',
      // Reno Series
      'Reno 11 Pro', 'Reno 10 Pro+', 'Reno 8 Pro', 'Reno 7 Pro',
      // A Series
      'A98', 'A78', 'A58', 'A38', 'A18',
      // Audio
      'Enco X2', 'Enco W51', 'Enco Air2 Pro',
      // Watches
      'Watch X', 'Watch 2', 'Band 2',
    ],

    // Vivo
    'Vivo': [
      // X Series
      'X100 Pro', 'X90 Pro+', 'X80 Pro', 'X70 Pro+',
      // V Series
      'V29 Pro', 'V27 Pro', 'V25 Pro', 'V23 Pro',
      // Y Series
      'Y100', 'Y78', 'Y56', 'Y36', 'Y22s',
      // iQOO Series
      'iQOO 12 Pro', 'iQOO 11 Pro', 'iQOO Neo8 Pro',
      // Audio
      'TWS 3 Pro', 'TWS Neo', 'TWS Air',
    ],

    // Google
    'Google': [
      'Pixel 8 Pro',
      'Pixel 8',
      'Pixel 7a',
      'Pixel 7 Pro',
      'Pixel 7',
      'Pixel 6a',
      'Pixel 6 Pro',
      'Pixel 6',
      'Pixel Fold',
      'Pixel Tablet',
      'Pixel Buds Pro',
      'Pixel Buds A-Series',
      'Nest Hub Max',
      'Nest Hub',
      'Nest Mini',
    ],

    // Honor
    'Honor': [
      // Magic Series
      'Magic 6 Pro', 'Magic 5 Pro', 'Magic 4 Pro',
      // X Series
      'X50 Pro', 'X40 GT', 'X30i',
      // Play Series
      'Play 50 Plus', 'Play 40 Plus', 'Play 7T Pro',
      // Tablets
      'Pad X9', 'Pad 8', 'Pad X8 Pro',
      // Laptops
      'MagicBook Pro 16', 'MagicBook 14', 'MagicBook X Pro',
      // Watches
      'Watch GS Pro', 'Watch GS 3', 'Watch ES',
    ],

    // Realme
    'Realme': [
      // GT Series
      'GT 5 Pro', 'GT Neo 6', 'GT 3', 'GT Master Edition',
      // Number Series
      '11 Pro+', '10 Pro+', '9 Pro+', '8 Pro',
      // C Series
      'C67', 'C55', 'C53', 'C33', 'C25s',
      // Narzo Series
      'Narzo 70 Pro', 'Narzo 60 Pro', 'Narzo 50 Pro',
      // Tablets
      'Pad 2', 'Pad Mini',
      // Audio
      'Buds T300', 'Buds Air 5 Pro', 'Buds Q2s',
    ],

    // Nothing
    'Nothing': [
      'Phone (2)',
      'Phone (1)',
      'Phone (2a)',
      'Ear (2)',
      'Ear (1)',
      'Ear (stick)',
      'CMF Phone 1',
      'CMF Buds Pro',
    ],

    // Microsoft Surface
    'Microsoft Surface': [
      'Surface Laptop Studio 2',
      'Surface Laptop 5',
      'Surface Pro 9',
      'Surface Studio 2+',
      'Surface Go 3',
      'Surface Book 3',
      'Surface Duo 2',
      'Surface Hub 2S',
    ],

    // MSI
    'MSI': [
      // Gaming Laptops
      'Titan 18 HX', 'Vector GP78 HX', 'Stealth 17 Studio',
      'Raider GE78 HX', 'Pulse GL76', 'Katana GF76',
      // Creator Series
      'CreatorPro Z17', 'Creator M16', 'Prestige 14 Evo',
      // Desktop
      'Aegis RS 13', 'Trident X2', 'Creator P100X',
    ],

    // Acer
    'Acer': [
      // Predator Gaming
      'Predator Triton 17 X', 'Predator Helios 18', 'Predator Orion 7000',
      // Aspire Series
      'Aspire 7', 'Aspire 5', 'Aspire Vero', 'Aspire TC',
      // Swift Series
      'Swift X 16', 'Swift 14', 'Swift Go 14',
      // Nitro Gaming
      'Nitro 17', 'Nitro 16', 'Nitro 5',
      // ChromeBook
      'Chromebook Spin 714', 'Chromebook 315',
    ],
  };

  final Map<String, List<String>> _osOptions = {
    'هاتف ذكي': ['iOS', 'Android', 'HarmonyOS'],
    'لاب توب': ['Windows 11', 'Windows 10', 'macOS', 'Linux'],
    'تابلت': ['iPadOS', 'Android', 'Windows 11'],
    'ساعة ذكية': ['watchOS', 'Wear OS', 'HarmonyOS'],
    'سماعات': ['لا يوجد'],
    'كمبيوتر': ['Windows 11', 'Windows 10', 'macOS', 'Linux'],
    'جهاز ألعاب': ['PlayStation OS', 'Xbox OS', 'Nintendo OS', 'Steam OS'],
  };

  final List<String> _faultTypes = [
    'سوفت وير',
    'هاردوير',
    'شاشة',
    'بطارية',
    'مياه',
    'شبكة',
    'صوت',
    'كاميرا',
    'أخرى',
  ];

  final List<String> _statuses = [
    'في الانتظار',
    'قيد الإصلاح',
    'مكتمل',
    'ملغي',
  ];

  List<String> get _filteredBrands {
    if (_selectedDeviceCategory.isEmpty) return [];
    final brands = _brandsByCategory[_selectedDeviceCategory] ?? [];
    if (_brandSearchController.text.isEmpty) return brands;
    return brands
        .where(
          (brand) => brand.toLowerCase().contains(
            _brandSearchController.text.toLowerCase(),
          ),
        )
        .toList();
  }

  // دالة لتحويل اسم الماركة المعروض إلى المفتاح المستخدم في قاعدة البيانات
  String _getBrandKey(String displayBrand) {
    if (displayBrand.startsWith('Apple')) {
      return 'Apple';
    } else if (displayBrand.startsWith('Google')) {
      return 'Google';
    }
    return displayBrand;
  }

  List<String> get _availableModels {
    if (_selectedBrand.isEmpty || _selectedDeviceCategory.isEmpty) return [];
    String brandKey = _getBrandKey(_selectedBrand);
    List<String> allModels = _modelsByBrand[brandKey] ?? [];

    // تصفية الموديلات حسب نوع الجهاز
    return _filterModelsByDeviceType(allModels, _selectedDeviceCategory);
  }

  List<String> _filterModelsByDeviceType(
    List<String> models,
    String deviceType,
  ) {
    switch (deviceType) {
      case 'هاتف ذكي':
        return models.where((model) => _isPhoneModel(model)).toList();

      case 'لاب توب':
        return models.where((model) => _isLaptopModel(model)).toList();

      case 'تابلت':
        return models.where((model) => _isTabletModel(model)).toList();

      case 'ساعة ذكية':
        return models.where((model) => _isWatchModel(model)).toList();

      case 'سماعات':
        return models.where((model) => _isHeadphoneModel(model)).toList();

      default:
        return models;
    }
  }

  bool _isPhoneModel(String model) {
    return model.contains('iPhone') ||
        model.contains('Galaxy S') ||
        model.contains('Galaxy A') ||
        model.contains('Galaxy Note') ||
        model.contains('Galaxy Z') ||
        model.contains('Xiaomi') ||
        model.contains('Redmi') ||
        model.contains('POCO') ||
        model.contains('Pixel') ||
        model.contains('Find') ||
        model.contains('Reno') ||
        model.contains('OnePlus') ||
        model.contains('Nord') ||
        model.contains('Magic') ||
        model.contains('Honor') ||
        model.contains('GT') ||
        model.contains('Edge') ||
        model.contains('Moto') ||
        model.contains('Razr') ||
        model.contains('Phone') ||
        model.contains('Nothing') ||
        (!model.contains('MacBook') &&
            !model.contains('iPad') &&
            !model.contains('Watch') &&
            !model.contains('Buds') &&
            !model.contains('Tab') &&
            !model.contains('Laptop') &&
            !model.contains('Book') &&
            !model.contains('Pro X') &&
            !model.contains('Pad') &&
            !model.contains('Band'));
  }

  bool _isLaptopModel(String model) {
    return model.contains('MacBook') ||
        model.contains('Laptop') ||
        model.contains('Book') ||
        model.contains('ThinkPad') ||
        model.contains('Inspiron') ||
        model.contains('XPS') ||
        model.contains('Latitude') ||
        model.contains('Pavilion') ||
        model.contains('EliteBook') ||
        model.contains('ProBook') ||
        model.contains('IdeaPad') ||
        model.contains('ThinkBook') ||
        model.contains('Legion') ||
        model.contains('VivoBook') ||
        model.contains('ZenBook') ||
        model.contains('ROG') ||
        model.contains('Aspire') ||
        model.contains('Swift') ||
        model.contains('Predator') ||
        model.contains('Surface Laptop') ||
        model.contains('Katana') ||
        model.contains('Creator') ||
        model.contains('Alienware') ||
        model.contains('Precision') ||
        model.contains('Vostro');
  }

  bool _isTabletModel(String model) {
    return model.contains('iPad') ||
        model.contains('Tab') ||
        model.contains('Pad') ||
        model.contains('Tablet') ||
        (model.contains('Surface') && !model.contains('Laptop'));
  }

  bool _isWatchModel(String model) {
    return model.contains('Watch') ||
        model.contains('Band') ||
        model.contains('Fit');
  }

  bool _isHeadphoneModel(String model) {
    return model.contains('Buds') ||
        model.contains('AirPods') ||
        model.contains('FreeBuds') ||
        model.contains('Ear') ||
        model.contains('TWS') ||
        model.contains('Audio') ||
        (model.contains('Nothing') && model.contains('Ear'));
  }

  List<String> get _availableOS {
    if (_selectedDeviceCategory.isEmpty) return [];
    return _osOptions[_selectedDeviceCategory] ?? [];
  }

  @override
  void initState() {
    super.initState();
    // Generate unique device ID when dialog opens
    _deviceId =
        'GF-1-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientPhone1Controller.dispose();
    _clientPhone2Controller.dispose();
    _brandSearchController.dispose();
    _problemController.dispose();
    _costController.dispose();
    _accessoriesController.dispose();
    _materialsController.dispose();
    _totalAmountController.dispose();
    _advanceAmountController.dispose();
    _remainingAmountController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onDeviceCategoryChanged(String? category) {
    setState(() {
      _selectedDeviceCategory = category ?? '';
      _selectedBrand = '';
      _selectedModel = '';
      _selectedOS = '';
      _showBrandList = false;
      _brandSearchController.clear();

      // Set default OS for the selected device category
      if (_selectedDeviceCategory.isNotEmpty) {
        final availableOS = _osOptions[_selectedDeviceCategory] ?? [];
        if (availableOS.isNotEmpty) {
          _selectedOS = availableOS.first;
        }
      }
    });
  }

  void _onBrandChanged(String? brand) {
    setState(() {
      _selectedBrand = brand ?? '';
      _selectedModel = '';
      _showBrandList = false; // إغلاق القائمة بعد الاختيار
      _brandSearchController.text =
          brand ?? ''; // عرض الماركة المختارة في صندوق البحث

      if (_selectedDeviceCategory == 'هاتف ذكي') {
        if (brand == 'Apple') {
          _selectedOS = 'iOS';
        } else if (brand == 'Huawei') {
          _selectedOS = 'HarmonyOS';
        } else {
          _selectedOS = 'Android';
        }
      } else if (_selectedDeviceCategory == 'لاب توب') {
        if (brand == 'Apple') {
          _selectedOS = 'macOS';
        } else {
          _selectedOS = 'Windows 11';
        }
      }

      // Ensure selected OS is valid for the current device category
      final availableOS = _osOptions[_selectedDeviceCategory] ?? [];
      if (!availableOS.contains(_selectedOS)) {
        _selectedOS = availableOS.isNotEmpty ? availableOS.first : '';
      }
    });
  }

  void _calculateRemaining() {
    final total = double.tryParse(_totalAmountController.text) ?? 0.0;
    final advance = double.tryParse(_advanceAmountController.text) ?? 0.0;
    final remaining = total - advance;

    setState(() {
      _remainingAmountController.text = remaining.toStringAsFixed(2);
    });
  }

  void _saveDevice() {
    if (_formKey.currentState!.validate()) {
      // Use the device ID that was generated when dialog opened

      // TODO: Save device to database or state management

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إضافة الجهاز بنجاح! رقم الجهاز: $_deviceId'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'نسخ الكود',
            textColor: Colors.white,
            onPressed: () {
              // TODO: Copy device ID to clipboard
            },
          ),
        ),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 950,
        height: 780,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with better design
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.add_circle_outline,
                      size: 32,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إضافة جهاز جديد',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'املأ البيانات المطلوبة لإضافة الجهاز',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.tag,
                                size: 16,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'كود الجهاز: $_deviceId',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Progress indicator with labels
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      for (int i = 0; i < 4; i++)
                        Expanded(
                          child: Container(
                            height: 6,
                            margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                            decoration: BoxDecoration(
                              color:
                                  i <= _currentPage
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[300],
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStepLabel('العميل', 0),
                      _buildStepLabel('الجهاز', 1),
                      _buildStepLabel('العطل', 2),
                      _buildStepLabel('المالية', 3),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged:
                        (page) => setState(() => _currentPage = page),
                    children: [
                      _buildClientInfoPage(),
                      _buildDeviceInfoPage(),
                      _buildProblemInfoPage(),
                      _buildFinancialInfoPage(),
                    ],
                  ),
                ),
              ),
            ),

            // Navigation buttons with better design
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    OutlinedButton.icon(
                      onPressed: _previousPage,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('السابق'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),

                  if (_currentPage < 3)
                    ElevatedButton.icon(
                      onPressed: _nextPage,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('التالي'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _saveDevice,
                      icon: const Icon(Icons.save),
                      label: const Text('حفظ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepLabel(String label, int step) {
    final isActive = step <= _currentPage;
    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? Theme.of(context).primaryColor : Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildClientInfoPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.1),
                  Theme.of(context).primaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_add,
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'معلومات العميل',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'أدخل البيانات الشخصية للعميل',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _buildCustomTextField(
            controller: _clientNameController,
            label: 'الاسم الكامل',
            icon: Icons.person,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى إدخال الاسم الكامل';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildCustomDropdown<String>(
                  value: _selectedGender.isEmpty ? null : _selectedGender,
                  label: 'النوع',
                  icon: Icons.person_outline,
                  items: _genders,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى اختيار النوع';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _buildCustomTextField(
            controller: _clientPhone1Controller,
            label: 'رقم الهاتف الأول',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى إدخال رقم الهاتف الأول';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          _buildCustomTextField(
            controller: _clientPhone2Controller,
            label: 'رقم الهاتف الثاني (اختياري)',
            icon: Icons.phone_android,
            keyboardType: TextInputType.phone,
            isRequired: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfoPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.1),
                  Colors.blue.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.devices, size: 32, color: Colors.blue[700]),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'معلومات الجهاز',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'حدد تفاصيل الجهاز والمواصفات',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // نوع الجهاز
          DropdownButtonFormField<String>(
            value:
                _selectedDeviceCategory.isEmpty
                    ? null
                    : _selectedDeviceCategory,
            decoration: const InputDecoration(
              labelText: 'نوع الجهاز',
              prefixIcon: Icon(Icons.devices),
              border: OutlineInputBorder(),
            ),
            items:
                _deviceCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
            onChanged: _onDeviceCategoryChanged,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى اختيار نوع الجهاز';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // ماركة الجهاز مع البحث
          if (_selectedDeviceCategory.isNotEmpty) ...[
            TextField(
              controller: _brandSearchController,
              decoration: InputDecoration(
                labelText:
                    _selectedBrand.isEmpty
                        ? 'ابحث عن الماركة'
                        : 'الماركة المختارة: $_selectedBrand',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _selectedBrand.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _selectedBrand = '';
                              _selectedModel = '';
                              _selectedOS = '';
                              _brandSearchController.clear();
                              _showBrandList = false;
                            });
                          },
                        )
                        : null,
                border: const OutlineInputBorder(),
              ),
              onTap: () {
                setState(() {
                  _showBrandList = !_showBrandList;
                });
              },
              onChanged: (value) {
                setState(() {
                  _showBrandList = value.isNotEmpty;
                });
              },
            ),

            const SizedBox(height: 8),

            if (_showBrandList && _filteredBrands.isNotEmpty)
              Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
                child: ListView.builder(
                  itemCount: _filteredBrands.length,
                  itemBuilder: (context, index) {
                    final brand = _filteredBrands[index];
                    final isSelected = brand == _selectedBrand;

                    return ListTile(
                      title: Text(brand),
                      selected: isSelected,
                      selectedTileColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(0.1),
                      leading:
                          isSelected
                              ? Icon(
                                Icons.check,
                                color: Theme.of(context).primaryColor,
                              )
                              : null,
                      onTap: () => _onBrandChanged(brand),
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),
          ],

          // الموديل
          if (_selectedBrand.isNotEmpty) ...[
            DropdownButtonFormField<String>(
              value: _selectedModel.isEmpty ? null : _selectedModel,
              decoration: const InputDecoration(
                labelText: 'الموديل',
                prefixIcon: Icon(Icons.phone_android),
                border: OutlineInputBorder(),
              ),
              items:
                  _availableModels.map((model) {
                    return DropdownMenuItem(value: model, child: Text(model));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedModel = value ?? '';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى اختيار الموديل';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),
          ],

          // نظام التشغيل
          if (_selectedDeviceCategory.isNotEmpty) ...[
            DropdownButtonFormField<String>(
              value: _selectedOS.isEmpty ? null : _selectedOS,
              decoration: const InputDecoration(
                labelText: 'نظام التشغيل',
                prefixIcon: Icon(Icons.memory),
                border: OutlineInputBorder(),
              ),
              items:
                  _availableOS.map((os) {
                    return DropdownMenuItem(value: os, child: Text(os));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedOS = value ?? '';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى اختيار نظام التشغيل';
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProblemInfoPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.withOpacity(0.1),
                  Colors.orange.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.build_circle, size: 32, color: Colors.orange[700]),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تفاصيل العطل والتكلفة',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'وصف المشكلة والتكلفة المتوقعة',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          DropdownButtonFormField<String>(
            value: _selectedFaultType.isEmpty ? null : _selectedFaultType,
            decoration: const InputDecoration(
              labelText: 'نوع العطل',
              prefixIcon: Icon(Icons.build),
              border: OutlineInputBorder(),
            ),
            items:
                _faultTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedFaultType = value ?? '';
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى اختيار نوع العطل';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _problemController,
            decoration: const InputDecoration(
              labelText: 'وصف المشكلة',
              prefixIcon: Icon(Icons.description),
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى وصف المشكلة';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          const SizedBox(height: 16),

          TextFormField(
            controller: _accessoriesController,
            decoration: const InputDecoration(
              labelText: 'الملحقات المرفقة',
              prefixIcon: Icon(Icons.inventory_2),
              border: OutlineInputBorder(),
              hintText: 'مثال: شاحن، سماعات، كيس الحماية...',
            ),
            maxLines: 2,
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedStatus,
            decoration: const InputDecoration(
              labelText: 'حالة الجهاز',
              prefixIcon: Icon(Icons.flag),
              border: OutlineInputBorder(),
            ),
            items:
                _statuses.map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStatus = value ?? 'في الانتظار';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialInfoPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withOpacity(0.1),
                  Colors.purple.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.attach_money, size: 32, color: Colors.purple[700]),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المعلومات المالية والمواد',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'التكلفة والمبالغ المطلوبة',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          TextFormField(
            controller: _materialsController,
            decoration: const InputDecoration(
              labelText: 'المواد المطلوبة',
              prefixIcon: Icon(Icons.construction),
              border: OutlineInputBorder(),
              hintText: 'مثال: شاشة جديدة، بطارية، قطع غيار...',
            ),
            maxLines: 3,
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _totalAmountController,
            decoration: const InputDecoration(
              labelText: 'المبلغ الكلي',
              prefixIcon: Icon(Icons.attach_money),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => _calculateRemaining(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى إدخال المبلغ الكلي';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _advanceAmountController,
            decoration: const InputDecoration(
              labelText: 'المبلغ المقدم',
              prefixIcon: Icon(Icons.payment),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => _calculateRemaining(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى إدخال المبلغ المقدم';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _remainingAmountController,
            decoration: const InputDecoration(
              labelText: 'المبلغ المتبقي (محسوب تلقائياً)',
              prefixIcon: Icon(Icons.account_balance),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            readOnly: true,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'سيتم حساب المبلغ المتبقي تلقائياً عند إدخال المبلغ الكلي والمقدم',
                    style: TextStyle(color: Colors.blue[700], fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool isRequired = true,
    int maxLines = 1,
    String? hintText,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDropdown<T>({
    required T? value,
    required String label,
    required IconData icon,
    required List<T> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        items:
            items.map((T item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    item.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
        onChanged: onChanged,
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 8,
      ),
    );
  }

  Widget _buildDeviceIdCard(String stepText, MaterialColor color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.qr_code, color: color[700], size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'كود الجهاز',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _deviceId,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color[700],
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              stepText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
