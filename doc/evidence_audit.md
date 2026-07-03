# DANH SÁCH EVIDENCE PHỤC VỤ EXCEL AI AUDIT LOG
*(Sao chép nội dung dưới đây vào cột **Evidence** trong file Excel của bạn)*

---

### **Entry 001**
**Nội dung điền vào cột Evidence:**
```text
Cấu trúc thư mục phân tách rõ rệt: business package (Agent.java, Order.java, OrderItem.java, Product.java, User.java); controller package (AuthServlet.java, OrderServlet.java, AgentServlet.java, ProductServlet.java, AdminCustomerServlet.java, PaymentWebhookServlet.java).
```

---

### **Entry 002**
**Nội dung điền vào cột Evidence:**
```text
File pom.xml chứa dependencies: jakarta.servlet-api (v6.0.0), jakarta.servlet.jsp-api (v3.1.1), weld-servlet-core (v5.1.2.Final) cho CDI Injection. Servlet sử dụng annotation @WebServlet và @Inject thay vì Spring Boot.
```

---

### **Entry 003**
**Nội dung điền vào cột Evidence:**
```text
Các trang giao diện JSP được phân mảnh nghiệp vụ rõ ràng: /view/menu.jsp (giao diện thực đơn lẻ), /view/order.jsp (checkout lẻ), /view/wholesale.jsp (giao diện đăng ký, đặt sỉ & máy tính giá sỉ), /view/admin_dashboard.jsp (dashboard quản trị).
```

---

### **Entry 004**
**Nội dung điền vào cột Evidence:**
```text
Tọa độ lò bánh mì BAKERY_LAT = 16.447500, BAKERY_LNG = 107.596100 định nghĩa tại order.js (L8-9) và wholesale.jsp (L384). Thuật toán tính khoảng cách haversine(lat1, lon1, lat2, lon2) cài đặt tại order.js (L353-359).
```

---

### **Entry 005**
**Nội dung điền vào cột Evidence:**
```text
Hàm calcWholesalePrice() tại wholesale.jsp (L386-435) chứa logic chặn đặt sỉ nếu qty < 50, phân bậc đơn giá sỉ: 1.500đ/ổ nếu qty <= 199 và 1.300đ/ổ nếu qty >= 200.
```

---

### **Entry 006**
**Nội dung điền vào cột Evidence:**
```text
Mã nguồn order.jsp bắt buộc chọn options Sữa/Đường đối với "Bánh mì bơ đậu". Hàm renderOrderCart() trong order.js (L127) và submitOrder() (L486) xử lý ghép option và size (Lớn/Nhỏ) làm SNAPSHOT lưu vào CSDL qua OrderItem.
```

---

### **Entry 007**
**Nội dung điền vào cột Evidence:**
```text
Trong DatabaseHelper.java (L139-160) chứa câu lệnh khởi tạo 2 bảng riêng biệt: users (chứa id, username, password, role, fullname, phone) và agents (chứa name, phone, shop_name, address, latitude, longitude, password, status).
```

---

### **Entry 008**
**Nội dung điền vào cột Evidence:**
```text
Servlet OrderServlet.java (L89-119) xử lý cập nhật trạng thái qua endpoint POST /resources/orders/{id}/status. Thẻ <select class="status-select"> tại admin_dashboard.jsp (L699-706) định nghĩa 6 trạng thái đơn hàng chuẩn.
```

---

### **Entry 009**
**Nội dung điền vào cột Evidence:**
```text
Lớp OrderWebSocket.java (L11-13) ánh xạ endpoint @ServerEndpoint("/order-ws/{orderId}"). Tệp track.jsp (L1180-1184) thiết lập kết nối Client qua: const ws = new WebSocket(wsUrl);
```

---

### **Entry 010**
**Nội dung điền vào cột Evidence:**
```text
Hằng số warningDist: 50.0 tại order.js (L17). Giao diện order.js (L345-347) ẩn/hiển thị cảnh báo dựa vào: warnEl.classList.toggle('hidden', distKm <= SHIPPING.warningDist); hoàn toàn không có logic chặn submit khi khoảng cách lớn hơn 10km.
```

---

### **Entry 012**
**Nội dung điền vào cột Evidence:**
```text
Lớp DatabaseHelper.java (L35-43) dùng Connection và DriverManager. Lớp UserDAO.java (L29-37) dùng Connection conn = DatabaseHelper.getConnection(); và ps = conn.prepareStatement(...) để chạy SQL thô, không có Spring Data JPA.
```

