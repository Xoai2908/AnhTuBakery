<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0
    response.setDateHeader("Expires", 0); // Proxies

    com.mycompany.bakery.business.User customerUser = (com.mycompany.bakery.business.User) session.getAttribute("user");
    if (customerUser == null) {
        response.sendRedirect("admin_login.jsp?required=1&redirect=order.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt Hàng Lẻ – Bánh Mì Anh Tú</title>
    <meta name="description" content="Đặt bánh mì, xôi, sữa đậu online. Chọn tự đến lấy (miễn phí) hoặc giao hàng tận nơi tại thành phố Huế.">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Pacifico&family=Nunito:ital,wght@0,300;0,400;0,600;0,700;0,800;0,900;1,400&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/style.css?v=20260616">
    <link rel="stylesheet" href="../css/order.css?v=20260616">
</head>
<body>

    <!-- HEADER -->
    <header class="site-header" id="site-header">
        <div class="container header-inner">
            <a href="index.jsp" class="brand-logo" id="brand-logo-link" style="display: flex; align-items: center; gap: var(--space-sm);">
                <img src="../images/logo.png" alt="Logo Bánh Mì Anh Tú" class="logo-img">
                <div style="display: flex; flex-direction: column; justify-content: center;">
                    <span class="brand-name" style="line-height: 1.2;">Bánh Mì Anh Tú</span>
                    <% if (customerUser != null) { %>
                        <span style="color:var(--yellow-light);font-weight:700;font-size:0.75rem;margin-top:2px;">Xin chào, <%= customerUser.getFullname() %></span>
                    <% } %>
                </div>
            </a>
            <nav class="main-nav" id="main-nav">
                <a href="index.jsp" class="nav-link" id="nav-home">Trang chủ</a>
                <a href="menu.jsp" class="nav-link" id="nav-menu">Thực đơn</a>
                <a href="order.jsp" class="nav-link active" id="nav-order">Đặt lẻ</a>
                <a href="wholesale.jsp" class="nav-link" id="nav-wholesale">Mua sỉ</a>
                <a href="track.jsp" class="nav-link" id="nav-track">Tình trạng đơn</a>
                <% if (customerUser != null) { %>
                    <% if ("ADMIN".equals(customerUser.getRole())) { %>
                        <a href="admin_dashboard.jsp" class="nav-link" id="nav-admin" style="color:var(--yellow-light) !important;font-weight:800;">Trang quản trị</a>
                    <% } %>
                    <a href="profile.jsp" class="nav-link" id="nav-profile">Trang cá nhân</a>
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
                <% if (customerUser != null) { %>
                    <div style="padding:10px 15px;color:var(--cream);font-weight:800;font-size:0.95rem;border-top:1px solid var(--cream-dark)">Xin chào, <%= customerUser.getFullname() %></div>
                    <% if ("ADMIN".equals(customerUser.getRole())) { %>
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
            <h1 class="page-hero-title">🛒 Đặt Hàng Lẻ</h1>
            <p class="page-hero-sub">Điền thông tin bên dưới để hoàn tất đơn hàng</p>
        </div>
    </div>

    <!-- MAIN ORDER LAYOUT -->
    <main class="order-page" id="order-page">
        <div class="container order-layout" id="order-layout">

            <!-- LEFT: Form -->
            <div class="order-form-col" id="order-form-col">

                <div class="order-top-row">
                    <!-- STEP 1: Giỏ hàng -->
                    <div class="order-section" id="section-cart-items">
                        <div class="section-step-header" id="step-header-1">
                            <span class="step-badge">1</span>
                            <h2 class="order-section-title" id="order-step1-title">Giỏ hàng của bạn</h2>
                        </div>
                        <div id="order-cart-empty" class="order-cart-empty">
                            <p>🥺 Giỏ hàng trống!</p>
                            <a href="menu.jsp" class="btn btn-primary" id="btn-go-to-menu">Quay lại chọn món</a>
                        </div>
                        <div id="order-cart-list" class="order-cart-list"></div>
                        <a href="menu.jsp" class="add-more-link" id="add-more-link">+ Thêm món khác</a>
                    </div>
     
                    <!-- STEP 2: Hình thức nhận hàng -->
                    <div class="order-section" id="section-delivery">
                        <div class="section-step-header" id="step-header-2">
                            <span class="step-badge">2</span>
                            <h2 class="order-section-title" id="order-step2-title">Hình thức nhận hàng</h2>
                        </div>
                        <div class="delivery-choice-group" id="delivery-choice-group" role="radiogroup" aria-label="Chọn hình thức nhận hàng">
                            <!-- Tự đến lấy -->
                            <label class="delivery-choice-card" id="choice-pickup" for="method-pickup">
                                <input type="radio" name="delivery-method" id="method-pickup" value="TU_LAY">
                                <div class="choice-inner">
                                    <span class="choice-icon">🏠</span>
                                    <div class="choice-text">
                                        <div class="choice-title">Tự đến lấy tại quán</div>
                                        <div class="choice-sub">Địa chỉ: Số 2 Hồ Đắc Di, thành phố Huế</div>
                                    </div>
                                    <div class="choice-fee free">Miễn phí</div>
                                    <div class="choice-check" aria-hidden="true">✔</div>
                                </div>
                            </label>
     
                            <!-- Giao hàng -->
                            <label class="delivery-choice-card" id="choice-ship" for="method-ship">
                                <input type="radio" name="delivery-method" id="method-ship" value="GIAO_HANG">
                                <div class="choice-inner">
                                    <span class="choice-icon">🚴</span>
                                    <div class="choice-text">
                                        <div class="choice-title">Giao hàng tận nơi</div>
                                        <div class="choice-sub">Phí tính theo km từ quán đến bạn</div>
                                    </div>
                                    <div class="choice-fee paid">Từ 10.000đ</div>
                                    <div class="choice-check" aria-hidden="true">✔</div>
                                </div>
                            </label>
                        </div>
                        <p class="delivery-error hidden" id="delivery-method-error">⚠️ Vui lòng chọn hình thức nhận hàng</p>
                    </div>
                </div>

                <!-- STEP 3: Thông tin khách -->
                <div class="order-section" id="section-customer-info">
                    <div class="section-step-header" id="step-header-3">
                        <span class="step-badge">3</span>
                        <h2 class="order-section-title" id="order-step3-title">Thông tin của bạn</h2>
                    </div>
                    <form class="customer-form" id="customer-form" novalidate>
                        <div class="form-group" id="fg-name">
                            <label class="form-label" for="customer-name">Họ và tên <span class="req">*</span></label>
                            <input type="text" id="customer-name" name="customerName" class="form-input" placeholder="Nguyễn Văn A" value="<%= customerUser.getFullname() != null ? customerUser.getFullname() : "" %>" maxlength="100" required autocomplete="name">
                            <span class="form-error hidden" id="err-name">Vui lòng nhập họ tên</span>
                        </div>
                        <div class="form-group" id="fg-phone">
                            <label class="form-label" for="customer-phone">Số điện thoại <span class="req">*</span></label>
                            <input type="tel" id="customer-phone" name="customerPhone" class="form-input" placeholder="0912 345 678" value="<%= customerUser.getUsername().matches("\\d{10}") ? customerUser.getUsername() : "" %>" maxlength="10" required autocomplete="tel" inputmode="numeric">
                            <span class="form-error hidden" id="err-phone">Vui lòng nhập đúng 10 số điện thoại</span>
                        </div>

                        <!-- Extra: Pickup time (optional, shown when TU_LAY) -->
                        <div class="form-group hidden" id="fg-pickup-time">
                            <label class="form-label" for="pickup-time">Giờ dự kiến đến lấy <span class="optional">(Không bắt buộc, tối thiểu sau 10 phút)</span></label>
                            <input type="time" id="pickup-time" name="pickupTime" class="form-input">
                        </div>

                        <!-- Extra: Delivery address (shown when GIAO_HANG) -->
                        <div class="form-group hidden" id="fg-address">
                            <label class="form-label" for="delivery-address">Địa chỉ giao hàng <span class="req">*</span></label>
                            <input type="text" id="delivery-address" name="deliveryAddress" class="form-input" placeholder="123 Đường ABC, Phường X, thành phố Huế" required autocomplete="street-address">
                            <span class="form-error hidden" id="err-address">Vui lòng nhập địa chỉ giao hàng</span>
                            <!-- Hidden coord fields (populated by geocoding) -->
                            <input type="hidden" id="lat" name="lat">
                            <input type="hidden" id="lng" name="lng">
                            <!-- Geocode status -->
                            <div class="geocode-status hidden" id="geocode-status">
                                <span class="geocode-status-icon" id="geocode-status-icon"></span>
                                <span class="geocode-status-text" id="geocode-status-text"></span>
                            </div>
                            <!-- Ship fee result (shown after geocoding) -->
                            <div class="ship-fee-result hidden" id="ship-fee-result">
                                <div class="ship-fee-row">
                                    <span>Khoảng cách:</span>
                                    <span id="ship-distance">—</span>
                                </div>
                                <div class="ship-fee-row">
                                    <span>Phí giao hàng:</span>
                                    <span id="ship-fee-val" class="ship-fee-val">—</span>
                                </div>
                                <div class="ship-warning hidden" id="ship-warning">⚠️ Khoảng cách rất xa. Phí ship cao, vui lòng cân nhắc.</div>
                            </div>
                        </div>
                        
                        <!-- Ghi chú (Notes) -->
                        <div class="form-group" id="fg-note" style="margin-top: 1.25rem;">
                            <label class="form-label" for="order-note">Ghi chú đơn hàng <span class="optional">(Không bắt buộc)</span></label>
                            <textarea id="order-note" name="note" class="form-input" placeholder="Ví dụ: Không ăn hành, nhiều pate, giao trước 8h sáng..." rows="3" maxlength="500" style="resize: vertical; font-family: inherit; padding: 0.75rem 1rem; border: 2px solid var(--cream-dark); border-radius: var(--radius-md); font-size: 0.95rem; box-sizing: border-box; width: 100%;"></textarea>
                        </div>
                    </form>
                </div>

                <!-- Tóm tắt đơn hàng -->
                <div class="order-summary-box" id="order-summary-box">
                    <h3 class="summary-title" id="summary-title">📋 Tóm tắt đơn hàng</h3>
                    <div class="summary-items" id="summary-items"></div>
                    <div class="summary-divider"></div>
                    <div class="summary-line" id="summary-subtotal-line">
                        <span>Tổng tiền hàng</span>
                        <span id="summary-subtotal">0đ</span>
                    </div>
                    <div class="summary-line" id="summary-ship-line">
                        <span>Phí giao hàng</span>
                        <span id="summary-ship-fee">—</span>
                    </div>
                    <div class="summary-divider"></div>
                    <div class="summary-line total" id="summary-total-line">
                        <span>TỔNG THANH TOÁN</span>
                        <span id="summary-total">0đ</span>
                    </div>
                </div>

                <!-- Submit Button -->
                <button class="btn btn-primary btn-lg submit-order-btn" id="btn-submit-order" onclick="submitOrder()">
                    Xem xác nhận đơn hàng →
                </button>
            </div>
        </div>

        <!-- ===== CONFIRMATION MODAL ===== -->
        <div class="modal-overlay hidden" id="confirm-modal-overlay">
            <div class="confirm-modal" id="confirm-modal" role="dialog" aria-modal="true" aria-label="Xác nhận đơn hàng">
                <div class="modal-header" id="modal-header">
                    <h2 class="modal-title" id="modal-title">✅ Xác Nhận Đơn Hàng</h2>
                    <button class="modal-close-btn" id="modal-close-btn" onclick="closeConfirmModal()">✕</button>
                </div>
                <div class="modal-body" id="modal-body">
                    <div class="modal-summary" id="modal-summary">
                        <!-- Populated by JS -->
                    </div>
                    <div class="qr-section" id="qr-section">
                        <h3 class="qr-title" id="qr-title">📱 Thanh toán chuyển khoản</h3>
                        <div class="qr-display" id="qr-display">
                            <img id="qr-image" src="" alt="Mã QR Thanh Toán" style="max-width: 230px; border: 2.5px solid var(--amber); border-radius: var(--radius-lg); box-shadow: var(--shadow-card);" />
                        </div>
                        <div class="qr-info" id="qr-info">
                            <div class="qr-info-row">
                                <span>Ngân hàng:</span>
                                <strong>BIDV (PGD An Đông)</strong>
                            </div>
                            <div class="qr-info-row">
                                <span>Chủ tài khoản:</span>
                                <strong>VO HO UYEN NHI</strong>
                            </div>
                            <div class="qr-info-row">
                                <span>Số tài khoản:</span>
                                <strong>8821037502</strong>
                            </div>
                            <div class="qr-info-row">
                                <span>Số tiền:</span>
                                <strong id="qr-amount" class="qr-amount">0đ</strong>
                            </div>
                            <div class="qr-info-row">
                                <span>Nội dung CK:</span>
                                <strong id="qr-content">ANHTUBAKERY DHMOI</strong>
                            </div>
                            <p class="qr-note-text" id="qr-note-text">Sau khi chuyển, vui lòng chờ xác nhận từ Anh Tú Bakery. Chúng tôi sẽ thông báo khi đơn được xác nhận!</p>
                        </div>
                    </div>
                </div>
                <div class="modal-footer" id="modal-footer">
                    <button class="btn btn-outline" onclick="closeConfirmModal()" id="btn-edit-order">← Sửa đơn hàng</button>
                    <button class="btn btn-primary" id="btn-place-order" onclick="placeOrder()">✅ Xác nhận đặt hàng</button>
                </div>
            </div>
        </div>

        <!-- SUCCESS STATE -->
        <div class="success-panel hidden" id="success-panel">
            <div class="container">
                <div class="success-box" id="success-box">
                    <div class="success-icon" id="success-icon">🎉</div>
                    <h2 class="success-title" id="success-title">Đặt hàng thành công!</h2>
                    <p class="success-msg" id="success-msg">Cảm ơn quý khách đã tin tưởng Bánh Mì Anh Tú!</p>
                    <div class="success-order-id" id="success-order-id">
                        Mã đơn hàng: <strong id="order-id-display">DH000000</strong>
                    </div>
                    <p class="success-sub" id="success-sub">Chúng tôi sẽ gửi thông báo ngay khi đơn được xác nhận và chuẩn bị xong.</p>
                    <div class="success-actions" id="success-actions">
                        <a href="track.jsp" class="btn btn-primary btn-lg" id="btn-track-order">📋 Tình trạng đơn hàng</a>
                        <a href="index.jsp" class="btn btn-outline btn-lg" id="btn-back-home">← Về trang chủ</a>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <footer class="site-footer" id="site-footer" style="margin-top:auto;">
        <div class="container footer-inner">
            <div class="footer-brand">
                <img src="../images/logo.png" alt="Logo" class="footer-logo">
                <p class="footer-tagline">Bánh mì nhà làm – Thơm từ lò ra</p>
            </div>
            <div class="footer-contact">
                <h5 class="footer-heading">Liên hệ</h5>
                <p class="footer-contact-info"><span>📞</span> <a href="tel:0779409567">0779 409 567</a></p>
                <p class="footer-contact-info"><span>⏰</span> 5:30 – hết hàng</p>
            </div>
        </div>
        <div class="footer-bottom"><p>© 2025 Bánh Mì Anh Tú.</p></div>
    </footer>

    <div class="toast" id="toast" role="alert"></div>

    <script src="../js/cart.js?v=20260614_v2"></script>
    <script src="../js/order.js?v=20260614_v2"></script>
</body>
</html>

