class MockIssue {
  final String id;
  final String title;
  final String description;
  final String author;
  final String status; // open | discussion | resolved
  final String category;
  final int importance;
  final DateTime createdAt;

  const MockIssue({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.status,
    required this.category,
    required this.importance,
    required this.createdAt,
  });
}

class MockMessage {
  final String text;
  final bool isMe;
  final DateTime time;

  const MockMessage({required this.text, required this.isMe, required this.time});
}

class MockAgreement {
  final String title;
  final String status; // active | done
  final String createdBy;

  const MockAgreement({
    required this.title,
    required this.status,
    required this.createdBy,
  });
}

class MockData {
  static final List<MockIssue> issues = [
    MockIssue(
      id: '1',
      title: 'Нет времени на совместные вечера',
      description: 'Мы редко проводим время вдвоём без телефонов.',
      author: 'Анна',
      status: 'open',
      category: 'Время',
      importance: 4,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    MockIssue(
      id: '2',
      title: 'Финансовое планирование',
      description: 'Нужно обсудить бюджет на следующий месяц.',
      author: 'Павел',
      status: 'discussion',
      category: 'Финансы',
      importance: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    MockIssue(
      id: '3',
      title: 'Распределение домашних дел',
      description: 'Хочу пересмотреть, кто что делает дома.',
      author: 'Анна',
      status: 'resolved',
      category: 'Быт',
      importance: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  static final List<MockMessage> messages = [
    MockMessage(text: 'Привет! Можем обсудить это сегодня вечером?', isMe: false, time: DateTime.now().subtract(const Duration(minutes: 30))),
    MockMessage(text: 'Да, конечно. Я буду дома около 8.', isMe: true, time: DateTime.now().subtract(const Duration(minutes: 25))),
    MockMessage(text: 'Хорошо, подготовлю свои мысли на эту тему.', isMe: false, time: DateTime.now().subtract(const Duration(minutes: 20))),
    MockMessage(text: 'Отлично 💜 Давай попробуем найти решение вместе', isMe: true, time: DateTime.now().subtract(const Duration(minutes: 10))),
  ];

  static final List<MockAgreement> agreements = [
    MockAgreement(title: 'Совместный ужин каждую пятницу', status: 'active', createdBy: 'Оба'),
    MockAgreement(title: 'Не проверять телефоны во время еды', status: 'active', createdBy: 'Анна'),
    MockAgreement(title: 'Убираться по очереди', status: 'done', createdBy: 'Павел'),
    MockAgreement(title: 'Ежемесячный финансовый разговор', status: 'active', createdBy: 'Оба'),
  ];

  static const List<String> randomActivities = [
    'Приготовить новое блюдо вместе 🍝',
    'Пешая прогулка в незнакомом месте 🌿',
    'Настольная игра при свечах 🕯️',
    'Посмотреть старый любимый фильм 🎬',
    'Сделать друг другу массаж 💆',
    'Нарисовать портреты друг друга 🎨',
    'Спонтанная поездка за город 🚗',
    'Квест в городе 🗺️',
  ];
}
