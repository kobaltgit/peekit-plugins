class WebsiteI18n {
  static const Map<String, Map<String, String>> _strings = {
    'ru': {
      // Navbar
      'nav_catalog': 'Каталог плагинов',
      'nav_demo': 'Живое демо',
      'nav_dev': 'Разработчикам',
      'nav_faq': 'Вопросы и ответы',
      'nav_download_peekit': 'Скачать PeekIt',

      // Hero
      'hero_tag': 'ЭКОСИСТЕМА РАСШИРЕНИЙ PEEKIT',
      'hero_title': 'Мгновенный просмотр любых файлов по клавише Space',
      'hero_subtitle':
          'Автономные, безопасные и ультрабыстрые плагины для PeekIt в Windows 10 & 11. Никаких тяжелых офисных программ: наведите курсор на 3D-модель, DOCX, XLSX или шрифт и нажмите Пробел.',
      'hero_btn_explore': 'Смотреть плагины',
      'hero_btn_peekit': 'Скачать PeekIt',
      'hero_badge_offline': '100% Offline-first',
      'hero_badge_sandbox': 'WebView2 Sandbox',
      'hero_badge_speed': 'Старт < 50 мс',

      // Catalog
      'cat_title': 'Официальные плагины',
      'cat_subtitle': 'Готовые пакеты формата .pkit для мгновенной интеграции в PeekIt',
      'cat_search_hint': 'Поиск плагина по названию или расширению (например: .stl, .docx, excel)...',
      'cat_all': 'Все',
      'cat_3d': '3D модели',
      'cat_docs': 'Документы',
      'cat_sheets': 'Таблицы',
      'cat_fonts': 'Шрифты',
      'cat_slides': 'Презентации',
      'cat_graphics': 'Векторная графика',
      'cat_download_btn': 'Скачать .pkit',
      'cat_details_btn': 'Подробнее',
      'cat_copied_sha': 'SHA-256 скопирован в буфер обмена!',
      'cat_no_results': 'Плагины не найдены по запросу',

      // Detail Dialog
      'dlg_formats': 'Поддерживаемые форматы:',
      'dlg_version': 'Версия:',
      'dlg_author': 'Автор:',
      'dlg_size': 'Размер пакета:',
      'dlg_sha': 'Контрольная сумма SHA-256:',
      'dlg_how_to_install': 'Как установить в PeekIt:',
      'dlg_step1': '1. Скачайте файл пакета (.pkit).',
      'dlg_step2': '2. Дважды кликните по файлу .pkit или перетащите его в окно настроек PeekIt.',
      'dlg_step3': '3. Плагин активируется мгновенно без перезагрузки утилиты!',
      'dlg_close': 'Закрыть',

      // Demo
      'demo_title': 'Интерактивное демо предпросмотра',
      'demo_subtitle': 'Попробуйте, как работают плагины PeekIt прямо в браузере',
      'demo_hint': 'Нажмите пробел или выберите файл для симуляции предпросмотра',
      'demo_spacebar_label': 'SPACEBAR',

      // Dev Guide
      'dev_title': 'Разработчикам плагинов',
      'dev_subtitle': 'Создайте свой плагин за 5 минут на привычном веб-стеке (HTML5, JS, WebGL, Canvas, WASM)',
      'dev_step1_title': '1. Создайте плагин из шаблона',
      'dev_step1_desc': 'Скопируйте готовую заготовку и настройте manifest.json с нужными расширениями файлов.',
      'dev_step2_title': '2. Упакуйте в .pkit одной командой',
      'dev_step2_desc': 'Утилита pack_plugin.cjs автоматически проверит структуру и создаст оптимизированный пакет.',
      'dev_step3_title': '3. Опубликуйте в реестре',
      'dev_step3_desc': 'Отправьте Pull Request в репозиторий для добавления в официальный каталог.',
      'dev_btn_guide': 'Полное руководство разработчика',

      // FAQ
      'faq_title': 'Часто задаваемые вопросы',
      'faq_subtitle': 'Все, что нужно знать об экосистеме плагинов PeekIt',
      'faq_q1': 'Что такое формат .pkit?',
      'faq_a1': '.pkit — это официальный защищенный формат дистрибуции плагинов PeekIt. Он представляет собой сжатый ZIP-архив, содержащий manifest.json, веб-точку входа index.html и необходимые локальные ресурсы.',
      'faq_q2': 'Безопасны ли плагины для Windows?',
      'faq_a2': 'Да! Плагины работают внутри изолированного контейнера <iframe sandbox="allow-scripts"> движка WebView2. У плагинов нет прямого доступа к файловой системе, реестру Windows или локальным процессам, а сетевые запросы строго запрещены.',
      'faq_q3': 'Сколько памяти потребляет плагин?',
      'faq_a3': 'Плагин активируется только в момент нажатия Пробела и мгновенно освобождает память и контексты рендера при закрытии окна предпросмотра.',
      'faq_q4': 'Как создать свой плагин?',
      'faq_a4': 'Вам не нужны компиляторы C++ или Rust. Достаточно знаний стандартного веб-стека. В репозитории доступен готовый шаблон в папке template/ и подробное руководство PLUGIN_DEVELOPMENT_GUIDE.md.',

      // Footer
      'footer_rights': '© 2026 Kobalt Tools / PeekIt Ecosystem. Распространяется под свободной лицензией MIT.',
      'footer_sister_projects': 'Проекты экосистемы Kobalt Tools:',
    },
    'en': {
      // Navbar
      'nav_catalog': 'Plugin Directory',
      'nav_demo': 'Live Demo',
      'nav_dev': 'Developers',
      'nav_faq': 'FAQ',
      'nav_download_peekit': 'Get PeekIt',

      // Hero
      'hero_tag': 'PEEKIT EXTENSION ECOSYSTEM',
      'hero_title': 'Instant Spacebar file preview for any format',
      'hero_subtitle':
          'Lightweight, secure, offline-first plugins for PeekIt on Windows 10 & 11. No need to launch heavy desktop apps: hover over a 3D model, Word doc, spreadsheet or font and tap Spacebar.',
      'hero_btn_explore': 'Explore Plugins',
      'hero_btn_peekit': 'Download PeekIt',
      'hero_badge_offline': '100% Offline-first',
      'hero_badge_sandbox': 'WebView2 Sandbox',
      'hero_badge_speed': 'Launch < 50 ms',

      // Catalog
      'cat_title': 'Official Plugins Catalog',
      'cat_subtitle': 'Ready-to-use .pkit packages for seamless PeekIt integration',
      'cat_search_hint': 'Search plugins by name or extension (e.g., .stl, .docx, excel)...',
      'cat_all': 'All',
      'cat_3d': '3D Models',
      'cat_docs': 'Documents',
      'cat_sheets': 'Spreadsheets',
      'cat_fonts': 'Fonts',
      'cat_slides': 'Presentations',
      'cat_graphics': 'Vector Graphics',
      'cat_download_btn': 'Download .pkit',
      'cat_details_btn': 'Details',
      'cat_copied_sha': 'SHA-256 copied to clipboard!',
      'cat_no_results': 'No plugins matched your search',

      // Detail Dialog
      'dlg_formats': 'Supported Formats:',
      'dlg_version': 'Version:',
      'dlg_author': 'Author:',
      'dlg_size': 'Package Size:',
      'dlg_sha': 'SHA-256 Checksum:',
      'dlg_how_to_install': 'How to install in PeekIt:',
      'dlg_step1': '1. Download the .pkit package file.',
      'dlg_step2': '2. Double-click the .pkit file or drag-and-drop it into PeekIt settings window.',
      'dlg_step3': '3. The plugin is activated instantly without restarting the app!',
      'dlg_close': 'Close',

      // Demo
      'demo_title': 'Interactive Preview Demo',
      'demo_subtitle': 'Experience how PeekIt plugins work right inside your browser',
      'demo_hint': 'Press Spacebar or select a file to simulate preview',
      'demo_spacebar_label': 'SPACEBAR',

      // Dev Guide
      'dev_title': 'For Plugin Developers',
      'dev_subtitle': 'Build custom preview plugins in 5 minutes using your favorite web tech (HTML5, JS, WebGL, Canvas, WASM)',
      'dev_step1_title': '1. Scaffold from template',
      'dev_step1_desc': 'Clone the starter kit and configure manifest.json with your target file extensions.',
      'dev_step2_title': '2. Pack to .pkit with one command',
      'dev_step2_desc': 'The pack_plugin.cjs tool validates the structure and builds an optimized .pkit archive.',
      'dev_step3_title': '3. Publish to Registry',
      'dev_step3_desc': 'Submit a Pull Request to the repository to be listed in the official directory.',
      'dev_btn_guide': 'Full Developer Guide',

      // FAQ
      'faq_title': 'Frequently Asked Questions',
      'faq_subtitle': 'Everything you need to know about PeekIt plugins ecosystem',
      'faq_q1': 'What is the .pkit format?',
      'faq_a1': '.pkit is the official distribution format for PeekIt plugins. It is a ZIP archive containing manifest.json, index.html entry point, and offline assets.',
      'faq_q2': 'Are third-party plugins safe?',
      'faq_a2': 'Yes! Plugins execute inside an isolated <iframe sandbox="allow-scripts"> container in WebView2. Plugins have zero direct access to host filesystem, registry, or network.',
      'faq_q3': 'How much RAM does a plugin consume?',
      'faq_a3': 'A plugin is only spun up when you hit Spacebar, and instantly deallocates its memory and render contexts upon window close.',
      'faq_q4': 'How do I build my own plugin?',
      'faq_a4': 'No C++ or Rust compilers required! Standard web technologies are all you need. Check template/ folder and PLUGIN_DEVELOPMENT_GUIDE.md.',

      // Footer
      'footer_rights': '© 2026 Kobalt Tools / PeekIt Ecosystem. Licensed under MIT.',
      'footer_sister_projects': 'Kobalt Tools Ecosystem projects:',
    },
  };

  static String get(String key, String locale) {
    return _strings[locale]?[key] ?? _strings['ru']?[key] ?? key;
  }
}
