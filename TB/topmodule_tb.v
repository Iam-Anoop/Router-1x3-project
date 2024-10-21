`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.10.2024 21:39:46
// Design Name: 
// Module Name: topmodule_tb
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


module topmodule_tb();
reg clk,resetn,pkt_valid,re0,re1,re2;
reg[7:0]datain;
wire [7:0]dataout0,dataout1,dataout2;
wire vldout0,vldout1,vldout2,err,busy;
integer i;

//instantiation
topmodule dut ( .clk(clk),
                .resetn(resetn),
                .pkt_valid(pkt_valid),
                .re0(re0),
                .re1(re1),
                .re2(re2),
                .datain(datain),
                .dataout0(dataout0),
                .dataout1(dataout1),
                .dataout2(dataout2),
                .vldout0(vldout0),
                .vldout1(vldout1),
                .vldout2(vldout2),
                .err(err),
                .busy(busy));
                
//clk generation
initial 
begin
    clk=1'b0;
    forever #5 clk=~clk;
end

//task  reset
task reset;
begin 
    @(negedge clk)    
    resetn=0;
    @(negedge clk)
    resetn=1;
end
endtask

// task initialise
task initialise;
begin
    resetn=1;
    {re0,re1,re2,pkt_valid}=0;
end
endtask

//task  packet1 with 12bytes ie 10 payload len and 1 header byte and 1 parity byte
task pkt1; 
       reg [7:0]header,payload,parity;
       reg[5:0]payload_len;
       reg[1:0]da;
begin       
       parity=0;
       wait(!busy) 
       begin
       @(negedge clk)
        payload_len=10;
        da=2'b01;
        header={payload_len,da};
        datain=header;
        pkt_valid=1;
        parity=parity^header;
       
       for(i=0;i<payload_len;i=i+1)
        @(negedge clk)
        begin
            payload={$random}%256;
            datain=payload;
            parity=parity^datain;
        end
       
       @(negedge clk)
        pkt_valid=0;
        datain=parity;
       end
end              
endtask

task reading;
begin
@(negedge clk)
re0=1;
end
endtask

// calling task
initial
begin
reset;
#10;
initialise;
#5;
pkt1;
reading;
#200;
$finish;
end


// similarly write task for pkt of paylaod_len =14 and 16
endmodule
