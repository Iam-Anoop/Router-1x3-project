`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.10.2024 16:54:15
// Design Name: 
// Module Name: router_fifo_tb
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


module fifo_tb();
reg clk,resetn,soft_reset,we,re,lfd_state;
reg [7:0]datain;
wire full,empty;
wire [7:0]dataout;
integer i;
reg [7:0]header,payload,parity;
reg [5:0]payload_len;
reg [1:0]addr;
//instantiation
fifo dut ( .clk(clk),
                  .resetn(resetn),
                  .we(we),
                  .re(re),
                  .lfd_state(lfd_state),
                  .datain(datain),
                  .full(full),
                  .empty(empty),
                  .dataout(dataout));
                  
//clk generation
initial
begin
    clk=0;
    forever #5 clk=~clk;
end 

//reset
task reset;
begin
    @(negedge clk)
    resetn=0;
    @(negedge clk)
    resetn=1;
end
endtask

// initialise    
task initialise;
begin
    we=0;
    re=0;
    datain=8'd0;
end
endtask

//task write
task write; //since this fifo for router we know data in to the fifo will be packet that can consist of different bytes
 begin 
 @(negedge clk)
 begin
    payload_len=6'd12;
    addr=2'b01;
    header={payload_len,addr};
    datain=header;
    lfd_state=1;
    we=1;
 end
    for(i=0;i<payload_len;i=i+1)
        @(negedge clk) begin
        payload={$random}%256;
        datain=payload;
        end
    @(negedge clk) begin
        parity={$random}%256;
        datain=parity;
        end
 end        
endtask

// task read 
task read;
@(negedge clk) begin
    we=0;
    re=1;
end
endtask

// calling tasks
initial begin
    initialise;
    reset;
    #10;
    write;
    #5;
    read;
    #100
    $finish; end
   
endmodule
