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
    <title>Quản Lý Đại Lý – Bánh Mì Anh Tú</title>
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
        .btn-logout:hover {
            color: #EF4444;
        }

        /* MAIN CONTENT */
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

        /* BOARD CARD */
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
        .agents-table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
            font-size: 0.9rem;
        }
        .agents-table th {
            background-color: #FAF8F5;
            color: var(--text-muted);
            font-weight: 800;
            padding: 1rem var(--space-lg);
            border-bottom: 2px solid var(--border-light);
            text-transform: uppercase;
            font-size: 0.75rem;
            letter-spacing: 0.5px;
        }
        .agents-table td {
            padding: 1rem var(--space-lg);
            border-bottom: 1px solid var(--border-light);
            vertical-align: middle;
        }
        .agents-table tr:hover {
            background-color: #FAFBFD;
        }

        .agent-shop {
            font-weight: 800;
            color: var(--brown-deep);
            font-size: 0.95rem;
        }
        .agent-name {
            font-weight: 700;
            font-size: 0.88rem;
        }
        .agent-contact span {
            color: var(--text-muted);
            font-size: 0.8rem;
            font-weight: 600;
        }
        .agent-location {
            max-width: 220px;
            font-size: 0.82rem;
            font-weight: 600;
        }
        .agent-gps {
            font-family: monospace;
            font-size: 0.75rem;
            color: var(--text-muted);
            margin-top: 2px;
        }

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
        .status-select.opt-active { background: #D1FAE5; color: #065F46; border-color: #6EE7B7; }
        .status-select.opt-suspended { background: #FEE2E2; color: #991B1B; border-color: #FCA5A5; }

        .btn-delete {
            background-color: #FEE2E2;
            color: #EF4444;
            border: none;
            padding: 0.4rem 0.8rem;
            border-radius: var(--radius-md);
            font-weight: 800;
            font-size: 0.8rem;
            cursor: pointer;
            transition: all var(--transition);
        }
        .btn-delete:hover {
            background-color: #EF4444;
            color: var(--white);
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
            <a href="admin_dashboard.jsp" class="menu-item">🛒 Đơn hàng lẻ</a>
            <a href="admin_agents.jsp" class="menu-item active">📦 Đại lý sỉ</a>
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
                <h1 class="dashboard-title">Quản Lý Đại Lý Sỉ</h1>
            </div>
        </div>

        <!-- AGENTS BOARD -->
        <section class="board-card">
            <div class="board-toolbar">
                <div class="filter-tabs">
                    <button class="filter-tab active" data-filter="ALL">Tất cả</button>
                    <button class="filter-tab" data-filter="PENDING">Chờ xử lý</button>
                    <button class="filter-tab" data-filter="ACTIVE">Hoạt động</button>
                    <button class="filter-tab" data-filter="SUSPENDED">Tạm khóa</button>
                </div>
                <div class="search-wrap">
                    <input type="text" id="search-input" class="search-input" placeholder="Tìm tên, SĐT hoặc cửa hàng...">
                </div>
            </div>

            <div class="table-responsive">
                <table class="agents-table">
                    <thead>
                        <tr>
                            <th>Đại Lý</th>
                            <th>Người Đại Diện</th>
                            <th>Liên Hệ</th>
                            <th>Địa Chỉ Giao Hàng</th>
                            <th>Ngày Đăng Ký</th>
                            <th>Trạng Thái</th>
                            <th>Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody id="agents-tbody">
                        <tr>
                            <td colspan="7" class="text-center p-4 text-muted">⏳ Đang tải danh sách đại lý...</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </section>
    </main>

    <!-- TOAST NOTIFICATION -->
    <div class="toast" id="toast">Cập nhật thành công!</div>

    <script>
        let allAgents = [];
        let currentFilter = 'ALL';
        let searchQuery = '';

        document.addEventListener('DOMContentLoaded', () => {
            loadAgents();
            setupFilters();
            setupSearch();
        });

        function loadAgents() {
            fetch('../resources/agents')
            .then(res => {
                if (!res.ok) throw new Error('Không thể tải danh sách đại lý');
                return res.json();
            })
            .then(data => {
                allAgents = data || [];
                renderAgentsTable();
            })
            .catch(err => {
                console.error(err);
                document.getElementById('agents-tbody').innerHTML = `
                    <tr>
                        <td colspan="7" class="text-center p-4" style="color:var(--red-dark)">
                            ⚠️ Lỗi tải dữ liệu: ${err.message}
                        </td>
                    </tr>`;
            });
        }

        function setupFilters() {
            document.querySelectorAll('.filter-tab').forEach(tab => {
                tab.addEventListener('click', () => {
                    document.querySelectorAll('.filter-tab').forEach(t => t.classList.remove('active'));
                    tab.classList.add('active');
                    currentFilter = tab.dataset.filter;
                    renderAgentsTable();
                });
            });
        }

        function setupSearch() {
            document.getElementById('search-input').addEventListener('input', (e) => {
                searchQuery = e.target.value.toLowerCase().trim();
                renderAgentsTable();
            });
        }

        function renderAgentsTable() {
            const tbody = document.getElementById('agents-tbody');
            
            let filtered = allAgents;
            
            if (currentFilter !== 'ALL') {
                filtered = filtered.filter(a => a.status === currentFilter);
            }
            
            if (searchQuery) {
                filtered = filtered.filter(a => 
                    a.name.toLowerCase().includes(searchQuery) ||
                    a.shopName.toLowerCase().includes(searchQuery) ||
                    a.phone.includes(searchQuery)
                );
            }

            if (filtered.length === 0) {
                tbody.innerHTML = `<tr><td colspan="7" class="text-center p-4 text-muted">Không tìm thấy đại lý nào.</td></tr>`;
                return;
            }

            tbody.innerHTML = '';
            filtered.forEach(a => {
                const tr = document.createElement('tr');
                
                const statusOptions = `
                    <select class="status-select opt-${a.status.toLowerCase()}" onchange="updateAgentStatus(${a.id}, this.value, this)">
                        <option value="PENDING" ${a.status === 'PENDING' ? 'selected' : ''}>⏳ Chờ xử lý</option>
                        <option value="ACTIVE" ${a.status === 'ACTIVE' ? 'selected' : ''}>✅ Hoạt động</option>
                        <option value="SUSPENDED" ${a.status === 'SUSPENDED' ? 'selected' : ''}>❌ Tạm khóa</option>
                    </select>
                `;

                tr.innerHTML = `
                    <td class="agent-shop">${a.shopName}</td>
                    <td class="agent-name">${a.name}</td>
                    <td class="agent-contact">
                        <div>📞 ${a.phone}</div>
                    </td>
                    <td class="agent-location">
                        <div>${a.address}</div>
                        <div class="agent-gps">📍 GPS: ${a.latitude.toFixed(6)}, ${a.longitude.toFixed(6)}</div>
                    </td>
                    <td style="font-weight:600;color:var(--text-muted)">${a.createdAt}</td>
                    <td>${statusOptions}</td>
                    <td>
                        <button class="btn-delete" onclick="deleteAgent(${a.id}, '${a.shopName.replace(/'/g, "\\'")}')">Xóa</button>
                    </td>
                `;
                tbody.appendChild(tr);
            });
        }

        function updateAgentStatus(id, newStatus, selectElement) {
            selectElement.className = `status-select opt-${newStatus.toLowerCase()}`;
            
            fetch(`../resources/agents/${id}/status?status=${newStatus}`, {
                method: 'POST'
            })
            .then(res => {
                if (!res.ok) throw new Error('Cập nhật trạng thái thất bại');
                return res.json();
            })
            .then(data => {
                const agent = allAgents.find(a => a.id === id);
                if (agent) agent.status = newStatus;
                showToast(`✅ Đã cập nhật đại lý sang trạng thái "${newStatus}"!`);
            })
            .catch(err => {
                alert('Lỗi: ' + err.message);
                loadAgents();
            });
        }

        function deleteAgent(id, shopName) {
            if (!confirm(`Bạn có chắc chắn muốn xóa đại lý "${shopName}" khỏi hệ thống không?`)) {
                return;
            }

            fetch(`../resources/agents/${id}`, {
                method: 'DELETE'
            })
            .then(res => {
                if (!res.ok) throw new Error('Xóa đại lý thất bại');
                showToast('✅ Đã xóa đại lý thành công!');
                loadAgents();
            })
            .catch(err => {
                alert('Lỗi: ' + err.message);
            });
        }

        let toastTimer;
        function showToast(msg) {
            const toast = document.getElementById('toast');
            toast.textContent = msg;
            toast.className = 'toast show';
            clearTimeout(toastTimer);
            toastTimer = setTimeout(() => {
                toast.className = 'toast';
            }, 3000);
        }
    </script>
</body>
</html>
