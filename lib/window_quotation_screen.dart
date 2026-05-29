import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_file/open_file.dart';
import 'package:samar_trading_quotation/pdf_generator.dart';
import 'package:samar_trading_quotation/quotation_storage.dart';
import 'package:samar_trading_quotation/window_design_picker.dart';
import 'package:samar_trading_quotation/window_designs.dart';

class WindowQuotationScreen extends StatefulWidget {
  final SavedWindowQuotation? editQuotation;

  const WindowQuotationScreen({super.key, this.editQuotation});

  @override
  State<WindowQuotationScreen> createState() => _WindowQuotationScreenState();
}

class _WindowQuotationScreenState extends State<WindowQuotationScreen> {
  // --- Controllers for Customer Info ---
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  // --- GST Percentage Selection ---
  int _gstPercentage = 18; // Default 18%

  // --- Quotation ID (for editing) ---
  String? _quotationId;

  // --- List of Items (The Table Data) ---
  final List<WindowQuotationItem> _items = [];

  // --- Calculations ---
  double get _subtotal {
    return _items.fold(0, (sum, item) => sum + item.amount);
  }

  double get _gst => _subtotal * (_gstPercentage / 100);
  double get _grandTotal => _subtotal + _gst;

  @override
  void initState() {
    super.initState();

    if (widget.editQuotation != null) {
      _loadEditQuotation();
    }
    // New quotations start with an empty table — user adds via dialog
  }

  void _loadEditQuotation() {
    final quotation = widget.editQuotation!;
    _quotationId = quotation.id;
    _nameController.text = quotation.customerName;
    _addressController.text = quotation.customerAddress;
    _gstPercentage = quotation.gstPercentage;

    for (final savedItem in quotation.items) {
      final item = WindowQuotationItem(
        onChanged: () => setState(() {}),
        initialDescription: savedItem.description,
        initialLengthMm: savedItem.lengthMm,
        initialWidthMm: savedItem.widthMm,
        initialQty: savedItem.qty,
        initialRate: savedItem.rate,
        initialWindowSeries: savedItem.windowSeries,
        initialDesignId: savedItem.designId,
        initialFrameColor: savedItem.frameColor,
        initialGi: savedItem.gi,
        initialGlassType: savedItem.glassType,
        initialSashOuter: savedItem.sashOuter,
        initialSlidingType: savedItem.slidingType,
        initialHandleType: savedItem.handleType,
        initialLocking: savedItem.locking,
        initialHinges: savedItem.hinges,
      );
      _items.add(item);
    }
  }

