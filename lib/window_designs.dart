/// Window design catalog + the single SVG builder used by both the on-screen
/// picker (via flutter_svg) and the generated PDF (via pw.SvgImage).
///
/// A design defines only its panel LAYOUT (grid of panes). The box shape is
/// computed at render time from the entered dimensions, and the frame color is
/// a render-time parameter — so the picker preview and the PDF always match.

/// A selectable window design (one catalog entry, e.g. "Fixed 3").
class WindowDesign {
  final String id; // stable key persisted on the item, e.g. 'fixed_3'
  final String family; // grouping for picker tabs + PDF series label
  final String label; // human label, e.g. 'Fixed 3'
  final int cols;
  final int rows;

  /// Optional unequal row/column splits (fractions, any positive scale).
  /// Null = equal panes. e.g. Fixed 5 = rows:2, rowFractions:[0.35, 0.65].
  final List<double>? rowFractions;
  final List<double>? colFractions;

  const WindowDesign({
    required this.id,
    required this.family,
    required this.label,
    required this.cols,
    required this.rows,
    this.rowFractions,
    this.colFractions,
  });
}

/// Round 1 catalog — only the validated Fixed designs. More families are added
/// in later rounds by extending this list (the picker builds tabs from it).
const List<WindowDesign> kWindowDesigns = [
  WindowDesign(id: 'fixed_1', family: 'Fixed', label: 'Fixed 1', cols: 1, rows: 1),
  WindowDesign(id: 'fixed_2', family: 'Fixed', label: 'Fixed 2', cols: 2, rows: 1),
  WindowDesign(id: 'fixed_3', family: 'Fixed', label: 'Fixed 3', cols: 3, rows: 1),
  WindowDesign(id: 'fixed_4', family: 'Fixed', label: 'Fixed 4', cols: 4, rows: 1),
  WindowDesign(
    id: 'fixed_5',
    family: 'Fixed',
    label: 'Fixed 5',
    cols: 1,
    rows: 2,
    rowFractions: [0.35, 0.65],
  ),
];

/// Distinct families in catalog order (drives picker tabs).
List<String> get kWindowFamilies {
  final seen = <String>[];
  for (final d in kWindowDesigns) {
    if (!seen.contains(d.family)) seen.add(d.family);
  }
  return seen;
}

WindowDesign designById(String? id) {
  for (final d in kWindowDesigns) {
    if (d.id == id) return d;
  }
  return kWindowDesigns.first; // safe fallback for old/unknown ids
}

/// Selectable frame colors. Glass stays cyan regardless.
const Map<String, String> kFrameColors = {
  'white': '#f5f5f5',
  'brown': '#7a4a23',
  'grey': '#8a8f96',
  'black': '#2a2a2a',
};

String frameHex(String? colorKey) =>
    kFrameColors[colorKey] ?? kFrameColors['white']!;

