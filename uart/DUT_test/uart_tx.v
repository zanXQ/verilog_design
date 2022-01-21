module uart_tx
(
    input             clk,reset,en,
    input   [7:0]     data,
    output            data_tx,
    output            done
);
parameter clk_tx=50000;
parameter Baudrate=10000;

parameter halfBaud=(clk_tx)/(Baudrate*2);

reg     [7:0]      count;
reg                temp;

reg                idle;
reg     [3:0]      baud_counter;
reg     [7:0]      data_shift;
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

always @(posedge clk or posedge reset) begin
    if(reset) idle <= 'b1;
    else begin
        if(en) idle <= 'b0;
        if(stop) idle <= 'b1;
    end
end

always @(posedge temp or posedge reset) begin
    if(reset) baud_counter <= 'b0;
    else begin
        if(en&(!stop)) baud_counter <= baud_counter + 1;
    end
end

always @(posedge temp or posedge reset) begin
    if(reset) data_shift <='b0;
    else begin
        if(baud_counter == 'b1) data_shift <= data;
        //data_shift[7]='b0;
        for(integer i = 0; i < 7; i=i+1) begin
            data_shift[i]=data_shift[i+1];
        end
    end
end

assign stop = baud_counter[3]&!baud_counter[2]&baud_counter[1]&baud_counter[0];
assign switch = baud_counter[3]&!baud_counter[2]&baud_counter[1]&!baud_counter[0];
assign parity = ^data;

assign data_tx = idle|stop|(switch?parity:data_shift[0]);
assign done=stop;

endmodule
