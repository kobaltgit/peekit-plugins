# PeekIt Plugin UI/UX Style Guide

PeekIt обеспечивает нативный, сверхбыстрый опыт предварительного просмотра файлов в среде Windows 10/11 по нажатию клавиши **Space (Пробел)**. Чтобы плагины выглядели органично, современно и единообразно с операционной системой и друг с другом, следуйте этим рекомендациям по стилю, токенам и верстке.

---

## 1. Цветовая палитра и системные CSS-токены

Плагин обязан поддерживать как тёмную, так и светлую тему оформления. Все стили компонентов должны опираться исключительно на стандартные CSS-переменные:

```css
/* Тёмная тема (по умолчанию) */
:root, [data-theme="dark"] {
  --bg-main:       #0d1117; /* Основной фон окна */
  --bg-surface:    #161b22; /* Фон шапки, тулбаров и панелей */
  --bg-card:       #21262d; /* Фон кнопок, карточек и бейджей */
  --bg-card-hover: #30363d; /* Состояние наведения интерактивных элементов */
  --border-color:  rgba(255, 255, 255, 0.12); /* Тонкие полупрозрачные границы */
  --text-main:     #f0f6fc; /* Основной контрастный текст */
  --text-muted:    #8b949e; /* Второстепенный текст, подсказки, лейблы */
  --accent:        #58a6ff; /* Акцентный цвет кнопок и фокусов */
  --radius-sm:     4px;
  --radius-md:     6px;
  --radius-lg:     10px;
}

/* Светлая тема */
[data-theme="light"] {
  --bg-main:       #f6f8fa;
  --bg-surface:    #ffffff;
  --bg-card:       #f3f4f6;
  --bg-card-hover: #e5e7eb;
  --border-color:  rgba(0, 0, 0, 0.12);
  --text-main:     #1f2328;
  --text-muted:    #656d76;
  --accent:        #0969da;
}
```

> [!TIP]
> Хост PeekIt при отправке `PEEKIT_INIT` может передать кастомный акцентный цвет Windows пользователя (`accentColor`). Вы можете динамически применять его:  
> `document.documentElement.style.setProperty('--accent', payload.accentColor);`

---

## 2. Типографика

Используйте системные гарнитуры Windows Fluent Design:

```css
body {
  font-family: "Segoe UI Variable Text", "Segoe UI", system-ui, -apple-system, sans-serif;
  -webkit-font-smoothing: antialiased;
}

/* Моноширинный текст (код, шестнадцатеричные дампы, метаданные) */
pre, code, .monospace {
  font-family: "Cascadia Code", "Cascadia Mono", "Consolas", monospace;
}
```

* **Заголовок документа в шапке:** `13px` – `14px`, `font-weight: 600`.
* **Основной текст и кнопки:** `12px` – `13px`, `line-height: 1.4`.
* **Бейджи, счётчики, подсказки:** `11px`, `font-weight: 500`.

---

## 3. Анатомия экрана предварительного просмотра

Стандартная компоновка плагина состоит из трёх основных зон:

```text
┌─────────────────────────────────────────────────────────────┐
│  [Icon] Имя_файла.ext   [SVG]    (Spacer)    [+][-][0] [RU] │ ➔ Шапка / Тулбар (40–44px)
├─────────────────────────────────────────────────────────────┤
│                                                             │
│                                                             │
│                      Основной вьюпорт                       │ ➔ Viewport (Canvas / WebGL /
│                   (Рендеринг содержимого)                   │    HTML DOM / SVG)
│                                                             │
│                                                             │
│             ┌───────────────────────────────┐               │
│             │  [Плавающий контроллер зума]  │               │ ➔ (Опционально)
│             └───────────────────────────────┘               │
├─────────────────────────────────────────────────────────────┤
│  1920 × 1080 px · 1.4 МБ                          Стр. 1/14 │ ➔ Статус-бар (24–28px)
└─────────────────────────────────────────────────────────────┘
```

### 3.1 Шапка / Тулбар (`#toolbar`)
* Высота: `40px` – `44px`.
* Фон: `var(--bg-surface)` с нижней границей `1px solid var(--border-color)`.
* Содержит имя открытого файла с обрезкой (`text-overflow: ellipsis`), бейдж расширения, управляющие кнопки и обязательную кнопку смены языка `#btnToggleLang`.

### 3.2 Кнопки управления (`.btn`)
```css
.btn {
  background: var(--bg-card);
  border: 1px solid var(--border-color);
  color: var(--text-main);
  border-radius: var(--radius-md);
  padding: 4px 10px;
  font-size: 12px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 6px;
  transition: all 0.15s ease;
}

.btn:hover {
  background: var(--bg-card-hover);
  border-color: var(--text-muted);
}
```

### 3.3 Плавающие панели управления (Акрил / Блюр)
Если плагину требуются плавающие инструменты (например, поворот 3D-модели или переключение слоёв):
```css
.floating-panel {
  position: absolute;
  bottom: 20px;
  left: 50%;
  transform: translateX(-50%);
  background: rgba(22, 27, 34, 0.85);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-lg);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.35);
  padding: 6px 12px;
  display: flex;
  gap: 8px;
  z-index: 100;
}
```

---

## 4. Правила глубокой локализации (Deep Visual I18N)

Интернационализация должна быть бесшовной: в интерфейсе **не должно оставаться видимых строк на одном языке**:

1. **Разделяйте иконку и текст внутри кнопки:**
   ```html
   <!-- ПЛОХО (текст нельзя обновить без затирания иконки): -->
   <button id="btnLayers">▦ Слои</button>

   <!-- ПРАВИЛЬНО: -->
   <button id="btnLayers">
     <span class="btn-icon">▦</span>
     <span id="btnLayersText" data-i18n="layers">Слои</span>
   </button>
   ```

2. **Локализуйте всплывающие подсказки:**
   Используйте атрибут `data-i18n-title` для кнопок, не имеющих явного текста:
   ```html
   <button class="btn-icon" id="btnZoomIn" data-i18n-title="zoomIn" title="Приблизить (+)">+</button>
   ```

3. **Динамические счётчики:**
   Не склеивайте русские окончания вручную. Используйте словарь:
   ```javascript
   function formatLayers(count) {
     return currentLocale === 'ru' 
       ? `${count} ${pluralize(count, 'слой', 'слоя', 'слоёв')}`
       : `${count} ${count === 1 ? 'layer' : 'layers'}`;
   }
   ```

---

## 5. Горячие клавиши и управление

Плагин должен поддерживать привычные пользователю Windows комбинации клавиш:
* `+` / `-` / `Ctrl + Колесо мыши` — приближение и удаление (Zoom In / Out).
* `Ctrl + 0` — сброс масштаба / вписывание в окно (Fit to screen).
* `Стрелки` / `PageUp` / `PageDown` — перелистывание страниц/слайдов.
* `F` — переключение полноэкранного режима/разворота контента.

> [!IMPORTANT]
> **Никогда не блокируйте клавиши Space (Пробел) и Escape через `event.preventDefault()`!**  
> Клавиша **Пробел** или **Esc** используется пользователем для мгновенного закрытия окна PeekIt. Перехватывать их нажатие разрешено только тогда, когда пользователь активно печатает в поле текстового поиска (`<input type="text">`).
