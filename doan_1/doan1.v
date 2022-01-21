


module doan1(

	//////////// CLOCK //////////
	input 		          		CLOCK2_50,
	input 		          		CLOCK3_50,
	input 		          		CLOCK4_50,
	input 		          		CLOCK_50,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// Seg7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,
	input										sign1,sign2,
	input										difference,direction,
	input					[7:0]				exponent,
	input					[22:0]			mantissa,
	input										carry_out1,carry_out2,
	output	reg		[7:0]				exponent_s,
	output	reg		[22:0]			mantissa_s
);

reg			[7:0]				exponent_increase;
wire			[7:0]				exponent_decrease;
wire			[7:0]				exponent_temp1,exponent_temp2;
wire			[1:0]				sign_temp={sign1,sign2};
wire 			[7:0]				cout1,cout2;


zle x( .mantissa(mantissa), .leading_zero(exponent_decrease));


always @ (*) begin
case (sign_temp)
	'b00,'b11:begin
				if(difference==0) begin
					if(carry_out1==1) begin
					mantissa_s=(mantissa>>1)|23'b1000000000000000000000;
					exponent_increase=8'b01;
					exponent_s=exponent_temp1;
					end
					else begin
					mantissa_s=mantissa>>1;
					exponent_increase=8'b01;
					exponent_s=exponent_temp1;
					end
				end
				else begin
					if(carry_out1==1) begin
					mantissa_s=mantissa>>1;
					exponent_increase=8'b01;
					exponent_s=exponent_temp1;
					end
					else begin
					mantissa_s=mantissa;
					exponent_s=exponent;
					end
				end
				end
	'b10,'b01:begin
				if(difference==0 || direction==0&&carry_out2==1 || direction==1&&carry_out2==0)begin
				mantissa_s=mantissa<<exponent_decrease;
				exponent_s=exponent_temp2;
				end
				else
				mantissa_s=mantissa;
				exponent_s=exponent;
				end
endcase
end

