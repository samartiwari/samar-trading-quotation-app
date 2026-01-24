import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:samar_trading_quotation/pdf_generator.dart';
import 'package:samar_trading_quotation/quotation_storage.dart';

class QuotationCreationScreen extends StatefulWidget {
  final SavedQuotation? editQuotation;
  
  const QuotationCreationScreen({super.key, this.editQuotation});

  @override
  State<QuotationCreationScreen> createState() => _QuotationCreationScreenState();
}

class _QuotationCreationScreenState extends State<QuotationCreationScreen> {
  // --- Controllers for Customer Info ---
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  // --- GST Percentage Selection ---
  int _gstPercentage = 18; // Default 18%

  // --- Quotation ID (for editing) ---
  String? _quotationId;

  // --- List of Items (The Table Data) ---
  final List<QuotationItem> _items = [];

  // --- Calculations ---
  double get _subtotal {
    return _items.fold(0, (sum, item) => sum + item.amount);
  }

  double get _gst => _subtotal * (_gstPercentage / 100);
  double get _grandTotal => _subtotal + _gst;

  @override
  void initState() {
    super.initState();
    
    // Check if we're editing an existing quotation
    if (widget.editQuotation != null) {
      _loadEditQuotation();
    } else {
      // Add one empty row by default so the screen isn't blank
      _addItem();
    }
  }

  void _loadEditQuotation() {
    final quotation = widget.editQuotation!;
    _quotationId = quotation.id;
    _nameController.text = quotation.customerName;
    _addressController.text = quotation.customerAddress;
    _gstPercentage = quotation.gstPercentage;
    
    for (final savedItem in quotation.items) {
      final item = QuotationItem(
        onChanged: () => setState(() {}),
        initialDescription: savedItem.description,
        initialQty: savedItem.qty,
        initialRate: savedItem.rate,
        initialUnit: savedItem.unit,
      );
      _items.add(item);
    }
    
    // Add at least one empty row if no items
    if (_items.isEmpty) {
      _addItem();
    }
  }

