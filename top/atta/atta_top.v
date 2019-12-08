`timescale 1 ns / 1 ns

module atta_top #(
    parameter firmware_file = "../../firmware/MMX.hex"
)
(
    input            sysclk_i,
    output [4:0]     gpio_led_o
);

wire clk_100;
wire locked;
// Should be more robust than this, but it will do for now
wire rst = ~locked;

sys_clk #(
    .DIFF_CLKIN     ("FALSE"),
    .CLKIN_PERIOD   (10.000),
    .MULT           (10.000),
    .DIV0           (10)
) cmp_sys_clk (
    .sysclk_p_i     (sysclk_i),
    .sysclk_n_i     (1'b0),
    .rst_i          (1'b0),
    .clk_out0_o     (clk_100),
    .locked_o       (locked)
);

wire [31:0] gpio;
wire trap;
wire trace_valid;
wire [35:0] trace_data;
reg [31:0] irq = 0;
atta_system #(
    .firmware_file  (firmware_file)
) cmp_atta_system (
    .clk_i          (clk_100),
    .rst_i          (rst),
    .trap_o         (trap),
    .trace_valid_o  (trace_valid),
    .trace_data_o   (trace_data),
    .mem_instr_o    (mem_instr),
    .irq_i          (irq),
    .gpio_o         (gpio)
);

assign gpio_led_o[0] = gpio[0];
assign gpio_led_o[1] = gpio[1];
assign gpio_led_o[2] = gpio[2];
assign gpio_led_o[3] = gpio[3];
assign gpio_led_o[4] = trap;

endmodule
