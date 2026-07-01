import '../models/activity_idea.dart';

/// Встроенный список идей для пары.
/// 152 идеи, 11 категорий.
const List<ActivityIdea> kBuiltinActivityIdeas = [
  // ── ДОМА ──────────────────────────────────────────────────────────────────

  ActivityIdea(
    id: 'home_001',
    title: 'Мини-кинотеатр дома',
    description:
        'Устройте настоящий кинотеатр: задёрните шторы, разложите подушки и пледы, приготовьте попкорн. Каждый выбирает один фильм — смотрите оба.',
    emoji: '🎬',
    categories: ['дома', 'уют'],
    durationMinutes: 180,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.cozy,
  ),

  ActivityIdea(
    id: 'home_002',
    title: 'Приготовьте ужин из 3 случайных ингредиентов',
    description:
        'Закройте глаза и вытащите три продукта из холодильника или шкафа. Приготовьте из них что-нибудь вместе — без рецепта. Удивите себя.',
    emoji: '🍳',
    categories: ['дома', 'еда', 'весело'],
    durationMinutes: 60,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'home_003',
    title: 'Настольные игры при свечах',
    description:
        'Выберите любую настольную игру и сыграйте при свечах. Шахматы, карты, домино — неважно. Атмосфера решает.',
    emoji: '🕯️',
    categories: ['дома', 'уют'],
    durationMinutes: 90,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.cozy,
  ),

  ActivityIdea(
    id: 'home_004',
    title: 'Рисуйте портреты друг друга',
    description:
        'Возьмите бумагу и что найдёте — карандаши, ручки, акварель. Нарисуйте партнёра за 10 минут не отрывая руки. Потом сравните.',
    emoji: '🎨',
    categories: ['дома', 'весело'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'home_005',
    title: 'Напишите друг другу 5 вещей, за которые благодарны',
    description:
        'Каждый пишет на бумаге 5 вещей, которые ценит в партнёре прямо сейчас. Обменяйтесь и прочитайте вслух.',
    emoji: '💌',
    categories: ['дома', 'романтика', 'глубокие разговоры'],
    durationMinutes: 20,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'home_006',
    title: 'Совместная готовка нового рецепта',
    description:
        'Найдите рецепт блюда, которое никогда не готовили, и приготовьте его вместе от начала до конца. Разделите роли: один режет, другой мешает.',
    emoji: '👨‍🍳',
    categories: ['дома', 'еда'],
    durationMinutes: 90,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'home_007',
    title: 'Составьте общий wishlist на этот год',
    description:
        'Каждый называет 5 вещей, которые хочет сделать или получить в этом году. Обсудите, что из этого можно сделать вместе.',
    emoji: '📝',
    categories: ['дома', 'глубокие разговоры'],
    durationMinutes: 40,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'home_008',
    title: 'Вечер масок и ухода',
    description:
        'Нанесите маски для лица, сделайте друг другу массаж рук, включите расслабляющую музыку. Никаких телефонов.',
    emoji: '🧖',
    categories: ['дома', 'уют', 'романтика'],
    durationMinutes: 60,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.calm,
  ),

  ActivityIdea(
    id: 'home_009',
    title: 'Танцы на кухне',
    description:
        'Включите музыку и танцуйте прямо на кухне — без правил и без стеснения. Можно выбрать по очереди по треку.',
    emoji: '💃',
    categories: ['дома', 'весело'],
    durationMinutes: 20,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'home_010',
    title: 'Пицца с нуля',
    description:
        'Замесите тесто, выберите начинку и испеките пиццу самостоятельно. Каждый делает свою половину.',
    emoji: '🍕',
    categories: ['дома', 'еда'],
    durationMinutes: 90,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'home_011',
    title: 'Посмотрите детский мультфильм',
    description:
        'Включите любимый мультфильм из детства — своего или партнёра. Расскажите, что он значил для вас.',
    emoji: '🧸',
    categories: ['дома', 'уют'],
    durationMinutes: 90,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.cozy,
  ),

  ActivityIdea(
    id: 'home_012',
    title: 'Кулинарный челлендж',
    description:
        'Каждый готовит что-то одно самостоятельно, не показывая другому. Потом — дегустация и честная оценка.',
    emoji: '🏆',
    categories: ['дома', 'еда', 'весело'],
    durationMinutes: 60,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'home_013',
    title: 'Читайте вслух друг другу',
    description:
        'Возьмите книгу, которую давно хотели прочитать, и читайте по очереди вслух. Останавливайтесь и обсуждайте.',
    emoji: '📚',
    categories: ['дома', 'уют', 'глубокие разговоры'],
    durationMinutes: 60,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.cozy,
  ),

  ActivityIdea(
    id: 'home_014',
    title: 'Сборка пазла',
    description:
        'Найдите пазл или купите новый. Собирайте вместе — можно под музыку или сериал. Хороший способ просто побыть рядом.',
    emoji: '🧩',
    categories: ['дома', 'уют'],
    durationMinutes: 120,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.calm,
  ),

  ActivityIdea(
    id: 'home_015',
    title: 'Вечер настойных коктейлей без алкоголя',
    description:
        'Сделайте моктейли из того, что есть: сок, газировка, мята, лимон, ягоды. Украсьте красиво и придумайте название каждому.',
    emoji: '🍹',
    categories: ['дома', 'еда', 'уют'],
    durationMinutes: 40,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.fun,
  ),

  // ── ПРОГУЛКА ─────────────────────────────────────────────────────────────

  ActivityIdea(
    id: 'walk_001',
    title: 'Прогулка без телефонов',
    description:
        'Оставьте телефоны дома. 30–40 минут идите куда хотите и разговаривайте. Без навигатора, без музыки, без соцсетей.',
    emoji: '🚶',
    categories: ['прогулка', 'глубокие разговоры', 'бесплатно'],
    durationMinutes: 40,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.calm,
  ),

  ActivityIdea(
    id: 'walk_002',
    title: 'Фото-прогулка: ищите красивые детали',
    description:
        'У каждого задание: найти 5 красивых или необычных деталей вокруг и сфотографировать. Потом сравните — что заметил каждый.',
    emoji: '📸',
    categories: ['прогулка', 'новые впечатления'],
    durationMinutes: 60,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'walk_003',
    title: 'Сходите в место, где давно не были',
    description:
        'Вспомните место в городе, которое любили раньше, но забыли. Парк, набережная, старая улица. Вернитесь и поделитесь воспоминаниями.',
    emoji: '🗺️',
    categories: ['прогулка', 'новые впечатления', 'глубокие разговоры'],
    durationMinutes: 90,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'walk_004',
    title: 'Прогулка до рассвета или заката',
    description:
        'Выйдите специально посмотреть на закат или рассвет. Найдите место с хорошим видом — крышу, парк, набережную.',
    emoji: '🌅',
    categories: ['прогулка', 'романтика'],
    durationMinutes: 60,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.romantic,
  ),

  ActivityIdea(
    id: 'walk_005',
    title: 'Поездка в незнакомый район',
    description:
        'Выберите район города, где почти не бывали. Дойдите пешком и исследуйте без плана — заходите в магазины, кафе, дворы.',
    emoji: '🏙️',
    categories: ['прогулка', 'новые впечатления'],
    durationMinutes: 120,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.spontaneous,
  ),

  ActivityIdea(
    id: 'walk_006',
    title: 'Найдите уличное граффити',
    description:
        'Погуляйте по улицам и ищите интересные граффити или стрит-арт. Фотографируйте лучшее и обсуждайте.',
    emoji: '🎭',
    categories: ['прогулка', 'новые впечатления', 'бесплатно'],
    durationMinutes: 60,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'walk_007',
    title: 'Прогулка под дождём',
    description:
        'Если идёт дождь — выйдите под него. Возьмите один зонт на двоих или наденьте дождевики. Иногда это лучшая прогулка.',
    emoji: '🌧️',
    categories: ['прогулка', 'романтика', 'спонтанно'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.romantic,
  ),

  ActivityIdea(
    id: 'walk_008',
    title: 'Утренняя прогулка с кофе',
    description:
        'Встаньте пораньше, возьмите кофе в термосах и пройдитесь по просыпающемуся городу. Тишина и пространство — только ваши.',
    emoji: '☕',
    categories: ['прогулка', 'уют'],
    durationMinutes: 60,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.calm,
  ),

  ActivityIdea(
    id: 'walk_009',
    title: 'Пикник в парке',
    description:
        'Соберите простые вещи: бутерброды, фрукты, плед. Найдите дерево или траву в парке и проведите час без спешки.',
    emoji: '🧺',
    categories: ['прогулка', 'еда', 'романтика'],
    durationMinutes: 90,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.romantic,
  ),

  ActivityIdea(
    id: 'walk_010',
    title: 'Посетите рынок или ярмарку',
    description:
        'Пройдитесь по местному рынку — не чтобы купить, а чтобы смотреть, пробовать, общаться. Купите одну вещь, которую выберет партнёр.',
    emoji: '🛍️',
    categories: ['прогулка', 'новые впечатления'],
    durationMinutes: 90,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'walk_011',
    title: 'Покорите ближайшую возвышенность',
    description:
        'Найдите холм, горку или смотровую площадку рядом с вами. Поднимитесь и посмотрите на город или природу сверху.',
    emoji: '⛰️',
    categories: ['прогулка', 'новые впечатления'],
    durationMinutes: 90,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.spontaneous,
  ),

  ActivityIdea(
    id: 'walk_012',
    title: 'Пройдите маршрут наугад',
    description:
        'На каждом перекрёстке подбросьте монетку: орёл — налево, решка — направо. Идите, куда приведёт случай.',
    emoji: '🪙',
    categories: ['прогулка', 'спонтанно', 'бесплатно'],
    durationMinutes: 60,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.spontaneous,
  ),

  ActivityIdea(
    id: 'walk_013',
    title: 'Прогулка с музыкой в одном наушнике',
    description:
        'Один наушник у каждого. Слушайте одну и ту же музыку и идите рядом. Попробуйте молчать и просто быть рядом.',
    emoji: '🎵',
    categories: ['прогулка', 'уют', 'романтика'],
    durationMinutes: 40,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.calm,
  ),

  // ── ЕДА ──────────────────────────────────────────────────────────────────

  ActivityIdea(
    id: 'food_001',
    title: 'Блюдо из страны мечты',
    description:
        'Выберите страну, куда хотите попасть. Найдите рецепт традиционного блюда оттуда и приготовьте вместе. Включите музыку из той страны.',
    emoji: '🌍',
    categories: ['еда', 'дома', 'новые впечатления'],
    durationMinutes: 90,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'food_002',
    title: 'Завтрак в постель',
    description:
        'Один встаёт пораньше и готовит завтрак другому в постель. На следующий раз — меняетесь ролями.',
    emoji: '🥞',
    categories: ['еда', 'дома', 'романтика', 'сюрприз'],
    durationMinutes: 30,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.romantic,
  ),

  ActivityIdea(
    id: 'food_003',
    title: 'Дегустация нового чая или кофе',
    description:
        'Купите два-три сорта чая или кофе, которые никогда не пробовали. Заварите по очереди и оцените по шкале от 1 до 10.',
    emoji: '🍵',
    categories: ['еда', 'дома', 'уют'],
    durationMinutes: 40,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.calm,
  ),

  ActivityIdea(
    id: 'food_004',
    title: 'Тематический ужин',
    description:
        'Выберите тему: страна, эпоха, цвет. Все блюда — в рамках темы. Украсьте стол соответственно.',
    emoji: '🍽️',
    categories: ['еда', 'дома', 'романтика'],
    durationMinutes: 120,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.romantic,
  ),

  ActivityIdea(
    id: 'food_005',
    title: 'Суши дома',
    description:
        'Купите набор для суши или нужные ингредиенты. Попробуйте свернуть роллы самостоятельно — получится смешно, но вкусно.',
    emoji: '🍱',
    categories: ['еда', 'дома', 'весело'],
    durationMinutes: 90,
    budget: ActivityBudget.medium,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'food_006',
    title: 'Выпечка без рецепта',
    description:
        'Испеките что-нибудь, не используя рецепт — только интуицию. Кекс, печенье, хлеб. Посмотрите, что получится.',
    emoji: '🍪',
    categories: ['еда', 'дома', 'весело'],
    durationMinutes: 60,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'food_007',
    title: 'Зайдите в кафе, где никогда не были',
    description:
        'Выберите кафе, мимо которого проходили, но никогда не заходили. Закажите что-то незнакомое из меню.',
    emoji: '☕',
    categories: ['еда', 'новые впечатления', 'прогулка'],
    durationMinutes: 60,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.calm,
  ),

  ActivityIdea(
    id: 'food_008',
    title: 'Слепая дегустация',
    description:
        'Один готовит или покупает несколько закусок. Другой с закрытыми глазами угадывает, что ест. Потом меняетесь.',
    emoji: '🙈',
    categories: ['еда', 'дома', 'весело'],
    durationMinutes: 30,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'food_009',
    title: 'Приготовьте любимое блюдо детства',
    description:
        'Каждый называет блюдо из детства, которое любил. Выберите одно и приготовьте вместе. Поговорите о детских воспоминаниях.',
    emoji: '🍲',
    categories: ['еда', 'дома', 'глубокие разговоры'],
    durationMinutes: 60,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'food_010',
    title: 'Ужин при свечах дома',
    description:
        'Приготовьте простой ужин, накройте стол красиво, зажгите свечи. Уберите телефоны и просто поговорите за едой.',
    emoji: '🕯️',
    categories: ['еда', 'дома', 'романтика'],
    durationMinutes: 90,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.romantic,
  ),

  ActivityIdea(
    id: 'food_011',
    title: 'Приготовьте завтрак в необычном месте',
    description:
        'Возьмите термос и простые продукты. Съешьте завтрак не дома — в парке, на крыше, на ступеньках.',
    emoji: '🌄',
    categories: ['еда', 'прогулка', 'новые впечатления'],
    durationMinutes: 60,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.spontaneous,
  ),

  ActivityIdea(
    id: 'food_012',
    title: 'Испеките торт на чей-то день рождения заранее',
    description:
        'Не ждите особого повода. Испеките торт просто так — раскрасьте его, придумайте ему название и съешьте вместе.',
    emoji: '🎂',
    categories: ['еда', 'дома', 'сюрприз'],
    durationMinutes: 120,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.fun,
  ),

  // ── РАЗГОВОР ─────────────────────────────────────────────────────────────

  ActivityIdea(
    id: 'talk_001',
    title: 'Вечер вопросов',
    description:
        'По очереди задавайте вопросы друг другу — честно и без осуждения. Начните с простых, заканчивайте глубокими.',
    emoji: '💬',
    categories: ['разговор', 'глубокие разговоры'],
    durationMinutes: 60,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'talk_002',
    title: 'Каждый выбирает песню и объясняет почему',
    description:
        'Выберите по одной песне, которая что-то значит лично для вас. Включите и расскажите, с чем она связана.',
    emoji: '🎶',
    categories: ['разговор', 'глубокие разговоры', 'дома'],
    durationMinutes: 40,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'talk_003',
    title: 'Расскажите историю из детства, которую не рассказывали',
    description:
        'Каждый вспоминает историю из детства, которую ещё не рассказывал партнёру. Чем неожиданнее — тем лучше.',
    emoji: '🧒',
    categories: ['разговор', 'глубокие разговоры'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'talk_004',
    title: 'Игра "Что бы вы сделали, если..."',
    description:
        'По очереди придумывайте гипотетические ситуации и отвечайте честно. Не ограничивайтесь реальным.',
    emoji: '🤔',
    categories: ['разговор', 'дома'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'talk_005',
    title: 'Список мест, куда хотите попасть вместе',
    description:
        'Назовите по 5 мест в мире (и рядом), куда хотите поехать вместе. Отметьте на карте и выберите следующий приоритет.',
    emoji: '✈️',
    categories: ['разговор', 'глубокие разговоры'],
    durationMinutes: 40,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'talk_006',
    title: 'Что изменилось за последний год?',
    description:
        'Поговорите о том, что в каждом из вас изменилось за последние 12 месяцев. Без оценок, просто — что стало другим.',
    emoji: '🌱',
    categories: ['разговор', 'глубокие разговоры'],
    durationMinutes: 45,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'talk_007',
    title: 'Расскажите о своём идеальном дне',
    description:
        'Каждый описывает свой идеальный день от пробуждения до сна. Без ограничений — где угодно, с кем угодно, делая что угодно.',
    emoji: '🌞',
    categories: ['разговор', 'глубокие разговоры'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.calm,
  ),

  ActivityIdea(
    id: 'talk_008',
    title: 'Игра в "правда"',
    description:
        'Задавайте друг другу любые вопросы — партнёр обязан ответить честно. Начните мягко, потом углубляйтесь.',
    emoji: '🎯',
    categories: ['разговор', 'глубокие разговоры'],
    durationMinutes: 40,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'talk_009',
    title: 'Обсудите фильм, который видели по-разному',
    description:
        'Вспомните фильм, который видели оба, но реакции были разными. Поговорите, почему это так — что зацепило каждого.',
    emoji: '🎞️',
    categories: ['разговор', 'дома'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'talk_010',
    title: 'Поговорите о страхах',
    description:
        'Каждый называет три вещи, которых боится — маленьких или больших. Не нужно решать или советовать. Просто слушайте.',
    emoji: '🌙',
    categories: ['разговор', 'глубокие разговоры'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'talk_011',
    title: 'Что сейчас тебя радует?',
    description:
        'Каждый называет три вещи, которые делают его счастливым прямо сейчас — большие и маленькие. Поговорите об этом.',
    emoji: '😊',
    categories: ['разговор', 'глубокие разговоры'],
    durationMinutes: 20,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.calm,
  ),

  ActivityIdea(
    id: 'talk_012',
    title: 'Письмо себе через 5 лет',
    description:
        'Каждый пишет короткое письмо себе через 5 лет. Запечатайте в конверт, подпишите дату и спрячьте вместе.',
    emoji: '📬',
    categories: ['разговор', 'глубокие разговоры', 'дома'],
    durationMinutes: 40,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.deep,
    preparation: 'Нужны бумага, ручки и конверты.',
  ),

  ActivityIdea(
    id: 'talk_013',
    title: 'Поговорите о ваших ролевых моделях',
    description:
        'Кем вы восхищаетесь — реальными людьми или героями? Расскажите партнёру и объясните почему.',
    emoji: '⭐',
    categories: ['разговор', 'глубокие разговоры'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.deep,
  ),

  // ── СЮРПРИЗ ───────────────────────────────────────────────────────────────

  ActivityIdea(
    id: 'surprise_001',
    title: 'Организуйте неожиданный пикник',
    description:
        'Пока партнёр занят чем-то, соберите простую корзину с едой и позовите его на пикник — прямо сейчас. Никакой подготовки заранее.',
    emoji: '🎁',
    categories: ['сюрприз', 'романтика', 'прогулка'],
    durationMinutes: 90,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.romantic,
  ),

  ActivityIdea(
    id: 'surprise_002',
    title: 'Записка в неожиданном месте',
    description:
        'Напишите тёплую записку партнёру и спрячьте в неожиданном месте — в кошельке, в книге, в кармане пальто.',
    emoji: '💝',
    categories: ['сюрприз', 'романтика'],
    durationMinutes: 10,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.romantic,
  ),

  ActivityIdea(
    id: 'surprise_003',
    title: 'Сделайте что-то, о чём партнёр давно просил',
    description:
        'Вспомните одну просьбу партнёра, которую откладывали. Сделайте её сегодня без напоминания.',
    emoji: '✨',
    categories: ['сюрприз', 'глубокие разговоры'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'surprise_004',
    title: 'Устройте тематический вечер без предупреждения',
    description:
        'Один готовит вечер на тему (страна, декада, фильм) — украшает, готовит еду, подбирает музыку. Другой узнаёт только когда приходит домой.',
    emoji: '🪄',
    categories: ['сюрприз', 'романтика', 'дома'],
    durationMinutes: 120,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.romantic,
    preparation: 'Один партнёр готовит заранее.',
  ),

  ActivityIdea(
    id: 'surprise_005',
    title: 'Соберите коллаж из ваших фото',
    description:
        'Выберите 10–15 совместных фото и соберите их в коллаж или мини-фотокнигу. Подарите партнёру.',
    emoji: '🖼️',
    categories: ['сюрприз', 'романтика', 'дома'],
    durationMinutes: 60,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.romantic,
  ),

  ActivityIdea(
    id: 'surprise_006',
    title: 'Закажите доставку из любимого места партнёра',
    description:
        'Узнайте у партнёра (или помните), откуда он любит еду больше всего. Закажите туда без повода.',
    emoji: '🛵',
    categories: ['сюрприз', 'еда'],
    durationMinutes: 45,
    budget: ActivityBudget.medium,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'surprise_007',
    title: 'Стикеры по всему дому',
    description:
        'Пока партнёр спит или выходил, расклейте по дому стикеры с добрыми словами, смешными рисунками и воспоминаниями.',
    emoji: '🗒️',
    categories: ['сюрприз', 'романтика', 'дома'],
    durationMinutes: 20,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.romantic,
    preparation: 'Нужны стикеры и маркер.',
  ),

  ActivityIdea(
    id: 'surprise_008',
    title: 'Подарите партнёру "час без обязанностей"',
    description:
        'Скажите партнёру: у него есть час, когда вы всё делаете сами. Он может читать, гулять, спать — что хочет. Без вопросов.',
    emoji: '⏰',
    categories: ['сюрприз', 'глубокие разговоры'],
    durationMinutes: 60,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.calm,
  ),

  // ── БЕСПЛАТНО ─────────────────────────────────────────────────────────────

  ActivityIdea(
    id: 'free_001',
    title: 'Смотрите на звёзды',
    description:
        'Найдите место потемнее, возьмите плед и лягте смотреть на небо. Просто так, без цели.',
    emoji: '⭐',
    categories: ['бесплатно', 'романтика', 'прогулка'],
    durationMinutes: 60,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.romantic,
  ),

  ActivityIdea(
    id: 'free_002',
    title: 'Посетите бесплатный музей или галерею',
    description:
        'Многие музеи имеют бесплатные часы или дни. Найдите такой в вашем городе и сходите.',
    emoji: '🏛️',
    categories: ['бесплатно', 'новые впечатления', 'прогулка'],
    durationMinutes: 120,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.calm,
  ),

  ActivityIdea(
    id: 'free_003',
    title: 'Разберите старые фото вместе',
    description:
        'Откройте архивы телефона или старые альбомы. Смотрите вместе и рассказывайте истории за каждым фото.',
    emoji: '📷',
    categories: ['бесплатно', 'дома', 'глубокие разговоры'],
    durationMinutes: 60,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'free_004',
    title: 'Сделайте упражнения вместе',
    description:
        'Короткая совместная тренировка дома или на улице. YouTube-ролик, бег или просто растяжка. Главное — вместе.',
    emoji: '🏃',
    categories: ['бесплатно', 'дома', 'прогулка'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'free_005',
    title: 'Помедитируйте вместе',
    description:
        'Найдите медитацию на YouTube или в приложении. 10–15 минут тишины рядом — это больше, чем кажется.',
    emoji: '🧘',
    categories: ['бесплатно', 'дома', 'уют'],
    durationMinutes: 15,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.calm,
  ),

  ActivityIdea(
    id: 'free_006',
    title: 'Посмотрите закат на крыше или возвышенности',
    description:
        'Найдите место с видом. Возьмите плед или куртки. Молчите и смотрите.',
    emoji: '🌇',
    categories: ['бесплатно', 'романтика', 'прогулка'],
    durationMinutes: 60,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.romantic,
  ),

  ActivityIdea(
    id: 'free_007',
    title: 'Напишите совместную историю',
    description:
        'Один пишет первый абзац, другой — следующий. Без плана, просто по очереди. Посмотрите, что получится.',
    emoji: '✍️',
    categories: ['бесплатно', 'дома', 'весело'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'free_008',
    title: 'Научите друг друга чему-нибудь',
    description:
        'Каждый выбирает что-то, что умеет, но партнёр — нет. По 10–15 минут на каждого: учите и учитесь.',
    emoji: '🎓',
    categories: ['бесплатно', 'дома', 'разговор'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'free_009',
    title: 'Запустите бумажные кораблики',
    description:
        'Сделайте бумажные кораблики и запустите в ближайшей луже, фонтане или ручье. Детское и приятное.',
    emoji: '⛵',
    categories: ['бесплатно', 'прогулка', 'весело'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'free_010',
    title: 'Составьте плейлист вместе',
    description:
        'По очереди добавляйте треки в общий плейлист. По одному. Без объяснений — просто музыка. Потом послушайте.',
    emoji: '🎧',
    categories: ['бесплатно', 'дома'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.calm,
  ),

  // ── БЫСТРО ────────────────────────────────────────────────────────────────

  ActivityIdea(
    id: 'quick_001',
    title: 'Обнимитесь на 30 секунд без движения',
    description:
        'Встаньте и обнимитесь на ровно 30 секунд. Без слов, без телефона, без движения. Просто побудьте рядом.',
    emoji: '🤗',
    categories: ['быстро', 'романтика'],
    durationMinutes: 5,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.romantic,
  ),

  ActivityIdea(
    id: 'quick_002',
    title: 'Назовите по 3 комплимента',
    description:
        'Каждый называет другому 3 конкретных комплимента прямо сейчас. Не общих, а именно сегодняшних.',
    emoji: '💐',
    categories: ['быстро', 'романтика', 'разговор'],
    durationMinutes: 10,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.romantic,
  ),

  ActivityIdea(
    id: 'quick_003',
    title: 'Минута смешных фото',
    description:
        'У вас есть 1 минута и телефон. Сделайте как можно больше смешных фото друг друга.',
    emoji: '🤳',
    categories: ['быстро', 'весело'],
    durationMinutes: 5,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'quick_004',
    title: 'Угадайте мысль партнёра',
    description:
        'Каждый пишет на бумаге, о чём думает прямо сейчас. Потом угадывайте. Открывайте и сравнивайте.',
    emoji: '🔮',
    categories: ['быстро', 'разговор'],
    durationMinutes: 10,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'quick_005',
    title: 'Быстрый рисунок друг друга',
    description:
        'Возьмите бумагу. 2 минуты — рисуете партнёра. Нельзя смотреть на лист, только на человека.',
    emoji: '🖊️',
    categories: ['быстро', 'весело', 'дома'],
    durationMinutes: 10,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'quick_006',
    title: 'Скажите одно слово, которое описывает этот день',
    description:
        'Каждый произносит одно слово про сегодняшний день. Потом объясняет, почему именно оно.',
    emoji: '💭',
    categories: ['быстро', 'разговор'],
    durationMinutes: 10,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.calm,
  ),

  ActivityIdea(
    id: 'quick_007',
    title: 'Спонтанная прогулка на 20 минут',
    description:
        'Оденьтесь и выйдите прямо сейчас. Куда угодно. 20 минут.',
    emoji: '🌬️',
    categories: ['быстро', 'прогулка', 'спонтанно', 'бесплатно'],
    durationMinutes: 20,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.spontaneous,
  ),

  ActivityIdea(
    id: 'quick_008',
    title: 'Поиграйте в крестики-нолики',
    description:
        'Достаточно листа бумаги и ручки. Играйте лучше из 5.',
    emoji: '❌',
    categories: ['быстро', 'весело', 'дома'],
    durationMinutes: 10,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'quick_009',
    title: 'Придумайте общего персонажа',
    description:
        'За 5 минут придумайте персонажа вместе: имя, характер, суперсила, слабость. По очереди добавляйте детали.',
    emoji: '🦸',
    categories: ['быстро', 'весело'],
    durationMinutes: 15,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.fun,
  ),

  // ── РОМАНТИКА ─────────────────────────────────────────────────────────────

  ActivityIdea(
    id: 'romantic_001',
    title: 'Воспроизведите первое свидание',
    description:
        'Вспомните, что вы делали на первом свидании. Попробуйте воспроизвести — туда же, то же самое. Или близко к этому.',
    emoji: '💞',
    categories: ['романтика', 'новые впечатления'],
    durationMinutes: 120,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.romantic,
  ),

  ActivityIdea(
    id: 'romantic_002',
    title: 'Напишите партнёру письмо от руки',
    description:
        'Напишите письмо от руки — не в телефоне, а на бумаге. Про то, что чувствуете, что цените, чего хотите. Передайте в руки.',
    emoji: '💌',
    categories: ['романтика', 'глубокие разговоры'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.romantic,
  ),

  ActivityIdea(
    id: 'romantic_003',
    title: 'Сделайте друг другу массаж',
    description:
        'Простой массаж плеч, спины или рук. 10–15 минут на каждого. Без спешки.',
    emoji: '🤲',
    categories: ['романтика', 'уют', 'дома'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.romantic,
  ),

  ActivityIdea(
    id: 'romantic_004',
    title: 'Создайте "карту" ваших отношений',
    description:
        'Нарисуйте на листе бумаги важные моменты ваших отношений — как карту. Места, события, точки поворота.',
    emoji: '🗺️',
    categories: ['романтика', 'глубокие разговоры', 'дома'],
    durationMinutes: 45,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.deep,
    preparation: 'Нужна большая бумага и маркеры.',
  ),

  ActivityIdea(
    id: 'romantic_005',
    title: 'Спланируйте воображаемое путешествие',
    description:
        'Выберите страну, куда хотите поехать вместе. Составьте маршрут, найдите отель, ресторан, место. Как если бы поехали завтра.',
    emoji: '🌏',
    categories: ['романтика', 'разговор'],
    durationMinutes: 60,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.romantic,
  ),

  ActivityIdea(
    id: 'romantic_006',
    title: 'Слушайте музыку в темноте',
    description:
        'Выключите свет, лягте или сядьте рядом и слушайте музыку вместе. Один альбом или плейлист — без слов.',
    emoji: '🌑',
    categories: ['романтика', 'уют', 'дома'],
    durationMinutes: 45,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.romantic,
  ),

  ActivityIdea(
    id: 'romantic_007',
    title: 'Назовите 5 моментов, которые помните до сих пор',
    description:
        'Каждый называет 5 конкретных моментов в ваших отношениях, которые запомнились больше всего. Рассказывайте подробно.',
    emoji: '🏅',
    categories: ['романтика', 'глубокие разговоры'],
    durationMinutes: 40,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.deep,
  ),

  // ── ГЛУБОКИЕ РАЗГОВОРЫ ────────────────────────────────────────────────────

  ActivityIdea(
    id: 'deep_001',
    title: 'Что для вас значит дом?',
    description:
        'Расскажите друг другу, что значит для вас "дом". Место? Ощущение? Человек? Поговорите об этом без спешки.',
    emoji: '🏠',
    categories: ['глубокие разговоры', 'разговор'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'deep_002',
    title: 'Каким был самый трудный период вашей жизни?',
    description:
        'Поговорите о самом сложном периоде — до или после знакомства. Что помогло пройти через это?',
    emoji: '🌊',
    categories: ['глубокие разговоры', 'разговор'],
    durationMinutes: 40,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'deep_003',
    title: 'Что вы хотели бы изменить в прошлом?',
    description:
        'Каждый называет одно решение или момент, который хотел бы пережить иначе. Не осуждайте — просто слушайте.',
    emoji: '⏪',
    categories: ['глубокие разговоры', 'разговор'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'deep_004',
    title: 'О чём вы мечтали в детстве?',
    description:
        'Расскажите, кем хотели стать и что хотели сделать, когда были маленькими. Что сбылось, а что нет?',
    emoji: '🌈',
    categories: ['глубокие разговоры', 'разговор'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'deep_005',
    title: 'Что вам даёт сила?',
    description:
        'Каждый рассказывает о том, откуда берёт силы в трудные моменты — люди, действия, привычки, места.',
    emoji: '💪',
    categories: ['глубокие разговоры', 'разговор'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'deep_006',
    title: 'Как изменились ваши приоритеты за последние 5 лет?',
    description:
        'Что было важным 5 лет назад и что важно сейчас? Где ваши ценности изменились, а где нет?',
    emoji: '📊',
    categories: ['глубокие разговоры', 'разговор'],
    durationMinutes: 40,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'deep_007',
    title: 'Что вы никогда не говорили партнёру?',
    description:
        'Каждый называет одну вещь, которую думал, но никогда не произносил вслух. Любую — маленькую или большую.',
    emoji: '🤐',
    categories: ['глубокие разговоры', 'разговор'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'deep_008',
    title: 'Какую легаси вы хотите оставить?',
    description:
        'Чем вы хотите быть запомнены? Что хотите построить, создать или передать? Поговорите об этом.',
    emoji: '🏗️',
    categories: ['глубокие разговоры', 'разговор'],
    durationMinutes: 40,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'deep_009',
    title: 'Что значит для вас быть хорошим партнёром?',
    description:
        'Честный разговор: что каждый из вас считает важным в паре? Не критика, а ценности.',
    emoji: '🤝',
    categories: ['глубокие разговоры', 'разговор'],
    durationMinutes: 40,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'deep_010',
    title: 'Расскажите о человеке, который вас сформировал',
    description:
        'Кто был самым влиятельным человеком в вашей жизни до встречи с партнёром? Расскажите о нём или ней.',
    emoji: '👥',
    categories: ['глубокие разговоры', 'разговор'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.deep,
  ),

  // ── УЮТ ──────────────────────────────────────────────────────────────────

  ActivityIdea(
    id: 'cozy_001',
    title: 'Вечер под пледом с горячим шоколадом',
    description:
        'Приготовьте горячий шоколад или какао, заверните в пледы и ничего не делайте. Просто будьте рядом.',
    emoji: '🍫',
    categories: ['уют', 'дома'],
    durationMinutes: 60,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.cozy,
  ),

  ActivityIdea(
    id: 'cozy_002',
    title: 'Слушайте дождь вместе',
    description:
        'Когда идёт дождь — откройте окно или балкон, сядьте рядом и просто слушайте. Никаких задач.',
    emoji: '🌧️',
    categories: ['уют', 'дома', 'романтика'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.cozy,
  ),

  ActivityIdea(
    id: 'cozy_003',
    title: 'Организуйте "ленивый день"',
    description:
        'Договоритесь, что сегодня — день без планов и обязанностей. Делайте только то, что хочется прямо сейчас.',
    emoji: '😴',
    categories: ['уют', 'дома'],
    durationMinutes: 480,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.cozy,
  ),

  ActivityIdea(
    id: 'cozy_004',
    title: 'Накройте пледом диван и смотрите сериал',
    description:
        'Начните новый сериал или досмотрите незаконченный. Пледы, подушки, закуски. Выключите всё остальное.',
    emoji: '🛋️',
    categories: ['уют', 'дома'],
    durationMinutes: 120,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.cozy,
  ),

  ActivityIdea(
    id: 'cozy_005',
    title: 'Зажгите ароматические свечи и расслабьтесь',
    description:
        'Зажгите свечи, выключите яркий свет, включите тихую музыку. Просто существуйте рядом.',
    emoji: '🕯️',
    categories: ['уют', 'дома', 'романтика'],
    durationMinutes: 60,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.cozy,
  ),

  ActivityIdea(
    id: 'cozy_006',
    title: 'Сделайте горячие напитки и поговорите',
    description:
        'Заварите чай, кофе или что любите. Сядьте напротив друг друга и поговорите — о чём угодно. Без телефонов.',
    emoji: '☕',
    categories: ['уют', 'дома', 'разговор'],
    durationMinutes: 45,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.cozy,
  ),

  ActivityIdea(
    id: 'cozy_007',
    title: 'Потанцуйте медленно дома',
    description:
        'Включите медленную музыку и потанцуйте — прямо в гостиной или на кухне. Без повода.',
    emoji: '🕺',
    categories: ['уют', 'дома', 'романтика'],
    durationMinutes: 15,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.romantic,
  ),

  ActivityIdea(
    id: 'cozy_008',
    title: 'Читайте рядом в тишине',
    description:
        'Каждый читает своё. Просто побудьте рядом в тишине. Иногда это самый тёплый вечер.',
    emoji: '📖',
    categories: ['уют', 'дома', 'бесплатно'],
    durationMinutes: 60,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.cozy,
  ),

  // ── НОВЫЕ ВПЕЧАТЛЕНИЯ ─────────────────────────────────────────────────────

  ActivityIdea(
    id: 'new_001',
    title: 'Попробуйте новое хобби вместе',
    description:
        'Выберите хобби, которое никто из вас не пробовал — лепка, скетчинг, оригами, макраме. Потратьте вечер на первые шаги.',
    emoji: '🎯',
    categories: ['новые впечатления', 'дома'],
    durationMinutes: 90,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'new_002',
    title: 'Сходите на выставку или концерт',
    description:
        'Найдите ближайшее мероприятие — выставку, концерт, лекцию, спектакль. Выберите что-то необычное для себя.',
    emoji: '🎪',
    categories: ['новые впечатления', 'прогулка'],
    durationMinutes: 120,
    budget: ActivityBudget.medium,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'new_003',
    title: 'Посетите место, которое всегда откладывали',
    description:
        'Есть ли в вашем городе место, куда хотели, но не доходили? Сходите туда сегодня.',
    emoji: '📍',
    categories: ['новые впечатления', 'прогулка'],
    durationMinutes: 120,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.spontaneous,
  ),

  ActivityIdea(
    id: 'new_004',
    title: 'Сыграйте в видеоигру, которую никогда не пробовали',
    description:
        'Найдите игру, в которую никто из вас не играл. Попробуйте пройти уровень вместе — даже если не получится.',
    emoji: '🎮',
    categories: ['новые впечатления', 'дома', 'весело'],
    durationMinutes: 60,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'new_005',
    title: 'Послушайте подкаст вместе и обсудите',
    description:
        'Выберите эпизод подкаста на интересную тему. Послушайте и поговорите о том, что узнали или не согласны.',
    emoji: '🎙️',
    categories: ['новые впечатления', 'разговор', 'дома'],
    durationMinutes: 60,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'new_006',
    title: 'Возьмите урок онлайн вместе',
    description:
        'Найдите бесплатный онлайн-курс или урок на YouTube по теме, которую хотели изучить. Смотрите и обсуждайте вместе.',
    emoji: '💡',
    categories: ['новые впечатления', 'дома', 'бесплатно'],
    durationMinutes: 60,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.calm,
  ),

  ActivityIdea(
    id: 'new_007',
    title: 'Попробуйте кухню страны, которую не пробовали',
    description:
        'Найдите ресторан или кафе с кухней страны, которую никогда не пробовали. Закажите незнакомые блюда.',
    emoji: '🌮',
    categories: ['новые впечатления', 'еда', 'прогулка'],
    durationMinutes: 90,
    budget: ActivityBudget.medium,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'new_008',
    title: 'Поиграйте в квест или детектив',
    description:
        'Найдите настольный квест или распечатайте сценарий детектива. Разыграйте вместе.',
    emoji: '🔍',
    categories: ['новые впечатления', 'дома', 'весело'],
    durationMinutes: 90,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'new_009',
    title: 'Посмотрите документальный фильм о месте, где хотите побывать',
    description:
        'Найдите документалку о стране или городе мечты. Потом обсудите, что хотите там увидеть.',
    emoji: '🗾',
    categories: ['новые впечатления', 'разговор', 'дома'],
    durationMinutes: 90,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.calm,
  ),

  ActivityIdea(
    id: 'new_010',
    title: 'Сделайте что-то, чего боитесь вместе',
    description:
        'Что каждый из вас избегает? Высота, темнота, публичность. Найдите маленькую версию страха и встретьте вместе.',
    emoji: '🎢',
    categories: ['новые впечатления', 'глубокие разговоры'],
    durationMinutes: 60,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.spontaneous,
  ),

  ActivityIdea(
    id: 'new_011',
    title: 'Попробуйте йогу или медитацию в первый раз',
    description:
        'Включите видео с базовой йогой или медитацией для начинающих. Делайте вместе, не смущаясь.',
    emoji: '🧘',
    categories: ['новые впечатления', 'дома', 'бесплатно'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.calm,
  ),

  ActivityIdea(
    id: 'new_012',
    title: 'Найдите в городе место, которого нет на Google Maps',
    description:
        'Погуляйте по дворам, переулкам, незаметным улицам. Найдите что-то, что не значится ни в каких списках.',
    emoji: '🗝️',
    categories: ['новые впечатления', 'прогулка', 'бесплатно'],
    durationMinutes: 90,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.spontaneous,
  ),

  // ── ДОПОЛНИТЕЛЬНЫЕ СМЕШАННЫЕ ─────────────────────────────────────────────

  ActivityIdea(
    id: 'mix_001',
    title: 'Составьте список "100 вещей до конца жизни"',
    description:
        'Каждый пишет свой список из 100 вещей, которые хочет сделать. Потом ищите пересечения.',
    emoji: '📋',
    categories: ['глубокие разговоры', 'разговор', 'дома'],
    durationMinutes: 60,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'mix_002',
    title: 'Играйте в ассоциации',
    description:
        'Один говорит слово, другой — первую ассоциацию. Не останавливайтесь. Через 10 минут разберите цепочку — что она говорит о каждом?',
    emoji: '🔗',
    categories: ['разговор', 'весело', 'быстро'],
    durationMinutes: 15,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'mix_003',
    title: 'Найдите кота или собаку погладить',
    description:
        'Пройдитесь по улице с целью найти и погладить животное. Звучит просто — но поднимает настроение.',
    emoji: '🐱',
    categories: ['прогулка', 'бесплатно', 'быстро'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'mix_004',
    title: 'Договоритесь об одном новом ритуале',
    description:
        'Придумайте маленький ритуал, который будете делать каждый день или каждую неделю. Утренний кофе вместе, вечерняя прогулка, слово дня.',
    emoji: '🔁',
    categories: ['разговор', 'глубокие разговоры', 'дома'],
    durationMinutes: 20,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.calm,
  ),

  ActivityIdea(
    id: 'mix_005',
    title: 'Пересмотрите старые видео с телефона',
    description:
        'Откройте архив телефона и просмотрите видео за последний год. Смейтесь, удивляйтесь, вспоминайте.',
    emoji: '📱',
    categories: ['дома', 'уют', 'бесплатно'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.cozy,
  ),

  ActivityIdea(
    id: 'mix_006',
    title: 'Придумайте вашу "фирменную" традицию',
    description:
        'Что-то только ваше: еда, место, фраза, жест. Придумайте одну вещь, которая будет означать "мы".',
    emoji: '🎋',
    categories: ['разговор', 'романтика', 'глубокие разговоры'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'mix_007',
    title: 'Запустите бумажный самолёт с высоты',
    description:
        'Сложите бумажные самолёты и запустите их с балкона, крыши или любой возвышенности. Чей дальше?',
    emoji: '✈️',
    categories: ['прогулка', 'весело', 'быстро', 'бесплатно'],
    durationMinutes: 15,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'mix_008',
    title: 'Сыграйте в карты',
    description:
        'Классические карты подходят. Дурак, война, рыбалка — выберите игру и сыграйте несколько раундов.',
    emoji: '🃏',
    categories: ['дома', 'весело', 'бесплатно'],
    durationMinutes: 45,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'mix_009',
    title: 'Поиграйте в города',
    description:
        'Классическая игра в города. По очереди называйте города на последнюю букву предыдущего. Кто первый застрянет?',
    emoji: '🌆',
    categories: ['дома', 'весело', 'быстро', 'бесплатно'],
    durationMinutes: 20,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'mix_010',
    title: 'Организуйте "суббота без экранов"',
    description:
        'Проведите несколько часов без телефонов, ноутбуков и телевизора. Только вы и то, что можно делать руками.',
    emoji: '📵',
    categories: ['дома', 'уют', 'глубокие разговоры'],
    durationMinutes: 180,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.calm,
  ),

  ActivityIdea(
    id: 'mix_011',
    title: 'Придумайте совместный проект',
    description:
        'Блог, канал, огород, ремонт, кулинарная книга — что-то, что вы хотели бы делать вместе долго. Обсудите и запишите первый шаг.',
    emoji: '🚀',
    categories: ['разговор', 'глубокие разговоры'],
    durationMinutes: 45,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'mix_012',
    title: 'Сделайте что-то приятное для другого человека вместе',
    description:
        'Помогите соседу, напишите письмо другу, поддержите кого-то в сети. Маленький добрый поступок вместе — это хорошо.',
    emoji: '💛',
    categories: ['новые впечатления', 'разговор'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.calm,
  ),

  ActivityIdea(
    id: 'mix_013',
    title: 'Запишите 10 вещей, которые вас смешат',
    description:
        'Каждый вспоминает 10 вещей, которые вас обоих смешат: моменты, шутки, фразы. Перечитайте и посмейтесь.',
    emoji: '😂',
    categories: ['дома', 'разговор', 'весело'],
    durationMinutes: 20,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'mix_014',
    title: 'Побывайте в месте, где познакомились',
    description:
        'Вернитесь туда, где вы впервые встретились — кафе, парк, улица, вечеринка. Постойте там немного.',
    emoji: '💫',
    categories: ['романтика', 'прогулка', 'новые впечатления'],
    durationMinutes: 60,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.romantic,
  ),

  ActivityIdea(
    id: 'mix_015',
    title: 'Нарисуйте карту вашего района',
    description:
        'Попробуйте нарисовать по памяти карту улиц вокруг вашего дома. Без телефона. Сравните, кто точнее.',
    emoji: '🗺️',
    categories: ['дома', 'весело', 'быстро'],
    durationMinutes: 20,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'mix_016',
    title: 'Устройте "вопрос дня" на неделю',
    description:
        'Придумайте 7 глубоких вопросов и записайте. Отвечайте на один каждый вечер. Просто и по-настоящему.',
    emoji: '📅',
    categories: ['разговор', 'глубокие разговоры', 'быстро'],
    durationMinutes: 15,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'mix_017',
    title: 'Сыграйте в шахматы или шашки',
    description:
        'Классика. Доставайте доску — или найдите приложение и играйте вместе на одном устройстве.',
    emoji: '♟️',
    categories: ['дома', 'весело'],
    durationMinutes: 45,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'mix_018',
    title: 'Посетите блошиный рынок или барахолку',
    description:
        'Найдите ближайшую блошку или барахолку. Каждый выбирает одну вещь до 100 рублей. Потом объясняет почему.',
    emoji: '🧸',
    categories: ['новые впечатления', 'прогулка'],
    durationMinutes: 120,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'mix_019',
    title: 'Составьте совместный список фильмов на этот год',
    description:
        'Каждый называет 10 фильмов, которые хочет посмотреть. Объедините и договоритесь о порядке.',
    emoji: '🎥',
    categories: ['дома', 'разговор', 'быстро'],
    durationMinutes: 20,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'mix_020',
    title: 'Поговорите о вашей паре в третьем лице',
    description:
        'Представьте, что рассказываете о своих отношениях другу — как бы вы описали их? Что бы сказал партнёр о вас?',
    emoji: '💬',
    categories: ['разговор', 'глубокие разговоры'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'mix_021',
    title: 'Сделайте совместную тренировку на свежем воздухе',
    description:
        'Пробежка, скандинавская ходьба, подтягивания на турнике во дворе. Любая активность вместе на улице.',
    emoji: '🏋️',
    categories: ['прогулка', 'бесплатно', 'быстро'],
    durationMinutes: 40,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'mix_022',
    title: 'Обсудите 3 вещи, которые хотите улучшить в себе',
    description:
        'Не жалобы, а намерения. Каждый называет 3 качества или привычки, которые хочет развить. Как можно поддержать друг друга?',
    emoji: '🎯',
    categories: ['глубокие разговоры', 'разговор'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'mix_023',
    title: 'Приготовьте что-нибудь из другой культуры',
    description:
        'Выберите рецепт из страны, которая вам нравится: Япония, Мексика, Грузия, Индия. Готовьте вместе с музыкой оттуда.',
    emoji: '🍜',
    categories: ['еда', 'дома', 'новые впечатления'],
    durationMinutes: 90,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'mix_024',
    title: 'Найдите в интернете место мечты и изучите его',
    description:
        'Откройте карту или YouTube и изучите место, куда хотите — улицы, достопримечательности, кафе. Представьте, что вы там.',
    emoji: '🌐',
    categories: ['разговор', 'новые впечатления', 'быстро'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.calm,
  ),

  ActivityIdea(
    id: 'mix_025',
    title: 'Поставьте цель на следующий месяц',
    description:
        'Каждый ставит одну личную цель на следующий месяц и одну совместную. Запишите и уберите в место, где увидите потом.',
    emoji: '🎯',
    categories: ['разговор', 'глубокие разговоры'],
    durationMinutes: 20,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'walk_014',
    title: 'Покормите уток или голубей',
    description:
        'Возьмите хлеб или крупу и найдите водоём с утками или сквер с голубями. Детское и приятное.',
    emoji: '🦆',
    categories: ['прогулка', 'бесплатно', 'быстро'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.calm,
  ),

  ActivityIdea(
    id: 'talk_014',
    title: 'Расскажите о своей самой большой победе',
    description:
        'Каждый называет момент, которым гордится больше всего. Не обязательно грандиозный — важно, что он значит лично.',
    emoji: '🏅',
    categories: ['разговор', 'глубокие разговоры'],
    durationMinutes: 20,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.any,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'home_016',
    title: 'Сделайте перестановку в одной комнате',
    description:
        'Передвиньте мебель в комнате и посмотрите, как изменится ощущение. Иногда это меняет всё — без покупок.',
    emoji: '🛋️',
    categories: ['дома', 'новые впечатления'],
    durationMinutes: 60,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.spontaneous,
  ),

  ActivityIdea(
    id: 'home_017',
    title: 'Составьте список "Что нас объединяет"',
    description:
        'Запишите всё, что у вас общее: интересы, привычки, ценности, воспоминания. Сколько наберёте?',
    emoji: '🔗',
    categories: ['дома', 'разговор', 'романтика'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.deep,
  ),

  ActivityIdea(
    id: 'cozy_009',
    title: 'Полежите и смотрите в потолок',
    description:
        'Лягте рядом и смотрите в потолок. Разговаривайте о чём угодно или молчите. Иногда самые важные разговоры случаются именно так.',
    emoji: '🌙',
    categories: ['уют', 'дома', 'разговор'],
    durationMinutes: 30,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.cozy,
  ),

  ActivityIdea(
    id: 'food_013',
    title: 'Устройте "tapas" дома',
    description:
        'Приготовьте много маленьких закусок — по 3-4 кусочка каждой. Накройте стол как в испанском баре и пробуйте всё понемногу.',
    emoji: '🥘',
    categories: ['еда', 'дома', 'уют'],
    durationMinutes: 60,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.fun,
  ),

  ActivityIdea(
    id: 'surprise_009',
    title: 'Купите цветы без повода',
    description:
        'Просто купите небольшой букет — один для другого. Не нужна причина. "Просто увидел и подумал о тебе".',
    emoji: '💐',
    categories: ['сюрприз', 'романтика'],
    durationMinutes: 10,
    budget: ActivityBudget.low,
    locationType: ActivityLocationType.outside,
    vibe: ActivityVibe.romantic,
  ),

  ActivityIdea(
    id: 'new_013',
    title: 'Попробуйте нарисовать мандалу вместе',
    description:
        'Возьмите бумагу и ручку, поставьте точку в центре. Рисуйте симметричные узоры, чередуясь — каждый добавляет линию.',
    emoji: '🌸',
    categories: ['новые впечатления', 'дома', 'уют'],
    durationMinutes: 45,
    budget: ActivityBudget.free,
    locationType: ActivityLocationType.home,
    vibe: ActivityVibe.calm,
  ),
];

/// Все доступные категории.
const List<String> kActivityCategories = [
  'дома',
  'прогулка',
  'еда',
  'разговор',
  'сюрприз',
  'бесплатно',
  'быстро',
  'романтика',
  'глубокие разговоры',
  'уют',
  'новые впечатления',
];
