# Структура backend

## Назначение документа

Документ описывает рекомендуемую архитектуру backend-части проекта USD Portal
для этапа 1 MVP.

## Технологическая основа

Для backend планируется использовать:

- Node.js
- TypeScript
- Express
- PostgreSQL
- `pg` для работы с базой данных

## Общий подход

На этапе 1 для backend используется понятная и практичная структура:

- `routes`
- `services`
- `models`

Такой подход выбран потому, что он уже знаком по предыдущим проектам,
позволяет быстро стартовать и хорошо подходит для MVP, если аккуратно
разделять ответственность между слоями.

## Почему без ORM

На текущем этапе ORM вроде Prisma или Drizzle не является обязательным.
Проект можно уверенно начать на PostgreSQL + `pg`, если:
- SQL-запросы хранятся организованно;
- логика работы с БД вынесена в `models`;
- бизнес-логика не смешивается с `routes`;
- доступ к данным проходит через отдельный слой.

ORM может быть рассмотрен позже, если проект вырастет и появится
необходимость ускорить миграции, генерацию схем или работу с большим
числом сущностей.

## Архитектурные принципы

- `routes` отвечают за HTTP-маршруты и связывают запрос с service;
- `services` содержат бизнес-логику;
- `models` работают с PostgreSQL;
- middleware отвечают за auth, permissions, rate limiting, validation и обработку ошибок;
- общие типы и утилиты выносятся отдельно;
- безопасность проверяется на backend, а не только на frontend.

## Рекомендуемая структура backend

```text
backend/
├── package.json
├── tsconfig.json
├── .env.example
├── src/
│   ├── app.ts
│   ├── server.ts
│   ├── config/
│   │   ├── env.ts
│   │   ├── db.ts
│   │   ├── logger.ts
│   │   └── security.ts
│   ├── middlewares/
│   │   ├── auth.ts
│   │   ├── permissions.ts
│   │   ├── errorHandler.ts
│   │   ├── rateLimit.ts
│   │   └── validate.ts
│   ├── routes/
│   │   ├── auth.routes.ts
│   │   ├── users.routes.ts
│   │   ├── roles.routes.ts
│   │   ├── protocolCategories.routes.ts
│   │   ├── templates.routes.ts
│   │   ├── reports.routes.ts
│   │   ├── materials.routes.ts
│   │   ├── articles.routes.ts
│   │   ├── events.routes.ts
│   │   ├── news.routes.ts
│   │   ├── trends.routes.ts
│   │   ├── audit.routes.ts
│   │   └── settings.routes.ts
│   ├── services/
│   │   ├── auth.service.ts
│   │   ├── users.service.ts
│   │   ├── roles.service.ts
│   │   ├── protocolCategories.service.ts
│   │   ├── templates.service.ts
│   │   ├── reports.service.ts
│   │   ├── materials.service.ts
│   │   ├── articles.service.ts
│   │   ├── events.service.ts
│   │   ├── news.service.ts
│   │   ├── trends.service.ts
│   │   ├── audit.service.ts
│   │   └── settings.service.ts
│   ├── models/
│   │   ├── user.model.ts
│   │   ├── role.model.ts
│   │   ├── permission.model.ts
│   │   ├── protocolCategory.model.ts
│   │   ├── template.model.ts
│   │   ├── templateVersion.model.ts
│   │   ├── reportDraft.model.ts
│   │   ├── finalReport.model.ts
│   │   ├── material.model.ts
│   │   ├── article.model.ts
│   │   ├── event.model.ts
│   │   ├── news.model.ts
│   │   ├── trend.model.ts
│   │   ├── auditLog.model.ts
│   │   └── settings.model.ts
│   ├── types/
│   │   ├── auth.types.ts
│   │   ├── user.types.ts
│   │   ├── template.types.ts
│   │   ├── report.types.ts
│   │   └── common.types.ts
│   ├── utils/
│   │   ├── password.ts
│   │   ├── tokens.ts
│   │   ├── permissions.ts
│   │   ├── dates.ts
│   │   └── responses.ts
│   └── tests/
│       ├── unit/
│       └── integration/
```

