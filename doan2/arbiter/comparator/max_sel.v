module max_sel
(
    input       [1:0]       in1,in2,
    output      [1:0]       out,
    output                  sel
);

assign sel= (in1[1]&!in2[1])|(in1[0]&!in2[1]&!in2[0])|(in1[1]&in1[0]&!in2[0]);
assign out= sel?in1:in2;

endmodule
