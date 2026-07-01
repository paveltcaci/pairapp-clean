import 'package:flutter/material.dart';

import '../models/quiz_question.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Категории
// ─────────────────────────────────────────────────────────────────────────────

const List<QuizCategory> kQuizCategories = [
  QuizCategory(
    id: 'know_each_other',
    title: 'Насколько вы знаете\nдруг друга',
    emoji: '💞',
    gradient: [0xFF7C5CFC, 0xFF9D7FFF],
  ),
  QuizCategory(
    id: 'deep',
    title: 'Глубокие вопросы',
    emoji: '🌙',
    gradient: [0xFF2D3561, 0xFF5C6BC0],
  ),
  QuizCategory(
    id: 'funny',
    title: 'Смешное',
    emoji: '😂',
    gradient: [0xFFFF8A65, 0xFFFFB74D],
  ),
  QuizCategory(
    id: 'food',
    title: 'Еда и привычки',
    emoji: '🍕',
    gradient: [0xFFEF5350, 0xFFFF7043],
  ),
  QuizCategory(
    id: 'lifestyle',
    title: 'Быт и характер',
    emoji: '🏡',
    gradient: [0xFF26A69A, 0xFF4DB6AC],
  ),
  QuizCategory(
    id: 'dreams',
    title: 'Мечты и планы',
    emoji: '✈️',
    gradient: [0xFF1E88E5, 0xFF42A5F5],
  ),
  QuizCategory(
    id: 'romance',
    title: 'Романтика',
    emoji: '🔥',
    gradient: [0xFFFF6B9D, 0xFFFF8A65],
  ),
  QuizCategory(
    id: 'random',
    title: 'Случайный вопрос',
    emoji: '🎲',
    gradient: [0xFF7C5CFC, 0xFFFF6B9D],
  ),
  QuizCategory(
    id: 'intimate',
    title: 'Близость 18+',
    emoji: '🔞',
    gradient: [0xFF880E4F, 0xFFAD1457],
    isAdult: true,
  ),
];

Color quizCategoryColor(QuizCategory cat) =>
    Color(cat.gradient[0]);

