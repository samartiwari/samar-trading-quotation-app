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