  void _addItem() {
    setState(() {
      _items.add(QuotationItem(onChanged: () => setState(() {})));
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items[index].dispose(); // Clean up memory
      _items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background for contrast
      appBar: AppBar(
        title: const Text("New Quotation"),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
        actions: [
          FilledButton.icon(
            onPressed: () async {
              // 1. Validation
              if (_items.isEmpty || _nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Fill in Name and Items first!")),
                );
                return;
              }

              // 2. Show "Saving" indicator
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Generating PDF...")),
              );

              try {
                // 3. Save the file
                final filePath = await PdfGenerator.saveToDefaultFolder(
                  name: _nameController.text,
                  address: _addressController.text,
                  items: _items,
                  subtotal: _subtotal,
                  gst: _gst,
                  grandTotal: _grandTotal,
                  gstPercentage: _gstPercentage,
                );

                // Save quotation data to storage for future editing
                final savedQuotation = SavedQuotation(
                  id: _quotationId ?? QuotationStorage.generateId(),
                  customerName: _nameController.text,
                  customerAddress: _addressController.text,
                  gstPercentage: _gstPercentage,
                  items: _items.map((item) => SavedQuotationItem(
                    description: item.description.text,
                    qty: item.qty.text,
                    rate: item.rate.text,
                    unit: item.unit,
                    amount: item.amount,
                  )).toList(),
                  createdAt: DateTime.now(),
                  pdfPath: filePath,
                );
                await QuotationStorage.saveQuotation(savedQuotation);

                // 4. AUTO-OPEN: This opens the PDF immediately!
                await OpenFile.open(filePath);

                // 5. Show where it was saved (useful for debugging)
                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Saved to: $filePath"), // Shows the exact path
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }

                // Print to console so you can see it in VS Code
                print("PDF SAVED AT: $filePath");
              } catch (e) {
                print(e);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e")),
                );
              }
            },
            icon: const Icon(Icons.save_alt),
            label: const Text("Save & Open"),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION 1: CUSTOMER INFO ---
            _buildCustomerSection(),
            const SizedBox(height: 32),

            // --- SECTION 2: ITEM TABLE ---
            const Text(
              "Items",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTableStructure(),

            const SizedBox(height: 16),

            // Add Row Button
            OutlinedButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
              label: const Text("Add Row"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),

            const SizedBox(height: 32),
            const Divider(),

            // --- SECTION 3: TOTALS ---
            _buildTotalsSection(),
          ],
        ),
      ),
    );
  }

  // Widget for Customer Details Card
  Widget _buildCustomerSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Customer Details",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Customer Name",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: "Address (Optional)",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<int>(
                    value: _gstPercentage,
                    decoration: const InputDecoration(
                      labelText: "GST %",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.percent),
                    ),
                    items: const [
                      DropdownMenuItem(value: 18, child: Text("18%")),
                      DropdownMenuItem(value: 0, child: Text("0%")),
                    ],
                    onChanged: (val) {
                      setState(() => _gstPercentage = val!);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // The Header + List of Rows
  Widget _buildTableStructure() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 4, child: Text("Description", style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 10),
                Expanded(flex: 1, child: Text("Qty", style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 10),
                Expanded(flex: 2, child: Text("Unit", style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 10),
                Expanded(flex: 2, child: Text("Rate", style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 10),
                Expanded(flex: 2, child: Text("Amount", style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 40), // Space for Delete Icon
              ],
            ),
          ),
          const Divider(height: 1),

          // Table Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _buildItemRow(index, _items[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(int index, QuotationItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Expanded(
            flex: 4,
            child: TextField(
              controller: item.description,
              decoration: const InputDecoration(
                hintText: "Item Name",
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Qty
          Expanded(
            flex: 1,
            child: TextField(
              controller: item.qty,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                DecimalTextInputFormatter(),
              ],
              decoration: const InputDecoration(
                hintText: "0",
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (val) => item.updateAmount(),
            ),
          ),
          const SizedBox(width: 10),
          // Unit Dropdown
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              value: item.unit,
              decoration: const InputDecoration(border: InputBorder.none, isDense: true),
              items: ["sqft", "mtr", "pcs", "kg", "box", "ltr"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                setState(() => item.unit = val!);
              },
            ),
          ),
          const SizedBox(width: 10),
          // Rate
          Expanded(
            flex: 2,
            child: TextField(
              controller: item.rate,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                DecimalTextInputFormatter(),
              ],
              decoration: const InputDecoration(
                hintText: "0.00",
                border: InputBorder.none,
                isDense: true,
                prefixText: "Rs. ",
              ),
              onChanged: (val) => item.updateAmount(),
            ),
          ),
          const SizedBox(width: 10),
          // Amount (Read Only)
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(
                                "Rs. ${item.amount.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _removeItem(index),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsSection() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            _buildSummaryRow("Subtotal", _subtotal),
            const SizedBox(height: 8),
            _buildSummaryRow("GST ($_gstPercentage%)", _gst),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Grand Total",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                                    "Rs. ${_grandTotal.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                Text("Rs. ${value.toStringAsFixed(2)}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// --- HELPER CLASS ---
// This holds the state for a single row in the table
class QuotationItem {
  final TextEditingController description = TextEditingController();
  final TextEditingController qty = TextEditingController();
  final TextEditingController rate = TextEditingController();

  String unit = "sqft"; // Default unit (changed from pcs)
  double amount = 0.0;

  final VoidCallback onChanged;

  QuotationItem({
    required this.onChanged,
    String? initialDescription,
    String? initialQty,
    String? initialRate,
    String? initialUnit,
  }) {
    if (initialDescription != null) description.text = initialDescription;
    if (initialQty != null) qty.text = initialQty;
    if (initialRate != null) rate.text = initialRate;
    if (initialUnit != null) unit = initialUnit;
    
    // Calculate initial amount if values provided
    updateAmount();
  }

  void updateAmount() {
    double q = double.tryParse(qty.text) ?? 0;
    double r = double.tryParse(rate.text) ?? 0;
    amount = q * r;
    onChanged(); // Notify the parent to rebuild totals
  }

  void dispose() {
    description.dispose();
    qty.dispose();
    rate.dispose();
  }
}

// Custom formatter that allows only valid decimal numbers
// Rejects invalid characters without clearing the field
class DecimalTextInputFormatter extends TextInputFormatter {
  final RegExp _regExp = RegExp(r'^\d*\.?\d*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If the new value matches the pattern, allow it
    if (_regExp.hasMatch(newValue.text)) {
      return newValue;
    }
    // Otherwise, keep the old value (reject the input)
    return oldValue;
  }
}