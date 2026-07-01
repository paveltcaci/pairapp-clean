/// Шаблон бытовой задачи для быстрого добавления.
class ChoreTemplate {
  const ChoreTemplate({
    required this.title,
    required this.emoji,
    required this.category,
    required this.intensity,
    this.estimatedMinutes,
  });

  final String title;
  final String emoji;
  final String category;

  /// 'easy' | 'medium' | 'annoying'
  final String intensity;
  final int? estimatedMinutes;
}

/// Все категории бытовых задач.
const List<String> kChoreCategories = [
  'кухня',
  'уборка',
  'покупки',
  'еда',
  'развлечения',
  'питомцы',
  'планирование',
  'быстрые',
  'неприятные',
  'забота',
  'другое',
];

/// 60 шаблонов бытовых задач на русском языке.
/// Используются как быстрые подсказки при добавлении задачи, а не как основной список.
const List<ChoreTemplate> kChoreTemplates = [
  // ── КУХНЯ ─────────────────────────────────────────────────────────────────
  ChoreTemplate(
    title: 'Помыть посуду',
    emoji: '🍽️',
    category: 'кухня',
    intensity: 'medium',
    estimatedMinutes: 15,
  ),
  ChoreTemplate(
    title: 'Убрать после готовки',
    emoji: '🧽',
    category: 'кухня',
    intensity: 'medium',
    estimatedMinutes: 20,
  ),
  ChoreTemplate(
    title: 'Сделать чай / кофе',
    emoji: '☕',
    category: 'кухня',
    intensity: 'easy',
    estimatedMinutes: 5,
  ),
  ChoreTemplate(
    title: 'Разгрузить посудомойку',
    emoji: '🫙',
    category: 'кухня',
    intensity: 'easy',
    estimatedMinutes: 10,
  ),
  ChoreTemplate(
    title: 'Протереть плиту',
    emoji: '🔥',
    category: 'кухня',
    intensity: 'medium',
    estimatedMinutes: 15,
  ),
  ChoreTemplate(
    title: 'Почистить холодильник',
    emoji: '🧊',
    category: 'кухня',
    intensity: 'annoying',
    estimatedMinutes: 30,
  ),
  ChoreTemplate(
    title: 'Помыть фрукты и овощи',
    emoji: '🥦',
    category: 'кухня',
    intensity: 'easy',
    estimatedMinutes: 10,
  ),

  // ── УБОРКА ────────────────────────────────────────────────────────────────
  ChoreTemplate(
    title: 'Вынести мусор',
    emoji: '🗑️',
    category: 'уборка',
    intensity: 'easy',
    estimatedMinutes: 5,
  ),
  ChoreTemplate(
    title: 'Пропылесосить квартиру',
    emoji: '🧹',
    category: 'уборка',
    intensity: 'medium',
    estimatedMinutes: 30,
  ),
  ChoreTemplate(
    title: 'Помыть полы',
    emoji: '🪣',
    category: 'уборка',
    intensity: 'medium',
    estimatedMinutes: 25,
  ),
  ChoreTemplate(
    title: 'Поменять постельное бельё',
    emoji: '🛏️',
    category: 'уборка',
    intensity: 'medium',
    estimatedMinutes: 20,
  ),
  ChoreTemplate(
    title: 'Постирать бельё',
    emoji: '👕',
    category: 'уборка',
    intensity: 'easy',
    estimatedMinutes: 10,
  ),
  ChoreTemplate(
    title: 'Развесить / сложить бельё',
    emoji: '🧺',
    category: 'уборка',
    intensity: 'medium',
    estimatedMinutes: 15,
  ),
  ChoreTemplate(
    title: 'Протереть пыль',
    emoji: '🌫️',
    category: 'уборка',
    intensity: 'medium',
    estimatedMinutes: 20,
  ),
  ChoreTemplate(
    title: 'Помыть ванную',
    emoji: '🛁',
    category: 'уборка',
    intensity: 'annoying',
    estimatedMinutes: 30,
  ),
  ChoreTemplate(
    title: 'Помыть унитаз',
    emoji: '🚽',
    category: 'неприятные',
    intensity: 'annoying',
    estimatedMinutes: 10,
  ),
  ChoreTemplate(
    title: 'Протереть зеркала',
    emoji: '🪞',
    category: 'уборка',
    intensity: 'easy',
    estimatedMinutes: 10,
  ),
  ChoreTemplate(
    title: 'Разобрать вещи на полках',
    emoji: '📦',
    category: 'уборка',
    intensity: 'annoying',
    estimatedMinutes: 40,
  ),

  // ── ПОКУПКИ ───────────────────────────────────────────────────────────────
  ChoreTemplate(
    title: 'Сходить в магазин',
    emoji: '🛒',
    category: 'покупки',
    intensity: 'medium',
    estimatedMinutes: 30,
  ),
  ChoreTemplate(
    title: 'Составить список покупок',
    emoji: '📝',
    category: 'покупки',
    intensity: 'easy',
    estimatedMinutes: 10,
  ),
  ChoreTemplate(
    title: 'Заказать продукты онлайн',
    emoji: '📱',
    category: 'покупки',
    intensity: 'easy',
    estimatedMinutes: 15,
  ),
  ChoreTemplate(
    title: 'Зайти в аптеку',
    emoji: '💊',
    category: 'покупки',
    intensity: 'easy',
    estimatedMinutes: 20,
  ),

  // ── ЕДА ───────────────────────────────────────────────────────────────────
  ChoreTemplate(
    title: 'Приготовить ужин',
    emoji: '🍳',
    category: 'еда',
    intensity: 'medium',
    estimatedMinutes: 45,
  ),
  ChoreTemplate(
    title: 'Приготовить завтрак',
    emoji: '🥞',
    category: 'еда',
    intensity: 'easy',
    estimatedMinutes: 20,
  ),
  ChoreTemplate(
    title: 'Заказать еду',
    emoji: '🛵',
    category: 'еда',
    intensity: 'easy',
    estimatedMinutes: 10,
  ),
  ChoreTemplate(
    title: 'Разогреть еду',
    emoji: '♨️',
    category: 'еда',
    intensity: 'easy',
    estimatedMinutes: 5,
  ),
  ChoreTemplate(
    title: 'Выбрать, где поужинать',
    emoji: '🍽️',
    category: 'еда',
    intensity: 'easy',
    estimatedMinutes: 5,
  ),
  ChoreTemplate(
    title: 'Приготовить перекус',
    emoji: '🥪',
    category: 'еда',
    intensity: 'easy',
    estimatedMinutes: 10,
  ),

  // ── РАЗВЛЕЧЕНИЯ ───────────────────────────────────────────────────────────
  ChoreTemplate(
    title: 'Выбрать фильм',
    emoji: '🎬',
    category: 'развлечения',
    intensity: 'easy',
    estimatedMinutes: 10,
  ),
  ChoreTemplate(
    title: 'Выбрать сериал',
    emoji: '📺',
    category: 'развлечения',
    intensity: 'easy',
    estimatedMinutes: 10,
  ),
  ChoreTemplate(
    title: 'Найти активность на вечер',
    emoji: '🎲',
    category: 'развлечения',
    intensity: 'easy',
    estimatedMinutes: 10,
  ),
  ChoreTemplate(
    title: 'Выбрать музыку',
    emoji: '🎵',
    category: 'развлечения',
    intensity: 'easy',
    estimatedMinutes: 5,
  ),

  // ── ПИТОМЦЫ ───────────────────────────────────────────────────────────────
  ChoreTemplate(
    title: 'Покормить питомца',
    emoji: '🐾',
    category: 'питомцы',
    intensity: 'easy',
    estimatedMinutes: 5,
  ),
  ChoreTemplate(
    title: 'Выгулять собаку',
    emoji: '🐕',
    category: 'питомцы',
    intensity: 'medium',
    estimatedMinutes: 30,
  ),
  ChoreTemplate(
    title: 'Почистить лоток',
    emoji: '🐱',
    category: 'неприятные',
    intensity: 'annoying',
    estimatedMinutes: 10,
  ),
  ChoreTemplate(
    title: 'Купать питомца',
    emoji: '🛁',
    category: 'питомцы',
    intensity: 'annoying',
    estimatedMinutes: 30,
  ),

  // ── ПЛАНИРОВАНИЕ ──────────────────────────────────────────────────────────
  ChoreTemplate(
    title: 'Запланировать свидание',
    emoji: '💑',
    category: 'планирование',
    intensity: 'easy',
    estimatedMinutes: 15,
  ),
  ChoreTemplate(
    title: 'Оплатить счета',
    emoji: '💳',
    category: 'планирование',
    intensity: 'medium',
    estimatedMinutes: 15,
  ),
  ChoreTemplate(
    title: 'Записаться к врачу',
    emoji: '🏥',
    category: 'планирование',
    intensity: 'easy',
    estimatedMinutes: 10,
  ),
  ChoreTemplate(
    title: 'Спланировать поездку',
    emoji: '✈️',
    category: 'планирование',
    intensity: 'medium',
    estimatedMinutes: 30,
  ),
  ChoreTemplate(
    title: 'Забронировать столик',
    emoji: '🍷',
    category: 'планирование',
    intensity: 'easy',
    estimatedMinutes: 10,
  ),

  // ── БЫСТРЫЕ ───────────────────────────────────────────────────────────────
  ChoreTemplate(
    title: 'Вынести бутылки',
    emoji: '♻️',
    category: 'быстрые',
    intensity: 'easy',
    estimatedMinutes: 5,
  ),
  ChoreTemplate(
    title: 'Полить цветы',
    emoji: '🌱',
    category: 'быстрые',
    intensity: 'easy',
    estimatedMinutes: 5,
  ),
  ChoreTemplate(
    title: 'Проветрить комнату',
    emoji: '🪟',
    category: 'быстрые',
    intensity: 'easy',
    estimatedMinutes: 5,
  ),
  ChoreTemplate(
    title: 'Сменить полотенца',
    emoji: '🏳️',
    category: 'быстрые',
    intensity: 'easy',
    estimatedMinutes: 5,
  ),
  ChoreTemplate(
    title: 'Зарядить телефоны',
    emoji: '🔋',
    category: 'быстрые',
    intensity: 'easy',
    estimatedMinutes: 2,
  ),

  // ── НЕПРИЯТНЫЕ ────────────────────────────────────────────────────────────
  ChoreTemplate(
    title: 'Разобрать завалы',
    emoji: '🗃️',
    category: 'неприятные',
    intensity: 'annoying',
    estimatedMinutes: 60,
  ),
  ChoreTemplate(
    title: 'Почистить духовку',
    emoji: '🔥',
    category: 'неприятные',
    intensity: 'annoying',
    estimatedMinutes: 40,
  ),
  ChoreTemplate(
    title: 'Разморозить холодильник',
    emoji: '❄️',
    category: 'неприятные',
    intensity: 'annoying',
    estimatedMinutes: 60,
  ),
  ChoreTemplate(
    title: 'Помыть окна',
    emoji: '🪟',
    category: 'неприятные',
    intensity: 'annoying',
    estimatedMinutes: 45,
  ),
  ChoreTemplate(
    title: 'Вынести старые вещи',
    emoji: '📦',
    category: 'неприятные',
    intensity: 'medium',
    estimatedMinutes: 30,
  ),

  // ── ЗАБОТА ────────────────────────────────────────────────────────────────
  ChoreTemplate(
    title: 'Приготовить что-то особенное',
    emoji: '💝',
    category: 'забота',
    intensity: 'medium',
    estimatedMinutes: 60,
  ),
  ChoreTemplate(
    title: 'Сделать массаж',
    emoji: '💆',
    category: 'забота',
    intensity: 'easy',
    estimatedMinutes: 20,
  ),
  ChoreTemplate(
    title: 'Приготовить завтрак в постель',
    emoji: '☕',
    category: 'забота',
    intensity: 'medium',
    estimatedMinutes: 25,
  ),
  ChoreTemplate(
    title: 'Купить любимое лакомство',
    emoji: '🍫',
    category: 'забота',
    intensity: 'easy',
    estimatedMinutes: 10,
  ),

  // ── ДРУГОЕ ────────────────────────────────────────────────────────────────
  ChoreTemplate(
    title: 'Забрать посылку',
    emoji: '📬',
    category: 'другое',
    intensity: 'easy',
    estimatedMinutes: 15,
  ),
  ChoreTemplate(
    title: 'Починить что-нибудь',
    emoji: '🔧',
    category: 'другое',
    intensity: 'medium',
    estimatedMinutes: 30,
  ),
  ChoreTemplate(
    title: 'Разобрать почту',
    emoji: '✉️',
    category: 'другое',
    intensity: 'easy',
    estimatedMinutes: 10,
  ),
];
