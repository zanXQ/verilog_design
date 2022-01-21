`include "uart_tx.v"
`include "uart_rx.v"

module uart
(
    input               clk,reset,en,
    input    [7:0]      data_in,
    output   [7:0]      data_out,
    output              done,we,
    output   [31:0]     address
);

wire    data;

uart_tx test0 ( .clk(clk), .reset(reset), .en(en),
                .data(data_in),
                .data_tx(data),
                .done(done));

uart_rx test1 ( .clk(clk), .reset(reset),
                .data_tx(data),
                .data_out(data_out),
                .we(we),
                .address(address));


endmodule
