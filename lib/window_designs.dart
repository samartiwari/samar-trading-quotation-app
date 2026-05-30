import 'package:flutter/services.dart' show rootBundle;

/// Window design catalog. Each design is now backed by a hand-authored static
/// SVG asset under `assets/windows/<id>.svg`. The SVG file uses the literal
/// string `FRAME_COLOR` everywhere the frame fill should appear; the loader
/// substitutes the chosen color hex at runtime.
///
/// The design also carries lightweight grid metadata (`cols`, `rows`,
/// optional `colFractions` / `rowFractions`). That metadata is no longer used
/// to draw the picture (the SVG is fixed); it only tells the form how many
/// width / height inputs to render and feeds the area calculation.

/// A selectable window design (one catalog entry, e.g. "Fixed 3").
class WindowDesign {
  final String id; // stable key persisted on the item, e.g. 'fixed_3'
  final String family; // grouping for picker tabs + PDF series label
  final String label; // human label, e.g. 'Fixed 3'
  final int cols; // # of per-column width inputs the form should show
  final int rows; // # of per-row height inputs the form should show

  /// Optional column / row weight fractions used by the area calculator when
  /// the user has entered fewer dimensions than the design has cells. With
  /// the new static-SVG approach these are rarely needed (the user provides
  /// real per-column widths) but they remain available as a fallback.
  final List<double>? colFractions;
  final List<double>? rowFractions;

  const WindowDesign({
    required this.id,
    required this.family,
    required this.label,
    required this.cols,
    required this.rows,
    this.colFractions,
    this.rowFractions,
  });

  String get assetPath => 'assets/windows/$id.svg';
}

