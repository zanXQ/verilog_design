


module doan(
	input										clk,reset,en,
	input				[31:0]				RAM_DATA,
	output			[31:0]				RAM_IN,RAM_ADDRESS,
	output									en_RAM
);
wire		[31:0]	IR,DATA_PC,DATA_PC_MEM,PC_increment;
wire 					fetch,decode,execute,cache,write,zero_flag,input_ins,output_ins;
wire					ALU_1,ALU_2,ALU_3,ALU_4;
wire					en_REG,en_IR,en_PC;
wire		[3:0]		mux_a,mux_b,mux_in;
wire					mux_pc;



wire		[31:0]	ALU_a,ALU_b;
wire		[31:0]	ALU_data;

wire		[31:0]	RAM_ADDRESS_R,RAM_ADDRESS_W;

sequence_generator sequence( .clk(clk), .reset(reset), .en(en), .fetch(fetch), .decode(decode), .execute(execute), .cache(cache), .write(write));

instruction_decoder ins_decode( .IR(IR), 
							 .fetch(fetch), .decode(decode), .execute(execute), .cache(cache), .write(write), .zero_flag(zero_flag),
							 .ALU_1(ALU_1), .ALU_2(ALU_2), .ALU_3(ALU_3), .ALU_4(ALU_4), .input_ins(input_ins), .output_ins(output_ins),
							 .en_REG(en_REG), .en_RAM(en_RAM), .en_IR(en_IR), .en_PC(en_PC),
							 .mux_a(mux_a), .mux_b(mux_b), .mux_in(mux_in),
							 .mux_pc(mux_pc));
							
register register( .D(DATA_PC_MEM), .RAM_DATA(RAM_DATA),
			  .sel_in(mux_in), .sel_a(mux_a), .sel_b(mux_b),
			  .clr(reset), .clk(clk), .en_IR(en_IR), .en_PC(en_PC), .en(en_REG),
			  .fetch(fetch), .decode(decode), .execute(execute), .cache(cache), .write(write),
			  .data_a(ALU_a), .data_b(ALU_b),
			  .data_output(RAM_IN), .data_mux_ir(IR), .data_mux_pc(RAM_ADDRESS_R), .PC_increment(PC_increment));

assign DATA_PC=mux_pc?PC_increment:ALU_data;
assign DATA_PC_MEM=(input_ins&cache)?RAM_DATA:DATA_PC;
assign RAM_ADDRESS=((input_ins|output_ins)&cache)?RAM_ADDRESS_W:RAM_ADDRESS_R;
assign RAM_ADDRESS_W=ALU_data;


			  
ALU ALU( .a(ALU_a), .b(ALU_b),
		.clk(clk), .reset(reset), .execute(execute),
		.ALU_1(ALU_1), .ALU_2(ALU_2), .ALU_3(ALU_3), .ALU_4(ALU_4),
		.data(ALU_data),
		.zero_flag(zero_flag));


//=======================================================
//  REG/WIRE declarations
//=======================================================




//=======================================================
//  Structural coding
//=======================================================



endmodule

module cpu_ram
(
	input					clk,reset,en,
	output	[31:0]	RAM_DATA,RAM_IN,RAM_ADDRESS,en_RAM			
);

//wire		[31:0]		RAM_DATA,RAM_IN;
//wire		[31:0]		RAM_ADDRESS;
//wire						en_RAM;

cpu	cpu( .clk(clk), .reset(reset), .en(en), .RAM_DATA(RAM_DATA),
			  .RAM_IN(RAM_IN), .RAM_ADDRESS(RAM_ADDRESS), .en_RAM(en_RAM));

single_port_ram	ram( .data(RAM_IN), .addr(RAM_ADDRESS[6:0]), .we(en_RAM), .clk(clk), .q(RAM_DATA));

endmodule

module cpu_ram_tb
();

reg 				clk,reset,en;
wire	[31:0]	RAM_DATA,RAM_IN,RAM_ADDRESS,en_RAM;

cpu_ram a(.clk(clk), .reset(reset), .en(en),
			 .RAM_DATA(RAM_DATA), .RAM_IN(RAM_IN), .RAM_ADDRESS(RAM_ADDRESS), .en_RAM(en_RAM));

