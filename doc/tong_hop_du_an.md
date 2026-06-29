# TÀI LIỆU TỔNG HỢP DỰ ÁN — ANH TU BAKERY
*(Website Quản Lý Bán Sỉ & Bán Lẻ Tích Hợp)*

---

## 1. TỔNG QUAN DỰ ÁN
Dự án **Anh Tu Bakery** vận hành đồng thời hai mô hình kinh doanh trên cùng một nền tảng:
*   **Phân hệ Bán Sỉ (Lò Bánh Mì Anh Tú)**: Quản lý các đại lý lấy bánh mì ổ không nhân trong bán kính tối đa 5km, hỗ trợ giao hàng tận nơi miễn phí với chính sách giá sỉ bậc thang tự động tính toán theo số lượng.
*   **Phân hệ Bán Lẻ (Quán Bánh Mì Của Mẹ)**: Cho phép khách hàng lẻ đặt món trực tuyến bao gồm bánh mì kẹp, xôi, nước uống và tự chọn một trong hai hình thức nhận hàng: tự đến lấy tại quán (miễn phí ship) hoặc giao hàng tận nơi (phí ship tính lũy tiến theo số km thực tế).

### Đối tượng sử dụng hệ thống (Actors):
1.  **Quản trị viên (Admin)**: Mẹ hoặc người nhà phụ trách vận hành hệ thống. Có quyền duyệt đại lý bán sỉ, xác nhận thanh toán chuyển khoản thủ công, cập nhật trạng thái đơn hàng (chế biến, xong, giao...), quản lý menu sản phẩm và theo dõi doanh thu.
2.  **Đại lý (Agent)**: Các cửa hàng, quán ăn mua sỉ mì ổ. Cần đăng ký tài khoản và được Admin kích hoạt trạng thái mới có thể đăng nhập để lên đơn sỉ.
3.  **Khách lẻ (Customer)**: Người mua bánh mì kẹp, xôi, nước uống. Có thể đặt hàng trực tiếp không cần đăng nhập, hoặc đăng ký tài khoản khách lẻ để tiện lưu trữ lịch sử giao dịch.

---

## 2. KIẾN TRÚC & CÔNG NGHỆ THỰC TẾ TRONG MÃ NGUỒN
> [!IMPORTANT]
> **Lưu ý quan trọng về sự khác biệt giữa thiết kế lý thuyết và mã nguồn:**
> Các tài liệu thiết kế ban đầu (`01.system_architecture.md` -> `05.admin_analystic.md`) mô tả dự án sử dụng *Spring Boot, Spring Data JPA, và Server-Sent Events (SSE)*.
> Tuy nhiên, trong mã nguồn thực tế, dự án được xây dựng bằng công nghệ **Jakarta EE 11 (Servlet/JSP)** chạy trên Servlet Container (như Apache Tomcat) kết hợp với **Weld CDI** để quản lý Dependency Injection và giao tiếp với CSDL qua **JDBC thuần (DriverManager/DataSource)**. Thay vì dùng SSE, hệ thống sử dụng **WebSocket** để cập nhật trạng thái đơn hàng thời gian thực.

### Chi tiết Stack công nghệ thực tế:
*   **Backend Core**: Java 17, Jakarta EE 11 (Servlet, JSP).
*   **Dependency Injection (CDI)**: JBoss Weld Servlet Shaded (`@Inject`, `@ApplicationScoped`).
*   **Database Engine**: `DatabaseHelper` hỗ trợ tương thích đồng thời cả **H2** (CSDL nhúng, mặc định để chạy thử nghiệm nhanh), **MySQL**, và **Microsoft SQL Server**. Hệ thống tự động tạo bảng tương ứng với từng hệ CSDL khi khởi chạy ứng dụng.
*   **Data Access (Persistence)**: JDBC thuần túy thông qua các lớp DAO (`UserDAO`, `AgentDAO`, `ProductDAO`, `OrderDAO`). Connection được lấy qua JNDI Resource `jdbc/BakeryDB` hoặc kết nối trực tiếp qua cấu hình trong file `db.properties`.
*   **JSON Binding**: Jakarta JSON Binding (Yasson & Parsson) thông qua đối tượng `Jsonb`.
*   **Real-time Notifications**: Jakarta WebSocket API (`OrderWebSocket` lắng nghe tại endpoint `/order-ws/{orderId}`).
*   **Frontend**: JSP làm View Engine, kết hợp với các tệp CSS giao diện (`style.css`, `menu.css`, `order.css`) và mã JavaScript thuần (`main.js`, `cart.js`, `menu.js`, `order.js`) thực hiện AJAX call đến các Servlet API.

