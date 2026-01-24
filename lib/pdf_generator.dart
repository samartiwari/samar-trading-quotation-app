import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';
import 'quotation_creation_screen.dart';

class PdfGenerator {
  // Company Details
  static const String companyName = 'SAMAR TRADING';
  static const String companyAddress =
      '4/117, Fims College Road Vibhav Khand -4,\nVibhav Khand, Gomti Nagar\nLucknow, Uttar Pradesh 226010';
  static const String companyPhone = '8429153343';
  static const String companyGstin = '09COTPT3845R1ZI';

  // Professional Colors (More muted and serious)
  static const PdfColor primaryColor = PdfColor.fromInt(0xFF212121); // Dark Grey / Near Black
  static const PdfColor accentColor = PdfColor.fromInt(0xFF424242); // Medium Grey
  static const PdfColor lightBg = PdfColor.fromInt(0xFFFAFAFA); // Very light grey

  // Storage key for quote counter
  static const String _quoteCounterKey = 'quote_counter';

  // --- Generate Quote Number (Sequential, Persistent) ---
  static Future<String> _generateQuoteNumber() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get current counter (default to 0 if not set)
    int currentCounter = prefs.getInt(_quoteCounterKey) ?? 0;
    
    // Increment the counter
    currentCounter++;
    
    // Save the new counter
    await prefs.setInt(_quoteCounterKey, currentCounter);
    
    // Generate quote number: QT-YYYY-NNNNN
    final year = DateTime.now().year;
    final paddedCounter = currentCounter.toString().padLeft(5, '0');
    
