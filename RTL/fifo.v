`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.10.2024 09:59:03
// Design Name: 
// Module Name: router_fifo
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
module fifo(clk,resetn,soft_reset,we,re,lfd_state,datain,full,empty,dataout);
//INPUT,OUTPUT
input clk,resetn,soft_reset,we,re,lfd_state;
input [7:0]datain;
output reg full,empty;
output reg [7:0]dataout;
//internal Data types
reg [3:0]rd_ptr,wr_ptr;
reg [5:0]count;
reg [8:0]fifo[15:0];//9 BIT DATA WIDTH 1 BIT EXTRA FOR HEADER AND 16 DEPTH SIZE
integer i;
reg temp;
reg [3:0] fifo_counter;

//------------------------------------------------------------------------------
//lfd_state
always@(posedge clk)
	begin
		if(!resetn)
		    temp<=1'b0;
		else 
			temp<=lfd_state;
	end 


//-------------------------------------------------------------------------------------------------------------------
//Incrementer

always @(posedge clk )
begin
   if( !resetn )
       fifo_counter <= 0;

   else if( !full && we )
          fifo_counter <=    fifo_counter + 1;					//inc is increased because data is written

   else if( !empty && re )									// inc is decrease because data is read
          fifo_counter <=    fifo_counter - 1;
   else
         fifo_counter <=    fifo_counter;
end

//full and empty logic
always @(fifo_counter)
begin
if(fifo_counter==0)      //nothing in fifo
  empty = 1 ;
  else
  empty = 0;

  if(fifo_counter==4'b1111)  // fifo is full
   full = 1;
   else
   full = 0;
end 
//-----------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------------------------------
//Fifo write logic
always@(posedge clk)
	begin
		if(!resetn || soft_reset)
			begin
				for(i=0;i<16;i=i+1)
					fifo[i]<=0; 
			end
		
		else if(we && !full)
				{fifo[wr_ptr[3:0]][8],fifo[wr_ptr[3:0]][7:0]}<={temp,datain}; //temp=1 for header data and 0 for other data
	
	end

//
//----------------------------------------------------------------------------------------------------------------------------------------
//FIFO READ logic
always@(posedge clk)
	begin
		if(!resetn)
		    for(i=0;i<16;i=i+1) begin
		      fifo[i]<=0;  
		      dataout<=8'd0;
		      end
		else if(soft_reset)
			dataout<=8'bzz;
		
		else
			begin 
				if(re && !empty)
					dataout<=fifo[rd_ptr[3:0]];
				//if(count==0) // COMPLETELY READ
					//dataout<=8'bz;
			end
	end
//------------------------------------------------------------------------------------------------------------------------------------
//datasent counter logic //payload length from the hreader byte is assigned plus oine added to consider parity byte
always@(posedge clk)
	begin
		
		 if(re && !empty)
			begin
				if(fifo[rd_ptr[3:0]][8])                          //a header byte is read, an internal counter is loaded with the payload
                                                               //length of the packet plus(parity byte) and starts decrementing every clock till it reached 
					count<=fifo[rd_ptr[3:0]][7:2]+1'b1;

				else if(count!=6'd0)
					count<=count-1'b1;
				
			end
	
	end
//---------------------------------------------------------------------------------------------------------------
//pointer logic
always@(posedge clk)
	begin
		if(!resetn || soft_reset)
			begin
				rd_ptr=0;
				wr_ptr=0;
			end

		else 
			begin
				if(we && !full)
					wr_ptr=wr_ptr+1'b1;

				if(re && !empty)
					rd_ptr=rd_ptr+1'b1;
			end
	end

endmodule

  


    

