package com.mycompany.bakery.controller;

import com.mycompany.bakery.business.Order;
import com.mycompany.bakery.business.OrderService;
import com.mycompany.bakery.business.User;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.json.bind.Jsonb;
import jakarta.json.bind.JsonbBuilder;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet(name = "OrderServlet", urlPatterns = {"/resources/orders/*"})
public class OrderServlet extends HttpServlet {

    @Inject
    private OrderService orderService;

    private static final Jsonb jsonb = JsonbBuilder.create();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String pathInfo = request.getPathInfo();

        if (pathInfo == null || pathInfo.equals("/")) {
            // GET /resources/orders?phone=...
            String phone = request.getParameter("phone");
            if (phone == null || phone.trim().isEmpty()) {
                // Check if requester is logged in
                HttpSession session = request.getSession(false);
                User user = (session != null) ? (User) session.getAttribute("user") : null;
                
                if (user != null && "ADMIN".equals(user.getRole())) {
                    List<Order> all = orderService.getAllOrders();
                    out.print(jsonb.toJson(all));
                    return;
                }
                
                // Nếu là CUSTOMER đã đăng nhập, trả đơn hàng theo user_id
                if (user != null && "CUSTOMER".equals(user.getRole())) {
                    List<Order> userOrders = orderService.getOrdersByUserId(user.getId());
                    out.print(jsonb.toJson(userOrders));
                    return;
                }

                // Nếu là AGENT đã đăng nhập, trả đơn hàng theo số điện thoại (username)
                if (user != null && "AGENT".equals(user.getRole())) {
                    List<Order> agentOrders = orderService.getOrdersByPhone(user.getUsername());
                    out.print(jsonb.toJson(agentOrders));
                    return;
                }
                
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("Yêu cầu cung cấp số điện thoại để tìm kiếm");
                return;
            }
            List<Order> found = orderService.getOrdersByPhone(phone.trim());
            out.print(jsonb.toJson(found));
        } else {
            // GET /resources/orders/{id}
            String id = pathInfo.substring(1).trim();
            if (id.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("Mã đơn hàng không hợp lệ");
                return;
            }
            Order order = orderService.getOrderById(id);
            if (order == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("Không tìm thấy đơn hàng với mã: " + id);
                return;
            }
            out.print(jsonb.toJson(order));
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String pathInfo = request.getPathInfo();

        // Check if path is status update: /resources/orders/{id}/status
        if (pathInfo != null && pathInfo.endsWith("/status")) {
            // Check admin session
            HttpSession session = request.getSession(false);
            User user = (session != null) ? (User) session.getAttribute("user") : null;
            if (user == null || !"ADMIN".equals(user.getRole())) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                out.print("{\"error\":\"Bạn không có quyền cập nhật trạng thái đơn hàng\"}");
                return;
            }

            // Path is "/{id}/status" -> extract ID
            String temp = pathInfo.substring(1); // "{id}/status"
            String id = temp.substring(0, temp.indexOf("/"));
            String status = request.getParameter("status");

            if (status == null || status.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"Trạng thái không hợp lệ\"}");
                return;
            }

            boolean success = orderService.updateOrderStatus(id, status.trim());
            if (success) {
                OrderWebSocket.sendStatusUpdate(id, status.trim());
                out.print("{\"success\":true}");
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\":\"Không tìm thấy đơn hàng hoặc cập nhật thất bại\"}");
            }
            return;
        }

        // Standard order creation
        try {
            Order order = jsonb.fromJson(request.getReader(), Order.class);
            if (order == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("Dữ liệu đơn hàng không hợp lệ");
                return;
            }

            // Kiểm tra hợp lệ cơ bản
            if (order.getCustomerName() == null || order.getCustomerName().trim().isEmpty() ||
                order.getCustomerPhone() == null || order.getCustomerPhone().trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("Tên khách hàng và Số điện thoại là bắt buộc");
                return;
            }

            // Gắn user_id nếu khách hàng đã đăng nhập
            HttpSession session = request.getSession(false);
            User loggedUser = (session != null) ? (User) session.getAttribute("user") : null;
            if (loggedUser != null && "CUSTOMER".equals(loggedUser.getRole())) {
                order.setUserId(loggedUser.getId());
            }

            Order created = orderService.createOrder(order);
            response.setStatus(HttpServletResponse.SC_CREATED);
            out.print(jsonb.toJson(created));
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("Lỗi định dạng dữ liệu: " + e.getMessage());
        }
    }
}
