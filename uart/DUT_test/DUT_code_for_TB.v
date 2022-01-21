`include "uart.v"
`timescale 1ns/1ns

module DUT_code_for_TB
();

reg               clk,reset,en;
reg    [7:0]      data_in;
wire   [7:0]      data_out;
wire              done,we;
wire   [31:0]     address;

integer file_input;
integer file_output;

uart test( .clk(clk), .reset(reset), .en(en),
           .data_in(data_in),
           .data_out(data_out),
           .done(done), .we(we),
           .address(address));
			  


initial begin
file_input = $fopen("input.txt","w");
file_output = $fopen("output.txt","w");
$dumpfile("DUT_code_for_TB.vcd");
$dumpvars(0,DUT_code_for_TB);
clk='b0;
reset='b1;
en='b0;
data_in='h00;
#10
clk=~clk;
reset=~reset;
repeat(1)#10 clk=~clk;
en=~en;
repeat (22526)#10 clk=~clk;
$fclose(file_input);
$fclose(file_output);
end
//DUT testing
always @(clk) begin
		if ((done == 1) && (data_in <= 8'hff))begin
			$fdisplayb(file_input,data_in);
			$fdisplayb(file_output,data_out);
			//$fdisplay(file_input,"value display with $fstrobe");
			data_in <= data_in + 1;
		   #10 en <= 1;
			#10 reset <= 1;
			#10 reset <= 0;
			end
		
		$display("done");
end



endmodule  