adder a0 (.a(exponent[0]), .b(exponent_increase[0]), .cin('b1), .sum(exponent_temp2[0]), .cout(cout1[0]));
adder a1 (.a(exponent[1]), .b(exponent_increase[1]), .cin(cout1[0]), .sum(exponent_temp2[1]), .cout(cout1[1]));
adder a2 (.a(exponent[2]), .b(exponent_increase[2]), .cin(cout1[1]), .sum(exponent_temp2[2]), .cout(cout1[2]));
adder a3 (.a(exponent[3]), .b(exponent_increase[3]), .cin(cout1[2]), .sum(exponent_temp2[3]), .cout(cout1[3]));
adder a4 (.a(exponent[4]), .b(exponent_increase[4]), .cin(cout1[3]), .sum(exponent_temp2[4]), .cout(cout1[4]));
adder a5 (.a(exponent[5]), .b(exponent_increase[5]), .cin(cout1[4]), .sum(exponent_temp2[5]), .cout(cout1[5]));
adder a6 (.a(exponent[6]), .b(exponent_increase[6]), .cin(cout1[5]), .sum(exponent_temp2[6]), .cout(cout1[6]));
adder a7 (.a(exponent[7]), .b(exponent_increase[7]), .cin(cout1[6]), .sum(exponent_temp2[7]), .cout(cout1[7]));

subtractor b0 (.a(exponent[0]), .b(exponent_decrease[0]), .cin('b1), .s(exponent_temp2[0]), .cout(cout2[0]));
subtractor b1 (.a(exponent[1]), .b(exponent_decrease[1]), .cin(cout2[0]), .s(exponent_temp2[1]), .cout(cout2[1]));
subtractor b2 (.a(exponent[2]), .b(exponent_decrease[2]), .cin(cout2[1]), .s(exponent_temp2[2]), .cout(cout2[2]));
subtractor b3 (.a(exponent[3]), .b(exponent_decrease[3]), .cin(cout2[2]), .s(exponent_temp2[3]), .cout(cout2[3]));
subtractor b4 (.a(exponent[4]), .b(exponent_decrease[4]), .cin(cout2[3]), .s(exponent_temp2[4]), .cout(cout2[4]));
subtractor b5 (.a(exponent[5]), .b(exponent_decrease[5]), .cin(cout2[4]), .s(exponent_temp2[5]), .cout(cout2[5]));
subtractor b6 (.a(exponent[6]), .b(exponent_decrease[6]), .cin(cout2[5]), .s(exponent_temp2[6]), .cout(cout2[6]));
subtractor b7 (.a(exponent[7]), .b(exponent_decrease[7]), .cin(cout2[6]), .s(exponent_temp2[7]), .cout(cout2[7]));


endmodule 


module disect
(
	input			[31:0]			input_float,
	output							sign,
	output		[7:0]				exponent,
	output		[22:0]			mantissa
);

assign 	sign			=	input_float[31];
assign 	exponent		=	input_float[30:23];
assign	mantissa		=	input_float[22:0];

endmodule 



module evaluate_number
(
	input									clk,
	input				[7:0]				exponent,
	output	reg	[1:0]				operation		
);
always @ (posedge clk) begin
	if(exponent=='b00000000) 
	operation='b00;//value zero
	else if(exponent=='b01111111)
	operation='b01;//value one
	else if(exponent=='b11111111)
	operation='b10;//infinity,NaN
	else operation='b11;
end
endmodule 

module compare_exponent
(
	input										clk,
	input 				[7:0]				exponent1,exponent2,
	output	reg		[7:0]				difference,
	output									direction
);

wire 						[7:0]				cout1,cout2,temp;
wire						[7:0]				change1,change2;

subtractor u0 ( .a(exponent1[0]), .b(exponent2[0]), .cin('b0), .s(change1[0]), .cout(cout1[0]));
subtractor u1 ( .a(exponent1[1]), .b(exponent2[1]), .cin(cout1[0]), .s(change1[1]), .cout(cout1[1]));
subtractor u2 ( .a(exponent1[2]), .b(exponent2[2]), .cin(cout1[1]), .s(change1[2]), .cout(cout1[2]));
subtractor u3 ( .a(exponent1[3]), .b(exponent2[3]), .cin(cout1[2]), .s(change1[3]), .cout(cout1[3]));
subtractor u4 ( .a(exponent1[4]), .b(exponent2[4]), .cin(cout1[3]), .s(change1[4]), .cout(cout1[4]));
subtractor u5 ( .a(exponent1[5]), .b(exponent2[5]), .cin(cout1[4]), .s(change1[5]), .cout(cout1[5]));
subtractor u6 ( .a(exponent1[6]), .b(exponent2[6]), .cin(cout1[5]), .s(change1[6]), .cout(cout1[6]));
subtractor u7 ( .a(exponent1[7]), .b(exponent2[7]), .cin(cout1[6]), .s(change1[7]), .cout(cout1[7]));

assign direction=cout1[7];

assign temp=~change1;

adder y0 ( .a(temp[0]), .b('b0), .cin(sign), .sum(change2[0]), .cout(cout2[0]));
adder y1 ( .a(temp[1]), .b('b0), .cin(cout2[0]), .sum(change2[1]), .cout(cout2[1]));
adder y2 ( .a(temp[2]), .b('b0), .cin(cout2[1]), .sum(change2[2]), .cout(cout2[2]));
adder y3 ( .a(temp[3]), .b('b0), .cin(cout2[2]), .sum(change2[3]), .cout(cout2[3]));
adder y4 ( .a(temp[4]), .b('b0), .cin(cout2[3]), .sum(change2[4]), .cout(cout2[4]));
adder y5 ( .a(temp[5]), .b('b0), .cin(cout2[4]), .sum(change2[5]), .cout(cout2[5]));
adder y6 ( .a(temp[6]), .b('b0), .cin(cout2[5]), .sum(change2[6]), .cout(cout2[6]));
adder y7 ( .a(temp[7]), .b('b0), .cin(cout2[6]), .sum(change2[7]), .cout(cout2[7]));



always @ (*) begin
case(direction)
	'b1:	difference=change2;
	'b0:	difference=change1;
endcase
end
endmodule

module subtractor
(
	input				a,b,cin,
	output			s,cout
);

assign s=(a^b)^cin;
assign cout=((!(a^b))&cin)|((!a)&b);

endmodule 


module adder
(
	input				a,b,cin,
	output			sum,cout
);

assign sum=(a^b)^cin;
assign cout=((a^b)&cin)|a&b;

endmodule

module align_mantissa_sign
(
	input				[7:0]			difference,
	input								direction,sign1,sign2,
	input				[7:0]			exponent1,exponent2,
	input				[22:0]		mantissa1,mantissa2,
	output	reg	[7:0]			exponent1_s,exponent2_s,
	output	reg	[22:0]		mantissa1_s,mantissa2_s,
	output	reg					sign_s
);
wire 					[7:0]				cout1,cout2;
wire					[22:0]			man_s;
reg					[22:0]			man_temp;
wire					[7:0]				diff_temp;

subtractor u0 ( .a(difference[0]), .b('b0), .cin('b1), .s(diff_temp[0]), .cout(cout1[0]));
subtractor u1 ( .a(difference[1]), .b('b0), .cin(cout1[0]), .s(diff_temp[1]), .cout(cout1[1]));
subtractor u2 ( .a(difference[2]), .b('b0), .cin(cout1[1]), .s(diff_temp[2]), .cout(cout1[2]));
subtractor u3 ( .a(difference[3]), .b('b0), .cin(cout1[2]), .s(diff_temp[3]), .cout(cout1[3]));
subtractor u4 ( .a(difference[4]), .b('b0), .cin(cout1[3]), .s(diff_temp[4]), .cout(cout1[4]));
subtractor u5 ( .a(difference[5]), .b('b0), .cin(cout1[4]), .s(diff_temp[5]), .cout(cout1[5]));
subtractor u6 ( .a(difference[6]), .b('b0), .cin(cout1[5]), .s(diff_temp[6]), .cout(cout1[6]));
subtractor u7 ( .a(difference[7]), .b('b0), .cin(cout1[6]), .s(diff_temp[7]), .cout(cout1[7]));

subtractor a0 (.a(mantissa1[0]), .b(mantissa2[0]), .cin('b0), .s(man_s[0]), .cout(cout2[0]));
subtractor a1 (.a(mantissa1[1]), .b(mantissa2[1]), .cin(cout2[0]), .s(man_s[1]), .cout(cout2[1]));
subtractor a2 (.a(mantissa1[2]), .b(mantissa2[2]), .cin(cout2[1]), .s(man_s[2]), .cout(cout2[2]));
subtractor a3 (.a(mantissa1[3]), .b(mantissa2[3]), .cin(cout2[2]), .s(man_s[3]), .cout(cout2[3]));
subtractor a4 (.a(mantissa1[4]), .b(mantissa2[4]), .cin(cout2[3]), .s(man_s[4]), .cout(cout2[4]));
subtractor a5 (.a(mantissa1[5]), .b(mantissa2[5]), .cin(cout2[4]), .s(man_s[5]), .cout(cout2[5]));
subtractor a6 (.a(mantissa1[6]), .b(mantissa2[6]), .cin(cout2[5]), .s(man_s[6]), .cout(cout2[6]));
subtractor a7 (.a(mantissa1[7]), .b(mantissa2[7]), .cin(cout2[6]), .s(man_s[7]), .cout(cout2[7]));
subtractor a8 (.a(mantissa1[8]), .b(mantissa2[8]), .cin(cout2[7]), .s(man_s[8]), .cout(cout2[8]));
subtractor a9 (.a(mantissa1[9]), .b(mantissa2[9]), .cin(cout2[8]), .s(man_s[9]), .cout(cout2[9]));
subtractor a10 (.a(mantissa1[10]), .b(mantissa2[10]), .cin(cout2[9]), .s(man_s[10]), .cout(cout2[10]));
subtractor a11 (.a(mantissa1[11]), .b(mantissa2[11]), .cin(cout2[10]), .s(man_s[11]), .cout(cout2[11]));
subtractor a12 (.a(mantissa1[12]), .b(mantissa2[12]), .cin(cout2[11]), .s(man_s[12]), .cout(cout2[12]));
subtractor a13 (.a(mantissa1[13]), .b(mantissa2[13]), .cin(cout2[12]), .s(man_s[13]), .cout(cout2[13]));
subtractor a14 (.a(mantissa1[14]), .b(mantissa2[14]), .cin(cout2[13]), .s(man_s[14]), .cout(cout2[14]));
subtractor a15 (.a(mantissa1[15]), .b(mantissa2[15]), .cin(cout2[14]), .s(man_s[15]), .cout(cout2[15]));
subtractor a16 (.a(mantissa1[16]), .b(mantissa2[16]), .cin(cout2[15]), .s(man_s[16]), .cout(cout2[16]));
subtractor a17 (.a(mantissa1[17]), .b(mantissa2[17]), .cin(cout2[16]), .s(man_s[17]), .cout(cout2[17]));
subtractor a18 (.a(mantissa1[18]), .b(mantissa2[18]), .cin(cout2[17]), .s(man_s[18]), .cout(cout2[18]));
subtractor a19 (.a(mantissa1[19]), .b(mantissa2[19]), .cin(cout2[18]), .s(man_s[19]), .cout(cout2[19]));
subtractor a20 (.a(mantissa1[20]), .b(mantissa2[20]), .cin(cout2[19]), .s(man_s[20]), .cout(cout2[20]));
subtractor a21 (.a(mantissa1[21]), .b(mantissa2[21]), .cin(cout2[20]), .s(man_s[21]), .cout(cout2[21]));
subtractor a22 (.a(mantissa1[22]), .b(mantissa2[22]), .cin(cout2[21]), .s(man_s[22]), .cout(cout2[22]));

always @(*) begin
if(difference==0)begin
mantissa2_s=mantissa2;
mantissa1_s=mantissa1;
exponent1_s=exponent1;
exponent2_s=exponent2;
if(cout2[22]==0) sign_s=sign1;
else sign_s=sign1;
end
else begin
if (direction == 0) begin 
man_temp=(mantissa1>>'b1)|23'b1000000000000000000000;
mantissa2_s=man_temp >> diff_temp;
mantissa1_s=mantissa1;
exponent1_s=exponent1;
exponent2_s=exponent1;
sign_s=sign1;
end
if(direction == 1) begin
man_temp=(mantissa2>>2'b01)|23'b1000000000000000000000;
mantissa1_s=man_temp >> diff_temp;
mantissa2_s=mantissa2;
exponent1_s=exponent2;
exponent2_s=exponent2;
sign_s=sign2;
end
end
end 
endmodule

module addition
(
	input 							sign1,sign2,sign_s,
	input				  [22:0]		mantissa1,mantissa2,
	output	reg	  [22:0]		mantissa_s,
	output							carry_out
);
wire [22:0]		cout1,cout2,cout3,man1_s,man2_s,man2_inv;
reg [22:0]		man1_temp,man2_temp,man3_temp;
wire [1:0]		sign_temp={sign1,sign2};

assign carry_out=cout2[22];

always @ (*) begin
case(sign_temp)
	'b00,'b11:begin
			man1_temp=mantissa1;
			man2_temp=mantissa2;
			man3_temp=23'b0;
			end
	'b01,'b10:begin
					man1_temp=mantissa1;
					man2_temp=23'b0;
					man3_temp=mantissa2;
					end
	
endcase
end
adder a0 (.a(man1_temp[0]), .b(man2_temp[0]), .cin('b0), .sum(man1_s[0]), .cout(cout1[0]));
adder a1 (.a(man1_temp[1]), .b(man2_temp[1]), .cin(cout1[0]), .sum(man1_s[1]), .cout(cout1[1]));
adder a2 (.a(man1_temp[2]), .b(man2_temp[2]), .cin(cout1[1]), .sum(man1_s[2]), .cout(cout1[2]));
adder a3 (.a(man1_temp[3]), .b(man2_temp[3]), .cin(cout1[2]), .sum(man1_s[3]), .cout(cout1[3]));
adder a4 (.a(man1_temp[4]), .b(man2_temp[4]), .cin(cout1[3]), .sum(man1_s[4]), .cout(cout1[4]));
adder a5 (.a(man1_temp[5]), .b(man2_temp[5]), .cin(cout1[4]), .sum(man1_s[5]), .cout(cout1[5]));
adder a6 (.a(man1_temp[6]), .b(man2_temp[6]), .cin(cout1[5]), .sum(man1_s[6]), .cout(cout1[6]));
adder a7 (.a(man1_temp[7]), .b(man2_temp[7]), .cin(cout1[6]), .sum(man1_s[7]), .cout(cout1[7]));
adder a8 (.a(man1_temp[8]), .b(man2_temp[8]), .cin(cout1[7]), .sum(man1_s[8]), .cout(cout1[8]));
adder a9 (.a(man1_temp[9]), .b(man2_temp[9]), .cin(cout1[8]), .sum(man1_s[9]), .cout(cout1[9]));
adder a10 (.a(man1_temp[10]), .b(man2_temp[10]), .cin(cout1[9]), .sum(man1_s[10]), .cout(cout1[10]));
adder a11 (.a(man1_temp[11]), .b(man2_temp[11]), .cin(cout1[10]), .sum(man1_s[11]), .cout(cout1[11]));
adder a12 (.a(man1_temp[12]), .b(man2_temp[12]), .cin(cout1[11]), .sum(man1_s[12]), .cout(cout1[12]));
adder a13 (.a(man1_temp[13]), .b(man2_temp[13]), .cin(cout1[12]), .sum(man1_s[13]), .cout(cout1[13]));
adder a14 (.a(man1_temp[14]), .b(man2_temp[14]), .cin(cout1[13]), .sum(man1_s[14]), .cout(cout1[14]));
adder a15 (.a(man1_temp[15]), .b(man2_temp[15]), .cin(cout1[14]), .sum(man1_s[15]), .cout(cout1[15]));
adder a16 (.a(man1_temp[16]), .b(man2_temp[16]), .cin(cout1[15]), .sum(man1_s[16]), .cout(cout1[16]));
adder a17 (.a(man1_temp[17]), .b(man2_temp[17]), .cin(cout1[16]), .sum(man1_s[17]), .cout(cout1[17]));
adder a18 (.a(man1_temp[18]), .b(man2_temp[18]), .cin(cout1[17]), .sum(man1_s[18]), .cout(cout1[18]));
adder a19 (.a(man1_temp[19]), .b(man2_temp[19]), .cin(cout1[18]), .sum(man1_s[19]), .cout(cout1[19]));
adder a20 (.a(man1_temp[20]), .b(man2_temp[20]), .cin(cout1[19]), .sum(man1_s[20]), .cout(cout1[20]));
adder a21 (.a(man1_temp[21]), .b(man2_temp[21]), .cin(cout1[20]), .sum(man1_s[21]), .cout(cout1[21]));
adder a22 (.a(man1_temp[22]), .b(man2_temp[22]), .cin(cout1[21]), .sum(man1_s[22]), .cout(cout1[22]));


subtractor b0 (.a(man1_s[0]), .b(man3_temp[0]), .cin('b0), .s(man2_s[0]), .cout(cout2[0]));
subtractor b1 (.a(man1_s[1]), .b(man3_temp[1]), .cin(cout2[0]), .s(man2_s[1]), .cout(cout2[1]));
subtractor b2 (.a(man1_s[2]), .b(man3_temp[2]), .cin(cout2[1]), .s(man2_s[2]), .cout(cout2[2]));
subtractor b3 (.a(man1_s[3]), .b(man3_temp[3]), .cin(cout2[2]), .s(man2_s[3]), .cout(cout2[3]));
subtractor b4 (.a(man1_s[4]), .b(man3_temp[4]), .cin(cout2[3]), .s(man2_s[4]), .cout(cout2[4]));
subtractor b5 (.a(man1_s[5]), .b(man3_temp[5]), .cin(cout2[4]), .s(man2_s[5]), .cout(cout2[5]));
subtractor b6 (.a(man1_s[6]), .b(man3_temp[6]), .cin(cout2[5]), .s(man2_s[6]), .cout(cout2[6]));
subtractor b7 (.a(man1_s[7]), .b(man3_temp[7]), .cin(cout2[6]), .s(man2_s[7]), .cout(cout2[7]));
subtractor b8 (.a(man1_s[8]), .b(man3_temp[8]), .cin(cout2[7]), .s(man2_s[8]), .cout(cout2[8]));
subtractor b9 (.a(man1_s[9]), .b(man3_temp[9]), .cin(cout2[8]), .s(man2_s[9]), .cout(cout2[9]));
subtractor b10 (.a(man1_s[10]), .b(man3_temp[10]), .cin(cout2[9]), .s(man2_s[10]), .cout(cout2[10]));
subtractor b11 (.a(man1_s[11]), .b(man3_temp[11]), .cin(cout2[10]), .s(man2_s[11]), .cout(cout2[11]));
subtractor b12 (.a(man1_s[12]), .b(man3_temp[12]), .cin(cout2[11]), .s(man2_s[12]), .cout(cout2[12]));
subtractor b13 (.a(man1_s[13]), .b(man3_temp[13]), .cin(cout2[12]), .s(man2_s[13]), .cout(cout2[13]));
subtractor b14 (.a(man1_s[14]), .b(man3_temp[14]), .cin(cout2[13]), .s(man2_s[14]), .cout(cout2[14]));
subtractor b15 (.a(man1_s[15]), .b(man3_temp[15]), .cin(cout2[14]), .s(man2_s[15]), .cout(cout2[15]));
subtractor b16 (.a(man1_s[16]), .b(man3_temp[16]), .cin(cout2[15]), .s(man2_s[16]), .cout(cout2[16]));
subtractor b17 (.a(man1_s[17]), .b(man3_temp[17]), .cin(cout2[16]), .s(man2_s[17]), .cout(cout2[17]));
subtractor b18 (.a(man1_s[18]), .b(man3_temp[18]), .cin(cout2[17]), .s(man2_s[18]), .cout(cout2[18]));
subtractor b19 (.a(man1_s[19]), .b(man3_temp[19]), .cin(cout2[18]), .s(man2_s[19]), .cout(cout2[19]));
subtractor b20 (.a(man1_s[20]), .b(man3_temp[20]), .cin(cout2[19]), .s(man2_s[20]), .cout(cout2[20]));
subtractor b21 (.a(man1_s[21]), .b(man3_temp[21]), .cin(cout2[20]), .s(man2_s[21]), .cout(cout2[21]));
subtractor b22 (.a(man1_s[22]), .b(man3_temp[22]), .cin(cout2[21]), .s(man2_s[22]), .cout(cout2[22]));



subtractor u0 (.a('b0), .b(man2_s[0]), .cin('b0), .s(man2_inv[0]), .cout(cout3[0]));
subtractor u1 (.a('b0), .b(man2_s[1]), .cin(cout3[0]), .s(man2_inv[1]), .cout(cout3[1]));
subtractor u2 (.a('b0), .b(man2_s[2]), .cin(cout3[1]), .s(man2_inv[2]), .cout(cout3[2]));
subtractor u3 (.a('b0), .b(man2_s[3]), .cin(cout3[2]), .s(man2_inv[3]), .cout(cout3[3]));
subtractor u4 (.a('b0), .b(man2_s[4]), .cin(cout3[3]), .s(man2_inv[4]), .cout(cout3[4]));
subtractor u5 (.a('b0), .b(man2_s[5]), .cin(cout3[4]), .s(man2_inv[5]), .cout(cout3[5]));
subtractor u6 (.a('b0), .b(man2_s[6]), .cin(cout3[5]), .s(man2_inv[6]), .cout(cout3[6]));
subtractor u7 (.a('b0), .b(man2_s[7]), .cin(cout3[6]), .s(man2_inv[7]), .cout(cout3[7]));
subtractor u8 (.a('b0), .b(man2_s[8]), .cin(cout3[7]), .s(man2_inv[8]), .cout(cout3[8]));
subtractor u9 (.a('b0), .b(man2_s[9]), .cin(cout3[8]), .s(man2_inv[9]), .cout(cout3[9]));
subtractor u10 (.a('b0), .b(man2_s[10]), .cin(cout3[9]), .s(man2_inv[10]), .cout(cout3[10]));
subtractor u11 (.a('b0), .b(man2_s[11]), .cin(cout3[10]), .s(man2_inv[11]), .cout(cout3[11]));
subtractor u12 (.a('b0), .b(man2_s[12]), .cin(cout3[11]), .s(man2_inv[12]), .cout(cout3[12]));
subtractor u13 (.a('b0), .b(man2_s[13]), .cin(cout3[12]), .s(man2_inv[13]), .cout(cout3[13]));
subtractor u14 (.a('b0), .b(man2_s[14]), .cin(cout3[13]), .s(man2_inv[14]), .cout(cout3[14]));
subtractor u15 (.a('b0), .b(man2_s[15]), .cin(cout3[14]), .s(man2_inv[15]), .cout(cout3[15]));
subtractor u16 (.a('b0), .b(man2_s[16]), .cin(cout3[15]), .s(man2_inv[16]), .cout(cout3[16]));
subtractor u17 (.a('b0), .b(man2_s[17]), .cin(cout3[16]), .s(man2_inv[17]), .cout(cout3[17]));
subtractor u18 (.a('b0), .b(man2_s[18]), .cin(cout3[17]), .s(man2_inv[18]), .cout(cout3[18]));
subtractor u19 (.a('b0), .b(man2_s[19]), .cin(cout3[18]), .s(man2_inv[19]), .cout(cout3[19]));
subtractor u20 (.a('b0), .b(man2_s[20]), .cin(cout3[19]), .s(man2_inv[20]), .cout(cout3[20]));
subtractor u21 (.a('b0), .b(man2_s[21]), .cin(cout3[20]), .s(man2_inv[21]), .cout(cout3[21]));
subtractor u22 (.a('b0), .b(man2_s[22]), .cin(cout3[21]), .s(man2_inv[22]), .cout(cout3[22]));

always @ (*) begin
if(cout2==1)mantissa_s=man2_inv;
else mantissa_s=man2_s;
end
endmodule


module normalize
(
	input										sign1,sign2,
	input										difference,direction,
	input					[7:0]				exponent,
	input					[22:0]			mantissa,
	input										carry_out1,carry_out2,
	output	reg		[7:0]				exponent_s,
	output	reg		[22:0]			mantissa_s
);

reg			[7:0]				exponent_increase;
wire			[7:0]				exponent_decrease;
wire			[7:0]				exponent_temp1,exponent_temp2;
wire			[1:0]				sign_temp={sign1,sign2};
wire 			[7:0]				cout1,cout2;


zle x( .mantissa(mantissa), .leading_zero(exponent_decrease));


always @ (*) begin
case (sign_temp)
	'b00,'b11:begin
				if(difference==0) begin
					if(carry_out1==1) begin
					mantissa_s=(mantissa>>1)|23'b1000000000000000000000;
					exponent_increase=8'b01;
					exponent_s=exponent_temp1;
					end
					else begin
					mantissa_s=mantissa>>1;
					exponent_increase=8'b01;
					exponent_s=exponent_temp1;
					end
				end
				else begin
					if(carry_out1==1) begin
					mantissa_s=mantissa>>1;
					exponent_increase=8'b01;
					exponent_s=exponent_temp1;
					end
					else begin
					mantissa_s=mantissa;
					exponent_s=exponent;
					end
				end
				end
	'b10,'b01:begin
				if(difference==0 || direction==0&&carry_out2==1 || direction==1&&carry_out2==0)begin
				mantissa_s=mantissa<<exponent_decrease;
				exponent_s=exponent_temp2;
				end
				else
				mantissa_s=mantissa;
				exponent_s=exponent;
				end
endcase
end

adder a0 (.a(exponent[0]), .b(exponent_increase[0]), .cin('b1), .sum(exponent_temp2[0]), .cout(cout1[0]));
adder a1 (.a(exponent[1]), .b(exponent_increase[1]), .cin(cout1[0]), .sum(exponent_temp2[1]), .cout(cout1[1]));
adder a2 (.a(exponent[2]), .b(exponent_increase[2]), .cin(cout1[1]), .sum(exponent_temp2[2]), .cout(cout1[2]));
adder a3 (.a(exponent[3]), .b(exponent_increase[3]), .cin(cout1[2]), .sum(exponent_temp2[3]), .cout(cout1[3]));
adder a4 (.a(exponent[4]), .b(exponent_increase[4]), .cin(cout1[3]), .sum(exponent_temp2[4]), .cout(cout1[4]));
adder a5 (.a(exponent[5]), .b(exponent_increase[5]), .cin(cout1[4]), .sum(exponent_temp2[5]), .cout(cout1[5]));
adder a6 (.a(exponent[6]), .b(exponent_increase[6]), .cin(cout1[5]), .sum(exponent_temp2[6]), .cout(cout1[6]));
adder a7 (.a(exponent[7]), .b(exponent_increase[7]), .cin(cout1[6]), .sum(exponent_temp2[7]), .cout(cout1[7]));

subtractor b0 (.a(exponent[0]), .b(exponent_decrease[0]), .cin('b1), .s(exponent_temp2[0]), .cout(cout2[0]));
subtractor b1 (.a(exponent[1]), .b(exponent_decrease[1]), .cin(cout2[0]), .s(exponent_temp2[1]), .cout(cout2[1]));
subtractor b2 (.a(exponent[2]), .b(exponent_decrease[2]), .cin(cout2[1]), .s(exponent_temp2[2]), .cout(cout2[2]));
subtractor b3 (.a(exponent[3]), .b(exponent_decrease[3]), .cin(cout2[2]), .s(exponent_temp2[3]), .cout(cout2[3]));
subtractor b4 (.a(exponent[4]), .b(exponent_decrease[4]), .cin(cout2[3]), .s(exponent_temp2[4]), .cout(cout2[4]));
subtractor b5 (.a(exponent[5]), .b(exponent_decrease[5]), .cin(cout2[4]), .s(exponent_temp2[5]), .cout(cout2[5]));
subtractor b6 (.a(exponent[6]), .b(exponent_decrease[6]), .cin(cout2[5]), .s(exponent_temp2[6]), .cout(cout2[6]));
subtractor b7 (.a(exponent[7]), .b(exponent_decrease[7]), .cin(cout2[6]), .s(exponent_temp2[7]), .cout(cout2[7]));


endmodule 

module zle
(
	input			[22:0]			mantissa,
	output		[7:0]				leading_zero
);

wire 				a0,a1,a2,a3,a4,a5;
wire				z0,z1,z2,z3,z4,z5;
wire				q3,q2,q1;
reg	[1:0]		q0;
wire	[2:0]		temp ={q3,q2,q1};

zlc b0( .x0('b0), .x1(mantissa[22]), .x2(mantissa[21]), .x3(mantissa[20]), .a(a0), .z(z0));
zlc b1( .x0(mantissa[19]), .x1(mantissa[18]), .x2(mantissa[17]), .x3(mantissa[16]), .a(a1), .z(z1));
zlc b2( .x0(mantissa[15]), .x1(mantissa[14]), .x2(mantissa[13]), .x3(mantissa[12]), .a(a2), .z(z2));
zlc b3( .x0(mantissa[11]), .x1(mantissa[10]), .x2(mantissa[9]), .x3(mantissa[8]), .a(a3), .z(z3));
zlc b4( .x0(mantissa[7]), .x1(mantissa[6]), .x2(mantissa[5]), .x3(mantissa[4]), .a(a4), .z(z4));
zlc b5( .x0(mantissa[3]), .x1(mantissa[2]), .x2(mantissa[1]), .x3(mantissa[0]), .a(a5), .z(z5));

assign q3 = (a0 & a1 & a2 & a3 & ~a4) | (a0 & a1 & a2 & a3 & a5);
assign q2 = (a0 & a1 & ~a2) | (a0 & a1 & ~a3);
assign q1 = (a0 & ~a1) | (a0 & a2 & ~a3) | (a0 & a2 & a4 & a5);

always @ (*) begin
	case(temp)
		'b000: q0=z0;
		'b001: q0=z1;
		'b010: q0=z2;
		'b011: q0=z3;
		'b100: q0=z4;
		'b101: q0=z5;
	endcase
end

assign leading_zero={3'b000,q3,q2,q1,q0};

endmodule
module zlc
(
	input						x0,x1,x2,x3,
	output					a,
	output		[1:0]		z
);

wire 			q1,q2;

assign q0=((!x3) & x2) | ((!x3)&(!x1));
assign q1=!(x3|x2);
assign a=!(x0|x1|x2|x3);

assign z={q1,q0};



endmodule 
