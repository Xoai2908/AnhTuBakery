package com.mycompany.bakery.data;

import com.mycompany.bakery.business.Order;
import com.mycompany.bakery.business.OrderItem;
import jakarta.enterprise.context.ApplicationScoped;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

@ApplicationScoped
public class OrderDAO {

    public OrderDAO() {
        // Khởi tạo một đơn hàng mẫu nếu chưa tồn tại trong database để chạy thử nghiệm tra cứu
        try (Connection conn = DatabaseHelper.getConnection(); Statement stmt = conn.createStatement()) {
            try (ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM orders WHERE id = 'DH00000001'")) {
                if (rs.next() && rs.getInt(1) == 0) {
                    Order demoOrder = new Order();
                    demoOrder.setId("DH00000001");
                    demoOrder.setStatus("PREPARING");
                    demoOrder.setCustomerName("Nguyễn Văn A");
                    demoOrder.setCustomerPhone("0912345678");
                    demoOrder.setDeliveryMethod("GIAO_HANG");
                    demoOrder.setDeliveryAddress("123 Đường ABC, Phường X, thành phố Huế");
                    demoOrder.setSubtotal(56000);
                    demoOrder.setShippingFee(15500);
                    demoOrder.setTotal(71500);
                    demoOrder.setCreatedAt("2026-06-11 08:30");

                    List<OrderItem> items = new ArrayList<>();
                    items.add(new OrderItem("Bánh mì Heo quay", 2, 13000));
                    items.add(new OrderItem("Xôi Bò xào (Hộp lớn)", 1, 20000));
                    items.add(new OrderItem("Sữa đậu (Ly nhỏ)", 2, 5000));
                    demoOrder.setItems(items);

                    createOrder(demoOrder);
                    System.out.println("Inserted demo order DH00000001 into database.");
                }
            }
        } catch (Exception e) {
            System.err.println("Error verifying/inserting demo order: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public Order createOrder(Order order) {
        String sqlOrder = "INSERT INTO orders (id, status, customer_name, customer_phone, delivery_method, delivery_address, pickup_time, latitude, longitude, subtotal, shipping_fee, total, created_at, note, user_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String sqlItem = "INSERT INTO order_items (order_id, name, qty, price) VALUES (?, ?, ?, ?)";
        
        try (Connection conn = DatabaseHelper.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // Insert order
                try (PreparedStatement ps = conn.prepareStatement(sqlOrder)) {
                    ps.setString(1, order.getId());
                    ps.setString(2, order.getStatus());
                    ps.setString(3, order.getCustomerName());
                    ps.setString(4, order.getCustomerPhone());
                    ps.setString(5, order.getDeliveryMethod());
                    ps.setString(6, order.getDeliveryAddress());
                    ps.setString(7, order.getPickupTime());
                    
                    if (order.getLatitude() != null) ps.setDouble(8, order.getLatitude());
                    else ps.setNull(8, java.sql.Types.DOUBLE);
                    
                    if (order.getLongitude() != null) ps.setDouble(9, order.getLongitude());
                    else ps.setNull(9, java.sql.Types.DOUBLE);
                    
                    ps.setInt(10, order.getSubtotal());
                    ps.setInt(11, order.getShippingFee());
                    ps.setInt(12, order.getTotal());
                    ps.setString(13, order.getCreatedAt());
                    ps.setString(14, order.getNote());
                    if (order.getUserId() != null) ps.setInt(15, order.getUserId());
                    else ps.setNull(15, java.sql.Types.INTEGER);
                    
                    ps.executeUpdate();
                }
                
                // Insert order items
                if (order.getItems() != null && !order.getItems().isEmpty()) {
                    try (PreparedStatement psItem = conn.prepareStatement(sqlItem)) {
                        for (OrderItem item : order.getItems()) {
                            psItem.setString(1, order.getId());
                            psItem.setString(2, item.getName());
                            psItem.setInt(3, item.getQty());
                            psItem.setInt(4, item.getPrice());
                            psItem.addBatch();
                        }
                        psItem.executeBatch();
                    }
                }
                
                conn.commit();
                return order;
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        } catch (Exception e) {
            System.err.println("Error saving order: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Lỗi lưu đơn hàng: " + e.getMessage(), e);
        }
    }

    public Order getOrderById(String id) {
        if (id == null) return null;
        String sqlOrder = "SELECT * FROM orders WHERE UPPER(id) = ?";
        String sqlItems = "SELECT * FROM order_items WHERE UPPER(order_id) = ?";
        
        try (Connection conn = DatabaseHelper.getConnection()) {
            Order order = null;
            // Get order details
            try (PreparedStatement ps = conn.prepareStatement(sqlOrder)) {
                ps.setString(1, id.toUpperCase());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        order = new Order();
                        order.setId(rs.getString("id"));
                        order.setStatus(rs.getString("status"));
                        order.setCustomerName(rs.getString("customer_name"));
                        order.setCustomerPhone(rs.getString("customer_phone"));
                        order.setDeliveryMethod(rs.getString("delivery_method"));
                        order.setDeliveryAddress(rs.getString("delivery_address"));
                        order.setPickupTime(rs.getString("pickup_time"));
                        
                        double lat = rs.getDouble("latitude");
                        order.setLatitude(rs.wasNull() ? null : lat);
                        
                        double lng = rs.getDouble("longitude");
                        order.setLongitude(rs.wasNull() ? null : lng);
                        
                        order.setSubtotal(rs.getInt("subtotal"));
                        order.setShippingFee(rs.getInt("shipping_fee"));
                        order.setTotal(rs.getInt("total"));
                        order.setCreatedAt(rs.getString("created_at"));
                        order.setNote(rs.getString("note"));
                        int uid = rs.getInt("user_id");
                        order.setUserId(rs.wasNull() ? null : uid);
                    }
                }
            }
            
            // Get order items if order was found
            if (order != null) {
                List<OrderItem> items = new ArrayList<>();
                try (PreparedStatement psItems = conn.prepareStatement(sqlItems)) {
                    psItems.setString(1, id.toUpperCase());
                    try (ResultSet rs = psItems.executeQuery()) {
                        while (rs.next()) {
                            OrderItem item = new OrderItem();
                            item.setName(rs.getString("name"));
                            item.setQty(rs.getInt("qty"));
                            item.setPrice(rs.getInt("price"));
                            items.add(item);
                        }
                    }
                }
                order.setItems(items);
            }
            
            return order;
        } catch (Exception e) {
            System.err.println("Error fetching order by ID: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    public List<Order> getOrdersByPhone(String phone) {
        List<Order> result = new ArrayList<>();
        if (phone == null || phone.isEmpty()) return result;
        
        String sqlOrders = "SELECT id FROM orders WHERE customer_phone = ? ORDER BY created_at DESC";
        try (Connection conn = DatabaseHelper.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlOrders)) {
            ps.setString(1, phone);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String id = rs.getString("id");
                    Order order = getOrderById(id);
                    if (order != null) {
                        result.add(order);
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Error fetching orders by phone: " + e.getMessage());
            e.printStackTrace();
        }
        return result;
    }

    public List<Order> getAllOrders() {
        List<Order> result = new ArrayList<>();
        String sqlOrders = "SELECT id FROM orders ORDER BY created_at DESC";
        try (Connection conn = DatabaseHelper.getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlOrders);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String id = rs.getString("id");
                Order order = getOrderById(id);
                if (order != null) {
                    result.add(order);
                }
            }
        } catch (Exception e) {
            System.err.println("Error fetching all orders: " + e.getMessage());
            e.printStackTrace();
        }
        return result;
    }

    public boolean updateOrderStatus(String id, String status) {
        if (id == null || status == null) return false;
        String sql = "UPDATE orders SET status = ? WHERE UPPER(id) = ?";
        try (Connection conn = DatabaseHelper.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status.toUpperCase());
            ps.setString(2, id.toUpperCase());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("Error updating status for order " + id + ": " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Lấy danh sách đơn hàng theo userId (khách hàng đã đăng nhập)
     */
    public List<Order> getOrdersByUserId(int userId) {
        List<Order> result = new ArrayList<>();
        String sql = "SELECT id FROM orders WHERE user_id = ? ORDER BY created_at DESC";
        try (Connection conn = DatabaseHelper.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String id = rs.getString("id");
                    Order order = getOrderById(id);
                    if (order != null) result.add(order);
                }
            }
        } catch (Exception e) {
            System.err.println("Error fetching orders by userId: " + e.getMessage());
            e.printStackTrace();
        }
        return result;
    }
}