initial begin
clk='b1;
repeat(4) #10 clk = ~clk;
forever #10 clk = ~clk;
end

initial begin
#10 reset='b1;
#10 en='b0;
#10 reset='b0;
//#10 reset='b1;	
#10 en = 'b1;
//$finish;
end

endmodule

module single_port_ram
(
	input [31:0] data,
	input [6:0] addr,
	input we, clk,
	output [31:0] q
);

	// Declare the RAM variable
	reg [31:0] ram[127:0];
	
	// Variable to hold the registered read address
	
	
	always @ (posedge clk)
	begin
	// Write
		if (we)
			ram[addr] <= data;
		
	end
		
	// Continuous assignment implies read returns NEW data.
	// This is the natural behavior of the TriMatrix memory
	// blocks in Single Port mode.  
	assign q = ram[addr];
	
	
	initial begin
		ram[0]=32'hA1EE0007; ///load r1 7
		ram[1]=32'hA2EE0003; ///load r2 3
		ram[2]=32'h30120000; ///add  r0 r1 r2
		ram[3]=32'h13FE0002; ///input r3=M[6]
		ram[4]=32'h44030000;	///sub r4 r0 r3
		ram[5]=32'h7FFE0002; ///j_z pc=pc+2
		ram[6]=32'h0000000A; ///M[6]=10
		ram[7]=32'h20FE0001;	///output M[9]=r0 
		ram[8]=32'hA5EE0007; ///load r5 7
	end
		
	
endmodule

/////////////////////////cpu///////////////////////

module cpu
(
	input										clk,reset,en,
	input				[31:0]				RAM_DATA,
	output			[31:0]				RAM_IN,RAM_ADDRESS,
	output									en_RAM
);
wire		[31:0]	IR,DATA_PC,DATA_PC_MEM,PC_increment;
wire 					fetch,decode,execute,cache,write,zero_flag,input_ins,output_ins;
wire					ALU_1,ALU_2,ALU_3,ALU_4;
wire					en_REG,en_IR,en_PC;
wire		[3:0]		mux_a,mux_b,mux_in;
wire					mux_pc;



wire		[31:0]	ALU_a,ALU_b;
wire		[31:0]	ALU_data;

wire		[31:0]	RAM_ADDRESS_R,RAM_ADDRESS_W;

sequence_generator sequence( .clk(clk), .reset(reset), .en(en), .fetch(fetch), .decode(decode), .execute(execute), .cache(cache), .write(write));

instruction_decoder ins_decode( .IR(IR), 
							 .fetch(fetch), .decode(decode), .execute(execute), .cache(cache), .write(write), .zero_flag(zero_flag),
							 .ALU_1(ALU_1), .ALU_2(ALU_2), .ALU_3(ALU_3), .ALU_4(ALU_4), .input_ins(input_ins), .output_ins(output_ins),
							 .en_REG(en_REG), .en_RAM(en_RAM), .en_IR(en_IR), .en_PC(en_PC),
							 .mux_a(mux_a), .mux_b(mux_b), .mux_in(mux_in),
							 .mux_pc(mux_pc));
							
register register( .D(DATA_PC_MEM), .RAM_DATA(RAM_DATA),
			  .sel_in(mux_in), .sel_a(mux_a), .sel_b(mux_b),
			  .clr(reset), .clk(clk), .en_IR(en_IR), .en_PC(en_PC), .en(en_REG),
			  .fetch(fetch), .decode(decode), .execute(execute), .cache(cache), .write(write),
			  .data_a(ALU_a), .data_b(ALU_b),
			  .data_output(RAM_IN), .data_mux_ir(IR), .data_mux_pc(RAM_ADDRESS_R), .PC_increment(PC_increment));

