`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.10.2024 14:33:36
// Design Name: 
// Module Name: fsm_tb
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
//here for router fsm tb i need to drive fsm through different states such that a task to drive fsm for eg packet of 12 bytes such that fsm o to parity state after load data then packet of 16 bytes such that this would make fsm go through different states and then a packet of length say 18

module fsm_tb();
reg clk,resetn, pkt_valid;
reg [1:0]datain;
reg fifo_full, empty0, empty1, empty2, soft_reset0, soft_reset1, soft_reset2, parity_done, low_packet_valid;
wire we_reg, detect_addr, ld_state, laf_state, lfd_state, full_state, rst_int_reg, busy;
integer i;

//instantiation
fsm dut(.clk(clk),
        .resetn(resetn),
        .pkt_valid(pkt_valid),
        .datain(datain),
        .fifo_full(fifo_full),
        .empty0(empty0),
        .empty1(empty1),
        .empty2(empty2),
        .soft_reset0(soft_reset0),
        .soft_reset1(soft_reset1),
        .soft_reset2(soft_reset2),
        .parity_done(parity_done),
        .low_pktvalid(low_pktvalid),
        .we_reg(we_reg), 
		 .detect_addr(detect_addr), 
		 .ld_state(ld_state), 
		 .laf_state(laf_state), 
		 .lfd_state(lfd_state),
		 .full_state(full_state), 
		 .rst_int_reg(rst_int_reg), 
		 .busy(busy)  );

//clk generation
initial begin
    clk=1'b0;
    forever #5 clk=~clk;
  end

//task initialise
task initialise;
    begin
        datain=0;
    end
endtask    
    
//task reset
task reset;
begin
    @(negedge clk)
       resetn=1'b0;   
    @(negedge clk)
        resetn=1'b1;
end
endtask

//task input drive
task packet1;
begin
    @(negedge clk)
    pkt_valid=1;
     datain=2'b01;
     empty0=1'b0;
     empty1=1'b1; 
     empty2=1'b0;
    for(i=0;i<13;i=i+1)
    begin
    @(negedge clk)
        pkt_valid=1;
        datain=2'b01;
        fifo_full=0;
        empty0=1'b0;
        empty1=1'b0; 
        empty2=1'b0; 
        soft_reset0=1'b0; 
        soft_reset1=1'b0;
        soft_reset2=1'b0;
        parity_done =1'b0;
        low_packet_valid=1'b0;    
    end
   @(negedge clk)
    pkt_valid=0;
        datain=2'b01;
        fifo_full=0; 
        soft_reset0=1'b0; 
        soft_reset1=1'b0;
        soft_reset2=1'b0;
        parity_done =1'b1;
        low_packet_valid=1'b1;
    @(negedge clk)
     parity_done =0;    
    
end   
  endtask
  
  // task calling
initial
begin
    initialise;
    reset;
    #5;
    packet1;
    #200
    $finish;
end         
        
//similarly create a task for packet2 with input change when packet is of 16 bytes and then packet3 with size 18
            
    
endmodule
