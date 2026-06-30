<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    com.mycompany.bakery.business.User loggedUser = (com.mycompany.bakery.business.User) session.getAttribute("user");
    String orderTarget = (loggedUser != null) ? "menu.jsp" : "admin_login.jsp?required=1&redirect=menu.jsp";
    String wholesaleTarget = (loggedUser != null) ? "wholesale.jsp" : "admin_login.jsp?required=1&redirect=wholesale.jsp";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bánh Mì Anh Tú – Thơm Từ Lò Ra, Giao Tận Nhà</title>
    <meta name="description" content="Bánh mì gia đình Anh Tú – Đặt online bánh mì kẹp, xôi, sữa đậu. Tự đến lấy miễn phí hoặc giao hàng tận nơi tại thành phố Huế.">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Pacifico&family=Nunito:ital,wght@0,300;0,400;0,600;0,700;0,800;0,900;1,400&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>

    <!-- ===== HEADER / NAVBAR ===== -->
    <header class="site-header" id="site-header">
        <div class="container header-inner">
            <a href="index.jsp" class="brand-logo" id="brand-logo-link" style="display: flex; align-items: center; gap: var(--space-sm);">
                <img src="../images/logo.png" alt="Logo Bánh Mì Anh Tú" class="logo-img" id="header-logo">
                <div style="display: flex; flex-direction: column; justify-content: center;">
                    <span class="brand-name" style="line-height: 1.2;">Bánh Mì Anh Tú</span>
                    <% if (loggedUser != null) { %>
                        <span style="color:var(--yellow-light);font-weight:700;font-size:0.75rem;margin-top:2px;">Xin chào, <%= loggedUser.getFullname() %></span>
                    <% } %>
                </div>
            </a>
            <nav class="main-nav" id="main-nav">
                <a href="#home" class="nav-link active" id="nav-home">Trang chủ</a>
                <a href="menu.jsp" class="nav-link" id="nav-menu">Thực đơn</a>
                <a href="order.jsp" class="nav-link" id="nav-order">Đặt lẻ</a>
                <a href="wholesale.jsp" class="nav-link" id="nav-wholesale">Mua sỉ</a>
                <a href="track.jsp" class="nav-link" id="nav-track">Tình trạng đơn</a>
                <% if (loggedUser != null) { %>
                    <% if ("ADMIN".equals(loggedUser.getRole())) { %>
                        <a href="admin_dashboard.jsp" class="nav-link" id="nav-admin" style="color:var(--yellow-light) !important;font-weight:800;">Trang quản trị</a>
                    <% } %>
                    <a href="profile.jsp" class="nav-link" id="nav-profile">Trang cá nhân</a>
                    <a href="../auth/logout" class="nav-link" style="color:var(--yellow-light) !important;font-weight:800;">Đăng xuất</a>
                <% } else { %>
                    <a href="admin_login.jsp?redirect=index.jsp" class="btn btn-primary nav-cta" id="nav-cta-order">👤 Đăng nhập</a>
                <% } %>
            </nav>
            <button class="hamburger" id="hamburger-btn" aria-label="Mở menu" aria-expanded="false">
                <span></span><span></span><span></span>
            </button>
        </div>
        <!-- Mobile Drawer -->
        <div class="mobile-drawer" id="mobile-drawer" role="dialog" aria-label="Menu điều hướng">
            <div class="drawer-overlay" id="drawer-overlay"></div>
            <nav class="drawer-nav" id="drawer-nav">
                <button class="drawer-close" id="drawer-close-btn" aria-label="Đóng menu">✕</button>
                <a href="#home" class="drawer-link" id="drawer-home">🏠 Trang chủ</a>
                <a href="menu.jsp" class="drawer-link" id="drawer-menu">🥖 Thực đơn</a>
                <a href="order.jsp" class="drawer-link" id="drawer-order">🛒 Đặt lẻ</a>
                <a href="wholesale.jsp" class="drawer-link" id="drawer-wholesale">📦 Mua sỉ</a>
                <a href="track.jsp" class="drawer-link" id="drawer-track">📋 Tình trạng đơn</a>
                <% if (loggedUser != null) { %>
                    <div style="padding:10px 15px;color:var(--cream);font-weight:800;font-size:0.95rem;border-top:1px solid var(--cream-dark)">Xin chào, <%= loggedUser.getFullname() %></div>
                    <% if ("ADMIN".equals(loggedUser.getRole())) { %>
                        <a href="admin_dashboard.jsp" class="drawer-link" style="color:var(--yellow-light) !important;font-weight:800;">⚙️ Trang quản trị</a>
                    <% } %>
                    <a href="profile.jsp" class="drawer-link">👤 Trang cá nhân</a>
                    <a href="../auth/logout" class="drawer-link" style="color:var(--yellow-light) !important;font-weight:800;">🚪 Đăng xuất</a>
                <% } else { %>
                    <a href="admin_login.jsp?redirect=index.jsp" class="drawer-link" style="font-weight:800;">🔑 Đăng nhập</a>
                <% } %>
            </nav>
        </div>
    </header>

    <!-- ===== HERO SECTION ===== -->
    <section class="hero-section" id="home">
        <div class="hero-bg-overlay"></div>
        <div class="container hero-inner">
            <div class="hero-text" id="hero-text">
                <p class="hero-tagline" id="hero-tagline">🍞 Lò bánh mì gia đình từ 1995</p>
                <h1 class="hero-title" id="hero-title">Bánh Mì Nhà Làm<br>Thơm Từ Lò Ra</h1>
                <p class="hero-desc" id="hero-desc">Đặt trước – Đến lấy hoặc giao tận nhà.<br>Bánh mì kẹp, xôi buổi sáng, sữa đậu tươi mỗi ngày.</p>
                <div class="hero-actions" id="hero-actions">
                    <a href="<%= orderTarget %>" class="btn btn-primary btn-lg" id="hero-btn-order">🛒 Đặt món ngay</a>
                    <a href="menu.jsp" class="btn btn-outline btn-lg" id="hero-btn-menu">📋 Xem thực đơn</a>
                </div>
                <div class="hero-badges" id="hero-badges">
                    <span class="badge" id="badge-ship">🚴 Giao hàng tận nơi</span>
                    <span class="badge" id="badge-pickup">🏠 Tự đến lấy miễn phí</span>
                    <span class="badge" id="badge-fresh">✨ Làm mới mỗi sáng</span>
                </div>
            </div>
            <div class="hero-image" id="hero-image">
                <div class="hero-img-wrap" id="hero-img-wrap">
                    <img src="../images/hero-banh-mi.png" alt="Bánh mì Anh Tú các loại" class="hero-img" id="hero-main-img" loading="eager">
                    <div class="floating-card fc-1" id="floating-card-1">
                        <span class="fc-icon">🔥</span>
                        <div>
                            <div class="fc-title">Mới ra lò</div>
                            <div class="fc-sub">Mỗi sáng 5:30</div>
                        </div>
                    </div>
                    <div class="floating-card fc-2" id="floating-card-2">
                        <span class="fc-icon">⭐</span>
                        <div>
                            <div class="fc-title">Từ 10.000đ</div>
                            <div class="fc-sub">Giá học sinh</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="hero-wave">
            <svg viewBox="0 0 1440 80" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="none">
                <path d="M0,40 C360,80 1080,0 1440,40 L1440,80 L0,80 Z" fill="#FFFBEB"/>
            </svg>
        </div>
    </section>

    <!-- ===== STATS BAR ===== -->
    <section class="stats-bar" id="stats-bar">
        <div class="container stats-inner">
            <div class="stat-item" id="stat-years">
                <div class="stat-num">30+</div>
                <div class="stat-label">Năm kinh nghiệm</div>
            </div>
            <div class="stat-divider"></div>
            <div class="stat-item" id="stat-products">
                <div class="stat-num">14+</div>
                <div class="stat-label">Món ngon</div>
            </div>
            <div class="stat-divider"></div>
            <div class="stat-item" id="stat-radius">
                <div class="stat-num">5km</div>
                <div class="stat-label">Bán kính giao sỉ</div>
            </div>
            <div class="stat-divider"></div>
            <div class="stat-item" id="stat-open">
                <div class="stat-num">5:30</div>
                <div class="stat-label">Mở cửa sớm</div>
            </div>
        </div>
    </section>

    <!-- ===== CHANNELS SECTION (RETAIL & WHOLESALE) ===== -->
    <section class="channels-section" id="channels">
        <div class="container channels-inner">
            <div class="channel-card retail-card" id="channel-retail">
                <div class="channel-header">
                    <span class="channel-icon">🥖</span>
                    <h3 class="channel-title">Đặt Mua Lẻ</h3>
                    <p class="channel-sub">Dành cho cá nhân & gia đình</p>
                </div>
                <p class="channel-desc">Thưởng thức bánh mì kẹp nóng hổi, xôi dẻo thơm ngon và sữa đậu lành lạnh tươi sạch mỗi sáng. Giao tận nơi hoặc tự đến lấy miễn phí.</p>
                <div class="channel-actions">
                    <a href="<%= orderTarget %>" class="btn btn-primary">🛒 Đặt mua lẻ</a>
                    <a href="menu.jsp" class="btn btn-outline">📋 Xem thực đơn</a>
                </div>
            </div>
            
            <div class="channel-card wholesale-card" id="channel-wholesale">
                <div class="channel-header">
                    <span class="channel-icon">📦</span>
                    <h3 class="channel-title">Mua Sỉ Đại Lý</h3>
                    <p class="channel-sub">Dành cho cửa hàng & đối tác</p>
                </div>
                <p class="channel-desc">Nhập mì ổ không nhân số lượng lớn với giá bậc thang ưu đãi. Hỗ trợ giao hàng miễn phí trong bán kính 5km từ lò bánh.</p>
                <div class="price-tiers-mini">
                    <div class="tier-mini">50 - 199 ổ: <strong>1.500đ</strong></div>
                    <div class="tier-mini highlighted">≥ 200 ổ: <strong>1.300đ</strong></div>
                </div>
                <div class="channel-actions">
                    <a href="<%= wholesaleTarget %>" class="btn btn-amber">📦 Đăng ký đại lý</a>
                    <a href="wholesale.jsp#order" class="btn btn-outline-white">Đặt đơn sỉ</a>
                </div>
            </div>
        </div>
    </section>

    <!-- ===== ABOUT SECTION ===== -->
    <section class="about-section" id="about">
        <div class="container about-inner">
            <div class="about-image-col" id="about-image-col">
                <div class="about-img-wrap" id="about-img-wrap">
                    <div class="about-logo-container">
                        <img src="../images/logo.png" alt="Logo Bánh Mì Anh Tú" class="about-logo-img" id="about-logo-img">
                    </div>
                    <div class="about-stamp" id="about-stamp">
                        <span>Gia đình</span>
                        <span>Ẩm thực</span>
                        <span>Truyền thống</span>
                    </div>
                </div>
            </div>
            <div class="about-text-col" id="about-text-col">
                <h2 class="section-title" id="about-title">Câu Chuyện<br>Nhà Chúng Tôi</h2>
                <p class="about-text" id="about-p1">
                    Từ những năm 1995, lò bánh mì của gia đình đã thức dậy từ 3 giờ sáng để nhào bột, nướng bánh — 
                    chỉ để đến 5:30 sáng, mùi bánh mì thơm lừng lan tỏa khắp khu phố.
                </p>
                <p class="about-text" id="about-p2">
                    Hơn 30 năm qua, chúng tôi vẫn giữ nguyên công thức gia truyền: bột mì chọn lọc, 
                    nhân làm tay mỗi ngày, không bảo quản, không phụ gia. 
                    Mỗi ổ bánh là một mảnh tình cảm mà gia đình gửi gắm đến bạn.
                </p>
                <div class="about-features" id="about-features">
                    <div class="about-feat" id="about-feat-1">
                        <span class="feat-icon">🌿</span>
                        <div>
                            <div class="feat-title">Nguyên liệu tươi</div>
                            <div class="feat-desc">Rau sạch, nhân làm mỗi sáng</div>
                        </div>
                    </div>
                    <div class="about-feat" id="about-feat-2">
                        <span class="feat-icon">🔥</span>
                        <div>
                            <div class="feat-title">Lò nướng truyền thống</div>
                            <div class="feat-desc">Vỏ giòn, ruột mềm đặc trưng</div>
                        </div>
                    </div>
                    <div class="about-feat" id="about-feat-3">
                        <span class="feat-icon">❤️</span>
                        <div>
                            <div class="feat-title">Tâm huyết gia đình</div>
                            <div class="feat-desc">Mỗi bánh là tình yêu của Mẹ</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- ===== MENU HIGHLIGHTS ===== -->
    <section class="menu-section" id="menu-highlights">
        <div class="container">
            <div class="section-header" id="menu-header">
                <h2 class="section-title centered" id="menu-title">Thực Đơn Nổi Bật</h2>
                <p class="section-sub" id="menu-sub">Tất cả được làm tươi mỗi ngày – không bảo quản</p>
            </div>

            <div class="menu-tabs" id="menu-tabs" role="tablist">
                <button class="menu-tab active" id="tab-banh-mi" data-tab="banh-mi" role="tab" aria-selected="true">🥖 Bánh mì kẹp</button>
                <button class="menu-tab" id="tab-xoi" data-tab="xoi" role="tab" aria-selected="false">🍚 Xôi</button>
                <button class="menu-tab" id="tab-nuoc" data-tab="nuoc" role="tab" aria-selected="false">🥛 Nước uống</button>
            </div>

            <!-- Bánh mì tab -->
            <div class="menu-grid" id="tab-content-banh-mi" role="tabpanel">
                <div class="product-card" id="card-heo-quay">
                    <div class="card-img-wrap">
                        <img src="../images/banh-mi-heo-quay.png" alt="Bánh mì Heo quay" class="card-img" loading="lazy">
                        <span class="card-badge-pop">Bán chạy</span>
                    </div>
                    <div class="card-body">
                        <h4 class="card-name">Bánh mì Heo quay</h4>
                        <p class="card-desc">Nhân heo quay giòn, rau tươi, sốt đặc biệt</p>
                        <div class="mcard-toppings">
                            <p class="topping-title">Thêm Toppings:</p>
                            <div class="topping-list">
                                <label class="topping-item"><input type="checkbox" name="topping-heo-quay" value="Thêm thịt" data-price="5000"><span>🥓 Thêm thịt (+5k)</span></label>
                                <label class="topping-item"><input type="checkbox" name="topping-heo-quay" value="Thêm trứng" data-price="5000"><span>🍳 Thêm trứng (+5k)</span></label>
                                <label class="topping-item"><input type="checkbox" name="topping-heo-quay" value="Thêm pate" data-price="3000"><span>🧆 Thêm pate (+3k)</span></label>
                            </div>
                        </div>
                        <div class="card-footer">
                            <span class="card-price">13.000đ</span>
                            <button class="btn btn-add-cart" id="add-heo-quay" onclick="BakeryCart.addBanhMiWithToppings('Bánh mì Heo quay', 13000, 'heo-quay')">+ Thêm</button>
                        </div>
                    </div>
                </div>
                <div class="product-card" id="card-bo-xao">
                    <div class="card-img-wrap">
                        <img src="../images/banh-mi-bo-xao.png" alt="Bánh mì Bò xào" class="card-img" loading="lazy">
                    </div>
                    <div class="card-body">
                        <h4 class="card-name">Bánh mì Bò xào</h4>
                        <p class="card-desc">Bò xào sả ớt thơm nức, ăn kèm rau sống</p>
                        <div class="mcard-toppings">
                            <p class="topping-title">Thêm Toppings:</p>
                            <div class="topping-list">
                                <label class="topping-item"><input type="checkbox" name="topping-bo-xao" value="Thêm thịt" data-price="5000"><span>🥓 Thêm thịt (+5k)</span></label>
                                <label class="topping-item"><input type="checkbox" name="topping-bo-xao" value="Thêm trứng" data-price="5000"><span>🍳 Thêm trứng (+5k)</span></label>
                                <label class="topping-item"><input type="checkbox" name="topping-bo-xao" value="Thêm pate" data-price="3000"><span>🧆 Thêm pate (+3k)</span></label>
                            </div>
                        </div>
                        <div class="card-footer">
                            <span class="card-price">13.000đ</span>
                            <button class="btn btn-add-cart" id="add-bo-xao" onclick="BakeryCart.addBanhMiWithToppings('Bánh mì Bò xào', 13000, 'bo-xao')">+ Thêm</button>
                        </div>
                    </div>
                </div>
                <div class="product-card" id="card-trung">
                    <div class="card-img-wrap">
                        <img src="../images/banh-mi-trung.png" alt="Bánh mì Trứng" class="card-img" loading="lazy">
                    </div>
                    <div class="card-body">
                        <h4 class="card-name">Bánh mì Trứng</h4>
                        <p class="card-desc">Trứng ốp la, chả lụa, rau thơm tươi mát</p>
                        <div class="mcard-toppings">
                            <p class="topping-title">Thêm Toppings:</p>
                            <div class="topping-list">
                                <label class="topping-item"><input type="checkbox" name="topping-trung" value="Thêm thịt" data-price="5000"><span>🥓 Thêm thịt (+5k)</span></label>
                                <label class="topping-item"><input type="checkbox" name="topping-trung" value="Thêm trứng" data-price="5000"><span>🍳 Thêm trứng (+5k)</span></label>
                                <label class="topping-item"><input type="checkbox" name="topping-trung" value="Thêm pate" data-price="3000"><span>🧆 Thêm pate (+3k)</span></label>
                            </div>
                        </div>
                        <div class="card-footer">
                            <span class="card-price">10.000đ</span>
                            <button class="btn btn-add-cart" id="add-trung" onclick="BakeryCart.addBanhMiWithToppings('Bánh mì Trứng', 10000, 'trung')">+ Thêm</button>
                        </div>
                    </div>
                </div>
                <div class="product-card" id="card-bo-dau">
                    <div class="card-img-wrap">
                        <img src="../images/banh-mi-bo-dau.png" alt="Bánh mì Bơ đậu" class="card-img" loading="lazy">
                        <span class="card-badge-option">Chọn loại</span>
                    </div>
                    <div class="card-body">
                        <h4 class="card-name">Bánh mì Bơ đậu</h4>
                        <p class="card-desc">Bơ thực vật béo ngậy, kèm sữa hoặc đường</p>
                        <div class="option-group" id="option-bo-dau" role="group" aria-label="Chọn loại bánh mì Bơ đậu">
                            <label class="option-label" id="opt-sua-label">
                                <input type="radio" name="bo-dau-opt" value="Sữa" id="opt-sua">
                                <span>Sữa</span>
                            </label>
                            <label class="option-label" id="opt-duong-label">
                                <input type="radio" name="bo-dau-opt" value="Đường" id="opt-duong">
                                <span>Đường</span>
                            </label>
                        </div>
                        <div class="card-footer">
                            <span class="card-price">10.000đ</span>
                            <button class="btn btn-add-cart" id="add-bo-dau" onclick="addBoDau()" disabled>+ Thêm</button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Xôi tab -->
            <div class="menu-grid hidden" id="tab-content-xoi" role="tabpanel">
                <div class="product-card" id="card-xoi-heo">
                    <div class="card-img-wrap">
                        <img src="../images/xoi-heo-quay.png" alt="Xôi Heo quay" class="card-img" loading="lazy">
                        <span class="card-badge-pop">Yêu thích</span>
                    </div>
                    <div class="card-body">
                        <h4 class="card-name">Xôi Heo quay</h4>
                        <p class="card-desc">Xôi dẻo, heo quay giòn da thơm ngon</p>
                        <div class="size-group" id="size-xoi-heo" role="group" aria-label="Chọn size Xôi Heo quay">
                            <button class="size-btn active" id="size-xoi-heo-s" data-size="SMALL" data-price="15000" onclick="selectSize(this, 'xoi-heo')">Hộp nhỏ 15.000đ</button>
                            <button class="size-btn" id="size-xoi-heo-l" data-size="LARGE" data-price="20000" onclick="selectSize(this, 'xoi-heo')">Hộp lớn 20.000đ</button>
                        </div>
                        <div class="card-footer">
                            <span class="card-price" id="price-xoi-heo">15.000đ</span>
                            <button class="btn btn-add-cart" id="add-xoi-heo" onclick="addSizeItem('Xôi Heo quay', 'xoi-heo')">+ Thêm</button>
                        </div>
                    </div>
                </div>
                <div class="product-card" id="card-xoi-bo">
                    <div class="card-img-wrap">
                        <img src="../images/xoi-bo-xao.png" alt="Xôi Bò xào" class="card-img" loading="lazy">
                    </div>
                    <div class="card-body">
                        <h4 class="card-name">Xôi Bò xào</h4>
                        <p class="card-desc">Xôi nếp dẻo, bò xào sả ớt đậm đà</p>
                        <div class="size-group" id="size-xoi-bo" role="group" aria-label="Chọn size Xôi Bò xào">
                            <button class="size-btn active" id="size-xoi-bo-s" data-size="SMALL" data-price="15000" onclick="selectSize(this, 'xoi-bo')">Hộp nhỏ 15.000đ</button>
                            <button class="size-btn" id="size-xoi-bo-l" data-size="LARGE" data-price="20000" onclick="selectSize(this, 'xoi-bo')">Hộp lớn 20.000đ</button>
                        </div>
                        <div class="card-footer">
                            <span class="card-price" id="price-xoi-bo">15.000đ</span>
                            <button class="btn btn-add-cart" id="add-xoi-bo" onclick="addSizeItem('Xôi Bò xào', 'xoi-bo')">+ Thêm</button>
                        </div>
                    </div>
                </div>
                <div class="product-card" id="card-xoi-trung">
                    <div class="card-img-wrap">
                        <img src="../images/xoi-trung.png" alt="Xôi Trứng" class="card-img" loading="lazy">
                    </div>
                    <div class="card-body">
                        <h4 class="card-name">Xôi Trứng</h4>
                        <p class="card-desc">Xôi gà dẻo mịn kèm trứng chiên vàng</p>
                        <div class="size-group" id="size-xoi-trung" role="group" aria-label="Chọn size Xôi Trứng">
                            <button class="size-btn active" id="size-xoi-trung-s" data-size="SMALL" data-price="10000" onclick="selectSize(this, 'xoi-trung')">Hộp nhỏ 10.000đ</button>
                            <button class="size-btn" id="size-xoi-trung-l" data-size="LARGE" data-price="15000" onclick="selectSize(this, 'xoi-trung')">Hộp lớn 15.000đ</button>
                        </div>
                        <div class="card-footer">
                            <span class="card-price" id="price-xoi-trung">10.000đ</span>
                            <button class="btn btn-add-cart" id="add-xoi-trung" onclick="addSizeItem('Xôi Trứng', 'xoi-trung')">+ Thêm</button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Nước tab -->
            <div class="menu-grid hidden" id="tab-content-nuoc" role="tabpanel">
                <div class="product-card" id="card-sua-dau">
                    <div class="card-img-wrap">
                        <img src="../images/sua-dau-tuoi.png" alt="Sữa đậu" class="card-img" loading="lazy">
                        <span class="card-badge-pop">Mỗi sáng</span>
                    </div>
                    <div class="card-body">
                        <h4 class="card-name">Sữa đậu tươi</h4>
                        <p class="card-desc">Sữa đậu tự nấu, không đường hóa học</p>
                        <div class="size-group" id="size-sua-dau" role="group" aria-label="Chọn size Sữa đậu">
                            <button class="size-btn active" id="size-sua-dau-s" data-size="SMALL" data-price="5000" onclick="selectSize(this, 'sua-dau')">Ly nhỏ 5.000đ</button>
                            <button class="size-btn" id="size-sua-dau-l" data-size="LARGE" data-price="10000" onclick="selectSize(this, 'sua-dau')">Ly lớn 10.000đ</button>
                        </div>
                        <div class="card-footer">
                            <span class="card-price" id="price-sua-dau">5.000đ</span>
                            <button class="btn btn-add-cart" id="add-sua-dau" onclick="addSizeItem('Sữa đậu', 'sua-dau')">+ Thêm</button>
                        </div>
                    </div>
                </div>
            </div>

            <div class="menu-cta" id="menu-cta">
                <a href="menu.jsp" class="btn btn-primary btn-lg" id="btn-view-full-menu">Xem đầy đủ thực đơn →</a>
            </div>
        </div>
    </section>

    <!-- ===== HOW IT WORKS ===== -->
    <section class="how-section" id="how-it-works">
        <div class="container">
            <div class="section-header" id="how-header">
                <h2 class="section-title centered" id="how-title">Đặt Hàng Siêu Dễ</h2>
                <p class="section-sub" id="how-sub">3 bước đơn giản – Nhận bánh thơm ngon</p>
            </div>
            <div class="steps-grid" id="steps-grid">
                <div class="step-card" id="step-1">
                    <div class="step-num">01</div>
                    <div class="step-icon">🥖</div>
                    <h3 class="step-title">Chọn món</h3>
                    <p class="step-desc">Duyệt thực đơn, thêm bánh mì, xôi, nước vào giỏ hàng</p>
                </div>
                <div class="step-arrow" id="arrow-1">→</div>
                <div class="step-card" id="step-2">
                    <div class="step-num">02</div>
                    <div class="step-icon">🏠</div>
                    <h3 class="step-title">Chọn nhận hàng</h3>
                    <p class="step-desc">Tự đến lấy miễn phí hoặc giao hàng tận nhà (tính phí theo km)</p>
                </div>
                <div class="step-arrow" id="arrow-2">→</div>
                <div class="step-card" id="step-3">
                    <div class="step-num">03</div>
                    <div class="step-icon">💳</div>
                    <h3 class="step-title">Thanh toán</h3>
                    <p class="step-desc">Quét mã QR chuyển khoản – nhận thông báo khi món sẵn sàng</p>
                </div>
            </div>
        </div>
    </section>

    <!-- ===== DELIVERY INFO ===== -->
    <section class="delivery-section" id="delivery-info">
        <div class="container delivery-inner">
            <div class="delivery-col" id="delivery-col-pickup">
                <div class="delivery-card pickup-card-style" id="delivery-pickup">
                    <div class="delivery-icon">🏠</div>
                    <h3 class="delivery-title">Tự đến lấy</h3>
                    <div class="delivery-fee free">Miễn phí ship</div>
                    <ul class="delivery-list" id="delivery-list-pickup">
                        <li>✅ Không mất phí giao hàng</li>
                        <li>✅ Nhận thông báo khi món sẵn</li>
                        <li>✅ Chọn khung giờ đến lấy</li>
                        <li>📍 Địa chỉ: Số 2 Hồ Đắc Di, thành phố Huế</li>
                    </ul>
                </div>
            </div>
            <div class="delivery-vs" id="delivery-vs">hoặc</div>
            <div class="delivery-col" id="delivery-col-ship">
                <div class="delivery-card ship-card-style" id="delivery-ship">
                    <div class="delivery-icon">🚴</div>
                    <h3 class="delivery-title">Giao hàng tận nơi</h3>
                    <div class="delivery-fee paid">Từ 10.000đ</div>
                    <ul class="delivery-list" id="delivery-list-ship">
                        <li>✅ Giao trong bán kính thành phố Huế</li>
                        <li>✅ Tính phí tự động theo km</li>
                        <li>✅ Báo ngay khi shipper lấy hàng</li>
                        <li>⏱ Giao trong vòng 30 phút</li>
                    </ul>
                </div>
            </div>
        </div>
        <div class="fee-table-wrap" id="fee-table-wrap">
            <div class="container">
                <h3 class="fee-table-title" id="fee-table-title">Bảng phí giao hàng</h3>
                <div class="fee-table" id="fee-table" role="table" aria-label="Bảng phí giao hàng">
                    <div class="fee-row header" role="row" id="fee-row-header">
                        <div role="columnheader">Khoảng cách</div>
                        <div role="columnheader">Phí ship</div>
                        <div role="columnheader">Ví dụ</div>
                    </div>
                    <div class="fee-row" role="row" id="fee-row-1">
                        <div role="cell">0 – 2 km</div>
                        <div role="cell" class="fee-highlight">10.000đ</div>
                        <div role="cell">1.5km → 10.000đ</div>
                    </div>
                    <div class="fee-row" role="row" id="fee-row-2">
                        <div role="cell">2 – 5 km</div>
                        <div role="cell" class="fee-highlight">10.000đ + (km × 3.500đ)</div>
                        <div role="cell">3.5km → 15.500đ</div>
                    </div>
                    <div class="fee-row" role="row" id="fee-row-3">
                        <div role="cell">5 – 10 km</div>
                        <div role="cell" class="fee-highlight">20.500đ + (km × 4.000đ)</div>
                        <div role="cell">7km → 28.500đ</div>
                    </div>
                    <div class="fee-row" role="row" id="fee-row-4">
                        <div role="cell">> 10 km</div>
                        <div role="cell" class="fee-highlight">40.500đ + (km × 5.000đ)</div>
                        <div role="cell">12km → 50.500đ</div>
                    </div>
                </div>
            </div>
        </div>
    </section>


    <!-- ===== CONTACT SECTION ===== -->
    <section class="contact-section" id="contact">
        <div class="container contact-inner">
            <div class="section-header" id="contact-header">
                <h2 class="section-title centered" id="contact-title">Liên Hệ & Tìm Chúng Tôi</h2>
            </div>
            <div class="contact-grid" id="contact-grid">
                <div class="contact-card" id="contact-card-address">
                    <div class="contact-icon">📍</div>
                    <h4 class="contact-label">Địa chỉ quán</h4>
                    <p class="contact-value">Lò Bánh Mì Anh Tú<br>Số 2 Hồ Đắc Di, thành phố Huế</p>
                </div>
                <div class="contact-card" id="contact-card-phone">
                    <div class="contact-icon">📞</div>
                    <h4 class="contact-label">Điện thoại</h4>
                    <p class="contact-value">
                        <a href="tel:0779409567" id="contact-phone-link">0779 409 567</a>
                    </p>
                </div>
                <div class="contact-card" id="contact-card-hours">
                    <div class="contact-icon">🕐</div>
                    <h4 class="contact-label">Giờ mở cửa</h4>
                    <p class="contact-value">Hàng ngày<br>5:30 – hết hàng</p>
                </div>
                <div class="contact-card" id="contact-card-delivery">
                    <div class="contact-icon">🚴</div>
                    <h4 class="contact-label">Giao hàng</h4>
                    <p class="contact-value">Trong nội ô thành phố Huế<br>Tính phí theo km</p>
                </div>
            </div>
        </div>
    </section>

    <!-- ===== FOOTER ===== -->
    <footer class="site-footer" id="site-footer">
        <div class="container footer-inner">
            <div class="footer-brand" id="footer-brand">
                <img src="../images/logo.png" alt="Logo Bánh Mì Anh Tú" class="footer-logo" id="footer-logo">
                <p class="footer-tagline" id="footer-tagline">Bánh mì nhà làm – Thơm từ lò ra</p>
            </div>
            <div class="footer-links" id="footer-links">
                <h5 class="footer-heading">Thực đơn</h5>
                <a href="menu.jsp#banh-mi" class="footer-link" id="footer-link-banh-mi">Bánh mì kẹp</a>
                <a href="menu.jsp#xoi" class="footer-link" id="footer-link-xoi">Xôi</a>
                <a href="menu.jsp#nuoc" class="footer-link" id="footer-link-nuoc">Nước uống</a>
            </div>
            <div class="footer-links" id="footer-links-order">
                <h5 class="footer-heading">Dịch vụ</h5>
                <a href="order.jsp" class="footer-link" id="footer-link-order">Đặt lẻ online</a>
                <a href="wholesale.jsp" class="footer-link" id="footer-link-wholesale">Mua sỉ đại lý</a>
                <a href="track.jsp" class="footer-link" id="footer-link-track">Tình trạng đơn hàng</a>
            </div>
            <div class="footer-contact" id="footer-contact">
                <h5 class="footer-heading">Liên hệ</h5>
                <p class="footer-contact-info"><span>📞</span> <a href="tel:0779409567" id="footer-phone">0779 409 567</a></p>
                <p class="footer-contact-info"><span>⏰</span> 5:30 – hết hàng</p>
                <p class="footer-contact-info"><span>📍</span> Số 2 Hồ Đắc Di, TP. Huế</p>
            </div>
        </div>
        <div class="footer-bottom" id="footer-bottom">
            <p>© 2025 Bánh Mì Anh Tú. Tất cả quyền được bảo lưu.</p>
        </div>
    </footer>

    <!-- ===== CART FLOATING BUTTON ===== -->
    <div class="cart-float" id="cart-float" onclick="toggleCart()" style="display:none;" role="button" tabindex="0" aria-label="Xem giỏ hàng">
        <span class="cart-icon">🛒</span>
        <span class="cart-count" id="cart-count">0</span>
        <span class="cart-total" id="cart-total-float">0đ</span>
    </div>

    <!-- ===== CART DRAWER ===== -->
    <div class="cart-drawer" id="cart-drawer" role="dialog" aria-label="Giỏ hàng" aria-hidden="true">
        <div class="cart-overlay" id="cart-overlay" onclick="toggleCart()"></div>
        <div class="cart-panel" id="cart-panel">
            <div class="cart-header" id="cart-header">
                <h3>🛒 Giỏ hàng</h3>
                <button class="cart-close-btn" id="cart-close-btn" onclick="toggleCart()" aria-label="Đóng giỏ hàng">✕</button>
            </div>
            <div class="cart-body" id="cart-body">
                <div class="cart-empty" id="cart-empty">
                    <p>Giỏ hàng đang trống 🥺</p>
                    <p>Thêm món ngon vào nhé!</p>
                </div>
                <div class="cart-items" id="cart-items"></div>
            </div>
            <div class="cart-summary" id="cart-summary" style="display:none;">
                <div class="cart-subtotal" id="cart-subtotal">
                    <span>Tổng tiền hàng:</span>
                    <span id="cart-subtotal-val">0đ</span>
                </div>
                <a href="order.jsp" class="btn btn-primary btn-block" id="btn-checkout">Tiếp tục đặt hàng →</a>
            </div>
        </div>
    </div>

    <!-- ===== TOAST NOTIFICATION ===== -->
    <div class="toast" id="toast" role="alert" aria-live="polite"></div>

    <!-- Back to Top -->
    <button class="back-to-top" id="back-to-top" onclick="window.scrollTo({top:0,behavior:'smooth'})" aria-label="Lên đầu trang">↑</button>

    <script src="../js/cart.js?v=20260614"></script>
    <script src="../js/main.js?v=20260614"></script>
</body>
</html>

