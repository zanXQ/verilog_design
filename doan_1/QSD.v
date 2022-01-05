module QSD//_generator
(
    input   [63:0]        a,b,
    output  [95:0]       QSD_a,QSD_b
);

wire [64:0] bin_a={a[63],a[63:0]};
wire [64:0] bin_b={b[63],b[63:0]};

reg [2:0] QSD_a[0:31];
reg [2:0] QSD_b[0:31];

integer i,j,z;

always @(*) begin
    for(i=0,z=0;i<62;i=i+2,z=z+1) begin
            QSD_a[z][0]=bin_a[i];
            QSD_a[z][1]=bin_a[i+1];
            QSD_a[z][2]=1'b0;

            QSD_b[z][0]=bin_b[i];
            QSD_b[z][1]=bin_b[i+1];
            QSD_b[z][2]=1'b0;
    end
            QSD_a[31][0]=bin_a[62];
            QSD_a[31][1]=bin_a[63];
            QSD_a[31][2]=bin_a[64];

            QSD_b[31][0]=bin_b[62];
            QSD_b[31][1]=bin_b[63];
            QSD_b[31][2]=bin_b[64];
end

endmodule


module QSD_inter
(
    input   [2:0]   a,b,
    output  [2:0]   sum,
    output  [1:0]   carry
);

assign sum[0]=(~a[2] & ~a[0] & b[0]) | (a[0] & ~b[2] & ~b[0]) | (a[0] & b[1] & ~b[0]) | (a[1] & ~a[0] & b[0]);
assign sum[1]=(~a[2] & ~a[1] & ~a[0] & b[1]) | (~a[1] & a[0] & ~b[1] & b[0]) | (a[1] & ~a[0] & ~b[1] & b[0]) | (a[1] & ~b[2] & ~b[1] & ~b[0]) | (a[1] & a[0] & b[1] & b[0]) | (~a[1] & a[0] & b[1] & ~b[0]);
assign sum[2]=(~a[2] & ~a[1] & ~a[0] & b[1] & b[0]) | (~a[1] & a[0] & b[1] & ~b[0]) | (~a[1] & a[0] & b[2] & ~b[1] & b[0]) | (a[1] & ~a[0] & ~b[1] & b[0]) | (a[1] & a[0] & ~b[2] & ~b[1] & ~b[0]) | (a[2] & ~a[1] & a[0] & ~b[1] & b[0]) | (a[2] & a[1] & a[0] & b[2] & b[1] & b[0]) | (~a[2] & ~a[1] & ~a[0] & b[2] & b[1]) | (a[2] & a[1] & ~a[0] & ~b[2] & ~b[1]);



endmodule

module QSD_inter_tb
();
reg [2:0] a,b;
wire[2:0] sum;
wire[1:0] carry;

QSD z( .a(a), .b(b),
		 .sum(sum),
		 .carry(carry));

initial begin
#20;
a= 3'b000;
b= 3'b100;
#20;
a=3'b001;
#20;
a=3'b011;
#20;
a=3'b010;
#20;
a=3'b110;
#20;
a=3'b111;
#20;
a=3'b101;


end

endmodule