/// Catalog. Order here drives the picker grid order within each family tab.
/// `cols`/`rows` drive how many width / height inputs the form shows; they
/// don't have to match the visual grid of the static SVG art (e.g. fixed_10
/// has a merged bottom pane in the picture but exposes 2×2 dimensions in the
/// form). Pick whatever produces the most natural data-entry experience.
const List<WindowDesign> kWindowDesigns = [
  WindowDesign(id: 'fixed_1', family: 'Fixed', label: 'Fixed 1', cols: 1, rows: 1),
  WindowDesign(id: 'fixed_2', family: 'Fixed', label: 'Fixed 2', cols: 2, rows: 1),
  WindowDesign(id: 'fixed_3', family: 'Fixed', label: 'Fixed 3', cols: 3, rows: 1),
  WindowDesign(id: 'fixed_4', family: 'Fixed', label: 'Fixed 4', cols: 4, rows: 1),
  WindowDesign(
    id: 'fixed_5',
    family: 'Fixed',
    label: 'Fixed 5',
    cols: 1, rows: 2, rowFractions: [0.35, 0.65],
  ),
  WindowDesign(
    id: 'fixed_6',
    family: 'Fixed', label: 'Fixed 6',
    cols: 2, rows: 2, rowFractions: [0.35, 0.65],
  ),
  WindowDesign(
    id: 'fixed_7',
    family: 'Fixed', label: 'Fixed 7',
    cols: 3, rows: 2, rowFractions: [0.35, 0.65],
  ),
  WindowDesign(
    id: 'fixed_8',
    family: 'Fixed', label: 'Fixed 8',
    cols: 1, rows: 2, rowFractions: [0.35, 0.65],
  ),
  WindowDesign(id: 'fixed_9', family: 'Fixed', label: 'Fixed 9', cols: 1, rows: 1),
  WindowDesign(
    id: 'fixed_10',
    family: 'Fixed', label: 'Fixed 10',
    cols: 2, rows: 2, rowFractions: [0.35, 0.65],
  ),
  WindowDesign(
    id: 'fixed_11',
    family: 'Fixed', label: 'Fixed 11',
    cols: 2, rows: 2, rowFractions: [0.35, 0.65],
  ),
  WindowDesign(
    id: 'fixed_12',
    family: 'Fixed', label: 'Fixed 12',
    cols: 1, rows: 2, rowFractions: [0.30, 0.70],
  ),
  WindowDesign(id: 'fixed_13', family: 'Fixed', label: 'Fixed 13', cols: 3, rows: 1),
  WindowDesign(id: 'fixed_14', family: 'Fixed', label: 'Fixed 14', cols: 1, rows: 1),
  WindowDesign(
    id: 'fixed_15',
    family: 'Fixed', label: 'Fixed 15',
    cols: 3, rows: 1, colFractions: [0.32, 0.36, 0.32],
  ),
  WindowDesign(id: 'fixed_16', family: 'Fixed', label: 'Fixed 16', cols: 2, rows: 2),
  WindowDesign(id: 'fixed_17', family: 'Fixed', label: 'Fixed 17', cols: 1, rows: 1),
  WindowDesign(
    id: 'fixed_18',
    family: 'Fixed', label: 'Fixed 18',
    cols: 1, rows: 2, rowFractions: [0.30, 0.70],
  ),
  WindowDesign(id: 'fixed_19', family: 'Fixed', label: 'Fixed 19', cols: 2, rows: 1),
  WindowDesign(id: 'fixed_20', family: 'Fixed', label: 'Fixed 20', cols: 2, rows: 2),
  WindowDesign(id: 'fixed_21', family: 'Fixed', label: 'Fixed 21', cols: 1, rows: 2),
  WindowDesign(
    id: 'fixed_22',
    family: 'Fixed', label: 'Fixed 22',
    cols: 1, rows: 2, rowFractions: [0.30, 0.70],
  ),
  WindowDesign(
    id: 'fixed_23',
    family: 'Fixed', label: 'Fixed 23',
    cols: 1, rows: 3, rowFractions: [0.25, 0.375, 0.375],
  ),
  WindowDesign(id: 'fixed_24', family: 'Fixed', label: 'Fixed 24', cols: 2, rows: 1),
  WindowDesign(id: 'fixed_25', family: 'Fixed', label: 'Fixed 25', cols: 2, rows: 2),
  WindowDesign(id: 'fixed_26', family: 'Fixed', label: 'Fixed 26', cols: 1, rows: 1),
  WindowDesign(
    id: 'fixed_27',
    family: 'Fixed', label: 'Fixed 27',
    cols: 1, rows: 2,
  ),
  WindowDesign(id: 'fixed_28', family: 'Fixed', label: 'Fixed 28', cols: 2, rows: 3),
  WindowDesign(id: 'fixed_29', family: 'Fixed', label: 'Fixed 29', cols: 4, rows: 2),
  WindowDesign(id: 'fixed_30', family: 'Fixed', label: 'Fixed 30', cols: 1, rows: 2),
  WindowDesign(id: 'fixed_31', family: 'Fixed', label: 'Fixed 31', cols: 1, rows: 1),
  WindowDesign(
    id: 'fixed_32',
    family: 'Fixed', label: 'Fixed 32',
    cols: 1, rows: 2, rowFractions: [0.30, 0.70],
  ),
  WindowDesign(
    id: 'fixed_33',
    family: 'Fixed', label: 'Fixed 33',
    cols: 1, rows: 2, rowFractions: [0.25, 0.75],
  ),
  WindowDesign(
    id: 'fixed_34',
    family: 'Fixed', label: 'Fixed 34',
    cols: 3, rows: 1, colFractions: [0.30, 0.40, 0.30],
  ),
  WindowDesign(
    id: 'fixed_35',
    family: 'Fixed', label: 'Fixed 35',
    cols: 3, rows: 1, colFractions: [0.28, 0.44, 0.28],
  ),
  // Casement family — openable casements (the CMT series). cols/rows below
  // drive how many dimension inputs the form shows. Per-pane open direction
  // and handles are baked into the static SVG art.
  WindowDesign(id: 'cmt_1', family: 'Casement', label: 'CMT 1', cols: 1, rows: 1),
  WindowDesign(id: 'cmt_2', family: 'Casement', label: 'CMT 2', cols: 1, rows: 1),
  WindowDesign(id: 'cmt_3', family: 'Casement', label: 'CMT 3', cols: 1, rows: 2, rowFractions: [0.22, 0.78]),
  WindowDesign(id: 'cmt_4', family: 'Casement', label: 'CMT 4', cols: 1, rows: 2, rowFractions: [0.72, 0.28]),
  WindowDesign(id: 'cmt_5', family: 'Casement', label: 'CMT 5', cols: 2, rows: 1),
  WindowDesign(id: 'cmt_6', family: 'Casement', label: 'CMT 6', cols: 1, rows: 2, rowFractions: [0.22, 0.78]),
  WindowDesign(id: 'cmt_7', family: 'Casement', label: 'CMT 7', cols: 1, rows: 2, rowFractions: [0.78, 0.22]),
  WindowDesign(id: 'cmt_8', family: 'Casement', label: 'CMT 8', cols: 2, rows: 1),
  WindowDesign(id: 'cmt_9', family: 'Casement', label: 'CMT 9', cols: 2, rows: 2, rowFractions: [0.28, 0.72]),
  WindowDesign(id: 'cmt_10', family: 'Casement', label: 'CMT 10', cols: 2, rows: 2, rowFractions: [0.72, 0.28]),
  WindowDesign(id: 'cmt_11', family: 'Casement', label: 'CMT 11', cols: 3, rows: 2, rowFractions: [0.20, 0.80]),
  WindowDesign(id: 'cmt_12', family: 'Casement', label: 'CMT 12', cols: 3, rows: 2, rowFractions: [0.80, 0.20]),
  WindowDesign(id: 'cmt_13', family: 'Casement', label: 'CMT 13', cols: 2, rows: 1),
  WindowDesign(id: 'cmt_14', family: 'Casement', label: 'CMT 14', cols: 2, rows: 2, rowFractions: [0.22, 0.78]),
  WindowDesign(id: 'cmt_15', family: 'Casement', label: 'CMT 15', cols: 2, rows: 1),
  WindowDesign(id: 'cmt_16', family: 'Casement', label: 'CMT 16', cols: 2, rows: 2, rowFractions: [0.22, 0.78]),
  WindowDesign(id: 'cmt_17', family: 'Casement', label: 'CMT 17', cols: 2, rows: 2, rowFractions: [0.22, 0.78]),
  WindowDesign(id: 'cmt_18', family: 'Casement', label: 'CMT 18', cols: 3, rows: 1, colFractions: [0.25, 0.5, 0.25]),
  WindowDesign(id: 'cmt_19', family: 'Casement', label: 'CMT 19', cols: 1, rows: 2, rowFractions: [0.25, 0.75]),
  WindowDesign(id: 'cmt_20', family: 'Casement', label: 'CMT 20', cols: 3, rows: 1),
  WindowDesign(id: 'cmt_21', family: 'Casement', label: 'CMT 21', cols: 4, rows: 1),
  WindowDesign(id: 'cmt_22', family: 'Casement', label: 'CMT 22', cols: 2, rows: 1),
  WindowDesign(id: 'cmt_23', family: 'Casement', label: 'CMT 23', cols: 1, rows: 1),
  WindowDesign(id: 'cmt_24', family: 'Casement', label: 'CMT 24', cols: 3, rows: 1, colFractions: [0.25, 0.5, 0.25]),
  WindowDesign(id: 'cmt_25', family: 'Casement', label: 'CMT 25', cols: 3, rows: 2, rowFractions: [0.78, 0.22]),
  WindowDesign(id: 'cmt_26', family: 'Casement', label: 'CMT 26', cols: 2, rows: 2, rowFractions: [0.3, 0.7], colFractions: [0.4, 0.6]),
  WindowDesign(id: 'cmt_27', family: 'Casement', label: 'CMT 27', cols: 2, rows: 2, rowFractions: [0.25, 0.75]),
  WindowDesign(id: 'cmt_28', family: 'Casement', label: 'CMT 28', cols: 1, rows: 1),
  WindowDesign(id: 'cmt_29', family: 'Casement', label: 'CMT 29', cols: 2, rows: 1),
  WindowDesign(id: 'cmt_30', family: 'Casement', label: 'CMT 30', cols: 2, rows: 2, rowFractions: [0.28, 0.72]),
  WindowDesign(id: 'cmt_31', family: 'Casement', label: 'CMT 31', cols: 3, rows: 2, rowFractions: [0.28, 0.72]),
  WindowDesign(id: 'cmt_32', family: 'Casement', label: 'CMT 32', cols: 3, rows: 2, rowFractions: [0.3, 0.7]),
  WindowDesign(id: 'cmt_33', family: 'Casement', label: 'CMT 33', cols: 4, rows: 2, rowFractions: [0.28, 0.72]),
  WindowDesign(id: 'cmt_34', family: 'Casement', label: 'CMT 34', cols: 2, rows: 1),
  WindowDesign(id: 'cmt_35', family: 'Casement', label: 'CMT 35', cols: 2, rows: 2, rowFractions: [0.78, 0.22]),
  WindowDesign(id: 'cmt_36', family: 'Casement', label: 'CMT 36', cols: 2, rows: 1),
  WindowDesign(id: 'cmt_37', family: 'Casement', label: 'CMT 37', cols: 2, rows: 1),
  WindowDesign(id: 'cmt_38', family: 'Casement', label: 'CMT 38', cols: 3, rows: 2, rowFractions: [0.78, 0.22]),
  WindowDesign(id: 'cmt_39', family: 'Casement', label: 'CMT 39', cols: 1, rows: 1),
  WindowDesign(id: 'cmt_40', family: 'Casement', label: 'CMT 40', cols: 2, rows: 2, rowFractions: [0.8, 0.2]),
  WindowDesign(id: 'cmt_41', family: 'Casement', label: 'CMT 41', cols: 2, rows: 3, rowFractions: [0.22, 0.6, 0.18]),
  WindowDesign(id: 'cmt_42', family: 'Casement', label: 'CMT 42', cols: 3, rows: 1),
  WindowDesign(id: 'cmt_43', family: 'Casement', label: 'CMT 43', cols: 3, rows: 2, rowFractions: [0.25, 0.75]),
  WindowDesign(id: 'cmt_44', family: 'Casement', label: 'CMT 44', cols: 3, rows: 3, rowFractions: [0.22, 0.62, 0.16]),
  WindowDesign(id: 'cmt_45', family: 'Casement', label: 'CMT 45', cols: 4, rows: 1),
  WindowDesign(id: 'cmt_46', family: 'Casement', label: 'CMT 46', cols: 4, rows: 2, rowFractions: [0.25, 0.75]),
  WindowDesign(id: 'cmt_47', family: 'Casement', label: 'CMT 47', cols: 2, rows: 2, rowFractions: [0.3, 0.7]),
  WindowDesign(id: 'cmt_48', family: 'Casement', label: 'CMT 48', cols: 4, rows: 1),
  WindowDesign(id: 'cmt_49', family: 'Casement', label: 'CMT 49', cols: 3, rows: 2, rowFractions: [0.25, 0.75]),
  WindowDesign(id: 'cmt_50', family: 'Casement', label: 'CMT 50', cols: 2, rows: 2, rowFractions: [0.3, 0.7], colFractions: [0.45, 0.55]),
  WindowDesign(id: 'cmt_51', family: 'Casement', label: 'CMT 51', cols: 3, rows: 2, rowFractions: [0.78, 0.22]),
  WindowDesign(id: 'cmt_52', family: 'Casement', label: 'CMT 52', cols: 3, rows: 2, rowFractions: [0.82, 0.18]),
  WindowDesign(id: 'cmt_53', family: 'Casement', label: 'CMT 53', cols: 3, rows: 2, rowFractions: [0.25, 0.75]),
  WindowDesign(id: 'cmt_54', family: 'Casement', label: 'CMT 54', cols: 2, rows: 2, rowFractions: [0.25, 0.75]),
  WindowDesign(id: 'cmt_55', family: 'Casement', label: 'CMT 55', cols: 2, rows: 2, rowFractions: [0.78, 0.22]),
  WindowDesign(id: 'cmt_56', family: 'Casement', label: 'CMT 56', cols: 3, rows: 2, rowFractions: [0.78, 0.22]),
  WindowDesign(id: 'cmt_57', family: 'Casement', label: 'CMT 57', cols: 2, rows: 1),
  WindowDesign(id: 'cmt_58', family: 'Casement', label: 'CMT 58', cols: 3, rows: 1),
  WindowDesign(id: 'cmt_59', family: 'Casement', label: 'CMT 59', cols: 3, rows: 2, rowFractions: [0.28, 0.72]),
  WindowDesign(id: 'cmt_60', family: 'Casement', label: 'CMT 60', cols: 4, rows: 2, rowFractions: [0.25, 0.75]),
  WindowDesign(id: 'cmt_61', family: 'Casement', label: 'CMT 61', cols: 2, rows: 2, rowFractions: [0.3, 0.7]),
  WindowDesign(id: 'cmt_62', family: 'Casement', label: 'CMT 62', cols: 1, rows: 1),
  WindowDesign(id: 'cmt_63', family: 'Casement', label: 'CMT 63', cols: 3, rows: 2, rowFractions: [0.25, 0.75]),
  WindowDesign(id: 'cmt_64', family: 'Casement', label: 'CMT 64', cols: 2, rows: 2, rowFractions: [0.25, 0.75]),
  WindowDesign(id: 'cmt_65', family: 'Casement', label: 'CMT 65', cols: 3, rows: 2, rowFractions: [0.28, 0.72]),
  WindowDesign(id: 'cmt_66', family: 'Casement', label: 'CMT 66', cols: 1, rows: 1),
  WindowDesign(id: 'cmt_67', family: 'Casement', label: 'CMT 67', cols: 2, rows: 2, rowFractions: [0.3, 0.7]),
  WindowDesign(id: 'cmt_68', family: 'Casement', label: 'CMT 68', cols: 3, rows: 2, rowFractions: [0.78, 0.22]),
  WindowDesign(id: 'cmt_69', family: 'Casement', label: 'CMT 69', cols: 4, rows: 1),
  WindowDesign(id: 'cmt_70', family: 'Casement', label: 'CMT 70', cols: 3, rows: 1),
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
  return kWindowDesigns.first; // safe fallback for old / unknown ids
}

