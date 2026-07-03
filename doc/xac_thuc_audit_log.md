# BÁO CÁO XÁC THỰC AI AUDIT LOG & MINH CHỨNG THỰC TẾ (EVIDENCE)
**Dự án:** Website Bán Sỉ & Bán Lẻ Bánh Mì — Anh Tu Bakery  
**Người thực hiện:** Antigravity (AI Coding Assistant)  
**Ngày xác thực:** 30-06-2026  

---

## 1. TỔNG QUAN XÁC THỰC
Báo cáo này tiến hành xác thực chéo (cross-verify) các phát hiện trong **Hallucination Detection Log (Báo cáo phát hiện ảo tưởng của AI)** với cấu trúc mã nguồn thực tế của dự án. Từng phát hiện dưới đây được đối chiếu trực tiếp với các tệp nguồn, các dòng mã cụ thể và các hàm thực thi thực tế trong project để làm minh chứng (evidence).

---

## 2. BẢNG CHI TIẾT XÁC THỰC & MINH CHỨNG THỰC TẾ (EVIDENCE LOG)

### 📊 Entry 009: Ảo tưởng về cơ chế Server-Sent Events (SSE)
*   **Loại lỗi:** Context Misunderstanding (Hiểu sai bối cảnh hệ thống).
*   **Tuyên bố của AI trước đó:** AI khẳng định hệ thống dùng cơ chế Server-Sent Events (SSE) để cập nhật trạng thái đơn hàng thời gian thực cho khách lẻ.
*   **Kết quả xác thực thực tế:** **CHÍNH XÁC.** Dự án thực tế hoàn toàn không sử dụng SSE mà sử dụng **Jakarta WebSocket API** kết nối hai đầu (Khách hàng & Admin).
*   **Minh chứng thực tế (Evidence):**
    *   **Server-side Endpoint**: Lớp [OrderWebSocket.java](file:///d:/code%20java/Test/Bakery/src/main/java/com/mycompany/bakery/controller/OrderWebSocket.java#L13) sử dụng annotation `@ServerEndpoint("/order-ws/{orderId}")` để mở cổng kết nối WebSocket cho từng mã đơn hàng cụ thể.
    *   **Server-side Broadcast**: Phương thức tĩnh `sendStatusUpdate(String orderId, String status)` tại [OrderWebSocket.java:L67-86](file:///d:/code%20java/Test/Bakery/src/main/java/com/mycompany/bakery/controller/OrderWebSocket.java#L67-L86) thực hiện đẩy trạng thái đơn hàng trực tiếp đến khách hàng thông qua giao tiếp text stream.
    *   **Server-side Trigger**: Trong lớp [OrderServlet.java](file:///d:/code%20java/Test/Bakery/src/main/java/com/mycompany/bakery/controller/OrderServlet.java#L112) tại dòng 112, hàm `OrderWebSocket.sendStatusUpdate(id, status.trim());` được gọi ngay sau khi Admin cập nhật trạng thái trong database thành công.
    *   **Client-side Connection**: Tệp [track.jsp](file:///d:/code%20java/Test/Bakery/src/main/webapp/view/track.jsp#L1180-L1184) thiết lập kết nối WebSocket tới server thông qua constructor:
        `const ws = new WebSocket(wsUrl);` với `wsUrl` có định dạng chứa `/order-ws/{orderId}`.

---

### 📊 Entry 010: Ảo tưởng về việc tự động chặn đơn lẻ trên 10km
*   **Loại lỗi:** Oversimplification (Đơn giản hóa nghiệp vụ quá mức).
*   **Tuyên bố của AI trước đó:** AI cho rằng hệ thống sẽ tự động chặn không cho khách hàng đặt đơn lẻ nếu địa chỉ giao hàng cách lò bánh mì trên 10km.
*   **Kết quả xác thực thực tế:** **CHÍNH XÁC.** Mã nguồn thực tế vẫn tính phí giao hàng bình thường cho khoảng cách trên 10km (theo hệ số TIER 4); hệ thống chỉ hiển thị một cảnh báo nhỏ ở giao diện nếu khoảng cách vượt quá **50km**, hoàn toàn không chặn việc gửi đơn hàng.
*   **Minh chứng thực tế (Evidence):**
    *   **Shipping Constants**: Tệp [order.js](file:///d:/code%20java/Test/Bakery/src/main/webapp/js/order.js#L12-L18) định nghĩa ngưỡng cảnh báo khoảng cách xa là `warningDist: 50.0` chứ không phải 10km:
        ```javascript
        const SHIPPING = {
            baseFee: 10000,
            tier2Start: 2.0, tier2Rate: 3500,
            tier3Start: 5.0, tier3Rate: 4000,
            tier4Start: 10.0, tier4Rate: 5000,
            warningDist: 50.0
        };
        ```
    *   **Tính phí lũy tiến trên 10km**: Hàm `calcShipFee(d)` tại [order.js:L363-370](file:///d:/code%20java/Test/Bakery/src/main/webapp/js/order.js#L363-L370) vẫn tính phí bình thường khi khoảng cách lớn hơn 10km:
        ```javascript
        else fee = (SHIPPING.baseFee + 3.0 * SHIPPING.tier2Rate + 5.0 * SHIPPING.tier3Rate) + (d - 10.0) * SHIPPING.tier4Rate;
        ```
    *   **Cảnh báo giao diện**: Hàm `calculateAndShowShipFee()` tại [order.js:L345-347](file:///d:/code%20java/Test/Bakery/src/main/webapp/js/order.js#L345-L347) chỉ bật/tắt hiển thị thẻ cảnh báo dựa vào ngưỡng 50km:
        ```javascript
        warnEl.classList.toggle('hidden', distKm <= SHIPPING.warningDist);
        ```
    *   **Không chặn khi Submit**: Hàm `submitOrder()` tại [order.js:L427-444](file:///d:/code%20java/Test/Bakery/src/main/webapp/js/order.js#L427-L444) chỉ kiểm tra tính hợp lệ của địa chỉ và tọa độ kinh/vĩ độ (không chặn cự ly giao lẻ).

---

### 📊 Entry 012: Ảo tưởng về việc sử dụng Spring Data JPA Repositories
*   **Loại lỗi:** Context Misunderstanding (Hiểu sai bối cảnh hệ thống).
*   **Tuyên bố của AI trước đó:** AI thiết kế một loạt lớp Repository kế thừa các Interface của Spring Data JPA để lưu trữ thực thể.
*   **Kết quả xác thực thực tế:** **CHÍNH XÁC.** Dự án thực tế là dự án **Jakarta EE Servlet/JSP** thuần túy, truy cập CSDL bằng các lớp DAO sử dụng kết nối **JDBC thuần túy (Connection, PreparedStatement, ResultSet)**.
*   **Minh chứng thực tế (Evidence):**
    *   **Thư viện kết nối CSDL**: Tệp [DatabaseHelper.java](file:///d:/code%20java/Test/Bakery/src/main/java/com/mycompany/bakery/data/DatabaseHelper.java#L3-L8) chỉ sử dụng các thư viện JDBC chuẩn của Java (`java.sql.Connection`, `java.sql.DriverManager`, `java.sql.PreparedStatement`) kết hợp với tra cứu JNDI DataSource `jdbc/BakeryDB`.
    *   **Các lớp DAO**: Lớp [UserDAO.java](file:///d:/code%20java/Test/Bakery/src/main/java/com/mycompany/bakery/data/UserDAO.java#L29-L37), [OrderDAO.java](file:///d:/code%20java/Test/Bakery/src/main/java/com/mycompany/bakery/data/OrderDAO.java#L50-L108) sử dụng annotation CDI `@ApplicationScoped` và truy vấn database bằng SQL string tham số hóa qua JDBC PreparedStatement. Không hề tồn tại bất kỳ một JPA Repository nào.

---

### 📊 Entry 015: Công thức tính tiền tiết kiệm sỉ bậc thang (Self-Correction)
*   **Loại lỗi:** Context Misunderstanding / UX Confusion.
*   **Tuyên bố của AI trước đó:** AI bị nhầm lẫn trong việc diễn giải công thức `Savings = q * 200` VNĐ, không làm rõ rằng đây là phần tiền tiết kiệm tính riêng trên số lượng hiện tại khi nâng bậc giá sỉ từ Bậc 1 lên Bậc 2.
*   **Kết quả xác thực thực tế:** **CHÍNH XÁC.** Logic mã nguồn thực tế tính toán chính xác phần chênh lệch này để gợi ý khách hàng mua thêm nhằm tối ưu hóa chi phí.
*   **Minh chứng thực tế (Evidence):**
    *   Tại tệp [wholesale.jsp:L427-431](file:///d:/code%20java/Test/Bakery/src/main/webapp/view/wholesale.jsp#L427-L431), mã nguồn tính toán tiền tiết kiệm như sau:
        ```javascript
        if (qty >= 50 && qty < 200) {
            const needed = 200 - qty;
            const saving = qty * 1500 - qty * 1300;
            hint.classList.remove('hidden');
            hint.innerHTML = `💡 Đặt thêm <strong>${needed} ổ</strong> → giá <strong>1.300đ/ổ</strong>, tiết kiệm được <strong>${saving.toLocaleString('vi-VN')}đ</strong>!`;
        }
        ```
        Biểu thức `saving = qty * 1500 - qty * 1300` tương đương về mặt toán học với $q \times (1500 - 1300) = q \times 200$ VNĐ. Đây là công thức phản ánh đúng số tiền đại lý sẽ tiết kiệm được cho lượng ổ hiện tại khi nâng cấp bậc sỉ.

---

### 📊 Entry 020: Bịa đặt về việc mã hóa mật khẩu bằng BCrypt
*   **Loại lỗi:** Fabrication (Bịa đặt thông tin không có thực).
*   **Tuyên bố của AI trước đó:** AI khẳng định toàn bộ mật khẩu người dùng và đại lý sỉ được băm và bảo vệ bằng thuật toán mã hóa một chiều **BCrypt với độ khó (strength) = 12**.
*   **Kết quả xác thực thực tế:** **CHÍNH XÁC (Xác minh có bịa đặt).** Hệ thống thực tế đang lưu trữ và so sánh mật khẩu dưới dạng **văn bản thô (Plaintext)** trực tiếp trong câu truy vấn SQL.
*   **Minh chứng thực tế (Evidence):**
    *   **Xác thực Khách lẻ/Admin**: Trong phương thức `authenticate` tại [UserDAO.java:L29-37](file:///d:/code%20java/Test/Bakery/src/main/java/com/mycompany/bakery/data/UserDAO.java#L29-L37), câu SQL so sánh trực tiếp chuỗi mật khẩu đầu vào không qua giải mã hay băm:
        `SELECT * FROM users WHERE username = ? AND password = ?`
    *   **Xác thực Đại lý sỉ**: Tương tự, phương thức `authenticate` của đại lý tại [AgentDAO.java:L71-76](file:///d:/code%20java/Test/Bakery/src/main/java/com/mycompany/bakery/data/AgentDAO.java#L71-L76) sử dụng:
        `SELECT * FROM agents WHERE phone = ? AND password = ?`
    *   **Dữ liệu mẫu (Seed Data)**: Trong [DatabaseHelper.java:L198-212](file:///d:/code%20java/Test/Bakery/src/main/java/com/mycompany/bakery/data/DatabaseHelper.java#L198-L212), mật khẩu của admin và customer được nạp cứng trực tiếp là `"admin123"` và `"user123"` dưới dạng plaintext.

---

### 📊 Entry 021: Bịa đặt về cơ chế bảo mật CSRF Token
*   **Loại lỗi:** Fabrication (Bịa đặt thông tin không có thực).
*   **Tuyên bố của AI trước đó:** AI khẳng định toàn bộ các biểu mẫu sử dụng phương thức POST trong hệ thống đều được bảo mật tự động bằng **CSRF Token**.
*   **Kết quả xác thực thực tế:** **CHÍNH XÁC (Xác minh có bịa đặt).** Hệ thống không triển khai bất kỳ một bộ lọc (`Filter`) hay cơ chế sinh/xác thực mã token CSRF nào.
*   **Minh chứng thực tế (Evidence):**
    *   **Cấu hình Web Application**: Tệp cấu hình deployment descriptor [web.xml](file:///d:/code%20java/Test/Bakery/src/main/webapp/WEB-INF/web.xml) hoàn toàn trống rỗng phần cấu hình `<filter>` hay `<filter-mapping>`.
    *   **Cấu trúc Controller**: Danh mục các tệp tin Java trong thư mục [controller](file:///d:/code%20java/Test/Bakery/src/main/java/com/mycompany/bakery/controller) chỉ gồm các servlet và websocket endpoint, hoàn toàn không có lớp Filter an ninh nào để chặn và kiểm tra CSRF token.

---

### 📊 Entry 022: Bịa đặt về chức năng Dự báo vật tư & Chart.js trên Dashboard
*   **Loại lỗi:** Fabrication (Bịa đặt thông tin không có thực).
*   **Tuyên bố của AI trước đó:** AI mô tả trang quản trị Admin tích hợp biểu đồ trực quan động sử dụng **Chart.js** để hiển thị phân bổ doanh thu và một bảng thuật toán **Dự báo số lượng vật tư** cần chuẩn bị cho ngày hôm sau.
*   **Kết quả xác thực thực tế:** **CHÍNH XÁC (Xác minh có bịa đặt).** Trang quản trị thực tế chỉ có các bảng danh sách đơn hàng dạng HTML thô và mã Javascript xử lý lọc trạng thái đơn thuần. Hoàn toàn không tích hợp thư viện vẽ biểu đồ hay logic dự toán nguyên liệu.
*   **Minh chứng thực tế (Evidence):**
    *   Truy vấn tìm kiếm từ khóa `"chart"` hoặc `"canvas"` trong tệp [admin_dashboard.jsp](file:///d:/code%20java/Test/Bakery/src/main/webapp/view/admin_dashboard.jsp) trả về **0 kết quả**. Trang này hiển thị dữ liệu doanh thu qua một thẻ text đơn giản có ID `stat-revenue` tại dòng 499 và tính tổng tiền bằng Javascript client-side tại dòng 627 (`allOrders.filter(...).reduce(...)`).

---

### 📊 Entry 023: Bịa đặt về độ phức tạp của sơ đồ thực thể ERD
*   **Loại lỗi:** Fabrication (Bịa đặt thông tin không có thực).
*   **Tuyên bố của AI trước đó:** AI vẽ một sơ đồ ERD phức tạp bao gồm các trường dữ liệu như `order_code` (unique), `order_type`, `display_order`, `variant_label`,...
*   **Kết quả xác thực thực tế:** **CHÍNH XÁC (Xác minh có bịa đặt).** Database thực tế được thiết lập tinh giản hơn rất nhiều để phù hợp với quy mô dự án demo.
*   **Minh chứng thực tế (Evidence):**
    *   Trong tệp [DatabaseHelper.java:L113-136](file:///d:/code%20java/Test/Bakery/src/main/java/com/mycompany/bakery/data/DatabaseHelper.java#L113-L136), câu lệnh SQL khởi tạo bảng `orders` và `order_items` cho thấy:
        *   Bảng `orders` dùng trực tiếp trường khóa chính `id` làm mã đơn (không có trường `order_code` riêng biệt), phân loại đơn dựa vào `delivery_method` (không có trường `order_type`).
        *   Bảng `order_items` chỉ gồm 5 trường cơ bản: `id` (int), `order_id` (varchar), `name` (varchar), `qty` (int), và `price` (int). Hoàn toàn không có các trường `size` hay `selected_option` (các tùy chọn này được nối trực tiếp vào chuỗi SNAPSHOT tên sản phẩm, ví dụ: *"Xôi Bò xào (Hộp lớn)"*).

---

## 3. XÁC THỰC CÁC TÍNH NĂNG MỚI ĐƯỢC BỔ SUNG (NEW FEATURES EVIDENCE)

Dưới đây là xác thực chi tiết và bằng chứng mã nguồn cho các tính năng mới được cập nhật trong hệ thống:

### 🔌 3.1 Cổng Webhook Thanh Toán Tự Động (SePay Integration)
*   **Tính năng:** Servlet lắng nghe các yêu cầu callback từ cổng thanh toán tự động, đối soát mã đơn hàng `DH...` bằng Regex và chuyển trạng thái đơn hàng sang `PAID` thời gian thực.
*   **Minh chứng thực tế (Evidence):**
    *   **Đường dẫn API**: Servlet được định nghĩa tại [PaymentWebhookServlet.java:L24-25](file:///d:/code%20java/Test/Bakery/src/main/java/com/mycompany/bakery/controller/PaymentWebhookServlet.java#L24-L25) ánh xạ tới endpoint `/payment-webhook`:
        `@WebServlet(name = "PaymentWebhookServlet", urlPatterns = {"/payment-webhook"})`
    *   **Xác thực Token**: Dòng 63-78 thực hiện kiểm tra Header `Authorization: Apikey <token>` và so khớp trực tiếp với token đọc được từ tệp `db.properties` (`payment.sepay.token`).
    *   **Regex Trích xuất Đơn hàng**: Sử dụng biểu thức chính quy tại dòng 28:
        `private static final Pattern ORDER_ID_PATTERN = Pattern.compile("DH\\d+", Pattern.CASE_INSENSITIVE);`
        và đối soát trong nội dung giao dịch tại dòng 104-108.
    *   **Đồng bộ thời gian thực**: Khi đơn hàng được cập nhật trạng thái sang `PAID`, Servlet kích hoạt phát sóng qua cả hai websocket:
        *   Cho khách hàng: `OrderWebSocket.sendStatusUpdate(orderId, "PAID");` (Dòng 119)
        *   Cho admin làm mới màn hình: `AdminWebSocket.broadcastRefresh();` (Dòng 122)

---

### 🔄 3.2 Kênh Tự Động Làm Mới Giao Diện Quản Trị (Admin WS)
*   **Tính năng:** WebSocket chuyên biệt dành riêng cho quản trị viên nhằm truyền tín hiệu yêu cầu client-side tự động tải lại danh sách đơn hàng khi có cập nhật mới mà không cần F5.
*   **Minh chứng thực tế (Evidence):**
    *   **Server-side Endpoint**: Lớp [AdminWebSocket.java:L11-12](file:///d:/code%20java/Test/Bakery/src/main/java/com/mycompany/bakery/controller/AdminWebSocket.java#L11-L12) khai báo:
        `@ServerEndpoint("/admin-ws")`
    *   **Server-side Broadcast**: Hàm `broadcastRefresh()` tại dòng 40-51 lặp qua danh sách các session admin đang hoạt động và gửi bản tin text `"refresh"`:
        `session.getBasicRemote().sendText("refresh");`
    *   **Client-side Connection & Action**: Trang [admin_dashboard.jsp:L861-871](file:///d:/code%20java/Test/Bakery/src/main/webapp/view/admin_dashboard.jsp#L861-L871) bắt sự kiện WebSocket và tự động kích hoạt hàm `loadOrders()` để cập nhật giao diện thời gian thực:
        ```javascript
        ws.onmessage = function(event) {
            if (event.data === 'refresh') {
                loadOrders();
                showToast('🔔 Có cập nhật đơn hàng mới!');
            }
        };
        ```

---

### 🛡️ 3.3 Tự Động Đồng Bộ Đơn Hàng Thành Viên Theo Tài Khoản (`user_id`)
*   **Tính năng:** Loại bỏ sự bất tiện và thiếu an toàn của việc liên kết SĐT thủ công. Đơn hàng lẻ của thành viên được đồng bộ tự động và bảo mật qua mã định danh tài khoản (`user_id`) trong session.
*   **Minh chứng thực tế (Evidence):**
    *   **Server-side API**: Hàm `doGet` tại [OrderServlet.java:L49-54](file:///d:/code%20java/Test/Bakery/src/main/java/com/mycompany/bakery/controller/OrderServlet.java#L49-L54) tự động nhận diện nếu có session khách hàng lẻ hoạt động thì trả về đơn theo `user_id`:
        ```java
        if (user != null && "CUSTOMER".equals(user.getRole())) {
            List<Order> userOrders = orderService.getOrdersByUserId(user.getId());
            out.print(jsonb.toJson(userOrders));
            return;
        }
        ```
    *   **Client-side Sync Banner**: Trang [track.jsp:L630-644](file:///d:/code%20java/Test/Bakery/src/main/webapp/view/track.jsp#L630-L644) đã loại bỏ hoàn toàn biểu mẫu điền và cập nhật số điện thoại thủ công đối với tài khoản thành viên.
    *   **Client-side Action**: Tại [track.jsp:L771-778](file:///d:/code%20java/Test/Bakery/src/main/webapp/view/track.jsp#L771-L778), trang web tự động phân nhánh: nếu thành viên đã đăng nhập sẽ gọi trực tiếp hàm `fetchOrdersByAccount()` để gửi request lên `/resources/orders` lấy dữ liệu an toàn thay vì dựa vào SĐT trong localStorage.
