`include "router.v"
`timescale 1ns/1ns

module router_tb
();
reg                   clk,reset;
reg       [4:0]       outputReady,validData;
reg       [15:0]      north_in,west_in,east_in,south_in,ni_in;
wire      [4:0]       valid,readyBuffer;
wire      [15:0]      north_out,west_out,east_out,south_out,ni_out;

router test( .clk(clk), .reset(reset),
             .outputReady(outputReady), .validData(validData),
             .north_in(north_in), .west_in(west_in), .east_in(east_in), .south_in(south_in), .ni_in(ni_in),
             .valid(valid), .readyBuffer(readyBuffer),
             .north_out(north_out), .west_out(west_out), .east_out(east_out), .south_out(south_out), .ni_out(ni_out));

initial begin
$dumpfile("router_tb.vcd");
$dumpvars(0,router_tb);

clk='b0;
reset='b1;
outputReady='b11111;
validData='b11111;
north_in='b11_001_00000000001;
west_in='b11_001_00000000010;
east_in='b11_001_00000000011;
south_in='b11_001_00000000100;
ni_in='b11_001_00000000101;
#10
clk=~clk;
reset=~reset;
north_in='b00_001_00000001111;
repeat(2)#10 clk=~clk;
north_in='b11_001_00000001110;
repeat(4)#10 clk=~clk;
west_in='b00_001_00000001100;
repeat(4)#10 clk=~clk;

end


endmodule