/// Selectable frame colors. Glass color is hardcoded inside the SVG assets
/// (cyan #1ee5ec) and not user-configurable.
const Map<String, String> kFrameColors = {
  'white': '#f5f5f5',
  'brown': '#7a4a23',
  'grey': '#8a8f96',
  'black': '#2a2a2a',
};

String frameHex(String? colorKey) =>
    kFrameColors[colorKey] ?? kFrameColors['white']!;

/// In-memory cache of raw SVG strings (placeholder intact), keyed by design
/// id. Populated by [preloadDesignSvgs]. Synchronous lookups for the picker /
/// list / form thumbnails use this cache via [cachedDesignSvg].
final Map<String, String> _rawSvgCache = <String, String>{};

/// Preload all catalog SVG assets into the in-memory cache. Call once at app
/// startup (before the window quotation screen opens). Missing files are
/// skipped silently — tiles will show a placeholder icon for those.
Future<void> preloadDesignSvgs() async {
  for (final d in kWindowDesigns) {
    if (_rawSvgCache.containsKey(d.id)) continue;
    try {
      _rawSvgCache[d.id] = await rootBundle.loadString(d.assetPath);
    } catch (_) {
      // Asset missing - leave it out; consumers will fall back gracefully.
    }
  }
}

/// Returns the cached raw SVG for [design], or null if it wasn't preloaded.
String? cachedDesignSvg(WindowDesign design) => _rawSvgCache[design.id];

