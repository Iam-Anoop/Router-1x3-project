`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.10.2024 11:41:35
// Design Name: 
// Module Name: register
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


module register(
input clk,resetn,pkt_valid,
input [7:0]data_in,
input detect_addr,we_reg,ld_state,lfd_state,laf_state,full_state,rst_int_reg,fifo_full,
output reg [7:0]dout,
output reg low_pktvalid,err,parity_done);

// internal reg
reg [7:0]holdheaderbyte,fifofullbyte,internalparity,paritybyte;

//functionality logics needed are dout logic,internal parity calcualtion logic,err logic,parity done logic,low pkt valid logic

//dout logic
always @(posedge clk)
begin
    if(!resetn)
        dout<=0;
    else if(detect_addr&&pkt_valid)
        holdheaderbyte<=data_in;
    else if(lfd_state)
        dout<=holdheaderbyte;
    else if(ld_state&!fifo_full)
        dout<=data_in;
    else if(ld_state&fifo_full)        
        fifofullbyte<=data_in;
    else if(laf_state)
        dout<=fifofullbyte;    
end
//internal parity calculation,packet parity byte....this is to give the err signal ie to check error we need to compare between internal mparity and packet parity
//paRITY byte logic
always@(posedge clk)
begin 
    if(!resetn)
        paritybyte<=0;
    else if(!pkt_valid&&ld_state)
        paritybyte<=data_in;
end        
//internal parity logic
always@(posedge clk)
begin
     if(!resetn)
        internalparity<=0;
     else if(lfd_state)
        internalparity<=holdheaderbyte^internalparity;
     else if(pkt_valid&&ld_state&&!fifo_full)
        internalparity<=data_in^internalparity;
     else if(detect_addr)
        internalparity<=0;      
end

//err logic if there is mismatch in what in the internalm parity and paritty byte then err is1
always@(posedge clk)
begin 
    if(!resetn)
        err<=0;
    else 
        if(!pkt_valid) begin
            if (internalparity!==paritybyte)
                err=1;
            else
                err=0;      
        end
end        

//parity done logic
always@(posedge clk)
begin
    if(!resetn)
        parity_done=0;     
    else if(!pkt_valid&&ld_state&&!fifo_full)
         parity_done=1;
    else if(!pkt_valid&&laf_state)
         parity_done=1;
    else 
        parity_done=0;          
end

//low pkt valid logic
always@(posedge clk)
begin 
    if(!resetn)
        low_pktvalid<=0;
    else if(rst_int_reg)
        low_pktvalid<=0;
    else if (ld_state&&!pkt_valid)
         low_pktvalid<=1;  
end
                              
endmodule
