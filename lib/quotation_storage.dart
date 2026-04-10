import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Model representing a saved quotation for editing purposes
class SavedQuotation {
  final String id;
  final String customerName;
  final String customerAddress;
  final int gstPercentage;
  final List<SavedQuotationItem> items;
  final DateTime createdAt;
  final String? pdfPath;

  SavedQuotation({
    required this.id,
    required this.customerName,
    required this.customerAddress,
    required this.gstPercentage,
    required this.items,
    required this.createdAt,
    this.pdfPath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerName': customerName,
        'customerAddress': customerAddress,
        'gstPercentage': gstPercentage,
        'items': items.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'pdfPath': pdfPath,
      };

  factory SavedQuotation.fromJson(Map<String, dynamic> json) => SavedQuotation(
        id: json['id'] as String,
        customerName: json['customerName'] as String,
        customerAddress: json['customerAddress'] as String,
        gstPercentage: json['gstPercentage'] as int,
        items: (json['items'] as List)
            .map((e) => SavedQuotationItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        pdfPath: json['pdfPath'] as String?,
      );
}

class SavedQuotationItem {
  final String description;
  final String qty;
  final String rate;
  final String unit;
  final double amount;

  SavedQuotationItem({
    required this.description,
    required this.qty,
    required this.rate,
    required this.unit,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        'description': description,
        'qty': qty,
        'rate': rate,
        'unit': unit,
        'amount': amount,
      };

  factory SavedQuotationItem.fromJson(Map<String, dynamic> json) =>
      SavedQuotationItem(
        description: json['description'] as String,
        qty: json['qty'] as String,
        rate: json['rate'] as String,
        unit: json['unit'] as String,
        amount: (json['amount'] as num).toDouble(),
      );
}

/// Service to manage quotation storage
class QuotationStorage {
  static const String _storageKey = 'saved_quotations';

  /// Save a quotation to storage
  static Future<void> saveQuotation(SavedQuotation quotation) async {
    final prefs = await SharedPreferences.getInstance();
    final quotations = await getAllQuotations();
    
    // Check if quotation with same ID exists, update it
    final existingIndex = quotations.indexWhere((q) => q.id == quotation.id);
    if (existingIndex != -1) {
      quotations[existingIndex] = quotation;
    } else {
      quotations.insert(0, quotation); // Add to beginning
    }
    
    final jsonList = quotations.map((q) => q.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  /// Get all saved quotations
  static Future<List<SavedQuotation>> getAllQuotations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((e) => SavedQuotation.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get a quotation by ID
  static Future<SavedQuotation?> getQuotationById(String id) async {
    final quotations = await getAllQuotations();
    try {
      return quotations.firstWhere((q) => q.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get quotation by PDF path
  static Future<SavedQuotation?> getQuotationByPdfPath(String pdfPath) async {
    final quotations = await getAllQuotations();
    try {
      return quotations.firstWhere((q) => q.pdfPath == pdfPath);
    } catch (e) {
      return null;
    }
  }

  /// Delete a quotation by ID
  static Future<void> deleteQuotation(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final quotations = await getAllQuotations();
    quotations.removeWhere((q) => q.id == id);
    
    final jsonList = quotations.map((q) => q.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  /// Generate a unique ID for a new quotation
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

// ============ CHALLAN MODELS & STORAGE ============

class SavedChallan {
  final String id;
  final String customerName;
  final String customerAddress;
  final String customerMobile;
  final String destination;
  final List<SavedChallanItem> items;
  final DateTime createdAt;
  final String? pdfPath;

  SavedChallan({
    required this.id,
    required this.customerName,
    required this.customerAddress,
    required this.customerMobile,
    required this.destination,
    required this.items,
    required this.createdAt,
    this.pdfPath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerName': customerName,
        'customerAddress': customerAddress,
        'customerMobile': customerMobile,
        'destination': destination,
        'items': items.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'pdfPath': pdfPath,
      };

  factory SavedChallan.fromJson(Map<String, dynamic> json) => SavedChallan(
        id: json['id'] as String,
        customerName: json['customerName'] as String,
        customerAddress: json['customerAddress'] as String,
        customerMobile: (json['customerMobile'] as String?) ?? '',
        destination: json['destination'] as String,
        items: (json['items'] as List)
            .map((e) => SavedChallanItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        pdfPath: json['pdfPath'] as String?,
      );
}

class SavedChallanItem {
  final String description;
  final String hsnSac;
  final String qty;
  final String unit;
  final String dimensions;

  SavedChallanItem({
    required this.description,
    required this.hsnSac,
    required this.qty,
    required this.unit,
    required this.dimensions,
  });

  Map<String, dynamic> toJson() => {
        'description': description,
        'hsnSac': hsnSac,
        'qty': qty,
        'unit': unit,
        'dimensions': dimensions,
      };

  factory SavedChallanItem.fromJson(Map<String, dynamic> json) =>
      SavedChallanItem(
        description: json['description'] as String,
        hsnSac: json['hsnSac'] as String,
        qty: json['qty'] as String,
        unit: json['unit'] as String,
        dimensions: json['dimensions'] as String,
      );
}

class ChallanStorage {
  static const String _storageKey = 'saved_challans';

  static Future<void> saveChallan(SavedChallan challan) async {
    final prefs = await SharedPreferences.getInstance();
    final challans = await getAllChallans();

    final existingIndex = challans.indexWhere((c) => c.id == challan.id);
    if (existingIndex != -1) {
      challans[existingIndex] = challan;
    } else {
      challans.insert(0, challan);
    }

    final jsonList = challans.map((c) => c.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  static Future<List<SavedChallan>> getAllChallans() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((e) => SavedChallan.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<SavedChallan?> getChallanByPdfPath(String pdfPath) async {
    final challans = await getAllChallans();
    try {
      return challans.firstWhere((c) => c.pdfPath == pdfPath);
    } catch (e) {
      return null;
    }
  }

  static Future<void> deleteChallan(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final challans = await getAllChallans();
    challans.removeWhere((c) => c.id == id);

    final jsonList = challans.map((c) => c.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