---

### **Entry 013**
**Nội dung điền vào cột Evidence:**
```text
Không có AuthFilter. Kiểm tra phân quyền được thực thi thủ công ở đầu các Servlet nghiệp vụ. Ví dụ: OrderServlet.java (L91-97) lấy session qua request.getSession(false) và kiểm tra !"ADMIN".equals(user.getRole()).
```

---

### **Entry 015**
**Nội dung điền vào cột Evidence:**
```text
Công thức tính số tiền tiết kiệm: saving = qty * 1500 - qty * 1300 triển khai tại wholesale.jsp (L427-431), tính toán chính xác phần chênh lệch chi phí giữa 2 bậc giá sỉ dựa trên số lượng ổ hiện tại.
```

---

### **Entry 016**
**Nội dung điền vào cột Evidence:**
```text
Hàm calcShipFee(d) tại order.js (L363-370) phân chặng tính phí lũy tiến dựa trên d: d <= 2km, d <= 5km, d <= 10km và d > 10km. Làm tròn lên 500đ gần nhất bằng công thức: Math.ceil(fee / 500) * 500;
```

---

### **Entry 017**
**Nội dung điền vào cột Evidence:**
```text
Lớp AdminCustomerServlet.java ánh xạ urlPatterns = {"/resources/admin/customers/*"}. Phương thức doGet trả về danh sách khách hàng và lịch sử đơn hàng của khách đó thông qua orderService.getOrdersByUserId(userId).
```

---

### **Entry 020**
**Nội dung điền vào cột Evidence:**
```text
Trong UserDAO.java (L29-37) dùng SQL: SELECT * FROM users WHERE username = ? AND password = ? đối chiếu thẳng tham số password dạng văn bản thô. Tương tự, DatabaseHelper.java (L198-212) seed tài khoản bằng mật khẩu plaintext.
```

---

### **Entry 021**
**Nội dung điền vào cột Evidence:**
```text
File web.xml trống rỗng phần cấu hình <filter>. Thư mục src/main/java/com/mycompany/bakery/controller chỉ chứa các Servlet và WebSocket endpoint, không tồn tại bất kỳ Filter nào để chặn hoặc xử lý CSRF token.
```

---

### **Entry 022**
**Nội dung điền vào cột Evidence:**
```text
Tìm kiếm từ khóa "chart" hoặc "canvas" trong tệp admin_dashboard.jsp trả về 0 kết quả. Doanh thu được tính bằng hàm reduce() ở client-side tại admin_dashboard.jsp (L627): allOrders.filter(...).reduce(...) và gán vào thẻ text.
```

---

### **Entry 023**
**Nội dung điền vào cột Evidence:**
```text
Trong DatabaseHelper.java (L113-136), câu lệnh CREATE TABLE orders chỉ sử dụng khóa chính id làm mã đơn (không có order_code), phân loại bằng delivery_method (không có order_type); bảng order_items chỉ có 5 trường cơ bản.
```

---

### **Entry 024**
**Nội dung điền vào cột Evidence:**
```text
Servlet PaymentWebhookServlet.java (L24-25) nhận POST tại /payment-webhook, kiểm tra Apikey trong header Authorization (L63-78), dùng Pattern.compile("DH\\d+", Pattern.CASE_INSENSITIVE) (L28) để quét mã đơn hàng và tự động cập nhật trạng thái đơn thành PAID.
```

---

### **Entry 025**
**Nội dung điền vào cột Evidence:**
```text
Lớp AdminWebSocket.java (L11-12) ánh xạ @ServerEndpoint("/admin-ws"). Đoạn mã client tại admin_dashboard.jsp (L861-871) lắng nghe tín hiệu "refresh" từ socket để tự động gọi hàm loadOrders() nhằm làm mới danh sách đơn hàng.
```

---

### **Entry 026**
**Nội dung điền vào cột Evidence:**
```text
Servlet OrderServlet.java (L49-54) tự nhận diện vai trò CUSTOMER từ Session để trả về đơn hàng theo user_id. Trang track.jsp (L771-778) tự động gọi hàm fetchOrdersByAccount() để tải đơn hàng qua endpoint /resources/orders mà không cần nhập SĐT.
```
