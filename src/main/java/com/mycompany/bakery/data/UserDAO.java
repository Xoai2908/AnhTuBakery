package com.mycompany.bakery.data;

import com.mycompany.bakery.business.User;
import jakarta.enterprise.context.ApplicationScoped;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

@ApplicationScoped
public class UserDAO {

    private User mapUser(ResultSet rs) throws Exception {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setUsername(rs.getString("username"));
        user.setPassword(rs.getString("password"));
        user.setFullname(rs.getString("fullname"));
        user.setPhone(rs.getString("phone"));
        try {
            user.setDob(rs.getString("dob"));
        } catch (Exception e) {
            // Safe fallback
        }
        user.setRole(rs.getString("role"));
        user.setCreatedAt(rs.getString("created_at"));
        return user;
    }

    public User authenticate(String username, String password) {
        if (username == null || password == null) return null;

        String sql = "SELECT * FROM users WHERE username = ? AND password = ?";
        try (Connection conn = DatabaseHelper.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username.trim());
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User user = mapUser(rs);
                    // Nếu là AGENT, kiểm tra trạng thái kích hoạt trong bảng agents
                    if ("AGENT".equals(user.getRole())) {
                        String sqlAgent = "SELECT status FROM agents WHERE phone = ?";
                        try (PreparedStatement psAgent = conn.prepareStatement(sqlAgent)) {
                            psAgent.setString(1, user.getUsername());
                            try (ResultSet rsAgent = psAgent.executeQuery()) {
                                if (rsAgent.next()) {
                                    String status = rsAgent.getString("status");
                                    if (!"ACTIVE".equals(status)) {
                                        return null; // Không cho phép đăng nhập nếu chưa ACTIVE
                                    }
                                } else {
                                    return null; // Không tìm thấy thông tin đại lý
                                }
                            }
                        }
                    }
                    return user;
                }
            }
        } catch (Exception e) {
            System.err.println("Authentication error: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    public User getUserById(int id) {
        String sql = "SELECT * FROM users WHERE id = ?";
        try (Connection conn = DatabaseHelper.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (Exception e) {
            System.err.println("Error fetching user by id: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    public boolean usernameExists(String username) {
        if (username == null || username.trim().isEmpty()) return false;
        String sql = "SELECT COUNT(*) FROM users WHERE username = ?";
        try (Connection conn = DatabaseHelper.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            System.err.println("Error checking username existence: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public boolean register(String username, String password, String fullname, String phone, String role) {
        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            return false;
        }
        if (usernameExists(username)) {
            return false;
        }
        String sql = "INSERT INTO users (username, password, fullname, phone, role, created_at) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseHelper.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username.trim());
            ps.setString(2, password);
            ps.setString(3, fullname != null ? fullname.trim() : "");
            ps.setString(4, (phone != null && !phone.trim().isEmpty()) ? phone.trim() : null);
            ps.setString(5, role != null ? role : "CUSTOMER");
            String createdAt = java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
            ps.setString(6, createdAt);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Registration error: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy danh sách tất cả khách hàng (CUSTOMER) kèm thống kê đơn hàng
     */
    public List<User> getAllCustomers() {
        List<User> customers = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE role = 'CUSTOMER' ORDER BY created_at DESC";
        try (Connection conn = DatabaseHelper.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                customers.add(mapUser(rs));
            }
        } catch (Exception e) {
            System.err.println("Error fetching customers: " + e.getMessage());
            e.printStackTrace();
        }
        return customers;
    }

    /**
     * Cập nhật thông tin cá nhân của user
     */
    public boolean updateProfile(int id, String fullname, String phone, String dob, String password) {
        String sql;
        boolean hasPassword = password != null && !password.trim().isEmpty();
        if (hasPassword) {
            sql = "UPDATE users SET fullname = ?, phone = ?, dob = ?, password = ? WHERE id = ?";
        } else {
            sql = "UPDATE users SET fullname = ?, phone = ?, dob = ? WHERE id = ?";
        }

        try (Connection conn = DatabaseHelper.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullname != null ? fullname.trim() : "");
            ps.setString(2, phone != null ? phone.trim() : null);
            ps.setString(3, dob != null ? dob.trim() : null);
            if (hasPassword) {
                ps.setString(4, password);
                ps.setInt(5, id);
            } else {
                ps.setInt(4, id);
            }
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Error updating profile for user " + id + ": " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
}