/// Loads the static SVG for [design] and substitutes the frame color
/// placeholder with the chosen color hex. Returns an SVG string suitable for
/// both `SvgPicture.string` (app UI) and `pw.SvgImage` (PDF). Uses the cache
/// when available, else reads from the asset bundle.
Future<String> loadDesignSvg(
  WindowDesign design, {
  String frameColorKey = 'white',
}) async {
  final cached = _rawSvgCache[design.id];
  final raw = cached ?? await rootBundle.loadString(design.assetPath);
  if (cached == null) _rawSvgCache[design.id] = raw;
  return raw.replaceAll('FRAME_COLOR', frameHex(frameColorKey));
}

/// Synchronous helper for code paths that already hold the raw SVG string
/// (e.g. after preloading) — applies the color substitution only.
String applyFrameColor(String rawSvg, {String frameColorKey = 'white'}) {
  return rawSvg.replaceAll('FRAME_COLOR', frameHex(frameColorKey));
}

/// Convenience: returns a ready-to-render SVG string for [design] using the
/// cache, or a tiny inline fallback if the asset isn't loaded yet. Safe to
/// call synchronously from build methods after [preloadDesignSvgs] has run.
String designSvgOrPlaceholder(
  WindowDesign design, {
  String frameColorKey = 'white',
}) {
  final raw = _rawSvgCache[design.id];
  if (raw == null) {
    // Inline neutral placeholder: a grey rectangle. Keeps layouts stable.
    return '<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">'
        '<rect x="2" y="2" width="96" height="96" fill="#eee" stroke="#999"/>'
        '<text x="50" y="55" font-size="10" text-anchor="middle" fill="#666">'
        '${design.label}</text>'
        '</svg>';
  }
  return raw.replaceAll('FRAME_COLOR', frameHex(frameColorKey));
}
