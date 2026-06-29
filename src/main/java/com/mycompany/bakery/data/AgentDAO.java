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
        String sql = "INSERT INTO agents (name, phone, shop_name, address, latitude, longitude, password, status, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseHelper.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, agent.getName().trim());
            ps.setString(2, agent.getPhone().trim());
            ps.setString(3, agent.getShopName().trim());
            ps.setString(4, agent.getAddress().trim());
            ps.setDouble(5, agent.getLatitude());
            ps.setDouble(6, agent.getLongitude());
            ps.setString(7, agent.getPassword()); // In a real app we would hash it, but here we store as-is to match user password behavior
            ps.setString(8, "PENDING"); // Default status is PENDING
            
            String createdAt = java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
            ps.setString(9, createdAt);
            
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        agent.setId(generatedKeys.getInt(1));
                    }
                }
                agent.setStatus("PENDING");
                agent.setCreatedAt(createdAt);
                return agent;
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
        String sql = "DELETE FROM agents WHERE id = ?";
        try (Connection conn = DatabaseHelper.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Error deleting agent: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}
