`timescale 1ns/1ns

module buffer_tb
();
reg                    clk,reset;
reg                    ready_in,valid_in;
reg         [9:0]      data_in;
wire        [9:0]      data_out;
wire                   ready_out,valid_out;


buffer a( .clk(clk), .reset(reset),
        .ready_in(ready_in), .valid_in(valid_in),
        .data_in(data_in),
        .data_out(data_out),
        .ready_out(ready_out), .valid_out(valid_out));

initial begin
$dumpfile("buffer_tb.vcd");
$dumpvars(0,buffer_tb);
#10;
clk='b1;
reset='b0;
ready_in='b0;
valid_in='b0;
#10
clk=~clk;
reset='b1;
#10
clk=~clk;
reset='b0;
ready_in='b1;
valid_in='b0;
data_in='b0000000111;
#10
clk=~clk;
reset='b0;
ready_in='b0;
valid_in='b1;
data_in='b0000001011;
#10
clk=~clk;
reset='b0;
ready_in='b0;
valid_in='b1;
data_in='b0000001111;
#10
clk=~clk;
reset='b0;
ready_in='b1;
valid_in='b0;
#10
clk=~clk;
reset='b0;
ready_in='b1;
valid_in='b0;
#10
clk=~clk;
reset='b0;
ready_in='b1;
valid_in='b0;
#10
clk=~clk;
reset='b0;
ready_in='b1;
valid_in='b0;
repeat (4)#10 clk=~clk;


end

endmodule


//////////ELASTIC BUFFER/////////////
module buffer
(
    input                   clk,reset,
    input                   ready_in,valid_in,
    input       [9:0]      data_in,
    output      [9:0]      data_out,
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
parameter  flit_size       = 10,
parameter  size_mem        = 16,                 //number of slot
parameter  size_pointer    = 4                   //pointer of the fifo (resize to fit the size of mem);
)

(
    input                   clk,reset,
    input                   push,pop,
    input       [flit_size-1:0]      data_in,
    output  reg [flit_size-1:0]      data_out,
    output                  fifo_full,fifo_empty
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
    if(push && !fifo_full) begin
        mem[pointer_head]=data_in;              //push new data into stack
    end
end

always @(posedge clk) begin                     //read side of fifo
    if(pop && !fifo_empty) begin
        data_out=mem[pointer_tail];             //pop data
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
