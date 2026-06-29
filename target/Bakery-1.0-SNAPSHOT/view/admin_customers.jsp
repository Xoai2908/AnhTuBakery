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
    <title>Quản Lý Khách Hàng – Bánh Mì Anh Tú</title>
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
        .btn-logout:hover { color: #EF4444; }

        /* MAIN CONTENT */
        .main-content {
            margin-left: var(--sidebar-width);
            flex: 1;
            padding: var(--space-2xl);
            box-sizing: border-box;
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

        /* STATS */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: var(--space-xl);
            margin-bottom: var(--space-2xl);
        }
        .stat-card {
            background: var(--white);
            border-radius: var(--radius-lg);
            padding: var(--space-xl);
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
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
        }
        .stat-card.primary::before { background: var(--amber); }
        .stat-card.success::before { background: #10B981; }
        .stat-card.info::before { background: #3B82F6; }
        .stat-label {
            font-size: 0.82rem;
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

        /* BOARD */
        .board-card {
            background: var(--white);
            border-radius: var(--radius-xl);
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
            border: 1px solid var(--border-light);
            overflow: hidden;
            margin-bottom: var(--space-2xl);
        }
        .board-toolbar {
            padding: var(--space-xl);
            border-bottom: 1px solid var(--border-light);
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: var(--space-md);
            background-color: #FAF8F5;
            flex-wrap: wrap;
        }
        .board-title {
            font-weight: 900;
            font-size: 1.1rem;
            color: var(--brown-deep);
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
            box-sizing: border-box;
        }
        .search-input:focus {
            outline: none;
            border-color: var(--amber);
        }

        /* TABLE */
        .table-responsive {
            width: 100%;
            overflow-x: auto;
        }
        .customers-table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
            font-size: 0.9rem;
        }
        .customers-table th {
            background-color: #FAF8F5;
            color: var(--text-muted);
            font-weight: 800;
            padding: 1rem var(--space-lg);
            border-bottom: 2px solid var(--border-light);
            text-transform: uppercase;
            font-size: 0.75rem;
            letter-spacing: 0.5px;
            white-space: nowrap;
        }
        .customers-table td {
            padding: 1rem var(--space-lg);
            border-bottom: 1px solid var(--border-light);
            vertical-align: middle;
        }
        .customers-table tr:hover { background-color: #FAFBFD; }
        .customer-name { font-weight: 800; color: var(--brown-deep); }
        .customer-sub { color: var(--text-muted); font-size: 0.8rem; font-weight: 600; }

        .badge-order-count {
            display: inline-block;
            padding: 0.2rem 0.65rem;
            background: var(--cream-light);
            border: 1px solid var(--cream-dark);
            border-radius: var(--radius-full);
            font-weight: 800;
            font-size: 0.8rem;
            color: var(--brown-deep);
        }
        .badge-order-count.has-orders {
            background: #DBEAFE;
            border-color: #93C5FD;
            color: #1E40AF;
        }

        .btn-view-history {
            background: var(--brown-deep);
            color: var(--white);
            border: none;
            padding: 0.4rem 0.9rem;
            border-radius: var(--radius-md);
            font-weight: 800;
            font-size: 0.82rem;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 4px;
            transition: all var(--transition);
        }
        .btn-view-history:hover {
            background: var(--amber);
            color: var(--brown-bark);
            transform: translateY(-1px);
        }

        /* MODAL */
        .modal-overlay {
            position: fixed;
            top: 0; bottom: 0; left: 0; right: 0;
            background: rgba(15, 23, 42, 0.65);
            backdrop-filter: blur(4px);
            z-index: 100;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: var(--space-lg);
        }
        .modal-card {
            background: var(--white);
            border-radius: var(--radius-xl);
            max-width: 760px;
            width: 100%;
            border: 2px solid var(--amber);
            box-shadow: 0 25px 50px -12px rgba(0,0,0,0.3);
            animation: zoomIn 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
            overflow: hidden;
            max-height: 90vh;
            display: flex;
            flex-direction: column;
        }
        @keyframes zoomIn {
            from { transform: scale(0.93); opacity: 0; }
            to { transform: scale(1); opacity: 1; }
        }
        .modal-header {
            background: var(--brown-deep);
            padding: var(--space-lg) var(--space-xl);
            display: flex;
            align-items: center;
            justify-content: space-between;
            color: var(--white);
            flex-shrink: 0;
        }
        .modal-title { font-size: 1.2rem; font-weight: 900; margin: 0; color: var(--amber); }
        .modal-subtitle { font-size: 0.82rem; color: #94A3B8; font-weight: 600; margin-top: 2px; }
        .modal-close {
            background: transparent;
            border: none;
            color: var(--white);
            font-size: 1.35rem;
            cursor: pointer;
            line-height: 1;
            padding: 4px;
        }
        .modal-body {
            padding: var(--space-xl);
            overflow-y: auto;
            flex: 1;
        }

        /* Customer info banner inside modal */
        .cust-info-bar {
            display: flex;
            gap: var(--space-xl);
            background: #F8FAFC;
            border: 1px solid var(--border-light);
            border-radius: var(--radius-lg);
            padding: var(--space-lg) var(--space-xl);
            margin-bottom: var(--space-xl);
            flex-wrap: wrap;
        }
        .cust-info-item { display: flex; flex-direction: column; gap: 2px; }
        .cust-info-label { font-size: 0.72rem; font-weight: 800; text-transform: uppercase; color: var(--text-muted); letter-spacing: 0.05em; }
        .cust-info-val { font-weight: 800; color: var(--brown-deep); font-size: 0.95rem; }

        /* Summary stats in modal */
        .modal-stats-row {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: var(--space-md);
            margin-bottom: var(--space-xl);
        }
        .modal-stat {
            background: var(--cream-light);
            border: 1px solid var(--cream-dark);
            border-radius: var(--radius-lg);
            padding: var(--space-md);
            text-align: center;
        }
        .modal-stat-label { font-size: 0.75rem; font-weight: 800; color: var(--text-muted); text-transform: uppercase; }
        .modal-stat-val { font-size: 1.35rem; font-weight: 900; color: var(--brown-deep); margin-top: 2px; }
        .modal-stat-val.revenue { color: #059669; }

        /* Mini order list inside modal */
        .order-mini-card {
            border: 1.5px solid var(--border-light);
            border-radius: var(--radius-lg);
            margin-bottom: var(--space-md);
            overflow: hidden;
            transition: all var(--transition);
        }
        .order-mini-card:hover {
            border-color: var(--amber);
            box-shadow: 0 4px 8px rgba(0,0,0,0.06);
        }
        .order-mini-header {
            background: #FAF8F5;
            padding: var(--space-sm) var(--space-lg);
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid var(--border-light);
            flex-wrap: wrap;
            gap: var(--space-sm);
        }
        .order-mini-id { font-weight: 800; color: var(--brown-deep); font-size: 0.95rem; }
        .order-mini-date { color: var(--text-muted); font-size: 0.8rem; font-weight: 600; }
        .order-mini-body {
            padding: var(--space-md) var(--space-lg);
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: var(--space-sm);
        }
        .order-mini-items { font-size: 0.85rem; color: var(--text-muted); font-weight: 600; }
        .order-mini-total { font-weight: 900; color: var(--red-dark); font-size: 1rem; }

        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 0.2rem 0.65rem;
            border-radius: var(--radius-full);
            font-weight: 800;
            font-size: 0.75rem;
        }
        .s-pending   { background: #FEF3C7; color: #92400E; }
        .s-paid      { background: #D1FAE5; color: #065F46; }
        .s-preparing { background: #FEF3C7; color: #92400E; }
        .s-ready     { background: #DBEAFE; color: #1E40AF; }
        .s-delivering{ background: #EDE9FE; color: #6D28D9; }
        .s-completed { background: #D1FAE5; color: #065F46; }
        .s-cancelled { background: #FEE2E2; color: #991B1B; }

        .empty-orders-msg {
            text-align: center;
            padding: var(--space-2xl);
            color: var(--text-muted);
            font-weight: 700;
        }

        /* Toast */
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
        .toast.show { transform: translateY(0); opacity: 1; }
        .hidden { display: none !important; }
        .text-center { text-align: center; }
        .p-4 { padding: var(--space-xl); }
        .text-muted-td { color: var(--text-muted); font-weight: 600; }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(6px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .fade-in { animation: fadeIn 0.3s ease; }
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
            <a href="admin_dashboard.jsp" class="menu-item">🛒 Đơn hàng lẻ</a>
            <a href="admin_agents.jsp" class="menu-item">📦 Đại lý sỉ</a>
            <a href="admin_customers.jsp" class="menu-item active">👥 Khách hàng</a>
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
                <h1 class="dashboard-title">👥 Quản Lý Khách Hàng</h1>
                <div style="color:var(--text-muted);font-weight:600;font-size:0.9rem;margin-top:4px;">Lịch sử giao dịch và thống kê khách hàng đã đăng ký</div>
            </div>
        </div>

        <!-- STATS -->
        <section class="stats-grid">
            <div class="stat-card primary">
                <span class="stat-label">Tổng khách đăng ký</span>
                <span class="stat-val" id="stat-total">0</span>
            </div>
            <div class="stat-card success">
                <span class="stat-label">Đã từng mua hàng</span>
                <span class="stat-val" id="stat-buyers">0</span>
            </div>
            <div class="stat-card info">
                <span class="stat-label">Chưa mua hàng</span>
                <span class="stat-val" id="stat-no-orders">0</span>
            </div>
        </section>

        <!-- CUSTOMER TABLE -->
        <section class="board-card">
            <div class="board-toolbar">
                <span class="board-title">📋 Danh Sách Khách Hàng</span>
                <div class="search-wrap">
                    <input type="text" id="search-input" class="search-input" placeholder="🔍 Tìm tên, SĐT, tài khoản...">
                </div>
            </div>
            <div class="table-responsive">
                <table class="customers-table">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Khách Hàng</th>
                            <th>Số Điện Thoại</th>
                            <th>Tài Khoản</th>
                            <th>Ngày Đăng Ký</th>
                            <th>Số Đơn</th>
                            <th>Lịch Sử</th>
                        </tr>
                    </thead>
                    <tbody id="customers-tbody">
                        <tr>
                            <td colspan="7" class="text-center p-4 text-muted-td">⏳ Đang tải danh sách khách hàng...</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </section>
    </main>

    <!-- HISTORY MODAL -->
    <div class="modal-overlay hidden" id="history-modal" onclick="closeModal(event)">
        <div class="modal-card" onclick="event.stopPropagation()">
            <div class="modal-header">
                <div>
                    <h2 class="modal-title" id="modal-customer-name">Khách hàng</h2>
                    <div class="modal-subtitle" id="modal-customer-sub">Lịch sử giao dịch</div>
                </div>
                <button class="modal-close" onclick="closeModal(null)">✕</button>
            </div>
            <div class="modal-body">
                <!-- Customer info bar -->
                <div class="cust-info-bar" id="modal-cust-info">
                    <div class="cust-info-item">
                        <span class="cust-info-label">Tài khoản</span>
                        <span class="cust-info-val" id="m-username">--</span>
                    </div>
                    <div class="cust-info-item">
                        <span class="cust-info-label">Số điện thoại</span>
                        <span class="cust-info-val" id="m-phone">--</span>
                    </div>
                    <div class="cust-info-item">
                        <span class="cust-info-label">Ngày đăng ký</span>
                        <span class="cust-info-val" id="m-joined">--</span>
                    </div>
                </div>

                <!-- Summary stats -->
                <div class="modal-stats-row" id="modal-stats-row">
                    <div class="modal-stat">
                        <div class="modal-stat-label">Tổng đơn hàng</div>
                        <div class="modal-stat-val" id="m-total-orders">0</div>
                    </div>
                    <div class="modal-stat">
                        <div class="modal-stat-label">Đơn hoàn thành</div>
                        <div class="modal-stat-val" id="m-completed-orders">0</div>
                    </div>
                    <div class="modal-stat">
                        <div class="modal-stat-label">Tổng chi tiêu</div>
                        <div class="modal-stat-val revenue" id="m-total-revenue">0đ</div>
                    </div>
                </div>

                <!-- Order list -->
                <div id="modal-orders-list">
                    <div style="text-align:center;padding:40px;color:var(--text-muted)">⏳ Đang tải lịch sử...</div>
                </div>
            </div>
        </div>
    </div>

    <!-- TOAST -->
    <div class="toast" id="toast"></div>

    <script>
        let allCustomers = [];
        let searchQuery = '';
        let orderCountMap = {}; // userId -> count

        const STATUS_MAP = {
            PENDING:    ['⏳', 'Chờ xử lý',   's-pending'],
            PAID:       ['💳', 'Đã thanh toán','s-paid'],
            PREPARING:  ['🍳', 'Chuẩn bị',     's-preparing'],
            READY:      ['✅', 'Sẵn sàng',     's-ready'],
            DELIVERING: ['🚴', 'Đang giao',    's-delivering'],
            COMPLETED:  ['🎉', 'Hoàn thành',   's-completed'],
            CANCELLED:  ['❌', 'Đã hủy',       's-cancelled']
        };

        function fmt(n) { return n.toLocaleString('vi-VN') + 'đ'; }

        document.addEventListener('DOMContentLoaded', () => {
            loadCustomers();
            document.getElementById('search-input').addEventListener('input', e => {
                searchQuery = e.target.value.toLowerCase().trim();
                renderTable();
            });
        });

        function loadCustomers() {
            fetch('../resources/admin/customers')
                .then(res => {
                    if (!res.ok) throw new Error('Không thể tải danh sách khách hàng (HTTP ' + res.status + ')');
                    return res.json();
                })
                .then(data => {
                    allCustomers = data || [];
                    updateStats();
                    renderTable();
                })
                .catch(err => {
                    document.getElementById('customers-tbody').innerHTML =
                        `<tr><td colspan="7" class="text-center p-4" style="color:var(--red-dark)">⚠️ ${err.message}</td></tr>`;
                });
        }

        function updateStats() {
            document.getElementById('stat-total').textContent = allCustomers.length;
            // Buyers vs non-buyers will be computed when orders load; show placeholder for now
            document.getElementById('stat-buyers').textContent = '...';
            document.getElementById('stat-no-orders').textContent = '...';
        }

        function renderTable() {
            const tbody = document.getElementById('customers-tbody');
            let list = allCustomers;
            if (searchQuery) {
                list = list.filter(c =>
                    (c.fullname || '').toLowerCase().includes(searchQuery) ||
                    (c.username || '').toLowerCase().includes(searchQuery) ||
                    (c.phone || '').includes(searchQuery)
                );
            }
            if (list.length === 0) {
                tbody.innerHTML = `<tr><td colspan="7" class="text-center p-4 text-muted-td">Không tìm thấy khách hàng nào.</td></tr>`;
                return;
            }
            tbody.innerHTML = '';
            list.forEach((c, idx) => {
                const count = orderCountMap[c.id];
                const countHtml = count === undefined
                    ? `<span class="badge-order-count" id="cnt-${c.id}">...</span>`
                    : `<span class="badge-order-count ${count > 0 ? 'has-orders' : ''}">${count} đơn</span>`;
                const phoneDisplay = c.phone ? `📞 ${c.phone}` : `<span style="color:var(--text-muted);font-style:italic;">Chưa cập nhật</span>`;
                const tr = document.createElement('tr');
                tr.className = 'fade-in';
                tr.innerHTML = `
                    <td style="color:var(--text-muted);font-weight:700">${idx + 1}</td>
                    <td>
                        <div class="customer-name">${escHtml(c.fullname || 'Không tên')}</div>
                    </td>
                    <td>${phoneDisplay}</td>
                    <td><span class="customer-sub">@${escHtml(c.username)}</span></td>
                    <td style="color:var(--text-muted);font-weight:600;font-size:0.85rem">${c.createdAt || '--'}</td>
                    <td>${countHtml}</td>
                    <td>
                        <button class="btn-view-history" onclick="openHistoryModal(${c.id}, '${escHtml(c.fullname || c.username)}', '${escHtml(c.phone || '')}', '${escHtml(c.username)}', '${c.createdAt || ''}')">
                            📋 Xem lịch sử
                        </button>
                    </td>
                `;
                tbody.appendChild(tr);
            });

            // Lazy-load order counts
            allCustomers.forEach(c => {
                if (orderCountMap[c.id] === undefined) {
                    fetchOrderCount(c.id);
                }
            });
        }

        // Cache and fetch order counts
        function fetchOrderCount(userId) {
            fetch(`../resources/admin/customers/${userId}/orders`)
                .then(res => res.ok ? res.json() : [])
                .then(orders => {
                    orderCountMap[userId] = orders.length;
                    const el = document.getElementById('cnt-' + userId);
                    if (el) {
                        el.textContent = orders.length + ' đơn';
                        if (orders.length > 0) el.classList.add('has-orders');
                    }
                    // Update summary stats
                    const buyers = Object.values(orderCountMap).filter(v => v > 0).length;
                    const noOrders = allCustomers.length - buyers;
                    document.getElementById('stat-buyers').textContent = buyers;
                    document.getElementById('stat-no-orders').textContent = noOrders;
                })
                .catch(() => { orderCountMap[userId] = 0; });
        }

        function openHistoryModal(userId, fullname, phone, username, joinedAt) {
            // Set customer info
            document.getElementById('modal-customer-name').textContent = '👤 ' + fullname;
            document.getElementById('modal-customer-sub').textContent = 'Toàn bộ lịch sử giao dịch';
            document.getElementById('m-username').textContent = '@' + username;
            document.getElementById('m-phone').textContent = phone || 'Chưa cập nhật';
            document.getElementById('m-joined').textContent = joinedAt || '--';

            // Reset stats
            document.getElementById('m-total-orders').textContent = '...';
            document.getElementById('m-completed-orders').textContent = '...';
            document.getElementById('m-total-revenue').textContent = '...';
            document.getElementById('modal-orders-list').innerHTML =
                '<div style="text-align:center;padding:40px;color:var(--text-muted)">⏳ Đang tải lịch sử...</div>';

            document.getElementById('history-modal').classList.remove('hidden');

            // Fetch orders
            fetch(`../resources/admin/customers/${userId}/orders`)
                .then(res => res.ok ? res.json() : Promise.reject('HTTP ' + res.status))
                .then(orders => renderModalOrders(orders))
                .catch(err => {
                    document.getElementById('modal-orders-list').innerHTML =
                        `<div style="text-align:center;padding:30px;color:var(--red-dark)">⚠️ Lỗi tải dữ liệu: ${err}</div>`;
                });
        }

        function renderModalOrders(orders) {
            const container = document.getElementById('modal-orders-list');

            const totalOrders = orders.length;
            const completed = orders.filter(o => o.status === 'COMPLETED').length;
            const revenue = orders.filter(o => o.status === 'COMPLETED').reduce((s, o) => s + o.total, 0);

            document.getElementById('m-total-orders').textContent = totalOrders;
            document.getElementById('m-completed-orders').textContent = completed;
            document.getElementById('m-total-revenue').textContent = fmt(revenue);

            if (totalOrders === 0) {
                container.innerHTML = `
                    <div class="empty-orders-msg">
                        <div style="font-size:2.5rem;margin-bottom:8px">🛒</div>
                        <div>Khách hàng chưa có đơn hàng nào được liên kết.</div>
                        <div style="font-size:0.82rem;margin-top:4px;color:var(--text-muted)">(Chỉ hiển thị đơn đặt khi đã đăng nhập)</div>
                    </div>`;
                return;
            }

            container.innerHTML = '';
            orders.forEach(order => {
                const st = STATUS_MAP[order.status] || ['❓', order.status, 's-pending'];
                const itemSummary = order.items && order.items.length > 0
                    ? order.items.slice(0, 2).map(i => `${i.name} ×${i.qty}`).join(', ') + (order.items.length > 2 ? ` +${order.items.length - 2} món khác` : '')
                    : 'Không có chi tiết';
                const deliveryIcon = order.deliveryMethod === 'TU_LAY' ? '🏠 Tự lấy' : '🚴 Giao hàng';

                const card = document.createElement('div');
                card.className = 'order-mini-card fade-in';
                card.innerHTML = `
                    <div class="order-mini-header">
                        <div style="display:flex;align-items:center;gap:12px;">
                            <span class="order-mini-id">#${order.id}</span>
                            <span class="status-badge ${st[2]}">${st[0]} ${st[1]}</span>
                        </div>
                        <div style="display:flex;align-items:center;gap:12px;flex-wrap:wrap;">
                            <span style="font-size:0.8rem;color:var(--text-muted);font-weight:600">${deliveryIcon}</span>
                            <span class="order-mini-date">${order.createdAt}</span>
                        </div>
                    </div>
                    <div class="order-mini-body">
                        <div class="order-mini-items">${escHtml(itemSummary)}</div>
                        <div class="order-mini-total">${fmt(order.total)}</div>
                    </div>
                `;
                container.appendChild(card);
            });
        }

        function closeModal(e) {
            if (e === null || e.target === document.getElementById('history-modal')) {
                document.getElementById('history-modal').classList.add('hidden');
            }
        }

        function escHtml(str) {
            if (!str) return '';
            return str.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
        }

        function showToast(msg, type) {
            const t = document.getElementById('toast');
            t.textContent = msg;
            t.style.background = type === 'warn' ? '#92400E' : '#065F46';
            t.classList.add('show');
            setTimeout(() => t.classList.remove('show'), 3000);
        }
    </script>
</body>
</html>
