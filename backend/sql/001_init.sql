CREATE EXTENSION IF NOT EXISTS pgcrypto;

BEGIN;

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(50) NOT NULL UNIQUE,
  title VARCHAR(100) NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(100) NOT NULL UNIQUE,
  title VARCHAR(150) NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE user_roles (
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, role_id)
);

CREATE TABLE role_permissions (
  role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
  permission_id UUID NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE protocol_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(100) NOT NULL UNIQUE,
  title VARCHAR(150) NOT NULL,
  description TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE protocol_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID REFERENCES protocol_categories(id) ON DELETE SET NULL,
  slug VARCHAR(150) NOT NULL UNIQUE,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  status TEXT NOT NULL DEFAULT 'draft',
  created_by UUID REFERENCES users(id) ON DELETE SET NULL,
  updated_by UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT protocol_templates_status_check
    CHECK (status IN ('draft', 'published', 'archived'))
);

CREATE TABLE protocol_template_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_id UUID NOT NULL REFERENCES protocol_templates(id) ON DELETE CASCADE,
  version_number INTEGER NOT NULL,
  is_published BOOLEAN NOT NULL DEFAULT FALSE,
  schema_json JSONB,
  notes TEXT,
  created_by UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT protocol_template_versions_version_positive_check
    CHECK (version_number > 0),
  CONSTRAINT protocol_template_versions_unique_version
    UNIQUE (template_id, version_number)
);

CREATE TABLE protocol_template_sections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_version_id UUID NOT NULL REFERENCES protocol_template_versions(id) ON DELETE CASCADE,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE protocol_template_fields (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  section_id UUID NOT NULL REFERENCES protocol_template_sections(id) ON DELETE CASCADE,
  field_code VARCHAR(150) NOT NULL,
  label VARCHAR(200) NOT NULL,
  field_type TEXT NOT NULL,
  is_required BOOLEAN NOT NULL DEFAULT FALSE,
  default_value TEXT,
  options_json JSONB,
  placeholder TEXT,
  help_text TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT protocol_template_fields_field_type_check
    CHECK (
      field_type IN (
        'text',
        'number',
        'textarea',
        'select',
        'multiselect',
        'checkbox',
        'radio',
        'date',
        'free_text'
      )
    ),
  CONSTRAINT protocol_template_fields_unique_code_per_section
    UNIQUE (section_id, field_code)
);

CREATE TABLE storage_objects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bucket VARCHAR(255) NOT NULL,
  object_key TEXT NOT NULL UNIQUE,
  original_name VARCHAR(255) NOT NULL,
  mime_type VARCHAR(255),
  size_bytes BIGINT NOT NULL DEFAULT 0,
  etag VARCHAR(255),
  uploaded_by UUID REFERENCES users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT storage_objects_size_bytes_check
    CHECK (size_bytes >= 0)
);

CREATE TABLE protocol_template_files (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_version_id UUID NOT NULL REFERENCES protocol_template_versions(id) ON DELETE CASCADE,
  storage_object_id UUID NOT NULL REFERENCES storage_objects(id) ON DELETE CASCADE,
  file_type TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT protocol_template_files_file_type_check
    CHECK (file_type IN ('docx', 'pdf', 'json', 'html'))
);

CREATE INDEX idx_users_email ON users(email);

CREATE INDEX idx_roles_code ON roles(code);
CREATE INDEX idx_permissions_code ON permissions(code);

CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX idx_user_roles_role_id ON user_roles(role_id);

CREATE INDEX idx_role_permissions_role_id ON role_permissions(role_id);
CREATE INDEX idx_role_permissions_permission_id ON role_permissions(permission_id);

CREATE INDEX idx_protocol_categories_code ON protocol_categories(code);
CREATE INDEX idx_protocol_categories_sort_order ON protocol_categories(sort_order);

CREATE INDEX idx_protocol_templates_category_id ON protocol_templates(category_id);
CREATE INDEX idx_protocol_templates_slug ON protocol_templates(slug);
CREATE INDEX idx_protocol_templates_status ON protocol_templates(status);
CREATE INDEX idx_protocol_templates_created_by ON protocol_templates(created_by);
CREATE INDEX idx_protocol_templates_updated_by ON protocol_templates(updated_by);

CREATE INDEX idx_protocol_template_versions_template_id ON protocol_template_versions(template_id);
CREATE INDEX idx_protocol_template_versions_created_by ON protocol_template_versions(created_by);
CREATE INDEX idx_protocol_template_versions_is_published ON protocol_template_versions(is_published);

CREATE INDEX idx_protocol_template_sections_template_version_id
  ON protocol_template_sections(template_version_id);
CREATE INDEX idx_protocol_template_sections_sort_order
  ON protocol_template_sections(template_version_id, sort_order);

CREATE INDEX idx_protocol_template_fields_section_id
  ON protocol_template_fields(section_id);
CREATE INDEX idx_protocol_template_fields_sort_order
  ON protocol_template_fields(section_id, sort_order);
CREATE INDEX idx_protocol_template_fields_field_type
  ON protocol_template_fields(field_type);

CREATE INDEX idx_storage_objects_uploaded_by ON storage_objects(uploaded_by);
CREATE INDEX idx_storage_objects_bucket ON storage_objects(bucket);
CREATE INDEX idx_storage_objects_created_at ON storage_objects(created_at);

CREATE INDEX idx_protocol_template_files_template_version_id
  ON protocol_template_files(template_version_id);
CREATE INDEX idx_protocol_template_files_storage_object_id
  ON protocol_template_files(storage_object_id);
CREATE INDEX idx_protocol_template_files_file_type
  ON protocol_template_files(file_type);

COMMIT;