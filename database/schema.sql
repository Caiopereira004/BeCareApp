CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    lgpd_accepted BOOLEAN DEFAULT TRUE,
    skin_type VARCHAR(60),
    skin_goal VARCHAR(120),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE glow_fridges (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    temperature DECIMAL(4,1) DEFAULT 6.0,
    mode VARCHAR(30) DEFAULT 'Ideal',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(140) NOT NULL,
    category VARCHAR(60) NOT NULL,
    partner_brand VARCHAR(80),
    skin_profile VARCHAR(60),
    price DECIMAL(10,2) NOT NULL
);