LinearGradient quizCategoryGradient(QuizCategory cat) => LinearGradient(
      colors: cat.gradient.map((c) => Color(c)).toList(),
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

// ─────────────────────────────────────────────────────────────────────────────
// Банк вопросов
// ─────────────────────────────────────────────────────────────────────────────

const List<QuizQuestion> kQuizQuestions = [
  // ── 💞 Насколько вы знаете друг друга (16 вопросов) ──────────────────────

  QuizQuestion(
    id: 'keo_01',
    category: 'know_each_other',
    text: 'Какое моё любимое блюдо на завтрак?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'keo_02',
    category: 'know_each_other',
    text: 'Назови мой самый большой страх.',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'keo_03',
    category: 'know_each_other',
    text: 'Что меня раздражает больше всего в людях?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'keo_04',
    category: 'know_each_other',
    text: 'Как я провожу идеальный выходной день?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'keo_05',
    category: 'know_each_other',
    text: 'Какое моё любимое время года?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'spring', text: '🌸 Весна'),
      QuizOption(id: 'summer', text: '☀️ Лето'),
      QuizOption(id: 'autumn', text: '🍂 Осень'),
      QuizOption(id: 'winter', text: '❄️ Зима'),
    ],
  ),
  QuizQuestion(
    id: 'keo_06',
    category: 'know_each_other',
    text: 'Какую музыку я слушаю, когда грустно?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'keo_07',
    category: 'know_each_other',
    text: 'Что меня заряжает после тяжёлого дня?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'keo_08',
    category: 'know_each_other',
    text: 'Как меня зовут мои ближайшие друзья?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'keo_09',
    category: 'know_each_other',
    text: 'Какой фильм я могу пересматривать бесконечно?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'keo_10',
    category: 'know_each_other',
    text: 'Что я обычно делаю в первые минуты после пробуждения?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'keo_11',
    category: 'know_each_other',
    text: 'Какой у меня стиль общения в конфликте?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'talk', text: '🗣 Сразу говорю'),
      QuizOption(id: 'think', text: '🧘 Сначала остываю'),
      QuizOption(id: 'silence', text: '🤐 Замыкаюсь'),
      QuizOption(id: 'jokes', text: '😄 Разряжаю юмором'),
    ],
  ),
  QuizQuestion(
    id: 'keo_12',
    category: 'know_each_other',
    text: 'Назови мою любимую книгу или жанр.',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'keo_13',
    category: 'know_each_other',
    text: 'Что я делаю, когда хочу побыть один(а)?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'keo_14',
    category: 'know_each_other',
    text: 'Какую работу мечты я бы выбрал(а), если бы деньги не имели значения?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'keo_15',
    category: 'know_each_other',
    text: 'Какой запах ассоциируется у меня с детством?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'keo_16',
    category: 'know_each_other',
    text: 'Что мне труднее всего: начать что-то новое, закончить начатое или просить о помощи?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'start', text: '🚀 Начать'),
      QuizOption(id: 'finish', text: '🏁 Закончить'),
      QuizOption(id: 'ask', text: '🙋 Просить помощи'),
    ],
  ),

  // ── 🌙 Глубокие вопросы (15 вопросов) ───────────────────────────────────

  QuizQuestion(
    id: 'deep_01',
    category: 'deep',
    text: 'Что для тебя важнее: честность или тактичность?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'honesty', text: '💬 Честность'),
      QuizOption(id: 'tact', text: '🕊 Тактичность'),
      QuizOption(id: 'both', text: '⚖️ Зависит от ситуации'),
    ],
  ),
  QuizQuestion(
    id: 'deep_02',
    category: 'deep',
    text: 'Что ты хотел(а) бы, чтобы о тебе помнили люди?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'deep_03',
    category: 'deep',
    text: 'Если бы ты мог(ла) изменить одно решение в своей жизни — что бы это было?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'deep_04',
    category: 'deep',
    text: 'Что для тебя значит «счастливая жизнь»?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'deep_05',
    category: 'deep',
    text: 'В чём твоя самая большая сила как человека?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'deep_06',
    category: 'deep',
    text: 'Чего ты больше всего боишься потерять?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'deep_07',
    category: 'deep',
    text: 'Что ты делаешь, когда теряешь веру в себя?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'deep_08',
    category: 'deep',
    text: 'Какой урок жизни ты усвоил(а) сложнее всего?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'deep_09',
    category: 'deep',
    text: 'Что тебя по-настоящему вдохновляет?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'deep_10',
    category: 'deep',
    text: 'Есть ли что-то, о чём ты редко говоришь вслух?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'deep_11',
    category: 'deep',
    text: 'Что ты думаешь об отношениях на расстоянии?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'deep_12',
    category: 'deep',
    text: 'Как ты относишься к идее прожить жизнь без компромиссов?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'deep_13',
    category: 'deep',
    text: 'Где ты черпаешь силы, когда всё идёт не так?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'deep_14',
    category: 'deep',
    text: 'Что для тебя важнее: деньги, свобода или любовь?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'money', text: '💰 Деньги'),
      QuizOption(id: 'freedom', text: '🌊 Свобода'),
      QuizOption(id: 'love', text: '❤️ Любовь'),
    ],
  ),
  QuizQuestion(
    id: 'deep_15',
    category: 'deep',
    text: 'Если бы ты написал(а) книгу о своей жизни — как бы она называлась?',
    answerType: QuizAnswerType.openText,
  ),

  // ── 😂 Смешное (14 вопросов) ──────────────────────────────────────────────

  QuizQuestion(
    id: 'funny_01',
    category: 'funny',
    text: 'Суперсила или способность читать мысли?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'power', text: '💪 Суперсила'),
      QuizOption(id: 'minds', text: '🧠 Читать мысли'),
    ],
  ),
  QuizQuestion(
    id: 'funny_02',
    category: 'funny',
    text: 'Какую смешную привычку в себе ты замечаешь?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'funny_03',
    category: 'funny',
    text: 'Что ты делаешь первым делом, когда никого нет дома?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'funny_04',
    category: 'funny',
    text: 'Если бы ты был(а) животным — кем бы ты стал(а)?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'funny_05',
    category: 'funny',
    text: 'Каким был твой самый неловкий момент в жизни?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'funny_06',
    category: 'funny',
    text: 'Что бы ты купил(а) первым делом, если бы выиграл(а) миллион?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'funny_07',
    category: 'funny',
    text: 'Ты скорее кот или собака?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'cat', text: '🐱 Кот'),
      QuizOption(id: 'dog', text: '🐶 Собака'),
    ],
  ),
  QuizQuestion(
    id: 'funny_08',
    category: 'funny',
    text: 'Какой странный факт о себе ты знаешь?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'funny_09',
    category: 'funny',
    text: 'Что ты делаешь, когда думаешь, что никто не смотрит?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'funny_10',
    category: 'funny',
    text: 'Пицца или бургер?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'pizza', text: '🍕 Пицца'),
      QuizOption(id: 'burger', text: '🍔 Бургер'),
    ],
  ),
  QuizQuestion(
    id: 'funny_11',
    category: 'funny',
    text: 'Какое прозвище тебе давали в детстве?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'funny_12',
    category: 'funny',
    text: 'Если бы твоя жизнь была сериалом — в каком жанре?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'funny_13',
    category: 'funny',
    text: 'Что ты ненавидишь делать, но всё равно делаешь?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'funny_14',
    category: 'funny',
    text: 'Ранняя пташка или ночная сова?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'early', text: '🌅 Ранняя пташка'),
      QuizOption(id: 'night', text: '🦉 Ночная сова'),
    ],
  ),

  // ── 🍕 Еда и привычки (14 вопросов) ─────────────────────────────────────

  QuizQuestion(
    id: 'food_01',
    category: 'food',
    text: 'Ты скорее сладкоежка или любишь солёное/острое?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'sweet', text: '🍰 Сладкое'),
      QuizOption(id: 'salty', text: '🧂 Солёное'),
      QuizOption(id: 'spicy', text: '🌶 Острое'),
    ],
  ),
  QuizQuestion(
    id: 'food_02',
    category: 'food',
    text: 'Что ты готовишь лучше всего?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'food_03',
    category: 'food',
    text: 'Кофе или чай утром?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'coffee', text: '☕ Кофе'),
      QuizOption(id: 'tea', text: '🍵 Чай'),
      QuizOption(id: 'neither', text: '💧 Ни то, ни другое'),
    ],
  ),
  QuizQuestion(
    id: 'food_04',
    category: 'food',
    text: 'Какое блюдо из детства ты до сих пор любишь?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'food_05',
    category: 'food',
    text: 'Ты любишь готовить или предпочитаешь, чтобы готовили для тебя?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'cook', text: '👨‍🍳 Люблю готовить'),
      QuizOption(id: 'eat', text: '🍽 Когда готовят для меня'),
      QuizOption(id: 'both', text: '😊 По-разному'),
    ],
  ),
  QuizQuestion(
    id: 'food_06',
    category: 'food',
    text: 'Есть ли продукт, который ты категорически не ешь?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'food_07',
    category: 'food',
    text: 'Ресторан или домашняя еда в уютной обстановке?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'restaurant', text: '🍽 Ресторан'),
      QuizOption(id: 'home', text: '🏠 Дома'),
    ],
  ),
  QuizQuestion(
    id: 'food_08',
    category: 'food',
    text: 'Ты ешь завтрак или пропускаешь его?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'always', text: '✅ Всегда ем'),
      QuizOption(id: 'sometimes', text: '🤷 Иногда'),
      QuizOption(id: 'skip', text: '❌ Пропускаю'),
    ],
  ),
  QuizQuestion(
    id: 'food_09',
    category: 'food',
    text: 'Какая кухня мира тебе ближе всего?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'food_10',
    category: 'food',
    text: 'Снеки ночью — это норма или грех?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'norm', text: '🌙 Норма, жизнь коротка'),
      QuizOption(id: 'sin', text: '😅 Грех, но всё равно ем'),
      QuizOption(id: 'never', text: '🧘 Никогда не ем ночью'),
    ],
  ),
  QuizQuestion(
    id: 'food_11',
    category: 'food',
    text: 'Как часто ты пьёшь воду в течение дня?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'food_12',
    category: 'food',
    text: 'Есть ли у тебя ритуал перед едой (фото блюда, молитва, что-то ещё)?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'food_13',
    category: 'food',
    text: 'Торт или мороженое?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'cake', text: '🎂 Торт'),
      QuizOption(id: 'icecream', text: '🍦 Мороженое'),
    ],
  ),
  QuizQuestion(
    id: 'food_14',
    category: 'food',
    text: 'Что ты обычно заказываешь в кафе, когда не можешь выбрать?',
    answerType: QuizAnswerType.openText,
  ),

  // ── 🏡 Быт и характер (14 вопросов) ─────────────────────────────────────

  QuizQuestion(
    id: 'life_01',
    category: 'lifestyle',
    text: 'Ты жаворонок или сова — в бытовом смысле (уборка, дела)?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'morning', text: '🌅 Делаю дела с утра'),
      QuizOption(id: 'evening', text: '🌙 Вечером активнее'),
      QuizOption(id: 'deadline', text: '⏰ По дедлайну'),
    ],
  ),
  QuizQuestion(
    id: 'life_02',
    category: 'lifestyle',
    text: 'Порядок в доме для тебя — это важно или терпимо?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'very', text: '🧹 Очень важно'),
      QuizOption(id: 'medium', text: '😌 Важно, но не сверх'),
      QuizOption(id: 'relax', text: '😎 Главное — уют, не чистота'),
    ],
  ),
  QuizQuestion(
    id: 'life_03',
    category: 'lifestyle',
    text: 'Что ты делаешь, когда устал(а) и не хочешь ничего делать?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'life_04',
    category: 'lifestyle',
    text: 'Ты привыкаешь к новому быстро или медленно?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'fast', text: '⚡ Быстро'),
      QuizOption(id: 'slow', text: '🐢 Медленно'),
      QuizOption(id: 'depends', text: '🤷 Зависит от ситуации'),
    ],
  ),
  QuizQuestion(
    id: 'life_05',
    category: 'lifestyle',
    text: 'Как ты реагируешь, когда что-то идёт не по плану?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'life_06',
    category: 'lifestyle',
    text: 'Ты скорее плановик или спонтанный(ая)?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'planner', text: '📅 Плановик'),
      QuizOption(id: 'spontaneous', text: '🎲 Спонтанный(ая)'),
      QuizOption(id: 'both', text: '🔄 По настроению'),
    ],
  ),
  QuizQuestion(
    id: 'life_07',
    category: 'lifestyle',
    text: 'Что тебе сложнее: говорить «нет» или говорить «мне нужна помощь»?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'no', text: '🚫 Говорить «нет»'),
      QuizOption(id: 'help', text: '🙋 Просить помощи'),
    ],
  ),
  QuizQuestion(
    id: 'life_08',
    category: 'lifestyle',
    text: 'Ты склонен(на) беспокоиться о будущем или живёшь настоящим?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'life_09',
    category: 'lifestyle',
    text: 'Как ты справляешься со стрессом?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'life_10',
    category: 'lifestyle',
    text: 'Ты чаще принимаешь решения сердцем или головой?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'heart', text: '❤️ Сердцем'),
      QuizOption(id: 'head', text: '🧠 Головой'),
      QuizOption(id: 'both', text: '⚖️ Стараюсь совмещать'),
    ],
  ),
  QuizQuestion(
    id: 'life_11',
    category: 'lifestyle',
    text: 'Что тебя больше утомляет: физический труд или общение с людьми?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'physical', text: '💪 Физический труд'),
      QuizOption(id: 'social', text: '👥 Социальное общение'),
      QuizOption(id: 'equal', text: '😅 Одинаково'),
    ],
  ),
  QuizQuestion(
    id: 'life_12',
    category: 'lifestyle',
    text: 'Ты легко просишь прощения или это даётся с трудом?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'life_13',
    category: 'lifestyle',
    text: 'Какая черта характера в тебе самая сильная?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'life_14',
    category: 'lifestyle',
    text: 'Что тебя могло бы вывести из себя дома?',
    answerType: QuizAnswerType.openText,
  ),

  // ── ✈️ Мечты и планы (14 вопросов) ───────────────────────────────────────

  QuizQuestion(
    id: 'dreams_01',
    category: 'dreams',
    text: 'Какая страна у тебя в топе списка для путешествий?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'dreams_02',
    category: 'dreams',
    text: 'Где ты видишь себя через 5 лет?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'dreams_03',
    category: 'dreams',
    text: 'Есть ли у тебя мечта, которую ты ещё не осуществил(а)?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'dreams_04',
    category: 'dreams',
    text: 'Ты хочешь жить в городе или за городом в будущем?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'city', text: '🏙 В городе'),
      QuizOption(id: 'suburbs', text: '🏡 За городом'),
      QuizOption(id: 'both', text: '🔄 Иметь оба варианта'),
    ],
  ),
  QuizQuestion(
    id: 'dreams_05',
    category: 'dreams',
    text: 'Ты когда-нибудь хотел(а) сменить профессию? На что?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'dreams_06',
    category: 'dreams',
    text: 'Хочешь ли ты открыть своё дело когда-нибудь?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'yes', text: '✅ Да, это мечта'),
      QuizOption(id: 'maybe', text: '🤔 Думаю об этом'),
      QuizOption(id: 'no', text: '❌ Нет, не для меня'),
    ],
  ),
  QuizQuestion(
    id: 'dreams_07',
    category: 'dreams',
    text: 'Что из детских мечт ты всё ещё хочешь осуществить?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'dreams_08',
    category: 'dreams',
    text: 'Какое приключение ты хотел(а) бы пережить вместе со мной?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'dreams_09',
    category: 'dreams',
    text: 'Ты хочешь детей? Сколько?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'dreams_10',
    category: 'dreams',
    text: 'Если бы деньги не были проблемой — как бы ты провёл(а) год жизни?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'dreams_11',
    category: 'dreams',
    text: 'Какой навык ты мечтаешь освоить?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'dreams_12',
    category: 'dreams',
    text: 'Хочешь ли ты когда-нибудь переехать в другую страну?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'yes', text: '✈️ Да, хочу'),
      QuizOption(id: 'maybe', text: '🌐 Возможно'),
      QuizOption(id: 'no', text: '🏠 Нет, здесь мой дом'),
    ],
  ),
  QuizQuestion(
    id: 'dreams_13',
    category: 'dreams',
    text: 'Что бы ты хотел(а) успеть до 40 лет?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'dreams_14',
    category: 'dreams',
    text: 'Есть ли что-то, чего ты ждёшь прямо сейчас с нетерпением?',
    answerType: QuizAnswerType.openText,
  ),

  // ── 🔥 Романтика (14 вопросов) ───────────────────────────────────────────

  QuizQuestion(
    id: 'romance_01',
    category: 'romance',
    text: 'Что для тебя идеальное свидание?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'romance_02',
    category: 'romance',
    text: 'Какой жест любви тебе говорит «я думаю о тебе»?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'romance_03',
    category: 'romance',
    text: 'Какой язык любви ближе тебе?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'words', text: '💬 Слова признания'),
      QuizOption(id: 'touch', text: '🤗 Прикосновения'),
      QuizOption(id: 'gifts', text: '🎁 Подарки'),
      QuizOption(id: 'service', text: '🛠 Помощь делом'),
      QuizOption(id: 'time', text: '⏱ Время вместе'),
    ],
  ),
  QuizQuestion(
    id: 'romance_04',
    category: 'romance',
    text: 'Что тебя удивило бы приятно в отношениях?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'romance_05',
    category: 'romance',
    text: 'Ты скорее тот, кто инициирует встречи, или ждёшь инициативы?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'initiates', text: '🚀 Инициирую сам(а)'),
      QuizOption(id: 'waits', text: '🌸 Жду инициативы'),
      QuizOption(id: 'depends', text: '🔄 По-разному'),
    ],
  ),
  QuizQuestion(
    id: 'romance_06',
    category: 'romance',
    text: 'Какой момент в наших отношениях ты вспоминаешь с улыбкой?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'romance_07',
    category: 'romance',
    text: 'Что для тебя важнее в паре: общие интересы или взаимное уважение?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'interests', text: '🎯 Общие интересы'),
      QuizOption(id: 'respect', text: '🙏 Взаимное уважение'),
      QuizOption(id: 'both', text: '💞 Оба одинаково'),
    ],
  ),
  QuizQuestion(
    id: 'romance_08',
    category: 'romance',
    text: 'Каким комплиментом ты особенно дорожишь?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'romance_09',
    category: 'romance',
    text: 'Что для тебя значит «чувствовать себя любимым(ой)»?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'romance_10',
    category: 'romance',
    text: 'Ты любишь сюрпризы или лучше знать заранее?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'surprise', text: '🎉 Люблю сюрпризы'),
      QuizOption(id: 'plan', text: '📋 Лучше знать заранее'),
    ],
  ),
  QuizQuestion(
    id: 'romance_11',
    category: 'romance',
    text: 'Как ты понимаешь, что влюбился(лась)?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'romance_12',
    category: 'romance',
    text: 'Что для тебя самое сложное в отношениях?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'romance_13',
    category: 'romance',
    text: 'Какой маленький знак внимания делает твой день лучше?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'romance_14',
    category: 'romance',
    text: 'Хочешь ли ты, чтобы мы делали что-то новое вместе чаще?',
    answerType: QuizAnswerType.openText,
  ),

  // ── 🔞 Близость 18+ (30 вопросов) ────────────────────────────────────────

  QuizQuestion(
    id: 'int_01',
    category: 'intimate',
    text: 'Что в близости помогает тебе чувствовать себя желанным(ой)?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'int_02',
    category: 'intimate',
    text: 'Какой комплимент в интимный момент тебе особенно приятно слышать?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'int_03',
    category: 'intimate',
    text: 'Что для тебя важнее: спонтанность или атмосфера?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'spontaneous', text: '⚡ Спонтанность'),
      QuizOption(id: 'atmosphere', text: '🕯 Атмосфера'),
      QuizOption(id: 'both', text: '💫 Люблю оба варианта'),
    ],
  ),
  QuizQuestion(
    id: 'int_04',
    category: 'intimate',
    text: 'Какая форма нежности быстрее всего сближает тебя с партнёром?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'int_05',
    category: 'intimate',
    text: 'О чём тебе хотелось бы говорить честнее, но без давления?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'int_06',
    category: 'intimate',
    text: 'Какая граница для тебя важна, чтобы чувствовать себя спокойно?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'int_07',
    category: 'intimate',
    text: 'Что из романтики для тебя плавно переходит в желание?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'int_08',
    category: 'intimate',
    text: 'Какой вечер для тебя был бы идеальным продолжением свидания?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'int_09',
    category: 'intimate',
    text: 'Что помогает тебе расслабиться и быть ближе?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'int_10',
    category: 'intimate',
    text: 'Что тебе хотелось бы попробовать, если оба чувствуют себя комфортно?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'int_11',
    category: 'intimate',
    text: 'Какое время суток ты предпочитаешь для близости?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'morning', text: '🌅 Утро'),
      QuizOption(id: 'day', text: '☀️ День'),
      QuizOption(id: 'evening', text: '🌇 Вечер'),
      QuizOption(id: 'night', text: '🌙 Поздняя ночь'),
    ],
  ),
  QuizQuestion(
    id: 'int_12',
    category: 'intimate',
    text: 'Что для тебя важнее: инициатива партнёра или взаимная атмосфера?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'initiative', text: '🙌 Инициатива партнёра'),
      QuizOption(id: 'atmosphere', text: '🕯 Общая атмосфера'),
      QuizOption(id: 'both', text: '❤️ Оба равно важны'),
    ],
  ),
  QuizQuestion(
    id: 'int_13',
    category: 'intimate',
    text: 'Как ты понимаешь, что партнёр рядом и это твоё безопасное пространство?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'int_14',
    category: 'intimate',
    text: 'Что для тебя означает «быть уязвимым(ой)» с партнёром?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'int_15',
    category: 'intimate',
    text: 'Ты предпочитаешь нежность или страсть — или это зависит от момента?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'tender', text: '🌸 Нежность'),
      QuizOption(id: 'passion', text: '🔥 Страсть'),
      QuizOption(id: 'moment', text: '🔄 Зависит от момента'),
    ],
  ),
  QuizQuestion(
    id: 'int_16',
    category: 'intimate',
    text: 'Какой жест партнёра делает тебя счастливее даже вне близости?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'int_17',
    category: 'intimate',
    text: 'Что для тебя важнее в интимной жизни пары: частота или качество?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'frequency', text: '📆 Частота'),
      QuizOption(id: 'quality', text: '✨ Качество'),
      QuizOption(id: 'both', text: '💞 Хочу и то, и то'),
    ],
  ),
  QuizQuestion(
    id: 'int_18',
    category: 'intimate',
    text: 'Есть ли что-то, о чём тебе трудно говорить вслух, но ты хотел(а) бы, чтобы партнёр знал?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'int_19',
    category: 'intimate',
    text: 'Что для тебя является знаком, что партнёр чувствует себя комфортно рядом?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'int_20',
    category: 'intimate',
    text: 'Как ты показываешь, что хочешь близости, когда сложно сказать об этом прямо?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'int_21',
    category: 'intimate',
    text: 'Что тебе помогает открыться и не бояться осуждения?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'int_22',
    category: 'intimate',
    text: 'Объятия после близости — это обязательно или по настроению?',
    answerType: QuizAnswerType.choice,
    options: [
      QuizOption(id: 'always', text: '🤗 Всегда обязательно'),
      QuizOption(id: 'mood', text: '🌊 По настроению'),
      QuizOption(id: 'rare', text: '🧘 Мне нужно пространство'),
    ],
  ),
  QuizQuestion(
    id: 'int_23',
    category: 'intimate',
    text: 'Что для тебя значит чувствовать эмоциональную близость с партнёром?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'int_24',
    category: 'intimate',
    text: 'Есть ли что-то в физической близости, что для тебя категорически некомфортно?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'int_25',
    category: 'intimate',
    text: 'Что для тебя делает момент близости по-настоящему особенным?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'int_26',
    category: 'intimate',
    text: 'Как ты реагируешь, когда партнёр говорит «нет» — как воспринимаешь это?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'int_27',
    category: 'intimate',
    text: 'Есть ли у тебя фантазия, которую ты пока не решался(лась) озвучить?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'int_28',
    category: 'intimate',
    text: 'Что ты чувствуешь в момент, когда партнёр доверяет тебе полностью?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'int_29',
    category: 'intimate',
    text: 'Как ты думаешь, как мы могли бы стать ещё ближе?',
    answerType: QuizAnswerType.openText,
  ),
  QuizQuestion(
    id: 'int_30',
    category: 'intimate',
    text: 'Есть ли что-то, что ты хотел(а) бы делать вместе чаще, но не говорил(а)?',
    answerType: QuizAnswerType.openText,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Все вопросы для данной категории.
List<QuizQuestion> questionsForCategory(String categoryId) {
  if (categoryId == 'random') {
    // Случайный — из всех категорий кроме intimate и random.
    final pool = kQuizQuestions
        .where((q) => q.category != 'intimate' && q.category != 'random')
        .toList();
    pool.shuffle();
    return pool;
  }
  return kQuizQuestions.where((q) => q.category == categoryId).toList();
}

/// Один случайный вопрос из категории.
QuizQuestion? randomQuestionFromCategory(String categoryId,
    {Set<String>? excludeIds}) {
  final list = questionsForCategory(categoryId)
      .where((q) => excludeIds == null || !excludeIds.contains(q.id))
      .toList();
  if (list.isEmpty) return null;
  list.shuffle();
  return list.first;
}