assign DATA_PC=mux_pc?PC_increment:ALU_data;
assign DATA_PC_MEM=(input_ins&cache)?RAM_DATA:DATA_PC;
assign RAM_ADDRESS=((input_ins|output_ins)&cache)?RAM_ADDRESS_W:RAM_ADDRESS_R;
assign RAM_ADDRESS_W=ALU_data;


			  
ALU ALU( .a(ALU_a), .b(ALU_b),
		.clk(clk), .reset(reset), .execute(execute),
		.ALU_1(ALU_1), .ALU_2(ALU_2), .ALU_3(ALU_3), .ALU_4(ALU_4),
		.data(ALU_data),
		.zero_flag(zero_flag));

endmodule

module cpu_tb
(
);

	reg										clk,reset,en;
	reg				[31:0]				RAM_DATA;
	wire				[31:0]				RAM_IN,RAM_ADDRESS;
	wire										en_RAM;

cpu a( .clk(clk), .reset(reset), .en(en), .RAM_DATA(RAM_DATA), .RAM_IN(RAM_IN), .RAM_ADDRESS(RAM_ADDRESS), .en_RAM(en_RAM));

initial begin
clk='b1;
repeat(4) #10 clk = ~clk;
forever #10 clk = ~clk;
end

initial begin
#10 reset='b1;
#10 en='b0;
#10 reset='b0;	
#10 en = 'b1;
//#10 reset='b1;
#10 RAM_DATA=32'h9FFE0003;
$finish;
end

endmodule

/////////////decode//////////////////////////////////////

module instruction_decoder
(
	input 			[31:0]				IR,
	input										fetch,decode,execute,cache,write,zero_flag,
	output									ALU_1,ALU_2,ALU_3,ALU_4,input_ins,output_ins,
	output									en_REG,en_RAM,en_IR,en_PC,
	output			[3:0]					mux_a,mux_b,mux_in,
	output									mux_pc
);
wire				jump_z,jump_pn,jump,load_ins;
wire				temp={input_ins,output_ins,ALU_1,ALU_2,ALU_3,ALU_4,jump_z,jump_pn,jump,load_ins};

//opcode decipher//
assign input_ins=!IR[31] & !IR[30] & !IR[29] & IR[28];
assign output_ins=!IR[31] & !IR[30] & IR[29] & !IR[28];
assign ALU_1=((!IR[31] & !IR[30] & IR[29] & IR[28])|input_ins|output_ins|jump_z|jump_pn|jump);
assign ALU_2=(!IR[31] & IR[30] & !IR[29] & !IR[28]);
assign ALU_3=((!IR[31] & IR[30] & !IR[29] & IR[28])|load_ins);
assign ALU_4=(!IR[31] & IR[30] & IR[29] & !IR[28]);
assign jump_z=!IR[31] & IR[30] & IR[29] & IR[28];
assign jump_pn=IR[31] & !IR[30] & !IR[29] & IR[28];
assign jump=IR[31] & !IR[30] & !IR[29] & IR[28];
assign load_ins=IR[31] & !IR[30] & IR[29] & !IR[28];

//update register signal//
assign en_REG=((cache &input_ins) | (write&((!input_ins&ALU_1)|ALU_2|ALU_3|ALU_4|load_ins)))&!output_ins;
assign en_RAM=cache & output_ins;
assign en_IR=fetch;
assign en_PC=(execute&((jump_z&zero_flag) | (jump_pn & !zero_flag) | jump))|(decode&!((jump_z&zero_flag) | (jump_pn & !zero_flag) | jump));

assign mux_pc=(decode&!((jump_z&zero_flag) | (jump_pn & !zero_flag) | jump));

//select register//
assign mux_a=IR[23:20];//SR1
assign mux_b=IR[19:16];//SR2
assign mux_in=IR[27:24];//DR


endmodule

///////////////////////ALU//////////////////////////////////////////////////////////

module ALU
(
	input				[31:0]				a,b,
	input										clk,reset,execute,
	input										ALU_1,ALU_2,ALU_3,ALU_4,
	output			[31:0]				data,
	output		reg						zero_flag
);
wire				[31:0]				adder_a,adder_b;
wire										adder_cin;
wire				[31:0]				adder_sum;
wire				[31:0]				bitwise_and,bitwise_or;

//adder,subtractor

assign adder_a=a;

assign adder_b=b^{32{ALU_2}};

assign adder_cin=ALU_2;


