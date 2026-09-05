import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/plugin_item.dart';

class RegistryService {
  static List<PluginItem>? _cachedPlugins;

  static Future<List<PluginItem>> loadPlugins() async {
    if (_cachedPlugins != null) {
      return _cachedPlugins!;
    }

    try {
      final jsonString = await rootBundle.loadString('assets/registry.json');
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final rawList = data['plugins'] as List<dynamic>? ?? [];
      _cachedPlugins = rawList.map((item) => PluginItem.fromJson(item as Map<String, dynamic>)).toList();
      return _cachedPlugins!;
    } catch (e) {
      // Fallback in case of asset bundling edge-case
      _cachedPlugins = _fallbackPlugins;
      return _cachedPlugins!;
    }
  }

  static final List<PluginItem> _fallbackPlugins = [
    const PluginItem(
      id: 'com.peekit.3d-viewer',
      name: '3D Model Viewer',
      version: '1.0.0',
      author: 'Kobalt',
      description: 'Interactive 3D model previewer for STL, OBJ, GLTF, GLB, and PLY files with WebGL rendering, orbit controls, turntable and wireframe modes.',
      extensions: ['.stl', '.obj', '.gltf', '.glb', '.ply'],
      entry: 'index.html',
      minPeekitVersion: '1.0.0',
      downloadUrl: 'https://github.com/kobaltgit/peekit-plugins/releases/latest/download/com.peekit.3d-viewer-1.0.0.pkit',
      icon: 'box',
      homepage: 'https://github.com/kobaltgit/peekit-plugins',
      category: '3D',
      sizeKb: '368.8 KB',
      sha256: 'f7434f82fa3a491ae79c4ba59cf72db4ba960fc060d4b99859f9c7e09ea9da6f',
    ),
    const PluginItem(
      id: 'com.peekit.docx-viewer',
      name: 'Word Document Viewer',
      version: '1.0.0',
      author: 'PeekIt Team',
      description: 'Fast offline viewer for Word documents (DOCX, DOC) with realistic page layout, styles, and tables.',
      extensions: ['.docx', '.doc'],
      entry: 'index.html',
      minPeekitVersion: '1.0.0',
      downloadUrl: 'https://github.com/kobaltgit/peekit-plugins/releases/latest/download/com.peekit.docx-viewer-1.0.0.pkit',
      icon: 'file-text',
      homepage: 'https://github.com/kobaltgit/peekit-plugins',
      category: 'Documents',
      sizeKb: '100.0 KB',
      sha256: '93f64d4970d82380590a597a731efcceb7bf1b20f4c3a372e90f230aa706603a',
    ),
    const PluginItem(
      id: 'com.peekit.font-viewer',
      name: 'Font Viewer',
      version: '1.0.0',
      author: 'Kobalt',
      description: 'Full font previewer supporting TTF, OTF, WOFF, and WOFF2 with pangram tests, size slider, and Unicode glyph matrix.',
      extensions: ['.ttf', '.otf', '.woff', '.woff2'],
      entry: 'index.html',
      minPeekitVersion: '1.0.0',
      downloadUrl: 'https://github.com/kobaltgit/peekit-plugins/releases/latest/download/com.peekit.font-viewer-1.0.0.pkit',
      icon: 'type',
      homepage: 'https://github.com/kobaltgit/peekit-plugins',
      category: 'Fonts',
      sizeKb: '101.5 KB',
      sha256: 'c4e8be7b35f24b04c818b2cba1b22e11e0e84c98a3c5a6109f2913fa394a1793',
    ),
    const PluginItem(
      id: 'com.peekit.sheet-viewer',
      name: 'Spreadsheet Viewer',
      version: '1.0.0',
      author: 'Kobalt',
      description: 'Fast offline spreadsheet reader for Excel (XLSX, XLS), CSV, TSV, and ODS with multi-sheet tabs and search.',
      extensions: ['.xlsx', '.xls', '.csv', '.tsv', '.ods'],
      entry: 'index.html',
      minPeekitVersion: '1.0.0',
      downloadUrl: 'https://github.com/kobaltgit/peekit-plugins/releases/latest/download/com.peekit.sheet-viewer-1.0.0.pkit',
      icon: 'table',
      homepage: 'https://github.com/kobaltgit/peekit-plugins',
      category: 'Spreadsheets',
      sizeKb: '659.8 KB',
      sha256: '9aba447f77373012929fa59dcba9b87a875a5c6d3bc01bdf2555627f12e873ad',
    ),
    const PluginItem(
      id: 'com.peekit.slides-viewer',
      name: 'PowerPoint Presentation Viewer',
      version: '1.0.0',
      author: 'PeekIt Team',
      description: 'Preview PPTX presentations slide-by-slide with thumbnail filmstrip and keyboard navigation.',
      extensions: ['.pptx', '.ppt'],
      entry: 'index.html',
      minPeekitVersion: '1.0.0',
      downloadUrl: 'https://github.com/kobaltgit/peekit-plugins/releases/latest/download/com.peekit.slides-viewer-1.0.0.pkit',
      icon: 'tv',
      homepage: 'https://github.com/kobaltgit/peekit-plugins',
      category: 'Presentations',
      sizeKb: '67.5 KB',
      sha256: 'a2d31c039f2e5a397858c49e1be281aa00a12e2c2fbf5dfd07ca2f458ca64147',
    ),
    const PluginItem(
      id: 'com.peekit.ai-viewer',
      name: 'Adobe Illustrator Viewer',
      version: '1.0.0',
      author: 'Kobalt',
      description: 'High-fidelity vector previewer for Adobe Illustrator (.ai) files with multi-artboard navigation, zoom controls, and metadata inspection.',
      extensions: ['.ai'],
      entry: 'index.html',
      minPeekitVersion: '1.0.0',
      downloadUrl: 'https://github.com/kobaltgit/peekit-plugins/releases/latest/download/com.peekit.ai-viewer-1.0.0.pkit',
      icon: 'image',
      homepage: 'https://github.com/kobaltgit/peekit-plugins',
      category: 'Graphics',
      sizeKb: '521.7 KB',
      sha256: '50534ccda6ef471d9fa6012c1a523a3082abb507c0a56c37db7f7503e831789c',
    ),
  ];
}