/// Builds the SVG string for a design at the given real dimensions and color.
///
/// - Aspect from widthMm/lengthMm when both > 0, else the natural cols/rows
///   shape. Clamped to [1:3, 3:1] so extreme orders stay legible.
/// - frameColorKey is one of kFrameColors' keys ('white'|'brown'|'grey'|'black').
String buildWindowSvg({
  required WindowDesign design,
  double widthMm = 0,
  double lengthMm = 0,
  String frameColorKey = 'white',
}) {
  const maxSide = 200.0;
  const minRatio = 1 / 3; // tallest allowed
  const maxRatio = 3.0; // widest allowed

  double ratio; // width / height
  if (widthMm > 0 && lengthMm > 0) {
    ratio = widthMm / lengthMm;
  } else {
    ratio = design.cols / design.rows;
  }
  if (ratio < minRatio) ratio = minRatio;
  if (ratio > maxRatio) ratio = maxRatio;

  double vbW, vbH;
  if (ratio >= 1) {
    vbW = maxSide;
    vbH = maxSide / ratio;
  } else {
    vbH = maxSide;
    vbW = maxSide * ratio;
  }

  final frame = frameHex(frameColorKey);
  const stroke = '#1a1a1a';
  const glass = '#1ee5ec';
  const m = 7.0; // mullion thickness
  const fo = 6.0; // outer frame thickness

  final ix = fo + m, iy = fo + m;
  final iw = vbW - 2 * (fo + m), ih = vbH - 2 * (fo + m);

  final cFr = design.colFractions ?? List.filled(design.cols, 1.0 / design.cols);
  final rFr = design.rowFractions ?? List.filled(design.rows, 1.0 / design.rows);
  final cSum = cFr.reduce((a, b) => a + b);
  final rSum = rFr.reduce((a, b) => a + b);

  String f(double v) => v.toStringAsFixed(2);

  final b = StringBuffer();
  b.write('<svg viewBox="0 0 ${f(vbW)} ${f(vbH)}" '
      'xmlns="http://www.w3.org/2000/svg">');
  // Outer frame
  b.write('<rect x="${f(fo / 2)}" y="${f(fo / 2)}" width="${f(vbW - fo)}" '
      'height="${f(vbH - fo)}" fill="$frame" stroke="$stroke" stroke-width="1.6"/>');
  // Glass pane
  b.write('<rect x="${f(ix)}" y="${f(iy)}" width="${f(iw)}" height="${f(ih)}" '
      'fill="$glass" stroke="$stroke" stroke-width="1.2"/>');
  // Bevel corners
  b.write('<line x1="${f(fo / 2)}" y1="${f(fo / 2)}" x2="${f(ix)}" y2="${f(iy)}" '
      'stroke="$stroke" stroke-width="0.8"/>');
  b.write('<line x1="${f(vbW - fo / 2)}" y1="${f(fo / 2)}" x2="${f(ix + iw)}" '
      'y2="${f(iy)}" stroke="$stroke" stroke-width="0.8"/>');
  b.write('<line x1="${f(fo / 2)}" y1="${f(vbH - fo / 2)}" x2="${f(ix)}" '
      'y2="${f(iy + ih)}" stroke="$stroke" stroke-width="0.8"/>');
  b.write('<line x1="${f(vbW - fo / 2)}" y1="${f(vbH - fo / 2)}" '
      'x2="${f(ix + iw)}" y2="${f(iy + ih)}" stroke="$stroke" stroke-width="0.8"/>');

  // Pane edges
  final colEdges = <double>[ix];
  double acc = ix;
  for (final fr in cFr) {
    acc += iw * (fr / cSum);
    colEdges.add(acc);
  }
  final rowEdges = <double>[iy];
  acc = iy;
  for (final fr in rFr) {
    acc += ih * (fr / rSum);
    rowEdges.add(acc);
  }

  // Mullions
  for (var c = 1; c < design.cols; c++) {
    final x = colEdges[c];
    b.write('<rect x="${f(x - m / 2)}" y="${f(iy)}" width="${f(m)}" '
        'height="${f(ih)}" fill="$frame" stroke="$stroke" stroke-width="0.8"/>');
  }
  for (var r = 1; r < design.rows; r++) {
    final y = rowEdges[r];
    b.write('<rect x="${f(ix)}" y="${f(y - m / 2)}" width="${f(iw)}" '
        'height="${f(m)}" fill="$frame" stroke="$stroke" stroke-width="0.8"/>');
  }

  // "+" markers, one per pane
  for (var c = 0; c < design.cols; c++) {
    for (var r = 0; r < design.rows; r++) {
      final cx = (colEdges[c] + colEdges[c + 1]) / 2;
      final cy = (rowEdges[r] + rowEdges[r + 1]) / 2;
      final paneW = colEdges[c + 1] - colEdges[c];
      final paneH = rowEdges[r + 1] - rowEdges[r];
      final arm = (paneW < paneH ? paneW : paneH) * 0.26;
      final sq = arm * 0.30;
      b.write('<line x1="${f(cx)}" y1="${f(cy - arm)}" x2="${f(cx)}" '
          'y2="${f(cy + arm)}" stroke="$stroke" stroke-width="1.1"/>');
      b.write('<line x1="${f(cx - arm)}" y1="${f(cy)}" x2="${f(cx + arm)}" '
          'y2="${f(cy)}" stroke="$stroke" stroke-width="1.1"/>');
      b.write('<rect x="${f(cx - sq)}" y="${f(cy - sq)}" width="${f(sq * 2)}" '
          'height="${f(sq * 2)}" fill="$stroke"/>');
    }
  }
  b.write('</svg>');
  return b.toString();
}
