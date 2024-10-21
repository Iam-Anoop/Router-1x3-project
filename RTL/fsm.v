`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.10.2024 14:33:04
// Design Name: 
// Module Name: fsm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fsm(
input clk,resetn,pkt_valid,parity_done,soft_reset0,soft_reset1,soft_reset2,fifo_full,low_pktvalid,empty0,empty1,empty2,
input [1:0]datain,
output  detect_addr,ld_state,laf_state,full_state,we_reg,rst_int_reg,lfd_state,busy);

//state encoding here there are 8 states therefore 4 bits needed to represent those states
parameter   decode_address=4'b0001,
            wait_till_empty=4'b0010,
            load_first_data=4'b0011,
            load_data=4'b0100,
            load_parity=4'b0101,
            check_parity=4'b0110,
            fifo_full_state=4'b0111,
            load_after_full=4'b1111;
            
//fifo present state and next state declaration number of bits for these depend on the number of states
reg [3:0]present_state,next_state;
reg [1:0] fifo_addr; //to store destination adress from datain

//data storing logic
always@(posedge clk)
begin   
    if(!resetn)
        fifo_addr<=0;
    else 
        fifo_addr<=datain;
end

//present logic
always@(posedge clk)
begin
    if(!resetn||soft_reset0||soft_reset1||soft_reset2)
        present_state<=decode_address;
    else
        present_state<=next_state;                
end

//next state logic
always@(*) begin
    next_state=decode_address;
    case(present_state)
        decode_address: begin
            if((pkt_valid&&datain==2'b00&&empty0)||(pkt_valid&&datain==2'b01&&empty1)||(pkt_valid&&datain==2'b10&&empty2))
                next_state=load_first_data;
            else if((pkt_valid&&datain==2'b00&&!empty0)||(pkt_valid&&datain==2'b01&&!empty1)||(pkt_valid&&datain==2'b10&&!empty2))    
                next_state=wait_till_empty;
            else
                next_state=decode_address;
        end
        wait_till_empty: begin
            if((empty0&&fifo_addr==2'b00)||(empty1&&fifo_addr==2'b01)||(empty2&&fifo_addr==2'b10))     
                  next_state=load_first_data;
            else
                next_state=wait_till_empty;
            end
        load_first_data: begin
            next_state=load_data;
            end
        load_data: begin
            if(fifo_full)
                next_state=fifo_full_state;
            else if(!pkt_valid&&!fifo_full)
                next_state=load_parity;
            else
                next_state=load_data;
            end
        load_parity: begin
            next_state=check_parity;
            end
        fifo_full_state: begin
            if(!fifo_full)
                next_state=load_after_full;
            else
                next_state=fifo_full_state;
            end
        load_after_full: begin
            if(!parity_done&&!low_pktvalid)
                next_state=load_data;
            else if(!parity_done&&low_pktvalid)
                next_state=load_parity;
            else begin
              if(parity_done)
                 next_state=decode_address;
              else
                 next_state=load_after_full;
              end  
            end
        check_parity: begin
            if(!fifo_full)
                next_state=decode_address;
            else 
                next_state=fifo_full_state;
            end    
        default : 
        next_state=decode_address;                                                                             
     endcase
 end
 
 //output logic
 assign detect_addr=(present_state==decode_address)?1'b1:1'b0;
 assign lfd_state=(present_state==load_first_data)?1'b1:1'b0;
 assign ld_state=(present_state==load_data)?1'b1:1'b0;
 assign laf_state=(present_state==load_after_full)?1'b1:1'b0;
 assign full_state=(present_state==fifo_full_state)?1'b1:1'b0;
 assign we_reg=((present_state==load_data)||(present_state==load_first_data)||(present_state==load_parity))?1'b1:1'b0;
 assign rst_int_reg=(present_state==check_parity)?1'b1:1'b0;
 assign busy=((present_state==load_first_data)||(present_state==load_parity)||(present_state==fifo_full_state)||(present_state==load_after_full)||(present_state==wait_till_empty)||(present_state==check_parity))?1'b1:1'b0;
             
endmodule
