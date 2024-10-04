[اللغة العربية (AR)](./about_ar.md) |
[Azərbaycanlı (AZ)](./about_az.md) |
[Тарашкевіца (BE)](./about_be.md) |
[Latsinka (BE)](./about_be_EU.md) |
[简体中文 (ZH-CN)](./about_zh.md) |
[繁體中文 (ZH-TW)](./about_zh_TW.md) |
[English (EN-US)](./about_en.md) |
[Français (FR)](./about_fr.md) |
[Deutsch (DE)](./about_de.md) |
[हिंदी (HI-IN)](./about_hi.md) |
[Italiano (IT)](./about_it.md) |
[日本語 (JA)](./about_ja.md) |
[فارسی (FA)](./about_fa.md) |
[Polski (PL)](./about_pl.md) |
[Português Europeu (PT)](./about_pt.md) |
[Português Brasileiro (PTB)](./about_pt_BR.md) |
[Español (ES)](./about_es.md) |
[Türk dili (TR)](./about_tr.md) |
Українська (UK-UA) |
[O'zbek (UZ)](./about_uz.md)

---

**Fingrom** - крос-платформенний додаток для фінансового обліку з відкритим вихідним кодом без реклами та обмежень.
Мета рішення - створити інтуїтивно зрозумілий, ефективний та інклюзивний додаток для фінансового обліку. 
Це дозволить користувачам легко керувати своїми фінансами, гарантуючи, що ніхто не залишиться поза увагою.

[![Подивіться відео](../images/presentation_en.png)](https://youtu.be/sNTbpILLsOw)

### Функціонал
- Облік (тип рахунку, валюта/криптовалюта)
  - Просте групування за допомогою `/`-символу (в назві) для головної сторінки
  - Журнал транзакцій
  - Заморожування суми за датою оновлення (для імпорту попередньої історії)
- Категорії бюджету
  - Просте групування за допомогою `/`-символу (в назві) на головній сторінці
  - З перерахунком лімітів:
    - Поновлюються на початку кожного місяця
    - Налаштовувані ліміти на місяць
    - Відносно (0.0 ... 1.0) до доходу
  - Або без обмежень, показуючи витрачену суму
- Рахунки, перекази, надходження (інвойси)
- Визначення цілей
- Курси валют, валюта за замовчуванням для підбиття підсумків
- Метрики: 
  - Бюджет:
    - Прогноз (з моделюванням за методом Монте-Карло)
    - Ліміт бюджету та витрати на місяць
  - Рахунок:
    - Свічковий (OHLC) графік
    - Радар здоров'я доходу
    - Розподіл валют
  - Рахунки:
    - Витрати з початку року
    - Барні перегони для категорій
  - Діаграма індикатора цілей
  - Історична діаграма валют
- Синхронізація між пристроями (P2P) 
- Відновлення через WebDav або прямий файл
- Імпорт з файлів `CSV`, `QIF`, `OFX` для рахунків та інвойсів
- Шифрування даних
- Локалізація
- Зручність для користувача
  - Налаштовувана головна сторінка (кілька конфігурацій для кожного параметра «ширина х висота»)
  - Адаптивний та адаптивний дизайн
    - Адаптивна навігаційна панель (зверху, знизу, праворуч) та вкладки (зверху, ліворуч)
  - Режим теми (темний, світлий, системний) з визначенням палітри (системна, користувацька, персональна - селектор кольорів)
  - Збереження останнього вибору для облікового запису, бюджету та валюти
  - Автопрокрутка до сфокусованого елемента на Формі
  - Розгортання / згортання розділів на головній сторінці
  - Проведіть пальцем для швидкого доступу до дій Редагування та Видалення
  - Збільшення/зменшення масштабу (від 60% до 200%) через «Налаштування»
  - Ярлики

| Опис                               | Ярлик                          |
| ---------------------------------- | ------------------------------ |
| Відкрити/закрити панель навігації  | `Shift` + `Enter`              |
| Перейти вгору                      | `вгору`                        |
| Перейти вниз                       | `вниз`                         |
| Відкрити вибране                   | `Enter`                        |
| Збільшити                          | `Ctrl` + `+`                   |
| Збільшити (мишею)                  | `Ctrl` + `прокрутити вниз`     |
| Зменшити                           | `Ctrl` + `-`                   |
| Зменшити (мишею)                   | `Ctrl` + `прокрутити вгору`    |
| Скинути масштаб                    | `Ctrl` + `0`                   |
| Додати нову транзакцію             | `Ctrl` + `N`                   |
| Повернутися назад                  | `Ctrl` + `Backspace`           |
<!--
| Редагувати вибраний елемент        | `Ctrl` + `E`                   |
| Видалити вибраний елемент          | `Ctrl` + `D`                   |
-->