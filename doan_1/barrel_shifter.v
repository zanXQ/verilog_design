module barrel_shifter
  (
    input   [63:0]      input_bit,
    input   [5:0]       shift_bit,
    input               lo_left,lo_right,art_right,art_left,rot_right,rot_left,
    output  [63:0]      output_bit
  );
  wire rot=rot_right|rot_left;
  wire left=lo_left|art_left|rot_left;
  reg [63:0] state_0,state_1,state_2,state_3,state_4,state_5,in,out;
  
  

  integer i;
  always @(*) begin
  
	for(i=0;i<64;i=i+1) begin
	in[i]=left?input_bit[63-i]:input_bit[i];
	end
  
	for(i=0;i<63;i=i+1) begin //state 0
	state_0[i]=shift_bit[0]?in[i+1]:in[i];
	end
	for(i=0;i<1;i=i+1) begin
	state_0[63-i]=shift_bit[0]?((in[0-i]&rot)|(art_right&input_bit[63])):in[63-i];
	end
	
	for(i=0;i < 62;i=i+1)begin //state 1
	state_1[i]=shift_bit[1]?state_0[i+2]:state_0[i];
	end
	for(i=0;i<2;i=i+1) begin
	state_1[63-i]=shift_bit[1]?((state_0[1-i]&rot)|(art_right&input_bit[63])):state_0[63-i];
	end
	
	for(i=0;i<60;i=i+1) begin //state 2
	state_2[i]=shift_bit[2]?state_1[i+4]:state_1[i];
	end
	for(i=0;i<4;i=i+1) begin
	state_2[63-i]=shift_bit[2]?((state_1[3-i]&rot)|(art_right&input_bit[63])):state_1[63-i];
	end
	
	for(i=0;i<56;i=i+1) begin //state 3
	state_3[i]=shift_bit[3]?state_2[i+8]:state_2[i];
	end
	for(i=0;i<8;i=i+1) begin
	state_3[63-i]=shift_bit[3]?((state_2[7-i]&rot)|(art_right&input_bit[63])):state_2[63-i];
	end
	
	for(i=0;i<48;i=i+1) begin //state 4
	state_4[i]=shift_bit[4]?state_3[i+16]:state_3[i];
	end
	for(i=0;i<16;i=i+1) begin
	state_4[63-i]=shift_bit[4]?((state_3[15-i]&rot)|(art_right&input_bit[63])):state_3[63-i];
	end
	
	for(i=0;i<32;i=i+1) begin //state 5
	state_5[i]=shift_bit[5]?state_4[i+32]:state_4[i];
	end
	for(i=0;i<32;i=i+1) begin
	state_5[63-i]=shift_bit[5]?((state_4[31-i]&rot)|(art_right&input_bit[63])):state_4[63-i];
	end
	
	for(i=0;i<64;i=i+1) begin
	out[i]=left?state_5[63-i]:state_5[i];
	end
  end
  
 assign output_bit=out;
endmodule


module barrel_shiftertb
  (
  );
  reg [63:0]	a;
  reg [5:0]		b;
  wire [63:0]	c;
  reg 			e,f,g,h,l,k;
  barrel_shifter he(.input_bit(a), .shift_bit(b),
                    .lo_left(e), .lo_right(f), .art_right(g), .art_left(h), .rot_right(l), .rot_left(k),
                    .output_bit(c));

initial begin
$dumpfile("barrel_shifter_tb.vcd");
$dumpvars(0,barrel_shiftertb);
a=64'h8000000000000071;
b=6'b010000;
e='b0;
f='b0;
g='b0;
h='b1;
l='b0;
k='b0;
end

endmodule


