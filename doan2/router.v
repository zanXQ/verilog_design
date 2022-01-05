`include "datapath.v"
`include "arbiter.v"

module router
(
    input                   clk,reset,
    input       [4:0]       outputReady,validData,
    input       [15:0]      north_in,west_in,east_in,south_in,ni_in,
    output      [4:0]       valid,readyBuffer,
    output      [15:0]      north_out,west_out,east_out,south_out,ni_out
);


wire    [4:0]  outputAvailable          ;
wire    [4:0]  outputGrant         [4:0];


wire    [16:0]   dataOut0   [4:0];
wire    [16:0]   dataOut1   [4:0];
wire    [16:0]   dataOut2   [4:0];
wire    [16:0]   dataOut3   [4:0];
wire    [16:0]   dataOut4   [4:0];

wire    [16:0]   data_out   [4:0];


wire    [4:0]   requestPort [4:0];
wire    [4:0]   request     [4:0];



datapath northGate(  .clk(clk), .reset(reset),
                     .validIn(validData[0]),
                     .outputAvailable(outputAvailable), .outputReady(outputReady), .outputGrant({outputGrant[4][0],outputGrant[3][0],outputGrant[2][0],outputGrant[1][0],outputGrant[0][0]}),
                     .dataIn(north_in),
                     .dataOut0(dataOut0[0]), .dataOut1(dataOut1[0]), .dataOut2(dataOut2[0]), .dataOut3(dataOut3[0]), .dataOut4(dataOut4[0]),
                     .requestPort(requestPort[0]),
                     .ready(readyBuffer[0]));

datapath westGate(   .clk(clk), .reset(reset),
                     .validIn(validData[1]),
                     .outputAvailable(outputAvailable), .outputReady(outputReady), .outputGrant({outputGrant[4][1],outputGrant[3][1],outputGrant[2][1],outputGrant[1][1],outputGrant[0][1]}),
                     .dataIn(west_in),
                     .dataOut0(dataOut0[1]), .dataOut1(dataOut1[1]), .dataOut2(dataOut2[1]), .dataOut3(dataOut3[1]), .dataOut4(dataOut4[1]),
                     .requestPort(requestPort[1]),
                     .ready(readyBuffer[1]));

datapath eastGate (  .clk(clk), .reset(reset),
                     .validIn(validData[2]),
                     .outputAvailable(outputAvailable), .outputReady(outputReady), .outputGrant({outputGrant[4][2],outputGrant[3][2],outputGrant[2][2],outputGrant[1][2],outputGrant[0][2]}),
                     .dataIn(east_in),
                     .dataOut0(dataOut0[2]), .dataOut1(dataOut1[2]), .dataOut2(dataOut2[2]), .dataOut3(dataOut3[2]), .dataOut4(dataOut4[2]),
                     .requestPort(requestPort[2]),
                     .ready(readyBuffer[2]));

datapath southGate(  .clk(clk), .reset(reset),
                     .validIn(validData[3]),
                     .outputAvailable(outputAvailable), .outputReady(outputReady), .outputGrant({outputGrant[4][3],outputGrant[3][3],outputGrant[2][3],outputGrant[1][3],outputGrant[0][3]}),
                     .dataIn(south_in),
                     .dataOut0(dataOut0[3]), .dataOut1(dataOut1[3]), .dataOut2(dataOut2[3]), .dataOut3(dataOut3[3]), .dataOut4(dataOut4[3]),
                     .requestPort(requestPort[3]),
                     .ready(readyBuffer[3]));

datapath niGate   (  .clk(clk), .reset(reset),
                     .validIn(validData[4]),
                     .outputAvailable(outputAvailable), .outputReady(outputReady), .outputGrant({outputGrant[4][4],outputGrant[3][4],outputGrant[2][4],outputGrant[1][4],outputGrant[0][4]}),
                     .dataIn(ni_in),
                     .dataOut0(dataOut0[4]), .dataOut1(dataOut1[4]), .dataOut2(dataOut2[4]), .dataOut3(dataOut3[4]), .dataOut4(dataOut4[4]),
                     .requestPort(requestPort[4]),
                     .ready(readyBuffer[4]));



assign request[0]={requestPort[4][0],requestPort[3][0],requestPort[2][0],requestPort[1][0],requestPort[0][0]};
assign request[1]={requestPort[4][1],requestPort[3][1],requestPort[2][1],requestPort[1][1],requestPort[0][1]};
assign request[2]={requestPort[4][2],requestPort[3][2],requestPort[2][2],requestPort[1][2],requestPort[0][2]};
assign request[3]={requestPort[4][3],requestPort[3][3],requestPort[2][3],requestPort[1][3],requestPort[0][3]};
assign request[4]={requestPort[4][4],requestPort[3][4],requestPort[2][4],requestPort[1][4],requestPort[0][4]};

