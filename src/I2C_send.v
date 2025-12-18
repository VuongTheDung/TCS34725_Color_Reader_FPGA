/*        
Module khoi tao va gui du lieu giao thuc I2C
Chi gui 1 byte du lieu trong 1 khung du lieu
Chi giao tiep 1 slave nen khong kiem tra cac 
bit ACK. 


*/



module LCD_Send(
    input clk,
    input rst,
    input enable,
    input [7:0] data,		//neu muon gui n byte sua 15 = (num_byte)*8 - 1
    input [7:0] add,
    input [7:0] add_reg,
    input [2:0] num_byte,
    input repeat_start,

    output reg done,
    inout scl_i2c,
    inout sda
);
	
    parameter START_W = -1;
    parameter SEND_ADDRESS = 0;
    parameter READ_ACK = 1;
    parameter IDLE = 2;
    parameter SEND_DATA = 3;
    parameter READ_ACK_NACK = 4;
    parameter PRE_STOP = 5;
    parameter STOP = 6;

    parameter num_byte_cons = 1;		//thay doi theo so luong byte truyen moi lan 
    parameter SEND_ADD_RES = 7;
   
    integer num_byte_cnt = 0;
    integer num = num_byte_cons;
    integer state = 0;
    integer count = 7;
    integer enddelay = 4;
    integer ck = 3;
    
    integer pause = 0;

    reg scl = 1;
    reg temp = 1;  
    assign scl_i2c = (enable)?scl:1'bz;
    assign sda = (~enable || state == IDLE)?1'bz:temp;
   
    reg checkACK = 0;

    always @(posedge clk) begin
        if (~rst | ~enable) begin
            ck <= 3; pause <= 0; count <= 7;						                                    
            state <= 0;					                                   
            done <= 0;
 	    num <= num_byte_cons;
	    num_byte_cnt <= 0;
        end
        else begin
            done <= 0;
            scl <= 1;						                                                       
            if (enable) begin
                if (pause == 0) begin							                                   
                    ck <= (ck != 3)?(ck + 1):0;
                    if ((ck == 0 | ck == 2)) scl <= ~scl;
                    else scl <= scl;

                    if(ck == 3 && (state == READ_ACK | state == READ_ACK_NACK)) checkACK <= sda;	
                    else checkACK <= 1'bZ;

                    if (state == SEND_ADDRESS && ck == 3 && count == 7) temp <= 1'b0;		          
                    //else temp <= temp;

                    if ((state == SEND_DATA || state == SEND_ADD_RES) && ck == 0 && count == 7) begin
			if (add_reg == 8'hfe) begin
			    if (num_byte_cnt == 0) scl <= scl;
			end
			else begin
			    if (state != SEND_DATA) scl <= scl;
			end
		    end
                    else if (state == STOP) scl <= 1;                                               										                
                end
                else begin
                    pause <= pause - 1;
                    if (state == SEND_DATA || state == SEND_ADD_RES) scl <= 0;					                           
                    else if (state == STOP) ck <= 2;					                            	
                    else ck <= ck;
                end
                

             
                if (ck == 1 && pause == 0) begin
                    case (state) 
                        SEND_ADDRESS: begin						                                    
                            temp <= add[count];                
                            if (count != 0) count <= count - 1;
                            else begin
                                state <= READ_ACK;
                                count <= 7;		
                            end
                        end
                        READ_ACK: begin						                   
                            temp <= 1'bz;					                    
                            if (1) state <= IDLE;
                            else begin
                                state <= SEND_ADDRESS;  
                                ck <= 0;
                            end
                        end
                        IDLE: begin						                        
                            pause <= 4;
                            if (add_reg == 8'hfe) state <= SEND_DATA;
                            else state <= SEND_ADD_RES;
                            scl <= 0;					                        
                            temp <= 1'b1;
                            ck <= 0;
                        end
                        SEND_DATA: begin						               
                            temp <= data[count + (num-1)*8];
                            if (count != 0) count <= count - 1;
                            else begin
                                state <= READ_ACK_NACK;
                                num <= num - 1;
                                count <= 7;
                            end
                        end
                        SEND_ADD_RES: begin
                            temp <= add_reg[count];
                            if (count != 0) count <= count - 1;
                            else begin
                                state <= READ_ACK_NACK;
                                count <= 7;
                            end
                        end
                        READ_ACK_NACK: begin						            
                            temp <= 1'bZ;
                            if (num_byte_cnt < ((add_reg != 8'hfe)?num_byte:(num_byte-1))) begin
                                num_byte_cnt <= num_byte_cnt + 1;
                                state <= SEND_DATA;
                            end
                            else begin
                                    state <= PRE_STOP;
                                    
                            end
                        end
                        PRE_STOP: begin	  
                            if (repeat_start) begin
                                temp <= 1'b1;
                                done <= 1;
                                state <= SEND_ADDRESS;
                            end
                            else begin
                                temp <= 0;
                                state <= STOP;
                            end
                        end
                        STOP: begin						                      
                            pause <= 60;                                     
                            temp <= 1; scl <= 1; ck <= 3;  
			
                            done <= 1;
                            state <= SEND_ADDRESS;		
                        end
                    endcase
                end
            end
            else begin
                ck <= 3; pause <= 0; count <= 7;
                state <= SEND_ADDRESS;
                done <= 0;
            end
        end
    end
endmodule