## Назначение основных слоев

### `routes/`

Папка `routes` описывает HTTP endpoints:
- path;
- method;
- middleware;
- вызов нужного service.

В `routes` не должно быть сложной бизнес-логики и SQL-запросов.

### `services/`

Папка `services` содержит основную бизнес-логику:
- проверка сценариев;
- вызов model-функций;
- проверка прав;
- формирование итогового результата;
- логирование действий в аудит.

Именно `services` являются главным рабочим слоем приложения.

### `models/`

Папка `models` отвечает за доступ к базе данных:
- SQL-запросы;
- выборка данных;
- вставка;
- обновление;
- удаление;
- базовые функции поиска и фильтрации.

В `models` не должно быть сложной бизнес-логики.

## Поток запроса

Базовый поток запроса должен быть таким:

`route -> middleware -> service -> model -> PostgreSQL`

Пример:
1. запрос приходит в `templates.routes.ts`;
2. route вызывает middleware авторизации;
3. route вызывает `templates.service.ts`;
4. service проверяет бизнес-правила;
5. service вызывает `template.model.ts`;
6. model выполняет SQL-запрос через `pg`;
7. результат возвращается обратно через service в response.

## Что хранить в `config/`

### `env.ts`
Чтение и проверка переменных окружения.

### `db.ts`
Подключение к PostgreSQL через `pg.Pool`.

### `logger.ts`
Базовый логгер приложения.

### `security.ts`
Общие security-настройки:
- token lifetime;
- password policy;
- cookie settings;
- CORS policy;
- rate limit config.

## Что хранить в `middlewares/`

### `auth.ts`
Проверка access token и извлечение пользователя из запроса.

### `permissions.ts`
Проверка permissions перед доступом к защищенным endpoint.

### `errorHandler.ts`
Централизованная обработка ошибок.

### `rateLimit.ts`
Ограничение частоты запросов.

### `validate.ts`
Проверка body, params и query.

## Что хранить в `utils/`

В `utils` стоит выносить только действительно переиспользуемые вещи:
- хеширование пароля;
- генерация токенов;
- проверка permissions;
- дата/время;
- helper-функции для API responses.

## Нужно ли использовать controllers

На этапе 1 controllers не являются обязательными.
Можно использовать более простой и привычный поток:

`routes -> services -> models`

Если позже `routes` начнут разрастаться, можно добавить слой `controllers`
без полной перестройки архитектуры.

## Подход к SQL

На этапе 1 рекомендуется:
- писать SQL-запросы явно;
- использовать параметризованные запросы;
- не собирать SQL через небезопасные строковые конкатенации;
- хранить SQL-логику внутри `models`.

Это особенно важно для безопасности и предсказуемости backend.

## Рекомендации по безопасности backend

Backend должен с самого начала поддерживать:
- безопасную аутентификацию;
- хранение паролей только в виде hash;
- refresh token / session management;
- RBAC + permissions;
- аудит действий;
- rate limiting;
- валидацию входных данных;
- защиту от доступа к чужим данным;
- обработку ошибок без утечки внутренних деталей.

## Что реализовывать первым

Рекомендуемый порядок разработки backend:

1. базовый Express-каркас;
2. env и db config;
3. auth;
4. users;
5. roles / permissions;
6. protocol categories;
7. templates;
8. reports;
9. materials;
10. articles / events / news / trends;
11. audit;
12. settings.

## Что не усложнять на старте

На этапе 1 не стоит:
- вводить ORM только ради “современности”;
- строить сложную многоуровневую clean architecture;
- делать микросервисы;
- добавлять лишние абстракции;
- усложнять flow запроса.

Главная цель — понятный, безопасный и поддерживаемый MVP backend.