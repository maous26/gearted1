-- PostgreSQL schema for gear compatibility system

-- Manufacturers table
CREATE TABLE IF NOT EXISTS manufacturers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    brand_code VARCHAR(50) NOT NULL,
    country VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Equipment Types table
CREATE TABLE IF NOT EXISTS equipment_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL,
    parent_id INTEGER REFERENCES equipment_types(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Equipment Categories table
CREATE TABLE IF NOT EXISTS equipment_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL,
    type_id INTEGER REFERENCES equipment_types(id) ON DELETE CASCADE NOT NULL,
    standard VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Equipment table
CREATE TABLE IF NOT EXISTS equipment (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    model VARCHAR(255) NOT NULL,
    manufacturer_id INTEGER REFERENCES manufacturers(id) ON DELETE CASCADE NOT NULL,
    category_id INTEGER REFERENCES equipment_categories(id) ON DELETE CASCADE NOT NULL,
    sku VARCHAR(100),
    weight INTEGER,  -- in grams
    length INTEGER,  -- in millimeters
    power_source VARCHAR(100),
    price_range VARCHAR(50),
    image_url VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    views INTEGER DEFAULT 0,  -- For analytics and optimization
    last_viewed_at TIMESTAMP WITH TIME ZONE  -- For hot/cold data strategy
);

-- Compatibility Rules table
CREATE TABLE IF NOT EXISTS compatibility_rules (
    id SERIAL PRIMARY KEY,
    source_equipment_id INTEGER REFERENCES equipment(id) ON DELETE CASCADE NOT NULL,
    target_equipment_id INTEGER REFERENCES equipment(id) ON DELETE CASCADE NOT NULL,
    compatibility_type VARCHAR(50) NOT NULL,  -- COMPATIBLE, REQUIRES_MODIFICATION, INCOMPATIBLE
    confidence_level VARCHAR(50) NOT NULL,    -- LOW, MEDIUM, HIGH, OFFICIAL
    compatibility_percentage INTEGER CHECK (compatibility_percentage BETWEEN 0 AND 100),
    source_type VARCHAR(50) NOT NULL,        -- OFFICIAL, USER_TESTED, COMMUNITY
    notes TEXT,
    modification_required TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(255),  -- User who created the rule
    check_count INTEGER DEFAULT 0,  -- How many times this compatibility has been checked
    last_checked_at TIMESTAMP WITH TIME ZONE,  -- For hot/cold data strategy
    UNIQUE (source_equipment_id, target_equipment_id)
);

-- User Compatibility Verifications table
CREATE TABLE IF NOT EXISTS user_compatibility_verifications (
    id SERIAL PRIMARY KEY,
    compatibility_rule_id INTEGER REFERENCES compatibility_rules(id) ON DELETE CASCADE NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    verification_type VARCHAR(50) NOT NULL,  -- CONFIRMED, DISPUTED
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Compatibility Analytics table
CREATE TABLE IF NOT EXISTS compatibility_analytics (
    id SERIAL PRIMARY KEY,
    source_equipment_id INTEGER REFERENCES equipment(id) ON DELETE CASCADE NOT NULL,
    target_equipment_id INTEGER REFERENCES equipment(id) ON DELETE CASCADE NOT NULL,
    user_id VARCHAR(255),
    check_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    source VARCHAR(50) NOT NULL,  -- APP, API, WEBSITE
    session_id VARCHAR(255)
);

-- Cold Data Archive table (references for data in S3)
CREATE TABLE IF NOT EXISTS cold_data_archives (
    id SERIAL PRIMARY KEY,
    data_type VARCHAR(50) NOT NULL,
    s3_key VARCHAR(255) NOT NULL,
    original_table VARCHAR(50) NOT NULL,
    record_count INTEGER NOT NULL,
    date_range_start TIMESTAMP WITH TIME ZONE,
    date_range_end TIMESTAMP WITH TIME ZONE,
    archived_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'ACTIVE'
);

-- Indexes for performance optimization
CREATE INDEX IF NOT EXISTS idx_equipment_manufacturer ON equipment(manufacturer_id);
CREATE INDEX IF NOT EXISTS idx_equipment_category ON equipment(category_id);
CREATE INDEX IF NOT EXISTS idx_compatibility_source ON compatibility_rules(source_equipment_id);
CREATE INDEX IF NOT EXISTS idx_compatibility_target ON compatibility_rules(target_equipment_id);
CREATE INDEX IF NOT EXISTS idx_analytics_equipment_pair ON compatibility_analytics(source_equipment_id, target_equipment_id);
CREATE INDEX IF NOT EXISTS idx_equipment_last_viewed ON equipment(last_viewed_at);
CREATE INDEX IF NOT EXISTS idx_compatibility_last_checked ON compatibility_rules(last_checked_at);
