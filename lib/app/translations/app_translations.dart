import 'dart:ui';
import 'package:get/get.dart';

/// Ilova tarjimalari. Kalitlar — o'zbekcha matnning o'zi, shuning uchun
/// 'uz' xaritasi shart emas: tarjima topilmasa `.tr` kalitni qaytaradi.
/// Bu standart (UZ) ko'rinishni ayn-i-ayn saqlaydi.
class AppTranslations extends Translations {
  static const fallback = Locale('uz', 'UZ');

  /// 'UZ' / 'RU' / 'EN' kodini Locale'ga aylantiradi.
  static Locale localeFromCode(String code) {
    switch (code) {
      case 'RU':
        return const Locale('ru', 'RU');
      case 'EN':
        return const Locale('en', 'US');
      default:
        return const Locale('uz', 'UZ');
    }
  }

  /// Til kodi uchun ko'rsatiladigan nom (profil sozlamalarida).
  static String languageName(String code) {
    switch (code) {
      case 'RU':
        return 'Русский';
      case 'EN':
        return 'English';
      default:
        return 'O\'zbekcha';
    }
  }

  @override
  Map<String, Map<String, String>> get keys => {'ru_RU': _ru, 'en_US': _en};

  static const Map<String, String> _ru = {
    // Login
    'Mehmonxona xizmati boshqaruv tizimiga xush kelibsiz':
        'Добро пожаловать в систему управления гостиничным сервисом',
    'Foydalanuvchi nomi': 'Имя пользователя',
    'PAROLNI UNUTDINGIZMI?': 'ЗАБЫЛИ ПАРОЛЬ?',
    'Eslab qolish': 'Запомнить меня',
    'Kirish': 'Войти',
    'Kirish...': 'Вход...',
    'Qo\'llab-quvvatlash': 'Поддержка',
    'Xatolik': 'Ошибка',
    'Iltimos, foydalanuvchi nomi va parolni kiriting':
        'Пожалуйста, введите имя пользователя и пароль',
    'Login ma\'lumotlari noto\'g\'ri yoki serverga ulanishda xatolik':
        'Неверные данные для входа или ошибка подключения к серверу',

    // Pastki navigatsiya
    'Bosh': 'Главная',
    'Vazifalar': 'Задачи',
    'Xabarlar': 'Уведомления',
    'Profil': 'Профиль',

    // Bosh sahifa
    'Xodim profili': 'Профиль сотрудника',
    'BUGUNGI SMENA': 'СЕГОДНЯШНЯЯ СМЕНА',
    'Xush kelibsiz!': 'Добро пожаловать!',
    'Bugungi smenangiz muvaffaqiyatli o\'tmoqda.':
        'Ваша смена проходит успешно.',
    'Bajarilish': 'Прогресс',
    'Yakunlandi': 'Завершено',
    'Kutilmoqda': 'Ожидает',
    'Muammo': 'Проблема',
    'Bugungi vazifalar': 'Задачи на сегодня',
    'Hammasi': 'Все',
    'Band xonalar': 'Занятые номера',
    'Xonalar qachon bo\'shashini ko\'ring': 'Узнайте, когда освободятся номера',

    // Vazifalar
    'Mening vazifalarim': 'Мои задачи',
    'Bugun, 24-Oktyabr': 'Сегодня',
    'Jarayonda': 'В процессе',
    'Yakunlangan': 'Завершённые',
    'Hozircha vazifalar yo\'q': 'Пока задач нет',
    'Tozalangan': 'Убрано',
    'Shoshilinch': 'Срочно',
    'Tozalanishi kerak': 'Требуется уборка',
    'Bajarish': 'Выполнить',
    'Boshlash': 'Начать',
    'Yakunlash': 'Завершить',
    'Hisobot': 'Отчёт',

    // Xona sahifasi
    'Xona': 'Номер',
    'Tekshirish ro\'yxati': 'Чек-лист',
    'QAVAT': 'ЭТАЖ',
    'HOLAT': 'СТАТУС',
    'JARAYON': 'ПРОГРЕСС',
    'QO\'SHIMCHA MA\'LUMOT': 'ДОПОЛНИТЕЛЬНАЯ ИНФОРМАЦИЯ',
    'Mehmon': 'Гость',
    'Ma\'lumot yo\'q': 'Нет данных',
    'Tozalash muddati': 'Срок уборки',
    'Belgilanmagan': 'Не задан',
    'Tekshirilmoqda...': 'Проверяется...',
    'Xona hozir band emas': 'Номер сейчас свободен',
    'Chiqish': 'Выезд',
    'Xona bandligi': 'Занятость номера',
    'Band': 'Занят',
    'Bo\'shatilgan': 'Освобождён',
    'Ro\'yxat biriktirilmagan': 'Чек-лист не прикреплён',
    'Xonani standart tartibda tozalang va yakunida fotohisobot yuboring.':
        'Уберите номер по стандарту и в конце отправьте фотоотчёт.',

    // Band xonalar
    'Xonalar qachon bo\'shaydi': 'Когда освободятся номера',
    'Jami band': 'Всего занято',
    '1 soatgacha': 'До 1 часа',
    'Kechikkan': 'Просрочено',
    'Bron qilinganlarni ham ko\'rsatish': 'Показать также брони',
    'Hozircha band xonalar yo\'q': 'Занятых номеров нет',
    'XONA': 'НОМЕР',
    'Bron': 'Бронь',
    'Soatlik': 'Почасовой',
    'Kunlik': 'Суточный',
    'Hozir bo\'shaydi': 'Скоро освободится',
    'daqiqa': 'мин',
    'soat': 'ч',
    'kun': 'дн',
    'qoldi': 'осталось',
    'kechikdi': 'просрочено',
    'yanvar': 'января',
    'fevral': 'февраля',
    'mart': 'марта',
    'aprel': 'апреля',
    'may': 'мая',
    'iyun': 'июня',
    'iyul': 'июля',
    'avgust': 'августа',
    'sentyabr': 'сентября',
    'oktyabr': 'октября',
    'noyabr': 'ноября',
    'dekabr': 'декабря',

    // Fotohisobot
    'Vazifani yakunlash': 'Завершение задачи',
    'Fotohisobot': 'Фотоотчёт',
    'SURATLAR': 'ФОТО',
    'ta surat': 'фото',
    'Suratga olish': 'Сделать фото',
    'Xona holatini bir nechta suratga olishingiz mumkin':
        'Можно сделать несколько снимков состояния номера',
    'Yana': 'Ещё',
    'QO\'SHIMCHA IZOH (IXTIYORIY)': 'КОММЕНТАРИЙ (НЕОБЯЗАТЕЛЬНО)',
    'Qo\'shimcha izoh yozish...': 'Написать комментарий...',
    'Yuborilmoqda...': 'Отправка...',
    'Hisobotni yuborish': 'Отправить отчёт',
    'Bekor qilish': 'Отмена',
    'Surat kerak': 'Нужно фото',
    'Kamida bitta surat oling': 'Сделайте хотя бы одно фото',
    'Hisobot yuborilmadi. Internetni tekshirib, qayta urinib ko\'ring.':
        'Отчёт не отправлен. Проверьте интернет и попробуйте снова.',
    'Muvaffaqiyatli!': 'Успешно!',
    'Xona tozalandi va hisobot yuborildi': 'Номер убран, отчёт отправлен',
    'Hisobot muvaffaqiyatli yuborildi': 'Отчёт успешно отправлен',

    // Muammo hisoboti
    'Muammo haqida xabar berish': 'Сообщить о проблеме',
    'Xonada siniq buyum, chiroy kuygan joy, texnik nosozlik yoki boshqa muammo bo\'lsa, quyidagi shakl orqali xabar bering va foto hisobot qo\'shing.':
        'Если в номере есть сломанные предметы, перегоревшие лампы, технические неисправности или другие проблемы — сообщите через форму ниже и приложите фото.',
    'KATEGORIYA': 'КАТЕГОРИЯ',
    'Siniq buyum': 'Сломанный предмет',
    'Texnik nosozlik': 'Техническая неисправность',
    'Suv sizishi': 'Протечка воды',
    'Chiroy kuygan': 'Перегоревшая лампа',
    'Elektr nosozligi': 'Электрическая неисправность',
    'Mexanizm buzilgan': 'Сломан механизм',
    'Boshqa': 'Другое',
    'TAFSILOTLAR': 'ДЕТАЛИ',
    'Muammoning tafsilotlarini kiriting...': 'Опишите проблему...',
    'FOTO HISOBOT': 'ФОТООТЧЁТ',
    'Muammo joyidan suratga oling (Max 3 ta)':
        'Сфотографируйте проблему (макс. 3)',
    'Rasm qo\'shish uchun bosing': 'Нажмите, чтобы добавить фото',
    'rasm yuklandi': 'фото загружено',
    'Xabar yuborish': 'Отправить',
    'Iltimos, muammoning tafsilotlarini kiriting':
        'Пожалуйста, опишите проблему',
    'Iltimos, muammo joyidan suratga oling':
        'Пожалуйста, сфотографируйте проблему',
    'Hisobot yuborishda xatolik yuz berdi': 'Ошибка при отправке отчёта',
    'Muammo haqida xabar yuborildi': 'Сообщение о проблеме отправлено',

    // Bildirishnomalar
    'YANGILANISHLAR': 'ОБНОВЛЕНИЯ',
    'Bildirishnomalar': 'Уведомления',
    'O\'qildi deb belgilash': 'Отметить прочитанным',
    'Barcha yangiliklardan xabardor bo\'ling': 'Будьте в курсе всех новостей',
    'BORISH': 'ПЕРЕЙТИ',
    'Hozir': 'Сейчас',
    'daqiqa oldin': 'мин назад',
    'soat oldin': 'ч назад',
    'kun oldin': 'дн назад',

    // Profil
    'XODIM MA\'LUMOTI': 'ДАННЫЕ СОТРУДНИКА',
    'Bo\'lim': 'Отдел',
    'ID raqam': 'ID',
    'Tilni o\'zgartirish': 'Сменить язык',
    'Maxfiylik': 'Конфиденциальность',
    'Xavfsizlik va kirish nazorati': 'Безопасность и контроль доступа',
    'Yordam': 'Помощь',
    'Qo\'llab-quvvatlash xizmati': 'Служба поддержки',
    'Til tanlang': 'Выберите язык',
    'Ish soatlari': 'Рабочие часы',
    'Reyting': 'Рейтинг',
    'Hisobdan chiqish': 'Выйти',
    'Versiya': 'Версия',
  };