---

## 3. CƠ SỞ DỮ LIỆU & THỰC THỂ (DATABASE SCHEMA)
Hệ thống sử dụng các bảng cơ sở dữ liệu sau để lưu trữ thông tin:

### 3.1 Bảng `users` (Tài khoản Admin & Khách hàng lẻ)
*   `id` (INT, AUTO_INCREMENT, PRIMARY KEY): Khóa chính.
*   `username` (VARCHAR(50), UNIQUE, NOT NULL): Tên đăng nhập.
*   `password` (VARCHAR(255), NOT NULL): Mật khẩu đăng nhập.
*   `fullname` (VARCHAR(100)): Họ tên đầy đủ.
*   `phone` (VARCHAR(20)): Số điện thoại liên hệ.
*   `role` (VARCHAR(20), NOT NULL): Phân quyền (`ADMIN`, `CUSTOMER`).
*   `created_at` (VARCHAR(50), NOT NULL): Thời điểm tạo tài khoản.

### 3.2 Bảng `agents` (Tài khoản đại lý bán sỉ)
*   `id` (INT, AUTO_INCREMENT, PRIMARY KEY): Khóa chính đại lý.
*   `name` (VARCHAR(100), NOT NULL): Tên người đại diện.
*   `phone` (VARCHAR(20), UNIQUE, NOT NULL): Số điện thoại đại lý (dùng để đăng nhập).
*   `shop_name` (VARCHAR(150), NOT NULL): Tên tiệm/cửa hàng đại lý.
*   `address` (VARCHAR(255), NOT NULL): Địa chỉ nhận giao hàng sỉ.
*   `latitude` (DOUBLE, NOT NULL): Vĩ độ GPS dùng tính khoảng cách.
*   `longitude` (DOUBLE, NOT NULL): Kinh độ GPS dùng tính khoảng cách.
*   `password` (VARCHAR(100), NOT NULL): Mật khẩu đăng nhập.
*   `status` (VARCHAR(20), NOT NULL, DEFAULT `'PENDING'`): Trạng thái xét duyệt đại lý (`PENDING`, `ACTIVE`, `SUSPENDED`).
*   `created_at` (VARCHAR(50), NOT NULL): Ngày đăng ký.

### 3.3 Bảng `products` (Danh mục thực đơn bán lẻ)
*   `id` (INT, AUTO_INCREMENT, PRIMARY KEY): Khóa chính sản phẩm.
*   `name` (VARCHAR(100), NOT NULL): Tên món ăn/thức uống.
*   `category` (VARCHAR(50), NOT NULL): Danh mục (`banh-mi`, `xoi`, `nuoc`).
*   `price` (INT, NOT NULL): Giá bán lẻ mặc định (đối với bánh mì hoặc hộp/ly nhỏ).
*   `description` (VARCHAR(255)): Mô tả chi tiết món ăn.
*   `image_url` (VARCHAR(255)): Đường dẫn ảnh sản phẩm.
*   `is_active` (BOOLEAN, NOT NULL, DEFAULT `TRUE`): Trạng thái bật/tắt hiển thị trên menu.

