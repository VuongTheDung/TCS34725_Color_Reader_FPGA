/*          
Module dieu khien sau top_module, chon 2 chuc nang
la khoi dong(init) hoac dieu khien gui lenh, du lieu
theo mode da chon
*/


module LCD_Initorcontrol(
    input clk,
    input rst,
    input enable,
    input init,
    input mode,
    input [7:0] datain,
    input [7:0] add,

    output reg done,
    output doneIOC,
    inout sda,
    output scl
);
    //wire doneIOC;
    reg [7:0] data;

    integer state = 0, count = 0;
    reg enableIOC = 0;

    LCD_sendCmdorChar sendcmd(.clk(clk), .mode(mode), .rst(rst), .enable(enableIOC), .data(data), .add(add), .done(doneIOC), .sda(sda), .scl(scl)); 

    always @(posedge clk) begin
        if (init) begin                                          
            done <= 0;
            if (~rst | ~enable) begin
                state <= 0;
                enableIOC <= 0;
                done <= 0;
            end
            else begin
                if (enable) begin
                    case (state)
                        0: begin                                   
                            count <= count + 1;
                            enableIOC <= 0;
                            if (count >= 5000) begin            
                                enableIOC <= 1;
                                data <= 8'h30;
                                if (doneIOC) begin                  
                                    enableIOC <= 0;
                                    state <= 1;  
                                    count <= 0;
                                end
                                else state <= 0;
                            end
                        end
                        1: begin                                   
                            count <= count + 1;
                            enableIOC <= 0;
                            if (count >= 500) begin               
                                enableIOC <= 1;
                                data <= 8'h03;
                                
                                if (doneIOC) begin                  
                                    enableIOC <= 0;
                                    state <= 2;
                                    count <= 0;                    
                                end
                                else state <= 1;
                            end              
                        end
                        2: begin                                   
                            count <= count + 1;
                            enableIOC <= 0;
                            if (count >= 100) begin             
                                enableIOC <= 1;
                                data <= 8'h00;
                                
                                if (doneIOC) begin                
                                    enableIOC <= 0;
                                    state <= 3; 
                                    count <= 0;    
                                end
                                else state <= 2;
                            end
                        end
                        3: begin                                   
                            count <= count + 1;
                            enableIOC <= 0;
                            if (count >= 100) begin             
                                enableIOC <= 1;
                                data <= 8'h02;                      
                                
                                if (doneIOC) begin                  
                                    state <= 4; 
                                    count <= 0; 
				    enableIOC <= 0;   
                                end
                                else state <= 3;
                            end
                        end
                        4: begin                                   
                            count <= count + 1;
                            enableIOC <= 0;
                            if (count >= 100) begin           
                                enableIOC <= 1;
                                data <= 8'h28;                      
                                
                                if (doneIOC) begin                  
                                    state <= 5; 
                                    count <= 0;   
				    enableIOC <= 0;  
                                end
                                else state <= 4;
                            end
                        end
                        5: begin                                    
                            count <= count + 1;
                            enableIOC <= 0;
                            if (count >= 100) begin                
                                enableIOC <= 1;
                                data <= 8'h08;                      
                                
                                if (doneIOC) begin                  
                                    state <= 6; 
                                    count <= 0;  
				    enableIOC <= 0;   
                                end
                                else state <= 5;
                            end
                        end
                        6: begin                                
                            count <= count + 1;
                            enableIOC <= 0;
                            if (count >= 100) begin                
                                enableIOC <= 1;
                                data <= 8'h01;                  
                                
                                if (doneIOC) begin                  
                                    state <= 7; 
                                    count <= 0;  
				    enableIOC <= 0;   
                                end
                                else state <= 6;
                            end
                        end
                        7: begin                                    
                            count <= count + 1;
                            enableIOC <= 0;
                            if (count >= 200) begin             
                                enableIOC <= 1;
                                data <= 8'h06;                     
                                
                                if (doneIOC) begin                 
                                    state <= 8; 
                                    count <= 0; 
				    enableIOC <= 0;    
                                end
                                else state <= 7;
                            end
                        end
                        8: begin                                   
                            count <= count + 1;
                            enableIOC <= 0;
                            if (count >= 200) begin                 
                                enableIOC <= 1;
                                data <= 8'h0C;                    
                                
                                if (doneIOC) begin                  
                                    state <= 9; 
                                    count <= 0;    
				    enableIOC <= 0; 
                                end
                                else state <= 8;
                            end
                        end
                        9: begin                                  
                            done <= 1;
                            enableIOC <= 0;
                            state <= 0;
                        end
                    endcase
                end  
            end
        end
        else begin                                                
            done <= 0;
            if (~rst | ~enable) begin
                state <= 0;
                enableIOC <= 0;
		done <= 0;
		count <= 0;
            end
            else if (enable) begin
		count <= count + 1;
		enableIOC <= 0;
		if (count >= 200) begin                                   
                   	enableIOC <= 1;
                        data <= datain;                               
                        if (doneIOC) begin                        
                                count <= 0;    
				enableIOC <= 0;
				done <= 1;
                        end    
                end
            end
	    else begin
		state <= 0;
                enableIOC <= 0;
		done <= 0;
		count <= 0;
	    end
        end
    end
endmodule