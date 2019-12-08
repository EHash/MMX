// Simple wrapper for wbgen/cheby generate code

module wbgen2_dpssram #(
    parameter g_data_width = 32,
    parameter g_size = 1024,
    parameter g_addr_width = 10,
    parameter g_dual_clock = 1,
    parameter g_use_bwsel = 1
) (
    input clk_a_i,
    input clk_b_i,

    input [g_addr_width-1:0] addr_a_i,
    input [g_addr_width-1:0] addr_b_i,

    input [g_data_width-1:0] data_a_i,
    input [g_data_width-1:0] data_b_i,

    output [g_data_width-1:0] data_a_o,
    output [g_data_width-1:0] data_b_o,

    input [(g_data_width+7)/8-1:0] bwsel_a_i,
    input [(g_data_width+7)/8-1:0] bwsel_b_i,

    input rd_a_i,
    input rd_b_i,

    input wr_a_i,
    input wr_b_i
);

dpram #(
    .dw(g_data_width),
    .aw(g_addr_width)
)
dpram_inst (
	.clka(clk_a_i),
    .clkb(clk_b_i),
	.addra(addr_a_i),
    .dina(data_a_i),
    .douta(data_a_o),
    .wena(wr_a_i),
	.addrb(addr_b_i),
    .dinb(data_b_i),
    .doutb(data_b_o),
    .wenb(wr_b_i)
);

endmodule
