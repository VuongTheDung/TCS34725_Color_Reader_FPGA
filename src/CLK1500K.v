/*     
Module chia tan cung cap tan so 100kHz
Tan so dau vao hien tai la 27MHz
*/

module clk_1500k(
    input clk27m,
    input rst,
    output clk1500k
);
    parameter Devision = 18; //27*2 --> tan so 500kHz

    reg clk1500ktemp = 0;
    integer countclk = 0;
    always @(posedge clk27m) begin
            if (countclk  < (Devision/2) - 1) countclk <= countclk + 1;  //500kHz
            else begin
                countclk <= 0;
                clk1500ktemp <= ~clk1500ktemp;
            end
        //end
    end
    assign clk1500k = clk1500ktemp;
endmodule