  static const Map<String, String> _en = {
    // Login
    'Mehmonxona xizmati boshqaruv tizimiga xush kelibsiz':
        'Welcome to the hotel service management system',
    'Foydalanuvchi nomi': 'Username',
    'PAROLNI UNUTDINGIZMI?': 'FORGOT PASSWORD?',
    'Eslab qolish': 'Remember me',
    'Kirish': 'Sign in',
    'Kirish...': 'Signing in...',
    'Qo\'llab-quvvatlash': 'Support',
    'Xatolik': 'Error',
    'Iltimos, foydalanuvchi nomi va parolni kiriting':
        'Please enter your username and password',
    'Login ma\'lumotlari noto\'g\'ri yoki serverga ulanishda xatolik':
        'Invalid credentials or server connection error',

    // Bottom navigation
    'Bosh': 'Home',
    'Vazifalar': 'Tasks',
    'Xabarlar': 'Alerts',
    'Profil': 'Profile',

    // Home
    'Xodim profili': 'Staff profile',
    'BUGUNGI SMENA': 'TODAY\'S SHIFT',
    'Xush kelibsiz!': 'Welcome!',
    'Bugungi smenangiz muvaffaqiyatli o\'tmoqda.': 'Your shift is going well.',
    'Bajarilish': 'Progress',
    'Yakunlandi': 'Done',
    'Kutilmoqda': 'Pending',
    'Muammo': 'Problem',
    'Bugungi vazifalar': 'Today\'s tasks',
    'Hammasi': 'All',
    'Band xonalar': 'Occupied rooms',
    'Xonalar qachon bo\'shashini ko\'ring': 'See when rooms become free',

    // Tasks
    'Mening vazifalarim': 'My tasks',
    'Bugun, 24-Oktyabr': 'Today',
    'Jarayonda': 'In progress',
    'Yakunlangan': 'Completed',
    'Hozircha vazifalar yo\'q': 'No tasks yet',
    'Tozalangan': 'Cleaned',
    'Shoshilinch': 'Urgent',
    'Tozalanishi kerak': 'Needs cleaning',
    'Bajarish': 'Do it',
    'Boshlash': 'Start',
    'Yakunlash': 'Finish',
    'Hisobot': 'Report',

    // Room details
    'Xona': 'Room',
    'Tekshirish ro\'yxati': 'Checklist',
    'QAVAT': 'FLOOR',
    'HOLAT': 'STATUS',
    'JARAYON': 'PROGRESS',
    'QO\'SHIMCHA MA\'LUMOT': 'ADDITIONAL INFO',
    'Mehmon': 'Guest',
    'Ma\'lumot yo\'q': 'No data',
    'Tozalash muddati': 'Cleaning deadline',
    'Belgilanmagan': 'Not set',
    'Tekshirilmoqda...': 'Checking...',
    'Xona hozir band emas': 'Room is not occupied',
    'Chiqish': 'Check-out',
    'Xona bandligi': 'Occupancy',
    'Band': 'Occupied',
    'Bo\'shatilgan': 'Vacated',
    'Ro\'yxat biriktirilmagan': 'No checklist attached',
    'Xonani standart tartibda tozalang va yakunida fotohisobot yuboring.':
        'Clean the room per standard and send a photo report at the end.',

    // Occupied rooms
    'Xonalar qachon bo\'shaydi': 'When rooms become free',
    'Jami band': 'Total occupied',
    '1 soatgacha': 'Within 1 hour',
    'Kechikkan': 'Overdue',
    'Bron qilinganlarni ham ko\'rsatish': 'Also show reservations',
    'Hozircha band xonalar yo\'q': 'No occupied rooms',
    'XONA': 'ROOM',
    'Bron': 'Reserved',
    'Soatlik': 'Hourly',
    'Kunlik': 'Daily',
    'Hozir bo\'shaydi': 'Freeing up now',
    'daqiqa': 'min',
    'soat': 'h',
    'kun': 'd',
    'qoldi': 'left',
    'kechikdi': 'overdue',
    'yanvar': 'Jan',
    'fevral': 'Feb',
    'mart': 'Mar',
    'aprel': 'Apr',
    'may': 'May',
    'iyun': 'Jun',
    'iyul': 'Jul',
    'avgust': 'Aug',
    'sentyabr': 'Sep',
    'oktyabr': 'Oct',
    'noyabr': 'Nov',
    'dekabr': 'Dec',

    // Photo report
    'Vazifani yakunlash': 'Complete the task',
    'Fotohisobot': 'Photo report',
    'SURATLAR': 'PHOTOS',
    'ta surat': 'photos',
    'Suratga olish': 'Take a photo',
    'Xona holatini bir nechta suratga olishingiz mumkin':
        'You can take several photos of the room',
    'Yana': 'More',
    'QO\'SHIMCHA IZOH (IXTIYORIY)': 'COMMENT (OPTIONAL)',
    'Qo\'shimcha izoh yozish...': 'Write a comment...',
    'Yuborilmoqda...': 'Sending...',
    'Hisobotni yuborish': 'Send report',
    'Bekor qilish': 'Cancel',
    'Surat kerak': 'Photo required',
    'Kamida bitta surat oling': 'Take at least one photo',
    'Hisobot yuborilmadi. Internetni tekshirib, qayta urinib ko\'ring.':
        'Report not sent. Check your connection and try again.',
    'Muvaffaqiyatli!': 'Success!',
    'Xona tozalandi va hisobot yuborildi': 'Room cleaned and report sent',
    'Hisobot muvaffaqiyatli yuborildi': 'Report sent successfully',

    // Problem report
    'Muammo haqida xabar berish': 'Report a problem',
    'Xonada siniq buyum, chiroy kuygan joy, texnik nosozlik yoki boshqa muammo bo\'lsa, quyidagi shakl orqali xabar bering va foto hisobot qo\'shing.':
        'If the room has broken items, burnt-out lights, technical faults or other problems, report them via the form below and attach photos.',
    'KATEGORIYA': 'CATEGORY',
    'Siniq buyum': 'Broken item',
    'Texnik nosozlik': 'Technical fault',
    'Suv sizishi': 'Water leak',
    'Chiroy kuygan': 'Burnt-out light',
    'Elektr nosozligi': 'Electrical fault',
    'Mexanizm buzilgan': 'Broken mechanism',
    'Boshqa': 'Other',
    'TAFSILOTLAR': 'DETAILS',
    'Muammoning tafsilotlarini kiriting...': 'Describe the problem...',
    'FOTO HISOBOT': 'PHOTO REPORT',
    'Muammo joyidan suratga oling (Max 3 ta)':
        'Take photos of the problem (max 3)',
    'Rasm qo\'shish uchun bosing': 'Tap to add a photo',
    'rasm yuklandi': 'photos added',
    'Xabar yuborish': 'Send',
    'Iltimos, muammoning tafsilotlarini kiriting':
        'Please describe the problem',
    'Iltimos, muammo joyidan suratga oling':
        'Please take a photo of the problem',
    'Hisobot yuborishda xatolik yuz berdi': 'Failed to send the report',
    'Muammo haqida xabar yuborildi': 'Problem report sent',

    // Notifications
    'YANGILANISHLAR': 'UPDATES',
    'Bildirishnomalar': 'Notifications',
    'O\'qildi deb belgilash': 'Mark all read',
    'Barcha yangiliklardan xabardor bo\'ling': 'Stay up to date',
    'BORISH': 'GO',
    'Hozir': 'Now',
    'daqiqa oldin': 'min ago',
    'soat oldin': 'h ago',
    'kun oldin': 'd ago',

    // Profile
    'XODIM MA\'LUMOTI': 'EMPLOYEE INFO',
    'Bo\'lim': 'Department',
    'ID raqam': 'ID',
    'Tilni o\'zgartirish': 'Change language',
    'Maxfiylik': 'Privacy',
    'Xavfsizlik va kirish nazorati': 'Security and access control',
    'Yordam': 'Help',
    'Qo\'llab-quvvatlash xizmati': 'Support service',
    'Til tanlang': 'Choose language',
    'Ish soatlari': 'Work hours',
    'Reyting': 'Rating',
    'Hisobdan chiqish': 'Log out',
    'Versiya': 'Version',
  };
}
