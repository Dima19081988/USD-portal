# Черновик схемы БД PostgreSQL

## Назначение документа

Документ описывает начальную структуру базы данных проекта USD Portal
для этапа 1 MVP.

## Общие принципы

- PostgreSQL используется как основная СУБД проекта.
- Схема должна поддерживать расширение ролей и permissions.
- Схема должна поддерживать аудит действий.
- Для динамических настроек шаблонов допускается использование JSONB.
- Все ключевые таблицы должны содержать `created_at` и `updated_at`.

## Основные группы таблиц

### 1. Пользователи и доступ
- `users`
- `roles`
- `permissions`
- `user_roles`
- `role_permissions`
- `sessions`
- `refresh_tokens`
- `login_attempts`

### 2. Протоколы и шаблоны
- `protocol_categories`
- `protocol_templates`
- `protocol_template_versions`
- `template_sections`
- `template_fields`
- `template_field_options`

### 3. Заключения
- `report_drafts`
- `report_field_values`
- `final_reports`

### 4. Контент
- `materials`
- `material_categories`
- `articles`
- `article_tags`
- `events`
- `news`
- `trends`
- `attachments`

### 5. Аудит и системные данные
- `audit_logs`
- `system_settings`

---

## 1. Таблицы доступа

### users

Основная таблица пользователей.

Поля:
- `id` UUID PK
- `email` TEXT UNIQUE NOT NULL
- `password_hash` TEXT NOT NULL
- `first_name` TEXT
- `last_name` TEXT
- `is_active` BOOLEAN DEFAULT true
- `last_login_at` TIMESTAMPTZ
- `created_at` TIMESTAMPTZ DEFAULT now()
- `updated_at` TIMESTAMPTZ DEFAULT now()

### roles

Список ролей системы.

Поля:
- `id` UUID PK
- `code` TEXT UNIQUE NOT NULL
- `name` TEXT NOT NULL
- `description` TEXT
- `created_at` TIMESTAMPTZ DEFAULT now()
- `updated_at` TIMESTAMPTZ DEFAULT now()

Примеры:
- `doctor`
- `owner`

### permissions

Список разрешений.

Поля:
- `id` UUID PK
- `code` TEXT UNIQUE NOT NULL
- `name` TEXT NOT NULL
- `description` TEXT
- `created_at` TIMESTAMPTZ DEFAULT now()

### user_roles

Связь пользователь ↔ роль.

Поля:
- `id` UUID PK
- `user_id` UUID FK -> users.id
- `role_id` UUID FK -> roles.id
- `created_at` TIMESTAMPTZ DEFAULT now()

### role_permissions

Связь роль ↔ permission.

Поля:
- `id` UUID PK
- `role_id` UUID FK -> roles.id
- `permission_id` UUID FK -> permissions.id
- `created_at` TIMESTAMPTZ DEFAULT now()

### sessions

Активные сессии пользователя.

Поля:
- `id` UUID PK
- `user_id` UUID FK -> users.id
- `ip_address` TEXT
- `user_agent` TEXT
- `expires_at` TIMESTAMPTZ
- `revoked_at` TIMESTAMPTZ
- `created_at` TIMESTAMPTZ DEFAULT now()

### refresh_tokens

Refresh-токены пользователя.

Поля:
- `id` UUID PK
- `user_id` UUID FK -> users.id
- `token_hash` TEXT NOT NULL
- `expires_at` TIMESTAMPTZ NOT NULL
- `revoked_at` TIMESTAMPTZ
- `created_at` TIMESTAMPTZ DEFAULT now()

### login_attempts

Лог попыток входа.

Поля:
- `id` UUID PK
- `email` TEXT
- `ip_address` TEXT
- `is_success` BOOLEAN NOT NULL
- `user_agent` TEXT
- `created_at` TIMESTAMPTZ DEFAULT now()

---

## 2. Таблицы протоколов и шаблонов

### protocol_categories

Категории протоколов.

Поля:
- `id` UUID PK
- `slug` TEXT UNIQUE NOT NULL
- `name` TEXT NOT NULL
- `description` TEXT
- `sort_order` INTEGER DEFAULT 0
- `created_at` TIMESTAMPTZ DEFAULT now()
- `updated_at` TIMESTAMPTZ DEFAULT now()

