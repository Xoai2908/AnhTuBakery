package com.mycompany.bakery.controller;

import com.mycompany.bakery.business.Agent;
import com.mycompany.bakery.business.User;
import com.mycompany.bakery.data.AgentDAO;
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

@WebServlet(name = "AgentServlet", urlPatterns = {"/resources/agents/*"})
public class AgentServlet extends HttpServlet {

    @Inject
    private AgentDAO agentDAO;

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

        if (!isAdmin(request)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"error\":\"Bạn không có quyền truy cập dữ liệu đại lý\"}");
            return;
        }

        // GET /resources/agents
        List<Agent> agents = agentDAO.getAllAgents();
        out.print(jsonb.toJson(agents));
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String pathInfo = request.getPathInfo();

        if (pathInfo != null && pathInfo.equals("/register")) {
            // POST /resources/agents/register (Wholesale registration)
            try {
                Agent agent = jsonb.fromJson(request.getReader(), Agent.class);
                if (agent == null || agent.getPhone() == null || agent.getPhone().trim().isEmpty() || agent.getPassword() == null) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("{\"error\":\"Thông tin đăng ký không hợp lệ\"}");
                    return;
                }

                if (agentDAO.phoneExists(agent.getPhone())) {
                    response.setStatus(HttpServletResponse.SC_CONFLICT);
                    out.print("{\"error\":\"Số điện thoại này đã được đăng ký đại lý\"}");
                    return;
                }

                Agent registered = agentDAO.register(agent);
                if (registered != null) {
                    response.setStatus(HttpServletResponse.SC_CREATED);
                    out.print("{\"success\":true}");
                } else {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    out.print("{\"error\":\"Đăng ký thất bại\"}");
                }
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"Lỗi định dạng dữ liệu: " + e.getMessage() + "\"}");
            }
            return;
        }

        if (pathInfo != null && pathInfo.equals("/login")) {
            // POST /resources/agents/login
            try {
                Credentials creds = jsonb.fromJson(request.getReader(), Credentials.class);
                if (creds == null || creds.phone == null || creds.password == null) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("{\"error\":\"Vui lòng cung cấp số điện thoại và mật khẩu\"}");
                    return;
                }

                Agent agent = agentDAO.authenticate(creds.phone, creds.password);
                if (agent != null) {
                    if ("PENDING".equals(agent.getStatus())) {
                        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                        out.print("{\"error\":\"Tài khoản đại lý đang chờ duyệt. Vui lòng liên hệ hotline!\"}");
                        return;
                    }
                    if ("SUSPENDED".equals(agent.getStatus())) {
                        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                        out.print("{\"error\":\"Tài khoản đại lý đã bị tạm khóa!\"}");
                        return;
                    }

                    // Authenticated successfully - map Agent to User session
                    HttpSession session = request.getSession(true);
                    User userSession = new User();
                    userSession.setUsername(agent.getPhone());
                    userSession.setFullname(agent.getShopName() + " (" + agent.getName() + ")");
                    userSession.setRole("AGENT");
                    session.setAttribute("user", userSession);

                    out.print("{\"success\":true}");
                } else {
                    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    out.print("{\"error\":\"Số điện thoại hoặc mật khẩu không chính xác\"}");
                }
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"Lỗi xử lý yêu cầu: " + e.getMessage() + "\"}");
            }
            return;
        }

        // Admin status update: POST /resources/agents/{id}/status?status=...
        if (pathInfo != null && pathInfo.endsWith("/status")) {
            if (!isAdmin(request)) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                out.print("{\"error\":\"Bạn không có quyền thực hiện hành động này\"}");
                return;
            }

            try {
                // Path is "/{id}/status"
                String temp = pathInfo.substring(1);
                String idStr = temp.substring(0, temp.indexOf("/"));
                int id = Integer.parseInt(idStr);
                String status = request.getParameter("status");

                if (status == null || status.trim().isEmpty()) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("{\"error\":\"Thiếu trạng thái cập nhật\"}");
                    return;
                }

                boolean success = agentDAO.updateAgentStatus(id, status.trim());
                if (success) {
                    out.print("{\"success\":true}");
                } else {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"error\":\"Cập nhật thất bại\"}");
                }
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"Lỗi xử lý yêu cầu: " + e.getMessage() + "\"}");
            }
            return;
        }

        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
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
            out.print("{\"error\":\"Thiếu mã đại lý cần xóa\"}");
            return;
        }

        try {
            String idStr = pathInfo.substring(1).trim();
            int id = Integer.parseInt(idStr);
            boolean success = agentDAO.deleteAgent(id);
            if (success) {
                out.print("{\"success\":true}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"error\":\"Xóa đại lý thất bại\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Mã đại lý không hợp lệ\"}");
        }
    }

    public static class Credentials {
        public String phone;
        public String password;
    }
}
