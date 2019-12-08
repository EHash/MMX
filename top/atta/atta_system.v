module atta_system #(
    parameter firmware_file = "../../firmware/MMX.hex",
    parameter firmware_ram_depth = 65536 // 64KB
)
(
    input           clk_i,
    input           rst_i,
    // picorv signals
    output          trap_o,
    output          trace_valid_o,
    output [35:0]   trace_data_o,
    output          mem_instr_o,
    input [31:0]    irq_i,

    // external modules
    output [31:0]    gpio_o
);

////////////////////////////////////////////////////////////////////////
// Modules interconnections
////////////////////////////////////////////////////////////////////////
`include "wb_intercon.vh"

// These are used by wb_intercon instantiatred by the "wb_intercon.vh" macro
assign wb_clk = clk_i;
assign wb_rst = rst_i;

wire rst_n = ~rst_i;

////////////////////////////////////////////////////////////////////////
// Picorv32
////////////////////////////////////////////////////////////////////////
picorv32_wb #(
    .ENABLE_REGS_DUALPORT (1),
    .ENABLE_MUL           (1),
    .ENABLE_DIV           (1),
    .ENABLE_TRACE         (1),
    // Enable support for compressed instr. set. Must match firmware options
    // in Makefile
    .COMPRESSED_ISA       (1),
    .BARREL_SHIFTER(1),
    .ENABLE_PCPI(1),
    .ENABLE_IRQ(0)

) cmp_picorv32 (
    .wb_clk_i           (clk_i),
    .wb_rst_i           (rst_i),

    .wbm_adr_o          (wb_m2s_picorv32_adr),
    .wbm_dat_i          (wb_s2m_picorv32_dat),
    .wbm_stb_o          (wb_m2s_picorv32_stb),
    .wbm_ack_i          (wb_s2m_picorv32_ack),
    .wbm_cyc_o          (wb_m2s_picorv32_cyc),
    .wbm_dat_o          (wb_m2s_picorv32_dat),
    .wbm_we_o           (wb_m2s_picorv32_we),
    .wbm_sel_o          (wb_m2s_picorv32_sel),

    .pcpi_wr            (1'b0),
    .pcpi_rd            (32'b0),
    .pcpi_wait          (1'b0),
    .pcpi_ready         (1'b0),

    .trap               (trap_o),
    .irq                (irq_i),
    .trace_valid        (trace_valid_o),
    .trace_data         (trace_data_o),
    .mem_instr          (mem_instr_o)
);

assign wb_m2s_picorv32_cti = 3'b000;
assign wb_m2s_picorv32_bte = 2'b00;

////////////////////////////////////////////////////////////////////////
// RAM
////////////////////////////////////////////////////////////////////////

wb_ram #(
    .memfile            (firmware_file),
    .depth              (firmware_ram_depth)
) cmp_wb_ram (
    //Wishbone Master interface
    .wb_clk_i           (clk_i),
    .wb_rst_i           (rst_i),

    .wb_cyc_i           (wb_m2s_ram_cyc),
    .wb_dat_i           (wb_m2s_ram_dat),
    .wb_sel_i           (wb_m2s_ram_sel),
    .wb_we_i            (wb_m2s_ram_we),
    .wb_bte_i           (wb_m2s_ram_bte),
    .wb_cti_i           (wb_m2s_ram_cti),
    .wb_adr_i           (wb_m2s_ram_adr),
    .wb_stb_i           (wb_m2s_ram_stb),
    .wb_dat_o           (wb_s2m_ram_dat),
    .wb_ack_o           (wb_s2m_ram_ack)
);

assign wb_s2m_ram_err = 1'b0;
assign wb_s2m_ram_rty = 1'b0;

////////////////////////////////////////////////////////////////////////
// LEDs
////////////////////////////////////////////////////////////////////////

wb_leds cmp_wb_leds
(
    // Clock/Resets
    .clk_i              (clk_i),
    .rst_n_i            (rst_n),

    // Wishbone signals
    .wb_cyc_i           (wb_m2s_leds_cyc),
    .wb_dat_i           (wb_m2s_leds_dat),
    .wb_sel_i           (wb_m2s_leds_sel),
    .wb_we_i            (wb_m2s_leds_we),
    .wb_adr_i           (wb_m2s_leds_adr),
    .wb_stb_i           (wb_m2s_leds_stb),
    .wb_dat_o           (wb_s2m_leds_dat),
    .wb_ack_o           (wb_s2m_leds_ack),

    // LEDs
    .leds_o             (gpio_o)
);

assign wb_s2m_leds_err = 1'b0;
assign wb_s2m_leds_rty = 1'b0;

endmodule
