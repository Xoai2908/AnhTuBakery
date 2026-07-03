<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<%
    com.mycompany.bakery.business.User loggedUser = (com.mycompany.bakery.business.User) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tình Trạng & Lịch Sử Đơn Hàng – Bánh Mì Anh Tú</title>
    <meta name="description" content="Theo dõi tình trạng đơn hàng thời gian thực và xem lịch sử mua hàng tại Bánh Mì Anh Tú.">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Pacifico&family=Nunito:ital,wght@0,300;0,400;0,600;0,700;0,800;0,900;1,400&display=swap" rel="stylesheet">
    <script>
        window.onerror = function(message, source, lineno, colno, error) {
            console.error("Global JS Error:", message, "at", source, ":", lineno);
            const target = document.getElementById('orders-render-target') || document.body;
            if (target) {
                target.innerHTML = `
                    <div style="color: #7f1d1d; padding: 20px; border: 2px solid #b91c1c; background: #fef2f2; border-radius: 8px; margin: 20px auto; max-width: 800px; text-align: left; font-family: sans-serif; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
                        <h3 style="margin-top:0; color:#b91c1c;">❌ Lỗi Javascript (Client-side Error)</h3>
                        <p><strong>Thông điệp:</strong> ${message}</p>
                        <p><strong>Vị trí:</strong> ${source} (Dòng ${lineno}, Cột ${colno})</p>
                        <p><strong>Chi tiết (Stack trace):</strong></p>
                        <pre style="background: #fff; padding: 10px; border: 1px solid #fca5a5; border-radius: 4px; overflow-x: auto; white-space: pre-wrap; font-family: monospace; font-size: 0.85rem;">${error ? error.stack : 'Không có chi tiết'}</pre>
                    </div>`;
            }
            return false;
        };
    </script>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .track-page { padding: var(--space-xl) 0 var(--space-3xl); min-height: 65vh; }

        /* Banner tài khoản */
        .account-sync-banner {
            background: linear-gradient(135deg, #FFFBEB 0%, #FEF3C7 100%);
            border: 1.5px solid var(--amber);
            border-radius: var(--radius-xl);
            padding: var(--space-lg) var(--space-xl);
            margin-bottom: var(--space-xl);
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: var(--space-md);
            box-shadow: var(--shadow-card);
        }
        .sync-user-info {
            display: flex;
            align-items: center;
            gap: var(--space-md);
        }
        .sync-avatar {
            font-size: 2rem;
            background: var(--amber);
            width: 50px;
            height: 50px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 2px solid var(--brown-deep);
            box-shadow: 0 4px 6px rgba(0,0,0,0.05);
        }
        .sync-user-text {
            display: flex;
            flex-direction: column;
        }
        .sync-user-name {
            font-weight: 800;
            color: var(--brown-deep);
            font-size: 1.05rem;
        }
        .sync-user-sub {
            font-size: 0.85rem;
            color: var(--brown-bark);
            font-weight: 600;
        }
        .sync-phone-form {
            display: flex;
            align-items: center;
            gap: var(--space-sm);
            flex-wrap: wrap;
        }
        .sync-input-group {
            display: flex;
            align-items: center;
            border: 2px solid var(--cream-dark);
            border-radius: var(--radius-md);
            background: var(--white);
            overflow: hidden;
            transition: border-color var(--transition);
        }
        .sync-input-group:focus-within {
            border-color: var(--red-dark);
        }
        .sync-icon-lbl {
            padding: 0 var(--space-xs) 0 var(--space-sm);
            color: var(--gray-mid);
        }
        .sync-input {
            border: none;
            padding: 0.65rem 0.85rem 0.65rem 0;
            font-family: inherit;
            font-weight: 700;
            color: var(--brown-deep);
            font-size: 0.95rem;
            width: 140px;
            outline: none;
        }
        .btn-sync {
            background: var(--red-dark);
            color: var(--white);
            border: none;
            padding: 0.7rem 1.25rem;
            border-radius: var(--radius-md);
            font-weight: 800;
            font-size: 0.95rem;
            cursor: pointer;
            transition: all var(--transition);
            box-shadow: 0 4px 6px rgba(185, 28, 28, 0.15);
        }
        .btn-sync:hover {
            background: var(--red-darker);
            transform: translateY(-1px);
        }

        /* Khung tìm kiếm thủ công */
        .track-search-box {
            background: var(--white);
            border-radius: var(--radius-xl);
            padding: var(--space-xl);
            border: 1.5px solid var(--amber);
            box-shadow: var(--shadow-card);
            max-width: 650px;
            margin: 0 auto var(--space-2xl);
        }
        .track-title {
            font-family: var(--font-display);
            font-size: 1.4rem;
            color: var(--brown-deep);
            margin-bottom: var(--space-md);
            text-align: center;
        }
        .track-form-grid {
            display: grid;
            grid-template-columns: 1fr auto 1fr;
            align-items: center;
            gap: var(--space-md);
        }
        @media(max-width: 580px) {
            .track-form-grid {
                grid-template-columns: 1fr;
                gap: var(--space-sm);
            }
            .track-or { margin: var(--space-xs) 0; }
        }
        .track-input {
            padding: 0.8rem 1.15rem;
            border: 2px solid var(--cream-dark);
            border-radius: var(--radius-md);
            font-family: var(--font-body);
            font-size: 0.95rem;
            color: var(--brown-deep);
            min-height: 48px;
            transition: border-color var(--transition);
            box-sizing: border-box;
            width: 100%;
        }
        .track-input:focus { outline: none; border-color: var(--red-dark); box-shadow: 0 0 0 3px rgba(185,28,28,0.08); }
        .track-or { text-align: center; color: var(--gray-mid); font-weight: 800; font-size: 0.85rem; position: relative; }
        .btn-track-submit {
            grid-column: 1 / -1;
            min-height: 48px;
            font-size: 1.05rem;
            font-weight: 800;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: var(--space-xs);
        }

        /* Giao diện Tabs */
        .track-tabs-container {
            display: flex;
            justify-content: center;
            margin: 0 auto var(--space-xl);
            border-bottom: 2.5px solid var(--cream-dark);
            max-width: 800px;
            position: relative;
        }
        .track-tab-btn {
            background: none;
            border: none;
            padding: 0.9rem 1.8rem;
            font-size: 1.05rem;
            font-weight: 800;
            color: var(--gray-mid);
            cursor: pointer;
            position: relative;
            transition: all var(--transition);
            display: flex;
            align-items: center;
            gap: var(--space-xs);
        }
        .track-tab-btn:hover {
            color: var(--brown-deep);
        }
        .track-tab-btn.active {
            color: var(--red-dark);
        }
        .track-tab-btn.active::after {
            content: '';
            position: absolute;
            bottom: -2.5px;
            left: 0;
            right: 0;
            height: 3px;
            background-color: var(--red-dark);
            border-radius: var(--radius-full);
        }
        .tab-badge {
            background-color: var(--cream-dark);
            color: var(--brown-deep);
            font-size: 0.78rem;
            padding: 0.15rem 0.5rem;
            border-radius: var(--radius-full);
            font-weight: 800;
        }
        .track-tab-btn.active .tab-badge {
            background-color: var(--red-dark);
            color: var(--white);
        }

        /* Danh sách đơn hàng */
        .orders-list-wrapper {
            max-width: 800px;
            margin: 0 auto;
        }
        .order-card {
            background: var(--white);
            border-radius: var(--radius-xl);
            border: 1.5px solid var(--cream-dark);
            box-shadow: var(--shadow-card);
            margin-bottom: var(--space-xl);
            overflow: hidden;
            transition: all var(--transition);
            animation: fadeInUp 0.4s ease;
        }
        .order-card:hover {
            box-shadow: var(--shadow-hover);
            border-color: var(--amber);
        }
        .order-card-header {
            background: var(--brown-deep);
            padding: var(--space-md) var(--space-xl);
            display: flex;
            justify-content: space-between;
            align-items: center;
            color: var(--white);
            flex-wrap: wrap;
            gap: var(--space-sm);
        }
        .order-card-id {
            font-family: var(--font-display);
            font-size: 1.25rem;
            color: var(--amber);
        }
        .order-card-date {
            font-size: 0.85rem;
            color: var(--cream);
            font-weight: 700;
        }
        .order-card-body {
            padding: var(--space-xl);
        }
        .order-card-meta {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: var(--space-md);
            margin-bottom: var(--space-lg);
        }
        .meta-item {
            display: flex;
            flex-direction: column;
            gap: 2px;
        }
        .meta-label {
            font-size: 0.72rem;
            color: var(--gray-mid);
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }
        .meta-val {
            font-weight: 700;
            color: var(--brown-deep);
        }
        .order-status-badge {
            display: inline-flex;
            align-items: center;
            gap: var(--space-xs);
            padding: 0.35rem 0.95rem;
            border-radius: var(--radius-full);
            font-weight: 800;
            font-size: 0.82rem;
            align-self: flex-start;
        }

        /* Tiến trình Progress Tracker */
        .order-progress-tracker {
            margin: var(--space-lg) 0;
            background: var(--cream-light);
            padding: var(--space-lg);
            border-radius: var(--radius-lg);
            border: 1px solid var(--cream-dark);
        }
        .progress-title {
            font-weight: 800;
            color: var(--brown-deep);
            margin-bottom: var(--space-md);
            font-size: 0.95rem;
        }
        .progress-track {
            display: flex;
            align-items: flex-start;
            position: relative;
        }
        .progress-step {
            display: flex;
            flex-direction: column;
            align-items: center;
            flex: 1;
            position: relative;
            z-index: 1;
        }
        .progress-step::before {
            content: '';
            position: absolute;
            top: 15px; left: 50%;
            width: 100%; height: 3px;
            background: var(--cream-dark);
            z-index: -1;
            transition: background var(--transition);
        }
        .progress-step:last-child::before { display: none; }
        .progress-step.done::before { background: var(--green-ok); }
        
        .step-dot {
            width: 34px; height: 34px;
            border-radius: 50%;
            background: var(--cream-dark);
            border: 3px solid var(--cream-dark);
            display: flex; align-items: center; justify-content: center;
            font-size: 0.95rem;
            font-weight: bold;
            color: var(--gray-mid);
            transition: all var(--transition);
        }
        .progress-step.done .step-dot {
            background: var(--green-ok);
            border-color: var(--green-ok);
            color: white;
            font-size: 0.8rem;
        }
        .progress-step.current .step-dot {
            background: var(--amber);
            border-color: var(--amber-dark);
            color: var(--brown-bark);
            animation: pulse 1.5s infinite;
        }
        .step-label {
            font-size: 0.75rem;
            font-weight: 800;
            color: var(--gray-mid);
            text-align: center;
            margin-top: var(--space-sm);
            line-height: 1.3;
            max-width: 90px;
        }
        .progress-step.done .step-label { color: var(--green-ok); }
        .progress-step.current .step-label { color: var(--amber-darker); }

        @keyframes pulse {
            0%, 100% { box-shadow: 0 0 0 0 rgba(245,158,11,0.5); }
            50% { box-shadow: 0 0 0 8px rgba(245,158,11,0); }
        }

        /* Hộp thông tin quét mã QR */
        .payment-qr-block {
            background: #FFFDF5;
            border: 2px dashed var(--amber);
            border-radius: var(--radius-xl);
            padding: var(--space-lg) var(--space-xl);
            margin: var(--space-lg) 0;
            display: flex;
            align-items: center;
            gap: var(--space-xl);
            flex-wrap: wrap;
            justify-content: center;
        }
        @media(max-width: 540px) {
            .payment-qr-block {
                flex-direction: column;
                gap: var(--space-md);
                text-align: center;
            }
            .qr-info-row { justify-content: center; gap: 8px; }
        }
        .qr-placeholder-wrap {
            width: 150px; height: 150px;
            background: var(--white);
            border: 2px solid var(--amber);
            border-radius: var(--radius-lg);
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: var(--shadow-card);
            padding: var(--space-xs);
            box-sizing: border-box;
            overflow: hidden;
        }
        .payment-qr-info { flex: 1; min-width: 220px; }
        .qr-desc-title { font-weight: 900; font-size: 1rem; color: var(--brown-deep); margin-bottom: 6px; }
        .qr-info-detail { background: var(--white); border: 1px solid var(--cream-dark); border-radius: var(--radius-md); padding: var(--space-md); }
        .qr-info-row { display: flex; justify-content: space-between; font-size: 0.88rem; margin-bottom: 4px; font-weight: 700; color: var(--brown-deep); }
        .qr-info-row:last-child { margin-bottom: 0; }
        .qr-copy-hint { font-size: 0.78rem; color: var(--gray-mid); margin-top: 4px; font-style: italic; }

        /* Collapse / Xem chi tiết */
        .details-toggle-btn {
            background: var(--cream-dark);
            color: var(--brown-deep);
            border: none;
            width: 100%;
            padding: 0.75rem var(--space-md);
            border-radius: var(--radius-lg);
            font-weight: 800;
            font-size: 0.9rem;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: var(--space-xs);
            transition: all var(--transition);
            margin-top: var(--space-md);
        }
        .details-toggle-btn:hover {
            background: var(--amber);
            color: var(--brown-bark);
        }
        .order-details-pane {
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.4s cubic-bezier(0, 1, 0, 1);
            background-color: var(--cream-light);
            border-radius: var(--radius-lg);
            padding: 0 var(--space-lg);
        }
        .order-details-pane.open {
            max-height: 1500px;
            padding: var(--space-lg);
            margin-top: var(--space-md);
            border: 1.5px solid var(--cream-dark);
        }
        
        .items-title { font-weight: 800; color: var(--brown-deep); margin-bottom: var(--space-sm); font-size: 0.95rem; }
        .item-row { display: flex; justify-content: space-between; padding: var(--space-xs) 0; font-size: 0.9rem; border-bottom: 1px dashed var(--cream-dark); font-weight: 600; color: var(--brown-deep); }
        .item-row:last-child { border-bottom: none; }
        .order-summary-block { margin-top: var(--space-md); padding-top: var(--space-md); border-top: 1.5px solid var(--cream-dark); }
        .summary-row { display: flex; justify-content: space-between; font-size: 0.9rem; font-weight: 600; color: var(--gray-mid); margin-bottom: 4px; }
        .summary-row.grand-total { font-weight: 900; font-size: 1.1rem; color: var(--red-dark); margin-top: var(--space-sm); padding-top: var(--space-sm); border-top: 1px dashed var(--cream-dark); }

        /* Lịch sử mua hàng */
        .history-card {
            background: var(--white);
            border-radius: var(--radius-lg);
            border: 1.5px solid var(--cream-dark);
            margin-bottom: var(--space-md);
            overflow: hidden;
            transition: all var(--transition);
        }
        .history-card:hover {
            border-color: var(--amber);
            box-shadow: var(--shadow-card);
        }
        .history-card-header {
            padding: var(--space-md) var(--space-lg);
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #FAF9F6;
            flex-wrap: wrap;
            gap: var(--space-sm);
            border-bottom: 1px solid var(--cream-dark);
        }
        .history-id-block { display: flex; align-items: center; gap: var(--space-md); }
        .history-id { font-weight: 800; color: var(--brown-deep); font-size: 1.05rem; }
        .btn-reorder {
            background: var(--red-dark);
            color: var(--white);
            border: none;
            padding: 0.45rem 1rem;
            border-radius: var(--radius-md);
            font-weight: 800;
            font-size: 0.85rem;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 4px;
            transition: all var(--transition);
        }
        .btn-reorder:hover {
            background: var(--red-darker);
            transform: translateY(-1px);
            box-shadow: 0 4px 6px rgba(185, 28, 28, 0.15);
        }

        /* Status colors */
        .status-pending   { background: #FEF3C7; color: #92400E; }
        .status-paid      { background: var(--green-bg); color: var(--green-ok); }
        .status-preparing { background: #FEF3C7; color: #92400E; }
        .status-ready     { background: #DBEAFE; color: #1E40AF; }
        .status-delivering{ background: #EDE9FE; color: #6D28D9; }
        .status-completed { background: var(--green-bg); color: var(--green-ok); }
        .status-cancelled { background: var(--red-err-bg); color: var(--red-err-text); }

        .empty-state-box {
            text-align: center;
            padding: var(--space-3xl) var(--space-xl);
            background: var(--white);
            border-radius: var(--radius-xl);
            border: 1.5px dashed var(--cream-dark);
            box-shadow: var(--shadow-card);
        }
        .empty-icon { font-size: 3.5rem; margin-bottom: var(--space-md); }
        .empty-title { font-family: var(--font-display); color: var(--brown-deep); font-size: 1.3rem; margin-bottom: 6px; }
        .empty-desc { color: var(--gray-mid); font-weight: 600; margin-bottom: var(--space-lg); }

        .login-suggest-box {
            background: var(--white);
            border-radius: var(--radius-xl);
            border: 1.5px solid var(--amber);
            padding: var(--space-xl);
            text-align: center;
            box-shadow: var(--shadow-card);
            margin-bottom: var(--space-2xl);
            max-width: 650px;
            margin: 0 auto var(--space-xl);
        }
        .login-suggest-title {
            font-family: var(--font-display);
            font-size: 1.3rem;
            color: var(--brown-deep);
            margin-bottom: 6px;
        }
        .login-suggest-desc {
            color: var(--gray-mid);
            font-weight: 600;
            margin-bottom: var(--space-md);
            font-size: 0.92rem;
        }
    </style>
</head>
<body>
    <!-- HEADER -->
    <header class="site-header" id="site-header">
        <div class="container header-inner">
            <a href="index.jsp" class="brand-logo" style="display: flex; align-items: center; gap: var(--space-sm);">
                <img src="../images/logo.png" alt="Logo" class="logo-img">
                <div style="display: flex; flex-direction: column; justify-content: center;">
                    <span class="brand-name" style="line-height: 1.2;">Bánh Mì Anh Tú</span>
                    <% if (loggedUser != null) { %>
                        <span style="color:var(--yellow-light);font-weight:700;font-size:0.75rem;margin-top:2px;">Xin chào, <%= loggedUser.getFullname() %></span>
                    <% } %>
                </div>
            </a>
            <nav class="main-nav" id="main-nav">
                <a href="index.jsp" class="nav-link">Trang chủ</a>
                <a href="menu.jsp" class="nav-link">Thực đơn</a>
                <a href="order.jsp" class="nav-link">Đặt lẻ</a>
                <a href="wholesale.jsp" class="nav-link">Mua sỉ</a>
                <a href="track.jsp" class="nav-link active">Tình trạng đơn</a>
                <% if (loggedUser != null) { %>
                    <% if ("ADMIN".equals(loggedUser.getRole())) { %>
                        <a href="admin_dashboard.jsp" class="nav-link" style="color:var(--yellow-light) !important;font-weight:800;">Trang quản trị</a>
                    <% } %>
                    <a href="profile.jsp" class="nav-link">Trang cá nhân</a>
                    <a href="../auth/logout" class="nav-link" style="color:var(--yellow-light) !important;font-weight:800;">Đăng xuất</a>
                <% } else { %>
                    <a href="admin_login.jsp?redirect=track.jsp" class="btn btn-primary nav-cta">👤 Đăng nhập</a>
                <% } %>
            </nav>
            <button class="hamburger" id="hamburger-btn" aria-label="Mở menu" aria-expanded="false">
                <span></span><span></span><span></span>
            </button>
        </div>
        <div class="mobile-drawer" id="mobile-drawer">
            <div class="drawer-overlay" id="drawer-overlay"></div>
            <nav class="drawer-nav">
                <button class="drawer-close" id="drawer-close-btn">✕</button>
                <a href="index.jsp" class="drawer-link">🏠 Trang chủ</a>
                <a href="menu.jsp" class="drawer-link">🥖 Thực đơn</a>
                <a href="order.jsp" class="drawer-link">🛒 Đặt lẻ</a>
                <a href="wholesale.jsp" class="drawer-link">📦 Mua sỉ</a>
                <a href="track.jsp" class="drawer-link">📋 Tình trạng đơn</a>
                <% if (loggedUser != null) { %>
                    <div style="padding:10px 15px;color:var(--cream);font-weight:800;font-size:0.95rem;border-top:1px solid var(--cream-dark)">Xin chào, <%= loggedUser.getFullname() %></div>
                    <% if ("ADMIN".equals(loggedUser.getRole())) { %>
                        <a href="admin_dashboard.jsp" class="drawer-link" style="color:var(--yellow-light) !important;font-weight:800;">⚙️ Trang quản trị</a>
                    <% } %>
                    <a href="profile.jsp" class="drawer-link">👤 Trang cá nhân</a>
                    <a href="../auth/logout" class="drawer-link" style="color:var(--yellow-light) !important;font-weight:800;">🚪 Đăng xuất</a>
                <% } else { %>
                    <a href="admin_login.jsp?redirect=track.jsp" class="drawer-link" style="font-weight:800;">🔑 Đăng nhập</a>
                <% } %>
            </nav>
        </div>
    </header>

    <div class="page-hero track-hero" id="page-hero">
        <div class="container page-hero-inner">
            <h1 class="page-hero-title">📋 Tình Trạng Đơn Hàng</h1>
            <p class="page-hero-sub">Theo dõi tiến trình đơn hàng và lịch sử mua hàng của bạn</p>
        </div>
    </div>

    <main class="track-page" id="track-page">
        <div class="container">

            <!-- Banner cho tài khoản thành viên -->
            <% if (loggedUser != null) { %>
                <div class="account-sync-banner" id="account-sync-banner">
                    <div class="sync-user-info">
                        <div class="sync-avatar">🥖</div>
                        <div class="sync-user-text">
                            <span class="sync-user-name">Chào mừng, <%= loggedUser.getFullname() %>!</span>
                            <span class="sync-user-sub">📦 Đơn hàng được tự động đồng bộ theo tài khoản của bạn</span>
                        </div>
                    </div>
                </div>
            <% } else { %>
                <div class="login-suggest-box">
                    <h3 class="login-suggest-title">🔑 Tiết kiệm thời gian với tài khoản thành viên</h3>
                    <p class="login-suggest-desc">Đăng nhập giúp tự động đồng bộ đơn hàng đang chuẩn bị và lưu trữ lịch sử mua sỉ/lẻ.</p>
                    <a href="admin_login.jsp?redirect=track.jsp" class="btn btn-outline" style="padding:0.55rem 1.25rem;">👤 Đăng nhập tài khoản</a>
                </div>
            <% } %>

            <!-- Tìm kiếm thủ công (cho khách vãng lai hoặc tìm nhanh mã đơn) -->
            <div class="track-search-box" id="track-search-box">
                <h2 class="track-title">🔍 Tìm đơn hàng nhanh</h2>
                <div class="track-form-grid">
                    <input type="text" id="manual-order-id" class="track-input" placeholder="Mã đơn (vd: DH12345678)" autocomplete="off">
                    <div class="track-or">hoặc</div>
                    <input type="tel" id="manual-phone" class="track-input" placeholder="Số điện thoại mua hàng" maxlength="10" inputmode="numeric">
                    <button class="btn btn-primary btn-track-submit" onclick="manualTrackSearch()">🔍 Tìm kiếm nhanh</button>
                </div>
            </div>

            <!-- Tabs cho Đơn hàng hiện tại và Lịch sử mua hàng -->
            <div class="track-tabs-container hidden" id="tabs-header-container">
                <button class="track-tab-btn active" id="tab-active" onclick="switchTab('active')">
                    🚴 Đơn hiện tại <span class="tab-badge" id="badge-active-count">0</span>
                </button>
                <button class="track-tab-btn" id="tab-history" onclick="switchTab('history')">
                    🎉 Lịch sử mua hàng <span class="tab-badge" id="badge-history-count">0</span>
                </button>
            </div>

            <!-- Giao diện kết quả chính -->
            <div class="orders-list-wrapper" id="orders-list-wrapper">
                <div style="text-align:center;padding:var(--space-lg);color:var(--gray-mid);" id="initial-loading-text" class="hidden">
                    ⏳ Đang truy vấn danh sách đơn hàng...
                </div>
                <div id="orders-render-target">
                    <!-- Được render động bằng Javascript -->
                </div>
            </div>
        </div>
    </main>

    <footer class="site-footer">
        <div class="container footer-inner">
            <div class="footer-brand">
                <img src="../images/logo.png" alt="Logo" class="footer-logo">
                <p class="footer-tagline">Bánh mì nhà làm – Thơm từ lò ra</p>
            </div>
            <div class="footer-contact">
                <h5 class="footer-heading">Liên hệ hỗ trợ</h5>
                <p class="footer-contact-info"><span>📞</span> <a href="tel:0779409567">0779 409 567</a></p>
                <p class="footer-contact-info"><span>⏰</span> 5:30 – hết hàng</p>
            </div>
        </div>
        <div class="footer-bottom"><p>© 2025 Bánh Mì Anh Tú.</p></div>
    </footer>

    <div class="toast" id="toast" role="alert"></div>
    <button class="back-to-top" id="back-to-top" onclick="window.scrollTo({top:0,behavior:'smooth'})">↑</button>

    <%
        String _userPhone = "";
        if (loggedUser != null && loggedUser.getPhone() != null && !loggedUser.getPhone().isEmpty()) {
            _userPhone = loggedUser.getPhone();
        }
        String _userId = "";
        if (loggedUser != null) {
            _userId = String.valueOf(loggedUser.getId());
        }
    %>
    <!-- Metadata passed from JSP to JavaScript to avoid IDE syntax parsing errors -->
    <div id="jsp-metadata" 
         data-logged-in="<%= loggedUser != null %>" 
         data-phone="<%= _userPhone %>" 
         data-user-id="<%= _userId %>"
         data-context-path="<%= request.getContextPath() %>" 
         style="display: none;"></div>

    <script src="../js/cart.js?v=20260614_v2"></script>
    <script>
        /* Constants & Mappings */
        const STORAGE_PHONE_KEY = 'anhtubakery_customer_phone';
        
        const metadataEl = document.getElementById('jsp-metadata');
        const isUserLoggedIn = metadataEl ? metadataEl.getAttribute('data-logged-in') === 'true' : false;
        const loggedUserPhone = metadataEl ? (metadataEl.getAttribute('data-phone') || '') : '';

        const STATUS_LABELS = {
            PENDING: ['⏳', 'Chờ xử lý', 'status-pending'],
            PAID: ['💳', 'Đã thanh toán', 'status-paid'],
            PREPARING: ['🍳', 'Đang chuẩn bị', 'status-preparing'],
            READY: ['✅', 'Sẵn sàng', 'status-ready'],
            DELIVERING: ['🚴', 'Đang giao hàng', 'status-delivering'],
            COMPLETED: ['🎉', 'Đã hoàn thành', 'status-completed'],
            CANCELLED: ['❌', 'Đã hủy', 'status-cancelled']
        };

        const STEP_INFO_SHIP = [
            { key: 'PENDING', label: 'Đặt hàng', icon: '📋' },
            { key: 'PAID', label: 'Thanh toán', icon: '💳' },
            { key: 'PREPARING', label: 'Chuẩn bị', icon: '🍳' },
            { key: 'READY', label: 'Sẵn sàng', icon: '✅' },
            { key: 'DELIVERING', label: 'Đang giao', icon: '🚴' },
            { key: 'COMPLETED', label: 'Hoàn thành', icon: '🎉' }
        ];

        const STEP_INFO_PICKUP = [
            { key: 'PENDING', label: 'Đặt hàng', icon: '📋' },
            { key: 'PAID', label: 'Thanh toán', icon: '💳' },
            { key: 'PREPARING', label: 'Chuẩn bị', icon: '🍳' },
            { key: 'READY', label: 'Sẵn sàng', icon: '✅' },
            { key: 'COMPLETED', label: 'Hoàn thành', icon: '🎉' }
        ];

        /* State management */
        let loadedOrders = [];
        let activeTab = 'active'; // 'active' or 'history'
        let currentSyncPhone = '';
        const activeSockets = new Map(); // orderId -> WebSocket instance

        document.addEventListener('DOMContentLoaded', () => {
            initPage();
            setupHamburger();
            setupBackToTop();
            
            // Hỗ trợ nút Enter cho khung tìm kiếm nhanh
            ['manual-order-id', 'manual-phone'].forEach(id => {
                document.getElementById(id)?.addEventListener('keydown', e => { if (e.key === 'Enter') manualTrackSearch(); });
            });
        });

        function initPage() {
            if (isUserLoggedIn) {
                // Người dùng đã đăng nhập: tự động tải đơn hàng theo tài khoản (user_id)
                fetchOrdersByAccount();
            } else {
                // Khách vãng lai: thử tải theo SĐT đã lưu trước đó
                currentSyncPhone = localStorage.getItem(STORAGE_PHONE_KEY) || '';
                if (currentSyncPhone) {
                    document.getElementById('manual-phone').value = currentSyncPhone;
                    fetchOrders(currentSyncPhone);
                }
            }
        }

        /* Đồng bộ số điện thoại cho thành viên */
        function syncPhoneNumber() {
            const phone = document.getElementById('sync-phone-input').value.trim();
            if (!/^\d{10}$/.test(phone)) {
                showToast('⚠️ Số điện thoại phải đúng 10 số!', 'warn');
                return;
            }
            localStorage.setItem(STORAGE_PHONE_KEY, phone);
            currentSyncPhone = phone;

            // Cập nhật SĐT lên server nếu đã đăng nhập
            if (isUserLoggedIn) {
                fetch('../auth/update-phone', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'phone=' + encodeURIComponent(phone)
                }).then(res => {
                    if (res.ok) showToast('✅ Đã lưu số điện thoại vào tài khoản!');
                    else showToast('✅ Đã đồng bộ số điện thoại!');
                }).catch(() => showToast('✅ Đã đồng bộ số điện thoại!'));
            } else {
                showToast('✅ Đã đồng bộ số điện thoại!');
            }
            fetchOrders(phone);
        }

        /* Tìm kiếm thủ công */
        function manualTrackSearch() {
            const orderId = document.getElementById('manual-order-id').value.trim().toUpperCase();
            const phone = document.getElementById('manual-phone').value.trim();
            const renderTarget = document.getElementById('orders-target') || document.getElementById('orders-render-target');

            if (!orderId && !phone) {
                showToast('⚠️ Vui lòng nhập mã đơn hoặc số điện thoại!', 'warn');
                return;
            }

            document.getElementById('tabs-header-container').classList.add('hidden');
            renderTarget.innerHTML = `<div style="text-align:center;padding:var(--space-xl);color:var(--gray-mid)">⏳ Đang tìm kiếm...</div>`;
            renderTarget.scrollIntoView({ behavior: 'smooth', block: 'start' });

            if (orderId) {
                // Tra cứu đơn hàng đơn lẻ theo mã
                fetch('../resources/orders/' + encodeURIComponent(orderId))
                .then(res => {
                    if (res.status === 404) return null;
                    if (!res.ok) throw new Error('Không thể kết nối máy chủ');
                    return res.json();
                })
                .then(order => {
                    if (!order) {
                        renderTarget.innerHTML = getEmptyStateHtml('🔍 Không tìm thấy đơn hàng', `Không tìm thấy đơn hàng nào có mã #${orderId}.`);
                        return;
                    }
                    loadedOrders = [order];
                    renderSingleManualResult(order);
                    connectWebSocketForOrder(order.id);
                })
                .catch(err => {
                    renderTarget.innerHTML = getEmptyStateHtml('⚠️ Lỗi kết nối', err.message);
                });
            } else {
                // Tra cứu danh sách đơn hàng theo điện thoại
                localStorage.setItem(STORAGE_PHONE_KEY, phone);
                currentSyncPhone = phone;
                fetchOrders(phone);
            }
        }

        /* Tải danh sách đơn hàng */
        function fetchOrders(phone) {
            const loadingText = document.getElementById('initial-loading-text');
            const renderTarget = document.getElementById('orders-render-target');
            
            loadingText.classList.remove('hidden');
            renderTarget.innerHTML = '';

            fetch('../resources/orders?phone=' + encodeURIComponent(phone))
            .then(res => {
                if (!res.ok) throw new Error('Lỗi truy cập dữ liệu máy chủ');
                return res.json();
            })
            .then(data => {
                loadedOrders = data || [];
                loadingText.classList.add('hidden');
                
                if (loadedOrders.length > 0) {
                    document.getElementById('tabs-header-container').classList.remove('hidden');
                    updateTabBadges();
                    
                    // Tự động chuyển sang tab lịch sử nếu không có đơn hàng hoạt động
                    const activeCount = loadedOrders.filter(o => 
                        o.status !== 'COMPLETED' && o.status !== 'CANCELLED'
                    ).length;
                    if (activeCount === 0) {
                        activeTab = 'history';
                        document.getElementById('tab-active').classList.remove('active');
                        document.getElementById('tab-history').classList.add('active');
                    } else {
                        activeTab = 'active';
                        document.getElementById('tab-active').classList.add('active');
                        document.getElementById('tab-history').classList.remove('active');
                    }
                    
                    renderTabContent();
                    initWebSocketsForActiveOrders();
                } else {
                    document.getElementById('tabs-header-container').classList.add('hidden');
                    renderTarget.innerHTML = getEmptyStateHtml('📦 Chưa có đơn hàng', `Chưa tìm thấy đơn hàng nào khớp với số điện thoại <strong>${phone}</strong>.`);
                }
            })
            .catch(err => {
                loadingText.classList.add('hidden');
                renderTarget.innerHTML = getEmptyStateHtml('⚠️ Lỗi kết nối', err.message);
            });
        }

        /* Tải danh sách đơn hàng theo tài khoản thành viên */
        function fetchOrdersByAccount() {
            const loadingText = document.getElementById('initial-loading-text');
            const renderTarget = document.getElementById('orders-render-target');
            
            loadingText.classList.remove('hidden');
            renderTarget.innerHTML = '';

            fetch('../resources/orders')
            .then(res => {
                if (!res.ok) throw new Error('Lỗi truy cập dữ liệu máy chủ');
                return res.json();
            })
            .then(data => {
                loadedOrders = data || [];
                loadingText.classList.add('hidden');
                
                if (loadedOrders.length > 0) {
                    document.getElementById('tabs-header-container').classList.remove('hidden');
                    updateTabBadges();
                    
                    // Tự động chuyển sang tab lịch sử nếu không có đơn hàng hoạt động
                    const activeCount = loadedOrders.filter(o => 
                        o.status !== 'COMPLETED' && o.status !== 'CANCELLED'
                    ).length;
                    if (activeCount === 0) {
                        activeTab = 'history';
                        document.getElementById('tab-active').classList.remove('active');
                        document.getElementById('tab-history').classList.add('active');
                    } else {
                        activeTab = 'active';
                        document.getElementById('tab-active').classList.add('active');
                        document.getElementById('tab-history').classList.remove('active');
                    }
                    
                    renderTabContent();
                    initWebSocketsForActiveOrders();
                } else {
                    document.getElementById('tabs-header-container').classList.add('hidden');
                    renderTarget.innerHTML = getEmptyStateHtml('📦 Chưa có đơn hàng', `Tài khoản của bạn chưa có đơn hàng nào.`);
                }
            })
            .catch(err => {
                loadingText.classList.add('hidden');
                renderTarget.innerHTML = getEmptyStateHtml('⚠️ Lỗi kết nối', err.message);
            });
        }

        /* Phân chia và đếm số lượng cho Tab badges */
        function updateTabBadges() {
            const activeCount = loadedOrders.filter(o => 
                o.status !== 'COMPLETED' && o.status !== 'CANCELLED'
            ).length;
            const historyCount = loadedOrders.length - activeCount;

            document.getElementById('badge-active-count').textContent = activeCount;
            document.getElementById('badge-history-count').textContent = historyCount;
        }

        /* Chuyển tab */
        function switchTab(tab) {
            activeTab = tab;
            document.getElementById('tab-active').classList.toggle('active', tab === 'active');
            document.getElementById('tab-history').classList.toggle('active', tab === 'history');
            renderTabContent();
        }

        /* Render nội dung Tab */
        function renderTabContent() {
            const renderTarget = document.getElementById('orders-render-target');
            renderTarget.innerHTML = '';

            const isActiveTab = activeTab === 'active';
            const filtered = loadedOrders.filter(o => {
                const isFinished = o.status === 'COMPLETED' || o.status === 'CANCELLED';
                return isActiveTab ? !isFinished : isFinished;
            });

            if (filtered.length === 0) {
                if (isActiveTab) {
                    renderTarget.innerHTML = getEmptyStateHtml('🚴 Không có đơn hàng nào', 'Bạn không có đơn hàng nào đang trong tiến trình chế biến hoặc giao hàng.', 'menu.jsp', '🛒 Khám phá thực đơn ngay');
                } else {
                    renderTarget.innerHTML = getEmptyStateHtml('🎉 Chưa có lịch sử mua', 'Lịch sử mua hàng của bạn trống. Hãy đặt những món ngon đầu tiên nhé!', 'menu.jsp', '🥖 Đặt hàng ngay');
                }
                return;
            }

            filtered.forEach(order => {
                const card = document.createElement('div');
                card.className = isActiveTab ? 'order-card' : 'history-card';
                card.id = `card-${order.id}`;

                const [statusIcon, statusLabel, statusClass] = STATUS_LABELS[order.status] || ['❓','Không xác định',''];
                const methodLabel = order.deliveryMethod === 'TU_LAY' ? '🏠 Tự đến lấy' : '🚴 Giao tận nơi';

                if (isActiveTab) {
                    // Render card đơn hàng active
                    const steps = order.deliveryMethod === 'TU_LAY' ? STEP_INFO_PICKUP : STEP_INFO_SHIP;
                    const currentIdx = steps.findIndex(s => s.key === order.status);
                    
                    const progressHtml = steps.map((step, i) => {
                        let cls = '';
                        if (i < currentIdx) cls = 'done';
                        else if (i === currentIdx) cls = 'current';
                        return `
                            <div class="progress-step ${cls}">
                                <div class="step-dot">${i < currentIdx ? '✓' : step.icon}</div>
                                <div class="step-label">${step.label}</div>
                            </div>`;
                    }).join('');

                    // QR section if PENDING
                    const qrContentVal = `ANHTUBAKERY ${order.id}`;
                    const qrImageUrl = `https://img.vietqr.io/image/BIDV-8888824977-compact2.png?amount=${order.total}&addInfo=${encodeURIComponent(qrContentVal)}&accountName=HO%20KINH%20DOANH%20VO%20VAN%20TRU`;
                    
                    const qrBlockHtml = order.status === 'PENDING' ? `
                        <div class="payment-qr-block">
                            <div class="qr-placeholder-wrap">
                                <img src="${qrImageUrl}" alt="Mã QR Thanh Toán" style="width: 100%; height: 100%; object-fit: contain;" />
                            </div>
                            <div class="payment-qr-info">
                                <div class="qr-desc-title">💳 Chuyển khoản QR ngân hàng</div>
                                <div class="qr-info-detail">
                                    <div class="qr-info-row"><span>Ngân hàng:</span><strong>BIDV (PGD An Cựu)</strong></div>
                                    <div class="qr-info-row"><span>Chủ tài khoản:</span><strong>HO KINH DOANH VO VAN TRU</strong></div>
                                    <div class="qr-info-row"><span>Số tài khoản:</span><strong>8888824977</strong></div>
                                    <div class="qr-info-row"><span>Số tiền:</span><strong style="color:var(--red-dark)">${order.total.toLocaleString('vi-VN')}đ</strong></div>
                                    <div class="qr-info-row"><span>Nội dung CK:</span><strong style="color:var(--red-dark)">${qrContentVal}</strong></div>
                                </div>
                                <p class="qr-copy-hint">💡 Vui lòng ghi đúng nội dung để đơn được duyệt tự động nhé.</p>
                            </div>
                        </div>` : '';

                    const itemsHtml = order.items.map(item => `
                        <div class="item-row">
                            <span>${item.name} ×${item.qty}</span>
                            <span>${(item.price * item.qty).toLocaleString('vi-VN')}đ</span>
                        </div>`).join('');

                    card.innerHTML = `
                        <div class="order-card-header">
                            <span class="order-card-id">#${order.id}</span>
                            <span class="order-card-date">${order.createdAt}</span>
                        </div>
                        <div class="order-card-body">
                            <div class="order-card-meta">
                                <div class="meta-item"><span class="meta-label">Trạng thái</span><span class="order-status-badge ${statusClass}">${statusIcon} ${statusLabel}</span></div>
                                <div class="meta-item"><span class="meta-label">Nhận hàng</span><span class="meta-val">${methodLabel}</span></div>
                                <div class="meta-item"><span class="meta-label">Tổng tiền</span><span class="meta-val" style="color:var(--red-dark)">${order.total.toLocaleString('vi-VN')}đ</span></div>
                            </div>

                            <div class="order-progress-tracker">
                                <div class="progress-title">Tiến trình chuẩn bị</div>
                                <div class="progress-track">${progressHtml}</div>
                            </div>

                            ${qrBlockHtml}

                            <button class="details-toggle-btn" onclick="toggleDetails('${order.id}')" id="toggle-btn-${order.id}">
                                <span>🥖 Xem chi tiết sản phẩm</span> ▾
                            </button>
                            
                            <div class="order-details-pane" id="pane-${order.id}">
                                <div class="items-title">Chi tiết sản phẩm đã đặt</div>
                                ${itemsHtml}
                                <div class="order-summary-block">
                                    <div class="summary-row"><span>Tiền món ăn</span><span>${order.subtotal.toLocaleString('vi-VN')}đ</span></div>
                                    <div class="summary-row"><span>Phí ship</span><span>${order.shippingFee > 0 ? order.shippingFee.toLocaleString('vi-VN') + 'đ' : 'Miễn phí'}</span></div>
                                    ${order.deliveryAddress ? `<div class="summary-row"><span>Địa chỉ giao:</span><span style="color:var(--brown-bark);text-align:right">${order.deliveryAddress}</span></div>` : ''}
                                    ${order.pickupTime ? `<div class="summary-row"><span>Khung giờ lấy:</span><span style="color:var(--brown-bark)">${order.pickupTime}</span></div>` : ''}
                                    ${order.note ? `<div class="summary-row"><span>Ghi chú của bạn:</span><span style="color:var(--red-dark);font-weight:bold">${order.note}</span></div>` : ''}
                                    <div class="summary-row grand-total">
                                        <span>TỔNG THANH TOÁN</span>
                                        <span>${order.total.toLocaleString('vi-VN')}đ</span>
                                    </div>
                                </div>
                            </div>
                        </div>`;
                } else {
                    // Render card đơn hàng lịch sử
                    const itemsHtml = order.items.map(item => `
                        <div class="item-row">
                            <span>${item.name} ×${item.qty}</span>
                            <span>${(item.price * item.qty).toLocaleString('vi-VN')}đ</span>
                        </div>`).join('');

                    card.innerHTML = `
                        <div class="history-card-header">
                            <div class="history-id-block">
                                <span class="history-id">#${order.id}</span>
                                <span class="order-status-badge ${statusClass}" style="padding:0.2rem 0.65rem;font-size:0.75rem">${statusIcon} ${statusLabel}</span>
                            </div>
                            <button class="btn-reorder" onclick="reorderOrder('${order.id}')">
                                🔄 Đặt lại đơn này
                            </button>
                        </div>
                        <div class="order-card-body" style="padding: var(--space-md) var(--space-lg);">
                            <div class="order-card-meta" style="margin-bottom:0; grid-template-columns: 1fr 1fr 1fr; gap:var(--space-sm)">
                                <div class="meta-item"><span class="meta-label">Ngày mua</span><span class="meta-val" style="font-size:0.85rem">${order.createdAt}</span></div>
                                <div class="meta-item"><span class="meta-label">Hình thức</span><span class="meta-val" style="font-size:0.85rem">${methodLabel}</span></div>
                                <div class="meta-item"><span class="meta-label">Thanh toán</span><span class="meta-val" style="color:var(--red-dark); font-size:0.9rem">${order.total.toLocaleString('vi-VN')}đ</span></div>
                            </div>

                            <button class="details-toggle-btn" onclick="toggleDetails('${order.id}')" id="toggle-btn-${order.id}" style="margin-top:var(--space-md); padding:0.5rem 1rem; font-size:0.82rem;">
                                <span>🥖 Xem chi tiết</span> ▾
                            </button>
                            
                            <div class="order-details-pane" id="pane-${order.id}">
                                <div class="items-title">Các sản phẩm đã đặt</div>
                                ${itemsHtml}
                                <div class="order-summary-block">
                                    <div class="summary-row"><span>Tiền hàng:</span><span>${order.subtotal.toLocaleString('vi-VN')}đ</span></div>
                                    <div class="summary-row"><span>Phí ship:</span><span>${order.shippingFee > 0 ? order.shippingFee.toLocaleString('vi-VN') + 'đ' : 'Miễn phí'}</span></div>
                                    <div class="summary-row grand-total" style="font-size:1rem;">
                                        <span>TỔNG ĐÃ THANH TOÁN</span>
                                        <span>${order.total.toLocaleString('vi-VN')}đ</span>
                                    </div>
                                </div>
                            </div>
                        </div>`;
                }
                renderTarget.appendChild(card);
            });
        }

        /* Render kết quả tìm kiếm thủ công đơn lẻ */
        function renderSingleManualResult(order) {
            const renderTarget = document.getElementById('orders-render-target');
            renderTarget.innerHTML = '';
            
            // Render active card nhưng nổi bật
            activeTab = (order.status === 'COMPLETED' || order.status === 'CANCELLED') ? 'history' : 'active';
            loadedOrders = [order];
            renderTabContent();
        }

        /* Mở rộng / Thu gọn chi tiết */
        function toggleDetails(orderId) {
            const pane = document.getElementById(`pane-${orderId}`);
            const btn = document.getElementById(`toggle-btn-${orderId}`);
            if (!pane) return;

            const isOpen = pane.classList.contains('open');
            pane.classList.toggle('open', !isOpen);
            
            if (isOpen) {
                btn.innerHTML = `<span>🥖 Xem chi tiết</span> ▾`;
            } else {
                btn.innerHTML = `<span>🥖 Thu gọn chi tiết</span> ▴`;
            }
        }

        /* Kết nối WebSocket cho tất cả các đơn hàng active */
        function initWebSocketsForActiveOrders() {
            // Close sockets for orders no longer active
            const activeOrderIds = new Set(
                loadedOrders
                .filter(o => o.status !== 'COMPLETED' && o.status !== 'CANCELLED')
                .map(o => o.id)
            );

            for (const [id, socket] of activeSockets.entries()) {
                if (!activeOrderIds.has(id)) {
                    socket.close();
                    activeSockets.delete(id);
                }
            }

            // Connect new active orders
            activeOrderIds.forEach(id => {
                if (!activeSockets.has(id)) {
                    connectWebSocketForOrder(id);
                }
            });
        }

        function connectWebSocketForOrder(orderId) {
            const metadataEl = document.getElementById('jsp-metadata');
            const contextPath = metadataEl ? (metadataEl.getAttribute('data-context-path') || '') : '';
            const protocol = window.location.protocol === 'https:' ? 'wss://' : 'ws://';
            const wsUrl = protocol + window.location.host + contextPath + '/order-ws/' + encodeURIComponent(orderId);

            try {
                const ws = new WebSocket(wsUrl);
                activeSockets.set(orderId, ws);

                ws.onmessage = function(event) {
                    const newStatus = event.data;
                    
                    // Gọi API lấy thông tin đơn hàng mới nhất để cập nhật
                    fetch('../resources/orders/' + encodeURIComponent(orderId))
                    .then(response => {
                        if (response.ok) return response.json();
                        throw new Error('Lỗi làm mới dữ liệu');
                    })
                    .then(updatedOrder => {
                        // Cập nhật lại list trong bộ nhớ
                        const idx = loadedOrders.findIndex(o => o.id === orderId);
                        if (idx !== -1) {
                            loadedOrders[idx] = updatedOrder;
                        } else {
                            loadedOrders.push(updatedOrder);
                        }

                        // Re-render UI
                        updateTabBadges();
                        renderTabContent();

                        // Nếu đơn đã kết thúc, đóng socket
                        if (updatedOrder.status === 'COMPLETED' || updatedOrder.status === 'CANCELLED') {
                            ws.close();
                            activeSockets.delete(orderId);
                        }

                        const statusText = STATUS_LABELS[newStatus] ? STATUS_LABELS[newStatus][1] : newStatus;
                        showToast(`🔔 Đơn hàng #${orderId} vừa cập nhật: ${statusText}`);
                    })
                    .catch(err => {
                        console.error('Error refreshing socket order:', err);
                    });
                };

                ws.onclose = function() {
                    activeSockets.delete(orderId);
                };

                ws.onerror = function(err) {
                    console.error(`WebSocket error for #${orderId}:`, err);
                };
            } catch (e) {
                console.error('Error creating WebSocket connection:', e);
            }
        }

        /* Đặt lại đơn hàng nhanh (Re-order) */
        function reorderOrder(orderId) {
            const order = loadedOrders.find(o => o.id === orderId);
            if (!order || !order.items) {
                showToast('⚠️ Không thể tải thông tin để đặt lại đơn!', 'warn');
                return;
            }

            if (!window.BakeryCart) {
                showToast('⚠️ Hệ thống giỏ hàng bị lỗi. Vui lòng reload trang!', 'warn');
                return;
            }

            // Xóa sạch giỏ hàng cũ
            window.BakeryCart.clear();

            // Thêm các sản phẩm vào giỏ hàng
            order.items.forEach(item => {
                for (let i = 0; i < item.qty; i++) {
                    window.BakeryCart.add(item.name, item.price, null, null);
                }
            });

            showToast('🛒 Giỏ hàng đã được nạp sản phẩm! Đang chuyển hướng...');

            setTimeout(() => {
                window.location.href = 'order.jsp';
            }, 1000);
        }

        /* Helper HTML empty state */
        function getEmptyStateHtml(title, desc, actionUrl, actionText) {
            const actionBtn = (actionUrl && actionText) ? `
                <a href="${actionUrl}" class="btn btn-primary" style="margin-top:var(--space-md)">${actionText}</a>` : '';
            return `
                <div class="empty-state-box">
                    <div class="empty-icon">🥖</div>
                    <h3 class="empty-title">${title}</h3>
                    <p class="empty-desc">${desc}</p>
                    ${actionBtn}
                </div>`;
        }

        /* Navigation & UI Boilerplate */
        function setupHamburger() {
            const h = document.getElementById('hamburger-btn');
            const d = document.getElementById('mobile-drawer');
            const o = document.getElementById('drawer-overlay');
            const c = document.getElementById('drawer-close-btn');
            if (!h || !d) return;
            const open = () => { d.classList.add('open'); h.classList.add('open'); document.body.style.overflow='hidden'; };
            const close = () => { d.classList.remove('open'); h.classList.remove('open'); document.body.style.overflow=''; };
            h.addEventListener('click', () => d.classList.contains('open') ? close() : open());
            o?.addEventListener('click', close);
            c?.addEventListener('click', close);
        }

        function setupBackToTop() {
            const btn = document.getElementById('back-to-top');
            if (btn) window.addEventListener('scroll', () => btn.classList.toggle('visible', window.scrollY > 400), { passive: true });
        }

        let trackToastTimer;
        function showToast(msg, type='success') {
            const t = document.getElementById('toast');
            if (!t) return;
            t.textContent = msg;
            t.className = 'toast show';
            if (type === 'warn') t.style.background = '#B45309';
            else if (type === 'info') t.style.background = '#3B82F6';
            else t.style.background = '#92400E';
            clearTimeout(trackToastTimer);
            trackToastTimer = setTimeout(() => { t.className = 'toast'; }, 2500);
        }
    </script>
</body>
</html>
