`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.10.2024 20:05:16
// Design Name: 
// Module Name: synchroniser
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


module synchroniser(
input detect_addr,clk,resetn,we_reg,re0,re1,re2,empty0,empty1,empty2,full0,full1,full2,
input[1:0]datain,
output  reg[2:0]we,
output wire vld_out0,vld_out1,vld_out2,
output reg soft_reset0,soft_reset1,soft_reset2,fifo_full);

//internall reg
reg [1:0]fifo_addr;
reg [4:0]count_sr0,count_sr1,count_sr2;

//capture data ie destination addr and store in fifo_addr
always@(posedge clk)
begin
    if(!resetn)
        fifo_addr<=0;
    else if (detect_addr)
        fifo_addr<=datain;    
end

//we logic
always@(*)
begin
    if (we_reg) //here onehot encoding is used such that if fifo 0 need to be we0 be high then from we of synchroniser the output 0th bit is 1 and all other bit is 0
        case (fifo_addr)
        2'b00:we=3'b001;
        2'b01:we=3'b010;
        2'b10:we=3'b100;
        endcase
end

//fifo full logic
always@(*)
begin
    case(fifo_addr)
    2'b00:fifo_full=full0;
    2'b01:fifo_full=full1;
    2'b10:fifo_full=full2;
    endcase
end

// vld out logic
assign vld_out0=!empty0;
assign vld_out1=!empty1;
assign vld_out2=!empty2;

//soft reset logic
always@(posedge clk)
begin
    if(!resetn)
        count_sr0<=0;
    else if(vld_out0) 
    begin
        if(!re0) begin
            if (count_sr0==5'd30) begin
                soft_reset0<=1'b1;
                count_sr0<=0;
                end
            else begin
                count_sr0<=count_sr0+1;
                soft_reset0<=0;
                end 
                end
        else if(re0) begin
            soft_reset0<=0;
            count_sr0<=0;
            end        
    end 
    else if(!vld_out0) begin
        count_sr0<=0;
        soft_reset0<=0;
         end  
end

always@(posedge clk)
begin
    if(!resetn)
        count_sr1<=0;
    else if(vld_out1) 
    begin
        if(!re0) 
        begin
            if (count_sr1==5'd30) begin
                soft_reset1<=1'b1;
                count_sr1<=0;
            end
            else begin
                count_sr1<=count_sr1+1;
                soft_reset1<=0;
                end 
        end
        else if(re1) begin
            soft_reset1<=0;
            count_sr1<=0;
            end        
    end 
    else if(!vld_out1) begin
        count_sr1<=0;
        soft_reset1<=0;
        end  
end

always@(posedge clk)
begin
    if(!resetn)
        count_sr2<=0;
    else if(vld_out2) 
    begin
        if(!re2) 
        begin
            if (count_sr2==5'd30) begin
                soft_reset2<=1'b1;
                count_sr2<=0;
                end
            else begin
                count_sr2<=count_sr2+1;
                soft_reset2<=0;
                end 
       end
        else if(re2) begin
            soft_reset2<=0;
            count_sr2<=0;
            end        
    end 
    else if(!vld_out2) begin
        count_sr2<=0;
        soft_reset2<=0;
         end  
end
            
            
endmodule
