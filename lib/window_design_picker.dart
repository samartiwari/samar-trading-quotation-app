import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'window_designs.dart';

/// Result of the picker: the chosen design id + the frame color used.
class WindowDesignSelection {
  final String designId;
  final String frameColor;
  const WindowDesignSelection(this.designId, this.frameColor);
}

/// Opens a modal design picker. Returns the selection, or null if cancelled.
Future<WindowDesignSelection?> showWindowDesignPicker(
  BuildContext context, {
  String initialDesignId = 'fixed_1',
  String initialFrameColor = 'white',
}) {
  return showDialog<WindowDesignSelection>(
    context: context,
    builder: (_) => _WindowDesignPickerDialog(
      initialDesignId: initialDesignId,
      initialFrameColor: initialFrameColor,
    ),
  );
}

class _WindowDesignPickerDialog extends StatefulWidget {
  final String initialDesignId;
  final String initialFrameColor;
  const _WindowDesignPickerDialog({
    required this.initialDesignId,
    required this.initialFrameColor,
  });

  @override
  State<_WindowDesignPickerDialog> createState() =>
      _WindowDesignPickerDialogState();
}

class _WindowDesignPickerDialogState extends State<_WindowDesignPickerDialog>
    with SingleTickerProviderStateMixin {
  late String _frameColor;
  late TabController _tabs;
  late List<String> _families;

  @override
  void initState() {
    super.initState();
    _frameColor = widget.initialFrameColor;
    _families = kWindowFamilies;
    final design = designById(widget.initialDesignId);
    final initialTab = _families.indexOf(design.family);
    _tabs = TabController(
      length: _families.length,
      vsync: this,
      initialIndex: initialTab < 0 ? 0 : initialTab,
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 900,
          maxHeight: screen.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(onClose: () => Navigator.of(context).pop()),
            _ColorBar(
              selected: _frameColor,
              onChanged: (c) => setState(() => _frameColor = c),
            ),
            TabBar(
              controller: _tabs,
              isScrollable: true,
              labelColor: Theme.of(context).colorScheme.primary,
              tabs: _families.map((f) => Tab(text: f)).toList(),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: _families
                    .map((f) => _DesignGrid(
                          family: f,
                          frameColor: _frameColor,
                          onPick: (id) => Navigator.of(context).pop(
                            WindowDesignSelection(id, _frameColor),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onClose;
  const _Header({required this.onClose});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Choose a window design',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(icon: const Icon(Icons.close), onPressed: onClose),
        ],
      ),
    );
  }
}

class _ColorBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _ColorBar({required this.selected, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text('Frame color: ', style: TextStyle(fontWeight: FontWeight.w600)),
          for (final entry in kFrameColors.entries) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _ColorSwatch(
                colorKey: entry.key,
                selected: entry.key == selected,
                onTap: () => onChanged(entry.key),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final String colorKey;
  final bool selected;
  final VoidCallback onTap;
  const _ColorSwatch({
    required this.colorKey,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final hex = frameHex(colorKey);
    final fill = Color(int.parse(hex.substring(1), radix: 16) | 0xFF000000);
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: colorKey,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? Theme.of(context).colorScheme.primary : Colors.black26,
              width: selected ? 3 : 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _DesignGrid extends StatelessWidget {
  final String family;
  final String frameColor;
  final ValueChanged<String> onPick;
  const _DesignGrid({
    required this.family,
    required this.frameColor,
    required this.onPick,
  });
  @override
  Widget build(BuildContext context) {
    final designs = kWindowDesigns.where((d) => d.family == family).toList();
    if (designs.isEmpty) {
      return const Center(child: Text('No designs in this family yet.'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: designs.length,
      itemBuilder: (_, i) {
        final d = designs[i];
        final svg = designSvgOrPlaceholder(d, frameColorKey: frameColor);
        return InkWell(
          onTap: () => onPick(d.id),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SvgPicture.string(svg, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 4),
                Text(d.label, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }
}
