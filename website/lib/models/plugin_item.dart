class PluginItem {
  final String id;
  final String name;
  final String version;
  final String author;
  final String description;
  final List<String> extensions;
  final String entry;
  final String minPeekitVersion;
  final String downloadUrl;
  final String icon;
  final String homepage;
  final String category;
  final String sizeKb;
  final String sha256;

  const PluginItem({
    required this.id,
    required this.name,
    required this.version,
    required this.author,
    required this.description,
    required this.extensions,
    required this.entry,
    required this.minPeekitVersion,
    required this.downloadUrl,
    required this.icon,
    required this.homepage,
    required this.category,
    required this.sizeKb,
    required this.sha256,
  });

  factory PluginItem.fromJson(Map<String, dynamic> json) {
    final exts = (json['extensions'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    final id = json['id'] as String? ?? '';
    final name = json['name'] as String? ?? '';
    final version = json['version'] as String? ?? '1.0.0';

    // Read category from JSON, or infer based on ID if absent
    String cat = (json['category'] as String?)?.trim() ?? '';
    if (cat.isEmpty) {
      if (id.contains('3d')) {
        cat = '3D';
      } else if (id.contains('docx') || id.contains('ebook')) {
        cat = 'Documents';
      } else if (id.contains('font')) {
        cat = 'Fonts';
      } else if (id.contains('sheet')) {
        cat = 'Spreadsheets';
      } else if (id.contains('slides')) {
        cat = 'Presentations';
      } else if (id.contains('ai') || id.contains('psd') || id.contains('eps') || id.contains('dds')) {
        cat = 'Graphics';
      } else if (id.contains('apk') || id.contains('sqlite')) {
        cat = 'Utilities';
      } else {
        cat = 'Utilities';
      }
    }

    final rawSize = json['size_kb'];
    final size = rawSize != null ? '$rawSize KB' : '100 KB';
    final sha = (json['sha256'] as String?) ?? '';

    return PluginItem(
      id: id,
      name: name,
      version: json['version'] as String? ?? '1.0.0',
      author: json['author'] as String? ?? 'Kobalt',
      description: json['description'] as String? ?? '',
      extensions: exts,
      entry: json['entry'] as String? ?? 'index.html',
      minPeekitVersion: json['min_peekit_version'] as String? ?? '1.0.0',
      downloadUrl: json['download_url'] as String? ??
          'https://kobaltgit.github.io/peekit-plugins/plugins/$id-$version.pkit',
      icon: json['icon'] as String? ?? 'box',
      homepage: json['homepage'] as String? ??
          'https://github.com/kobaltgit/peekit-plugins',
      category: cat,
      sizeKb: size,
      sha256: sha,
    );
  }
}
