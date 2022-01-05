`include "max_sel.v"
`timescale 1ns/1ns

module max_sel_tb
();

reg       [1:0]       in1,in2;
wire      [1:0]       out;
wire                  sel;

max_sel a( .in1(in1), .in2(in2), .out(out), .sel(sel));

initial begin

$dumpfile("max_sel_tb.vcd");
$dumpvars(0,max_sel_tb);

#10
in1='b00;
in2='b00;
#10
in1='b00;
in2='b01;
#10
in1='b00;
in2='b10;
#10
in1='b00;
in2='b11;
#10
in1='b01;
in2='b00;
#10
in1='b01;
in2='b01;
#10
in1='b01;
in2='b10;
#10
in1='b01;
in2='b11;
#10
in1='b10;
in2='b00;
#10
in1='b10;
in2='b01;
#10
in1='b10;
in2='b10;
#10
in1='b10;
in2='b11;
#10
in1='b11;
in2='b00;
#10
in1='b11;
in2='b01;
#10
in1='b11;
in2='b10;
#10
in1='b11;
in2='b11;


end

endmodule
