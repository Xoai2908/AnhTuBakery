package com.mycompany.bakery.data;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Properties;

public class DatabaseHelper {
    private static String url = "jdbc:h2:./data/bakery;AUTO_SERVER=TRUE;MODE=MySQL";
    private static String username = "sa";
    private static String password = "";
    private static String driver = "org.h2.Driver";
    private static boolean initialized = false;

    static {
        loadConfig();
        initDatabase();
    }

    private static void loadConfig() {
        try (InputStream input = DatabaseHelper.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (input != null) {
                Properties prop = new Properties();
                prop.load(input);
                url = prop.getProperty("db.url", url);
                username = prop.getProperty("db.username", username);
                password = prop.getProperty("db.password", password);
                driver = prop.getProperty("db.driver", driver);
                System.out.println("Loaded database configuration from db.properties");
            } else {
                System.out.println("No db.properties found. Using default embedded H2 database.");
            }
        } catch (Exception e) {
            System.err.println("Error loading db.properties: " + e.getMessage());
        }
    }

    private static synchronized void initDatabase() {
        if (initialized) return;
        try {
            Class.forName(driver);
            try (Connection conn = getConnection(); Statement stmt = conn.createStatement()) {
                String dbProduct = conn.getMetaData().getDatabaseProductName().toLowerCase();
                boolean isSQLServer = dbProduct.contains("microsoft") || dbProduct.contains("sql server");
                
                if (isSQLServer) {
                    // SQL Server table creation checks
                    stmt.execute("IF OBJECT_ID('orders', 'U') IS NULL " +
                            "CREATE TABLE orders (" +
                            "id VARCHAR(50) PRIMARY KEY, " +
                            "status VARCHAR(20) NOT NULL, " +
                            "customer_name NVARCHAR(100) NOT NULL, " +
                            "customer_phone VARCHAR(20) NOT NULL, " +
                            "delivery_method VARCHAR(20) NOT NULL, " +
                            "delivery_address NVARCHAR(255), " +
                            "pickup_time NVARCHAR(50), " +
                            "latitude DOUBLE PRECISION, " +
                            "longitude DOUBLE PRECISION, " +
                            "subtotal INT NOT NULL, " +
                            "shipping_fee INT NOT NULL, " +
                            "total INT NOT NULL, " +
                            "created_at VARCHAR(50) NOT NULL" +
                            ")");

                    stmt.execute("IF OBJECT_ID('order_items', 'U') IS NULL " +
                            "CREATE TABLE order_items (" +
                            "id INT IDENTITY(1,1) PRIMARY KEY, " +
                            "order_id VARCHAR(50) NOT NULL, " +
                            "name NVARCHAR(100) NOT NULL, " +
                            "qty INT NOT NULL, " +
                            "price INT NOT NULL, " +
                            "FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE" +
                            ")");

                    stmt.execute("IF OBJECT_ID('users', 'U') IS NULL " +
                            "CREATE TABLE users (" +
                            "id INT IDENTITY(1,1) PRIMARY KEY, " +
                            "username VARCHAR(50) NOT NULL UNIQUE, " +
                            "password VARCHAR(255) NOT NULL, " +
                            "fullname NVARCHAR(100), " +
                            "role VARCHAR(20) NOT NULL, " +
                            "created_at VARCHAR(50) NOT NULL" +
                            ")");

                    stmt.execute("IF OBJECT_ID('products', 'U') IS NULL " +
                            "CREATE TABLE products (" +
                            "id INT IDENTITY(1,1) PRIMARY KEY, " +
                            "name NVARCHAR(100) NOT NULL, " +
                            "category VARCHAR(50) NOT NULL, " +
                            "price INT NOT NULL, " +
                            "description NVARCHAR(255), " +
                            "image_url VARCHAR(255), " +
                            "is_active BIT NOT NULL DEFAULT 1" +
                            ")");

                    stmt.execute("IF OBJECT_ID('agents', 'U') IS NULL " +
                            "CREATE TABLE agents (" +
                            "id INT IDENTITY(1,1) PRIMARY KEY, " +
                            "name NVARCHAR(100) NOT NULL, " +
                            "phone VARCHAR(20) NOT NULL UNIQUE, " +
                            "shop_name NVARCHAR(150) NOT NULL, " +
                            "address NVARCHAR(255) NOT NULL, " +
                            "latitude DOUBLE PRECISION NOT NULL, " +
                            "longitude DOUBLE PRECISION NOT NULL, " +
                            "password VARCHAR(100) NOT NULL, " +
                            "status VARCHAR(20) NOT NULL DEFAULT 'PENDING', " +
                            "created_at VARCHAR(50) NOT NULL" +
                            ")");
                } else {
                    // H2 and MySQL table creation checks
                    stmt.execute("CREATE TABLE IF NOT EXISTS orders (" +
                            "id VARCHAR(50) PRIMARY KEY, " +
                            "status VARCHAR(20) NOT NULL, " +
                            "customer_name VARCHAR(100) NOT NULL, " +
                            "customer_phone VARCHAR(20) NOT NULL, " +
                            "delivery_method VARCHAR(20) NOT NULL, " +
                            "delivery_address VARCHAR(255), " +
                            "pickup_time VARCHAR(50), " +
                            "latitude DOUBLE, " +
                            "longitude DOUBLE, " +
                            "subtotal INT NOT NULL, " +
                            "shipping_fee INT NOT NULL, " +
                            "total INT NOT NULL, " +
                            "created_at VARCHAR(50) NOT NULL" +
                            ")");

                    stmt.execute("CREATE TABLE IF NOT EXISTS order_items (" +
                            "id INT AUTO_INCREMENT PRIMARY KEY, " +
                            "order_id VARCHAR(50) NOT NULL, " +
                            "name VARCHAR(100) NOT NULL, " +
                            "qty INT NOT NULL, " +
                            "price INT NOT NULL, " +
                            "FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE" +
                            ")");

                    stmt.execute("CREATE TABLE IF NOT EXISTS users (" +
                            "id INT AUTO_INCREMENT PRIMARY KEY, " +
                            "username VARCHAR(50) NOT NULL UNIQUE, " +
                            "password VARCHAR(255) NOT NULL, " +
                            "fullname VARCHAR(100), " +
                            "role VARCHAR(20) NOT NULL, " +
                            "created_at VARCHAR(50) NOT NULL" +
                            ")");

                    stmt.execute("CREATE TABLE IF NOT EXISTS products (" +
                            "id INT AUTO_INCREMENT PRIMARY KEY, " +
                            "name VARCHAR(100) NOT NULL, " +
                            "category VARCHAR(50) NOT NULL, " +
                            "price INT NOT NULL, " +
                            "description VARCHAR(255), " +
                            "image_url VARCHAR(255), " +
                            "is_active BOOLEAN NOT NULL DEFAULT TRUE" +
                            ")");

                    stmt.execute("CREATE TABLE IF NOT EXISTS agents (" +
                            "id INT AUTO_INCREMENT PRIMARY KEY, " +
                            "name VARCHAR(100) NOT NULL, " +
                            "phone VARCHAR(20) NOT NULL UNIQUE, " +
                            "shop_name VARCHAR(150) NOT NULL, " +
                            "address VARCHAR(255) NOT NULL, " +
                            "latitude DOUBLE NOT NULL, " +
                            "longitude DOUBLE NOT NULL, " +
                            "password VARCHAR(100) NOT NULL, " +
                            "status VARCHAR(20) NOT NULL DEFAULT 'PENDING', " +
                            "created_at VARCHAR(50) NOT NULL" +
                            ")");
                }

                // Add note column to orders table if it doesn't exist
                try {
                    stmt.execute("ALTER TABLE orders ADD note VARCHAR(500)");
                } catch (Exception e) {
                    // Column already exists or alter not needed
                }

                // Add phone column to users table if it doesn't exist
                try {
                    stmt.execute("ALTER TABLE users ADD phone VARCHAR(20)");
                } catch (Exception e) {
                    // Column already exists
                }

                // Add dob column to users table if it doesn't exist
                try {
                    stmt.execute("ALTER TABLE users ADD dob VARCHAR(20)");
                } catch (Exception e) {
                    // Column already exists
                }

                // Add user_id column to orders table if it doesn't exist
                try {
                    stmt.execute("ALTER TABLE orders ADD user_id INT");
                } catch (Exception e) {
                    // Column already exists
                }

                // Seed default admin and customer user if table is empty
                try (ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM users")) {
                    if (rs.next() && rs.getInt(1) == 0) {
                        try (java.sql.PreparedStatement ps = conn.prepareStatement(
                                "INSERT INTO users (username, password, fullname, role, created_at) VALUES (?, ?, ?, ?, ?)")) {
                            // Seed Admin
                            ps.setString(1, "admin");
                            ps.setString(2, "admin123");
                            ps.setString(3, "Quản trị viên");
                            ps.setString(4, "ADMIN");
                            ps.setString(5, "2026-06-14 12:00");
                            ps.executeUpdate();
                            
                            // Seed Customer User
                            ps.setString(1, "user");
                            ps.setString(2, "user123");
                            ps.setString(3, "Khách Hàng Thử Nghiệm");
                            ps.setString(4, "CUSTOMER");
                            ps.setString(5, "2026-06-14 12:00");
                            ps.executeUpdate();
                            
                            System.out.println("Default admin (admin/admin123) and user (user/user123) created successfully.");
                        }
                    }
                }

                // Seed default products if table is empty
                try (ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM products")) {
                    if (rs.next() && rs.getInt(1) == 0) {
                        String seedSql = "INSERT INTO products (name, category, price, description, image_url, is_active) VALUES (?, ?, ?, ?, ?, ?)";
                        try (java.sql.PreparedStatement ps = conn.prepareStatement(seedSql)) {
                            // Category: banh-mi
                            addProductSeed(ps, "Bánh mì Heo quay", "banh-mi", 13000, "Nhân heo quay giòn da, dưa leo, rau mùi, sốt đặc biệt nhà", "../images/banh-mi-heo-quay.png");
                            addProductSeed(ps, "Bánh mì Bò xào", "banh-mi", 13000, "Bò xào sả ớt thơm nức, ăn kèm rau sống, tương ớt", "../images/banh-mi-bo-xao.png");
                            addProductSeed(ps, "Bánh mì Trứng", "banh-mi", 10000, "Trứng ốp la vàng ươm, chả lụa, rau thơm tươi mát", "../images/banh-mi-trung.png");
                            addProductSeed(ps, "Bánh mì Thịt nướng", "banh-mi", 10000, "Thịt nướng than hoa, ướp gia vị đặc trưng của lò", "../images/banh-mi-thit-nuong.png");
                            addProductSeed(ps, "Bánh mì Chả", "banh-mi", 10000, "Chả lụa thượng hạng, pate nhà làm, đồ chua truyền thống", "../images/banh-mi-cha.png");
                            addProductSeed(ps, "Bánh mì Bánh lọc", "banh-mi", 10000, "Bánh lọc truyền thống nhân tôm thịt, chấm nước mắm chua ngọt", "../images/banh-mi-banh-loc.png");
                            addProductSeed(ps, "Bánh mì Thập cẩm", "banh-mi", 10000, "Heo quay + chả lụa + trứng + rau đủ loại — đầy đủ nhất", "../images/banh-mi-thap-cam.png");
                            addProductSeed(ps, "Bánh mì Bơ đậu", "banh-mi", 10000, "Bơ thực vật béo ngậy, dừa, kèm sữa đặc hoặc đường vừng", "../images/banh-mi-bo-dau.png");

                            // Category: xoi
                            addProductSeed(ps, "Xôi Heo quay", "xoi", 15000, "Xôi nếp dẻo, heo quay giòn bì thơm, hành phi vàng", "../images/xoi-heo-quay.png");
                            addProductSeed(ps, "Xôi Bò xào", "xoi", 15000, "Bò xào sả cay thơm trên lớp xôi nếp mềm dẻo", "../images/xoi-bo-xao.png");
                            addProductSeed(ps, "Xôi Thập cẩm", "xoi", 15000, "Heo quay + bò xào + tôm thịt — đa vị đầy đặn", "../images/xoi-thap-cam.png");
                            addProductSeed(ps, "Xôi Trứng", "xoi", 10000, "Trứng chiên vàng mềm ăn kèm xôi nếp thơm dẻo", "../images/xoi-trung.png");
                            addProductSeed(ps, "Xôi Muối mè", "xoi", 10000, "Thanh đạm, xôi nếp trắng rắc mè rang vàng thơm", "../images/xoi-muoi-me.png");

                            // Category: nuoc
                            addProductSeed(ps, "Sữa đậu tươi", "nuoc", 5000, "Sữa đậu nành nấu tươi từ đậu nguyên hạt, không phẩm màu", "../images/sua-dau-tuoi.png");
                            
                            System.out.println("Default products seeded successfully.");
                        }
                    }
                }

                // Migrate: update image_url for existing products still using old shared images
                migrateProductImages(conn);
                
                System.out.println("Database tables initialized successfully for: " + dbProduct);
                initialized = true;
            }
        } catch (Exception e) {
            System.err.println("Failed to initialize database tables: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private static void addProductSeed(java.sql.PreparedStatement ps, String name, String category, int price, String description, String imageUrl) throws Exception {
        ps.setString(1, name);
        ps.setString(2, category);
        ps.setInt(3, price);
        ps.setString(4, description);
        ps.setString(5, imageUrl);
        ps.setBoolean(6, true);
        ps.executeUpdate();
    }

    /**
     * Migrate existing products to use individual generated images
     * instead of shared fallback images (hero-banh-mi.png, xoi.png, sua-dau.png).
     */
    private static void migrateProductImages(Connection conn) {
        // Map: product name -> new individual image URL
        String[][] imageMap = {
            {"Bánh mì Heo quay",   "../images/banh-mi-heo-quay.png"},
            {"Bánh mì Bò xào",    "../images/banh-mi-bo-xao.png"},
            {"Bánh mì Trứng",     "../images/banh-mi-trung.png"},
            {"Bánh mì Thịt nướng", "../images/banh-mi-thit-nuong.png"},
            {"Bánh mì Chả",       "../images/banh-mi-cha.png"},
            {"Bánh mì Bánh lọc",  "../images/banh-mi-banh-loc.png"},
            {"Bánh mì Thập cẩm",  "../images/banh-mi-thap-cam.png"},
            {"Bánh mì Bơ đậu",    "../images/banh-mi-bo-dau.png"},
            {"Xôi Heo quay",      "../images/xoi-heo-quay.png"},
            {"Xôi Bò xào",        "../images/xoi-bo-xao.png"},
            {"Xôi Thập cẩm",      "../images/xoi-thap-cam.png"},
            {"Xôi Trứng",         "../images/xoi-trung.png"},
            {"Xôi Muối mè",       "../images/xoi-muoi-me.png"},
            {"Sữa đậu tươi",     "../images/sua-dau-tuoi.png"},
        };

        String updateSql = "UPDATE products SET image_url = ? WHERE name = ? AND (image_url IS NULL OR image_url IN ('../images/hero-banh-mi.png', '../images/xoi.png', '../images/sua-dau.png'))";
        try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
            int updated = 0;
            for (String[] entry : imageMap) {
                ps.setString(1, entry[1]); // new image URL
                ps.setString(2, entry[0]); // product name
                updated += ps.executeUpdate();
            }
            if (updated > 0) {
                System.out.println("Migrated " + updated + " product image(s) to individual images.");
            }
        } catch (Exception e) {
            System.err.println("Error migrating product images: " + e.getMessage());
            e.printStackTrace();
        }
    }


    public static Connection getConnection() throws Exception {
        try {
            javax.naming.InitialContext ctx = new javax.naming.InitialContext();
            javax.sql.DataSource ds = (javax.sql.DataSource) ctx.lookup("java:comp/env/jdbc/BakeryDB");
            if (ds != null) {
                return ds.getConnection();
            }
        } catch (Exception e) {
            // JNDI lookup failed (e.g. outside container or misconfigured), fallback to direct JDBC
        }
        Class.forName(driver);
        return DriverManager.getConnection(url, username, password);
    }
}
