-- SQL Schema for Bakery Website Database (MySQL and H2 compatible)

-- Table for Users (Admin and Customer accounts)
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    fullname VARCHAR(100),
    phone VARCHAR(20),
    role VARCHAR(20) NOT NULL,
    created_at VARCHAR(50) NOT NULL
);

-- Table for Orders
CREATE TABLE IF NOT EXISTS orders (
    id VARCHAR(50) PRIMARY KEY,
    status VARCHAR(20) NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    delivery_method VARCHAR(20) NOT NULL,
    delivery_address VARCHAR(255),
    pickup_time VARCHAR(50),
    latitude DOUBLE,
    longitude DOUBLE,
    subtotal INT NOT NULL,
    shipping_fee INT NOT NULL,
    total INT NOT NULL,
    created_at VARCHAR(50) NOT NULL,
    note VARCHAR(500),
    user_id INT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Table for Order Items
CREATE TABLE IF NOT EXISTS order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    qty INT NOT NULL,
    price INT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

-- Table for Products
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    price INT NOT NULL,
    description VARCHAR(255),
    image_url VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- Table for Agents (Wholesale)
CREATE TABLE IF NOT EXISTS agents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL UNIQUE,
    shop_name VARCHAR(150) NOT NULL,
    address VARCHAR(255) NOT NULL,
    latitude DOUBLE NOT NULL,
    longitude DOUBLE NOT NULL,
    password VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_at VARCHAR(50) NOT NULL
);

-- Seed default admin user (admin / admin123)
INSERT INTO users (username, password, fullname, phone, role, created_at) 
VALUES ('admin', 'admin123', 'Quản trị viên', NULL, 'ADMIN', '2026-06-14 12:00');

-- Seed default test customer user (user / user123)
INSERT INTO users (username, password, fullname, phone, role, created_at) 
VALUES ('user', 'user123', 'Khách Hàng Thử Nghiệm', '0779409567', 'CUSTOMER', '2026-06-14 12:00');