### 3.4 Bảng `orders` (Quản lý thông tin đơn hàng)
*   `id` (VARCHAR(50), PRIMARY KEY): Mã đơn hàng tự sinh dạng `DH` + timestamp.
*   `status` (VARCHAR(20), NOT NULL): Trạng thái đơn (`PENDING`, `PAID`, `PREPARING`, `READY`, `DELIVERING`, `COMPLETED`, `CANCELLED`).
*   `customer_name` (VARCHAR(100), NOT NULL): Tên người đặt/nhận hàng.
*   `customer_phone` (VARCHAR(20), NOT NULL): Số điện thoại liên hệ.
*   `delivery_method` (VARCHAR(20), NOT NULL): Phương thức giao nhận (`TU_LAY`, `GIAO_HANG`, hoặc `WHOLESALE` đối với đơn sỉ).
*   `delivery_address` (VARCHAR(255)): Địa chỉ giao hàng lẻ.
*   `pickup_time` (VARCHAR(50)): Khung giờ hẹn đến lấy tại tiệm.
*   `latitude` / `longitude` (DOUBLE): Tọa độ địa chỉ giao hàng lẻ.
*   `subtotal` (INT, NOT NULL): Tiền hàng chưa bao gồm phí vận chuyển.
*   `shipping_fee` (INT, NOT NULL): Phí giao hàng (đơn sỉ luôn bằng 0 VNĐ).
*   `total` (INT, NOT NULL): Tổng tiền thanh toán (`subtotal` + `shipping_fee`).
*   `created_at` (VARCHAR(50), NOT NULL): Thời điểm lên đơn.
*   `note` (VARCHAR(500)): Ghi chú từ khách hàng.
*   `user_id` (INT, FOREIGN KEY): Liên kết tới `users` (nếu khách hàng đã đăng nhập).

### 3.5 Bảng `order_items` (Chi tiết các món trong đơn)
*   `id` (INT, AUTO_INCREMENT, PRIMARY KEY): Khóa chính.
*   `order_id` (VARCHAR(50), FOREIGN KEY, NOT NULL): Liên kết tới đơn hàng.
*   `name` (VARCHAR(100), NOT NULL): Tên sản phẩm (lưu snapshot tại thời điểm đặt hàng để tránh sai lệch khi đổi giá).
*   `qty` (INT, NOT NULL): Số lượng món đặt.
*   `price` (INT, NOT NULL): Đơn giá sản phẩm (lưu snapshot tại thời điểm đặt hàng).

---

## 4. CHI TIẾT NGHIỆP VỤ HỆ THỐNG

### 4.1 Nghiệp vụ Phân hệ Bán Sỉ (Lò Bánh Mì)
1.  **Duyệt tài khoản đại lý**: Khi một đại lý điền form đăng ký, tài khoản sẽ ở trạng thái `PENDING`. Admin sẽ đối chiếu thông tin ngoài đời thực và bấm nút **"Kích hoạt"** trên màn hình quản lý đại lý để chuyển tài khoản sang `ACTIVE`. Chỉ tài khoản `ACTIVE` mới có quyền đăng nhập và lên đơn.
2.  **Giới hạn khoảng cách 5km**: Hệ thống sử dụng **công thức Haversine** để tính khoảng cách đường thẳng từ tọa độ lò bánh mì (cấu hình trong file cấu hình) tới tọa độ đại lý. Nếu khoảng cách vượt quá 5km, hệ thống sẽ từ chối tạo đơn sỉ.
3.  **Giá sỉ bậc thang**:
    *   Dưới 50 ổ: Hệ thống từ chối nhận đơn sỉ, yêu cầu đặt mua lẻ.
    *   Từ 50 – 199 ổ: Áp dụng đơn giá sỉ **1.500 VNĐ / ổ**.
    *   Từ 200 ổ trở lên: Áp dụng đơn giá sỉ tốt nhất **1.300 VNĐ / ổ**.
    *   *Real-time Hint (Gợi ý giao diện)*: Khi đại lý gõ số lượng, giao diện tự động tính tiền, hiển thị giá sỉ tương ứng và đưa ra gợi ý đặt thêm để lên bậc giá tốt hơn.