adder_32bit a0	( .a(adder_a), .b(adder_b), .cin(adder_cin), .sum(adder_sum));

	
always @ (posedge clk) begin
if(reset) zero_flag<='b0;
else begin
	if(execute==1) zero_flag<=!data;
end
end

//bitwise_and
assign bitwise_and=a&b;
//bitwise_or
assign bitwise_or=a|b;

assign data=(({32{ALU_1}}|{32{ALU_2}})&adder_sum)|({32{ALU_3}}&bitwise_and)|({32{ALU_4}}&bitwise_or);

endmodule


//////////////////state/////////////////////////////

module sequence_generator
(
	input									clk,reset,en,
	output								fetch,decode,execute,cache,write
);
reg		[4:0]			state;


integer i;
always @ (posedge clk or posedge reset) begin
if(reset) state <= 'b10000;
else begin
	if(en==1) begin
	state[4]<=state[0];
	for( i=0; i<4; i=i+1)begin
		state[i]<=state[i+1];
	end
	end
end
end

assign fetch=state[4];
assign decode=state[3];
assign execute=state[2];
assign cache=state[1];
assign write=state[0];
endmodule


module sequence_generator_tb
(
);
reg	clk,reset,en;
wire	fetch,decode,execute,write;


sequence_generator a( .clk(clk), .reset(reset), .en(en),
							 .fetch(fetch), .decode(decode), .execute(execute), .cache(cache), .write(write));

initial begin
clk='b1;
repeat(4) #10 clk = ~clk;
forever #10 clk = ~clk;
end

initial begin
#10 reset='b1;
#10 en='b0;
#10 reset='b0;	
#10 en = 'b1;
//#10 reset='b1;
$finish;
end
							 
endmodule
////////////////////REGISTER///////////////////////////

module general_register
(
	input					[31:0]		D,
	input									clr,clk,en,
	output	reg		[31:0]		Q
);

always @ (posedge clk or posedge clr) begin
if(clr) Q<='b0;
else begin
	if (en==1) Q<=D;
end
end

endmodule

module register
(
	input				[31:0]		D,RAM_DATA,
	input				[3:0]		sel_in,sel_a,sel_b,
	input							clr,clk,en_IR,en_PC,en,
	input							fetch,decode,execute,cache,write,
	output				[31:0]		data_a,data_b,
	output				[31:0]		data_output,data_mux_ir,data_mux_pc,PC_increment
);
wire		[15:0]		en_mux;
wire 		[31:0]		data_mux0,data_mux1,data_mux2,data_mux3,data_mux4,data_mux5,data_mux6,data_mux7,data_mux8,data_mux9,data_mux10,data_mux11,data_mux12,data_mux13; 

general_register R0( .D(D), .clr(clr), .clk(clk), .en(en_mux[0]), .Q(data_mux0));
general_register R1( .D(D), .clr(clr), .clk(clk), .en(en_mux[1]), .Q(data_mux1));
general_register R2( .D(D), .clr(clr), .clk(clk), .en(en_mux[2]), .Q(data_mux2));
general_register R3( .D(D), .clr(clr), .clk(clk), .en(en_mux[3]), .Q(data_mux3));
general_register R4( .D(D), .clr(clr), .clk(clk), .en(en_mux[4]), .Q(data_mux4));
general_register R5( .D(D), .clr(clr), .clk(clk), .en(en_mux[5]), .Q(data_mux5));
general_register R6( .D(D), .clr(clr), .clk(clk), .en(en_mux[6]), .Q(data_mux6));
general_register R7( .D(D), .clr(clr), .clk(clk), .en(en_mux[7]), .Q(data_mux7));
general_register R8( .D(D), .clr(clr), .clk(clk), .en(en_mux[8]), .Q(data_mux8));
general_register R9( .D(D), .clr(clr), .clk(clk), .en(en_mux[9]), .Q(data_mux9));
general_register R10( .D(D), .clr(clr), .clk(clk), .en(en_mux[10]), .Q(data_mux10));
general_register R11( .D(D), .clr(clr), .clk(clk), .en(en_mux[11]), .Q(data_mux11));
general_register R12( .D(D), .clr(clr), .clk(clk), .en(en_mux[12]), .Q(data_mux12));
general_register R13( .D(D), .clr(clr), .clk(clk), .en(en_mux[13]), .Q(data_mux13));
general_register R14( .D(RAM_DATA), .clr(clr), .clk(clk), .en(en_IR), .Q(data_mux_ir));			//IR
general_register R15( .D(D), .clr(clr), .clk(clk), .en(en_PC), .Q(data_mux_pc));				//PC

