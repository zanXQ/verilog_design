`include "uart_tx.v"
`timescale 1ns/1ns

module uart_tx_tb
();

reg             clk,reset,en;
reg   [7:0]     data;
wire            data_tx;

uart_tx test_tx( .clk(clk), .reset(reset), .en(en),
                 .data(data),
                 .data_tx(data_tx));



initial begin
$dumpfile("uart_tx_tb.vcd");
$dumpvars(0,uart_tx_tb);
clk='b0;
reset='b1;
en='b0;
data='b01110110;
#10
clk=~clk;
reset=~reset;
repeat(2)#10 clk=~clk;
en=~en;
repeat (100)#10 clk=~clk;


end

endmodule
