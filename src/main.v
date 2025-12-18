/*              
Module tang cao nhat dieu khien du lieu hien thi len LCD
Thay doi FSM trong module nay de dieu khien du lieu hien 
thi mong muon. Nhat thiet phai co FSM dau tien de khoi
tao LCD
*/

module top_moduleLCD(
    input clk,
    input rst,

    output wire xong,
    output wire xongIOC,

    inout sda,
    inout scl
);
    parameter LCD_ADDRESS = 7'h27;
    parameter READ = 1'b1;
    parameter WRITE = 1'b0;

    parameter INIT = 0;
    parameter READ_TCS34725 = 1;
    parameter RESET_CURSER = 2;
    parameter DISPLAY_TEMP = 3;
    parameter SET_ADDRESS = 4;
    parameter DISPLAY_HUMI = 5;

    wire clk100k, clk1M, clk1500k;
    wire doneLCD, doneIOC, doneRT, doneRK, doneRL;

    wire [15:0] data_blue;
    wire [15:0] data_green;
    wire [15:0] data_red;
    wire [15:0] data_clear;

    integer Index_Display_Temp = 0;
    integer count = 0;

    reg enable = 0;
    reg enableRT = 0;
    reg enableIOC = 0;
    reg enableTCS34725 = 0;

    reg [7:0] data;
    reg [7:0] add;
    reg modeLCD;
    reg [1:0] modeRT;
    reg init = 0;
    reg [1:0] check;
    reg check_RL = 0;
    reg [15:0] data_display = 0;
    
    integer fsm = 0;

    // Thêm các biến để tính phần trăm và xác định màu
    reg [15:0] percent_red;
    reg [15:0] percent_green;
    reg [15:0] percent_blue;
    reg [3:0] color_state; // 0: Không xác định, 1: Đỏ, 2: Xanh lá, 3: Xanh dương

    LCD_clk clk100KHZ(
        .clk27m(clk), 
        .rst(rst), 
        .clk100k(clk100k)
    );
 
    clk_1500k clk1500KHZ(
        .clk27m(clk), 
        .rst(rst), 
        .clk1500k(clk1500k)
    );
    
    LCD_Initorcontrol IOC(
        .clk(clk100k), 
        .rst(rst), 
        .enable(enableIOC), 
        .init(init), 
        .mode(modeLCD), 
        .datain(data), 
        .add(add), 
        .done(doneLCD), 
        .doneIOC(doneIOC), 
        .sda(sda), 
        .scl(scl)
    );

    TCS34725_Read TCS(
        .clk(clk1500k),
        .enable(enableTCS34725),
        .rst(rst),
        .done(doneRL),
        .data_red(data_red),
        .data_blue(data_blue),
        .data_clear(data_clear),
        .data_green(data_green),
        .sda(sda),
        .scl(scl)
    );

    always @(posedge clk100k) begin
        if (~rst) begin
            fsm <= INIT;
            enableIOC <= 0;
            enableTCS34725 <= 0;
            Index_Display_Temp <= 0;
            count <= 0;
            check_RL <= 0;
            percent_red <= 0;
            percent_green <= 0;
            percent_blue <= 0;
            color_state <= 0;
        end
        else begin
            case (fsm)
                INIT: begin                                
                    enableIOC <= 1;
                    add <= {LCD_ADDRESS, WRITE};
                    init <= 1;
                    modeLCD <= 0;
                    if (doneLCD) begin
                        enableIOC <= 0;
                        init <= 0;
                        fsm <= READ_TCS34725;
                    end
                end
             
                READ_TCS34725: begin
                    enableTCS34725 <= 1;
                    if (doneRL) begin
                        // Tính phần trăm
                        percent_red <= (data_clear > 0) ? (data_red * 100 / data_clear) : 0;
                        percent_green <= (data_clear > 0) ? (data_green * 100 / data_clear) : 0;
                        percent_blue <= (data_clear > 0) ? (data_blue * 100 / data_clear) : 0;

                        // Xác định màu
                        if (percent_red > 50) begin
                            color_state <= 1; // Đỏ
                        end else if (percent_green > 50) begin
                            color_state <= 2; // Xanh lá
                        end else if (percent_blue > 50) begin
                            color_state <= 3; // Xanh dương
                        end else begin
                            color_state <= 0; // Không xác định
                        end

                        enableTCS34725 <= 0;
                        fsm <= RESET_CURSER;
                    end
                end

                RESET_CURSER: begin
                    enableIOC <= 1;
                    add <= {LCD_ADDRESS, WRITE};
                    data <= 8'h02;
                    init <= 0;
                    modeLCD <= 0;
                    if (doneLCD) begin
                        fsm <= DISPLAY_TEMP;
                        enableRT <= 0;
                    end
                end

                DISPLAY_TEMP: begin                               
                    enableIOC <= 1;
                    case (Index_Display_Temp)  
                        0: data <= "A";
                        1: data <= "N";
                        2: data <= "H";
                        3: data <= " ";
                        4: data <= "S";
                        5: data <= "A";
                        6: data <= "N";
                        7: data <= "G";
                        8: data <= ":";
                        9: data <= " ";
                        10: data <= "~";
                        11: data <= 48 + data_clear/10000;
                        12: data <= 48 + (data_clear%10000)/1000;
                        13: data <= 48 + (data_clear%1000)/100;
                        14: data <= 48 + (data_clear%100)/10;
                        15: data <= 48 + data_clear%10;
                    endcase
                    add <= {LCD_ADDRESS, WRITE};
                    init <= 0;
                    modeLCD <= 1;
                    if (doneLCD) begin
                        enableIOC <= 0;
                        Index_Display_Temp <= Index_Display_Temp + 1;
                        if (Index_Display_Temp == 15) begin
                            Index_Display_Temp <= 0;
                            fsm <= SET_ADDRESS;
                        end
                    end
                end

                SET_ADDRESS: begin
                    enableIOC <= 1;
                    add <= {LCD_ADDRESS, WRITE};
                    data <= 8'hC0;
                    init <= 0;
                    modeLCD <= 0;
                    if (doneLCD) begin
                        fsm <= DISPLAY_HUMI;
                        enableIOC <= 0;
                    end
                end

                DISPLAY_HUMI: begin                               
                    enableIOC <= 1;
                    case (color_state)
                        0: begin // Không xác định: "Khong xac dinh"
                            case (Index_Display_Temp)  
                                0: data <= "K";
                                1: data <= "h";
                                2: data <= "o";
                                3: data <= "n";
                                4: data <= "g";
                                5: data <= " ";
                                6: data <= "x";
                                7: data <= "a";
                                8: data <= "c";
                                9: data <= " ";
                                10: data <= "d";
                                11: data <= "i";
                                12: data <= "n";
                                13: data <= "h";
                                default: data <= " ";
                            endcase
                        end
                        1: begin // Đỏ: "Mau: Do"
                            case (Index_Display_Temp)  
                                0: data <= "M";
                                1: data <= "a";
                                2: data <= "u";
                                3: data <= ":";
                                4: data <= " ";
                                5: data <= "D";
                                6: data <= "o";
                                default: data <= " ";
                            endcase
                        end
                        2: begin // Xanh lá: "Mau: Xanh La"
                            case (Index_Display_Temp)  
                                0: data <= "M";
                                1: data <= "a";
                                2: data <= "u";
                                3: data <= ":";
                                4: data <= " ";
                                5: data <= "X";
                                6: data <= "a";
                                7: data <= "n";
                                8: data <= "h";
                                9: data <= " ";
                                10: data <= "L";
                                11: data <= "a";
                                default: data <= " ";
                            endcase
                        end
                        3: begin // Xanh dương: "Mau: Xanh Duong"
                            case (Index_Display_Temp)  
                                0: data <= "M";
                                1: data <= "a";
                                2: data <= "u";
                                3: data <= ":";
                                4: data <= " ";
                                5: data <= "X";
                                6: data <= "a";
                                7: data <= "n";
                                8: data <= "h";
                                9: data <= " ";
                                10: data <= "D";
                                11: data <= "u";
                                12: data <= "o";
                                13: data <= "n";
                                14: data <= "g";
                                default: data <= " ";
                            endcase
                        end
                    endcase
                    add <= {LCD_ADDRESS, WRITE};
                    init <= 0;
                    modeLCD <= 1;
                    if (doneLCD) begin
                        enableIOC <= 0;
                        Index_Display_Temp <= Index_Display_Temp + 1;
                        if (Index_Display_Temp == 15) begin
                            Index_Display_Temp <= 0;
                            fsm <= READ_TCS34725;
                        end
                    end
                end
            endcase
        end
    end

    assign xong = data;
    assign xongIOC = data;
endmodule