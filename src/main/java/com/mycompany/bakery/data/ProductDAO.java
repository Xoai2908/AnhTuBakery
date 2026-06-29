package com.mycompany.bakery.data;

import com.mycompany.bakery.business.Product;
import jakarta.enterprise.context.ApplicationScoped;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

@ApplicationScoped
public class ProductDAO {

    public List<Product> getAllProducts() {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT * FROM products ORDER BY id ASC";
        try (Connection conn = DatabaseHelper.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Product p = new Product();
                p.setId(rs.getInt("id"));
                p.setName(rs.getString("name"));
                p.setCategory(rs.getString("category"));
                p.setPrice(rs.getInt("price"));
                p.setDescription(rs.getString("description"));
                p.setImageUrl(rs.getString("image_url"));
                p.setActive(rs.getBoolean("is_active"));
                list.add(p);
            }
        } catch (Exception e) {
            System.err.println("Error fetching all products: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    public Product getProductById(int id) {
        String sql = "SELECT * FROM products WHERE id = ?";
        try (Connection conn = DatabaseHelper.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Product p = new Product();
                    p.setId(rs.getInt("id"));
                    p.setName(rs.getString("name"));
                    p.setCategory(rs.getString("category"));
                    p.setPrice(rs.getInt("price"));
                    p.setDescription(rs.getString("description"));
                    p.setImageUrl(rs.getString("image_url"));
                    p.setActive(rs.getBoolean("is_active"));
                    return p;
                }
            }
        } catch (Exception e) {
            System.err.println("Error fetching product by ID: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    public Product createProduct(Product p) {
        String sql = "INSERT INTO products (name, category, price, description, image_url, is_active) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseHelper.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, p.getName());
            ps.setString(2, p.getCategory());
            ps.setInt(3, p.getPrice());
            ps.setString(4, p.getDescription());
            ps.setString(5, p.getImageUrl());
            ps.setBoolean(6, p.isActive());
            
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        p.setId(generatedKeys.getInt(1));
                    }
                }
                return p;
            }
        } catch (Exception e) {
            System.err.println("Error creating product: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateProduct(Product p) {
        String sql = "UPDATE products SET name = ?, category = ?, price = ?, description = ?, image_url = ?, is_active = ? WHERE id = ?";
        try (Connection conn = DatabaseHelper.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, p.getName());
            ps.setString(2, p.getCategory());
            ps.setInt(3, p.getPrice());
            ps.setString(4, p.getDescription());
            ps.setString(5, p.getImageUrl());
            ps.setBoolean(6, p.isActive());
            ps.setInt(7, p.getId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Error updating product: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteProduct(int id) {
        String sql = "DELETE FROM products WHERE id = ?";
        try (Connection conn = DatabaseHelper.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Error deleting product: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
}