adder_32bit pc( .a(data_mux_pc), .b({31'b0,decode}), .cin('b0), .sum(PC_increment));

demux1_16 in ( .sel(sel_in), .in(en), .out(en_mux));

assign data_output=data_mux0;

mux16_1 a( .R_0(data_mux0), .R_1(data_mux1), .R_2(data_mux2), .R_3(data_mux3), .R_4(data_mux4), .R_5(data_mux5), .R_6(data_mux6), .R_7(data_mux7), 
			 .R_8(data_mux8), .R_9(data_mux9), .R_10(data_mux10), .R_11(data_mux11), .R_12(data_mux12), .R_13(data_mux13), 
			 .R_14({{16{data_mux_ir[15]}},data_mux_ir[15:0]}), .R_15(data_mux_pc),
			 .sel_a(sel_a), .sel_b(sel_b),
			 .data_a(data_a), .data_b(data_b));

endmodule

///////////////////////FULL ADDER////////////////////////////

module adder_32bit
(
	input		[31:0]		a,b,
	input						cin,
	output	[31:0]		sum
);
wire			[31:0]		cout;

adder a0  (.a(a[0]),  .b(b[0]),  .cin(cin),      .sum(sum[0]),  .cout(cout[0]));
adder a1  (.a(a[1]),  .b(b[1]),  .cin(cout[0]),  .sum(sum[1]),  .cout(cout[1]));
adder a2  (.a(a[2]),  .b(b[2]),  .cin(cout[1]),  .sum(sum[2]),  .cout(cout[2]));
adder a3  (.a(a[3]),  .b(b[3]),  .cin(cout[2]),  .sum(sum[3]),  .cout(cout[3]));
adder a4  (.a(a[4]),  .b(b[4]),  .cin(cout[3]),  .sum(sum[4]),  .cout(cout[4]));
adder a5  (.a(a[5]),  .b(b[5]),  .cin(cout[4]),  .sum(sum[5]),  .cout(cout[5]));
adder a6  (.a(a[6]),  .b(b[6]),  .cin(cout[5]),  .sum(sum[6]),  .cout(cout[6]));
adder a7  (.a(a[7]),  .b(b[7]),  .cin(cout[6]),  .sum(sum[7]),  .cout(cout[7]));
adder a8  (.a(a[8]),  .b(b[8]),  .cin(cout[7]),  .sum(sum[8]),  .cout(cout[8]));
adder a9  (.a(a[9]),  .b(b[9]),  .cin(cout[8]),  .sum(sum[9]),  .cout(cout[9]));
adder a10 (.a(a[10]), .b(b[10]), .cin(cout[9]),  .sum(sum[10]), .cout(cout[10]));
adder a11 (.a(a[11]), .b(b[11]), .cin(cout[10]), .sum(sum[11]), .cout(cout[11]));
adder a12 (.a(a[12]), .b(b[12]), .cin(cout[11]), .sum(sum[12]), .cout(cout[12]));
adder a13 (.a(a[13]), .b(b[13]), .cin(cout[12]), .sum(sum[13]), .cout(cout[13]));
adder a14 (.a(a[14]), .b(b[14]), .cin(cout[13]), .sum(sum[14]), .cout(cout[14]));
adder a15 (.a(a[15]), .b(b[15]), .cin(cout[14]), .sum(sum[15]), .cout(cout[15]));

adder a16 (.a(a[16]), .b(b[16]), .cin(cout[15]), .sum(sum[16]), .cout(cout[16]));
adder a17 (.a(a[17]), .b(b[17]), .cin(cout[16]), .sum(sum[17]), .cout(cout[17]));
adder a18 (.a(a[18]), .b(b[18]), .cin(cout[17]), .sum(sum[18]), .cout(cout[18]));
adder a19 (.a(a[19]), .b(b[19]), .cin(cout[18]), .sum(sum[19]), .cout(cout[19]));
adder a20 (.a(a[20]), .b(b[20]), .cin(cout[19]), .sum(sum[20]), .cout(cout[20]));
adder a21 (.a(a[21]), .b(b[21]), .cin(cout[20]), .sum(sum[21]), .cout(cout[21]));
adder a22 (.a(a[22]), .b(b[22]), .cin(cout[21]), .sum(sum[22]), .cout(cout[22]));
adder a23 (.a(a[23]), .b(b[23]), .cin(cout[22]), .sum(sum[23]), .cout(cout[23]));
adder a24 (.a(a[24]), .b(b[24]), .cin(cout[23]), .sum(sum[24]), .cout(cout[24]));
adder a25 (.a(a[25]), .b(b[25]), .cin(cout[24]), .sum(sum[25]), .cout(cout[25]));
adder a26 (.a(a[26]), .b(b[26]), .cin(cout[25]), .sum(sum[26]), .cout(cout[26]));
adder a27 (.a(a[27]), .b(b[27]), .cin(cout[26]), .sum(sum[27]), .cout(cout[27]));
adder a28 (.a(a[28]), .b(b[28]), .cin(cout[27]), .sum(sum[28]), .cout(cout[28]));
adder a29 (.a(a[29]), .b(b[29]), .cin(cout[28]), .sum(sum[29]), .cout(cout[29]));
adder a30 (.a(a[30]), .b(b[30]), .cin(cout[29]), .sum(sum[30]), .cout(cout[30]));
adder a31 (.a(a[31]), .b(b[31]), .cin(cout[30]), .sum(sum[31]), .cout(cout[31]));


endmodule



/////////////half adder//////////////////////

module adder
(
	input				a,b,cin,
	output			sum,cout
);

assign sum=(a^b)^cin;
assign cout=((a^b)&cin)|a&b;

endmodule

////////////demux////////////////////
module demux1_16
(
	input		[3:0]		sel,
	input					in,
	output	[15:0]	out
);
assign out[0]=in & ( !sel[3] & !sel[2] & !sel[1] & !sel[0]);
assign out[1]=in & ( !sel[3] & !sel[2] & !sel[1] & sel[0]);
assign out[2]=in & ( !sel[3] & !sel[2] & sel[1] & !sel[0]);
assign out[3]=in & ( !sel[3] & !sel[2] & sel[1] & sel[0]);
assign out[4]=in & ( !sel[3] & sel[2] & !sel[1] & !sel[0]);
assign out[5]=in & ( !sel[3] & sel[2] & !sel[1] & sel[0]);
assign out[6]=in & ( !sel[3] & sel[2] & sel[1] & !sel[0]);
assign out[7]=in & ( !sel[3] & sel[2] & sel[1] & sel[0]);
assign out[8]=in & ( sel[3] & !sel[2] & !sel[1] & !sel[0]);
assign out[9]=in & ( sel[3] & !sel[2] & !sel[1] & sel[0]);
assign out[10]=in & ( sel[3] & !sel[2] & sel[1] & !sel[0]);
assign out[11]=in & ( sel[3] & !sel[2] & sel[1] & sel[0]);
assign out[12]=in & ( sel[3] & sel[2] & !sel[1] & !sel[0]);
assign out[13]=in & ( sel[3] & sel[2] & !sel[1] & sel[0]);
assign out[14]=in & ( sel[3] & sel[2] & sel[1] & !sel[0]);
assign out[15]=in & ( sel[3] & sel[2] & sel[1] & sel[0]);

endmodule

//////////mux////////////////////////
module mux4_1
(
	input 	[31:0]	temp1_0,temp1_1,temp1_2,temp1_3,
	input		[1:0]		sel,
	output	[31:0]	temp2
);

assign temp2=sel[1]?(sel[0]?temp1_3:temp1_2):(sel[0]?temp1_1:temp1_0);

endmodule

module mux16_1
(
	input					[31:0]		R_0,R_1,R_2,R_3,R_4,R_5,R_6,R_7,R_8,R_9,R_10,R_11,R_12,R_13,R_14,R_15,
	input					[3:0]			sel_a,sel_b,
	output				[31:0]		data_a,data_b
);

wire	[31:0]	temp2_0a,temp2_1a,temp2_2a,temp2_3a;
wire	[31:0]	temp2_0b,temp2_1b,temp2_2b,temp2_3b;

mux4_1 a0( .temp1_0(R_0), .temp1_1(R_1), .temp1_2(R_2), .temp1_3(R_3),
		  .sel(sel_a[1:0]),
		  .temp2(temp2_0a));
		  
mux4_1 a1( .temp1_0(R_4), .temp1_1(R_5), .temp1_2(R_6), .temp1_3(R_7),
		  .sel(sel_a[1:0]),
		  .temp2(temp2_1a));
		  
mux4_1 a2( .temp1_0(R_8), .temp1_1(R_9), .temp1_2(R_10), .temp1_3(R_11),
		  .sel(sel_a[1:0]),
		  .temp2(temp2_2a));	

mux4_1 a3( .temp1_0(R_12), .temp1_1(R_13), .temp1_2(R_14), .temp1_3(R_15),
		  .sel(sel_a[1:0]),
		  .temp2(temp2_3a));
		  
mux4_1 a( .temp1_0(temp2_0a), .temp1_1(temp2_1a), .temp1_2(temp2_2a), .temp1_3(temp2_3a),
		  .sel(sel_a[3:2]),
		  .temp2(data_a));
		  
mux4_1 b0( .temp1_0(R_0), .temp1_1(R_1), .temp1_2(R_2), .temp1_3(R_3),
		  .sel(sel_b[1:0]),
		  .temp2(temp2_0b));
		  
mux4_1 b1( .temp1_0(R_4), .temp1_1(R_5), .temp1_2(R_6), .temp1_3(R_7),
		  .sel(sel_b[1:0]),
		  .temp2(temp2_1b));
		  
mux4_1 b2( .temp1_0(R_8), .temp1_1(R_9), .temp1_2(R_10), .temp1_3(R_11),
		  .sel(sel_b[1:0]),
		  .temp2(temp2_2b));	

mux4_1 b3( .temp1_0(R_12), .temp1_1(R_13), .temp1_2(R_14), .temp1_3(R_15),
		  .sel(sel_b[1:0]),
		  .temp2(temp2_3b));
		  
mux4_1 b( .temp1_0(temp2_0b), .temp1_1(temp2_1b), .temp1_2(temp2_2b), .temp1_3(temp2_3b),
		  .sel(sel_a[3:2]),
		  .temp2(data_b));

endmodule 

module mux16_1_tb
();
reg	[31:0]		R_0,R_1,R_2,R_3,R_4,R_5,R_6,R_7,R_8,R_9,R_10,R_11,R_12,R_13,R_14,R_15;
reg	[3:0]			sel_a,sel_b;
wire	[31:0]		data_a,data_b;

mux16_1 a( .R_0(R_0), .R_1(R_1), .R_2(R_2), .R_3(R_3), .R_4(R_4), .R_5(R_5), .R_6(R_6), .R_7(R_7), .R_8(R_8), .R_9(R_9), .R_10(R_10), .R_11(R_11), .R_12(R_12), .R_13(R_13), .R_14(R_14), .R_15(R_15),
			 .sel_a(sel_a), .sel_b(sel_b),
			 .data_a(data_a), .data_b(data_b));


integer i; 

initial begin
R_0='d0;
R_1='d1;
R_2='d2;
R_3='d3;
R_4='d4;
R_5='d5;
R_6='d6;
R_7='d7;
R_8='d8;
R_9='d9;
R_10='d10;
R_11='d11;
R_12='d12;
R_13='d13;
R_14='d14;
R_15='d15;




for (i=0;i<16;i=i+1) begin
#10 sel_a=i;
#10 sel_b=i;
end

$finish;
end

endmodule 
