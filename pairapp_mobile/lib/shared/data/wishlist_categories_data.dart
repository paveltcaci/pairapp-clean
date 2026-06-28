/// Категории желаний для списка желаний пары.
const List<String> kWishlistCategories = [
  'все',
  'свидания',
  'еда',
  'путешествия',
  'дом',
  'подарки',
  'впечатления',
  'уют',
  'разговоры',
  'развлечения',
  'другое',
];

/// Категории без «все» — для фильтров создания.
const List<String> kWishlistCategoriesForCreate = [
  'свидания',
  'еда',
  'путешествия',
  'дом',
  'подарки',
  'впечатления',
  'уют',
  'разговоры',
  'развлечения',
  'другое',
];

/// Шаблоны желаний для быстрого выбора в bottom sheet.
class WishlistTemplate {
  const WishlistTemplate({
    required this.title,
    required this.emoji,
    required this.category,
    this.description,
  });

  final String title;
  final String emoji;
  final String category;
  final String? description;
}

const List<WishlistTemplate> kWishlistTemplates = [
  WishlistTemplate(
    title: 'Сходить в новое кафе',
    emoji: '☕',
    category: 'еда',
    description: 'Выбрать заведение, где ещё не были',
  ),
  WishlistTemplate(
    title: 'Устроить вечер кино',
    emoji: '🎬',
    category: 'развлечения',
    description: 'Выключить свет, попкорн и любимый фильм',
  ),
  WishlistTemplate(
    title: 'Съездить на выходные',
    emoji: '🚗',
    category: 'путешествия',
    description: 'Мини-побег из рутины в любое красивое место',
  ),
  WishlistTemplate(
    title: 'Купить что-то домой',
    emoji: '🏠',
    category: 'дом',
    description: 'То, что давно хотели, но всё откладывали',
  ),
  WishlistTemplate(
    title: 'Сделать совместную фотосессию',
    emoji: '📸',
    category: 'впечатления',
    description: 'Красивые воспоминания на весь год',
  ),
  WishlistTemplate(
    title: 'Приготовить новое блюдо',
    emoji: '🍳',
    category: 'еда',
    description: 'Выбрать рецепт и приготовить вместе',
  ),
  WishlistTemplate(
    title: 'Сходить на концерт',
    emoji: '🎵',
    category: 'развлечения',
    description: 'Живая музыка всегда запоминается',
  ),
  WishlistTemplate(
    title: 'Устроить вечер без телефонов',
    emoji: '📵',
    category: 'уют',
    description: 'Только вы двое и настоящий разговор',
  ),
  WishlistTemplate(
    title: 'Спланировать путешествие',
    emoji: '✈️',
    category: 'путешествия',
    description: 'Выбрать страну и начать мечтать вслух',
  ),
  WishlistTemplate(
    title: 'Сделать общий wishlist на год',
    emoji: '📝',
    category: 'разговоры',
    description: 'Записать всё, чего хотите вместе за год',
  ),
  WishlistTemplate(
    title: 'Попробовать новый ресторан',
    emoji: '🍽️',
    category: 'еда',
    description: 'Кухня, которую ещё не пробовали',
  ),
  WishlistTemplate(
    title: 'Сходить на выставку',
    emoji: '🎨',
    category: 'впечатления',
    description: 'Искусство, которое вдохновит обоих',
  ),
  WishlistTemplate(
    title: 'Поиграть в настольную игру',
    emoji: '🎲',
    category: 'развлечения',
    description: 'Купить новую игру и провести вечер в игре',
  ),
  WishlistTemplate(
    title: 'Сделать сюрприз партнёру',
    emoji: '🎁',
    category: 'подарки',
    description: 'Что-то неожиданное и от души',
  ),
  WishlistTemplate(
    title: 'Устроить пикник',
    emoji: '🧺',
    category: 'свидания',
    description: 'На природе с едой и хорошей погодой',
  ),
  WishlistTemplate(
    title: 'Посмотреть рассвет или закат',
    emoji: '🌅',
    category: 'впечатления',
    description: 'Найти красивое место и просто побыть вместе',
  ),
  WishlistTemplate(
    title: 'Записаться на мастер-класс',
    emoji: '🎭',
    category: 'впечатления',
    description: 'Научиться чему-то новому вдвоём',
  ),
  WishlistTemplate(
    title: 'Создать уютный уголок дома',
    emoji: '🕯️',
    category: 'уют',
    description: 'Украсить пространство для двоих',
  ),
  WishlistTemplate(
    title: 'Поговорить о мечтах',
    emoji: '💬',
    category: 'разговоры',
    description: 'Без спешки, за чашкой чая о самом важном',
  ),
  WishlistTemplate(
    title: 'Сходить в spa или баню',
    emoji: '🛁',
    category: 'уют',
    description: 'Расслабиться и перезагрузиться вместе',
  ),
];
