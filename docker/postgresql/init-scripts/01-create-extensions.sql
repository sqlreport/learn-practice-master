-- 01-create-extensions.sql
-- Enable required PostgreSQL extensions

-- UUID extension for generating UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Crypto extension for encryption functions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Full-text search extension (usually enabled by default)
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Additional useful extensions
CREATE EXTENSION IF NOT EXISTS "unaccent";

-- Log the extensions creation
DO $$
BEGIN
    RAISE NOTICE 'PostgreSQL extensions created successfully';
END $$;