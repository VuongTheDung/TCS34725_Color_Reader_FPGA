module TCS34725_Read(
    input clk,                                                  
    input enable,
    input rst,
    //input [7:0] add,
    output reg [15:0] data_green,
    output reg [15:0] data_blue,
    output reg [15:0] data_clear,
    output reg [15:0] data_red,
    output reg done,

    inout sda,
    inout scl
);
    parameter TCS34725_add = 7'h29;
    parameter MODE_READ = 1'b1;
    parameter MODE_WRITE = 1'b0;
          

    integer state = 0;
    integer count = 0;
    reg enable_send = 0, enable_receive = 0;
    reg [7:0] add;
    reg [7:0] add_reg = 0;
    reg [7:0] datain;
    reg repeat_start = 0;

    reg [7:0] data_clear_m;
    reg [7:0] data_clear_l;
    reg [7:0] data_red_m;
    reg [7:0] data_reg_l;
    reg [7:0] data_green_m;
    reg [7:0] data_green_l;
    reg [7:0] data_blue_m;
    reg [7:0] data_blue_l;

    wire [7:0] data_r;
    wire done_send, done_receice;

    i2c_receive uut(.clk(clk), .data(data_r), .enable(enable_receive), .rst(rst), .scl_i2c(scl), .sda(sda), .done(done_receice), .add(add));
    LCD_Send SendLCD(.clk(clk), .rst(rst), .enable(enable_send), .add_reg(add_reg), .num_byte(1), .data(datain), .add(add), .done(done_send), .scl_i2c(scl), .sda(sda), .repeat_start(repeat_start)); 

    always @(posedge clk) begin
        if (~rst || ~ enable) begin
            state <= 0;
            done <= 0;
            repeat_start <= 0;
            count <= 0;
            enable_receive <= 0;
            enable_send <= 0;
        end
        else begin
            done <= 0;
            repeat_start <= 0;
            case (state) 


/////////////////////////////////INIT///////////////////////////////////
                0: begin
                    add <= {TCS34725_add , MODE_WRITE};
                    add_reg <= 8'h00 | 8'h80;
                    enable_send <= 1;
                    enable_receive <= 0;
                    datain <= 8'h03;        //Power on, Enable RGBC 
                    if (done_send) begin
                        enable_send <= 0;
                        state <= 1;
                    end
                end
                1: begin
                    add <= {TCS34725_add , MODE_WRITE};
                    add_reg <= 8'h01 | 8'h80;
                    enable_send <= 1;
                    enable_receive <= 0;
                    datain <= 8'hd5; 
                    if (done_send) begin
                        enable_send <= 0;
                        state <= 2;
                    end
                end
                2: begin
                    add <= {TCS34725_add , MODE_WRITE};
                    add_reg <= 8'h0f | 8'h80;
                    enable_send <= 1;
                    enable_receive <= 0;
                    datain <= 8'h01;
                    if (done_send) begin
                        enable_send <= 0;
                        state <= 8 ;
                    end
                end
                8: begin
                    count <= count + 1;
                    if (count >= 24 * 1500) begin          //24ms 
                        count <= 0;
                        state <= 9;
                    end
                end


/////////////////////////////////////////CLEAR//////////////////////////////////////////
                9 : begin
                    add <= {TCS34725_add , MODE_WRITE};
                    add_reg <= 8'hfe;
                    enable_send <= 1;
                    enable_receive <= 0;
                    datain <= 8'h14 | 8'h80 ;
                    repeat_start <= 1;
                    if (done_send) begin
                        repeat_start <= 0;
                        enable_send <= 0;
                        state <= 10;
                    end
                end
                10: begin
                    add <= {TCS34725_add , MODE_READ};
                    enable_send <= 0;
                    enable_receive <= 1;
                    if (done_receice) begin
                        data_clear_l <= data_r;
                        enable_receive <= 0;
                        state <= 11;
                    end
                end
                11: begin
                    add <= {TCS34725_add , MODE_WRITE};
                    add_reg <= 8'hfe;
                    enable_send <= 1;
                    enable_receive <= 0;
                    datain <= 8'h15 | 8'h80 ;
                    repeat_start <= 1;
                    if (done_send) begin
                        enable_send <= 0;
                        repeat_start <= 0;
                        state <= 12;
                    end
                end
                12: begin
                    add <= {TCS34725_add , MODE_READ};
                    enable_send <= 0;
                    enable_receive <= 1;
                    if (done_receice) begin
                        data_clear_m <= data_r;
                        enable_receive <= 0;
                        state <= 13;
                    end
                end




