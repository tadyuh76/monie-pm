# ĐIỀU LỆ DỰ ÁN (PROJECT CHARTER)
# Dự án: Monie - Ứng dụng Quản lý Tài chính Cá nhân

---

## i. Mục đích dự án

Dự án Monie được khởi tạo nhằm giải quyết vấn đề quản lý tài chính cá nhân không hiệu quả trong sinh viên và người trẻ tuổi. Nhiều người trong nhóm đối tượng này gặp khó khăn trong việc theo dõi thu chi, lập kế hoạch ngân sách, và kiểm soát chi tiêu hàng tháng, dẫn đến tình trạng thất thoát tài chính và không đạt được mục tiêu tiết kiệm.

Monie được phát triển để cung cấp một giải pháp di động, dễ sử dụng, giúp người dùng:
- Theo dõi giao dịch thu chi một cách thuận tiện
- Quản lý ngân sách theo từng hạng mục chi tiêu
- Nhận thông tin chi tiết về thói quen chi tiêu cá nhân
- Quản lý chi tiêu nhóm (cho sinh viên sống cùng phòng, bạn bè đi du lịch, v.v.)

---

## ii. Mục tiêu dự án có thể đo lường và các tiêu chí thành công liên quan

### Mục tiêu chính:

1. **Phát triển ứng dụng mobile hoàn chỉnh**
   - Tiêu chí: Ứng dụng chạy ổn định trên cả Android và iOS
   - Thành công: Tỷ lệ crash < 2%, performance score > 85/100

2. **Triển khai đầy đủ các tính năng cốt lõi**
   - Tiêu chí: 8 module chính hoàn thành và kiểm thử
   - Thành công: 100% các use case chính được implement và test pass

3. **Đạt được sự hài lòng của người dùng**
   - Tiêu chí: Khảo sát 30-50 người dùng thử nghiệm
   - Thành công: Điểm đánh giá trung bình ≥ 4.0/5.0

4. **Đảm bảo bảo mật dữ liệu người dùng**
   - Tiêu chí: Tích hợp xác thực an toàn và mã hóa dữ liệu
   - Thành công: 0 lỗ hổng bảo mật nghiêm trọng trong audit

5. **Hoàn thành đúng tiến độ học kỳ**
   - Tiêu chí: Nộp dự án trước deadline của trường
   - Thành công: Hoàn thành ≥ 90% tính năng đã cam kết

---

## iii. Yêu cầu đối với dự án

### Yêu cầu chức năng:

1. **Xác thực người dùng**
   - Đăng ký tài khoản mới với email/password
   - Đăng nhập an toàn
   - Quên mật khẩu và khôi phục tài khoản

2. **Quản lý giao dịch**
   - Thêm, sửa, xóa các giao dịch thu/chi
   - Phân loại giao dịch theo danh mục
   - Xem lịch sử giao dịch với bộ lọc

3. **Quản lý ngân sách**
   - Tạo ngân sách theo danh mục và thời gian
   - Theo dõi tiến độ sử dụng ngân sách
   - Cảnh báo khi vượt quá ngân sách

4. **Quản lý tài khoản**
   - Xem và chỉnh sửa thông tin cá nhân
   - Quản lý các nguồn tài chính (ví, ngân hàng, v.v.)

5. **Chi tiêu nhóm**
   - Tạo nhóm chi tiêu với nhiều thành viên
   - Ghi nhận và phân chia chi phí nhóm
   - Tính toán và thanh toán công nợ trong nhóm

6. **Dashboard và báo cáo**
   - Hiển thị tổng quan tài chính cá nhân
   - Biểu đồ thống kê thu chi
   - Insight về thói quen chi tiêu

7. **Phân tích tài chính thông minh với AI**
   - Phân tích xu hướng chi tiêu tự động
   - Dự đoán chi phí trong tương lai
   - Đề xuất tối ưu hóa ngân sách
   - Cảnh báo bất thường trong giao dịch

8. **Cài đặt ứng dụng**
   - Tùy chỉnh giao diện (theme sáng/tối)
   - Cài đặt thông báo
   - Quản lý ngôn ngữ

### Yêu cầu phi chức năng:

