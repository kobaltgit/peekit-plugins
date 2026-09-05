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

    // Infer category and packaging details based on ID
    String cat = 'Other';
    String size = '100 KB';
    String sha = '';

    if (id.contains('3d')) {
      cat = '3D';
      size = '368.8 KB';
      sha = 'f7434f82fa3a491ae79c4ba59cf72db4ba960fc060d4b99859f9c7e09ea9da6f';
    } else if (id.contains('docx')) {
      cat = 'Documents';
      size = '100.0 KB';
      sha = '93f64d4970d82380590a597a731efcceb7bf1b20f4c3a372e90f230aa706603a';
    } else if (id.contains('font')) {
      cat = 'Fonts';
      size = '101.5 KB';
      sha = 'c4e8be7b35f24b04c818b2cba1b22e11e0e84c98a3c5a6109f2913fa394a1793';
    } else if (id.contains('sheet')) {
      cat = 'Spreadsheets';
      size = '659.8 KB';
      sha = '9aba447f77373012929fa59dcba9b87a875a5c6d3bc01bdf2555627f12e873ad';
    } else if (id.contains('slides')) {
      cat = 'Presentations';
      size = '67.5 KB';
      sha = 'a2d31c039f2e5a397858c49e1be281aa00a12e2c2fbf5dfd07ca2f458ca64147';
    }

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
      sizeKb: json['size_kb'] != null ? '${json['size_kb']} KB' : size,
      sha256: (json['sha256'] as String?) ?? sha,
    );
  }
}
