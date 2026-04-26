# Черновик API спецификации

## Назначение документа

Документ описывает предварительную REST API-структуру backend для проекта USD Portal
на этапе 1 MVP.

## Общие принципы API

- Базовый префикс API: `/api`
- Формат обмена: JSON
- Аутентификация: access token + refresh token
- Авторизация: RBAC + permissions
- Проверка прав выполняется на backend
- Все защищенные endpoint требуют аутентификации, кроме login/refresh/logout по соответствующим правилам

## Общие соглашения

### Статусы ответа
- `200 OK` — успешный запрос
- `201 Created` — ресурс создан
- `204 No Content` — успешное удаление без тела ответа
- `400 Bad Request` — ошибка входных данных
- `401 Unauthorized` — пользователь не аутентифицирован
- `403 Forbidden` — недостаточно прав
- `404 Not Found` — ресурс не найден
- `409 Conflict` — конфликт состояния
- `422 Unprocessable Entity` — ошибка валидации
- `500 Internal Server Error` — внутренняя ошибка

### Общий формат ошибок

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": []
  }
}
```

### Общий формат успешного ответа

```json
{
  "data": {}
}
```

---

## 1. Auth

### POST `/api/auth/login`
Вход пользователя в систему.

#### Request
```json
{
  "email": "user@example.com",
  "password": "secret"
}
```

#### Response `200`
```json
{
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "firstName": "Ivan",
      "lastName": "Ivanov",
      "roles": ["owner"]
    },
    "accessToken": "jwt-token"
  }
}
```

#### Errors
- `401 Unauthorized`
- `422 Unprocessable Entity`

### POST `/api/auth/refresh`
Обновление access token по refresh token.

#### Response `200`
```json
{
  "data": {
    "accessToken": "new-jwt-token"
  }
}
```

### POST `/api/auth/logout`
Выход из системы и инвалидирование refresh token / session.

#### Response `204`

### GET `/api/auth/me`
Получение текущего пользователя.

#### Response `200`
```json
{
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "firstName": "Ivan",
    "lastName": "Ivanov",
    "roles": ["doctor"],
    "permissions": ["protocol.read", "report.create"]
  }
}
```

---

## 2. Users

### GET `/api/users`
Список пользователей.

Доступ:
- `users.manage`

#### Query params
- `search`
- `isActive`
- `page`
- `limit`

### POST `/api/users`
Создание пользователя.

Доступ:
- `users.manage`

#### Request
```json
{
  "email": "doctor@example.com",
  "password": "secret123",
  "firstName": "Dmitry",
  "lastName": "K",
  "roleCodes": ["doctor"]
}
```

### GET `/api/users/:id`
Получение пользователя по id.

Доступ:
- `users.manage`

### PATCH `/api/users/:id`
Обновление пользователя.

Доступ:
- `users.manage`

### PATCH `/api/users/:id/status`
Активация / деактивация пользователя.

Доступ:
- `users.manage`

---

## 3. Roles and permissions

### GET `/api/roles`
Получение списка ролей.

Доступ:
- `roles.manage`

### GET `/api/permissions`
Получение списка permissions.

Доступ:
- `roles.manage`

### PATCH `/api/users/:id/roles`
Назначение ролей пользователю.

Доступ:
- `roles.manage`

#### Request
```json
{
  "roleCodes": ["doctor"]
}
```

---

## 4. Protocol categories

### GET `/api/protocol-categories`
Получение списка категорий протоколов.

Доступ:
- `protocol.read`

### POST `/api/protocol-categories`
Создание категории протокола.

Доступ:
- `template.manage`

---

## 5. Protocol templates

### GET `/api/templates`
Получение списка шаблонов.

Доступ:
- `template.read`

#### Query params
- `categoryId`
- `status`
- `search`
- `page`
- `limit`

### POST `/api/templates`
Создание шаблона.

Доступ:
- `template.manage`

#### Request
```json
{
  "categoryId": "uuid",
  "slug": "thyroid-basic",
  "title": "Щитовидная железа — базовый шаблон",
  "description": "Базовый шаблон исследования щитовидной железы"
}
```

### GET `/api/templates/:id`
Получение шаблона по id.

Доступ:
- `template.read`

### PATCH `/api/templates/:id`
Обновление карточки шаблона.

Доступ:
- `template.manage`

### PATCH `/api/templates/:id/status`
Изменение статуса шаблона.

Доступ:
- `template.manage`

#### Request
```json
{
  "status": "published"
}
```

### DELETE `/api/templates/:id`
Удаление / архивирование шаблона.

Доступ:
- `template.manage`

---

## 6. Template versions

### GET `/api/templates/:id/versions`
Получение версий шаблона.

Доступ:
- `template.read`

### POST `/api/templates/:id/versions`
Создание новой версии шаблона.

Доступ:
- `template.manage`

#### Request
```json
{
  "versionNumber": 2,
  "schema": {
    "sections": []
  }
}
```

### GET `/api/template-versions/:id`
Получение версии шаблона.

Доступ:
- `template.read`

### PATCH `/api/template-versions/:id`
Обновление версии шаблона.

Доступ:
- `template.manage`

### PATCH `/api/template-versions/:id/publish`
Публикация версии шаблона.

Доступ:
- `template.manage`

---

## 7. Reports

### GET `/api/reports`
Получение списка отчетов / заключений.

Доступ:
- `report.read_own` или расширенный доступ владельца

#### Query params
- `status`
- `templateId`
- `authorId`
- `page`
- `limit`

### POST `/api/reports`
Создание черновика заключения.

Доступ:
- `report.create`

#### Request
```json
{
  "templateId": "uuid",
  "templateVersionId": "uuid",
  "title": "УЗИ щитовидной железы"
}
```

### GET `/api/reports/:id`
Получение черновика / отчета.

Доступ:
- владелец или автор

### PATCH `/api/reports/:id`
Обновление черновика.

Доступ:
- владелец или автор

#### Request
```json
{
  "generatedText": "....",
  "manualText": "....",
  "fieldValues": [
    {
      "templateFieldId": "uuid",
      "valueText": "..."
    }
  ]
}
```

### POST `/api/reports/:id/finalize`
Фиксация финальной версии заключения.

Доступ:
- владелец или автор

### GET `/api/final-reports/:id`
Получение финального заключения.

Доступ:
- владелец или автор

---

## 8. Materials

### GET `/api/materials`
Получение списка материалов.

Доступ:
- `materials.read`

#### Query params
- `categoryId`
- `materialType`
- `search`
- `page`
- `limit`

### POST `/api/materials`
Создание материала.

Доступ:
- `materials.manage`

### GET `/api/materials/:id`
Получение материала.

Доступ:
- `materials.read`

### PATCH `/api/materials/:id`
Обновление материала.

Доступ:
- `materials.manage`

### DELETE `/api/materials/:id`
Удаление материала.

Доступ:
- `materials.manage`

---

## 9. Articles

### GET `/api/articles`
Список статей и ссылок.

### POST `/api/articles`
Создание статьи / ссылки.

Доступ:
- `content.manage`

### GET `/api/articles/:id`
Получение статьи.

### PATCH `/api/articles/:id`
Обновление статьи.

Доступ:
- `content.manage`

### DELETE `/api/articles/:id`
Удаление статьи.

Доступ:
- `content.manage`

---

## 10. Events

### GET `/api/events`
Список мероприятий.

### POST `/api/events`
Создание мероприятия.

Доступ:
- `events.manage`

### GET `/api/events/:id`
Получение мероприятия.

### PATCH `/api/events/:id`
Обновление мероприятия.

Доступ:
- `events.manage`

### DELETE `/api/events/:id`
Удаление мероприятия.

Доступ:
- `events.manage`

---

## 11. News

### GET `/api/news`
Список новостей.

### POST `/api/news`
Создание новости.

Доступ:
- `content.manage`

### GET `/api/news/:id`
Получение новости.

### PATCH `/api/news/:id`
Обновление новости.

Доступ:
- `content.manage`

### DELETE `/api/news/:id`
Удаление новости.

Доступ:
- `content.manage`

---

## 12. Trends

### GET `/api/trends`
Список трендов.

### POST `/api/trends`
Создание тренда.

Доступ:
- `content.manage`

### GET `/api/trends/:id`
Получение тренда.

### PATCH `/api/trends/:id`
Обновление тренда.

Доступ:
- `content.manage`

### DELETE `/api/trends/:id`
Удаление тренда.

Доступ:
- `content.manage`

---

## 13. Attachments

### POST `/api/attachments`
Загрузка файла.

Доступ:
- зависит от сущности, к которой прикрепляется файл

### DELETE `/api/attachments/:id`
Удаление файла.

Доступ:
- владелец или пользователь с правом управления сущностью

---

## 14. Audit

### GET `/api/audit-logs`
Получение журнала действий.

Доступ:
- `audit.read`

#### Query params
- `userId`
- `entityType`
- `action`
- `dateFrom`
- `dateTo`
- `page`
- `limit`

---

## 15. Settings

### GET `/api/settings`
Получение системных настроек.

Доступ:
- `settings.manage`

### PATCH `/api/settings`
Обновление системных настроек.

Доступ:
- `settings.manage`

---

## Минимальные требования безопасности API

- каждый защищенный endpoint должен проверять access token;
- каждый чувствительный endpoint должен проверять permissions;
- нельзя полагаться только на скрытие кнопок на frontend;
- нужно валидировать body, params и query;
- нужно логировать чувствительные действия;
- ошибки не должны раскрывать внутреннюю структуру системы;
- нужна защита от mass assignment;
- нужно тестировать доступ к чужим объектам и привилегированным endpoint;
- все запросы должны идти по HTTPS в production.

## Следующий шаг

После этого документа следующим шагом логично подготовить:
1. backend project structure;
2. frontend structure;
3. стартовую схему Prisma или SQL-миграций;
4. каркас auth-модуля.