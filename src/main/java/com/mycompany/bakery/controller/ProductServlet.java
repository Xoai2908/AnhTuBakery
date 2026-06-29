package com.mycompany.bakery.controller;

import com.mycompany.bakery.business.Product;
import com.mycompany.bakery.business.User;
import com.mycompany.bakery.data.ProductDAO;
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

@WebServlet(name = "ProductServlet", urlPatterns = {"/resources/products/*"})
public class ProductServlet extends HttpServlet {

    @Inject
    private ProductDAO productDAO;

    private static final Jsonb jsonb = JsonbBuilder.create();

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        return user != null && "ADMIN".equals(user.getRole());
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String pathInfo = request.getPathInfo();

        if (pathInfo == null || pathInfo.equals("/")) {
            // GET /resources/products
            List<Product> products = productDAO.getAllProducts();
            out.print(jsonb.toJson(products));
        } else {
            // GET /resources/products/{id}
            try {
                String idStr = pathInfo.substring(1).trim();
                int id = Integer.parseInt(idStr);
                Product product = productDAO.getProductById(id);
                if (product == null) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\":\"Không tìm thấy sản phẩm\"}");
                } else {
                    out.print(jsonb.toJson(product));
                }
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"Mã sản phẩm không hợp lệ\"}");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        if (!isAdmin(request)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"error\":\"Bạn không có quyền thực hiện hành động này\"}");
            return;
        }

        try {
            Product product = jsonb.fromJson(request.getReader(), Product.class);
            if (product == null || product.getName() == null || product.getName().trim().isEmpty() || product.getPrice() <= 0) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"Dữ liệu sản phẩm không hợp lệ\"}");
                return;
            }

            Product created = productDAO.createProduct(product);
            if (created != null) {
                response.setStatus(HttpServletResponse.SC_CREATED);
                out.print(jsonb.toJson(created));
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\":\"Tạo sản phẩm thất bại\"}");
            }
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Lỗi định dạng dữ liệu: " + e.getMessage() + "\"}");
        }
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        if (!isAdmin(request)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"error\":\"Bạn không có quyền thực hiện hành động này\"}");
            return;
        }

        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Cần cung cấp mã sản phẩm để cập nhật\"}");
            return;
        }

        try {
            String idStr = pathInfo.substring(1).trim();
            int id = Integer.parseInt(idStr);
            
            Product product = jsonb.fromJson(request.getReader(), Product.class);
            if (product == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"Dữ liệu sản phẩm không hợp lệ\"}");
                return;
            }
            product.setId(id); // Ensure the ID matches pathInfo

            boolean success = productDAO.updateProduct(product);
            if (success) {
                out.print(jsonb.toJson(product));
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\":\"Cập nhật sản phẩm thất bại\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Mã sản phẩm không hợp lệ\"}");
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Lỗi định dạng dữ liệu: " + e.getMessage() + "\"}");
        }
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        if (!isAdmin(request)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"error\":\"Bạn không có quyền thực hiện hành động này\"}");
            return;
        }

        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Cần cung cấp mã sản phẩm để xóa\"}");
            return;
        }

        try {
            String idStr = pathInfo.substring(1).trim();
            int id = Integer.parseInt(idStr);
            
            boolean success = productDAO.deleteProduct(id);
            if (success) {
                out.print("{\"success\":true}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\":\"Xóa sản phẩm thất bại\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Mã sản phẩm không hợp lệ\"}");
        }
    }
}
