<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="true" %>
<%
    com.mycompany.bakery.business.User adminUser = (com.mycompany.bakery.business.User) session.getAttribute("user");
    if (adminUser == null || !"ADMIN".equals(adminUser.getRole())) {
        response.sendRedirect("admin_login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bảng Quản Trị Đơn Hàng – Bánh Mì Anh Tú</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@300;400;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/style.css">
    <style>
        :root {
            --bg-dashboard: #F1F5F9;
            --sidebar-width: 260px;
            --text-dark: #0F172A;
            --text-muted: #64748B;
            --border-light: #E2E8F0;
        }
        body {
            background-color: var(--bg-dashboard);
            color: var(--text-dark);
            font-family: 'Nunito', sans-serif;
            margin: 0;
            display: flex;
            min-height: 100vh;
        }
        h1, h2, h3, h4, h5, h6 {
            font-family: 'Nunito', sans-serif;
        }
        
        /* SIDEBAR */
        .sidebar {
            width: var(--sidebar-width);
            background: #1E293B;
            color: var(--white);
            display: flex;
            flex-direction: column;
            position: fixed;
            top: 0; bottom: 0; left: 0;
            z-index: 10;
        }
        .sidebar-brand {
            padding: var(--space-xl);
            display: flex;
            align-items: center;
            gap: var(--space-md);
            border-bottom: 1px solid #334155;
        }
        .sidebar-logo {
            width: 40px; height: 40px;
            border-radius: 50%;
            border: 2px solid var(--amber);
            object-fit: cover;
        }
        .sidebar-brand-name {
            font-weight: 900;
            font-size: 1.15rem;
            letter-spacing: 0.5px;
            color: var(--amber);
        }
        .sidebar-menu {
            padding: var(--space-lg) 0;
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 4px;
        }
        .menu-item {
            display: flex;
            align-items: center;
            gap: var(--space-md);
            padding: 0.85rem var(--space-xl);
            color: #94A3B8;
            text-decoration: none;
            font-weight: 700;
            font-size: 0.95rem;
            border-left: 4px solid transparent;
            transition: all var(--transition);
        }
        .menu-item:hover, .menu-item.active {
            color: var(--white);
            background: #334155;
            border-left-color: var(--amber);
        }
        .sidebar-footer {
            padding: var(--space-lg) var(--space-xl);
            border-top: 1px solid #334155;
        }
        .user-info {
            font-size: 0.85rem;
            color: #94A3B8;
            margin-bottom: var(--space-sm);
            font-weight: 600;
        }
        .btn-logout {
            display: inline-flex;
            align-items: center;
            gap: var(--space-xs);
            color: #F87171;
            text-decoration: none;
            font-weight: 800;
            font-size: 0.9rem;
            transition: color var(--transition);
        }
        .btn-logout:hover {
            color: #EF4444;
        }

        /* MAIN CONTENT CONTAINER */
        .main-content {
            margin-left: var(--sidebar-width);
            flex: 1;
            padding: var(--space-2xl);
            box-sizing: border-box;
            max-width: calc(100% - var(--sidebar-width));
        }

        .dashboard-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: var(--space-2xl);
        }
        .dashboard-title {
            font-size: 1.75rem;
            font-weight: 900;
            color: var(--brown-deep);
            margin: 0;
        }
        .date-display {
            font-weight: 700;
            color: var(--text-muted);
            font-size: 0.95rem;
        }

        /* STATS CARDS */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: var(--space-xl);
            margin-bottom: var(--space-2xl);
        }
        .stat-card {
            background: var(--white);
            border-radius: var(--radius-lg);
            padding: var(--space-xl);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);
            border: 1px solid var(--border-light);
            display: flex;
            flex-direction: column;
            gap: var(--space-xs);
            position: relative;
            overflow: hidden;
        }
        .stat-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0; height: 4px;
            background: var(--gray-mid);
        }
        .stat-card.primary::before { background: var(--amber); }
        .stat-card.success::before { background: #10B981; }
        .stat-card.danger::before { background: #EF4444; }
        
        .stat-label {
            font-size: 0.85rem;
            font-weight: 800;
            text-transform: uppercase;
            color: var(--text-muted);
            letter-spacing: 0.5px;
        }
        .stat-val {
            font-size: 1.75rem;
            font-weight: 900;
            color: var(--text-dark);
        }

        /* ORDERS BOARD */
        .board-card {
            background: var(--white);
            border-radius: var(--radius-xl);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);
            border: 1px solid var(--border-light);
            overflow: hidden;
        }
        .board-toolbar {
            padding: var(--space-xl);
            border-bottom: 1px solid var(--border-light);
            display: flex;
            flex-wrap: wrap;
            justify-content: space-between;
            align-items: center;
            gap: var(--space-md);
            background-color: #FAF8F5;
        }
        .search-wrap {
            position: relative;
            max-width: 320px;
            width: 100%;
        }
        .search-input {
            width: 100%;
            padding: 0.65rem 1rem;
            border: 2px solid var(--cream-dark);
            border-radius: var(--radius-md);
            font-size: 0.9rem;
            font-family: inherit;
            color: var(--text-dark);
        }
        .search-input:focus {
            outline: none;
            border-color: var(--amber);
        }

        .filter-tabs {
            display: flex;
            gap: var(--space-xs);
            overflow-x: auto;
        }
        .filter-tab {
            background: transparent;
            border: none;
            padding: 0.5rem 1rem;
            font-weight: 800;
            font-size: 0.85rem;
            color: var(--text-muted);
            border-radius: var(--radius-md);
            cursor: pointer;
            transition: all var(--transition);
        }
        .filter-tab:hover {
            color: var(--text-dark);
            background: #F1F5F9;
        }
        .filter-tab.active {
            color: var(--white);
            background: var(--brown-deep);
        }

        /* TABLE */
        .table-responsive {
            width: 100%;
            overflow-x: auto;
        }
        .orders-table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
            font-size: 0.9rem;
        }
        .orders-table th {
            background-color: #FAF8F5;
            color: var(--text-muted);
            font-weight: 800;
            padding: 1rem var(--space-lg);
            border-bottom: 2px solid var(--border-light);
            text-transform: uppercase;
            font-size: 0.75rem;
            letter-spacing: 0.5px;
        }
        .orders-table td {
            padding: 1rem var(--space-lg);
            border-bottom: 1px solid var(--border-light);
            vertical-align: middle;
        }
        .orders-table tr:hover {
            background-color: #FAFBFD;
        }
        
        .order-id-td {
            font-weight: 800;
            color: var(--brown-deep);
        }
        .customer-info-td div {
            font-weight: 700;
        }
        .customer-info-td span {
            color: var(--text-muted);
            font-size: 0.8rem;
            font-weight: 600;
        }
        .badge {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            border-radius: var(--radius-full);
            font-weight: 800;
            font-size: 0.75rem;
        }
        .badge-pickup { background-color: #E0F2FE; color: #0369A1; }
        .badge-ship { background-color: #EDE9FE; color: #5B21B6; }

        /* Dropdowns for status in tables */
        .status-select {
            padding: 0.35rem 0.75rem;
            border: 2px solid var(--cream-dark);
            border-radius: var(--radius-md);
            font-family: inherit;
            font-weight: 800;
            font-size: 0.82rem;
            cursor: pointer;
            outline: none;
            transition: all var(--transition);
        }
        .status-select:focus {
            border-color: var(--amber);
        }
        
        .status-select.opt-pending { background: #FEF3C7; color: #92400E; border-color: #FCD34D; }
        .status-select.opt-preparing { background: #FEF3C7; color: #92400E; border-color: #FCD34D; }
        .status-select.opt-ready { background: #DBEAFE; color: #1E40AF; border-color: #93C5FD; }
        .status-select.opt-delivering { background: #EDE9FE; color: #6D28D9; border-color: #C4B5FD; }
        .status-select.opt-completed { background: #D1FAE5; color: #065F46; border-color: #6EE7B7; }
        .status-select.opt-cancelled { background: #FEE2E2; color: #991B1B; border-color: #FCA5A5; }

        .btn-action {
            background-color: var(--cream-dark);
            color: var(--brown-deep);
            border: none;
            padding: 0.4rem 0.8rem;
            border-radius: var(--radius-md);
            font-weight: 800;
            font-size: 0.8rem;
            cursor: pointer;
            transition: all var(--transition);
        }
        .btn-action:hover {
            background-color: var(--amber);
            color: var(--brown-bark);
        }

        /* MODAL OVERLAY */
        .modal-overlay {
            position: fixed;
            top: 0; bottom: 0; left: 0; right: 0;
            background: rgba(15, 23, 42, 0.6);
            backdrop-filter: blur(4px);
            z-index: 100;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: var(--space-lg);
            transition: opacity 0.3s ease;
        }
        .modal-card {
            background: var(--white);
            border-radius: var(--radius-xl);
            max-width: 580px;
            width: 100%;
            border: 2px solid var(--amber);
            box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25);
            animation: zoomIn 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
            overflow: hidden;
        }
        @keyframes zoomIn {
            from { transform: scale(0.95); opacity: 0; }
            to { transform: scale(1); opacity: 1; }
        }
        .modal-header {
            background: var(--brown-deep);
            padding: var(--space-lg) var(--space-xl);
            display: flex;
            align-items: center;
            justify-content: space-between;
            color: var(--white);
        }
        .modal-title {
            font-size: 1.25rem;
            font-weight: 900;
            margin: 0;
            color: var(--amber);
        }
        .modal-close {
            background: transparent;
            border: none;
            color: var(--white);
            font-size: 1.25rem;
            cursor: pointer;
        }
        .modal-body {
            padding: var(--space-xl);
            max-height: 70vh;
            overflow-y: auto;
        }
        .modal-info-row {
            display: flex;
            justify-content: space-between;
            padding: var(--space-sm) 0;
            border-bottom: 1px solid var(--border-light);
            font-size: 0.9rem;
            font-weight: 600;
        }
        .modal-info-label {
            color: var(--text-muted);
        }
        .modal-info-val {
            color: var(--text-dark);
            text-align: right;
        }
        .modal-items-title {
            font-weight: 800;
            color: var(--brown-deep);
            margin: var(--space-lg) 0 var(--space-xs);
            font-size: 0.95rem;
        }
        .modal-item-row {
            display: flex;
            justify-content: space-between;
            padding: var(--space-xs) 0;
            font-size: 0.88rem;
            border-bottom: 1px dashed var(--cream-dark);
            font-weight: 700;
        }
        .modal-item-total {
            display: flex;
            justify-content: space-between;
            font-weight: 900;
            font-size: 1.1rem;
            color: var(--red-dark);
            padding-top: var(--space-md);
            margin-top: var(--space-md);
            border-top: 2px solid var(--cream-dark);
        }

        .toast {
            position: fixed;
            bottom: var(--space-xl);
            right: var(--space-xl);
            background: #065F46;
            color: var(--white);
            padding: 0.85rem 1.5rem;
            border-radius: var(--radius-md);
            font-weight: 800;
            box-shadow: var(--shadow-hover);
            z-index: 200;
            transform: translateY(100px);
            opacity: 0;
            transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
        }
        .toast.show {
            transform: translateY(0);
            opacity: 1;
        }

        .hidden { display: none !important; }
        .text-center { text-align: center; }
        .p-4 { padding: var(--space-xl); }
        .text-muted { color: var(--text-muted); font-weight: 600; }
    </style>
</head>
<body>

    <!-- SIDEBAR -->
    <aside class="sidebar">
        <div class="sidebar-brand">
            <img src="../images/logo.png" alt="Logo" class="sidebar-logo">
            <span class="sidebar-brand-name">Anh Tú Bakery</span>
        </div>
        <nav class="sidebar-menu">
            <a href="admin_dashboard.jsp" class="menu-item active">🛒 Đơn hàng lẻ</a>
            <a href="admin_agents.jsp" class="menu-item">📦 Đại lý sỉ</a>
            <a href="admin_customers.jsp" class="menu-item">👥 Khách hàng</a>
            <a href="admin_menu.jsp" class="menu-item">🥖 Thực đơn</a>
            <a href="index.jsp" class="menu-item">🏠 Vào Trang chủ</a>
        </nav>
        <div class="sidebar-footer">
            <div class="user-info">👤 <%= adminUser.getFullname() %></div>
            <a href="../auth/logout" class="btn-logout">🚪 Đăng xuất</a>
        </div>
    </aside>

    <!-- MAIN CONTENT -->
    <main class="main-content">
        <div class="dashboard-header">
            <div>
                <h1 class="dashboard-title">Quản Lý Đơn Hàng</h1>
                <div class="date-display" id="date-display">--/--/----</div>
            </div>
        </div>

        <!-- STATS BAR -->
        <section class="stats-grid">
            <div class="stat-card primary">
                <span class="stat-label">Tổng đơn hàng</span>
                <span class="stat-val" id="stat-total-orders">0</span>
            </div>
            <div class="stat-card primary">
                <span class="stat-label">Đang chế biến</span>
                <span class="stat-val" id="stat-preparing-orders">0</span>
            </div>
            <div class="stat-card success">
                <span class="stat-label">Doanh thu hoàn thành</span>
                <span class="stat-val" id="stat-revenue">0đ</span>
            </div>
        </section>

        <!-- ORDERS BOARD -->
        <section class="board-card">
            <div class="board-toolbar">
                <div class="filter-tabs">
                    <button class="filter-tab active" data-filter="ALL">Tất cả</button>
                    <button class="filter-tab" data-filter="PENDING">Chờ xử lý</button>
                    <button class="filter-tab" data-filter="PREPARING">Chuẩn bị</button>
                    <button class="filter-tab" data-filter="READY">Sẵn sàng</button>
                    <button class="filter-tab" data-filter="DELIVERING">Đang giao</button>
                    <button class="filter-tab" data-filter="COMPLETED">Hoàn thành</button>
                    <button class="filter-tab" data-filter="CANCELLED">Đã hủy</button>
                </div>
                <div class="search-wrap">
                    <input type="text" id="search-input" class="search-input" placeholder="Tìm tên, SĐT hoặc mã đơn...">
                </div>
            </div>

            <div class="table-responsive">
                <table class="orders-table">
                    <thead>
                        <tr>
                            <th>Mã Đơn</th>
                            <th>Ngày Đặt</th>
                            <th>Khách Hàng</th>
                            <th>Hình Thức</th>
                            <th>Tổng Tiền</th>
                            <th>Trạng Thái</th>
                            <th>Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody id="orders-tbody">
                        <tr>
                            <td colspan="7" class="text-center p-4 text-muted">⏳ Đang tải dữ liệu đơn hàng...</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </section>
    </main>

    <!-- DETAILS MODAL -->
    <div class="modal-overlay hidden" id="details-modal" onclick="closeDetailsModal(event)">
        <div class="modal-card" onclick="event.stopPropagation()">
            <div class="modal-header">
                <h2 class="modal-title" id="modal-order-id">#DH00000000</h2>
                <button class="modal-close" onclick="closeDetailsModal(null)">✕</button>
            </div>
            <div class="modal-body">
                <div class="modal-info-row"><span class="modal-info-label">👤 Khách hàng</span><span class="modal-info-val" id="m-customer-name">--</span></div>
                <div class="modal-info-row"><span class="modal-info-label">📞 Điện thoại</span><span class="modal-info-val" id="m-customer-phone">--</span></div>
                <div class="modal-info-row"><span class="modal-info-label">📦 Hình thức</span><span class="modal-info-val" id="m-delivery-method">--</span></div>
                <div class="modal-info-row hidden" id="m-address-row"><span class="modal-info-label">📍 Địa chỉ</span><span class="modal-info-val" id="m-delivery-address">--</span></div>
                <div class="modal-info-row hidden" id="m-pickup-row"><span class="modal-info-label">⏰ Khung giờ lấy</span><span class="modal-info-val" id="m-pickup-time">--</span></div>
                <div class="modal-info-row"><span class="modal-info-label">📅 Ngày tạo</span><span class="modal-info-val" id="m-created-at">--</span></div>
                <div class="modal-info-row hidden" id="m-note-row"><span class="modal-info-label">📝 Ghi chú</span><span class="modal-info-val" id="m-note" style="color: var(--red-dark); font-weight: bold;">--</span></div>
                
                <h3 class="modal-items-title">🥖 Món ăn đã đặt</h3>
                <div id="modal-items-list">
                    <!-- Populated dynamically -->
                </div>
                
                <div class="modal-info-row" style="margin-top:12px;"><span class="modal-info-label">Tiền hàng</span><span class="modal-info-val" id="m-subtotal">0đ</span></div>
                <div class="modal-info-row"><span class="modal-info-label">Phí giao hàng</span><span class="modal-info-val" id="m-shipping-fee">0đ</span></div>
                <div class="modal-item-total">
                    <span>TỔNG THANH TOÁN</span>
                    <span id="m-total">0đ</span>
                </div>
            </div>
        </div>
    </div>

    <!-- TOAST NOTIFICATION -->
    <div class="toast" id="toast">Cập nhật thành công!</div>

    <script>
        let allOrders = [];
        let currentFilter = 'ALL';
        let searchQuery = '';

        // Formatter helper
        function formatVND(amount) {
            return amount.toLocaleString('vi-VN') + 'đ';
        }

        // Set date
        document.getElementById('date-display').textContent = new Date().toLocaleDateString('vi-VN', {
            weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'
        });

        // Initialize and load
        document.addEventListener('DOMContentLoaded', () => {
            loadOrders();
            setupFilters();
            setupSearch();
        });

        function loadOrders() {
            fetch('../resources/orders')
            .then(res => {
                if (!res.ok) throw new Error('Không thể tải danh sách đơn hàng');
                return res.json();
            })
            .then(data => {
                allOrders = data || [];
                updateStats();
                renderOrdersTable();
            })
            .catch(err => {
                console.error(err);
                document.getElementById('orders-tbody').innerHTML = `
                    <tr>
                        <td colspan="7" class="text-center p-4" style="color:var(--red-dark)">
                            ⚠️ Lỗi tải dữ liệu: ${err.message}
                        </td>
                    </tr>`;
            });
        }

        function updateStats() {
            document.getElementById('stat-total-orders').textContent = allOrders.length;
            
            const prepCount = allOrders.filter(o => o.status === 'PREPARING' || o.status === 'PENDING').length;
            document.getElementById('stat-preparing-orders').textContent = prepCount;

            const revenue = allOrders
                .filter(o => o.status === 'COMPLETED')
                .reduce((sum, o) => sum + o.total, 0);
            document.getElementById('stat-revenue').textContent = formatVND(revenue);
        }

        function setupFilters() {
            document.querySelectorAll('.filter-tab').forEach(tab => {
                tab.addEventListener('click', () => {
                    document.querySelectorAll('.filter-tab').forEach(t => t.classList.remove('active'));
                    tab.classList.add('active');
                    currentFilter = tab.dataset.filter;
                    renderOrdersTable();
                });
            });
        }

        function setupSearch() {
            document.getElementById('search-input').addEventListener('input', (e) => {
                searchQuery = e.target.value.toLowerCase().trim();
                renderOrdersTable();
            });
        }

        function renderOrdersTable() {
            const tbody = document.getElementById('orders-tbody');
            
            // Filter orders
            let filtered = allOrders;
            
            if (currentFilter !== 'ALL') {
                filtered = filtered.filter(o => o.status === currentFilter);
            }
            
            if (searchQuery) {
                filtered = filtered.filter(o => 
                    o.id.toLowerCase().includes(searchQuery) ||
                    o.customerName.toLowerCase().includes(searchQuery) ||
                    o.customerPhone.includes(searchQuery)
                );
            }

            if (filtered.length === 0) {
                tbody.innerHTML = `<tr><td colspan="7" class="text-center p-4 text-muted">Không tìm thấy đơn hàng nào.</td></tr>`;
                return;
            }

            tbody.innerHTML = '';
            filtered.forEach(order => {
                const tr = document.createElement('tr');
                
                let methodBadge = '';
                if (order.deliveryMethod === 'TU_LAY') {
                    const pickupTimeMap = {
                        SANG_SOM: '5:30–7:00',
                        SANG: '7:00–9:00',
                        TRUA: '11:00–13:00',
                        CHIEU: '14:00–17:00'
                    };
                    const timeLabel = pickupTimeMap[order.pickupTime] || order.pickupTime || 'Tự do';
                    methodBadge = `
                        <div style="display:flex; flex-direction:column; gap:4px; align-items:flex-start;">
                            <span class="badge badge-pickup">🏠 Tự đến lấy</span>
                            <span style="font-size:0.8rem; font-weight:800; color:var(--red-dark); background:rgba(185,28,28,0.06); padding:2px 8px; border-radius:4px; border:1px solid rgba(185,28,28,0.1);">⏱ ${timeLabel}</span>
                        </div>
                    `;
                } else {
                    methodBadge = '<span class="badge badge-ship">🚴 Giao tận nhà</span>';
                }

                // Dropdown status options
                const statusOptions = `
                    <select class="status-select opt-${order.status.toLowerCase()}" onchange="updateStatus('${order.id}', this.value, this)">
                        <option value="PENDING" ${order.status === 'PENDING' ? 'selected' : ''}>⏳ Chờ xử lý</option>
                        <option value="PREPARING" ${order.status === 'PREPARING' ? 'selected' : ''}>🍳 Chuẩn bị</option>
                        <option value="READY" ${order.status === 'READY' ? 'selected' : ''}>✅ Sẵn sàng</option>
                        <option value="DELIVERING" ${order.status === 'DELIVERING' ? 'selected' : ''}>🚴 Đang giao</option>
                        <option value="COMPLETED" ${order.status === 'COMPLETED' ? 'selected' : ''}>🎉 Hoàn thành</option>
                        <option value="CANCELLED" ${order.status === 'CANCELLED' ? 'selected' : ''}>❌ Đã hủy</option>
                    </select>
                `;

                tr.innerHTML = `
                    <td class="order-id-td">#${order.id}</td>
                    <td style="font-weight:600;color:var(--text-muted)">${order.createdAt}</td>
                    <td class="customer-info-td">
                        <div>${order.customerName}</div>
                        <span>📞 ${order.customerPhone}</span>
                    </td>
                    <td>${methodBadge}</td>
                    <td style="font-weight:800;color:var(--red-dark)">${formatVND(order.total)}</td>
                    <td>${statusOptions}</td>
                    <td>
                        <button class="btn-action" onclick="viewOrderDetails('${order.id}')">Chi tiết</button>
                    </td>
                `;
                tbody.appendChild(tr);
            });
        }

        function updateStatus(orderId, newStatus, selectElement) {
            // Update select classes dynamically
            selectElement.className = `status-select opt-${newStatus.toLowerCase()}`;

            const url = `../resources/orders/${orderId}/status?status=${newStatus}`;
            
            fetch(url, {
                method: 'POST'
            })
            .then(res => {
                if (!res.ok) throw new Error('Không thể cập nhật trạng thái');
                return res.json();
            })
            .then(data => {
                // Update local status
                const order = allOrders.find(o => o.id === orderId);
                if (order) order.status = newStatus;
                
                updateStats();
                showToast(`✅ Đã cập nhật đơn #${orderId} thành "${newStatus}"`);
            })
            .catch(err => {
                console.error(err);
                showToast(`⚠️ Lỗi: ${err.message}`, 'warn');
                loadOrders(); // reload
            });
        }

        function viewOrderDetails(orderId) {
            const order = allOrders.find(o => o.id === orderId);
            if (!order) return;

            document.getElementById('modal-order-id').textContent = '#' + order.id;
            document.getElementById('m-customer-name').textContent = order.customerName;
            document.getElementById('m-customer-phone').textContent = order.customerPhone;
            
            const methodLabel = order.deliveryMethod === 'TU_LAY' ? '🏠 Tự đến lấy' : '🚴 Giao hàng tận nơi';
            document.getElementById('m-delivery-method').textContent = methodLabel;
            document.getElementById('m-created-at').textContent = order.createdAt;

            // Render Notes
            const noteRow = document.getElementById('m-note-row');
            if (order.note && order.note.trim() !== '') {
                noteRow.classList.remove('hidden');
                document.getElementById('m-note').textContent = order.note;
            } else {
                noteRow.classList.add('hidden');
            }

            // Delivery Address or Pickup time logic
            const addrRow = document.getElementById('m-address-row');
            const pickupRow = document.getElementById('m-pickup-row');
            
            if (order.deliveryMethod === 'GIAO_HANG') {
                addrRow.classList.remove('hidden');
                pickupRow.classList.add('hidden');
                document.getElementById('m-delivery-address').textContent = order.deliveryAddress || 'Chưa nhập';
            } else {
                addrRow.classList.add('hidden');
                pickupRow.classList.remove('hidden');
                
                const pickupTimeMap = {
                    SANG_SOM: 'Sáng sớm (5:30–7:00)',
                    SANG: 'Buổi sáng (7:00–9:00)',
                    TRUA: 'Buổi trưa (11:00–13:00)',
                    CHIEU: 'Buổi chiều (14:00–17:00)'
                };
                document.getElementById('m-pickup-time').textContent = pickupTimeMap[order.pickupTime] || order.pickupTime || 'Tự do';
            }

            // Render items list
            const listContainer = document.getElementById('modal-items-list');
            listContainer.innerHTML = '';
            
            if (order.items && order.items.length > 0) {
                order.items.forEach(item => {
                    const row = document.createElement('div');
                    row.className = 'modal-item-row';
                    row.innerHTML = `
                        <span>${item.name} ×${item.qty}</span>
                        <span>${formatVND(item.price * item.qty)}</span>
                    `;
                    listContainer.appendChild(row);
                });
            } else {
                listContainer.innerHTML = '<div style="color:var(--text-muted);font-style:italic">Không có chi tiết mặt hàng</div>';
            }

            document.getElementById('m-subtotal').textContent = formatVND(order.subtotal);
            document.getElementById('m-shipping-fee').textContent = order.shippingFee > 0 ? formatVND(order.shippingFee) : 'Miễn phí';
            document.getElementById('m-total').textContent = formatVND(order.total);

            document.getElementById('details-modal').classList.remove('hidden');
        }

        function closeDetailsModal(e) {
            if (e === null || e.target.id === 'details-modal') {
                document.getElementById('details-modal').classList.add('hidden');
            }
        }

        let toastTimer;
        function showToast(msg, type = 'success') {
            const toast = document.getElementById('toast');
            toast.textContent = msg;
            toast.className = 'toast show';
            if (type === 'warn') {
                toast.style.background = '#991B1B';
            } else {
                toast.style.background = '#065F46';
            }
            clearTimeout(toastTimer);
            toastTimer = setTimeout(() => {
                toast.className = 'toast';
            }, 3000);
        }
    </script>
</body>
</html>
