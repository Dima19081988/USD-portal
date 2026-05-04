BEGIN;

INSERT INTO roles (code, title, description)
VALUES
  ('owner',  'Owner',  'Full access to all portal features'),
  ('doctor', 'Doctor', 'Ultrasound doctor workflow access')
ON CONFLICT (code) DO NOTHING;

INSERT INTO permissions (code, title, description)
VALUES
  ('templates.view',    'View templates',         'View template list and details'),
  ('templates.manage',  'Manage templates',       'Create, edit, archive templates'),
  ('templates.publish', 'Publish templates',      'Publish templates and change status'),
  ('templates.files',   'Export templates',       'Generate and download template files'),

  ('reports.create',    'Create reports',         'Create working reports from templates'),
  ('reports.edit',      'Edit reports',           'Edit draft reports'),
  ('reports.finalize',  'Finalize reports',       'Approve final report text'),
  ('reports.files',     'Export reports',         'Generate and download report files'),

  ('cases.view',        'View cases',             'View internal interesting cases'),
  ('cases.manage',      'Manage cases',           'Create and edit cases, upload images'),

  ('storage.manage',    'Manage storage objects', 'Work with file storage objects')
ON CONFLICT (code) DO NOTHING;

INSERT INTO role_permissions (role_id, permission_id, created_at)
SELECT r.id, p.id, NOW()
FROM roles r
JOIN permissions p ON p.code IN (
  'templates.view',
  'templates.manage',
  'templates.publish',
  'templates.files',
  'reports.create',
  'reports.edit',
  'reports.finalize',
  'reports.files',
  'cases.view',
  'cases.manage',
  'storage.manage'
)
WHERE r.code = 'owner'
ON CONFLICT (role_id, permission_id) DO NOTHING;

INSERT INTO role_permissions (role_id, permission_id, created_at)
SELECT r.id, p.id, NOW()
FROM roles r
JOIN permissions p ON p.code IN (
  'templates.view',
  'reports.create',
  'reports.edit',
  'reports.finalize',
  'reports.files',
  'cases.view',
  'cases.manage'
)
WHERE r.code = 'doctor'
ON CONFLICT (role_id, permission_id) DO NOTHING;

INSERT INTO users (email, password_hash, first_name, last_name, is_active, created_at, updated_at)
VALUES
  ('owner@example.local',  'changeme', 'Owner',  'User', TRUE, NOW(), NOW()),
  ('doctor@example.local', 'changeme', 'Doctor', 'User', TRUE, NOW(), NOW())
ON CONFLICT (email) DO NOTHING;

INSERT INTO user_roles (user_id, role_id, created_at)
SELECT u.id, r.id, NOW()
FROM users u
JOIN roles r ON r.code = 'owner'
WHERE u.email = 'owner@example.local'
ON CONFLICT (user_id, role_id) DO NOTHING;

INSERT INTO user_roles (user_id, role_id, created_at)
SELECT u.id, r.id, NOW()
FROM users u
JOIN roles r ON r.code = 'doctor'
WHERE u.email = 'doctor@example.local'
ON CONFLICT (user_id, role_id) DO NOTHING;

INSERT INTO protocol_categories (code, title, description, sort_order, created_at)
VALUES
  ('thyroid',    'Thyroid',          'Thyroid ultrasound protocols',       10, NOW()),
  ('abdomen',    'Abdominal organs', 'Abdominal ultrasound protocols',     20, NOW()),
  ('kidneys',    'Kidneys',          'Kidney and urinary tract protocols', 30, NOW()),
  ('breast',     'Breast',           'Breast ultrasound protocols',        40, NOW()),
  ('gynecology', 'Gynecology',       'Gynecology ultrasound protocols',    50, NOW()),
  ('vessels',    'Vessels',          'Vascular ultrasound protocols',      60, NOW())
ON CONFLICT (code) DO NOTHING;

COMMIT;