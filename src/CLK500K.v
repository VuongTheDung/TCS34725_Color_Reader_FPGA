/*     
Module chia tan cung cap tan so 500kHz
Tan so dau vao hien tai la 27MHz
*/

module LCD_clk(
    input clk27m,
    input rst,
    output clk100k
);
    parameter Devision = 54; //27*2 --> tan so 500kHz

    reg clk100ktemp = 0;
    integer countclk = 0;
    always @(posedge clk27m) begin
            if (countclk  < (Devision/2) - 1) countclk <= countclk + 1;  //500kHz
            else begin
                countclk <= 0;
                clk100ktemp <= ~clk100ktemp;
            end
        //end
    end
    assign clk100k = clk100ktemp;
endmodule