arbiter_mux arbiterNorth( .clk(clk), .reset(reset),
                          .request(request[0]),
                          .data_0(dataOut0[0]), .data_1(dataOut0[1]), .data_2(dataOut0[2]), .data_3(dataOut0[3]), .data_4(dataOut0[4]),
                          .grant(outputGrant[0]),
                          .data_out(data_out[0]),
                          .outputAvailable(outputAvailable[0]));

arbiter_mux arbiterWest ( .clk(clk), .reset(reset),
                          .request(request[1]),
                          .data_0(dataOut1[0]), .data_1(dataOut1[1]), .data_2(dataOut1[2]), .data_3(dataOut1[3]), .data_4(dataOut1[4]),
                          .grant(outputGrant[1]),
                          .data_out(data_out[1]),
                          .outputAvailable(outputAvailable[1]));

arbiter_mux arbiterEast ( .clk(clk), .reset(reset),
                          .request(request[2]),
                          .data_0(dataOut2[0]), .data_1(dataOut2[1]), .data_2(dataOut2[2]), .data_3(dataOut2[3]), .data_4(dataOut2[4]),
                          .grant(outputGrant[2]),
                          .data_out(data_out[2]),
                          .outputAvailable(outputAvailable[2]));

arbiter_mux arbiterSouth( .clk(clk), .reset(reset),
                          .request(request[3]),
                          .data_0(dataOut3[0]), .data_1(dataOut3[1]), .data_2(dataOut3[2]), .data_3(dataOut3[3]), .data_4(dataOut3[4]),
                          .grant(outputGrant[3]),
                          .data_out(data_out[3]),
                          .outputAvailable(outputAvailable[3]));

arbiter_mux arbiterNi   ( .clk(clk), .reset(reset),
                          .request(request[4]),
                          .data_0(dataOut4[0]), .data_1(dataOut4[1]), .data_2(dataOut4[2]), .data_3(dataOut4[3]), .data_4(dataOut4[4]),
                          .grant(outputGrant[4]),
                          .data_out(data_out[4]),
                          .outputAvailable(outputAvailable[4]));

assign valid={data_out[4][16],data_out[3][16],data_out[2][16],data_out[1][16],data_out[0][16]};

assign north_out=data_out[0][15:0];
assign west_out =data_out[1][15:0];
assign east_out =data_out[2][15:0];
assign south_out=data_out[3][15:0];
assign ni_out   =data_out[4][15:0];

endmodule

/////////CREDIT COUNTER/////////////
/*
module credit_counter
(
    input                   clk,reset,
    input                   inc,dec,
    output                  ready_out
);
reg     [3:0]    credit;
wire             head,tail;
wire             inc_temp,dec_temp;
wire             change,no_change;
wire    [3:0]    credit_change;

always @(posedge clk or posedge reset) begin
    if(reset) credit<='b1111;
    else begin
        if(change)         credit<=credit_change;
    end
end

add_sub_4bits up_down( .a(credit), .b({3'b0,change}), .cin(dec_temp), .sum(credit_change));

assign head=credit[3]&credit[2]&credit[1]&credit[0];
assign tail=!credit[3]&!credit[2]&!credit[1]&!credit[0];

assign inc_temp=!head&inc;
assign dec_temp=!tail&dec;

assign no_change=inc&dec;
assign change=(inc_temp|dec_temp)&!no_change;

assign ready_out=!tail|no_change;

endmodule
*/

//////////ELASTIC BUFFER/////////////
module buffer
(
    input                   clk,reset,
    input                   ready_in,valid_in,
    input       [15:0]      data_in,
    output      [15:0]      data_out,
    output                  ready_out,valid_out
);
wire            fifo_full,fifo_empty;
wire            control_push,control_pop;

assign control_push=valid_in&!fifo_full;
assign control_pop=ready_in&!fifo_empty;

assign ready_out=!fifo_full;
assign valid_out=!fifo_empty;

FIFO fifo( .clk(clk), .reset(reset),
           .push(control_push), .pop(control_pop),
           .data_in(data_in),
           .data_out(data_out),
           .fifo_full(fifo_full), .fifo_empty(fifo_empty));


endmodule

//////////FIFO///////////////////////
module FIFO
#(
parameter  flit_size       = 16,
parameter  size_mem        = 16,                 //number of slot
parameter  size_pointer    = 4                   //pointer of the fifo (resize to fit the size of mem);
)

