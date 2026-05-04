BEGIN;

UPDATE roles
SET title = 'Владелец',
    description = 'Полный доступ ко всем функциям портала'
WHERE code = 'owner';

UPDATE roles
SET title = 'Врач УЗИ',
    description = 'Доступ к рабочим протоколам и базе случаев'
WHERE code = 'doctor';

UPDATE permissions
SET title = 'Просмотр шаблонов',
    description = 'Просмотр списка шаблонов и карточек'
WHERE code = 'templates.view';

UPDATE permissions
SET title = 'Управление шаблонами',
    description = 'Создание, редактирование, архивирование шаблонов'
WHERE code = 'templates.manage';

UPDATE permissions
SET title = 'Публикация шаблонов',
    description = 'Публикация шаблонов и смена статусов'
WHERE code = 'templates.publish';

UPDATE permissions
SET title = 'Экспорт шаблонов',
    description = 'Генерация и скачивание файлов шаблонов'
WHERE code = 'templates.files';

UPDATE permissions
SET title = 'Создание протоколов',
    description = 'Создание рабочих протоколов по шаблонам'
WHERE code = 'reports.create';

UPDATE permissions
SET title = 'Редактирование протоколов',
    description = 'Редактирование черновиков рабочих протоколов'
WHERE code = 'reports.edit';

UPDATE permissions
SET title = 'Финализация протоколов',
    description = 'Фиксация финального текста протокола'
WHERE code = 'reports.finalize';

UPDATE permissions
SET title = 'Экспорт протоколов',
    description = 'Генерация и скачивание файлов протоколов'
WHERE code = 'reports.files';

UPDATE permissions
SET title = 'Просмотр базы случаев',
    description = 'Просмотр интересных случаев внутри команды'
WHERE code = 'cases.view';

UPDATE permissions
SET title = 'Управление базой случаев',
    description = 'Создание и редактирование случаев, загрузка изображений'
WHERE code = 'cases.manage';

UPDATE permissions
SET title = 'Управление файлами хранилища',
    description = 'Работа с объектами файлового хранилища'
WHERE code = 'storage.manage';

UPDATE protocol_categories
SET title = 'Щитовидная железа',
    description = 'Протоколы для щитовидной железы'
WHERE code = 'thyroid';

UPDATE protocol_categories
SET title = 'Органы брюшной полости',
    description = 'Протоколы для органов брюшной полости'
WHERE code = 'abdomen';

UPDATE protocol_categories
SET title = 'Почки',
    description = 'Протоколы для почек и мочевыводящих путей'
WHERE code = 'kidneys';

UPDATE protocol_categories
SET title = 'Молочные железы',
    description = 'Протоколы для молочных желез'
WHERE code = 'breast';

UPDATE protocol_categories
SET title = 'Гинекология',
    description = 'Протоколы гинекологического УЗИ'
WHERE code = 'gynecology';

UPDATE protocol_categories
SET title = 'Сосуды',
    description = 'Протоколы для сосудистых исследований'
WHERE code = 'vessels';

COMMIT;