- **Hiệu suất**: Thời gian phản hồi < 2 giây cho các thao tác thông thường
- **Khả năng sử dụng**: Giao diện thân thiện, dễ học dễ dùng cho người mới
- **Bảo mật**: Mã hóa dữ liệu nhạy cảm, xác thực an toàn
- **Tương thích**: Hỗ trợ Android 7.0+ và iOS 12.0+
- **Khả năng mở rộng**: Kiến trúc Clean Architecture cho phép bảo trì và mở rộng dễ dàng

### Yêu cầu kỹ thuật:

- Ngôn ngữ lập trình: Dart
- Framework: Flutter 3.x.x
- Backend: Supabase (PostgreSQL)
- State Management: BLoC/Cubit
- Dependency Injection: GetIt
- Kiến trúc: Clean Architecture

---

## iv. Lợi ích của dự án

### Lợi ích cho người dùng cuối:

1. **Kiểm soát tài chính tốt hơn**: Người dùng có cái nhìn rõ ràng về thu chi, giúp đưa ra quyết định tài chính thông minh hơn
2. **Tiết kiệm thời gian**: Ghi chép và theo dõi tự động thay vì sổ sách thủ công
3. **Đạt mục tiêu tài chính**: Công cụ ngân sách giúp người dùng tiết kiệm hiệu quả
4. **Quản lý chi tiêu nhóm dễ dàng**: Giải quyết vấn đề chia tiền, tránh mâu thuẫn trong nhóm bạn
5. **Miễn phí và dễ tiếp cận**: Phù hợp với túi tiền sinh viên

### Lợi ích cho nhóm phát triển:

1. **Kỹ năng lập trình**: Nâng cao khả năng phát triển ứng dụng mobile với Flutter
2. **Kinh nghiệm thực tế**: Trải nghiệm quy trình phát triển phần mềm hoàn chỉnh
3. **Hiểu biết về kiến trúc**: Áp dụng Clean Architecture trong dự án thực tế
4. **Làm việc nhóm**: Rèn luyện kỹ năng collaboration và git workflow
5. **Portfolio**: Có sản phẩm thực tế để bổ sung vào hồ sơ xin việc

### Lợi ích cho trường học:

1. **Thành tích học thuật**: Dự án demo cho khóa học Project Management
2. **Ứng dụng thực tế**: Cho thấy sinh viên có thể áp dụng kiến thức vào sản phẩm hữu ích
3. **Khả năng nghiên cứu**: Cơ sở để nghiên cứu về hành vi quản lý tài chính của sinh viên

---

## v. Sơ lược về phương pháp thực hiện dự án

### Phương pháp quản lý dự án:

Dự án sử dụng **phương pháp Agile - Scrum** với các sprint 1 tuần, cho phép linh hoạt thích ứng với thay đổi và phản hồi nhanh chóng.

### Các giai đoạn thực hiện (7 tuần):

**Sprint 1 (Tuần 1): Khởi động và Setup**
- Lập Project Charter và phân công nhiệm vụ
- Thiết lập môi trường phát triển (Flutter, Supabase)
- Khởi tạo repository và CI/CD cơ bản
- Thiết kế kiến trúc Clean Architecture và database schema
- Deliverable: Project documentation, dev environment ready

**Sprint 2 (Tuần 2): Authentication & Core Infrastructure**
- Implement Authentication module (đăng ký, đăng nhập, quên mật khẩu)
- Setup state management với BLoC/Cubit
- Thiết lập dependency injection với GetIt
- Database setup và basic models
- Deliverable: Working authentication system

**Sprint 3 (Tuần 3): Transaction Management**
- CRUD operations cho giao dịch thu/chi
- Phân loại giao dịch theo danh mục
- Lịch sử giao dịch với filter và search
- Deliverable: Full transaction management feature

**Sprint 4 (Tuần 4): Budget & Dashboard**
- Budget management system
- Home dashboard với overview tài chính
- Biểu đồ và thống kê cơ bản
- Budget tracking và cảnh báo
- Deliverable: Budget feature + Dashboard

**Sprint 5 (Tuần 5): Group Spending & AI Analytics**
- Group management và shared expenses
- Debt calculation và settlement
- AI analysis integration (spending pattern, predictions)
- Deliverable: Group feature + AI insights

