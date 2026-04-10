import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:samar_trading_quotation/pdf_generator.dart';
import 'package:samar_trading_quotation/quotation_storage.dart';

class ChallanCreationScreen extends StatefulWidget {
  final SavedChallan? editChallan;

  const ChallanCreationScreen({super.key, this.editChallan});

  @override
  State<ChallanCreationScreen> createState() => _ChallanCreationScreenState();
}

class _ChallanCreationScreenState extends State<ChallanCreationScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _destinationController = TextEditingController();

  String? _challanId;

  final List<ChallanItem> _items = [];

  @override
  void initState() {
    super.initState();
    if (widget.editChallan != null) {
      _loadEditChallan();
    } else {
      _addItem();
    }
  }

  void _loadEditChallan() {
    final challan = widget.editChallan!;
    _challanId = challan.id;
    _nameController.text = challan.customerName;
    _addressController.text = challan.customerAddress;
    _destinationController.text = challan.destination;

    for (final savedItem in challan.items) {
      final item = ChallanItem(
        onChanged: () => setState(() {}),
        initialDescription: savedItem.description,
        initialHsnSac: savedItem.hsnSac,
        initialQty: savedItem.qty,
        initialUnit: savedItem.unit,
        initialDimensions: savedItem.dimensions,
      );
      _items.add(item);
    }

    if (_items.isEmpty) {
      _addItem();
    }
  }

  void _addItem() {
    setState(() {
      _items.add(ChallanItem(onChanged: () => setState(() {})));
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _destinationController.dispose();
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
        title: const Text("New E-Challan"),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
        actions: [
          FilledButton.icon(
            onPressed: () async {
              if (_items.isEmpty || _nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Fill in Name and Items first!")),
                );
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Generating Challan PDF...")),
              );

              try {
                final filePath = await PdfGenerator.saveChallanToDefaultFolder(
                  name: _nameController.text,
                  address: _addressController.text,
                  destination: _destinationController.text,
                  items: _items,
                );

                final savedChallan = SavedChallan(
                  id: _challanId ?? ChallanStorage.generateId(),
                  customerName: _nameController.text,
                  customerAddress: _addressController.text,
                  destination: _destinationController.text,
                  items: _items.map((item) => SavedChallanItem(
                    description: item.description.text,
                    hsnSac: item.hsnSac.text,
                    qty: item.qty.text,
                    unit: item.unit,
                    dimensions: item.dimensions.text,
                  )).toList(),
                  createdAt: DateTime.now(),
                  pdfPath: filePath,
                );
                await ChallanStorage.saveChallan(savedChallan);

                await OpenFile.open(filePath);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Saved to: $filePath"),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
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
            _buildCustomerSection(),
            const SizedBox(height: 32),
            const Text(
              "Goods Details",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTableStructure(),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
              label: const Text("Add Row"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              "Challan Details",
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
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _destinationController,
              decoration: const InputDecoration(
                labelText: "Destination (Where goods are reaching)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_shipping),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableStructure() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text("Description of Goods", style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 10),
                Expanded(flex: 2, child: Text("HSN/SAC Code", style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 10),
                Expanded(flex: 1, child: Text("Qty", style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 10),
                Expanded(flex: 1, child: Text("Unit", style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 10),
                Expanded(flex: 2, child: Text("Dimensions / Specs", style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 40),
              ],
            ),
          ),
          const Divider(height: 1),
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

  Widget _buildItemRow(int index, ChallanItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: item.description,
              decoration: const InputDecoration(
                hintText: "e.g. Wooden Door",
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: TextField(
              controller: item.hsnSac,
              decoration: const InputDecoration(
                hintText: "e.g. 4418",
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: TextField(
              controller: item.qty,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                _DecimalTextInputFormatter(),
              ],
              decoration: const InputDecoration(
                hintText: "0",
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: DropdownButtonFormField<String>(
              value: item.unit,
              decoration: const InputDecoration(border: InputBorder.none, isDense: true),
              items: ["pcs", "sqft", "mtr", "kg", "box", "ltr", "nos"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                setState(() => item.unit = val!);
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: TextField(
              controller: item.dimensions,
              decoration: const InputDecoration(
                hintText: "e.g. 8 ft x 4 ft",
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _removeItem(index),
          ),
        ],
      ),
    );
  }
}

class ChallanItem {
  final TextEditingController description = TextEditingController();
  final TextEditingController hsnSac = TextEditingController();
  final TextEditingController qty = TextEditingController();
  final TextEditingController dimensions = TextEditingController();

  String unit = "pcs";

  final VoidCallback onChanged;

  ChallanItem({
    required this.onChanged,
    String? initialDescription,
    String? initialHsnSac,
    String? initialQty,
    String? initialUnit,
    String? initialDimensions,
  }) {
    if (initialDescription != null) description.text = initialDescription;
    if (initialHsnSac != null) hsnSac.text = initialHsnSac;
    if (initialQty != null) qty.text = initialQty;
    if (initialUnit != null) unit = initialUnit;
    if (initialDimensions != null) dimensions.text = initialDimensions;
  }

  void dispose() {
    description.dispose();
    hsnSac.dispose();
    qty.dispose();
    dimensions.dispose();
  }
}

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