Примеры:
- `thyroid`
- `abdominal`
- `kidneys`
- `breast`
- `gynecology`
- `vessels`

### protocol_templates

Карточка шаблона протокола.

Поля:
- `id` UUID PK
- `category_id` UUID FK -> protocol_categories.id
- `slug` TEXT UNIQUE NOT NULL
- `title` TEXT NOT NULL
- `description` TEXT
- `status` TEXT NOT NULL DEFAULT 'draft'
- `current_version_id` UUID NULL
- `created_by` UUID FK -> users.id
- `updated_by` UUID FK -> users.id
- `created_at` TIMESTAMPTZ DEFAULT now()
- `updated_at` TIMESTAMPTZ DEFAULT now()

Статусы:
- `draft`
- `published`
- `archived`

### protocol_template_versions

Версии шаблона.

Поля:
- `id` UUID PK
- `template_id` UUID FK -> protocol_templates.id
- `version_number` INTEGER NOT NULL
- `schema_json` JSONB
- `is_published` BOOLEAN DEFAULT false
- `created_by` UUID FK -> users.id
- `created_at` TIMESTAMPTZ DEFAULT now()

### template_sections

Секции шаблона.

Поля:
- `id` UUID PK
- `template_version_id` UUID FK -> protocol_template_versions.id
- `title` TEXT NOT NULL
- `sort_order` INTEGER DEFAULT 0
- `is_required` BOOLEAN DEFAULT false
- `created_at` TIMESTAMPTZ DEFAULT now()

### template_fields

Поля внутри секции.

Поля:
- `id` UUID PK
- `section_id` UUID FK -> template_sections.id
- `field_key` TEXT NOT NULL
- `label` TEXT NOT NULL
- `field_type` TEXT NOT NULL
- `placeholder` TEXT
- `default_value` TEXT
- `is_required` BOOLEAN DEFAULT false
- `sort_order` INTEGER DEFAULT 0
- `config_json` JSONB
- `created_at` TIMESTAMPTZ DEFAULT now()

Примеры `field_type`:
- `text`
- `textarea`
- `number`
- `select`
- `multiselect`
- `checkbox`
- `radio`

### template_field_options

Опции для select/radio/multiselect.

Поля:
- `id` UUID PK
- `field_id` UUID FK -> template_fields.id
- `value` TEXT NOT NULL
- `label` TEXT NOT NULL
- `sort_order` INTEGER DEFAULT 0
- `created_at` TIMESTAMPTZ DEFAULT now()

---

## 3. Таблицы заключений

### report_drafts

Черновики заключений.

Поля:
- `id` UUID PK
- `template_id` UUID FK -> protocol_templates.id
- `template_version_id` UUID FK -> protocol_template_versions.id
- `author_id` UUID FK -> users.id
- `title` TEXT
- `status` TEXT NOT NULL DEFAULT 'draft'
- `generated_text` TEXT
- `manual_text` TEXT
- `created_at` TIMESTAMPTZ DEFAULT now()
- `updated_at` TIMESTAMPTZ DEFAULT now()

### report_field_values

Значения полей черновика.

Поля:
- `id` UUID PK
- `report_draft_id` UUID FK -> report_drafts.id
- `template_field_id` UUID FK -> template_fields.id
- `value_text` TEXT
- `value_json` JSONB
- `created_at` TIMESTAMPTZ DEFAULT now()
- `updated_at` TIMESTAMPTZ DEFAULT now()

### final_reports

Финальные заключения.

Поля:
- `id` UUID PK
- `draft_id` UUID FK -> report_drafts.id
- `author_id` UUID FK -> users.id
- `final_text` TEXT NOT NULL
- `finalized_at` TIMESTAMPTZ DEFAULT now()
- `created_at` TIMESTAMPTZ DEFAULT now()

---

## 4. Таблицы контента

### material_categories

Категории материалов.

Поля:
- `id` UUID PK
- `slug` TEXT UNIQUE NOT NULL
- `name` TEXT NOT NULL
- `created_at` TIMESTAMPTZ DEFAULT now()

### materials

Материалы библиотеки.

