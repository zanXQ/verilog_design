`include "arbiter.v"
`timescale 1ns/1ns

module arbiter_mux_tb
();
reg                        clk,reset;
reg            [4:0]       request;
reg            [15:0]      data_0,data_1,data_2,data_3,data_4;
wire           [4:0]       grant;
wire           [15:0]      data_out;
wire                       outputAvailable;

arbiter_mux a( .clk(clk), .reset(reset),
               .request(request),
               .data_0(data_0), .data_1(data_1), .data_2(data_2), .data_3(data_3), .data_4(data_4),
               .grant(grant),
               .data_out(data_out),
               .outputAvailable(outputAvailable));

initial begin
$dumpfile("arbiter_tb.vcd");
$dumpvars(0,arbiter_mux_tb);

clk='b0;
reset='b1;
data_0='h00A;
data_1='h00B;
data_2='h00C;
data_3='h00D;
data_4='h00E;
request='b00100;
#10
clk=~clk;
reset='b0;
repeat(4)#10 clk=~clk;
request='b01100;
repeat(4)#10 clk=~clk;
request='b00000;
repeat(4)#10 clk=~clk;

end


endmodule
