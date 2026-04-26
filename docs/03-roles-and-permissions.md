# Роли и права

## Активные роли этапа 1

На этапе 1 используются две активные роли:

- `doctor`
- `owner`

## Принцип расширяемости

Несмотря на то что в MVP используются только две роли, архитектура должна
поддерживать расширение количества ролей в будущем без переписывания всей
системы доступа.

Возможные будущие роли:
- `head`
- `editor`
- `reviewer`
- `content_manager`
- `superadmin`

## Описание ролей

### doctor

Врач УЗИ, который:
- использует готовые шаблоны;
- создает заключения;
- редактирует свои черновики;
- просматривает материалы и информационные разделы.

### owner

Владелец системы, который:
- управляет шаблонами;
- управляет пользователями;
- управляет контентом;
- управляет настройками системы;
- просматривает аудит и системные логи.

## Базовые permissions

- `protocol.read`
- `report.create`
- `report.read_own`
- `report.update_own`
- `template.read`
- `template.manage`
- `materials.read`
- `materials.manage`
- `content.manage`
- `events.manage`
- `users.manage`
- `roles.manage`
- `settings.manage`
- `audit.read`

## Матрица доступа

| Permission | doctor | owner |
|------------|--------|-------|
| protocol.read | Да | Да |
| report.create | Да | Да |
| report.read_own | Да | Да |
| report.update_own | Да | Да |
| template.read | Да | Да |
| template.manage | Нет | Да |
| materials.read | Да | Да |
| materials.manage | Нет | Да |
| content.manage | Нет | Да |
| events.manage | Нет | Да |
| users.manage | Нет | Да |
| roles.manage | Нет | Да |
| settings.manage | Нет | Да |
| audit.read | Нет / ограниченно | Да |

## Подход к реализации

Для реализации доступа рекомендуется использовать RBAC-модель с отдельными
сущностями:
- users
- roles
- permissions
- user_roles
- role_permissions