/////////////////////////////////Red/////////////////////////////////////// 
                13: begin
                    add <= {TCS34725_add , MODE_WRITE};
                    add_reg <= 8'hfe;
                    enable_send <= 1;
                    enable_receive <= 0;
                    datain <= 8'h16 | 8'h80 ;
                    repeat_start <= 1;
                    if (done_send) begin
                        repeat_start <= 0;
                        enable_send <= 0;
                        state <= 14;
                    end
                end
                14: begin
                    add <= {TCS34725_add , MODE_READ};
                    enable_send <= 0;
                    enable_receive <= 1;
                    if (done_receice) begin
                        data_reg_l <= data_r;
                        enable_receive <= 0;
                        state <= 15;
                    end
                end
                15: begin
                    add <= {TCS34725_add , MODE_WRITE};
                    add_reg <= 8'hfe;
                    enable_send <= 1;
                    enable_receive <= 0;
                    datain <= 8'h17 | 8'h80 ;
                    repeat_start <= 1;
                    if (done_send) begin
                        enable_send <= 0;
                        repeat_start <= 0;
                        state <= 16;
                    end
                end
                16: begin
                    add <= {TCS34725_add , MODE_READ};
                    enable_send <= 0;
                    enable_receive <= 1;
                    if (done_receice) begin
                        data_red_m <= data_r;
                        enable_receive <= 0;
                        state <= 17;
                    end
                end




//////////////////////////////Green////////////////////////////
                17: begin
                    add <= {TCS34725_add , MODE_WRITE};
                    add_reg <= 8'hfe;
                    enable_send <= 1;
                    enable_receive <= 0;
                    datain <= 8'h18 | 8'h80 ;
                    repeat_start <= 1;
                    if (done_send) begin
                        repeat_start <= 0;
                        enable_send <= 0;
                        state <= 18;
                    end
                end
                18: begin
                    add <= {TCS34725_add , MODE_READ};
                    enable_send <= 0;
                    enable_receive <= 1;
                    if (done_receice) begin
                        data_green_l <= data_r;
                        enable_receive <= 0;
                        state <= 19;
                    end
                end
                19: begin
                    add <= {TCS34725_add , MODE_WRITE};
                    add_reg <= 8'hfe;
                    enable_send <= 1;
                    enable_receive <= 0;
                    datain <= 8'h19 | 8'h80 ;
                    repeat_start <= 1;
                    if (done_send) begin
                        enable_send <= 0;
                        repeat_start <= 0;
                        state <= 20;
                    end
                end
                20: begin
                    add <= {TCS34725_add , MODE_READ};
                    enable_send <= 0;
                    enable_receive <= 1;
                    if (done_receice) begin
                        data_green_m <= data_r;
                        enable_receive <= 0;
                        state <= 21;
                    end
                end






/////////////////////////////////Blue/////////////////////////////////
                21: begin
                    add <= {TCS34725_add , MODE_WRITE};
                    add_reg <= 8'hfe;
                    enable_send <= 1;
                    enable_receive <= 0;
                    datain <= 8'h1A | 8'h80 ;
                    repeat_start <= 1;
                    if (done_send) begin
                        repeat_start <= 0;
                        enable_send <= 0;
                        state <= 22;
                    end
                end
                22: begin
                    add <= {TCS34725_add , MODE_READ};
                    enable_send <= 0;
                    enable_receive <= 1;
                    if (done_receice) begin
                        data_blue_l <= data_r;
                        enable_receive <= 0;
                        state <= 23;
                    end
                end
                23: begin
                    add <= {TCS34725_add , MODE_WRITE};
                    add_reg <= 8'hfe;
                    enable_send <= 1;
                    enable_receive <= 0;
                    datain <= 8'h1B | 8'h80 ;
                    repeat_start <= 1;
                    if (done_send) begin
                        enable_send <= 0;
                        repeat_start <= 0;
                        state <= 24;
                    end
                end
                24: begin
                    add <= {TCS34725_add , MODE_READ};
                    enable_send <= 0;
                    enable_receive <= 1;
                    if (done_receice) begin
                        data_blue_m <= data_r;
                        enable_receive <= 0;
                        state <= 25;
                    end
                end




///////////////////////////////END//////////////////////////////////          
                25: begin
                    count <= count + 1;
                    data_blue <= data_blue_m*256 + data_blue_l;
                    data_red <= data_red_m*256 + data_reg_l;
                    data_green <= data_green_m*256 + data_green_l;
                    data_clear <= data_clear_m*256 + data_clear_l;
                    if (count >= 22*1500) begin          //22ms
                        count <= 0;
                        done <= 1;
                        state <= 25;
                    end
                end
            endcase
        end
    end
endmodule