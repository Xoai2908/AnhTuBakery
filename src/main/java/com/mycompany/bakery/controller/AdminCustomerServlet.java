package com.mycompany.bakery.controller;

import com.mycompany.bakery.business.Order;
import com.mycompany.bakery.business.OrderService;
import com.mycompany.bakery.business.User;
import com.mycompany.bakery.data.UserDAO;
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

/**
 * Servlet phục vụ trang Admin – quản lý khách hàng và lịch sử giao dịch.
 *
 * GET /resources/admin/customers       → danh sách tất cả CUSTOMER
 * GET /resources/admin/customers/{id}/orders → đơn hàng của 1 khách
 */
@WebServlet(name = "AdminCustomerServlet", urlPatterns = {"/resources/admin/customers/*"})
public class AdminCustomerServlet extends HttpServlet {

    @Inject
    private UserDAO userDAO;

    @Inject
    private OrderService orderService;

    private static final Jsonb jsonb = JsonbBuilder.create();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        // Chỉ ADMIN mới được truy cập
        HttpSession session = request.getSession(false);
        User admin = (session != null) ? (User) session.getAttribute("user") : null;
        if (admin == null || !"ADMIN".equals(admin.getRole())) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"error\":\"Bạn không có quyền truy cập\"}");
            return;
        }

        String pathInfo = request.getPathInfo(); // null | "/" | "/{id}/orders"

        if (pathInfo == null || pathInfo.equals("/") || pathInfo.isEmpty()) {
            // GET /resources/admin/customers → danh sách khách hàng
            List<User> customers = userDAO.getAllCustomers();
            out.print(jsonb.toJson(customers));
        } else if (pathInfo.endsWith("/orders")) {
            // GET /resources/admin/customers/{id}/orders
            try {
                String temp = pathInfo.substring(1); // "{id}/orders"
                String idStr = temp.substring(0, temp.indexOf("/"));
                int userId = Integer.parseInt(idStr);
                List<Order> orders = orderService.getOrdersByUserId(userId);
                out.print(jsonb.toJson(orders));
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"ID khách hàng không hợp lệ\"}");
            }
        } else {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            out.print("{\"error\":\"Endpoint không tồn tại\"}");
        }
    }
}