(
    input                                clk,reset,
    input                                push,pop,
    input           [flit_size-1:0]      data_in,
    output   reg    [flit_size-1:0]      data_out,
    output                               fifo_full,fifo_empty
);


reg     [flit_size-1:0]                 mem     [size_mem-1:0];          //fifo has size slot of 10 bit data storage
reg     [size_pointer-1:0]     pointer_head;                             //pointer to the head
reg     [size_pointer-1:0]     pointer_tail;                             //pointer to the tail
wire    [size_pointer-1:0]     pointer_head_inc,pointer_tail_inc;        //hold the value increment or dercrement of pointer


always @(posedge clk or posedge reset) begin
    if(reset) begin
        pointer_head<=4'b0;                       //initialize the head pointer
        pointer_tail<=4'b0;                       //initialize the tail pointer
    end
    else begin
        if(push & !fifo_full)
            pointer_head=pointer_head_inc;          //move pointer to next position
        if(pop & !fifo_empty)
            pointer_tail=pointer_tail_inc;          //move pointer to next position
    end
end

always @(posedge clk) begin                     //write side of fifo
    if(push) begin
        mem[pointer_head]=data_in;              //push new data into stack
    end
end

always @(posedge clk) begin                     //read side of fifo
    if(pop) begin
        data_out<=mem[pointer_tail];            //pop data from stack
    end
end

assign fifo_empty=!(pointer_head_inc[3]^pointer_tail_inc[3])&!(pointer_head_inc[2]^pointer_tail_inc[2])&!(pointer_head_inc[1]^pointer_tail_inc[1])&!(pointer_head_inc[0]^pointer_tail_inc[0]);   //both pointer at the same position
assign fifo_full=!(pointer_head_inc[3]^pointer_tail[3])&!(pointer_head_inc[2]^pointer_tail[2])&!(pointer_head_inc[1]^pointer_tail[1])&!(pointer_head_inc[0]^pointer_tail[0]);                    //next value of head pointer is the current position of tail value


adder_4bits head( .a(pointer_head), .b(4'b0),
                  .cin(1'b1),
                  .output_adder_4bits(pointer_head_inc));

adder_4bits tail( .a(pointer_tail), .b(4'b0),
                  .cin(1'b1),
                  .output_adder_4bits(pointer_tail_inc));

endmodule






//////////mux////////////////////////
module mux4_1
(
	input 	[31:0]	temp1_0,temp1_1,temp1_2,temp1_3,
	input	[1:0]	sel,
	output	[31:0]	temp2
);

assign temp2=sel[1]?(sel[0]?temp1_3:temp1_2):(sel[0]?temp1_1:temp1_0);

endmodule





//////////adder/////////////////////

module adder_4bits
(
    input   [3:0]      a,b,
    input              cin,
    output  [3:0]      output_adder_4bits,
    output             cout
);
wire    [3:0]      cout_temp;

full_adder a0( .a(a[0]), .b(b[0]), .cin(cin),
               .s(output_adder_4bits[0]), .cout(cout_temp[0]));

full_adder a1( .a(a[1]), .b(b[1]), .cin(cout_temp[0]),
               .s(output_adder_4bits[1]), .cout(cout_temp[1]));

full_adder a2( .a(a[2]), .b(b[2]), .cin(cout_temp[1]),
               .s(output_adder_4bits[2]), .cout(cout_temp[2]));

full_adder a3( .a(a[3]), .b(b[3]), .cin(cout_temp[2]),
               .s(output_adder_4bits[3]), .cout(cout_temp[3]));
assign cout=cout_temp[3];

endmodule

module full_adder
(
    input               a,b,cin,
    output              s,cout
);

assign s=cin^(a^b);
assign cout=cin&(a^b)|(a&b);

endmodule

////////////4 bit adder subtractor//////////////////////
module add_sub_4bits
(
	input		[3:0]		a,b,
	input					cin,               //if 1 then subtract, 0 add
	output	    [3:0]		sum
);
wire			[3:0]		cout;
wire            [3:0]       b_temp;

assign b_temp={4{cin}}^b;

full_adder a0  (.a(a[0]),  .b(b_temp[0]),  .cin(cin),      .s(sum[0]),  .cout(cout[0]));
full_adder a1  (.a(a[1]),  .b(b_temp[1]),  .cin(cout[0]),  .s(sum[1]),  .cout(cout[1]));
full_adder a2  (.a(a[2]),  .b(b_temp[2]),  .cin(cout[1]),  .s(sum[2]),  .cout(cout[2]));
full_adder a3  (.a(a[3]),  .b(b_temp[3]),  .cin(cout[2]),  .s(sum[3]),  .cout(cout[3]));

endmodule
