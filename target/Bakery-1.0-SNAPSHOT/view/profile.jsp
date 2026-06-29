<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<%
    com.mycompany.bakery.business.User loggedUser = (com.mycompany.bakery.business.User) session.getAttribute("user");
    if (loggedUser == null) {
        response.sendRedirect(request.getContextPath() + "/view/admin_login.jsp?required=1&redirect=profile.jsp");
        return;
    }
    String success = request.getParameter("success");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trang Cá Nhân – Bánh Mì Anh Tú</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Pacifico&family=Nunito:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .profile-page {
            padding: var(--space-2xl) 0 var(--space-3xl);
            background: linear-gradient(135deg, #FFFBEB 0%, #FEF3C7 100%);
            min-height: 70vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .profile-card {
            background: var(--white);
            max-width: 500px;
            width: 100%;
            border-radius: var(--radius-xl);
            box-shadow: 0 10px 25px rgba(146, 64, 14, 0.08);
            border: 2px solid var(--amber);
            overflow: hidden;
        }
        .card-header {
            background: var(--brown-deep);
            padding: var(--space-xl) var(--space-lg);
            text-align: center;
            color: var(--white);
            border-bottom: 3px dashed var(--amber);
        }
        .card-title {
            font-family: 'Pacifico', cursive;
            font-size: 1.8rem;
            color: var(--amber);
            margin: 0;
        }
        .card-subtitle {
            font-size: 0.9rem;
            opacity: 0.8;
            margin-top: 5px;
            font-weight: 600;
        }
        .card-body {
            padding: var(--space-xl) var(--space-lg);
        }
        .form-group {
            margin-bottom: var(--space-md);
        }
        .form-label {
            display: block;
            font-weight: 800;
            color: var(--brown-deep);
            margin-bottom: var(--space-xs);
            font-size: 0.9rem;
        }
        .form-input {
            width: 100%;
            padding: 0.75rem 1rem;
            border: 2px solid var(--cream-dark);
            border-radius: var(--radius-md);
            font-family: inherit;
            font-size: 0.95rem;
            color: var(--brown-deep);
            background-color: #FAFAF9;
            transition: all var(--transition);
            box-sizing: border-box;
        }
        .form-input:focus {
            outline: none;
            border-color: var(--red-dark);
            background-color: var(--white);
            box-shadow: 0 0 0 3px rgba(185, 28, 28, 0.08);
        }
        .form-input:disabled {
            background-color: #EAE8E4;
            color: #78716C;
            cursor: not-allowed;
            border-color: #D6D3D1;
        }
        .alert {
            padding: var(--space-md);
            border-radius: var(--radius-md);
            font-size: 0.9rem;
            font-weight: 700;
            margin-bottom: var(--space-md);
            text-align: center;
        }
        .alert-success {
            background-color: var(--green-bg);
            color: var(--green-ok);
            border: 1px solid rgba(5, 150, 105, 0.2);
        }
        .alert-error {
            background-color: var(--red-err-bg);
            color: var(--red-err-text);
            border: 1px solid rgba(220, 38, 38, 0.2);
        }
        .btn-submit {
            width: 100%;
            background: var(--red-dark);
            color: var(--white);
            border: none;
            padding: 0.9rem;
            border-radius: var(--radius-md);
            font-size: 1rem;
            font-weight: 800;
            cursor: pointer;
            transition: all var(--transition);
            box-shadow: 0 4px 6px rgba(185, 28, 28, 0.15);
            margin-top: var(--space-md);
        }
        .btn-submit:hover {
            background: var(--red-darker);
            transform: translateY(-1px);
            box-shadow: 0 6px 12px rgba(185, 28, 28, 0.25);
        }
    </style>
</head>
<body style="min-height: 100vh; display: flex; flex-direction: column;">

    <!-- HEADER -->
    <header class="site-header" id="site-header">
        <div class="container header-inner">
            <a href="index.jsp" class="brand-logo" id="brand-logo-link">
                <img src="../images/logo.png" alt="Logo Bánh Mì Anh Tú" class="logo-img" id="header-logo" style="width: 44px; height: 44px; border-radius: 50%;">
                <div style="display: flex; flex-direction: column; justify-content: center;">
                    <span class="brand-name" style="line-height: 1.2;">Bánh Mì Anh Tú</span>
                    <span style="color:var(--yellow-light);font-weight:700;font-size:0.75rem;margin-top:2px;">Xin chào, <%= loggedUser.getFullname() %></span>
                </div>
            </a>
            <nav class="main-nav" id="main-nav">
                <a href="index.jsp" class="nav-link" id="nav-home">Trang chủ</a>
                <a href="menu.jsp" class="nav-link" id="nav-menu">Thực đơn</a>
                <a href="order.jsp" class="nav-link" id="nav-order">Đặt lẻ</a>
                <a href="wholesale.jsp" class="nav-link" id="nav-wholesale">Mua sỉ</a>
                <a href="track.jsp" class="nav-link" id="nav-track">Tình trạng đơn</a>
                <a href="profile.jsp" class="nav-link active" id="nav-profile">Trang cá nhân</a>
                <a href="../auth/logout" class="nav-link" style="color:var(--yellow-light) !important;font-weight:800;">Đăng xuất</a>
            </nav>
            <button class="hamburger" id="hamburger-btn" aria-label="Mở menu" aria-expanded="false">
                <span></span><span></span><span></span>
            </button>
        </div>
        <div class="mobile-drawer" id="mobile-drawer">
            <div class="drawer-overlay" id="drawer-overlay"></div>
            <nav class="drawer-nav" id="drawer-nav">
                <button class="drawer-close" id="drawer-close-btn">✕</button>
                <a href="index.jsp" class="drawer-link">🏠 Trang chủ</a>
                <a href="menu.jsp" class="drawer-link">🥖 Thực đơn</a>
                <a href="order.jsp" class="drawer-link">🛒 Đặt lẻ</a>
                <a href="wholesale.jsp" class="drawer-link">📦 Mua sỉ</a>
                <a href="track.jsp" class="drawer-link">📋 Tình trạng đơn</a>
                <a href="profile.jsp" class="drawer-link active">👤 Trang cá nhân</a>
                <a href="../auth/logout" class="drawer-link" style="color:var(--yellow-light) !important;font-weight:800;">🚪 Đăng xuất</a>
            </nav>
        </div>
    </header>

    <!-- MAIN CONTENT -->
    <main class="profile-page">
        <div class="profile-card">
            <div class="card-header">
                <h1 class="card-title">Bánh Mì Anh Tú</h1>
                <p class="card-subtitle">Trang Cá Nhân Của Bạn</p>
            </div>
            <div class="card-body">
                <% if ("1".equals(success)) { %>
                    <div class="alert alert-success">
                        ✅ Cập nhật thông tin cá nhân thành công!
                    </div>
                <% } else if (error != null) { %>
                    <div class="alert alert-error">
                        <% if ("name".equals(error)) { %>
                            ⚠️ Vui lòng nhập họ tên hợp lệ!
                        <% } else if ("phone".equals(error)) { %>
                            ⚠️ Vui lòng nhập số điện thoại hợp lệ (10 chữ số)!
                        <% } else { %>
                            ⚠️ Cập nhật thất bại. Vui lòng thử lại!
                        <% } %>
                    </div>
                <% } %>

                <form action="../auth/update-profile" method="POST" id="profile-form" novalidate>
                    <div class="form-group">
                        <label class="form-label" for="username">Tên tài khoản</label>
                        <input type="text" id="username" class="form-input" value="<%= loggedUser.getUsername() %>" disabled>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="fullname">Họ và tên <span style="color: var(--red-dark);">*</span></label>
                        <input type="text" id="fullname" name="fullname" class="form-input" value="<%= loggedUser.getFullname() != null ? loggedUser.getFullname() : "" %>" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="phone">Số điện thoại <span style="color: var(--red-dark);">*</span></label>
                        <input type="tel" id="phone" name="phone" class="form-input" value="<%= loggedUser.getPhone() != null ? loggedUser.getPhone() : "" %>" maxlength="10" placeholder="Ví dụ: 0912345678" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="dob">Ngày tháng năm sinh</label>
                        <input type="date" id="dob" name="dob" class="form-input" value="<%= loggedUser.getDob() != null ? loggedUser.getDob() : "" %>">
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="password">Mật khẩu mới (Bỏ trống nếu không đổi)</label>
                        <input type="password" id="password" name="password" class="form-input" placeholder="••••••••" minlength="4">
                    </div>

                    <button type="submit" class="btn-submit">💾 Lưu thay đổi</button>
                </form>
            </div>
        </div>
    </main>

    <!-- FOOTER -->
    <footer class="site-footer" style="margin-top:auto;">
        <div class="container footer-inner" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: var(--space-md); padding: var(--space-xl) var(--space-md);">
            <div class="footer-brand">
                <img src="../images/logo.png" alt="Logo" class="footer-logo" style="width: 60px; height: 60px; border-radius: 50%; object-fit: cover;">
                <p class="footer-tagline" style="margin-top: 5px; font-weight: 700; color: var(--brown-deep);">Bánh mì nhà làm – Thơm từ lò ra</p>
            </div>
            <div class="footer-contact">
                <h5 class="footer-heading" style="font-weight: 800; color: var(--brown-deep); margin-bottom: 8px;">Liên hệ</h5>
                <p class="footer-contact-info" style="font-weight: 700; color: var(--brown-deep); margin: 4px 0;">📞 <a href="tel:0779409567" style="color: inherit; text-decoration: none;">0779 409 567</a></p>
                <p class="footer-contact-info" style="font-weight: 700; color: var(--brown-deep); margin: 4px 0;">⏰ 5:30 – hết hàng</p>
            </div>
        </div>
        <div class="footer-bottom" style="text-align: center; padding: 10px; border-top: 1px solid var(--cream-dark);"><p style="margin:0; font-size:0.85rem; color:var(--gray-mid);">© 2025 Bánh Mì Anh Tú.</p></div>
    </footer>

    <script>
        document.addEventListener('DOMContentLoaded', () => {
            // Hamburger menu script
            const hamburger = document.getElementById('hamburger-btn');
            const drawer = document.getElementById('mobile-drawer');
            const overlay = document.getElementById('drawer-overlay');
            const closeBtn = document.getElementById('drawer-close-btn');

            if (hamburger && drawer) {
                function openDrawer() {
                    drawer.classList.add('open');
                    hamburger.classList.add('open');
                    document.body.style.overflow = 'hidden';
                }
                function closeDrawer() {
                    drawer.classList.remove('open');
                    hamburger.classList.remove('open');
                    document.body.style.overflow = '';
                }
                hamburger.addEventListener('click', () => {
                    if (drawer.classList.contains('open')) closeDrawer();
                    else openDrawer();
                });
                if (overlay) overlay.addEventListener('click', closeDrawer);
                if (closeBtn) closeBtn.addEventListener('click', closeDrawer);
            }

            // Form validation script
            const form = document.getElementById('profile-form');
            form.addEventListener('submit', (e) => {
                const fullname = document.getElementById('fullname').value.trim();
                const phone = document.getElementById('phone').value.trim();
                const password = document.getElementById('password').value;
                let hasError = false;

                if (!fullname) {
                    alert('Vui lòng nhập họ tên!');
                    e.preventDefault();
                    return;
                }

                if (!/^\d{10}$/.test(phone)) {
                    alert('Số điện thoại phải chứa đúng 10 chữ số!');
                    e.preventDefault();
                    return;
                }

                if (password && password.length < 4) {
                    alert('Mật khẩu mới phải dài từ 4 ký tự trở lên!');
                    e.preventDefault();
                    return;
                }
            });
        });
    </script>
</body>
</html>