**Sprint 6 (Tuần 6): Polish & Testing**
- Settings module (theme, notifications, language)
- UI/UX improvements và responsiveness
- Unit testing và integration testing
- Bug fixing và performance optimization
- Deliverable: Feature-complete app

**Sprint 7 (Tuần 7): UAT & Delivery**
- User Acceptance Testing với 30-50 người dùng
- Critical bug fixes
- Final documentation (README, user guide, technical docs)
- Presentation preparation và demo video
- Deliverable: Final product + complete documentation

### Công cụ và quy trình:

- **Version Control**: Git + GitHub
- **Project Management**: GitHub Projects / Trello
- **Communication**: Zalo, Discord
- **Development**: VS Code / Android Studio
- **Testing**: Flutter Test, Manual Testing
- **Review**: Code review qua Pull Requests

### Họp nhóm:

- **Weekly Long Meeting**: Chủ nhật (2 giờ) - Sprint Planning (45p) + Review (45p) + Retrospective (30p)
- **Standup Meeting**: Thứ 2, Thứ 4, Thứ 6 (15 phút mỗi buổi) - Progress check & blockers
- **Ad-hoc meetings**: Khi cần thiết cho technical discussions hoặc urgent issues

---

## vi. Rủi ro tổng thể của dự án

| STT | Rủi ro | Mức độ | Xác suất | Tác động | Biện pháp phòng ngừa | Biện pháp ứng phó |
|-----|--------|--------|----------|----------|----------------------|-------------------|
| 1 | Thành viên nhóm bận học, deadline đồ án khác | Cao | 70% | Cao | Lập lịch làm việc rõ ràng, phân công hợp lý | Tái phân công công việc, giảm scope tính năng không cần thiết |
| 2 | Thiếu kinh nghiệm với Flutter/Clean Architecture | Trung bình | 60% | Trung bình | Học tập trước qua tutorial, code review thường xuyên | Pair programming, tìm mentor hỗ trợ |
| 3 | Vấn đề kỹ thuật với Supabase | Thấp | 30% | Cao | Backup và documentation đầy đủ, test kỹ API | Có plan B: chuyển sang Firebase hoặc local storage tạm thời |
| 4 | Thay đổi yêu cầu từ giảng viên | Trung bình | 40% | Trung bình | Xác nhận yêu cầu rõ ràng từ đầu, báo cáo tiến độ thường xuyên | Agile cho phép adapt nhanh, ưu tiên làm features quan trọng trước |
| 5 | Bug nghiêm trọng phát hiện gần deadline | Trung bình | 50% | Cao | Testing liên tục, không để tích lũy technical debt | Tập trung toàn bộ team fix bug, có thể delay features ít quan trọng |
| 6 | Mất dữ liệu code do sự cố | Thấp | 20% | Rất cao | Git backup thường xuyên, push code mỗi ngày | Restore từ GitHub, mỗi thành viên có local backup |
| 7 | Conflict trong nhóm về technical decision | Thấp | 25% | Trung bình | Quy định rõ process decision making, PM có quyền quyết định cuối | Họp team để thảo luận, voting nếu cần |

---

## vii. Tóm tắt cột mốc tiến độ

| Cột mốc | Mô tả | Ngày dự kiến | Deliverables |
|---------|-------|--------------|--------------|
| **M1: Project Initialization** | Hoàn thành setup và planning | Tuần 1 | - Project Charter<br>- Architecture Document<br>- Git repo setup<br>- Supabase config |
| **M2: Core Authentication** | Authentication module hoạt động | Tuần 2 | - User registration/login<br>- State management setup<br>- Database models |
| **M3: Transaction System** | Quản lý giao dịch hoàn chỉnh | Tuần 3 | - Transaction CRUD<br>- Category management<br>- Transaction history |
| **M4: Budget & Dashboard** | Ngân sách và dashboard | Tuần 4 | - Budget management<br>- Home dashboard<br>- Basic charts & analytics |
| **M5: Advanced Features** | Tính năng nâng cao | Tuần 5 | - Group spending<br>- AI analysis<br>- Smart insights |
| **M6: Feature Complete** | Hoàn thành tất cả tính năng | Tuần 6 | - Settings module<br>- All 8 modules working<br>- UI/UX polished<br>- Testing completed |
| **M7: Project Delivery** | Bàn giao dự án | Tuần 7 | - UAT completed<br>- Final Report<br>- Presentation<br>- Demo Video |