Поля:
- `id` UUID PK
- `category_id` UUID FK -> material_categories.id
- `title` TEXT NOT NULL
- `description` TEXT
- `material_type` TEXT NOT NULL
- `source_name` TEXT
- `source_url` TEXT
- `file_url` TEXT
- `access_level` TEXT DEFAULT 'all'
- `created_by` UUID FK -> users.id
- `created_at` TIMESTAMPTZ DEFAULT now()
- `updated_at` TIMESTAMPTZ DEFAULT now()

Примеры `material_type`:
- `book`
- `guide`
- `presentation`
- `checklist`
- `link`

### articles

Статьи и ссылки.

Поля:
- `id` UUID PK
- `title` TEXT NOT NULL
- `summary` TEXT
- `url` TEXT
- `source_name` TEXT
- `status` TEXT DEFAULT 'draft'
- `published_at` TIMESTAMPTZ
- `created_by` UUID FK -> users.id
- `created_at` TIMESTAMPTZ DEFAULT now()
- `updated_at` TIMESTAMPTZ DEFAULT now()

### article_tags

Теги для статей.

Поля:
- `id` UUID PK
- `article_id` UUID FK -> articles.id
- `tag` TEXT NOT NULL

### events

Мероприятия.

Поля:
- `id` UUID PK
- `title` TEXT NOT NULL
- `description` TEXT
- `event_format` TEXT
- `organizer` TEXT
- `location` TEXT
- `event_url` TEXT
- `starts_at` TIMESTAMPTZ
- `ends_at` TIMESTAMPTZ
- `status` TEXT DEFAULT 'draft'
- `created_by` UUID FK -> users.id
- `created_at` TIMESTAMPTZ DEFAULT now()
- `updated_at` TIMESTAMPTZ DEFAULT now()

### news

Новости.

Поля:
- `id` UUID PK
- `title` TEXT NOT NULL
- `summary` TEXT
- `source_name` TEXT
- `source_url` TEXT
- `status` TEXT DEFAULT 'draft'
- `published_at` TIMESTAMPTZ
- `created_by` UUID FK -> users.id
- `created_at` TIMESTAMPTZ DEFAULT now()
- `updated_at` TIMESTAMPTZ DEFAULT now()

### trends

Тренды.

Поля:
- `id` UUID PK
- `title` TEXT NOT NULL
- `summary` TEXT
- `content` TEXT
- `status` TEXT DEFAULT 'draft'
- `published_at` TIMESTAMPTZ
- `created_by` UUID FK -> users.id
- `created_at` TIMESTAMPTZ DEFAULT now()
- `updated_at` TIMESTAMPTZ DEFAULT now()

### attachments

Файлы-вложения.

Поля:
- `id` UUID PK
- `entity_type` TEXT NOT NULL
- `entity_id` UUID NOT NULL
- `file_name` TEXT NOT NULL
- `file_url` TEXT NOT NULL
- `mime_type` TEXT
- `file_size` BIGINT
- `uploaded_by` UUID FK -> users.id
- `created_at` TIMESTAMPTZ DEFAULT now()

---

## 5. Аудит и системные данные

### audit_logs

Журнал действий.

Поля:
- `id` UUID PK
- `user_id` UUID FK -> users.id
- `action` TEXT NOT NULL
- `entity_type` TEXT NOT NULL
- `entity_id` UUID
- `meta_json` JSONB
- `ip_address` TEXT
- `user_agent` TEXT
- `created_at` TIMESTAMPTZ DEFAULT now()

### system_settings

Системные настройки.

Поля:
- `id` UUID PK
- `key` TEXT UNIQUE NOT NULL
- `value_json` JSONB NOT NULL
- `updated_by` UUID FK -> users.id
- `updated_at` TIMESTAMPTZ DEFAULT now()

---

## Первичные индексы и рекомендации

Рекомендуется добавить индексы на:
- `users.email`
- `roles.code`
- `permissions.code`
- `protocol_categories.slug`
- `protocol_templates.slug`
- `materials.title`
- `articles.title`
- `events.starts_at`
- `news.published_at`
- `audit_logs.created_at`
- `audit_logs.user_id`

## Дальнейшие шаги

Следующий шаг после этого документа:
1. уточнить связи и nullable-поля;
2. определить enum-значения;
3. выбрать подход: Prisma, Drizzle или SQL-миграции;
4. подготовить первую SQL/ORM-схему;
5. потом описать API endpoints.