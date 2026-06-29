package com.mycompany.bakery.business;

import com.mycompany.bakery.data.OrderDAO;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@ApplicationScoped
public class OrderService {

    @Inject
    private OrderDAO orderDAO;

    public OrderService() {
    }

    public Order createOrder(Order order) {
        if (order.getId() == null || order.getId().isEmpty()) {
            order.setId("DH" + String.valueOf(System.currentTimeMillis()).substring(5));
        }
        if (order.getStatus() == null) {
            order.setStatus("PENDING");
        }
        if (order.getCreatedAt() == null) {
            order.setCreatedAt(LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")));
        }
        return orderDAO.createOrder(order);
    }

    public Order getOrderById(String id) {
        return orderDAO.getOrderById(id);
    }

    public List<Order> getOrdersByPhone(String phone) {
        return orderDAO.getOrdersByPhone(phone);
    }

    public List<Order> getAllOrders() {
        return orderDAO.getAllOrders();
    }

    public boolean updateOrderStatus(String id, String status) {
        return orderDAO.updateOrderStatus(id, status);
    }

    public List<Order> getOrdersByUserId(int userId) {
        return orderDAO.getOrdersByUserId(userId);
    }
}
