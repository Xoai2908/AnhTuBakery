<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng Nhập Quản Trị – Bánh Mì Anh Tú</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Pacifico&family=Nunito:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/style.css">
    <style>
        body {
            background: linear-gradient(135deg, #FFFBEB 0%, #FEF3C7 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: var(--space-lg);
            font-family: 'Nunito', sans-serif;
        }
        .login-card {
            background: var(--white);
            max-width: 420px;
            width: 100%;
            border-radius: var(--radius-xl);
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
            border: 2px solid var(--amber);
            overflow: hidden;
            animation: slideUp 0.5s ease-out;
        }
        @keyframes slideUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .card-header {
            background: var(--brown-deep);
            padding: var(--space-2xl) var(--space-xl);
            text-align: center;
            color: var(--white);
            position: relative;
        }
        .logo-img {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            border: 3px solid var(--amber);
            background: var(--white);
            margin: 0 auto var(--space-md);
            display: block;
            object-fit: cover;
        }
        .brand-title {
            font-family: 'Pacifico', cursive;
            font-size: 1.8rem;
            color: var(--amber);
            margin-bottom: var(--space-xs);
        }
        .header-subtitle {
            font-size: 0.9rem;
            opacity: 0.8;
            font-weight: 600;
        }
        .card-body {
            padding: var(--space-2xl) var(--space-xl);
        }
        .form-group {
            margin-bottom: var(--space-lg);
        }
        .form-label {
            display: block;
            font-weight: 800;
            color: var(--brown-deep);
            margin-bottom: var(--space-xs);
            font-size: 0.95rem;
        }
        .form-input {
            width: 100%;
            padding: 0.85rem 1.15rem;
            border: 2px solid var(--cream-dark);
            border-radius: var(--radius-md);
            font-family: inherit;
            font-size: 1rem;
            color: var(--brown-deep);
            background-color: #FAFAF9;
            transition: all var(--transition);
        }
        .form-input:focus {
            outline: none;
            border-color: var(--red-dark);
            background-color: var(--white);
            box-shadow: 0 0 0 4px rgba(185, 28, 28, 0.08);
        }
        .alert {
            padding: var(--space-md);
            border-radius: var(--radius-md);
            font-size: 0.9rem;
            font-weight: 700;
            margin-bottom: var(--space-lg);
            text-align: center;
        }
        .alert-error {
            background-color: var(--red-err-bg);
            color: var(--red-err-text);
            border: 1px solid rgba(220, 38, 38, 0.2);
        }
        .alert-info {
            background-color: var(--green-bg);
            color: var(--green-ok);
            border: 1px solid rgba(22, 163, 74, 0.2);
        }
        .btn-submit {
            width: 100%;
            background: var(--red-dark);
            color: var(--white);
            border: none;
            padding: 1rem;
            border-radius: var(--radius-md);
            font-size: 1.1rem;
            font-weight: 800;
            cursor: pointer;
            transition: all var(--transition);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: var(--space-xs);
            box-shadow: 0 4px 6px -1px rgba(185, 28, 28, 0.2);
        }
        .btn-submit:hover {
            background: var(--red-darker);
            transform: translateY(-2px);
            box-shadow: 0 10px 15px -3px rgba(185, 28, 28, 0.3);
        }
        .auth-card-footer {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: var(--space-sm);
            padding: 0 var(--space-xl) var(--space-2xl);
            text-align: center;
        }
        .back-link {
            color: var(--brown-deep);
            font-weight: 700;
            text-decoration: none;
            font-size: 0.95rem;
            transition: color var(--transition);
        }
        .back-link:hover {
            color: var(--red-dark);
        }
    </style>
</head>
<body>

    <div class="login-card">
        <div class="card-header">
            <img src="../images/logo.png" alt="Logo" class="logo-img">
            <h1 class="brand-title">Bánh Mì Anh Tú</h1>
            <p class="header-subtitle">Hệ Thống Quản Trị Cửa Hàng</p>
        </div>
        
        <div class="card-body">
            <!-- Message alerts -->
            <% if (request.getParameter("error") != null) { %>
                <div class="alert alert-error">
                    ⚠️ Sai tên đăng nhập hoặc mật khẩu!
                </div>
            <% } else if (request.getParameter("logout") != null) { %>
                <div class="alert alert-info">
                    👋 Đăng xuất thành công!
                </div>
            <% } else if (request.getParameter("required") != null) { %>
                <div class="alert alert-error">
                    🔒 Vui lòng đăng nhập để tiếp tục!
                </div>
            <% } else if (request.getParameter("registered") != null) { %>
                <div class="alert alert-info">
                    🎉 Đăng ký thành công! Vui lòng đăng nhập.
                </div>
            <% } %>

            <form action="../auth/login" method="POST" novalidate>
                <% if (request.getParameter("redirect") != null) { %>
                    <input type="hidden" name="redirect" value="<%= request.getParameter("redirect") %>">
                <% } %>
                <div class="form-group">
                    <label class="form-label" for="username">Tên đăng nhập</label>
                    <input type="text" id="username" name="username" class="form-input" placeholder="Nhập tên đăng nhập" required autocomplete="username" autofocus>
                </div>
                <div class="form-group">
                    <label class="form-label" for="password">Mật khẩu</label>
                    <input type="password" id="password" name="password" class="form-input" placeholder="Nhập mật khẩu" required autocomplete="current-password">
                </div>
                <button type="submit" class="btn-submit">
                    🔐 Đăng Nhập
                </button>
            </form>
        </div>
        
        <div class="auth-card-footer">
            <div style="margin-bottom: var(--space-xs);">
                <a href="register.jsp<%= request.getParameter("redirect") != null ? "?redirect=" + java.net.URLEncoder.encode(request.getParameter("redirect"), "UTF-8") : "" %>" class="back-link" style="color: var(--red-dark); font-weight: 800;">
                    🆕 Chưa có tài khoản? Đăng ký ngay!
                </a>
            </div>
            <a href="index.jsp" class="back-link">← Quay lại trang chủ đặt hàng</a>
        </div>
    </div>

</body>
</html>
