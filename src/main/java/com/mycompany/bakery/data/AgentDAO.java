package com.mycompany.bakery.data;

import com.mycompany.bakery.business.Agent;
import jakarta.enterprise.context.ApplicationScoped;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

@ApplicationScoped
public class AgentDAO {

    public boolean phoneExists(String phone) {
        if (phone == null || phone.trim().isEmpty()) return false;
        String sql = "SELECT COUNT(*) FROM agents WHERE phone = ?";
        try (Connection conn = DatabaseHelper.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, phone.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            System.err.println("Error checking agent phone existence: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public Agent register(Agent agent) {
        if (agent == null || phoneExists(agent.getPhone())) {
            return null;
        }

        // Check if phone/username already exists in users table
        String sqlCheckUser = "SELECT COUNT(*) FROM users WHERE username = ?";
        try (Connection conn = DatabaseHelper.getConnection();
             PreparedStatement psCheck = conn.prepareStatement(sqlCheckUser)) {
            psCheck.setString(1, agent.getPhone().trim());
            try (ResultSet rsCheck = psCheck.executeQuery()) {
                if (rsCheck.next() && rsCheck.getInt(1) > 0) {
                    return null; // Phone already exists in users table
                }
            }
        } catch (Exception e) {
            System.err.println("Error verifying agent phone in users: " + e.getMessage());
            e.printStackTrace();
            return null;
        }

        String sqlAgent = "INSERT INTO agents (name, phone, shop_name, address, latitude, longitude, password, status, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String sqlUser = "INSERT INTO users (username, password, fullname, phone, role, created_at) VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseHelper.getConnection()) {
            conn.setAutoCommit(false);
            try {
                String createdAt = java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
                
                // Insert into users table
                try (PreparedStatement psUser = conn.prepareStatement(sqlUser)) {
                    psUser.setString(1, agent.getPhone().trim());
                    psUser.setString(2, agent.getPassword());
                    psUser.setString(3, agent.getShopName().trim() + " (" + agent.getName().trim() + ")");
                    psUser.setString(4, agent.getPhone().trim());
                    psUser.setString(5, "AGENT");
                    psUser.setString(6, createdAt);
                    psUser.executeUpdate();
                }

                // Insert into agents table
                try (PreparedStatement psAgent = conn.prepareStatement(sqlAgent, PreparedStatement.RETURN_GENERATED_KEYS)) {
                    psAgent.setString(1, agent.getName().trim());
                    psAgent.setString(2, agent.getPhone().trim());
                    psAgent.setString(3, agent.getShopName().trim());
                    psAgent.setString(4, agent.getAddress().trim());
                    psAgent.setDouble(5, agent.getLatitude());
                    psAgent.setDouble(6, agent.getLongitude());
                    psAgent.setString(7, agent.getPassword()); // In a real app we would hash it, but here we store as-is to match user password behavior
                    psAgent.setString(8, "PENDING"); // Default status is PENDING
                    psAgent.setString(9, createdAt);

                    int affected = psAgent.executeUpdate();
                    if (affected > 0) {
                        try (ResultSet generatedKeys = psAgent.getGeneratedKeys()) {
                            if (generatedKeys.next()) {
                                agent.setId(generatedKeys.getInt(1));
                            }
                        }
                    }
                }

                conn.commit();
                agent.setStatus("PENDING");
                agent.setCreatedAt(createdAt);
                return agent;
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        } catch (Exception e) {
            System.err.println("Error registering agent: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    public Agent authenticate(String phone, String password) {
        if (phone == null || password == null) return null;
        String sql = "SELECT * FROM agents WHERE phone = ? AND password = ?";
        try (Connection conn = DatabaseHelper.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, phone.trim());
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Agent agent = new Agent();
                    agent.setId(rs.getInt("id"));
                    agent.setName(rs.getString("name"));
                    agent.setPhone(rs.getString("phone"));
                    agent.setShopName(rs.getString("shop_name"));
                    agent.setAddress(rs.getString("address"));
                    agent.setLatitude(rs.getDouble("latitude"));
                    agent.setLongitude(rs.getDouble("longitude"));
                    agent.setPassword(rs.getString("password"));
                    agent.setStatus(rs.getString("status"));
                    agent.setCreatedAt(rs.getString("created_at"));
                    return agent;
                }
            }
        } catch (Exception e) {
            System.err.println("Error authenticating agent: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    public Agent getAgentByPhone(String phone) {
        if (phone == null || phone.trim().isEmpty()) return null;
        String sql = "SELECT * FROM agents WHERE phone = ?";
        try (Connection conn = DatabaseHelper.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, phone.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Agent agent = new Agent();
                    agent.setId(rs.getInt("id"));
                    agent.setName(rs.getString("name"));
                    agent.setPhone(rs.getString("phone"));
                    agent.setShopName(rs.getString("shop_name"));
                    agent.setAddress(rs.getString("address"));
                    agent.setLatitude(rs.getDouble("latitude"));
                    agent.setLongitude(rs.getDouble("longitude"));
                    agent.setPassword(rs.getString("password"));
                    agent.setStatus(rs.getString("status"));
                    agent.setCreatedAt(rs.getString("created_at"));
                    return agent;
                }
            }
        } catch (Exception e) {
            System.err.println("Error retrieving agent by phone: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    public List<Agent> getAllAgents() {
        List<Agent> list = new ArrayList<>();
        String sql = "SELECT * FROM agents ORDER BY created_at DESC";
        try (Connection conn = DatabaseHelper.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Agent agent = new Agent();
                agent.setId(rs.getInt("id"));
                agent.setName(rs.getString("name"));
                agent.setPhone(rs.getString("phone"));
                agent.setShopName(rs.getString("shop_name"));
                agent.setAddress(rs.getString("address"));
                agent.setLatitude(rs.getDouble("latitude"));
                agent.setLongitude(rs.getDouble("longitude"));
                agent.setPassword(rs.getString("password"));
                agent.setStatus(rs.getString("status"));
                agent.setCreatedAt(rs.getString("created_at"));
                list.add(agent);
            }
        } catch (Exception e) {
            System.err.println("Error listing all agents: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateAgentStatus(int id, String status) {
        if (status == null) return false;
        String sql = "UPDATE agents SET status = ? WHERE id = ?";
        try (Connection conn = DatabaseHelper.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status.toUpperCase());
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Error updating agent status: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteAgent(int id) {
        String sqlGetPhone = "SELECT phone FROM agents WHERE id = ?";
        String sqlAgent = "DELETE FROM agents WHERE id = ?";
        String sqlUser = "DELETE FROM users WHERE username = ?";
        
        try (Connection conn = DatabaseHelper.getConnection()) {
            conn.setAutoCommit(false);
            try {
                String phone = null;
                try (PreparedStatement psGet = conn.prepareStatement(sqlGetPhone)) {
                    psGet.setInt(1, id);
                    try (ResultSet rs = psGet.executeQuery()) {
                        if (rs.next()) {
                            phone = rs.getString("phone");
                        }
                    }
                }
                
                // Delete from agents
                boolean successAgent = false;
                try (PreparedStatement psAgent = conn.prepareStatement(sqlAgent)) {
                    psAgent.setInt(1, id);
                    successAgent = psAgent.executeUpdate() > 0;
                }
                
                // Delete from users if phone found
                if (phone != null) {
                    try (PreparedStatement psUser = conn.prepareStatement(sqlUser)) {
                        psUser.setString(1, phone);
                        psUser.executeUpdate();
                    }
                }
                
                conn.commit();
                return successAgent;
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        } catch (Exception e) {
            System.err.println("Error deleting agent: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}
