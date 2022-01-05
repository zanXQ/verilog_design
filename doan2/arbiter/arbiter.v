module arbiter_mux
(
    input                   clk,reset,
    input       [4:0]       request,
    input       [15:0]      data_0,data_1,data_2,data_3,data_4,
    output      [4:0]       grant,
    output      [15:0]      data_out,
    output                  outputAvailable
);

reg     [4:0]       prior;

wire    [1:0]       stage0      [4:0];
wire    [1:0]       stage1      [2:0];
wire    [1:0]       stage2      [1:0];
wire    [1:0]       stage3;

wire    [1:0]       stage1_sel;
wire                stage2_sel;
wire                stage3_sel;

wire    [15:0]      stage1_data   [2:0];
wire    [15:0]      stage2_data   [1:0];
wire    [16:0]      stage3_data;

wire    [4:0]       stage1_grant;
wire    [4:0]       stage2_grant;
wire    [4:0]       stage3_grant;

wire                anyGrant;

always @(posedge clk or posedge reset) begin
if(reset) prior <=5'b11111;
else begin
    if(anyGrant) begin
        prior[0]<=grant[4];
        prior[1]<=grant[4]|grant[0];
        prior[2]<=grant[4]|grant[0]|grant[1];
        prior[3]<=grant[4]|grant[0]|grant[1]|grant[2];
        prior[4]<=grant[0]|grant[1]|grant[2]|grant[3];
    end
end
end

//generate prior logic
assign stage0[0]={request[0],prior[0]};
assign stage0[1]={request[1],prior[1]};
assign stage0[2]={request[2],prior[2]};
assign stage0[3]={request[3],prior[3]};
assign stage0[4]={request[4],prior[4]};

//generate select signal for mux
max_sel stage_1_0( .in1(stage0[1]), .in2(stage0[0]), .out(stage1[0]), .sel(stage1_sel[0]));
max_sel stage_1_1( .in1(stage0[3]), .in2(stage0[2]), .out(stage1[1]), .sel(stage1_sel[1]));

assign stage1[2]=stage0[4];

max_sel stage_2( .in1(stage1[1]), .in2(stage1[0]), .out(stage2[0]), .sel(stage2_sel));
assign stage2[1]=stage1[2];

max_sel stage_3( .in1(stage2[1]), .in2(stage2[0]), .out(stage3), .sel(stage3_sel));

//generate datapath for output
assign stage1_data[0] = stage1_sel[0]?data_1:data_0;
assign stage1_data[1] = stage1_sel[1]?data_3:data_2;
assign stage1_data[2] = data_4;

assign stage2_data[0] = stage2_sel?stage1_data[1]:stage1_data[0];
assign stage2_data[1] = stage1_data[2];

assign stage3_data=stage3_sel?stage2_data[1]:stage2_data[0];

//generate grant signal
assign stage1_grant[0]=request[0]&!stage1_sel[0];
assign stage1_grant[1]=request[1]&stage1_sel[0];
assign stage1_grant[2]=request[2]&!stage1_sel[1];
assign stage1_grant[3]=request[3]&stage1_sel[1];
assign stage1_grant[4]=request[4];

assign stage2_grant[0]=stage1_grant[0]&!stage2_sel;
assign stage2_grant[1]=stage1_grant[1]&!stage2_sel;
assign stage2_grant[2]=stage1_grant[2]&stage2_sel;
assign stage2_grant[3]=stage1_grant[3]&stage2_sel;
assign stage2_grant[4]=stage1_grant[4];

assign stage3_grant[0]=stage2_grant[0]&!stage3_sel;
assign stage3_grant[1]=stage2_grant[1]&!stage3_sel;
assign stage3_grant[2]=stage2_grant[2]&!stage3_sel;
assign stage3_grant[3]=stage2_grant[3]&!stage3_sel;
assign stage3_grant[4]=stage2_grant[4]&stage3_sel;

assign grant=stage3_grant;
assign anyGrant=stage3_grant[4]|stage3_grant[3]|stage3_grant[2]|stage3_grant[1]|stage3_grant[0];


always @(posedge clk or posedge reset) begin
if(reset) outputAvailable <='b1;
else begin
    if(anyGrant) begin
        outputAvailable=!anyGrant;
    end
end
end

assign data_out=stage3_data;

endmodule


/////////comparator select max input//////////////
module max_sel
(
    input       [1:0]       in1,in2,
    output      [1:0]       out,
    output                  sel
);

assign sel= (in1[1]&!in2[1])|(in1[0]&!in2[1]&!in2[0])|(in1[1]&in1[0]&!in2[0]);
assign out= sel?in1:in2;

endmodule
