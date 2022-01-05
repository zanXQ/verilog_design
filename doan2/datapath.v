module datapath
(
    input                   clk,reset,
    input                   validIn,
    input       [4:0]       outputAvailable,outputReady,outputGrant,
    input       [15:0]      dataIn,
    output      [16:0]      dataOut0,dataOut1,dataOut2,dataOut3,dataOut4,
    output      [4:0]       validOut,requestPort,
    output                  ready
);

wire            isHead;
wire            grant,readyPort;
wire   [4:0]    destination;
wire   [2:0]    selectPort;
wire            portAvailable;
wire            request;
reg    [4:0]    outPort;
reg             outLock;


assign isHead        = dataIn[15]&dataIn[14];
assign destination   = dataIn[13:11];

assign selectPort    = isHead?destination:outPort;

mux5_1 Available( .in(outputAvailable), .sel(selectPort), .out(portAvailable));
mux5_1 outReady ( .in(outputReady)    , .sel(selectPort), .out(readyPort));

assign request=validIn&(isHead?portAvailable:outLock);
demux1_5 outRequest( .in(request), .sel(selectPort), .out(requestPort));

assign ready    = readyPort&(outputGrant[4]|outputGrant[3]|outputGrant[2]|outputGrant[1]|outputGrant[0]);


assign dataOut0 = {validIn,dataIn};
assign dataOut1 = {validIn,dataIn};
assign dataOut2 = {validIn,dataIn};
assign dataOut3 = {validIn,dataIn};
assign dataOut4 = {validIn,dataIn};

always @(posedge clk or posedge reset) begin
    if(reset) begin
        outPort<=5'b0;
        outLock<=1'b0;
    end
    else begin
        if(isHead) begin
            outPort<=destination;
            outLock<=(outputGrant[4]|outputGrant[3]|outputGrant[2]|outputGrant[1]|outputGrant[0]);
        end
    end
end



endmodule



module mux5_1
(
    input   [4:0]    in,
    input   [2:0]    sel,
    output           out
);
wire    [1:0]    stage_1;
wire             stage_2;
wire             stage_3;

assign stage_1[0]=sel[0]?in[1]:in[0];
assign stage_1[1]=sel[0]?in[3]:in[2];

assign stage_2=sel[1]?stage_1[1]:stage_1[0];

assign stage_3=sel[2]?in[4]:stage_2;

assign out=stage_3;

endmodule

module demux1_5
(
    input            in,
    input   [2:0]    sel,
    output  [4:0]    out
);

assign out[0]=in&(!sel[2]&!sel[1]&!sel[0]);
assign out[1]=in&(!sel[2]&!sel[1]&sel[0]);
assign out[2]=in&(!sel[2]&sel[1]&!sel[0]);
assign out[3]=in&(!sel[2]&sel[1]&sel[0]);
assign out[4]=in&sel[2];

endmodule