---

## viii. Nguồn tài chính được phê duyệt trước

### Tổng ngân sách dự án: 1.800.000 VNĐ

| Hạng mục | Mô tả | Chi phí (VNĐ) | Ghi chú |
|----------|-------|---------------|---------|
| **1. Chi phí phát triển** | | **0** | |
| - Supabase Hosting | Free tier | 0 | Đủ cho development & testing |
| - Flutter & Dev Tools | Open source | 0 | VS Code, Android Studio free |
| - Version Control | GitHub Free | 0 | Unlimited public repos |
| **2. Chi phí nghiên cứu & học tập** | | **400.000** | |
| - Online Resources | Udemy courses, tài liệu | 250.000 | Flutter, Clean Architecture, AI/ML |
| - Documentation & Books | eBooks, technical docs | 150.000 | Digital resources |
| **3. Chi phí testing** | | **600.000** | |
| - User Testing Incentives | Khảo sát người dùng (quà tặng) | 400.000 | 40 người x 10k/người |
| - Testing Tools | Firebase Test Lab trial | 0 | Free tier |
| - Device Testing | Mượn từ members | 0 | Team devices |
| - QA Documentation | In checklist, test cases | 200.000 | Printing & materials |
| **4. Chi phí AI/ML Services** | | **300.000** | |
| - AI API Costs | OpenAI/Gemini API credits | 200.000 | For AI analysis feature |
| - ML Model Training | Cloud compute (trial) | 100.000 | Google Colab Pro if needed |
| **5. Chi phí vận hành** | | **350.000** | |
| - Internet & Communication | Mạng cho họp online | 100.000 | 7 tuần (~15k/tuần) |
| - Team Meetings | Coffee, workspace | 150.000 | 5 team meetings |
| - Printing & Presentation | In báo cáo, poster, tài liệu | 100.000 | Final deliverables |
| **6. Chi phí dự phòng** | | **150.000** | |
| - Contingency | Rủi ro phát sinh | 150.000 | ~8.3% của tổng |

### Nguồn kinh phí:

1. **Tự đóng góp của nhóm**: 1.500.000 VNĐ (250.000 VNĐ/người x 6 người)
2. **Tài trợ từ gia đình/cá nhân**: 300.000 VNĐ

### Quản lý tài chính:

- **Quản lý**: Tất cả chi phí được ghi chép trong Google Sheets chia sẻ
- **Phê duyệt**: Chi phí > 500.000 VNĐ cần thống nhất toàn nhóm
- **Báo cáo**: Báo cáo tài chính sau mỗi sprint

---

## ix. Danh sách các bên liên quan chính và Ma trận quản lý Stakeholder

### Danh sách Stakeholders:

| STT | Tên/Vai trò | Tổ chức | Vai trò trong dự án | Thông tin liên hệ |
|-----|-------------|---------|---------------------|-------------------|
| 1 | Giảng viên hướng dẫn | Trường Đại học Kinh tế TP.HCM (UEH) | Sponsor, Mentor | Email: instructor@ueh.edu.vn |
| 2 | Nguyễn Văn A | Development Team | Team Leader | Email: member1@ueh.edu.vn |
| 3 | Trần Thị B | Development Team | Project Manager | Email: member2@ueh.edu.vn |
| 4 | Lê Văn C | Development Team | Fullstack Mobile Developer | Email: member3@ueh.edu.vn |
| 5 | Phạm Thị D | Development Team | Fullstack Mobile Developer | Email: member4@ueh.edu.vn |
| 6 | Hoàng Văn E | Development Team | UI/UX Designer | Email: member5@ueh.edu.vn |
| 7 | Vũ Thị F | Development Team | QA/QC Engineer | Email: member6@ueh.edu.vn |
| 8 | Sinh viên UEH | Cộng đồng sinh viên | End Users, Beta Testers | N/A |
| 9 | Ban quản lý khoa | Khoa CNTT - UEH | Approver | Email: department@ueh.edu.vn |

