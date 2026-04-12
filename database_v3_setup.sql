-- Drop the old database completely to avoid conflicts
DROP DATABASE IF EXISTS ecom_db;
CREATE DATABASE ecom_db;
USE ecom_db;

-- 1. Authentication Table (V3 with Phone and Address)
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  phone VARCHAR(50) NOT NULL,
  address TEXT NOT NULL
);

-- 2. Enhanced Products Table
CREATE TABLE IF NOT EXISTS products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  price DECIMAL(10, 2) NOT NULL
);

-- 3. Enhanced Orders Table
CREATE TABLE IF NOT EXISTS orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  items TEXT NOT NULL,
  total DECIMAL(10, 2) NOT NULL,
  status VARCHAR(50) DEFAULT 'Pending',
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Insert 10 dummy products with descriptions
INSERT INTO products (name, description, price) VALUES 
('Laptop Pro 15"', 'High performance laptop with 16GB RAM, 512GB SSD, and powerful dedicated graphics for professional workloads.', 250000.00),
('Smartphone X', 'Latest generation smartphone featuring an edge-to-edge OLED display and a revolutionary new dual-camera system.', 150000.00),
('Wireless Headphones', 'Noise-cancelling over-ear headphones with 40 hours of battery life and studio-quality sound.', 25000.00),
('Smart Watch Series 5', 'Track your fitness, heart rate, and notifications on the go with a sleek, water-resistant aluminum body.', 45000.00),
('DSLR Camera 4K', 'Capture stunning ultra-HD video and 24MP photos. Includes an interchangeable 50mm lens and robust auto-focus.', 180000.00),
('Gaming Console 5', 'Next-generation gaming console featuring ultra high-speed SSD, ray tracing, and 4K-TV gaming support.', 140000.00),
('Bluetooth Speaker', 'Portable waterproof speaker delivering massive bass, 20 hours of playtime, and heavy-duty durability.', 15000.00),
('Mechanical Keyboard', 'RGB backlit mechanical gaming keyboard with tactile switches for satisfying feedback and e-sports durability.', 22000.00),
('Wireless Mouse', 'Ergonomic multi-device wireless mouse with precise tracking, long battery life, and customizable buttons.', 8000.00),
('Tablet Pro 11"', 'Powerful multi-purpose tablet with a stunning Liquid Retina display, Pro cameras, and all-day battery life.', 210000.00);

-- Insert a dummy admin user if you want to test login immediately
INSERT INTO users (email, password, phone, address) VALUES 
('admin@shayan.com', 'password', '1-800-ADMIN', 'Karachi, Pakistan');
