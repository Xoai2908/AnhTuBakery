package com.mycompany.bakery.controller;

import com.mycompany.bakery.business.User;
import com.mycompany.bakery.data.UserDAO;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "AuthServlet", urlPatterns = {"/auth/login", "/auth/logout", "/auth/register", "/auth/update-phone", "/auth/update-profile"})
public class AuthServlet extends HttpServlet {

    @Inject
    private UserDAO userDAO;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getServletPath();
        
        if ("/auth/login".equals(action)) {
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String redirect = request.getParameter("redirect");
            
            User user = userDAO.authenticate(username, password);
            
            if (user != null) {
                HttpSession session = request.getSession(true);
                session.setAttribute("user", user);
                
                if ("ADMIN".equals(user.getRole())) {
                    response.sendRedirect(request.getContextPath() + "/view/admin_dashboard.jsp");
                } else {
                    if (redirect != null && !redirect.trim().isEmpty()) {
                        response.sendRedirect(request.getContextPath() + "/view/" + redirect);
                    } else {
                        response.sendRedirect(request.getContextPath() + "/view/order.jsp");
                    }
                }
            } else {
                // Redirect back to login with error query and preserve redirect parameter
                String errorRedirect = request.getContextPath() + "/view/admin_login.jsp?error=1";
                if (redirect != null && !redirect.trim().isEmpty()) {
                    errorRedirect += "&redirect=" + java.net.URLEncoder.encode(redirect, "UTF-8");
                }
                response.sendRedirect(errorRedirect);
            }
        } else if ("/auth/register".equals(action)) {
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String fullname = request.getParameter("fullname");
            String phone = request.getParameter("phone");
            String redirect = request.getParameter("redirect");
            
            if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
                String errorRedirect = request.getContextPath() + "/view/register.jsp?error=invalid";
                if (redirect != null && !redirect.trim().isEmpty()) {
                    errorRedirect += "&redirect=" + java.net.URLEncoder.encode(redirect, "UTF-8");
                }
                response.sendRedirect(errorRedirect);
                return;
            }
            
            boolean success = userDAO.register(username, password, fullname, phone, "CUSTOMER");
            if (success) {
                // Auto login after successful registration
                User user = userDAO.authenticate(username, password);
                if (user != null) {
                    HttpSession session = request.getSession(true);
                    session.setAttribute("user", user);
                    if (redirect != null && !redirect.trim().isEmpty()) {
                        response.sendRedirect(request.getContextPath() + "/view/" + redirect);
                    } else {
                        response.sendRedirect(request.getContextPath() + "/view/order.jsp");
                    }
                } else {
                    response.sendRedirect(request.getContextPath() + "/view/admin_login.jsp?registered=1");
                }
            } else {
                String errorRedirect = request.getContextPath() + "/view/register.jsp?error=duplicate";
                if (redirect != null && !redirect.trim().isEmpty()) {
                    errorRedirect += "&redirect=" + java.net.URLEncoder.encode(redirect, "UTF-8");
                }
                response.sendRedirect(errorRedirect);
            }
        } else if ("/auth/update-phone".equals(action)) {
            // Cập nhật SĐT cho user đang đăng nhập
            response.setContentType("application/json;charset=UTF-8");
            HttpSession session = request.getSession(false);
            User user = (session != null) ? (User) session.getAttribute("user") : null;
            if (user == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().print("{\"error\":\"Chưa đăng nhập\"}");
                return;
            }
            String phone = request.getParameter("phone");
            if (phone == null || !phone.trim().matches("\\d{10}")) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().print("{\"error\":\"Số điện thoại không hợp lệ\"}");
                return;
            }
            boolean updated = userDAO.updateProfile(user.getId(), user.getFullname(), phone.trim(), user.getDob(), null);
            if (updated) {
                // Cập nhật lại session object
                user.setPhone(phone.trim());
                session.setAttribute("user", user);
                response.getWriter().print("{\"success\":true}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().print("{\"error\":\"Cập nhật thất bại\"}");
            }
        } else if ("/auth/update-profile".equals(action)) {
            HttpSession session = request.getSession(false);
            User user = (session != null) ? (User) session.getAttribute("user") : null;
            if (user == null) {
                response.sendRedirect(request.getContextPath() + "/view/admin_login.jsp?required=1");
                return;
            }

            String fullname = request.getParameter("fullname");
            String phone = request.getParameter("phone");
            String dob = request.getParameter("dob");
            String password = request.getParameter("password");

            // Simple validation
            if (fullname == null || fullname.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/view/profile.jsp?error=name");
                return;
            }
            if (phone == null || !phone.trim().matches("\\d{10}")) {
                response.sendRedirect(request.getContextPath() + "/view/profile.jsp?error=phone");
                return;
            }

            boolean updated = userDAO.updateProfile(user.getId(), fullname, phone, dob, password);
            if (updated) {
                // Update session
                user.setFullname(fullname.trim());
                user.setPhone(phone.trim());
                user.setDob(dob != null ? dob.trim() : null);
                if (password != null && !password.trim().isEmpty()) {
                    user.setPassword(password);
                }
                session.setAttribute("user", user);
                response.sendRedirect(request.getContextPath() + "/view/profile.jsp?success=1");
            } else {
                response.sendRedirect(request.getContextPath() + "/view/profile.jsp?error=failed");
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getServletPath();
        
        if ("/auth/logout".equals(action)) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/view/admin_login.jsp?logout=1");
        }
    }
}