### Ma trận Quản lý Stakeholder:

| Stakeholder | Mức độ quan tâm | Mức độ ảnh hưởng | Chiến lược quản lý | Hành động cụ thể |
|-------------|-----------------|------------------|-------------------|------------------|
| **Giảng viên hướng dẫn** | Cao | Cao | **Manage Closely** | - Báo cáo tiến độ 2 tuần/lần<br>- Xin feedback về direction<br>- Demo sau mỗi sprint<br>- Họp 1-on-1 khi cần |
| **Development Team** | Rất cao | Cao | **Manage Closely** | - Daily standup<br>- Sprint planning/review<br>- Transparent communication<br>- Fair workload distribution |
| **Sinh viên UEH** | Trung bình | Thấp | **Keep Informed** | - Khảo sát nhu cầu đầu dự án<br>- Mời tham gia UAT<br>- Thu thập feedback sau testing<br>- Announcement về launch |
| **Ban quản lý khoa** | Thấp | Trung bình | **Keep Satisfied** | - Submit báo cáo theo yêu cầu<br>- Tuân thủ quy định của khoa<br>- Invite đến demo day (nếu có) |

### Kế hoạch Communication:

| Stakeholder | Phương thức | Tần suất | Nội dung |
|-------------|-------------|----------|----------|
| Giảng viên | Email, Meeting | Mỗi tuần | Weekly progress report, sprint demo, issues |
| Team Members | Discord, Zalo, GitHub | Hàng ngày | Daily standup, code review, collaboration |
| End Users | Google Forms, In-app | 3 lần (Tuần 1, 5, 7) | Initial survey, beta testing, final feedback |
| Ban quản lý khoa | Email | Theo yêu cầu | Formal reports, documentation |

---

## x. Tiêu chí thoát khỏi dự án

### Điều kiện để đóng dự án thành công:

Dự án được coi là hoàn thành khi tất cả các điều kiện sau được đáp ứng:

1. **Hoàn thành chức năng**:
   - ✅ Tất cả 8 module chính đã được implement và test
   - ✅ Ít nhất 90% use cases được cover
   - ✅ Không còn critical bugs hoặc blocking issues

2. **Chất lượng kỹ thuật**:
   - ✅ Code coverage ≥ 60% cho business logic
   - ✅ Ứng dụng chạy ổn định trên cả Android và iOS
   - ✅ Đạt performance benchmarks đã định (load time < 2s)

3. **Chấp nhận người dùng**:
   - ✅ UAT completed với ≥ 30 users
   - ✅ User satisfaction score ≥ 4.0/5.0
   - ✅ Không có major usability issues

4. **Tài liệu đầy đủ**:
   - ✅ README và technical documentation hoàn chỉnh
   - ✅ User manual/guide
   - ✅ API documentation (nếu có)
   - ✅ Final project report

5. **Phê duyệt từ giảng viên**:
   - ✅ Giảng viên hướng dẫn approve dự án
   - ✅ Presentation/demo được đánh giá đạt yêu cầu
   - ✅ Báo cáo cuối kỳ đã nộp và được chấp nhận

6. **Bàn giao**:
   - ✅ Source code pushed lên GitHub repository
   - ✅ Database backup và migration scripts
   - ✅ Deployment guide (nếu deploy)

### Điều kiện để hủy/tạm dừng dự án:

Dự án có thể bị hủy bỏ hoặc tạm dừng trong các trường hợp sau:

1. **Rủi ro nghiêm trọng**:
   - ❌ > 50% team members không thể tiếp tục (lý do sức khỏe, gia đình, v.v.)
   - ❌ Phát hiện technical blocker không thể giải quyết (ví dụ: Flutter không support requirement quan trọng)
   - ❌ Ngân sách vượt quá 150% dự kiến và không thể bổ sung

2. **Thay đổi yêu cầu lớn**:
   - ❌ Giảng viên yêu cầu thay đổi > 50% scope
   - ❌ Phát hiện duplicate với dự án khác và phải làm lại hoàn toàn

