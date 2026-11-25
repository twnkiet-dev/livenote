# LiveNote — SwiftUI + ActivityKit

App iPhone cá nhân, iOS 16.2 trở lên. Không backend, không Flutter, không gói trả phí, không App Groups/APNs. Toàn bộ ghi chú được lưu cục bộ bằng UserDefaults. Bản này là source, chưa phải IPA đã ký.

## Build bằng Codemagic trên Windows

1. Giải nén ZIP, tạo GitHub repository (private được). Upload **nội dung** thư mục LiveNote, sao cho `codemagic.yaml` và `project.yml` ở thư mục gốc của repo; giữ nguyên thư mục App, Shared, Widget, scripts.
2. Trong Codemagic, thêm repository, chọn kiểu cấu hình `codemagic.yaml` (Native iOS / Other nếu được hỏi). Chọn workflow `LiveNote - IPA for sideload (unsigned)`.
3. Start build. Workflow tự cài XcodeGen nếu cần, tạo project Xcode, biên dịch app và Widget Extension cho iPhone thật, sau đó đóng gói `build/LiveNote.ipa`. Nếu lỗi, xem log build.
4. Tải IPA từ Artifacts. Đây là IPA **chưa ký**, không cài trực tiếp được. Dùng công cụ sideload có hỗ trợ ký cả app chính và Widget Extension (ví dụ Sideloadly; không chọn tùy chọn loại bỏ app extensions). Bundle ID của extension phải là con của bundle ID app chính sau khi ký lại. Nếu công cụ yêu cầu, đặt lại bundle ID cho phù hợp với tài khoản của bạn; đổi cả hai trong project.yml và build lại khi cần.
5. Cài lên iPhone, bật Developer Mode nếu hệ thống yêu cầu. Nếu dùng Apple Account miễn phí, provisioning thường hết hạn sau 7 ngày; cần ký/cài lại. Không đảm bảo mọi công cụ sideload hoặc tài khoản đều ký được extension đúng cách.

## Dùng app

- Nhập hoặc sửa ghi chú; toàn bộ text tự lưu, kể cả phần không hiển thị.
- Bấm Cập nhật Live Note. App tạo Live Activity nếu chưa có, hoặc cập nhật activity đang chạy, không tạo một activity mới mỗi lần. Nếu iOS từ chối, app báo lỗi. Không gửi notification alert riêng.
- Sau khi gửi cập nhật thành công, app thử về Home. Khóa máy để xem nội dung. Nếu vẫn ở app, vuốt về Home hoặc bấm nút khóa máy. Không dùng `exit(0)`.
- Không có nút dừng; có thể bỏ Live Activity qua màn hình khóa bằng thao tác hệ thống. Không đăng ký APNs, không cần internet để cập nhật local.

## Giới hạn iOS và lựa chọn triển khai

- iOS không có API công khai để tự đưa ứng dụng về Home. Bản sideload thử nghiệm gọi selector UIKit không công khai `suspend` sau khi ActivityKit chấp nhận yêu cầu. Có thể không hoạt động trên một phiên bản iOS hoặc khi ký lại; không dành cho App Store. Để dùng API công khai 100%, xóa `SIDELOAD_AUTO_HOME` khỏi `SWIFT_ACTIVE_COMPILATION_CONDITIONS` trong project.yml rồi build lại. Khi đó nút cập nhật sẽ ẩn bàn phím, báo trạng thái và người dùng tự vuốt/khóa máy. Không tự khóa màn hình.
- Lock Screen: cố định khung 156 pt, padding ngang 6 pt, dọc 4 pt, font hệ thống trắng trên nền tối, không tiêu đề/nhãn/timestamp. Tên app hoặc UI hệ thống bên ngoài khung vẫn do iOS quản lý.
- Chỉ lấy 10 dòng nhập đầu tiên (tính cả dòng trống) và tối đa 10 hàng hiển thị sau khi tự xuống dòng. Thuật toán TextKit đo độ rộng ở cỡ chữ 40 xuống 10 pt, lấy cỡ lớn nhất vừa khung. Nếu vẫn không đủ chỗ, cắt cuối và thêm dấu …; toàn bộ ghi chú vẫn được lưu. Có thể có sai khác nhẹ giữa phép đo TextKit và SwiftUI.
- ActivityKit giới hạn dữ liệu 4 KB, nên payload được giới hạn bảo thủ ở 3400 byte JSON; ghi chú cực dài có thể bị cắt thêm.
- iOS có thể giới hạn thời gian hiển thị, tần suất và quyền Live Activities; tối đa 8 giờ hoạt động, có thể còn trên Lock Screen tối đa 4 giờ nữa. Không tự gia hạn khi app đã đóng. Mở app cập nhật lại để tạo activity mới khi activity cũ hết hạn. Nếu Live Activity cũ đã kết thúc nhưng còn trên màn hình, có thể vuốt bỏ.
- Dynamic Island có biểu tượng ghi chú ở chế độ nhỏ, nội dung ở chế độ mở rộng. iPhone không có Dynamic Island vẫn có Lock Screen Live Activity.
- Ghi chú có thể được đọc khi máy khóa: không nhập nội dung bí mật nếu người khác có thể nhìn thấy máy.

## Xem giao diện trên Windows

Mở `preview/index.html` bằng Chrome/Edge, không cần cài gì hoặc kết nối mạng. Đây là bản mô phỏng HTML của bố cục và thuật toán co chữ, không phải SwiftUI thật. Có thể gõ trực tiếp và bấm cập nhật để mô phỏng.

## Kiểm tra / tình trạng

Source được viết cho Xcode/iOS SDK. Môi trường tạo file chỉ có Linux, không có Xcode hoặc iPhone, nên chưa compile hoặc chạy Live Activities thực tế. Có kiểm tra cú pháp Swift bằng parser và test phần cắt text độc lập. Kết quả build Codemagic và việc ký extension cần được xác nhận thực tế.

Tài liệu:
- https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities
- https://docs.codemagic.io/yaml-quick-start/building-a-native-ios-app/
- https://yonaskolb.github.io/XcodeGen/Docs/ProjectSpec.html
