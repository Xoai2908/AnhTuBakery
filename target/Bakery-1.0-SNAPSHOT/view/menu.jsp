<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<%
    com.mycompany.bakery.business.User loggedUser = (com.mycompany.bakery.business.User) session.getAttribute("user");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thực Đơn – Bánh Mì Anh Tú</title>
    <meta name="description" content="Xem đầy đủ thực đơn Bánh Mì Anh Tú: Bánh mì kẹp, Xôi các loại, Sữa đậu tươi. Giá bình dân từ 5.000đ.">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Pacifico&family=Nunito:ital,wght@0,300;0,400;0,600;0,700;0,800;0,900;1,400&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/style.css">
    <link rel="stylesheet" href="../css/menu.css">
</head>
<body>

    <!-- HEADER -->
    <header class="site-header" id="site-header">
        <div class="container header-inner">
            <a href="index.jsp" class="brand-logo" id="brand-logo-link">
                <img src="../images/logo.png" alt="Logo Bánh Mì Anh Tú" class="logo-img" id="header-logo">
                <div style="display: flex; flex-direction: column; justify-content: center;">
                    <span class="brand-name" style="line-height: 1.2;">Bánh Mì Anh Tú</span>
                    <% if (loggedUser != null) { %>
                        <span style="color:var(--yellow-light);font-weight:700;font-size:0.75rem;margin-top:2px;">Xin chào, <%= loggedUser.getFullname() %></span>
                    <% } %>
                </div>
            </a>
            <nav class="main-nav" id="main-nav">
                <a href="index.jsp" class="nav-link" id="nav-home">Trang chủ</a>
                <a href="menu.jsp" class="nav-link active" id="nav-menu">Thực đơn</a>
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
                    <a href="admin_login.jsp?redirect=menu.jsp" class="btn btn-primary nav-cta" id="nav-cta-order">👤 Đăng nhập</a>
                <% } %>
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
                <% if (loggedUser != null) { %>
                    <div style="padding:10px 15px;color:var(--cream);font-weight:800;font-size:0.95rem;border-top:1px solid var(--cream-dark)">Xin chào, <%= loggedUser.getFullname() %></div>
                    <% if ("ADMIN".equals(loggedUser.getRole())) { %>
                        <a href="admin_dashboard.jsp" class="drawer-link" style="color:var(--yellow-light) !important;font-weight:800;">⚙️ Trang quản trị</a>
                    <% } %>
                    <a href="profile.jsp" class="drawer-link">👤 Trang cá nhân</a>
                    <a href="../auth/logout" class="drawer-link" style="color:var(--yellow-light) !important;font-weight:800;">🚪 Đăng xuất</a>
                <% } else { %>
                    <a href="admin_login.jsp?redirect=menu.jsp" class="drawer-link" style="font-weight:800;">🔑 Đăng nhập</a>
                <% } %>
            </nav>
        </div>
    </header>

    <!-- PAGE HERO -->
    <div class="page-hero" id="page-hero">
        <div class="container page-hero-inner">
            <h1 class="page-hero-title" id="page-title">📋 Thực Đơn Hôm Nay</h1>
            <p class="page-hero-sub" id="page-sub">Tươi ngon mỗi sáng — Đặt online, giao tận nơi</p>
        </div>
    </div>

    <!-- MENU TOOLBAR: SEARCH & FILTER -->
    <div class="menu-toolbar" id="menu-toolbar">
        <div class="container toolbar-inner">
            <div class="filter-tabs">
                <button class="filter-tab active" data-category="all">🍽️ Tất cả</button>
                <button class="filter-tab" data-category="banh-mi">🥖 Bánh mì</button>
                <button class="filter-tab" data-category="xoi">🍚 Xôi</button>
                <button class="filter-tab" data-category="nuoc">🥛 Nước uống</button>
            </div>
            <div class="search-wrap">
                <span class="search-icon">🔍</span>
                <input type="text" id="menu-search-input" class="search-input" placeholder="Tìm tên món ăn...">
                <button id="search-clear-btn" class="search-clear-btn hidden" onclick="clearSearch()">✕</button>
            </div>
        </div>
    </div>

    <!-- MAIN CONTENT -->
    <main class="menu-page" id="menu-page">
        <div class="container">

            <!-- BÁNH MÌ SECTION -->
            <section class="menu-cat-section" id="banh-mi">
                <div class="cat-header" id="cat-header-banh-mi">
                    <h2 class="cat-title" id="cat-title-banh-mi">🥖 Bánh mì kẹp</h2>
                    <p class="cat-desc" id="cat-desc-banh-mi">Baguette lò nướng mỗi sáng, nhân tươi làm tay</p>
                </div>

                <div class="full-menu-grid" id="grid-banh-mi">
                    <div class="text-center p-4 text-muted" style="grid-column: 1/-1;">⏳ Đang tải bánh mì...</div>
                </div>
            </section>

            <!-- XÔI SECTION -->
            <section class="menu-cat-section" id="xoi">
                <div class="cat-header" id="cat-header-xoi">
                    <h2 class="cat-title" id="cat-title-xoi">🍚 Xôi</h2>
                    <p class="cat-desc" id="cat-desc-xoi">Nếp dẻo thơm, nhân đa dạng — ăn sáng no bền</p>
                </div>

                <div class="size-info-bar" id="xoi-size-info">
                    <div class="size-info-item">
                        <span class="size-pill small">Hộp nhỏ</span>
                        <span>= 10.000đ – 15.000đ</span>
                    </div>
                    <div class="size-info-item">
                        <span class="size-pill large">Hộp lớn</span>
                        <span>= 15.000đ – 20.000đ</span>
                    </div>
                </div>

                <div class="full-menu-grid" id="grid-xoi">
                    <div class="text-center p-4 text-muted" style="grid-column: 1/-1;">⏳ Đang tải xôi...</div>
                </div>
            </section>

            <!-- NƯỚC UỐNG SECTION -->
            <section class="menu-cat-section" id="nuoc">
                <div class="cat-header" id="cat-header-nuoc">
                    <h2 class="cat-title" id="cat-title-nuoc">🥛 Nước uống</h2>
                    <p class="cat-desc" id="cat-desc-nuoc">Tự nấu mỗi sáng — không đường hóa học, tốt cho sức khỏe</p>
                </div>

                <div class="full-menu-grid" id="grid-nuoc">
                    <div class="text-center p-4 text-muted" style="grid-column: 1/-1;">⏳ Đang tải nước uống...</div>
                </div>
            </section>

            <!-- ORDER CTA -->
            <div class="menu-order-cta" id="menu-order-cta">
                <div class="cta-box" id="cta-box">
                    <h3 class="cta-title" id="cta-title">Đã chọn xong? 🎉</h3>
                    <p class="cta-desc" id="cta-desc">Tiếp tục điền thông tin để đặt hàng nhé!</p>
                    <a href="order.jsp" class="btn btn-primary btn-lg" id="btn-go-order">🛒 Tiến hành đặt hàng</a>
                </div>
            </div>

        </div>
    </main>

    <!-- FOOTER -->
    <footer class="site-footer" id="site-footer">
        <div class="container footer-inner">
            <div class="footer-brand">
                <img src="../images/logo.png" alt="Logo Bánh Mì Anh Tú" class="footer-logo">
                <p class="footer-tagline">Bánh mì nhà làm – Thơm từ lò ra</p>
            </div>
            <div class="footer-links">
                <h5 class="footer-heading">Thực đơn</h5>
                <a href="#banh-mi" class="footer-link">Bánh mì kẹp</a>
                <a href="#xoi" class="footer-link">Xôi</a>
                <a href="#nuoc" class="footer-link">Nước uống</a>
            </div>
            <div class="footer-links">
                <h5 class="footer-heading">Dịch vụ</h5>
                <a href="order.jsp" class="footer-link">Đặt lẻ online</a>
                <a href="wholesale.jsp" class="footer-link">Mua sỉ đại lý</a>
                <a href="track.jsp" class="footer-link">Tình trạng đơn hàng</a>
            </div>
            <div class="footer-contact">
                <h5 class="footer-heading">Liên hệ</h5>
                <p class="footer-contact-info"><span>📞</span> <a href="tel:0779409567">0779 409 567</a></p>
                <p class="footer-contact-info"><span>⏰</span> 5:30 – hết hàng</p>
            </div>
        </div>
        <div class="footer-bottom"><p>© 2025 Bánh Mì Anh Tú.</p></div>
    </footer>

    <!-- CART FLOAT & DRAWER -->
    <div class="cart-float" id="cart-float" onclick="toggleCart()" style="display:none;">
        <span class="cart-icon">🛒</span>
        <span class="cart-count" id="cart-count">0</span>
        <span class="cart-total" id="cart-total-float">0đ</span>
    </div>
    <div class="cart-drawer" id="cart-drawer" aria-hidden="true">
        <div class="cart-overlay" id="cart-overlay" onclick="toggleCart()"></div>
        <div class="cart-panel" id="cart-panel">
            <div class="cart-header"><h3>🛒 Giỏ hàng</h3><button class="cart-close-btn" id="cart-close-btn" onclick="toggleCart()">✕</button></div>
            <div class="cart-body" id="cart-body">
                <div class="cart-empty" id="cart-empty"><p>Giỏ hàng đang trống 🥺</p><p>Thêm món ngon vào nhé!</p></div>
                <div class="cart-items" id="cart-items"></div>
            </div>
            <div class="cart-summary" id="cart-summary" style="display:none;">
                <div class="cart-subtotal"><span>Tổng tiền hàng:</span><span id="cart-subtotal-val">0đ</span></div>
                <a href="order.jsp" class="btn btn-primary btn-block">Tiến hành đặt hàng →</a>
            </div>
        </div>
    </div>
    <div class="toast" id="toast" role="alert"></div>
    <button class="back-to-top" id="back-to-top" onclick="window.scrollTo({top:0,behavior:'smooth'})">↑</button>

    <script>
        let allProducts = [];
        let currentCategory = 'all';
        let searchQuery = '';

        document.addEventListener('DOMContentLoaded', () => {
            fetch('../resources/products')
            .then(res => {
                if (!res.ok) throw new Error('Không thể tải thực đơn');
                return res.json();
            })
            .then(products => {
                allProducts = products || [];
                renderMenu();
                setupToolbar();
                
                if (typeof initScrollReveal === 'function') {
                    setTimeout(initScrollReveal, 100);
                }
            })
            .catch(err => {
                console.error(err);
                const errHtml = `<div class="text-center p-4" style="color:var(--red-dark);grid-column:1/-1;">⚠️ Lỗi tải món ăn: ${err.message}</div>`;
                document.getElementById('grid-banh-mi').innerHTML = errHtml;
                document.getElementById('grid-xoi').innerHTML = errHtml;
                document.getElementById('grid-nuoc').innerHTML = errHtml;
            });
        });

        function setupToolbar() {
            // Category Tabs filter click
            document.querySelectorAll('.filter-tab').forEach(tab => {
                tab.addEventListener('click', () => {
                    document.querySelectorAll('.filter-tab').forEach(t => t.classList.remove('active'));
                    tab.classList.add('active');
                    currentCategory = tab.dataset.category;
                    renderMenu();
                });
            });

            // Search input typing
            const searchInput = document.getElementById('menu-search-input');
            const clearBtn = document.getElementById('search-clear-btn');
            
            searchInput.addEventListener('input', (e) => {
                searchQuery = e.target.value.toLowerCase().trim();
                if (searchQuery) {
                    clearBtn.classList.remove('hidden');
                } else {
                    clearBtn.classList.add('hidden');
                }
                renderMenu();
            });
        }

        function clearSearch() {
            const searchInput = document.getElementById('menu-search-input');
            searchInput.value = '';
            searchQuery = '';
            document.getElementById('search-clear-btn').classList.add('hidden');
            renderMenu();
            searchInput.focus();
        }

        function renderMenu() {
            let filtered = allProducts;

            // Apply search filter
            if (searchQuery) {
                filtered = filtered.filter(p => p.name.toLowerCase().includes(searchQuery));
            }

            const banhMiList = filtered.filter(p => p.category === 'banh-mi');
            const xoiList = filtered.filter(p => p.category === 'xoi');
            const nuocList = filtered.filter(p => p.category === 'nuoc');

            const secBanhMi = document.getElementById('banh-mi');
            const secXoi = document.getElementById('xoi');
            const secNuoc = document.getElementById('nuoc');

            // Hide/Show sections based on tab selection and search results
            if (currentCategory === 'all') {
                secBanhMi.style.display = (banhMiList.length > 0 || !searchQuery) ? '' : 'none';
                secXoi.style.display = (xoiList.length > 0 || !searchQuery) ? '' : 'none';
                secNuoc.style.display = (nuocList.length > 0 || !searchQuery) ? '' : 'none';

                renderBanhMi(banhMiList);
                renderXoi(xoiList);
                renderNuoc(nuocList);
            } else {
                secBanhMi.style.display = (currentCategory === 'banh-mi') ? '' : 'none';
                secXoi.style.display = (currentCategory === 'xoi') ? '' : 'none';
                secNuoc.style.display = (currentCategory === 'nuoc') ? '' : 'none';

                if (currentCategory === 'banh-mi') renderBanhMi(banhMiList);
                if (currentCategory === 'xoi') renderXoi(xoiList);
                if (currentCategory === 'nuoc') renderNuoc(nuocList);
            }

            // Check if all sections are hidden
            const noResults = document.getElementById('no-results-msg');
            const isAllHidden = secBanhMi.style.display === 'none' && secXoi.style.display === 'none' && secNuoc.style.display === 'none';
            if (isAllHidden) {
                if (!noResults) {
                    const msg = document.createElement('div');
                    msg.id = 'no-results-msg';
                    msg.className = 'text-center p-4 text-muted';
                    msg.style.gridColumn = '1/-1';
                    msg.style.fontSize = '1.1rem';
                    msg.style.margin = '3rem 0';
                    msg.innerHTML = '🔍 Không tìm thấy món ăn nào phù hợp với từ khóa của bạn.';
                    document.getElementById('menu-page').querySelector('.container').appendChild(msg);
                }
            } else {
                if (noResults) noResults.remove();
            }
        }

        function renderBanhMi(list) {
            const grid = document.getElementById('grid-banh-mi');
            if (list.length === 0) {
                grid.innerHTML = '<div class="text-center p-4 text-muted" style="grid-column: 1/-1;">Không tìm thấy bánh mì kẹp nào.</div>';
                return;
            }
            grid.innerHTML = '';
            list.forEach(p => {
                const article = document.createElement('article');
                const disabledAttr = p.active ? '' : 'disabled';
                
                let toppingsHtml = '';
                let badgeHtml = '';
                let clickAction = '';
                
                if (!p.active) {
                    badgeHtml = '<span class="mcard-badge out-of-stock-badge">Hết hàng</span>';
                }
                
                if (p.name.includes('Bơ đậu')) {
                    article.className = 'menu-product-card special-card' + (p.active ? '' : ' out-of-stock');
                    if (p.active) {
                        badgeHtml = '<span class="mcard-badge option">✦ Chọn loại</span>';
                    }
                    toppingsHtml = `
                        <div class="mcard-option-section" id="mcard-option-bo-dau">
                            <p class="option-required-label" id="option-req-label">Chọn loại <span class="req-mark">*</span></p>
                            <div class="option-group" id="m-option-bo-dau" role="group">
                                <label class="option-label" id="m-opt-sua-label">
                                    <input type="radio" name="m-bo-dau-opt" value="Sữa" id="m-opt-sua" ${disabledAttr}>
                                    <span>🥛 Sữa</span>
                                </label>
                                <label class="option-label" id="m-opt-duong-label">
                                    <input type="radio" name="m-bo-dau-opt" value="Đường" id="m-opt-duong" ${disabledAttr}>
                                    <span>🍯 Đường</span>
                                </label>
                            </div>
                            <p class="option-error-msg hidden" id="m-opt-error">⚠️ Vui lòng chọn Sữa hoặc Đường</p>
                        </div>
                    `;
                    clickAction = `addBoDauMenu()`;
                } else {
                    article.className = 'menu-product-card' + (p.active ? '' : ' out-of-stock');
                    if (p.active) {
                        if (p.name.includes('Thập cẩm') || p.name.includes('Đặc biệt')) {
                            badgeHtml = '<span class="mcard-badge bestseller">⭐ Đặc biệt</span>';
                        } else if (p.name.includes('Heo quay') || p.name.includes('Bò xào')) {
                            badgeHtml = '<span class="mcard-badge sell">🔥 Bán chạy</span>';
                        }
                    }
                    
                    toppingsHtml = `
                        <div class="mcard-toppings">
                            <p class="topping-title">Thêm Toppings:</p>
                            <div class="topping-list">
                                <label class="topping-item"><input type="checkbox" name="topping-prod-${p.id}" value="Thêm thịt" data-price="5000" ${disabledAttr}><span>🥓 Thêm thịt (+5k)</span></label>
                                <label class="topping-item"><input type="checkbox" name="topping-prod-${p.id}" value="Thêm trứng" data-price="5000" ${disabledAttr}><span>🍳 Thêm trứng (+5k)</span></label>
                                <label class="topping-item"><input type="checkbox" name="topping-prod-${p.id}" value="Thêm pate" data-price="3000" ${disabledAttr}><span>🧆 Thêm pate (+3k)</span></label>
                            </div>
                        </div>
                    `;
                    clickAction = `BakeryCart.addBanhMiWithToppings('${p.name}', ${p.price}, 'prod-${p.id}'); animateBtn(this)`;
                }
                
                const btnHtml = p.active 
                    ? `<button class="btn btn-add-cart" id="m-add-prod-${p.id}" onclick="${clickAction}">+ Thêm vào giỏ</button>`
                    : `<button class="btn btn-add-cart" id="m-add-prod-${p.id}" disabled>Hết hàng</button>`;

                article.id = `mcard-prod-${p.id}`;
                article.innerHTML = `
                    <div class="mcard-img-wrap">
                        <img src="${p.imageUrl || '../images/logo.png'}" alt="${p.name}" class="mcard-img" loading="lazy">
                        ${badgeHtml}
                    </div>
                    <div class="mcard-body">
                        <h3 class="mcard-name">${p.name}</h3>
                        <p class="mcard-desc">${p.description || ''}</p>
                        ${toppingsHtml}
                        <div class="mcard-footer">
                            <span class="mcard-price">${p.price.toLocaleString('vi-VN')}đ</span>
                            ${btnHtml}
                        </div>
                    </div>
                `;
                grid.appendChild(article);
            });
        }

        function renderXoi(list) {
            const grid = document.getElementById('grid-xoi');
            if (list.length === 0) {
                grid.innerHTML = '<div class="text-center p-4 text-muted" style="grid-column: 1/-1;">Không tìm thấy xôi nào.</div>';
                return;
            }
            grid.innerHTML = '';
            list.forEach(p => {
                const article = document.createElement('article');
                article.className = 'menu-product-card' + (p.active ? '' : ' out-of-stock');
                article.id = `mcard-prod-${p.id}`;
                
                let badgeHtml = '';
                if (!p.active) {
                    badgeHtml = '<span class="mcard-badge out-of-stock-badge">Hết hàng</span>';
                } else {
                    if (p.name.includes('Thập cẩm') || p.name.includes('Đặc biệt')) {
                        badgeHtml = '<span class="mcard-badge bestseller">⭐ Đặc biệt</span>';
                    } else if (p.name.includes('Heo quay') || p.name.includes('Bò xào')) {
                        badgeHtml = '<span class="mcard-badge sell">❤️ Yêu thích</span>';
                    }
                }

                const disabledAttr = p.active ? '' : 'disabled';
                const btnHtml = p.active
                    ? `<button class="btn btn-add-cart" id="m-add-prod-${p.id}" onclick="addMenuSizeItem('${p.name}','m-prod-${p.id}'); animateBtn(this)">+ Thêm vào giỏ</button>`
                    : `<button class="btn btn-add-cart" id="m-add-prod-${p.id}" disabled>Hết hàng</button>`;

                article.innerHTML = `
                    <div class="mcard-img-wrap">
                        <img src="${p.imageUrl || '../images/logo.png'}" alt="${p.name}" class="mcard-img" loading="lazy">
                        ${badgeHtml}
                    </div>
                    <div class="mcard-body">
                        <h3 class="mcard-name">${p.name}</h3>
                        <p class="mcard-desc">${p.description || ''}</p>
                        <div class="size-group" id="m-size-prod-${p.id}" role="group">
                            <button class="size-btn active" id="m-size-prod-${p.id}-s" data-size="SMALL" data-price="${p.price}" onclick="selectSize(this, 'm-prod-${p.id}')" ${disabledAttr}>Hộp nhỏ<br>${p.price.toLocaleString('vi-VN')}đ</button>
                            <button class="size-btn" id="m-size-prod-${p.id}-l" data-size="LARGE" data-price="${p.price + 5000}" onclick="selectSize(this, 'm-prod-${p.id}')" ${disabledAttr}>Hộp lớn<br>${(p.price + 5000).toLocaleString('vi-VN')}đ</button>
                        </div>
                        <div class="mcard-footer">
                            <span class="mcard-price" id="m-price-m-prod-${p.id}">${p.price.toLocaleString('vi-VN')}đ</span>
                            ${btnHtml}
                        </div>
                    </div>
                `;
                grid.appendChild(article);
            });
        }

        function renderNuoc(list) {
            const grid = document.getElementById('grid-nuoc');
            if (list.length === 0) {
                grid.innerHTML = '<div class="text-center p-4 text-muted" style="grid-column: 1/-1;">Không tìm thấy nước uống nào.</div>';
                return;
            }
            grid.innerHTML = '';
            list.forEach(p => {
                const article = document.createElement('article');
                article.className = 'menu-product-card' + (p.active ? '' : ' out-of-stock');
                article.id = `mcard-prod-${p.id}`;
                
                let badgeHtml = '';
                if (!p.active) {
                    badgeHtml = '<span class="mcard-badge out-of-stock-badge">Hết hàng</span>';
                } else {
                    badgeHtml = '<span class="mcard-badge sell">🌿 Tươi mỗi sáng</span>';
                }

                const disabledAttr = p.active ? '' : 'disabled';
                const btnHtml = p.active
                    ? `<button class="btn btn-add-cart" id="m-add-prod-${p.id}" onclick="addMenuSizeItem('${p.name}','m-prod-${p.id}'); animateBtn(this)">+ Thêm vào giỏ</button>`
                    : `<button class="btn btn-add-cart" id="m-add-prod-${p.id}" disabled>Hết hàng</button>`;

                article.innerHTML = `
                    <div class="mcard-img-wrap">
                        <img src="${p.imageUrl || '../images/logo.png'}" alt="${p.name}" class="mcard-img" loading="lazy">
                        ${badgeHtml}
                    </div>
                    <div class="mcard-body">
                        <h3 class="mcard-name">${p.name}</h3>
                        <p class="mcard-desc">${p.description || ''}</p>
                        <div class="size-group" id="m-size-prod-${p.id}" role="group">
                            <button class="size-btn active" id="m-size-prod-${p.id}-s" data-size="SMALL" data-price="${p.price}" onclick="selectSize(this, 'm-prod-${p.id}')" ${disabledAttr}>Ly nhỏ<br>${p.price.toLocaleString('vi-VN')}đ</button>
                            <button class="size-btn" id="m-size-prod-${p.id}-l" data-size="LARGE" data-price="${p.price + 5000}" onclick="selectSize(this, 'm-prod-${p.id}')" ${disabledAttr}>Ly lớn<br>${(p.price + 5000).toLocaleString('vi-VN')}đ</button>
                        </div>
                        <div class="mcard-footer">
                            <span class="mcard-price" id="m-price-m-prod-${p.id}">${p.price.toLocaleString('vi-VN')}đ</span>
                            ${btnHtml}
                        </div>
                    </div>
                `;
                grid.appendChild(article);
            });
        }
    </script>
    <script src="../js/cart.js?v=20260614"></script>
    <script src="../js/menu.js?v=20260614"></script>
    <script src="../js/main.js?v=20260614"></script>
</body>
</html>

