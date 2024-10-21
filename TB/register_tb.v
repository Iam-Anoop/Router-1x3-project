`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.10.2024 11:42:06
// Design Name: 
// Module Name: register_tb
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


module register_tb();
reg clk, resetn, pkt_valid,fifo_full, detect_addr, ld_state, laf_state, full_state, lfd_state, rst_int_reg;
reg [7:0] data_in;
wire err, parity_done, low_pktvalid;
wire [7:0]dout;
integer i;
//instantiation
register dut(.clk(clk),
             .resetn(resetn),
             .pkt_valid(pkt_valid),
             .fifo_full(fifo_full),
             .detect_addr(detect_addr),
             .ld_state(ld_state),
             .laf_state(laf_state),
             .full_state(full_state),
             .lfd_state(lfd_state),
             .rst_int_reg(rst_int_reg),
             .data_in(data_in),
             .err(err),
             .parity_done(parity_done),
             .dout(dout),
             .low_pktvalid(low_pktvalid));

//clk generation
initial 
begin   
    clk=0;
    forever #5 clk=~clk;
end

//task initialise
task initialise;
begin
    data_in=0;
end
endtask
//task reset
task reset;
begin
    @(negedge clk)
    resetn=0;
    @(negedge clk)
    resetn=1;
end
endtask
// task input drive 
//giving first packet to the register
task packet1;
reg [7:0]header, payload_data, parity;
reg [5:0]payloadlen;
reg[1:0]da;
begin
    
@(negedge clk) 
    begin
        payloadlen=8;
        da=2'b01;
		detect_addr=1'b1;
		pkt_valid=1'b1;
		header={payloadlen,da};
		data_in=header;
	end
@(negedge clk)
    begin
        lfd_state=1;
        detect_addr=0;
    end
for(i=0;i<payloadlen;i=i+1)    
@(negedge clk)
    begin
        lfd_state=0;
        ld_state=1;
        fifo_full=0;
        payload_data={$random}%256;
        data_in=payload_data;
    end
@(negedge clk)
    begin
        pkt_valid=0;
        parity={$random}%256;
        data_in=parity;
    end
@(negedge clk)
ld_state=0;
end
endtask

//czlling tasks
initial
begin
initialise;
#5;
reset;
#5;
packet1;
#100;
$finish;
end
//similarly write two more packet task with each  of size 16 and 18
        
   
    

    
endmodule