3. **Vấn đề pháp lý/chính sách**:
   - ❌ Vi phạm quy định của trường
   - ❌ Vấn đề bản quyền không giải quyết được

4. **Quyết định của sponsor**:
   - ❌ Giảng viên/khoa quyết định hủy dự án

### Quy trình thoát khỏi dự án:

1. **Họp review với tất cả stakeholders**
2. **Đánh giá lessons learned**
3. **Lưu trữ tất cả artifacts** (code, docs, assets)
4. **Viết final report** (summary, achievements, challenges)
5. **Bàn giao tài sản** (nếu có)
6. **Celebration** 🎉 (nếu thành công) hoặc **Retrospective** (nếu hủy)

---

## xi. Giám đốc dự án được giao, trách nhiệm và cấp thẩm quyền

### Thông tin Team Leader:

- **Họ tên**: Nguyễn Văn A
- **Vai trò**: Team Leader
- **Thời gian bổ nhiệm**: Từ ngày bắt đầu dự án đến khi kết thúc
- **Báo cáo cho**: Giảng viên hướng dẫn

### Thông tin Project Manager:

- **Họ tên**: Trần Thị B
- **Vai trò**: Project Manager
- **Thời gian bổ nhiệm**: Từ ngày bắt đầu dự án đến khi kết thúc
- **Báo cáo cho**: Team Leader & Giảng viên hướng dẫn

### Cơ cấu nhóm phát triển:

| Vai trò | Thành viên | Trách nhiệm chính |
|---------|-----------|-------------------|
| **Team Leader** | Nguyễn Văn A | Lãnh đạo team, quyết định kỹ thuật, architecture design, code review |
| **Project Manager** | Trần Thị B | Quản lý tiến độ, resource planning, stakeholder communication, risk management |
| **Fullstack Mobile Developer** | Lê Văn C | Frontend (UI/UX implementation), Backend (API integration), AI features |
| **Fullstack Mobile Developer** | Phạm Thị D | Frontend (screens & widgets), Backend (Supabase, auth, database), state management |
| **UI/UX Designer** | Hoàng Văn E | Design system, mockups, prototypes, user flow, visual design, branding |
| **QA/QC Engineer** | Vũ Thị F | Test planning, test cases, manual & automated testing, bug tracking, quality assurance |

### Trách nhiệm chính của Team Leader:

1. **Technical Leadership**:
   - Thiết kế kiến trúc hệ thống (Clean Architecture)
   - Quyết định technical stack và tools
   - Code review cho tất cả pull requests
   - Giải quyết technical blockers
   - Mentor developers về best practices

2. **Quản lý chất lượng kỹ thuật**:
   - Enforce coding standards và conventions
   - Đảm bảo code quality và maintainability
   - Review architecture và design patterns
   - Performance optimization

3. **Coordination**:
   - Phối hợp giữa PM và developers
   - Làm việc với Designer về technical feasibility
   - Support QA/QC trong test planning
   - Final decision maker cho technical disputes

4. **Development**:
   - Tham gia coding cho critical features
   - Setup CI/CD và development environment
   - Database schema design

### Trách nhiệm chính của Project Manager:

1. **Quản lý tiến độ**:
   - Lập và duy trì project schedule (Gantt chart, sprint backlog)
   - Theo dõi tiến độ các task và sprint hàng ngày
   - Đảm bảo dự án hoàn thành đúng 7 tuần
   - Identify và resolve bottlenecks

2. **Quản lý team và resource**:
   - Phân công công việc cho từng thành viên
   - Tổ chức các buổi họp: daily standup, sprint planning, review, retrospective
   - Theo dõi workload và productivity
   - Đảm bảo team có đủ resources

3. **Quản lý stakeholders**:
   - Báo cáo tiến độ cho giảng viên hàng tuần
   - Liên lạc với giảng viên hướng dẫn
   - Tổ chức demo và thu thập feedback
   - Maintain communication plan

4. **Quản lý rủi ro**:
   - Identify và đánh giá risks
   - Xây dựng risk mitigation plans
   - Monitor và respond to issues khi phát sinh
   - Escalate critical issues