    return 'QT-$year-$paddedCounter';
  }

  // --- 1. THE MAIN FUNCTION TO SAVE FILE ---
  static Future<String> saveToDefaultFolder({
    required String name,
    required String address,
    required List<QuotationItem> items,
    required double subtotal,
    required double gst,
    required double grandTotal,
    required int gstPercentage,
  }) async {
    final pdf = await _generateDocument(name, address, items, subtotal, gst, grandTotal, gstPercentage);

    final directory = await getApplicationDocumentsDirectory();
    final customPath = path.join(directory.path, 'Samar Trading Invoices');
    final customDir = Directory(customPath);

    if (!await customDir.exists()) {
      await customDir.create(recursive: true);
    }

    final safeName = name.replaceAll(RegExp(r'[^\w\s]+'), '');
    final timestamp = DateTime.now().toString().split('.')[0].replaceAll(':', '-');
    final filePath = path.join(customPath, 'QT_${safeName}_$timestamp.pdf');

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  // --- 2. THE PDF DESIGN ---
  static Future<pw.Document> _generateDocument(
      String customerName,
      String customerAddress,
      List<QuotationItem> items,
      double subtotal,
      double gst,
      double grandTotal,
      int gstPercentage) async {
    final pdf = pw.Document();

    final now = DateTime.now();
    final validUntil = now.add(const Duration(days: 7));
    final quoteNumber = await _generateQuoteNumber();

    // Load logo image from assets
    final logoData = await rootBundle.load('assets/logo.png');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    // Date formatting
    String formatDate(DateTime date) {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (pw.Context context) {
          // Only show full header on first page
          if (context.pageNumber == 1) {
            return pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 20),
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 2)),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // LEFT: Company Info with Logo
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // We use a Stack so the Logo doesn't push the text down
                      pw.SizedBox(
                        height: 60, // This fixes the vertical space the logo "area" takes
                        width: 300,
                        child: pw.Stack(
                          alignment: pw.Alignment.centerLeft,
                          children: [
                            pw.Positioned(
                              left: 25, // Pulls the logo left to ignore the image's internal padding
                              top: -30,  // Pulls the logo up to ignore the image's internal padding
                              child: pw.Transform.scale(
                                scale: 1.8, // This makes the logo larger without moving the text
                                child: pw.Image(logoImage, width: 120, height: 120),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Address & Contact - These will now stay in place
                      pw.Text(
                        companyAddress,
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700, lineSpacing: 3),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Row(
                        children: [
                          pw.Text('Phone: ', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
                          pw.Text(companyPhone, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                        ],
                      ),
                      pw.SizedBox(height: 2),
                      pw.Row(
                        children: [
                          pw.Text('GSTIN: ', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
                          pw.Text(companyGstin, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                        ],
                      ),
                    ],
                  ),

                  // RIGHT: Quotation Info
                  pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: lightBg,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        _infoRow('Quote #:', quoteNumber),
                        pw.SizedBox(height: 4),
                        _infoRow('Date:', formatDate(now)),
                        pw.SizedBox(height: 4),
                        _infoRow('Valid Until:', formatDate(validUntil)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Compact header for subsequent pages
            return pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 10),
              margin: const pw.EdgeInsets.only(bottom: 10),
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 1)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    companyName,
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  pw.Text(
                    'Quotation: $quoteNumber',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                ],
              ),
            );
          }
        },
        footer: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(top: 10),
            decoration: const pw.BoxDecoration(
              border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 1)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  '$companyName | Phone: $companyPhone',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          return [
            pw.SizedBox(height: 24),

            // ============ BILL TO SECTION ============
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFF5F5F5), // Light grey (professional)
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'BILL TO',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: accentColor,
                      letterSpacing: 1,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    customerName,
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
                  ),
                  if (customerAddress.isNotEmpty)
                    pw.Text(
                      customerAddress,
                      style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                    ),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // ============ ITEMS TABLE ============
            pw.Table(
              border: null,
              columnWidths: {
                0: const pw.FlexColumnWidth(0.8), // S.No
                1: const pw.FlexColumnWidth(5),   // Description
                2: const pw.FlexColumnWidth(1.2), // Qty
                3: const pw.FlexColumnWidth(1.2), // Unit
                4: const pw.FlexColumnWidth(2),   // Rate
                5: const pw.FlexColumnWidth(2),   // Amount
              },
              children: [
                // Header Row
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: primaryColor,
                    borderRadius: const pw.BorderRadius.only(
                      topLeft: pw.Radius.circular(6),
                      topRight: pw.Radius.circular(6),
                    ),
                  ),
                  children: [
                    _tableCell('#', isHeader: true, align: pw.TextAlign.center),
                    _tableCell('DESCRIPTION', isHeader: true),
                    _tableCell('QTY', isHeader: true, align: pw.TextAlign.center),
                    _tableCell('UNIT', isHeader: true, align: pw.TextAlign.center),
                    _tableCell('RATE (Rs.)', isHeader: true, align: pw.TextAlign.right),
                    _tableCell('AMOUNT (Rs.)', isHeader: true, align: pw.TextAlign.right),
                  ],
                ),
                // Data Rows - Filter out empty items
                ...items.where((item) => 
                  item.description.text.trim().isNotEmpty || 
                  item.qty.text.trim().isNotEmpty || 
                  item.rate.text.trim().isNotEmpty
                ).toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isEven = index % 2 == 0;
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: isEven ? PdfColors.white : lightBg,
                      border: const pw.Border(
                        bottom: pw.BorderSide(color: PdfColors.grey200),
                      ),
                    ),
                    children: [
                      _tableCell((index + 1).toString(), align: pw.TextAlign.center),
                      _tableCell(item.description.text),
                      _tableCell(item.qty.text, align: pw.TextAlign.center),
                      _tableCell(item.unit, align: pw.TextAlign.center),
                      _tableCell(item.rate.text, align: pw.TextAlign.right),
                      _tableCell(item.amount.toStringAsFixed(2), align: pw.TextAlign.right),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 24),

            // ============ TOTALS SECTION ============
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  width: 220,
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: lightBg,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Column(
                    children: [
                      _totalRow('Subtotal', subtotal),
                      pw.SizedBox(height: 6),
                      _totalRow('GST ($gstPercentage%)', gst),
                      pw.Divider(color: PdfColors.grey400, height: 16),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: pw.BoxDecoration(
                          color: primaryColor,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                        ),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'GRAND TOTAL',
                              style: pw.TextStyle(
                                fontSize: 11,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                            pw.Text(
                              'Rs. ${grandTotal.toStringAsFixed(2)}',
                              style: pw.TextStyle(
                                fontSize: 13,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),


            pw.SizedBox(height: 24),

            // ============ TERMS & CONDITIONS + BANK DETAILS ============
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // LEFT: Terms & Conditions
                pw.Expanded(
                  flex: 1,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromInt(0xFFF5F5F5), // Light grey (professional)
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'TERMS & CONDITIONS',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        _termItem('1. Payment: 100% advance before dispatch.'),
                        _termItem('2. Prices are valid for 7 days from quote date.'),
                        _termItem('3. Delivery timeline will be confirmed upon order.'),
                        _termItem('4. Goods once sold will not be taken back.'),
                        _termItem('5. Freight cost is extra.'),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 16),
                // RIGHT: Bank Details
                pw.Expanded(
                  flex: 1,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromInt(0xFFF5F5F5), // Light grey (professional)
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'BANK DETAILS',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        _bankDetailRow('Account Name', 'M/s SAMAR TRADING'),
                        _bankDetailRow('Bank Name', 'Karnataka Bank'),
                        _bankDetailRow('Account No.', '5942000100024001'),
                        _bankDetailRow('IFSC Code', 'KARB0000594'),
                        _bankDetailRow('Branch', 'Gomti Nagar Branch'),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // ============ THANK YOU MESSAGE ============
            pw.Container(
              width: double.infinity,
              child: pw.Center(
                child: pw.Text(
                  'Thank you for your business!',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  // --- Helper: Info Row (for Quotation header) ---
  static pw.Widget _infoRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
        pw.SizedBox(width: 8),
        pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900)),
      ],
    );
  }

  // --- Helper: Table Cell ---
  static pw.Widget _tableCell(String text, {bool isHeader = false, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: isHeader ? 9 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.white : PdfColors.grey800,
          letterSpacing: isHeader ? 0.5 : 0,
        ),
      ),
    );
  }

  // --- Helper: Total Row ---
  static pw.Widget _totalRow(String label, double value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        pw.Text('Rs. ${value.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900)),
      ],
    );
  }

  // --- Helper: Terms Item ---
  static pw.Widget _termItem(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700, lineSpacing: 1.5),
      ),
    );
  }

  // --- Helper: Bank Detail Row ---
  static pw.Widget _bankDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              '$label:',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
            ),
          ),
        ],
      ),
    );
  }
}