 

module i2c_receive(
    input clk,
    input rst,
    input enable,
    input [7:0] add,

    output reg [7:0] data,
    output reg done,
    inout scl_i2c,
    inout sda
);

    parameter START_W = -1;
    parameter SEND_ADDRESS = 0;
    parameter READ_ACK = 1;
    parameter IDLE = 2;
    parameter SEND_DATA = 3, READ_DATA = 3;
    parameter READ_ACK_NACK = 4, SEND_ACK_NACK = 4;
    parameter PRE_STOP = 5;
    parameter STOP = 6;
   
    integer state = 0;
    integer count = 7;
    integer count_byte = 0;
    integer enddelay = 4;
    integer ck = 3;
    
    integer pause = 0;

    reg temp = 1;
    reg checkACK = 0;
    reg checkBug = 0;
    reg scl;
    
    assign scl_i2c = (enable)?scl:1'bz;
    assign sda = (~enable || state == IDLE || state == SEND_DATA)?1'bz:temp;
    
    always @(posedge clk) begin
        if (~rst | ~enable) begin
            ck <= 3; pause <= 0; count <= 7; count_byte = 0;					                                   
            state <= 0;
            scl <= 1;						                                   
            done <= 0;
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

                    if (state == SEND_ADDRESS && ck == 3 && count == 7) temp <= 0;		           
                    //else temp <= temp;

                    if (state == SEND_DATA && ck == 0 && count == 7) scl <= scl;
                    else if (state == STOP) scl <= 1;                                              				                
                end
                else begin
                    pause <= pause - 1;
                    if (state == SEND_DATA) scl <= 0;					                            
                    else if (state == STOP) ck <= 2;					                        
                    else ck <= ck;
                end


                if (((ck == 1 && (state <= IDLE||state >= READ_ACK_NACK))||(ck == 3 && state > IDLE && state < READ_ACK_NACK))&& pause == 0) begin
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
                            temp <= 1'bZ;					                    
                            if (1) state <= IDLE;
                            else begin
                                state <= SEND_ADDRESS;  
                                ck <= 0; 
                            end
                        end
                        IDLE: begin						                       
                            pause <= 4;
                            state <= SEND_DATA;
                            scl <= 0;					                        
                            temp <= 1'bz;
                            ck <= 0;
                        end
                        READ_DATA: begin						             
                            temp <= 1'bz;
                            data[count] <= sda;
                            if (count != 0) count <= count - 1;
                            else begin
                                state <= READ_ACK_NACK;
                                count <= 7;
                                count_byte <= count_byte + 1;
                            end
                        end
                        READ_ACK_NACK: begin						          
                            if (count_byte == 1) begin
                                temp <= 1'b1;
                                count_byte <= 0;
                                state <= PRE_STOP;
                            end
                            else begin
                                if (~checkBug) begin
                                    temp <= 1'b0;
                                    checkBug <= 1'b1;
                                end 
                                else begin
                                    state <= SEND_DATA;
                                    temp <= 1'bz;
                                    checkBug <= 0;
                                end
                            end
                        end
                        PRE_STOP: begin						               
                            temp <= 0;
                            state <= STOP;
                        end
                        STOP: begin						                      
                            pause <= 60;                                    
                            temp <= 1'bz; scl <= 1; ck <= 3;  
                            done <= 1;
                            state <= SEND_ADDRESS;		
                        end
                    endcase
                end
            end
            else begin
                ck <= 3; pause <= 0; count <= 7; count_byte = 0;
                state <= SEND_ADDRESS;
                done <= 0;
            end
        end
    end
endmodule

