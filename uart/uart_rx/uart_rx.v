module uart_tx
(
    input             clk,reset,
    input             data_tx,
    output  [7:0]     data_out,
    output            we
);
parameter clk_rx=50000;
parameter Baudrate=10000;

parameter halfBaud=(clk_tx)/(Baudrate*2);

reg     [7:0]      count;
reg                temp;

reg                idle;
reg     [3:0]      baud_counter;
reg     [8:0]      data_shift;
wire               en;
wire               stop;
wire               switch;
wire               parity;


always @(posedge clk or posedge reset) begin
    if(reset) begin
        count<='b0;
        temp<='b0;
    end
    else begin
        if(en) count <= count + 1;
        if(count==halfBaud-1) begin
            temp=~temp;
            count<='b0;
        end
    end
end

always @(negedge data or posedge reset) begin
    if(reset) idle <= 'b1;
    else begin
        if(stop) idle <= 'b1;
        else idle <= 'b0;
    end
end

assign en=~idle;

always @(posedge temp or posedge reset) begin
    if(reset) baud_counter <= 'b0;
    else begin
        if(en&(!stop)) baud_counter <= baud_counter + 1;
    end
end

always @(posedge temp or posedge reset) begin
    if(reset) data_shift <='b0;
    else begin
        if(en) data_shift[8] <= data;
        for(integer i = 0; i < 8; i=i+1) begin
            data_shift[i]=data_shift[i+1];
        end
    end
end

assign stop = baud_counter[3]&!baud_counter[2]&baud_counter[1]&!baud_counter[0];
assign parity = ^data_shift[7:0];

assign we=stop&(parity&data_shift[8]);
assign data_out=data_shift[7:0];

endmodule
