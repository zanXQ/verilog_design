`include"datapath.v"
`timescale 1ns/1ns

module datapath_tb
();

reg                   clk,reset;
reg                   validIn;
reg       [4:0]       outputAvailable,outputReady,outputGrant;
reg       [15:0]      dataIn;
wire      [15:0]      dataOut0,dataOut1,dataOut2,dataOut3,dataOut4;
wire      [4:0]       validOut,requestPort;
wire                  ready;

datapath test( .clk(clk), .reset(reset),
               .validIn(validIn),
               .outputAvailable(outputAvailable), .outputReady(outputReady), .outputGrant(outputGrant),
               .dataIn(dataIn),
               .dataOut0(dataOut0), .dataOut1(dataOut1), .dataOut2(dataOut2), .dataOut3(dataOut3), .dataOut4(dataOut4),
               .requestPort(requestPort),
               .ready(ready));

initial begin
$dumpfile("datapath_tb.vcd");
$dumpvars(0,datapath_tb);


clk             ='b0;
reset           ='b1;
validIn         ='b1;
outputAvailable ='b00100;
outputReady     ='b00010;
outputGrant     ='b00010;
dataIn          ='b11_001_00010000000;
#10
clk=~clk;
reset=~reset;
repeat(4) #10 clk=~clk;
dataIn          ='b11_010_00010000000;
repeat(4) #10 clk=~clk;

end



endmodule
