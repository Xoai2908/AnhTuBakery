<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0
    response.setDateHeader("Expires", 0); // Proxies

    com.mycompany.bakery.business.User loggedUser = (com.mycompany.bakery.business.User) session.getAttribute("user");
    if (loggedUser == null) {
        response.sendRedirect("admin_login.jsp?required=1&redirect=wholesale.jsp");
        return;
    }

    com.mycompany.bakery.business.Agent currentAgent = null;
    com.mycompany.bakery.data.AgentDAO agentDAO = new com.mycompany.bakery.data.AgentDAO();
    
    // Check if the logged user's phone or username matches an active agent
    String userPhone = loggedUser.getPhone();
    if (userPhone == null || userPhone.trim().isEmpty()) {
        userPhone = loggedUser.getUsername();
    }
    
    if (userPhone != null && !userPhone.trim().isEmpty()) {
        currentAgent = agentDAO.getAgentByPhone(userPhone);
        if (currentAgent != null && "ACTIVE".equals(currentAgent.getStatus())) {
            // Auto-promote session to AGENT if it was CUSTOMER
            if (!"AGENT".equals(loggedUser.getRole())) {
                loggedUser.setRole("AGENT");
                loggedUser.setFullname(currentAgent.getShopName() + " (" + currentAgent.getName() + ")");
                loggedUser.setUsername(currentAgent.getPhone());
                session.setAttribute("user", loggedUser);
            }
        } else {
            currentAgent = null; // Only treat as active agent
        }
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mua Sỉ Đại Lý – Bánh Mì Anh Tú</title>
    <meta name="description" content="Đăng ký đại lý và đặt mì ổ sỉ với giá bậc thang ưu đãi. Giao miễn phí trong 5km tại thành phố Huế.">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Pacifico&family=Nunito:ital,wght@0,300;0,400;0,600;0,700;0,800;0,900;1,400&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/style.css">
    <link rel="stylesheet" href="../css/order.css">
    <style>
        .wholesale-page { padding: var(--space-2xl) 0 var(--space-3xl); }
        .ws-grid { display: grid; grid-template-columns: 1fr 1fr; gap: var(--space-2xl); margin-bottom: var(--space-2xl); }
        @media(max-width:767px){ .ws-grid{ grid-template-columns: 1fr; } }

        .ws-section {
            background: var(--white);
            border-radius: var(--radius-lg);
            padding: var(--space-xl);
            border: 1.5px solid var(--amber);
            box-shadow: var(--shadow-card);
        }
        .ws-section-title {
            font-family: var(--font-display);
            font-size: 1.5rem;
            color: var(--brown-deep);
            margin-bottom: var(--space-lg);
            padding-bottom: var(--space-md);
            border-bottom: 2px dashed var(--amber);
            display: flex;
            align-items: center;
            gap: var(--space-sm);
        }

        /* Price Calculator */
        .price-calc { display: flex; flex-direction: column; gap: var(--space-md); }
        .qty-input-wrap { display: flex; align-items: center; gap: var(--space-md); }
        .qty-input {
            flex: 1;
            padding: 0.75rem 1rem;
            border: 2px solid var(--amber);
            border-radius: var(--radius-md);
            font-size: 1.2rem;
            font-weight: 800;
            color: var(--brown-deep);
            text-align: center;
            font-family: var(--font-body);
            min-height: 52px;
        }
        .qty-input:focus { outline: none; border-color: var(--red-dark); box-shadow: 0 0 0 3px rgba(185,28,28,0.1); }
        .qty-label { font-weight: 700; color: var(--brown-bark); font-size: 0.95rem; }

        .price-preview {
            background: linear-gradient(135deg, var(--cream-dark), var(--cream));
            border-radius: var(--radius-md);
            padding: var(--space-lg);
            border: 2px solid var(--amber);
            display: flex;
            flex-direction: column;
            gap: var(--space-sm);
            min-height: 140px;
            transition: all var(--transition);
        }
        .price-preview.error-state { border-color: var(--red-dark); background: var(--red-err-bg); }

        .preview-row { display: flex; justify-content: space-between; align-items: center; font-size: 0.9rem; }
        .preview-label { color: var(--gray-mid); font-weight: 600; }
        .preview-val { font-weight: 800; color: var(--brown-deep); }
        .preview-val.big { font-size: 1.4rem; color: var(--red-dark); }
        .preview-val.free { color: var(--green-ok); }

        .hint-box {
            background: var(--cream-dark);
            border-radius: var(--radius-sm);
            padding: var(--space-sm) var(--space-md);
            border-left: 4px solid var(--amber);
            font-size: 0.85rem;
            font-weight: 700;
            color: var(--amber-darker);
            display: flex;
            align-items: center;
            gap: var(--space-sm);
        }

        .price-table { width: 100%; border-collapse: collapse; font-size: 0.9rem; }
        .price-table th { background: var(--amber); color: var(--brown-bark); padding: 0.6rem 1rem; text-align: left; font-weight: 800; }
        .price-table td { padding: 0.6rem 1rem; border-bottom: 1px solid var(--cream-dark); font-weight: 600; color: var(--brown-deep); }
        .price-table tr:hover td { background: var(--cream-dark); }
        .price-table .highlight-row td { background: rgba(245,158,11,0.1); font-weight: 800; }
        .price-badge { padding: 0.2rem 0.6rem; border-radius: var(--radius-full); font-size: 0.75rem; font-weight: 800; }
        .price-badge.best { background: var(--amber); color: var(--brown-bark); }

        /* Registration Form */
        .reg-form { display: flex; flex-direction: column; gap: var(--space-md); }
        .reg-form .form-group { display: flex; flex-direction: column; gap: var(--space-xs); }
        .reg-form .form-label { font-weight: 700; color: var(--brown-deep); font-size: 0.9rem; }
        .req { color: var(--red-dark); }
        .reg-form .form-input {
            padding: 0.7rem 1rem;
            border: 2px solid var(--cream-dark);
            border-radius: var(--radius-md);
            font-family: var(--font-body);
            font-size: 1rem;
            color: var(--brown-deep);
            transition: border-color var(--transition);
            min-height: 44px;
        }
        .reg-form .form-input:focus { outline: none; border-color: var(--red-dark); box-shadow: 0 0 0 3px rgba(185,28,28,0.1); }
        .reg-form .form-input.error { border-color: var(--red-dark); }
        .form-error { color: var(--red-dark); font-size: 0.8rem; font-weight: 700; }
        .reg-form .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: var(--space-md); }
        @media(max-width:600px){ .reg-form .form-row { grid-template-columns: 1fr; } }
        .reg-submit-btn { align-self: flex-start; }

        /* Login form */
        .ws-login-box {
            background: var(--cream-dark);
            border-radius: var(--radius-md);
            padding: var(--space-lg);
            border: 1.5px solid var(--amber);
            display: flex;
            flex-direction: column;
            gap: var(--space-md);
        }
        .ws-login-title { font-weight: 800; color: var(--brown-deep); font-size: 1rem; }
        .ws-login-form { display: flex; flex-direction: column; gap: var(--space-sm); }
        .ws-login-form .form-input { min-height: 44px; }
        .order-section { background: var(--white); border-radius: var(--radius-lg); padding: var(--space-xl); border: 1.5px solid var(--amber); box-shadow: var(--shadow-card); }
        .order-section-title { font-family: var(--font-display); font-size: 1.5rem; color: var(--brown-deep); margin-bottom: var(--space-lg); }

        /* Status badges */
        .status-badge { padding: 0.2rem 0.6rem; border-radius: var(--radius-full); font-size: 0.75rem; font-weight: 800; }
        .status-pending { background: #FEF3C7; color: #92400E; }
        .status-active { background: var(--green-bg); color: var(--green-ok); }
        .status-suspended { background: var(--red-err-bg); color: var(--red-err-text); }

        .ws-alert {
            padding: var(--space-md);
            border-radius: var(--radius-md);
            font-weight: 600;
            font-size: 0.9rem;
            display: flex;
            align-items: flex-start;
            gap: var(--space-sm);
            line-height: 1.6;
        }
        .ws-alert.info { background: var(--cream-dark); color: var(--brown-deep); border-left: 3px solid var(--amber); }
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
                <a href="wholesale.jsp" class="nav-link active">Mua sỉ</a>
                <a href="track.jsp" class="nav-link">Tình trạng đơn</a>
                <% if (loggedUser != null) { %>
                    <% if ("ADMIN".equals(loggedUser.getRole())) { %>
                        <a href="admin_dashboard.jsp" class="nav-link" style="color:var(--yellow-light) !important;font-weight:800;">Trang quản trị</a>
                    <% } %>
                    <a href="profile.jsp" class="nav-link">Trang cá nhân</a>
                    <a href="../auth/logout" class="nav-link" style="color:var(--yellow-light) !important;font-weight:800;">Đăng xuất</a>
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
                <% } %>
            </nav>
        </div>
    </header>

    <div class="page-hero" id="page-hero">
        <div class="container page-hero-inner">
            <h1 class="page-hero-title">📦 Mua Sỉ Đại Lý</h1>
            <p class="page-hero-sub">Giá bậc thang ưu đãi — Giao miễn phí trong 5km</p>
        </div>
    </div>

    <main class="wholesale-page">
        <div class="container">

            <!-- PRICE CALCULATOR + TABLE -->
            <div class="ws-grid">
                <div class="ws-section" id="ws-calc">
                    <h2 class="ws-section-title">💰 Tính giá nhanh</h2>
                    <div class="price-calc">
                        <div class="form-group">
                            <label class="form-label" for="ws-qty">Số lượng mì ổ cần lấy</label>
                            <div class="qty-input-wrap">
                                <input type="number" id="ws-qty" class="qty-input" placeholder="Nhập số lượng" min="0" oninput="calcWholesalePrice()" autocomplete="off">
                                <span class="qty-label">ổ</span>
                            </div>
                        </div>
                        <div class="price-preview" id="price-preview">
                            <div id="preview-content">
                                <p style="color:var(--gray-mid);font-weight:600;text-align:center;padding:var(--space-lg)">Nhập số lượng để xem giá ⬆</p>
                            </div>
                        </div>
                        <div class="hint-box hidden" id="upgrade-hint"></div>
                    </div>
                </div>
                <div class="ws-section" id="ws-price-table">
                    <h2 class="ws-section-title">📊 Bảng giá sỉ</h2>
                    <table class="price-table" id="price-table">
                        <thead>
                            <tr>
                                <th>Số lượng</th>
                                <th>Đơn giá</th>
                                <th>Ghi chú</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>Dưới 50 ổ</td>
                                <td>—</td>
                                <td><span style="color:var(--red-dark);font-weight:700">Không áp dụng sỉ</span></td>
                            </tr>
                            <tr>
                                <td>50 – 199 ổ</td>
                                <td><strong>1.500đ/ổ</strong></td>
                                <td>Giá tiêu chuẩn</td>
                            </tr>
                            <tr class="highlight-row">
                                <td>≥ 200 ổ</td>
                                <td><strong style="color:var(--red-dark)">1.300đ/ổ</strong></td>
                                <td><span class="price-badge best">Giá tốt nhất</span></td>
                            </tr>
                        </tbody>
                    </table>
                    <div class="ws-alert info" style="margin-top:var(--space-lg)">
                        <span>🚚</span>
                        <div>
                            <strong>Giao hàng miễn phí</strong> cho tất cả đơn sỉ trong bán kính <strong>5km</strong> từ lò bánh.<br>
                            Đơn nằm ngoài 5km: vui lòng liên hệ <a href="tel:0779409567" style="color:var(--red-dark)">0779 409 567</a>
                        </div>
                    </div>
                </div>
            </div>

            <!-- REGISTRATION & LOGIN -->
            <% if (currentAgent != null) { %>
            <div class="ws-grid" id="order">
                <div class="ws-section" id="ws-agent-info">
                    <h2 class="ws-section-title">👤 Thông tin Đại lý</h2>
                    <div style="display:flex;flex-direction:column;gap:var(--space-md)">
                        <div class="ws-alert info" style="font-size: 0.95rem; line-height: 1.8;">
                            <div>
                                <span style="font-size: 1.2rem; margin-right: 4px;">🏪</span> <strong>Tên đại lý:</strong> <%= currentAgent.getShopName() %><br>
                                👤 <strong>Người đại diện:</strong> <%= currentAgent.getName() %><br>
                                📞 <strong>Số điện thoại:</strong> <%= currentAgent.getPhone() %><br>
                                📍 <strong>Địa chỉ giao hàng:</strong> <%= currentAgent.getAddress() %><br>
                                🚚 <strong>Vùng phục vụ:</strong> Trong phạm vi 5km (Giao hàng miễn phí)
                            </div>
                        </div>
                    </div>
                </div>

                <div style="display:flex;flex-direction:column;gap:var(--space-lg)">
                    <!-- Quick Order Panel -->
                    <div class="ws-section" id="ws-order-panel">
                        <h2 class="ws-section-title">🛒 Đặt đơn hàng sỉ</h2>
                        <div style="display:flex;flex-direction:column;gap:var(--space-md)">
                            <p style="font-size:0.95rem;color:var(--brown-deep);font-weight:600;">Hệ thống sẽ tạo đơn hàng tự động dựa trên số lượng mì ổ bạn nhập ở mục "Tính giá nhanh" phía trên.</p>
                            <div class="form-group" style="display: flex; flex-direction: column; gap: var(--space-xs);">
                                <label class="form-label" for="ws-order-note">Ghi chú đơn hàng (Không bắt buộc)</label>
                                <textarea id="ws-order-note" class="form-input" placeholder="Ví dụ: Giao trước 7h sáng, mì giòn..." rows="3" style="resize:vertical;font-family:inherit;padding:0.75rem 1rem;border:2px solid var(--cream-dark);border-radius:var(--radius-md);width:100%;box-sizing:border-box;"></textarea>
                            </div>
                            <button type="button" class="btn btn-primary" style="width:100%; font-size:1.1rem; font-weight:800; padding:12px;" onclick="placeAgentWholesaleOrder()">✅ Tiến hành đặt hàng →</button>
                        </div>
                    </div>

                    <!-- Info box -->
                    <div class="ws-section">
                        <h2 class="ws-section-title">ℹ️ Lưu ý quan trọng</h2>
                        <div style="display:flex;flex-direction:column;gap:var(--space-sm)">
                            <div class="ws-alert info"><span>📦</span><div>Đặt sỉ tối thiểu <strong>50 ổ/đơn</strong>. Đơn dưới 50 ổ sẽ không được xử lý.</div></div>
                            <div class="ws-alert info"><span>🚚</span><div>Giao trong <strong>bán kính 5km</strong> từ lò bánh. Kiểm tra vị trí trước khi đăng ký.</div></div>
                        </div>
                    </div>
                </div>
            </div>
            <% } else { %>
            <div class="ws-grid" id="order">
                <div class="ws-section" id="ws-register">
                    <h2 class="ws-section-title">📝 Đăng ký đại lý mới</h2>
                    <form class="reg-form" id="reg-form" novalidate onsubmit="submitRegistration(event)">
                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label" for="reg-name">Họ tên đại diện <span class="req">*</span></label>
                                <input type="text" id="reg-name" class="form-input" placeholder="Nguyễn Văn A" required maxlength="100">
                            </div>
                            <div class="form-group">
                                <label class="form-label" for="reg-phone">Số điện thoại <span class="req">*</span></label>
                                <input type="tel" id="reg-phone" class="form-input" placeholder="0912 345 678" required maxlength="10" inputmode="numeric">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="reg-shop">Tên cửa hàng / đại lý <span class="req">*</span></label>
                            <input type="text" id="reg-shop" class="form-input" placeholder="Cửa hàng Thành Đạt" required maxlength="150">
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="reg-address">Địa chỉ giao hàng <span class="req">*</span></label>
                            <input type="text" id="reg-address" class="form-input" placeholder="123 Đường ABC, Phường X, thành phố Huế" required>
                            <input type="hidden" id="reg-lat" required>
                            <input type="hidden" id="reg-lng" required>
                            <!-- Geocode status -->
                            <div class="geocode-status hidden" id="geocode-status">
                                <span class="geocode-status-icon" id="geocode-status-icon"></span>
                                <span class="geocode-status-text" id="geocode-status-text"></span>
                            </div>
                        </div>
                        <div class="form-row">
                            <div class="form-group">
                                <label class="form-label" for="reg-password">Mật khẩu <span class="req">*</span></label>
                                <input type="password" id="reg-password" class="form-input" placeholder="Tối thiểu 6 ký tự" required minlength="6">
                            </div>
                            <div class="form-group">
                                <label class="form-label" for="reg-confirm">Xác nhận mật khẩu <span class="req">*</span></label>
                                <input type="password" id="reg-confirm" class="form-input" placeholder="Nhập lại mật khẩu" required>
                            </div>
                        </div>
                        <p id="reg-error" class="form-error hidden"></p>
                        <button type="submit" class="btn btn-primary reg-submit-btn" id="btn-reg-submit">Gửi đơn đăng ký →</button>
                    </form>
                </div>

                <div style="display:flex;flex-direction:column;gap:var(--space-lg)">
                    <!-- Login box -->
                    <div class="ws-section" id="ws-login">
                        <h2 class="ws-section-title">🔑 Đại lý đã có tài khoản</h2>
                        <form class="ws-login-form" id="ws-login-form" novalidate onsubmit="submitLogin(event)">
                            <div class="form-group">
                                <label class="form-label" for="login-phone">Số điện thoại</label>
                                <input type="tel" id="login-phone" class="form-input" placeholder="0912 345 678" maxlength="10" inputmode="numeric">
                            </div>
                            <div class="form-group">
                                <label class="form-label" for="login-password">Mật khẩu</label>
                                <input type="password" id="login-password" class="form-input" placeholder="Mật khẩu">
                            </div>
                            <p id="login-error" class="form-error hidden"></p>
                            <button type="submit" class="btn btn-amber" id="btn-login">Đăng nhập →</button>
                        </form>
                    </div>

                    <!-- Info box -->
                    <div class="ws-section">
                        <h2 class="ws-section-title">ℹ️ Lưu ý quan trọng</h2>
                        <div style="display:flex;flex-direction:column;gap:var(--space-sm)">
                            <div class="ws-alert info"><span>⏳</span><div>Sau khi đăng ký, Admin sẽ xác nhận và <strong>kích hoạt tài khoản</strong> qua điện thoại trong vòng 24h.</div></div>
                            <div class="ws-alert info"><span>📦</span><div>Đặt sỉ tối thiểu <strong>50 ổ/đơn</strong>. Đơn dưới 50 ổ sẽ không được xử lý.</div></div>
                            <div class="ws-alert info"><span>🚚</span><div>Giao trong <strong>bán kính 5km</strong> từ lò bánh. Kiểm tra vị trí trước khi đăng ký.</div></div>
                        </div>
                    </div>
                </div>
            </div>
            <% } %>

            <!-- SUCCESS / PENDING message -->
            <div class="hidden" id="reg-success-box" style="text-align:center;padding:var(--space-3xl)">
                <div style="font-size:4rem;margin-bottom:var(--space-md)">✅</div>
                <h2 style="font-family:var(--font-display);font-size:2rem;color:var(--green-ok);margin-bottom:var(--space-md)">Đăng ký thành công!</h2>
                <p style="color:var(--brown-deep);font-weight:600;margin-bottom:var(--space-sm)">Thông tin đã được ghi nhận. Admin sẽ liên hệ xác nhận qua <strong>0779 409 567</strong></p>
                <p style="color:var(--gray-mid);font-size:0.9rem">Sau khi tài khoản được kích hoạt, bạn có thể đăng nhập và bắt đầu đặt đơn sỉ.</p>
            </div>

            <!-- SUCCESS STATE FOR AGENT ORDER -->
            <div class="success-panel hidden" id="success-panel">
                <div class="container">
                    <div class="success-box" style="border: 2.5px solid var(--green-ok); box-shadow: 0 20px 45px rgba(5, 150, 105, 0.12), var(--shadow-card); background: linear-gradient(135deg, var(--white) 0%, var(--cream) 100%); border-radius: var(--radius-xl); padding: var(--space-3xl); text-align: center; max-width: 540px; margin: 0 auto;">
                        <div class="success-icon" style="font-size: 3rem; margin-bottom: var(--space-md);">🎉</div>
                        <h2 class="success-title" style="font-family: var(--font-display); font-size: 2rem; color: var(--green-ok); margin-bottom: var(--space-md);">Đặt hàng sỉ thành công!</h2>
                        <p class="success-msg" style="color: var(--brown-deep); font-weight: 600; margin-bottom: var(--space-sm);">Cảm ơn đại lý đã hợp tác cùng Bánh Mì Anh Tú!</p>
                        <div class="success-order-id" style="background: var(--cream-dark); padding: var(--space-sm) var(--space-md); border-radius: var(--radius-md); display: inline-block; font-size: 1.1rem; color: var(--brown-bark); margin-bottom: var(--space-md); font-weight: 700;">
                            Mã đơn hàng sỉ: <strong id="order-id-display" style="color: var(--red-dark);">DH000000</strong>
                        </div>
                        <p class="success-sub" style="color: var(--gray-mid); font-size: 0.9rem; margin-bottom: var(--space-lg); line-height: 1.6;">Đơn sỉ đã được ghi nhận tự động và chuyển sang bộ phận chuẩn bị. Giao hàng miễn phí trong bán kính 5km.</p>
                        <div class="success-actions" style="display: flex; gap: var(--space-md); justify-content: center;">
                            <a href="track.jsp" class="btn btn-primary btn-lg" style="font-weight: 800;">📋 Tình trạng đơn hàng</a>
                            <a href="index.jsp" class="btn btn-outline btn-lg" style="font-weight: 800;">← Về trang chủ</a>
                        </div>
                    </div>
                </div>
            </div>

            <!-- ===== CONFIRMATION & PAYMENT MODAL ===== -->
            <div class="modal-overlay hidden" id="confirm-modal-overlay">
                <div class="confirm-modal" id="confirm-modal" role="dialog" aria-modal="true" aria-label="Xác nhận đơn hàng sỉ">
                    <style>
                        @keyframes modal-spin {
                            0% { transform: rotate(0deg); }
                            100% { transform: rotate(360deg); }
                        }
                        .modal-spinner {
                            border: 2px solid var(--cream-dark);
                            border-top: 2px solid var(--amber);
                            border-radius: 50%;
                            width: 18px;
                            height: 18px;
                            animation: modal-spin 1.2s linear infinite;
                        }
                        .hidden-state {
                            display: none !important;
                        }
                    </style>
                    <div class="modal-header">
                        <h2 class="modal-title" id="modal-title">✅ Xác Nhận Đơn Hàng Sỉ</h2>
                        <button class="modal-close-btn" id="modal-close-btn" onclick="closeConfirmModal()">✕</button>
                    </div>
                    <div class="modal-body">
                        <!-- State 1: Confirm Details -->
                        <div id="modal-state-confirm">
                            <div class="modal-summary" id="modal-summary">
                                <!-- Populated by JS -->
                            </div>
                        </div>

                        <!-- State 2: Payment/QR (Hidden initially) -->
                        <div id="modal-state-payment" class="hidden-state">
                            <div class="qr-section">
                                <h3 class="qr-title" style="font-family: var(--font-display); font-size: 1.1rem; color: var(--brown-deep); margin-bottom: var(--space-md);">📱 Thanh toán chuyển khoản sỉ</h3>
                                <div class="qr-display" style="display: flex; justify-content: center; margin-bottom: var(--space-md);">
                                    <img id="qr-image" src="" alt="Mã QR Thanh Toán" style="max-width: 230px; border: 2.5px solid var(--amber); border-radius: var(--radius-lg); box-shadow: var(--shadow-card);" />
                                </div>
                                <div class="qr-info" style="background: var(--cream); border-radius: var(--radius-md); padding: var(--space-md); border: 1px solid var(--amber);">
                                    <div class="qr-info-row" style="display: flex; justify-content: space-between; align-items: center; padding: var(--space-sm) 0; border-bottom: 1px dashed var(--cream-dark); font-size: 0.9rem;">
                                        <span style="color: var(--gray-mid); font-weight: 500;">Ngân hàng:</span>
                                        <strong>BIDV (PGD An Cựu)</strong>
                                    </div>
                                    <div class="qr-info-row" style="display: flex; justify-content: space-between; align-items: center; padding: var(--space-sm) 0; border-bottom: 1px dashed var(--cream-dark); font-size: 0.9rem;">
                                        <span style="color: var(--gray-mid); font-weight: 500;">Chủ tài khoản:</span>
                                        <strong>HO KINH DOANH VO VAN TRU</strong>
                                    </div>
                                    <div class="qr-info-row" style="display: flex; justify-content: space-between; align-items: center; padding: var(--space-sm) 0; border-bottom: 1px dashed var(--cream-dark); font-size: 0.9rem;">
                                        <span style="color: var(--gray-mid); font-weight: 500;">Số tài khoản:</span>
                                        <strong>8888824977</strong>
                                    </div>
                                    <div class="qr-info-row" style="display: flex; justify-content: space-between; align-items: center; padding: var(--space-sm) 0; border-bottom: 1px dashed var(--cream-dark); font-size: 0.9rem;">
                                        <span style="color: var(--gray-mid); font-weight: 500;">Số tiền:</span>
                                        <strong id="qr-amount" class="qr-amount" style="color: var(--red-dark); font-size: 1.2rem;">0đ</strong>
                                    </div>
                                    <div class="qr-info-row" style="display: flex; justify-content: space-between; align-items: center; padding: var(--space-sm) 0; border-bottom: none; font-size: 0.9rem;">
                                        <span style="color: var(--gray-mid); font-weight: 500;">Nội dung CK:</span>
                                        <strong id="qr-content">ANHTUBAKERY DHMOI</strong>
                                    </div>
                                    
                                    <div style="display:flex; justify-content:center; align-items:center; gap: 8px; margin-top: 15px; padding: 12px; background: rgba(245,158,11,0.08); border-radius: 8px; border: 1.5px solid rgba(245,158,11,0.15);">
                                        <div class="modal-spinner"></div>
                                        <span style="font-size:0.85rem; font-weight:800; color:var(--brown-deep);">Đang chờ thanh toán tự động...</span>
                                    </div>
                                    
                                    <p class="qr-note-text" style="margin-top: 12px; font-size: 0.82rem; color: var(--gray-mid); font-weight: 500; line-height: 1.5; font-style: italic;">Vui lòng chuyển khoản đúng số tiền và nội dung chuyển khoản ở trên. Giao dịch sẽ được hệ thống kiểm tra và tự động xác nhận ngay lập tức.</p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer" id="modal-footer" style="display: flex; gap: var(--space-md); padding: var(--space-lg); border-top: 1px solid var(--cream-dark);">
                        <button class="btn btn-outline" style="flex: 1; justify-content: center;" onclick="closeConfirmModal()">← Hủy</button>
                        <button class="btn btn-primary" id="btn-place-order" style="flex: 1; justify-content: center; font-weight: 800;" onclick="placeOrder()">✅ Xác nhận & Đặt hàng sỉ</button>
                    </div>
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
                <h5 class="footer-heading">Liên hệ</h5>
                <p class="footer-contact-info"><span>📞</span> <a href="tel:0779409567">0779 409 567</a></p>
            </div>
        </div>
        <div class="footer-bottom"><p>© 2025 Bánh Mì Anh Tú.</p></div>
    </footer>

    <div class="toast" id="toast" role="alert"></div>
    <script>
        const agentName = <%= currentAgent != null ? "'" + currentAgent.getName().replace("'", "\\'") + "'" : "''" %>;
        const agentPhone = <%= currentAgent != null ? "'" + currentAgent.getPhone().replace("'", "\\'") + "'" : "''" %>;
        const agentShopName = <%= currentAgent != null ? "'" + currentAgent.getShopName().replace("'", "\\'") + "'" : "''" %>;
        const agentAddress = <%= currentAgent != null ? "'" + currentAgent.getAddress().replace("'", "\\'") + "'" : "''" %>;
        const agentLat = <%= currentAgent != null ? currentAgent.getLatitude() : "null" %>;
        const agentLng = <%= currentAgent != null ? currentAgent.getLongitude() : "null" %>;

        /* Wholesale price calculator */
        const BAKERY_LAT = 16.447500, BAKERY_LNG = 107.596100;

        function calcWholesalePrice() {
            const qty = parseInt(document.getElementById('ws-qty').value) || 0;
            const preview = document.getElementById('price-preview');
            const hint = document.getElementById('upgrade-hint');

            if (qty <= 0) {
                preview.innerHTML = '<p style="color:var(--gray-mid);font-weight:600;text-align:center;padding:var(--space-lg)">Nhập số lượng để xem giá ⬆</p>';
                preview.className = 'price-preview';
                hint.classList.add('hidden');
                return;
            }
            if (qty < 50) {
                preview.className = 'price-preview error-state';
                preview.innerHTML = `
                    <div style="text-align:center;padding:var(--space-md)">
                        <div style="font-size:2rem;margin-bottom:var(--space-sm)">🚫</div>
                        <strong style="color:var(--red-dark)">Đặt sỉ tối thiểu 50 ổ</strong>
                        <p style="font-size:0.85rem;color:var(--gray-mid);margin-top:4px">Đặt lẻ tại: <a href="order.jsp" style="color:var(--red-dark)">Trang đặt lẻ</a></p>
                    </div>`;
                hint.classList.add('hidden');
                return;
            }

            preview.className = 'price-preview';
            let unitPrice, tier;
            if (qty <= 199) { unitPrice = 1500; tier = '50–199 ổ'; }
            else { unitPrice = 1300; tier = '≥ 200 ổ'; }

            const total = qty * unitPrice;

            preview.innerHTML = `
                <div class="preview-row"><span class="preview-label">Số lượng</span><span class="preview-val">${qty.toLocaleString('vi-VN')} ổ</span></div>
                <div class="preview-row"><span class="preview-label">Bậc giá</span><span class="preview-val">${tier}</span></div>
                <div class="preview-row"><span class="preview-label">Đơn giá</span><span class="preview-val">${unitPrice.toLocaleString('vi-VN')}đ/ổ</span></div>
                <div class="preview-row" style="border-top:1px dashed var(--amber);padding-top:8px;margin-top:4px">
                    <span class="preview-label" style="font-weight:800">THÀNH TIỀN</span>
                    <span class="preview-val big">${total.toLocaleString('vi-VN')}đ</span>
                </div>
                <div class="preview-row"><span class="preview-label">Phí giao hàng</span><span class="preview-val free">🚚 Miễn phí</span></div>`;

            // Hint to upgrade tier
            if (qty >= 50 && qty < 200) {
                const needed = 200 - qty;
                const saving = qty * 1500 - qty * 1300;
                hint.classList.remove('hidden');
                hint.innerHTML = `💡 Đặt thêm <strong>${needed} ổ</strong> → giá <strong>1.300đ/ổ</strong>, tiết kiệm được <strong>${saving.toLocaleString('vi-VN')}đ</strong>!`;
            } else {
                hint.classList.add('hidden');
            }
        }

        // Auto Geocode for Wholesale Register Address
        let geocodeTimer;
        let lastGeocodedAddress = '';

        function initAddressAutoGeocode() {
            const addressInput = document.getElementById('reg-address');
            if (!addressInput) return;

            function onAddressChange() {
                clearTimeout(geocodeTimer);
                const address = addressInput.value.trim();

                // Reset if address cleared or too short
                if (address.length < 5) {
                    resetGeocodeState();
                    return;
                }

                // Debounce 600ms
                geocodeTimer = setTimeout(() => geocodeFromAddress(address), 600);
            }

            addressInput.addEventListener('input', onAddressChange);
            addressInput.addEventListener('change', onAddressChange);
            addressInput.addEventListener('blur', () => {
                const address = addressInput.value.trim();
                if (address.length >= 5 && address !== lastGeocodedAddress) {
                    clearTimeout(geocodeTimer);
                    geocodeFromAddress(address);
                }
            });
        }

        function resetGeocodeState() {
            document.getElementById('reg-lat').value = '';
            document.getElementById('reg-lng').value = '';
            const statusEl = document.getElementById('geocode-status');
            if (statusEl) statusEl.classList.add('hidden');
            lastGeocodedAddress = '';
        }

        function geocodeFromAddress(address) {
            if (address === lastGeocodedAddress) return;

            const statusEl = document.getElementById('geocode-status');
            const statusIcon = document.getElementById('geocode-status-icon');
            const statusText = document.getElementById('geocode-status-text');

            if (statusEl) {
                statusEl.classList.remove('hidden', 'geocode-success', 'geocode-error');
                statusEl.classList.add('geocode-loading');
                statusIcon.textContent = '⏳';
                statusText.textContent = 'Đang tra cứu vị trí...';
            }

            const searchQuery = address.includes('Huế') || address.includes('Hue')
                ? address + ', Việt Nam'
                : address + ', Thừa Thiên Huế, Việt Nam';

            var urlParts = [];
            urlParts.push('https://nominatim.openstreetmap.org/search');
            urlParts.push('?q=');
            urlParts.push(encodeURIComponent(searchQuery));
            urlParts.push(String.fromCharCode(38) + 'format=json');
            urlParts.push(String.fromCharCode(38) + 'limit=1');
            urlParts.push(String.fromCharCode(38) + 'addressdetails=1');
            urlParts.push(String.fromCharCode(38) + 'countrycodes=vn');
            const url = urlParts.join('');

            fetch(url, { headers: { 'Accept-Language': 'vi' } })
            .then(res => {
                if (!res.ok) throw new Error('Network error');
                return res.json();
            })
            .then(data => {
                if (data && data.length > 0) {
                    const result = data[0];
                    const lat = parseFloat(result.lat).toFixed(6);
                    const lng = parseFloat(result.lon).toFixed(6);

                    // Check if returned result is generic (district, city, province boundary)
                    const isGeneric = ['country', 'state', 'county', 'district', 'municipality', 'city', 'province', 'region'].includes(result.addresstype) || 
                                      result.type === 'administrative';

                    if (isGeneric) {
                        resetGeocodeState();
                        if (statusEl) {
                            statusEl.classList.remove('hidden', 'geocode-loading', 'geocode-success');
                            statusEl.classList.add('geocode-error');
                            statusIcon.textContent = '⚠️';
                            statusText.innerHTML = '<strong>' + result.display_name + '</strong><br><span style="color:var(--red-dark); font-weight:700;">Địa chỉ quá chung chung. Vui lòng nhập cụ thể số nhà, tên đường, thôn/xóm...</span>';
                        }
                        return;
                    }

                    document.getElementById('reg-lat').value = lat;
                    document.getElementById('reg-lng').value = lng;
                    lastGeocodedAddress = address;

                    if (statusEl) {
                        statusEl.classList.remove('geocode-loading', 'geocode-error');
                        statusEl.classList.add('geocode-success');
                        statusIcon.textContent = '✅';
                        statusText.innerHTML = '<strong>' + result.display_name + '</strong>';
                    }
                } else {
                    resetGeocodeState();
                    if (statusEl) {
                        statusEl.classList.remove('hidden', 'geocode-loading', 'geocode-success');
                        statusEl.classList.add('geocode-error');
                        statusIcon.textContent = '❌';
                        statusText.textContent = 'Không tìm thấy địa chỉ. Vui lòng nhập chi tiết hơn.';
                    }
                }
            })
            .catch(err => {
                console.error(err);
                if (statusEl) {
                    statusEl.classList.remove('hidden', 'geocode-loading', 'geocode-success');
                    statusEl.classList.add('geocode-error');
                    statusIcon.textContent = '⚠️';
                    statusText.textContent = 'Lỗi kết nối. Không thể định vị vị trí.';
                }
            });
        }

        function submitRegistration(e) {
            e.preventDefault();
            const name = document.getElementById('reg-name').value.trim();
            const phone = document.getElementById('reg-phone').value.trim();
            const shopName = document.getElementById('reg-shop').value.trim();
            const address = document.getElementById('reg-address').value.trim();
            const latitude = parseFloat(document.getElementById('reg-lat').value);
            const longitude = parseFloat(document.getElementById('reg-lng').value);
            const password = document.getElementById('reg-password').value;
            const confirm = document.getElementById('reg-confirm').value;
            const errEl = document.getElementById('reg-error');

            if (!name || !phone || !shopName || !address || isNaN(latitude) || isNaN(longitude) || !password || !confirm) {
                errEl.textContent = '⚠️ Vui lòng điền đầy đủ thông tin bắt buộc.';
                errEl.classList.remove('hidden'); return;
            }
            if (!/^\d{10}$/.test(phone)) {
                errEl.textContent = '⚠️ Số điện thoại phải đúng 10 chữ số.';
                errEl.classList.remove('hidden'); return;
            }
            if (password.length < 6) {
                errEl.textContent = '⚠️ Mật khẩu tối thiểu 6 ký tự.';
                errEl.classList.remove('hidden'); return;
            }
            if (password !== confirm) {
                errEl.textContent = '⚠️ Mật khẩu xác nhận không khớp.';
                errEl.classList.remove('hidden'); return;
            }
            errEl.classList.add('hidden');

            const btn = document.getElementById('btn-reg-submit');
            btn.disabled = true; btn.textContent = '⏳ Đang gửi...';
            
            const payload = { name, phone, shopName, address, latitude, longitude, password };

            fetch('../resources/agents/register', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload)
            })
            .then(res => {
                if (!res.ok) return res.json().then(d => { throw new Error(d.error || 'Đăng ký thất bại'); });
                return res.json();
            })
            .then(data => {
                document.getElementById('reg-form').classList.add('hidden');
                document.getElementById('reg-success-box').classList.remove('hidden');
            })
            .catch(err => {
                btn.disabled = false; btn.textContent = 'Gửi đơn đăng ký →';
                errEl.textContent = '⚠️ ' + err.message;
                errEl.classList.remove('hidden');
            });
        }

        function submitLogin(e) {
            e.preventDefault();
            const phone = document.getElementById('login-phone').value.trim();
            const password = document.getElementById('login-password').value;
            const errEl = document.getElementById('login-error');
            if (!phone || !password) { errEl.textContent = '⚠️ Vui lòng nhập đủ thông tin.'; errEl.classList.remove('hidden'); return; }
            errEl.classList.add('hidden');
            
            const btn = document.getElementById('btn-login');
            btn.disabled = true; btn.textContent = '⏳ Đang đăng nhập...';
            
            const payload = { phone, password };

            fetch('../resources/agents/login', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload)
            })
            .then(res => {
                if (!res.ok) return res.json().then(d => { throw new Error(d.error || 'Đăng nhập thất bại'); });
                return res.json();
            })
            .then(data => {
                showToast('✅ Đăng nhập thành công!');
                setTimeout(() => {
                    window.location.reload();
                }, 1000);
            })
            .catch(err => {
                btn.disabled = false; btn.textContent = 'Đăng nhập →';
                errEl.textContent = '⚠️ ' + err.message;
                errEl.classList.remove('hidden');
            });
        }

        // Hamburger
        document.addEventListener('DOMContentLoaded', () => {
            // Init auto geocoding
            initAddressAutoGeocode();

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
        });

        /* Agent wholesale order flow */
        let currentQty = 0;
        let currentTotalPrice = 0;
        let currentUnitPrice = 0;
        let activePaymentSocket = null;

        function placeAgentWholesaleOrder() {
            const qtyInput = document.getElementById('ws-qty');
            const qty = parseInt(qtyInput ? qtyInput.value : 0) || 0;
            if (qty < 50) {
                showToast('⚠️ Đặt sỉ tối thiểu 50 ổ. Vui lòng nhập số lượng hợp lệ.', 'warn');
                qtyInput?.focus();
                return;
            }
            openConfirmModal(qty);
        }

        function openConfirmModal(qty) {
            currentQty = qty;
            currentUnitPrice = qty <= 199 ? 1500 : 1300;
            currentTotalPrice = qty * currentUnitPrice;

            document.getElementById('modal-summary').innerHTML = `
                <div class="modal-info-row"><span class="modal-info-label">👤 Khách hàng (Đại lý)</span><span class="modal-info-val">${agentShopName} (${agentName})</span></div>
                <div class="modal-info-row"><span class="modal-info-label">📞 Điện thoại</span><span class="modal-info-val">${agentPhone}</span></div>
                <div class="modal-info-row"><span class="modal-info-label">📍 Địa chỉ giao hàng</span><span class="modal-info-val">${agentAddress}</span></div>
                <div class="modal-info-row"><span class="modal-info-label">🥖 Sản phẩm</span><span class="modal-info-val">Mì ổ không nhân (Sỉ)</span></div>
                <div class="modal-info-row"><span class="modal-info-label">🔢 Số lượng</span><span class="modal-info-val">${qty.toLocaleString('vi-VN')} ổ</span></div>
                <div class="modal-info-row"><span class="modal-info-label">💵 Đơn giá sỉ</span><span class="modal-info-val">${currentUnitPrice.toLocaleString('vi-VN')}đ/ổ</span></div>
                <div class="modal-info-row"><span class="modal-info-label">🚚 Phí ship</span><span class="modal-info-val">Miễn phí (sỉ trong 5km)</span></div>
                <div class="modal-info-row"><span class="modal-info-label" style="font-weight:800">TỔNG THANH TOÁN</span><span class="modal-info-val highlight" style="color:var(--red-dark); font-size:1.1rem">${currentTotalPrice.toLocaleString('vi-VN')}đ</span></div>
            `;

            // Reset modal state
            document.getElementById('modal-state-confirm')?.classList.remove('hidden-state');
            document.getElementById('modal-state-payment')?.classList.add('hidden-state');
            document.getElementById('modal-close-btn')?.classList.remove('hidden-state');
            document.getElementById('modal-footer')?.classList.remove('hidden-state');
            document.getElementById('modal-title').textContent = "✅ Xác Nhận Đơn Hàng Sỉ";

            const overlay = document.getElementById('confirm-modal-overlay');
            overlay?.classList.remove('hidden');
            document.body.style.overflow = 'hidden';
        }

        function closeConfirmModal() {
            document.getElementById('confirm-modal-overlay')?.classList.add('hidden');
            document.body.style.overflow = '';
        }

        function placeOrder() {
            const btn = document.getElementById('btn-place-order');
            if (btn) { btn.disabled = true; btn.textContent = '⏳ Đang xử lý...'; }

            const note = document.getElementById('ws-order-note')?.value.trim() || '';

            const orderData = {
                customerName: agentShopName + " (" + agentName + ")",
                customerPhone: agentPhone,
                deliveryMethod: "GIAO_HANG",
                deliveryAddress: agentAddress,
                pickupTime: "",
                note: note,
                latitude: agentLat,
                longitude: agentLng,
                subtotal: currentTotalPrice,
                shippingFee: 0,
                total: currentTotalPrice,
                items: [
                    {
                        name: "Mì ổ không nhân (Sỉ)",
                        qty: currentQty,
                        price: currentUnitPrice
                    }
                ]
            };

            fetch('../resources/orders', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(orderData)
            })
            .then(response => {
                if (!response.ok) {
                    return response.text().then(text => { throw new Error(text || 'Đặt hàng thất bại'); });
                }
                return response.json();
            })
            .then(data => {
                const orderId = data.id;

                // QR payment content
                document.getElementById('qr-amount').textContent = currentTotalPrice.toLocaleString('vi-VN') + 'đ';
                const contentVal = `ANHTUBAKERY ${orderId}`;
                document.getElementById('qr-content').textContent = contentVal;

                // QR VietQR image URL
                const qrImageEl = document.getElementById('qr-image');
                if (qrImageEl) {
                    const qrUrl = 'https://img.vietqr.io/image/BIDV-8888824977-compact2.png'
                        + '?amount=' + currentTotalPrice
                        + '&addInfo=' + encodeURIComponent(contentVal)
                        + '&accountName=HO%20KINH%20DOANH%20VO%20VAN%20TRU';
                    qrImageEl.src = qrUrl;
                }

                // Switch Modal to state 2: QR Payment
                document.getElementById('modal-state-confirm')?.classList.add('hidden-state');
                document.getElementById('modal-state-payment')?.classList.remove('hidden-state');
                document.getElementById('modal-title').textContent = "📱 Quét Mã Thanh Toán";
                document.getElementById('modal-close-btn')?.classList.add('hidden-state');
                document.getElementById('modal-footer')?.classList.add('hidden-state');

                if (btn) { btn.disabled = false; btn.textContent = '✅ Xác nhận & Đặt hàng sỉ'; }

                // Connect WebSocket
                connectPaymentWebSocket(orderId);
            })
            .catch(error => {
                console.error('Error placing order:', error);
                showToast('⚠️ Lỗi: ' + error.message, 'warn');
                if (btn) { btn.disabled = false; btn.textContent = '✅ Xác nhận & Đặt hàng sỉ'; }
            });
        }

        function connectPaymentWebSocket(orderId) {
            if (activePaymentSocket) {
                try { activePaymentSocket.close(); } catch(e) {}
            }

            const protocol = window.location.protocol === 'https:' ? 'wss://' : 'ws://';
            const pathParts = window.location.pathname.split('/view/');
            const contextPath = pathParts[0] || '';
            const wsUrl = protocol + window.location.host + contextPath + '/order-ws/' + encodeURIComponent(orderId);

            console.log('[Payment WS] Connecting to:', wsUrl);

            try {
                const ws = new WebSocket(wsUrl);
                activePaymentSocket = ws;

                ws.onmessage = function(event) {
                    const status = event.data;
                    console.log('[Payment WS] Message received:', status);
                    
                    if (status === 'PAID') {
                        ws.close();
                        activePaymentSocket = null;

                        closeConfirmModal();

                        // Hide main layout elements and show success panel
                        document.getElementById('order-id-display').textContent = orderId;
                        
                        // Hide existing calculation sections and registration/agent forms
                        const calcSection = document.getElementById('ws-calc');
                        const priceTableSection = document.getElementById('ws-price-table');
                        const orderSection = document.getElementById('order');
                        
                        if (calcSection) calcSection.classList.add('hidden');
                        if (priceTableSection) priceTableSection.classList.add('hidden');
                        if (orderSection) orderSection.classList.add('hidden');

                        const successPanel = document.getElementById('success-panel');
                        if (successPanel) {
                            successPanel.classList.remove('hidden');
                            successPanel.scrollIntoView({ behavior: 'smooth' });
                        }

                        showToast('🎉 Thanh toán thành công! Đơn sỉ của bạn đã được tiếp nhận.');
                    }
                };

                ws.onclose = function() {
                    console.log('[Payment WS] Closed for order:', orderId);
                };

                ws.onerror = function(err) {
                    console.error('[Payment WS] Error:', err);
                };

            } catch (e) {
                console.error('[Payment WS] Failed to create WebSocket connection:', e);
            }
        }

        let toastTimer;
        function showToast(msg, type='success') {
            const t = document.getElementById('toast');
            if (!t) return;
            t.textContent = msg;
            t.className = 'toast show';
            t.style.background = type==='warn' ? '#B45309' : '#92400E';
            clearTimeout(toastTimer);
            toastTimer = setTimeout(() => { t.className = 'toast'; }, 2500);
        }
    </script>
</body>
</html>

