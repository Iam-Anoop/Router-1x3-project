`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.10.2024 20:06:02
// Design Name: 
// Module Name: synchroniser_tb
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


module synchroniser_tb();
reg detect_addr,clk,resetn,we_reg,re0,re1,re2,empty0,empty1,empty2,full0,full1,full2;
reg [1:0]datain;
wire fifo_full,vld_out0,vld_out1,vld_out2,soft_reset0,soft_reset1,soft_reset2;
wire[2:0]we;

//instantiation
synchroniser dut( .clk(clk),
                  .resetn(resetn),
                  .detect_addr(detect_addr),
                  .we_reg(we_reg),
                  .re0(re0),
                  .re1(re1),
                  .re2(re2),
                  .empty0(empty0),
                  .empty1(empty1),
                  .empty2(empty2),
                  .full0(full0),
                  .full1(full1),
                  .full2(full2),
                  .datain(datain),
                  .fifo_full(fifo_full),
                  .we(we),
                  .soft_reset0(soft_reset0),
                  .soft_reset1(soft_reset1),
                  .soft_reset2(soft_reset2),
                  .vld_out0(vld_out0),
                  .vld_out1(vld_out1),
                  .vld_out2(vld_out2));
                  
//clk generation 
initial
begin
    clk=1'b0;
    forever #5 clk=~clk;
end

//initialisation
task initialisation;
begin
datain=0;
re0=0;
re1=0;
re2=0;
end
endtask

//reset
task reset;
begin
@(negedge clk)
resetn=0;
@(negedge clk)
resetn=1;
end
endtask

//task input driving
task input_drive;
begin
    @(negedge clk)
    detect_addr=1;
    datain=2'b01;
    we_reg=1;
    empty0=1;
    empty1=0;
    empty2=0;
    full0=0;
    full1=1;
    full2=1;
    re0=0;
    re1=1;
    re2=0;
end
endtask

//calling tasks
initial
begin
initialisation;
reset;
#5;
input_drive;
#1000;
$finish;
end 

    





    
                  
                  
                    
endmodule