5. **Quản lý tài chính**:
   - Theo dõi budget và chi phí
   - Approve expenses < 500K VND
   - Báo cáo tài chính sau mỗi sprint

6. **Documentation**:
   - Maintain project documentation
   - Meeting minutes và decision logs
   - Status reports và presentations

### Cấp thẩm quyền:

| Quyết định | Team Leader | Project Manager | Điều kiện |
|------------|-------------|-----------------|-----------|
| **Quyết định kỹ thuật (architecture, stack, patterns)** | Toàn quyền (final say) | Tham vấn | Sau khi thảo luận với developers |
| **Phân công công việc** | Tham vấn | Toàn quyền | Đảm bảo fair và skill-appropriate |
| **Code review approval** | Toàn quyền | Không | Review trước khi merge |
| **Thay đổi schedule trong sprint** | Tham vấn | Toàn quyền | Thông báo team và giảng viên |
| **Thay đổi scope nhỏ (< 5% effort)** | Cùng quyết định | Cùng quyết định | Log trong sprint report |
| **Thay đổi scope lớn (> 5% effort)** | Không | Không | Cần approval từ giảng viên |
| **Chi phí < 500.000 VNĐ** | Không | Toàn quyền | Báo cáo trong financial report |
| **Chi phí > 500.000 VNĐ** | Không | Cần consensus từ toàn team | Vote trong team meeting |
| **Giải quyết technical conflict** | Toàn quyền | Hỗ trợ facilitation | TL có final decision |
| **Giải quyết team conflict** | Hỗ trợ | Toàn quyền | PM lead, TL support |
| **Thêm/bớt team member** | Không | Không | Cần approval từ giảng viên |
| **Hủy bỏ dự án** | Không | Không | Chỉ giảng viên hoặc khoa quyết định |

### Hỗ trợ và Escalation:

- **Mentor kỹ thuật**: Giảng viên hướng dẫn (cho TL)
- **Escalation path**: Team Member → TL/PM → Giảng viên → Ban quản lý khoa
- **Khi nào escalate**:
  - Technical: Developer → Team Leader → Giảng viên
  - Process/Timeline: Developer → Project Manager → Team Leader → Giảng viên
  - Rủi ro nghiêm trọng ảnh hưởng timeline/scope
  - Conflict không thể resolve trong team

### KPI đánh giá Team Leader:

1. **Code Quality**: Code review turnaround < 24h, < 10 critical bugs at delivery
2. **Technical Excellence**: Architecture documented, coding standards established
3. **Team Development**: Developers report improvement in technical skills
4. **System Performance**: App performance meets benchmarks (< 2s load time)
5. **Collaboration**: Effective coordination giữa PM và developers

### KPI đánh giá Project Manager:

1. **On-time delivery**: 100% sprints (7/7) hoàn thành đúng hạn
2. **Budget Management**: Chi phí không vượt quá 110% budget
3. **Team satisfaction**: Team feedback score ≥ 4.0/5.0
4. **Communication**: 100% weekly reports submitted on time (7/7 tuần)
5. **Stakeholder satisfaction**: Giảng viên feedback ≥ 4.0/5.0
6. **Risk Management**: Identify và mitigate 100% high-priority risks

---

## Phê duyệt

| Vai trò | Họ tên | Chữ ký | Ngày |
|---------|--------|--------|------|
| **Team Leader** | Nguyễn Văn A | _________________ | ___/___/2025 |
| **Project Manager** | Trần Thị B | _________________ | ___/___/2025 |
| **Fullstack Mobile Developer** | Lê Văn C | _________________ | ___/___/2025 |
| **Fullstack Mobile Developer** | Phạm Thị D | _________________ | ___/___/2025 |
| **UI/UX Designer** | Hoàng Văn E | _________________ | ___/___/2025 |
| **QA/QC Engineer** | Vũ Thị F | _________________ | ___/___/2025 |
| **Giảng viên hướng dẫn** | [Tên giảng viên] | _________________ | ___/___/2025 |
| **Trưởng khoa CNTT** | [Tên trưởng khoa] | _________________ | ___/___/2025 |

---