4.  **Phí ship đơn sỉ**: Luôn là **0 VNĐ** (miễn phí ship hoàn toàn) trong phạm vi hỗ trợ 5km.

### 4.2 Nghiệp vụ Phân hệ Bán Lẻ (Bánh Mì Của Mẹ)
1.  **Các ràng buộc đặc thù trên Thực đơn (Menu)**:
    *   Bánh mì Bơ đậu: Yêu cầu bắt buộc khách phải chọn một trong hai tùy chọn: **Sữa** hoặc **Đường** thông qua nút chọn radio trước khi cho vào giỏ hàng.
    *   Xôi: Gồm các loại xôi mặn/ngọt, giao diện hiển thị 2 tùy chọn kích thước (**Hộp nhỏ / Hộp lớn**) và tự động hiển thị giá tương ứng khi khách bấm chọn.
    *   Sữa đậu: Giao diện hỗ trợ chọn size ly (**Ly nhỏ / Ly lớn**).
2.  **Phương thức nhận hàng lẻ**: Khách hàng được lựa chọn 1 trong 2 hình thức:
    *   **Tự đến lấy tại quán**: Khách điền Tên, SĐT và chọn khung giờ dự kiến đến lấy. Phí ship mặc định bằng 0 VNĐ.
    *   **Giao hàng tận nơi**: Khách cung cấp Tên, SĐT, Địa chỉ, và Tọa độ GPS (lấy tự động bằng trình duyệt hoặc ghim vị trí). Phí ship được tính lũy tiến:
        *   Khoảng cách $\le 2\text{ km}$: Cố định **10.000 VNĐ**.
        *   Khoảng cách $2\text{ km} < d \le 5\text{ km}$: **10.000 VNĐ + 3.500 VNĐ / km** vượt.
        *   Khoảng cách $5\text{ km} < d \le 10\text{ km}$: **20.500 VNĐ + 4.000 VNĐ / km** vượt.
        *   Khoảng cách $> 10\text{ km}$: **40.500 VNĐ + 5.000 VNĐ / km** vượt.
        *   Khoảng cách $> 50\text{ km}$: Hiển thị cảnh báo khoảng cách quá xa nhưng không tự động chặn đơn hàng.

---

## 5. LUỒNG ĐƠN HÀNG, THANH TOÁN & WEB-SOCKET
1.  **Đặt đơn & hiển thị QR tĩnh**: Khách đặt đơn thành công sẽ được điều hướng tới màn hình thanh toán. Hệ thống tự động render ảnh QR ngân hàng tĩnh và nội dung chuyển khoản theo cú pháp: `ANHTUBAKERY DH{mã_đơn}` (Ví dụ: `ANHTUBAKERY DH171928374`).
2.  **Đối chiếu & Xác nhận thủ công**: Khách thực hiện chuyển khoản bằng ứng dụng ngân hàng. Khi tiền về tài khoản thực tế của gia đình, Admin đối chiếu mã đơn trong nội dung chuyển khoản và bấm nút **"Xác nhận đã thanh toán"** trên trang Admin.
3.  **WebSocket đồng bộ thời gian thực**:
    *   Khi khách hàng ở trang theo dõi đơn hàng (`/view/track.jsp`), trình duyệt sẽ kết nối WebSocket đến server tại địa chỉ `/order-ws/{orderId}`.
    *   Khi Admin thay đổi trạng thái đơn hàng (Ví dụ: từ `PENDING` $\rightarrow$ `PAID` $\rightarrow$ `PREPARING` $\rightarrow$ `READY`), Servlet Backend gọi phương thức tĩnh `OrderWebSocket.sendStatusUpdate` để lập tức gửi tin nhắn thông báo về trình duyệt khách hàng. Giao diện trang theo dõi sẽ tự động cập nhật tiến trình (ví dụ: hiển thị thông báo "Đơn của bạn đã chuẩn bị xong, mời đến lấy" hoặc "Shipper đang giao hàng").

---

## 6. DANH SÁCH ENDPOINTS / APIS TRONG DỰ ÁN
Dữ liệu được trao đổi qua định dạng JSON thông qua các Servlet sau:

