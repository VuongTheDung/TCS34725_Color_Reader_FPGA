FPGA-Based RGB Color Recognition using Tang Nano 9K
📌 Giới thiệu

Dự án FPGA-Based RGB Color Recognition using Tang Nano 9K là một hệ thống nhận diện màu sắc được thiết kế và triển khai hoàn toàn trên phần cứng FPGA. Hệ thống sử dụng cảm biến màu RGB TCS34725 để thu thập dữ liệu ánh sáng, xử lý trực tiếp trên FPGA Tang Nano 9K, và hiển thị kết quả lên màn hình LCD 16x2 thông qua giao tiếp I2C.

Mục tiêu của dự án là nghiên cứu khả năng xử lý song song, tính linh hoạt và hiệu suất cao của FPGA trong các ứng dụng hệ thống nhúng, đồng thời làm chủ thiết kế I2C Master, FSM điều khiển, và giao tiếp ngoại vi bằng Verilog HDL.

🎯 Mục tiêu dự án

    Thiết kế hệ thống nhận diện màu sắc RGB sử dụng FPGA Tang Nano 9K

    Xây dựng I2C Master thuần phần cứng để giao tiếp với cảm biến và LCD

    Đọc và xử lý dữ liệu RGBC (Red, Green, Blue, Clear) từ cảm biến TCS34725

    Hiển thị kết quả màu sắc và cường độ ánh sáng lên LCD 16x2

🧩 Kiến trúc hệ thống

Hệ thống gồm 3 khối chính:
    
Khối cảm biến (TCS34725)

    Thu thập dữ liệu ánh sáng RGBC

    Giao tiếp với FPGA thông qua I2C (địa chỉ mặc định: 0x29)

Khối xử lý trung tâm (FPGA Tang Nano 9K)

    Điều khiển giao tiếp I2C

    Xử lý và chuẩn hóa dữ liệu màu sắc

    Điều khiển luồng hiển thị LCD bằng FSM

Khối hiển thị (LCD 16x2 + PCF8574)

    Nhận dữ liệu từ FPGA qua I2C (địa chỉ mặc định: 0x27)

    Hiển thị giá trị RGB và cường độ ánh sáng

🛠 Phần cứng sử dụng

    FPGA: Sipeed Tang Nano 9K (GW1NR-9)

    Cảm biến màu: TCS34725 (RGB + Clear, I2C)

    Màn hình hiển thị: LCD 16x2 (Driver HD44780)

    Module I2C LCD: PCF8574

Nguồn cấp: 3.3V (USB Type-C)

💻 Phần mềm & công cụ

    Ngôn ngữ mô tả phần cứng: Verilog HDL

    IDE: Gowin FPGA Designer

    Clock hệ thống: 27 MHz (on-board)

🧠 Thiết kế chức năng chính
1. I2C Master (FPGA)

Thiết kế hoàn toàn bằng Verilog

Hỗ trợ:

    Start / Stop condition

    ACK / NACK

    Ghi và đọc nhiều byte

Gồm 2 module chính:

    i2c_send.v

    i2c_receive.v

2. Giao tiếp cảm biến TCS34725

Cấu hình các thanh ghi:

    Enable (PON, AEN)

    Thời gian tích hợp (ATIME = 24 ms)

    Độ lợi (AGAIN = 1x)

    Đọc dữ liệu từ các thanh ghi:

    Clear: 0x14 – 0x15

    Red: 0x16 – 0x17

    Green: 0x18 – 0x19

    Blue: 0x1A – 0x1B

3. Điều khiển LCD 16x2 (I2C)

    Giao tiếp thông qua PCF8574

    Chế độ 4-bit

    FSM điều khiển:

    Khởi tạo LCD

    Đặt con trỏ

    Hiển thị chuỗi ký tự RGB

📷 Hình ảnh phần cứng

<img width="1920" height="2560" alt="image" src="https://github.com/user-attachments/assets/ad9c7b3e-9654-4b5a-9771-7f46ececcaa1" />

<img width="1920" height="2560" alt="image" src="https://github.com/user-attachments/assets/d971c212-4ccb-4c01-8ebc-42991c2a65b3" />

<img width="1920" height="2560" alt="image" src="https://github.com/user-attachments/assets/caf99c8d-b3f6-48c4-93b8-f8143c6c19db" />