**Ghi chú**: Tài liệu này là phiên bản 1.0 và có thể được cập nhật trong quá trình thực hiện dự án. Mọi thay đổi quan trọng cần được phê duyệt bởi giảng viên hướng dẫn.

**Ngày tạo**: [Điền ngày hiện tại]
**Người tạo**: Nguyễn Văn A (Team Leader) & Trần Thị B (Project Manager)
**Trạng thái**: Draft / Pending Approval

---

## Phụ lục: Bảng phân công công việc chi tiết

| Tuần | Module/Feature | TL | PM | Dev 1 (Lê Văn C) | Dev 2 (Phạm Thị D) | Designer (Hoàng Văn E) | QA/QC (Vũ Thị F) |
|------|----------------|----|----|------------------|-------------------|----------------------|------------------|
| 1 | Project Setup & Planning | Setup repo, architecture | Schedule, charter | Dev env setup | Dev env setup | Design system kickoff | Test plan draft |
| 2 | Authentication | Code review | Track progress | Auth UI | Auth backend (Supabase) | Login/signup screens | Test cases auth |
| 3 | Transaction Management | Code review, integration | Track progress | Transaction UI & list | Transaction CRUD & DB | Transaction screens | Test transaction flows |
| 4 | Budget & Dashboard | Code review | Track progress | Dashboard UI & charts | Budget logic & DB | Dashboard & budget design | Test budget features |
| 5 | Group Spending & AI | Code review, AI integration | Track progress | Group UI & AI features | Group backend & calculations | Group screens | Test group & AI |
| 6 | Settings & Polish | Code review | Track progress | Settings & themes | Notifications & locale | Polish UI/UX | Full regression testing |
| 7 | UAT & Delivery | Support UAT | Coordinate UAT | Bug fixes | Bug fixes | Final touches | UAT coordination & report |

**Phân chia trách nhiệm cụ thể:**

- **Nguyễn Văn A (Team Leader)**:
  - Architect Clean Architecture layers
  - Setup BLoC/Cubit patterns
  - Code review tất cả PRs
  - Integration giữa modules
  - Critical features development

- **Trần Thị B (Project Manager)**:
  - Daily standup facilitation
  - Sprint planning & retrospectives
  - Weekly reports to instructor
  - Risk tracking & mitigation
  - Budget management

- **Lê Văn C (Fullstack Dev 1)**:
  - Focus: Frontend UI implementation
  - AI/ML feature integration
  - Group spending frontend
  - Charts & data visualization

- **Phạm Thị D (Fullstack Dev 2)**:
  - Focus: Backend & data layer
  - Supabase integration
  - Database schema & queries
  - State management with BLoC

- **Hoàng Văn E (UI/UX Designer)**:
  - Design system & style guide
  - All screen mockups in Figma
  - User flow diagrams
  - Visual assets & icons

- **Vũ Thị F (QA/QC Engineer)**:
  - Test strategy & test plans
  - Test cases for all features
  - Manual testing execution
  - Bug tracking & reporting
  - UAT coordination

**Testing Strategy:**
- **Unit Testing**: Developers test own code (Target: 60% coverage for domain layer)
- **Integration Testing**: Tuần 5-6, QA/QC leads với dev support
- **User Acceptance Testing**: Tuần 7 với 40 users thực tế
- **Bug Tracking**: GitHub Issues với labels: `bug`, `critical`, `high`, `medium`, `low`
- **Test Environments**: Dev, Staging (pre-UAT), Production

**Communication Protocol:**
- **Weekly Long Meeting**: Chủ nhật 7:00 PM (Discord/Zoom) - 2 giờ
  - Sprint Planning (45p): Plan tasks for upcoming week
  - Sprint Review (45p): Demo completed features
  - Retrospective (30p): What went well, what to improve
- **Bi-daily Standup**: Thứ 2, Thứ 4, Thứ 6 @ 9:00 AM (Discord) - 15 phút
  - What did you do since last meeting?
  - What will you do next?
  - Any blockers?
- **Async Communication**: Discord channel 24/7 cho updates và questions
- **Code Review**: Max 24h turnaround, review qua GitHub PR
- **Blocker Escalation**: Immediately ping TL/PM in Discord
- **Weekly Report**: PM sends report to instructor every Sunday evening