### 6.1 Servlet Xác thực & Tài khoản (`AuthServlet` -> `/auth/*`)
*   `POST /auth/login`: Đăng nhập hệ thống (cho Admin hoặc Khách lẻ).
*   `POST /auth/register`: Đăng ký tài khoản khách hàng lẻ mới.
*   `GET /auth/logout`: Đăng xuất và hủy bỏ Session hiện tại.
*   `POST /auth/update-phone`: Cập nhật số điện thoại cho tài khoản hiện tại.

### 6.2 Servlet Đơn hàng (`OrderServlet` -> `/resources/orders/*`)
*   `GET /resources/orders?phone={sđt}`: Tìm danh sách đơn hàng theo số điện thoại (dành cho khách lẻ tự tra cứu lịch sử).
*   `GET /resources/orders`: Admin lấy danh sách toàn bộ đơn hàng trong hệ thống.
*   `GET /resources/orders/{id}`: Xem chi tiết một đơn hàng cụ thể kèm theo danh sách các món ăn đã đặt.
*   `POST /resources/orders`: Tạo mới một đơn hàng (nhận dữ liệu JSON từ giỏ hàng).
*   `POST /resources/orders/{id}/status?status={trạng_thái}`: Cập nhật trạng thái đơn hàng (chỉ dành cho Admin, phát sóng WebSocket sau khi lưu thành công).

### 6.3 Servlet Đại lý (`AgentServlet` -> `/resources/agents/*`)
*   `GET /resources/agents`: Admin lấy toàn bộ danh sách đại lý.
*   `POST /resources/agents/register`: Đăng ký tài khoản đại lý sỉ mới.
*   `POST /resources/agents/login`: Đăng nhập cho đại lý (lưu Session với vai trò `AGENT`).
*   `POST /resources/agents/{id}/status?status={trạng_thái}`: Duyệt kích hoạt (`ACTIVE`) hoặc tạm khóa (`SUSPENDED`) đại lý (chỉ dành cho Admin).
*   `DELETE /resources/agents/{id}`: Xóa tài khoản đại lý (chỉ dành cho Admin).

### 6.4 Servlet Sản phẩm (`ProductServlet` -> `/resources/products/*`)
*   `GET /resources/products`: Lấy danh sách toàn bộ sản phẩm đang có trên hệ thống.
*   `GET /resources/products/{id}`: Lấy thông tin chi tiết một sản phẩm.
*   `POST /resources/products`: Tạo mới sản phẩm (chỉ dành cho Admin).
*   `PUT /resources/products/{id}`: Cập nhật thông tin sản phẩm (chỉ dành cho Admin).
*   `DELETE /resources/products/{id}`: Xóa sản phẩm (chỉ dành cho Admin).

---

## 7. HƯỚNG DẪN BUILD & CHẠY DỰ ÁN LOCAL
1.  **Yêu cầu môi trường**: Cần cài đặt JDK 17 và Maven.
2.  **Build dự án**:
    Mở Terminal tại thư mục gốc của dự án và chạy lệnh:
    ```bash
    mvn clean package
    ```
    Sau khi tiến trình hoàn thành, file lưu trữ `Bakery.war` sẽ được tạo ra tại thư mục `target/`.
3.  **Deploy lên Server**:
    Sao chép tệp `Bakery.war` vào thư mục deploy của Servlet container (ví dụ thư mục `webapps/` của Apache Tomcat).
4.  **Cấu hình Cơ sở dữ liệu**:
    *   Mặc định hệ thống tự khởi tạo một file CSDL nhúng **H2** tại thư mục `./data/bakery` trong thư mục chạy của dự án.
    *   Để đổi sang sử dụng CSDL **MySQL** hoặc **SQL Server**, hãy chỉnh sửa các cấu hình trong tệp `db.properties` hoặc thiết lập một DataSource JNDI trên máy chủ Tomcat có tên `jdbc/BakeryDB`.
