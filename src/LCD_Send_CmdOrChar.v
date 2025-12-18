/*               Do Thanh Phong B21166
Module gui lenh hoac du lieu toi LCD. Duoc LCD_InitOrControl
dieu khien.
*/

module LCD_sendCmdorChar(
    input clk,
    input mode,                                                      //mode = 0 gui lenh, mode = 1 gui du lieu
    input enable,
    input rst,
    input [7:0] data,
    input [7:0] add,
    
    output reg done,
    inout sda,
    output scl
);
    reg enable1 = 0;
    reg [7:0] data1;
    wire done1;
    integer state1 = 0;

    LCD_Send SendLCD(.clk(clk), .rst(rst), .add_reg(8'hfe), .num_byte(1), .enable(enable1), .data(data1), .add(add), .done(done1), .scl_i2c(scl), .sda(sda), .repeat_start(0)); 
    
    
    always @(posedge clk) begin
        if (~rst) begin
            state1 = 0;
            done <= 0;
        end
        else begin
            if (enable) begin
                done <= 0;
                if (~mode) begin
                    case (state1) 
                        0: begin
                            enable1 <= 1;
                            data1 <= (data & 8'hF0)|(8'h0C);     
                            if (done1) begin
                                state1 <= 1;
                                //enable1 <= 0;
                            end
                        end
                        1: begin
                            enable1 <= 1;
                            data1 <= (data & 8'hF0)|(8'h08);        
                            if (done1) begin
                                state1 <= 2;
                                //enable1 <= 0;
                            end
                        end
                        2: begin
                            enable1 <= 1;
                            data1 <= ((data<<4) & 8'hF0)|(8'h0C);   
                            if (done1) begin
                                state1 <= 3;
                                //enable1 <= 0;
                            end
                        end
                        3: begin
                            enable1 <= 1;
                            data1 <= ((data<<4) & 8'hF0)|(8'h08);    
                            if (done1) begin 
                                state1 <= 4;
                                //enable1 <= 0;
                            end
                        end
                        4: begin
                            done <= 1;
                            state1 <= 0;
                        end
                    endcase
                end
                else begin
                    case (state1) 
                        0: begin
                            enable1 <= 1;
                            data1 <= (data & 8'hF0)|(8'h0D);        
                            if (done1) begin
                                state1 <= 1;
                                //enable1 <= 0;
                            end
                        end
                        1: begin
                            enable1 <= 1;
                            data1 <= (data & 8'hF0)|(8'h09);        
                            if (done1) begin
                                state1 <= 2;
                                //enable1 <= 0;
                            end
                        end
                        2: begin
                            enable1 <= 1;
                            data1 <= ((data<<4) & 8'hF0)|(8'h0D);    
                            if (done1) begin
                                state1 <= 3;
                                //enable1 <= 0;
                            end
                        end
                        3: begin
                            enable1 <= 1;
                            data1 <= ((data<<4) & 8'hF0)|(8'h09);    
                            if (done1) begin 
                                state1 <= 4;
                                //enable1 <= 0;
                            end
                        end
                        4: begin
                            done <= 1;
                            state1 <= 0;
                        end
                    endcase
                end
            end
            else enable1 <= 0;
        end
    end
endmodule
