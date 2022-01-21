`include "uart.v"
`timescale 1ns/1ns

module uart_tb
();

reg               clk,reset,en;
reg    [7:0]      data_in;
wire   [7:0]      data_out;
wire              done,we;
wire   [31:0]     address;

uart test( .clk(clk), .reset(reset), .en(en),
           .data_in(data_in),
           .data_out(data_out),
           .done(done), .we(we),
           .address(address));

initial begin
$dumpfile("uart_tb.vcd");
$dumpvars(0,uart_tb);
clk='b0;
reset='b1;
en='b0;
data_in='b11001100;
#10
clk=~clk;
reset=~reset;
repeat(2)#10 clk=~clk;
en=~en;
repeat (100)#10 clk=~clk;

end

endmodule
