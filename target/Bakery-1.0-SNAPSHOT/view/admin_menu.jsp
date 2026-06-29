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
    <title>Quản Lý Thực Đơn – Bánh Mì Anh Tú</title>
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

        /* BUTTONS */
        .btn-add {
            background-color: var(--red-dark);
            color: var(--white);
            border: none;
            padding: 0.75rem 1.5rem;
            border-radius: var(--radius-md);
            font-weight: 800;
            font-size: 0.95rem;
            cursor: pointer;
            transition: all var(--transition);
            box-shadow: 0 4px 6px -1px rgba(185, 28, 28, 0.2);
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .btn-add:hover {
            background-color: var(--red-darker);
            transform: translateY(-1px);
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
        .menu-table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
            font-size: 0.9rem;
        }
        .menu-table th {
            background-color: #FAF8F5;
            color: var(--text-muted);
            font-weight: 800;
            padding: 1rem var(--space-lg);
            border-bottom: 2px solid var(--border-light);
            text-transform: uppercase;
            font-size: 0.75rem;
            letter-spacing: 0.5px;
        }
        .menu-table td {
            padding: 1rem var(--space-lg);
            border-bottom: 1px solid var(--border-light);
            vertical-align: middle;
        }
        .menu-table tr:hover {
            background-color: #FAFBFD;
        }

        .prod-img-preview {
            width: 50px;
            height: 50px;
            border-radius: var(--radius-md);
            object-fit: cover;
            border: 1px solid var(--cream-dark);
            background: #fdfdfd;
        }
        .prod-name {
            font-weight: 800;
            color: var(--brown-deep);
            font-size: 0.95rem;
        }
        .prod-category {
            font-weight: 700;
            text-transform: uppercase;
            font-size: 0.75rem;
            padding: 0.2rem 0.6rem;
            background: #E2E8F0;
            color: #475569;
            border-radius: var(--radius-sm);
            display: inline-block;
        }
        .prod-category.banh-mi { background-color: #FEF3C7; color: #92400E; }
        .prod-category.xoi { background-color: #ECFDF5; color: #065F46; }
        .prod-category.nuoc { background-color: #E0F2FE; color: #0369A1; }

        .badge-status {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            border-radius: var(--radius-full);
            font-weight: 800;
            font-size: 0.75rem;
        }
        .badge-status.active { background-color: #D1FAE5; color: #065F46; }
        .badge-status.inactive { background-color: #FEE2E2; color: #991B1B; }

        .btn-action-group {
            display: flex;
            gap: 6px;
        }
        .btn-edit {
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
        .btn-edit:hover {
            background-color: var(--amber);
            color: var(--brown-bark);
        }
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
            max-width: 520px;
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
        }
        .form-group {
            margin-bottom: var(--space-md);
            display: flex;
            flex-direction: column;
            gap: var(--space-xs);
        }
        .form-label {
            font-weight: 800;
            font-size: 0.88rem;
            color: var(--brown-deep);
        }
        .form-input {
            padding: 0.65rem 0.85rem;
            border: 2px solid var(--cream-dark);
            border-radius: var(--radius-md);
            font-family: inherit;
            font-size: 0.92rem;
            outline: none;
            transition: all var(--transition);
        }
        .form-input:focus {
            border-color: var(--amber);
        }
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: var(--space-md);
        }
        .modal-footer {
            padding: var(--space-lg) var(--space-xl);
            border-top: 1px solid var(--border-light);
            display: flex;
            justify-content: flex-end;
            gap: var(--space-md);
            background: #FAF8F5;
        }
        .btn-cancel {
            background: transparent;
            border: 2px solid var(--cream-dark);
            color: var(--text-muted);
            padding: 0.6rem 1.2rem;
            border-radius: var(--radius-md);
            font-weight: 800;
            cursor: pointer;
            font-size: 0.9rem;
        }
        .btn-cancel:hover {
            background: #F1F5F9;
            color: var(--text-dark);
        }
        .btn-save {
            background: var(--red-dark);
            color: var(--white);
            border: none;
            padding: 0.6rem 1.4rem;
            border-radius: var(--radius-md);
            font-weight: 800;
            cursor: pointer;
            font-size: 0.9rem;
            box-shadow: 0 4px 6px -1px rgba(185, 28, 28, 0.2);
        }
        .btn-save:hover {
            background: var(--red-darker);
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
            <a href="admin_agents.jsp" class="menu-item">📦 Đại lý sỉ</a>
            <a href="admin_customers.jsp" class="menu-item">👥 Khách hàng</a>
            <a href="admin_menu.jsp" class="menu-item active">🥖 Thực đơn</a>
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
                <h1 class="dashboard-title">Quản Lý Thực Đơn</h1>
            </div>
            <button class="btn-add" onclick="openCreateModal()">
                ➕ Thêm Món Mới
            </button>
        </div>

        <!-- PRODUCTS BOARD -->
        <section class="board-card">
            <div class="board-toolbar">
                <div class="filter-tabs">
                    <button class="filter-tab active" data-filter="ALL">Tất cả</button>
                    <button class="filter-tab" data-filter="banh-mi">Bánh mì</button>
                    <button class="filter-tab" data-filter="xoi">Xôi</button>
                    <button class="filter-tab" data-filter="nuoc">Nước uống</button>
                </div>
                <div class="search-wrap">
                    <input type="text" id="search-input" class="search-input" placeholder="Tìm tên món ăn...">
                </div>
            </div>

            <div class="table-responsive">
                <table class="menu-table">
                    <thead>
                        <tr>
                            <th>Ảnh</th>
                            <th>Tên Món</th>
                            <th>Loại</th>
                            <th>Giá Bán</th>
                            <th>Mô Tả</th>
                            <th>Trạng Thái</th>
                            <th>Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody id="products-tbody">
                        <tr>
                            <td colspan="7" class="text-center p-4 text-muted">⏳ Đang tải danh sách món ăn...</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </section>
    </main>

    <!-- PRODUCT MODAL -->
    <div class="modal-overlay hidden" id="product-modal" onclick="closeProductModal(event)">
        <div class="modal-card" onclick="event.stopPropagation()">
            <div class="modal-header">
                <h2 class="modal-title" id="modal-title">Thêm Sản Phẩm Mới</h2>
                <button class="modal-close" onclick="closeProductModal(null)">✕</button>
            </div>
            <form id="product-form" onsubmit="saveProduct(event)">
                <input type="hidden" id="prod-id" value="">
                <div class="modal-body">
                    <div class="form-group">
                        <label class="form-label" for="prod-name">Tên sản phẩm *</label>
                        <input type="text" id="prod-name" class="form-input" placeholder="Ví dụ: Bánh mì Thập cẩm" required maxlength="100">
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label" for="prod-category">Phân loại *</label>
                            <select id="prod-category" class="form-input" required>
                                <option value="banh-mi">🥖 Bánh mì kẹp</option>
                                <option value="xoi">🍚 Xôi</option>
                                <option value="nuoc">🥛 Nước uống</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="prod-price">Giá bán (VNĐ) *</label>
                            <input type="number" id="prod-price" class="form-input" placeholder="Ví dụ: 10000" min="0" required>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="prod-image">Đường dẫn ảnh</label>
                        <input type="text" id="prod-image" class="form-input" placeholder="Ví dụ: ../images/hero-banh-mi.png">
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="prod-description">Mô tả chi tiết</label>
                        <textarea id="prod-description" class="form-input" placeholder="Nhập mô tả ngắn về thành phần..." rows="3" maxlength="255" style="resize: vertical;"></textarea>
                    </div>

                    <div class="form-group" style="flex-direction:row; align-items:center; gap:8px;">
                        <input type="checkbox" id="prod-active" checked style="width:18px; height:18px; cursor:pointer;">
                        <label class="form-label" for="prod-active" style="cursor:pointer; margin-top:2px;">Còn hàng</label>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-cancel" onclick="closeProductModal(null)">Hủy bỏ</button>
                    <button type="submit" class="btn-save">Lưu lại</button>
                </div>
            </form>
        </div>
    </div>

    <!-- TOAST NOTIFICATION -->
    <div class="toast" id="toast">Cập nhật thành công!</div>

    <script>
        let allProducts = [];
        let currentFilter = 'ALL';
        let searchQuery = '';

        document.addEventListener('DOMContentLoaded', () => {
            loadProducts();
            setupFilters();
            setupSearch();
        });

        function loadProducts() {
            fetch('../resources/products')
            .then(res => {
                if (!res.ok) throw new Error('Không thể tải danh sách sản phẩm');
                return res.json();
            })
            .then(data => {
                allProducts = data || [];
                renderProductsTable();
            })
            .catch(err => {
                console.error(err);
                document.getElementById('products-tbody').innerHTML = `
                    <tr>
                        <td colspan="7" class="text-center p-4" style="color:var(--red-dark)">
                            ⚠️ Lỗi tải thực đơn: ${err.message}
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
                    renderProductsTable();
                });
            });
        }

        function setupSearch() {
            document.getElementById('search-input').addEventListener('input', (e) => {
                searchQuery = e.target.value.toLowerCase().trim();
                renderProductsTable();
            });
        }

        function formatVND(amount) {
            return amount.toLocaleString('vi-VN') + 'đ';
        }

        function renderProductsTable() {
            const tbody = document.getElementById('products-tbody');
            
            let filtered = allProducts;
            
            if (currentFilter !== 'ALL') {
                filtered = filtered.filter(p => p.category === currentFilter);
            }
            
            if (searchQuery) {
                filtered = filtered.filter(p => p.name.toLowerCase().includes(searchQuery));
            }

            if (filtered.length === 0) {
                tbody.innerHTML = `<tr><td colspan="7" class="text-center p-4 text-muted">Không tìm thấy món ăn nào.</td></tr>`;
                return;
            }

            tbody.innerHTML = '';
            filtered.forEach(p => {
                const tr = document.createElement('tr');
                
                const catLabel = p.category === 'banh-mi' ? 'Bánh mì' 
                               : p.category === 'xoi' ? 'Xôi' 
                               : 'Nước uống';
                
                const statusBadge = p.active 
                    ? '<span class="badge-status active">Còn hàng</span>'
                    : '<span class="badge-status inactive">Hết hàng</span>';

                tr.innerHTML = `
                    <td><img src="${p.imageUrl || '../images/logo.png'}" class="prod-img-preview" alt="Preview"></td>
                    <td class="prod-name">${p.name}</td>
                    <td><span class="prod-category ${p.category}">${catLabel}</span></td>
                    <td style="font-weight:800;color:var(--red-dark)">${formatVND(p.price)}</td>
                    <td style="max-width:240px; color:var(--text-muted); font-size:0.85rem;" title="${p.description || ''}">${p.description || '—'}</td>
                    <td>${statusBadge}</td>
                    <td>
                        <div class="btn-action-group">
                            <button class="btn-edit" onclick="openEditModal(${p.id})">Sửa</button>
                            <button class="btn-delete" onclick="deleteProduct(${p.id}, '${p.name.replace(/'/g, "\\'")}')">Xóa</button>
                        </div>
                    </td>
                `;
                tbody.appendChild(tr);
            });
        }

        function openCreateModal() {
            document.getElementById('modal-title').textContent = 'Thêm Sản Phẩm Mới';
            document.getElementById('prod-id').value = '';
            document.getElementById('prod-name').value = '';
            document.getElementById('prod-category').value = 'banh-mi';
            document.getElementById('prod-price').value = '';
            document.getElementById('prod-image').value = '../images/hero-banh-mi.png';
            document.getElementById('prod-description').value = '';
            document.getElementById('prod-active').checked = true;
            
            document.getElementById('product-modal').classList.remove('hidden');
        }

        function openEditModal(id) {
            const p = allProducts.find(prod => prod.id === id);
            if (!p) return;

            document.getElementById('modal-title').textContent = 'Chỉnh Sửa Sản Phẩm';
            document.getElementById('prod-id').value = p.id;
            document.getElementById('prod-name').value = p.name;
            document.getElementById('prod-category').value = p.category;
            document.getElementById('prod-price').value = p.price;
            document.getElementById('prod-image').value = p.imageUrl || '';
            document.getElementById('prod-description').value = p.description || '';
            document.getElementById('prod-active').checked = p.active;

            document.getElementById('product-modal').classList.remove('hidden');
        }

        function closeProductModal(e) {
            if (e === null || e.target.id === 'product-modal') {
                document.getElementById('product-modal').classList.add('hidden');
            }
        }

        function saveProduct(e) {
            e.preventDefault();

            const id = document.getElementById('prod-id').value;
            const name = document.getElementById('prod-name').value.trim();
            const category = document.getElementById('prod-category').value;
            const price = parseInt(document.getElementById('prod-price').value) || 0;
            const imageUrl = document.getElementById('prod-image').value.trim();
            const description = document.getElementById('prod-description').value.trim();
            const active = document.getElementById('prod-active').checked;

            const payload = {
                name,
                category,
                price,
                imageUrl: imageUrl || null,
                description: description || null,
                active
            };

            const isEdit = id !== '';
            const url = isEdit ? `../resources/products/${id}` : '../resources/products';
            const method = isEdit ? 'PUT' : 'POST';

            fetch(url, {
                method: method,
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload)
            })
            .then(res => {
                if (!res.ok) return res.json().then(d => { throw new Error(d.error || 'Lưu thất bại'); });
                return res.json();
            })
            .then(data => {
                showToast(isEdit ? '✅ Đã cập nhật sản phẩm!' : '✅ Đã thêm sản phẩm mới!');
                document.getElementById('product-modal').classList.add('hidden');
                loadProducts();
            })
            .catch(err => {
                alert('Lỗi: ' + err.message);
            });
        }

        function deleteProduct(id, name) {
            if (!confirm(`Bạn có chắc chắn muốn xóa món "${name}" khỏi thực đơn không?`)) {
                return;
            }

            fetch(`../resources/products/${id}`, {
                method: 'DELETE'
            })
            .then(res => {
                if (!res.ok) return res.json().then(d => { throw new Error(d.error || 'Xóa thất bại'); });
                showToast('✅ Đã xóa món khỏi thực đơn!');
                loadProducts();
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
