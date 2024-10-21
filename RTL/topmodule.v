`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.10.2024 21:39:21
// Design Name: 
// Module Name: topmodule
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


module topmodule( input clk,resetn,pkt_valid,re0,re1,re2,
                  input[7:0]datain,
                  output[7:0]dataout0,dataout1,dataout2,
                  output vldout0,vldout1,vldout2,err,busy );
                  
//internal wires
wire [2:0]we;
wire [7:0]din;

//instantiztion

fifo f1( .clk(clk), .resetn(resetn),  .re(re0), .datain(din), .lfd_state(lfd_state), .full(full0), .empty(empty0), .dataout(dataout0));
fifo f2( .clk(clk), .resetn(resetn),  .re(re1), .datain(din), .lfd_state(lfd_state), .full(full1), .empty(empty1), .dataout(dataout1));
fifo f3( .clk(clk), .resetn(resetn), .re(re2), .datain(din), .lfd_state(lfd_state), .full(full2), .empty(empty2), .dataout(dataout2));

register rg( .clk(clk), .resetn(resetn), .pkt_valid(pkt_valid), .detect_addr(detect_addr), .we_reg(we_reg), .ld_state(ld_state), .lfd_state(lfd_state), .laf_state(laf_state), .full_state(full_state), .rst_int_reg(rst_int_reg), .fifo_full(fifo_full), .dout(din), .low_pktvalid(low_pktvalid), .err(err), .parity_done(parity_done));

fsm controller( .clk(clk), .resetn(resetn), .pkt_valid(pkt_valid), .parity_done(parity_done), .soft_reset0(soft_reset0), .soft_reset1(soft_reset1), .soft_reset2(soft_reset2), .fifo_full(fifo_full), .low_pktvalid(low_pktvalid), .empty0(empty0), .empty1(empty1), .empty2(empty2), .datain(datain), .detect_addr(detect_addr), .ld_state(ld_state), .laf_state(laf_state), .full_state(full_state), .we_reg(we_reg), .rst_int_reg(rst_int_reg), .lfd_state(lfd_state), .busy(busy));

synchroniser syn( .clk(clk), .resetn(resetn), .vld_out0(vldout0), .vld_out1(vldout1), .vld_out2(vldout2), .re0(re0), .re1(re1), .re2(re2), .empty0(empty0), .empty1(empty1), .empty2(empty2), .fifo_full(fifo_full), .we(we), .full0(full0), .full1(full1), .full2(full2), .soft_reset0(soft_reset0), .soft_reset1(soft_reset1), .soft_reset2(soft_reset2), .we_reg(we_reg), .detect_addr(detect_addr), .datain(datain));

                  
endmodule