  void _removeItem(int index) {
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
    });
  }

  void _editItem(int index) {
    _showWindowDialog(editIndex: index);
  }

  /// Opens a spacious dialog for adding a new window or editing an existing one.
  /// If [editIndex] is provided, pre-fills the dialog with data from that item.
  void _showWindowDialog({int? editIndex}) {
    final isEditing = editIndex != null;
    final existingItem = isEditing ? _items[editIndex] : null;

    // Local controllers for the dialog
    final lengthCtrl = TextEditingController(
        text: existingItem?.lengthMm.text ?? '');
    final widthCtrl = TextEditingController(
        text: existingItem?.widthMm.text ?? '');
    final qtyCtrl = TextEditingController(
        text: existingItem?.qty.text ?? '1');
    final rateCtrl = TextEditingController(
        text: existingItem?.rate.text ?? '');
    final glassTypeCtrl = TextEditingController(
        text: existingItem?.glassType.text ?? '');
    final sashOuterCtrl = TextEditingController(
        text: existingItem?.sashOuter.text ?? '');

    // Dropdown initial values
    final initialSeries = existingItem?.windowSeries ?? 'Fixed';
    final initialDesignId = existingItem?.designId ?? 'fixed_1';
    final initialFrameColor = existingItem?.frameColor ?? 'white';
    final initialGi = existingItem?.gi ?? '0.8';
    final initialSlidingType = existingItem?.slidingType ?? '2 Track';
    final initialHandleType = existingItem?.handleType ?? 'Touch Lock';
    final initialLocking = existingItem?.locking ?? 'Single Point';
    final initialHinges = existingItem?.hinges ?? '2D Hinges';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _WindowItemDialog(
          isEditing: isEditing,
          lengthCtrl: lengthCtrl,
          widthCtrl: widthCtrl,
          qtyCtrl: qtyCtrl,
          rateCtrl: rateCtrl,
          glassTypeCtrl: glassTypeCtrl,
          sashOuterCtrl: sashOuterCtrl,
          initialSeries: initialSeries,
          initialDesignId: initialDesignId,
          initialFrameColor: initialFrameColor,
          initialGi: initialGi,
          initialSlidingType: initialSlidingType,
          initialHandleType: initialHandleType,
          initialLocking: initialLocking,
          initialHinges: initialHinges,
          onSave: (dialogState) {
            setState(() {
              final autoDescription = "${dialogState.windowSeries} Window";
              if (isEditing) {
                // Update the existing item's controllers & fields
                existingItem!.description.text = autoDescription;
                existingItem.lengthMm.text = lengthCtrl.text;
                existingItem.widthMm.text = widthCtrl.text;
                existingItem.qty.text = qtyCtrl.text;
                existingItem.rate.text = rateCtrl.text;
                existingItem.glassType.text = glassTypeCtrl.text;
                existingItem.sashOuter.text = sashOuterCtrl.text;
                existingItem.windowSeries = dialogState.windowSeries;
                existingItem.designId = dialogState.designId;
                existingItem.frameColor = dialogState.frameColor;
                existingItem.gi = dialogState.gi;
                existingItem.slidingType = dialogState.slidingType;
                existingItem.handleType = dialogState.handleType;
                existingItem.locking = dialogState.locking;
                existingItem.hinges = dialogState.hinges;
                existingItem.updateAmount();
              } else {
                // Create a new item
                final newItem = WindowQuotationItem(
                  onChanged: () => setState(() {}),
                  initialDescription: autoDescription,
                  initialLengthMm: lengthCtrl.text,
                  initialWidthMm: widthCtrl.text,
                  initialQty: qtyCtrl.text,
                  initialRate: rateCtrl.text,
                  initialGlassType: glassTypeCtrl.text,
                  initialSashOuter: sashOuterCtrl.text,
                  initialWindowSeries: dialogState.windowSeries,
                  initialDesignId: dialogState.designId,
                  initialFrameColor: dialogState.frameColor,
                  initialGi: dialogState.gi,
                  initialSlidingType: dialogState.slidingType,
                  initialHandleType: dialogState.handleType,
                  initialLocking: dialogState.locking,
                  initialHinges: dialogState.hinges,
                );
                _items.add(newItem);
              }
            });
            Navigator.of(dialogContext).pop();
          },
          onCancel: () {
            Navigator.of(dialogContext).pop();
          },
        );
      },
    ).then((_) {
      // Dispose dialog controllers after dialog closes
      lengthCtrl.dispose();
      widthCtrl.dispose();
      qtyCtrl.dispose();
      rateCtrl.dispose();
      glassTypeCtrl.dispose();
      sashOuterCtrl.dispose();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.editQuotation != null
            ? "Edit Window Quotation"
            : "New Window Quotation"),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
        actions: [
          FilledButton.icon(
            onPressed: () async {
              // 1. Validation
              if (_items.isEmpty || _nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Fill in Name and Items first!")),
                );
                return;
              }

              // 2. Show "Saving" indicator
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Generating PDF...")),
              );

              try {
                // 3. Save the file
                final filePath =
                    await PdfGenerator.saveWindowQuotationToDefaultFolder(
                  name: _nameController.text,
                  address: _addressController.text,
                  items: _items,
                  subtotal: _subtotal,
                  gst: _gst,
                  grandTotal: _grandTotal,
                  gstPercentage: _gstPercentage,
                );

                // Save quotation data to storage for future editing
                final savedQuotation = SavedWindowQuotation(
                  id: _quotationId ?? WindowQuotationStorage.generateId(),
                  customerName: _nameController.text,
                  customerAddress: _addressController.text,
                  gstPercentage: _gstPercentage,
                  items: _items
                      .map((item) => SavedWindowQuotationItem(
                            description: item.description.text,
                            lengthMm: item.lengthMm.text,
                            widthMm: item.widthMm.text,
                            areaSqft: item.areaSqft,
                            qty: item.qty.text,
                            rate: item.rate.text,
                            amount: item.amount,
                            windowSeries: item.windowSeries,
                            designId: item.designId,
                            frameColor: item.frameColor,
                            gi: item.gi,
                            glassType: item.glassType.text,
                            sashOuter: item.sashOuter.text,
                            slidingType: item.slidingType,
                            handleType: item.handleType,
                            locking: item.locking,
                            hinges: item.hinges,
                          ))
                      .toList(),
                  createdAt: DateTime.now(),
                  pdfPath: filePath,
                );
                await WindowQuotationStorage.saveQuotation(savedQuotation);

                // 4. AUTO-OPEN
                await OpenFile.open(filePath);

                // 5. Show where it was saved
                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Saved to: $filePath"),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }

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
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Window Items",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Add windows using the button below. Dimensions in mm, area auto-calculated in sqft.",
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                FilledButton.icon(
                  onPressed: () => _showWindowDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text("Add Window"),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xff8D6E63),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTableStructure(),

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
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
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
                      DropdownMenuItem(value: 9, child: Text("9%")),
                      DropdownMenuItem(value: 5, child: Text("5%")),
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

  // The Header + List of Read-Only Rows
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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: const Row(
              children: [
                SizedBox(width: 40, child: Text("#", style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 8),
                Expanded(
                    flex: 3,
                    child: Text("Description",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 8),
                Expanded(
                    flex: 1,
                    child: Text("Length (mm)",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 8),
                Expanded(
                    flex: 1,
                    child: Text("Width (mm)",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 8),
                Expanded(
                    flex: 1,
                    child: Text("Area (sqft)",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 8),
                Expanded(
                    flex: 1,
                    child: Text("Qty",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 8),
                Expanded(
                    flex: 2,
                    child: Text("Rate / sqft",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 8),
                Expanded(
                    flex: 2,
                    child: Text("Amount",
                        style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 80), // Space for Edit + Delete Icons
              ],
            ),
          ),
          const Divider(height: 1),

          // Empty state or rows
          if (_items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.window_rounded,
                      size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    "No windows added yet.\nClick \"Add Window\" to get started.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          else
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

  Widget _buildSpecChip(String label, String value, Color baseColor) {
    return Container(
      margin: const EdgeInsets.only(right: 4, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: baseColor.withValues(alpha: 0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: baseColor.withValues(alpha: 0.85),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: baseColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(int index, WindowQuotationItem item) {
    // Build specs chips
    final chips = <Widget>[];
    chips.add(_buildSpecChip('GI', '${item.gi} mm', Colors.orange.shade900));
    if (item.glassType.text.isNotEmpty) {
      chips.add(_buildSpecChip('Glass', item.glassType.text, Colors.blue.shade800));
    }
    if (item.sashOuter.text.isNotEmpty) {
      chips.add(_buildSpecChip('Sash/Outer', item.sashOuter.text, Colors.teal.shade800));
    }
    if (item.windowSeries == 'Slider') {
      chips.add(_buildSpecChip('Track', item.slidingType, Colors.indigo.shade800));
      chips.add(_buildSpecChip('Handle', item.handleType, Colors.purple.shade800));
    } else if (item.windowSeries == 'Casement') {
      chips.add(_buildSpecChip('Locking', item.locking, Colors.deepOrange.shade800));
      chips.add(_buildSpecChip('Hinges', item.hinges, Colors.pink.shade800));
    }

    // Series badge color
    Color seriesColor;
    switch (item.windowSeries) {
      case 'Slider':
        seriesColor = Colors.indigo;
        break;
      case 'Casement':
        seriesColor = Colors.teal;
        break;
      case 'Ventilator':
        seriesColor = Colors.green;
        break;
      default:
        seriesColor = const Color(0xff8D6E63);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          // S.No
          SizedBox(
            width: 40,
            child: Text(
              "${index + 1}",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey.shade800),
            ),
          ),
          const SizedBox(width: 8),
          // Design thumbnail
          SizedBox(
            width: 44,
            height: 44,
            child: SvgPicture.string(
              buildWindowSvg(
                design: designById(item.designId),
                widthMm: double.tryParse(item.widthMm.text) ?? 0,
                lengthMm: double.tryParse(item.lengthMm.text) ?? 0,
                frameColorKey: item.frameColor,
              ),
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 8),
          // Description + Series badge + Specs subtitle
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: seriesColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: seriesColor.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        item.windowSeries,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: seriesColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        item.description.text.isNotEmpty
                            ? item.description.text
                            : "—",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: chips,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Length (mm)
          Expanded(
            flex: 1,
            child: Text(item.lengthMm.text.isNotEmpty
                ? item.lengthMm.text
                : "—"),
          ),
          const SizedBox(width: 8),
          // Width (mm)
          Expanded(
            flex: 1,
            child: Text(item.widthMm.text.isNotEmpty
                ? item.widthMm.text
                : "—"),
          ),
          const SizedBox(width: 8),
          // Area (sqft)
          Expanded(
            flex: 1,
            child: Text(
              item.areaSqft.toStringAsFixed(2),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Qty
          Expanded(
            flex: 1,
            child: Text(item.qty.text),
          ),
          const SizedBox(width: 8),
          // Rate
          Expanded(
            flex: 2,
            child: Text("Rs. ${item.rate.text}"),
          ),
          const SizedBox(width: 8),
          // Amount
          Expanded(
            flex: 2,
            child: Text(
              "Rs. ${item.amount.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          // Edit Button
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xff8D6E63)),
            tooltip: "Edit",
            onPressed: () => _editItem(index),
          ),
          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: "Delete",
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
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
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
        Text("Rs. ${value.toStringAsFixed(2)}",
            style:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// --- HELPER CLASS ---
// This holds the state for a single row in the window quotation table.
// Conversion: 1 sqft = 92903.04 mm²
// So areaSqft = (lengthMm * widthMm) / 92903.04
// amount = areaSqft * qty * rate
class WindowQuotationItem {
  final TextEditingController description = TextEditingController();
  final TextEditingController lengthMm = TextEditingController();
  final TextEditingController widthMm = TextEditingController();
  final TextEditingController qty = TextEditingController();
  final TextEditingController rate = TextEditingController();

  // New text controllers
  final TextEditingController glassType = TextEditingController();
  final TextEditingController sashOuter = TextEditingController();

  // New dropdown values
  String windowSeries = 'Fixed'; // family label, derived from chosen design
  String designId = 'fixed_1'; // catalog design key
  String frameColor = 'white'; // 'white' | 'brown' | 'grey' | 'black'
  String gi = '0.8'; // 0.8, 1, 1.2, 1.5

  // Slider-only
  String slidingType = '2 Track'; // 2 Track, 3 Track
  String handleType = 'Touch Lock'; // Touch Lock, Popup Lock, etc.

  // Casement-only
  String locking = 'Single Point'; // Single Point, Multi Point
  String hinges = '2D Hinges'; // 2D Hinges, 3D Hinges

  double areaSqft = 0.0;
  double amount = 0.0;

  final VoidCallback onChanged;

  // Conversion constant: 1 sqft = 92903.04 mm²
  static const double _sqmmPerSqft = 92903.04;

  WindowQuotationItem({
    required this.onChanged,
    String? initialDescription,
    String? initialLengthMm,
    String? initialWidthMm,
    String? initialQty,
    String? initialRate,
    String? initialWindowSeries,
    String? initialDesignId,
    String? initialFrameColor,
    String? initialGi,
    String? initialGlassType,
    String? initialSashOuter,
    String? initialSlidingType,
    String? initialHandleType,
    String? initialLocking,
    String? initialHinges,
  }) {
    if (initialDescription != null) description.text = initialDescription;
    if (initialLengthMm != null) lengthMm.text = initialLengthMm;
    if (initialWidthMm != null) widthMm.text = initialWidthMm;
    if (initialQty != null) {
      qty.text = initialQty;
    } else {
      qty.text = '1'; // Default qty to 1
    }
    if (initialRate != null) rate.text = initialRate;
    if (initialGlassType != null) glassType.text = initialGlassType;
    if (initialSashOuter != null) sashOuter.text = initialSashOuter;
    if (initialWindowSeries != null) windowSeries = initialWindowSeries;
    if (initialDesignId != null) designId = initialDesignId;
    if (initialFrameColor != null) frameColor = initialFrameColor;
    if (initialGi != null) gi = initialGi;
    if (initialSlidingType != null) slidingType = initialSlidingType;
    if (initialHandleType != null) handleType = initialHandleType;
    if (initialLocking != null) locking = initialLocking;
    if (initialHinges != null) hinges = initialHinges;

    // Calculate initial amount if values provided
    updateAmount();
  }

  void updateAmount() {
    double l = double.tryParse(lengthMm.text) ?? 0;
    double w = double.tryParse(widthMm.text) ?? 0;
    double q = double.tryParse(qty.text) ?? 1;
    double r = double.tryParse(rate.text) ?? 0;

    // Convert mm² to sqft
    areaSqft = (l * w) / _sqmmPerSqft;
    amount = areaSqft * q * r;
    onChanged(); // Notify the parent to rebuild totals
  }

  void dispose() {
    description.dispose();
    lengthMm.dispose();
    widthMm.dispose();
    qty.dispose();
    rate.dispose();
    glassType.dispose();
    sashOuter.dispose();
  }
}

// Custom formatter that allows only valid decimal numbers
class _DecimalTextInputFormatter extends TextInputFormatter {
  final RegExp _regExp = RegExp(r'^\d*\.?\d*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (_regExp.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}

// ============ DIALOG STATE CARRIER ============

/// Carries dropdown values from the dialog back to the parent on save.
class _DialogDropdownState {
  final String windowSeries;
  final String designId;
  final String frameColor;
  final String gi;
  final String slidingType;
  final String handleType;
  final String locking;
  final String hinges;

  _DialogDropdownState({
    required this.windowSeries,
    required this.designId,
    required this.frameColor,
    required this.gi,
    required this.slidingType,
    required this.handleType,
    required this.locking,
    required this.hinges,
  });
}

// ============ DIALOG WIDGET ============

/// A spacious popup dialog for adding or editing a window item.
class _WindowItemDialog extends StatefulWidget {
  final bool isEditing;
  final TextEditingController lengthCtrl;
  final TextEditingController widthCtrl;
  final TextEditingController qtyCtrl;
  final TextEditingController rateCtrl;
  final TextEditingController glassTypeCtrl;
  final TextEditingController sashOuterCtrl;

  final String initialSeries;
  final String initialDesignId;
  final String initialFrameColor;
  final String initialGi;
  final String initialSlidingType;
  final String initialHandleType;
  final String initialLocking;
  final String initialHinges;

  final void Function(_DialogDropdownState state) onSave;
  final VoidCallback onCancel;

  const _WindowItemDialog({
    required this.isEditing,
    required this.lengthCtrl,
    required this.widthCtrl,
    required this.qtyCtrl,
    required this.rateCtrl,
    required this.glassTypeCtrl,
    required this.sashOuterCtrl,
    required this.initialSeries,
    required this.initialDesignId,
    required this.initialFrameColor,
    required this.initialGi,
    required this.initialSlidingType,
    required this.initialHandleType,
    required this.initialLocking,
    required this.initialHinges,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_WindowItemDialog> createState() => _WindowItemDialogState();
}

class _WindowItemDialogState extends State<_WindowItemDialog> {
  static const double _sqmmPerSqft = 92903.04;

  double _areaSqft = 0.0;
  double _amount = 0.0;

  late String _windowSeries;
  late String _designId;
  late String _frameColor;
  late String _gi;
  late String _slidingType;
  late String _handleType;
  late String _locking;
  late String _hinges;

  @override
  void initState() {
    super.initState();
    _windowSeries = widget.initialSeries;
    _designId = widget.initialDesignId;
    _frameColor = widget.initialFrameColor;
    _gi = widget.initialGi;
    _slidingType = widget.initialSlidingType;
    _handleType = widget.initialHandleType;
    _locking = widget.initialLocking;
    _hinges = widget.initialHinges;

    _recalculate();
    widget.lengthCtrl.addListener(_recalculate);
    widget.widthCtrl.addListener(_recalculate);
    widget.qtyCtrl.addListener(_recalculate);
    widget.rateCtrl.addListener(_recalculate);
  }

  void _recalculate() {
    final l = double.tryParse(widget.lengthCtrl.text) ?? 0;
    final w = double.tryParse(widget.widthCtrl.text) ?? 0;
    final q = double.tryParse(widget.qtyCtrl.text) ?? 1;
    final r = double.tryParse(widget.rateCtrl.text) ?? 0;
    setState(() {
      _areaSqft = (l * w) / _sqmmPerSqft;
      _amount = _areaSqft * q * r;
    });
  }

  void _handleSave() {
    // 1. Validate Glass Type
    final glassType = widget.glassTypeCtrl.text.trim();
    if (glassType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Glass Type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2. Validate Sash / Outer
    final sashOuter = widget.sashOuterCtrl.text.trim();
    if (sashOuter.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Sash / Outer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 3. Validate Length
    final lengthStr = widget.lengthCtrl.text.trim();
    if (lengthStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Length (mm)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final length = double.tryParse(lengthStr);
    if (length == null || length <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid positive number for Length'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 4. Validate Width
    final widthStr = widget.widthCtrl.text.trim();
    if (widthStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Width (mm)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final width = double.tryParse(widthStr);
    if (width == null || width <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid positive number for Width'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 5. Validate Quantity
    final qtyStr = widget.qtyCtrl.text.trim();
    if (qtyStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Quantity'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final qty = double.tryParse(qtyStr);
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid positive number for Quantity'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 6. Validate Rate
    final rateStr = widget.rateCtrl.text.trim();
    if (rateStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Rate / sqft'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final rate = double.tryParse(rateStr);
    if (rate == null || rate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid positive number for Rate'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    widget.onSave(_DialogDropdownState(
      windowSeries: _windowSeries,
      designId: _designId,
      frameColor: _frameColor,
      gi: _gi,
      slidingType: _slidingType,
      handleType: _handleType,
      locking: _locking,
      hinges: _hinges,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xff8D6E63).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.window_rounded,
                      color: Color(0xff8D6E63), size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.isEditing ? "Edit Window" : "Add New Window",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onCancel,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Design picker tile ──
                    _DesignPickerTile(
                      designId: _designId,
                      frameColor: _frameColor,
                      onTap: () async {
                        final result = await showWindowDesignPicker(
                          context,
                          initialDesignId: _designId,
                          initialFrameColor: _frameColor,
                        );
                        if (result != null) {
                          setState(() {
                            _designId = result.designId;
                            _frameColor = result.frameColor;
                            _windowSeries = designById(result.designId).family;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // ── Common: GI, Glass Type, Sash/Outer ──
                    _sectionLabel("Material Details"),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _gi,
                            decoration: const InputDecoration(
                              labelText: "GI (mm)",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.layers),
                            ),
                            items: ['0.8', '1', '1.2', '1.5']
                                .map((e) => DropdownMenuItem(
                                    value: e, child: Text('$e mm')))
                                .toList(),
                            onChanged: (val) => setState(() => _gi = val!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: widget.glassTypeCtrl,
                            decoration: const InputDecoration(
                              labelText: "Glass Type",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.blur_on),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: widget.sashOuterCtrl,
                            decoration: const InputDecoration(
                              labelText: "Sash / Outer",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.border_outer),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Slider-Only ──
                    if (_windowSeries == 'Slider') ...[
                      _sectionLabel("Slider Options"),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _slidingType,
                              decoration: const InputDecoration(
                                labelText: "Sliding Type",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.swap_horiz),
                              ),
                              items: ['2 Track', '3 Track']
                                  .map((e) => DropdownMenuItem(
                                      value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _slidingType = val!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _handleType,
                              decoration: const InputDecoration(
                                labelText: "Handle Type",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.pan_tool),
                              ),
                              items: [
                                'Touch Lock',
                                'Popup Lock',
                                'L Handle',
                                'D Handle',
                                'Crescent Lock Handle',
                                'No Lock',
                              ]
                                  .map((e) => DropdownMenuItem(
                                      value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _handleType = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Casement-Only ──
                    if (_windowSeries == 'Casement') ...[
                      _sectionLabel("Casement Options"),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _locking,
                              decoration: const InputDecoration(
                                labelText: "Locking",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.lock),
                              ),
                              items: ['Single Point', 'Multi Point']
                                  .map((e) => DropdownMenuItem(
                                      value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _locking = val!),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _hinges,
                              decoration: const InputDecoration(
                                labelText: "Hinges",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.rotate_right),
                              ),
                              items: ['2D Hinges', '3D Hinges']
                                  .map((e) => DropdownMenuItem(
                                      value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _hinges = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── Dimensions & Pricing ──
                    _sectionLabel("Dimensions & Pricing"),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: widget.lengthCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [_DecimalTextInputFormatter()],
                            decoration: const InputDecoration(
                              labelText: "Length (mm)",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.straighten),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: widget.widthCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [_DecimalTextInputFormatter()],
                            decoration: const InputDecoration(
                              labelText: "Width (mm)",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.straighten),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Area highlight
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.square_foot,
                              color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          Text("Area: ",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.blue.shade700)),
                          Text(
                            "${_areaSqft.toStringAsFixed(4)} sqft",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Qty & Rate
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: widget.qtyCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [_DecimalTextInputFormatter()],
                            decoration: const InputDecoration(
                              labelText: "Quantity",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.numbers),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: widget.rateCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [_DecimalTextInputFormatter()],
                            decoration: const InputDecoration(
                              labelText: "Rate / sqft",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.currency_rupee),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Amount highlight
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.currency_rupee,
                              color: Colors.green.shade700, size: 20),
                          const SizedBox(width: 8),
                          Text("Amount: ",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.green.shade700)),
                          Text(
                            "Rs. ${_amount.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                  ),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _handleSave,
                  icon: Icon(widget.isEditing ? Icons.check : Icons.add),
                  label: Text(widget.isEditing ? "Update" : "Add Window"),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xff8D6E63),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade600,
        letterSpacing: 0.5,
      ),
    );
  }
}

/// Tappable tile that shows the currently selected design (live SVG preview +
/// label + chosen frame color) and opens the design picker on tap.
class _DesignPickerTile extends StatelessWidget {
  final String designId;
  final String frameColor;
  final VoidCallback onTap;
  const _DesignPickerTile({
    required this.designId,
    required this.frameColor,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final design = designById(designId);
    final svg = buildWindowSvg(design: design, frameColorKey: frameColor);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: SvgPicture.string(svg, fit: BoxFit.contain),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(design.label,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${design.family} • $frameColor frame',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade700)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
