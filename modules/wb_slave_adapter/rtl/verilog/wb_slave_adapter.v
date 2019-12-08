///////////////////////////////////////////////////////////////////////////////
// Title      : Wishbone Slave Adapter
// Project    : General Cores
///////////////////////////////////////////////////////////////////////////////
// File       : wb_slave_adapter.vhd
// Author     : Tomasz Wlostowski
// Company    : CERN
// Platform   : FPGA-generics
// Standard   : VHDL '93
///////////////////////////////////////////////////////////////////////////////
// Description:
//
// universal "adapter"
// pipelined <> classic
// word-aligned/byte-aligned address
///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2011-2017 CERN
//
// This source file is free software; you can redistribute it
// and/or modify it under the terms of the GNU Lesser General
// Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any
// later version.
//
// This source is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
// PURPOSE.  See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General
// Public License along with this source; if not, download it
// from http://www.gnu.org/licenses/lgpl-2.1.html
///////////////////////////////////////////////////////////////////////////////
//
// This is a conversion from VHDL to Verilog

module wb_slave_adapter #(
    parameter dw = 32,
    parameter aw = 32,
    // Wishbone master mode: 0 ("CLASSIC") or 1 ("PIPELINED")
    parameter g_master_mode        = 0,
    // Wishbone master g_slave_granularity: 0 ("BYTE") or 1 ("WORD")
    parameter g_master_granularity = 0,
    // Wishbone slave mode: 0 ("CLASSIC") or 1 ("PIPELINED")
    parameter g_slave_mode         = 0,
    // Wishbone master g_slave_granularity: 0 ("BYTE") or 1 ("WORD")
    parameter g_slave_granularity  = 0
) (
    // Clock/Resets
    input               clk_i,
    input               rst_n_i,

    // Wishbone signals
    // slave port (i.e. wb_slave_adapter is slave)
    input  [aw-1:0]     sl_adr_i,
    input  [dw-1:0]     sl_dat_i,
    input  [dw/8-1:0]   sl_sel_i,
    input               sl_we_i,
    input               sl_cyc_i,
    input               sl_stb_i,
    output [dw-1:0]     sl_dat_o,
    output              sl_ack_o,
    output              sl_err_o,
    output              sl_rty_o,
    output              sl_stall_o,

    // master port (i.e. wb_slave_adapter is master)
    output [aw-1:0]     ma_adr_o,
    output [dw-1:0]     ma_dat_o,
    output [dw/8-1:0]   ma_sel_o,
    output              ma_we_o,
    output              ma_cyc_o,
    output              ma_stb_o,
    input [dw-1:0]      ma_dat_i,
    input               ma_ack_i,
    input               ma_err_i,
    input               ma_rty_i,
    input               ma_stall_i
);

// As we only support 32 bits of wishbone data, the conversion
// from byte to word is always to shift data to 2 bits
localparam c_num_bytes2word_bits = 2;
localparam [c_num_bytes2word_bits-1:0] c_zero_bytes2word = 0;
localparam c_state_width = 1;
localparam [c_state_width-1:0]
    IDLE = 0,
    WAIT4ACK = 1;

reg [c_state_width-1:0] fsm_state = IDLE;

// Master to Slave address generation
generate
    if (g_master_granularity == g_slave_granularity)
        assign ma_adr_o = sl_adr_i;
    else if (g_master_granularity == 0) // byte -> word
        assign ma_adr_o = {sl_adr_i[32-c_num_bytes2word_bits-1:0], c_zero_bytes2word};
    else // word -> byte
        assign ma_adr_o = {c_zero_bytes2word, sl_adr_i[32-1:c_num_bytes2word_bits]};
endgenerate

// Parameter check
generate if (g_slave_mode != 0 && g_slave_mode != 1) begin: gen_error
    g_slave_mode_is_invalid_valid_modes_are_classic_or_pipelined invalid();
end
endgenerate

// Parameter check
generate if (g_master_mode != 0 && g_master_mode != 1) begin: gen_error
    g_master_mode_is_invalid_valid_modes_are_classic_or_pipelined invalid();
end
endgenerate

generate if (g_slave_mode == 1 && g_master_mode == 0) begin: gen_p2c
    assign ma_stb_o = sl_stb_i;
    assign sl_stall_o = ~ma_ack_i;
end
endgenerate

generate if (g_slave_mode == 0 && g_master_mode == 1) begin: gen_c2p
    assign ma_stb_o = (fsm_state == IDLE)? sl_stb_i : 0;
    assign sl_stall_o = 0; // classic will ignore this anyway

    always @(posedge clk_i) begin
        if (~rst_n_i)
            fsm_state <= IDLE;
        else begin
            case (fsm_state)
                IDLE: begin
                    if (sl_stb_i && sl_cyc_i && ~ma_stall_i && ~ma_ack_i)
                        fsm_state <= WAIT4ACK;
                end

                WAIT4ACK: begin
                    if ((~sl_stb_i && ~sl_cyc_i) || ma_ack_i || ma_err_i)
                        fsm_state <= IDLE;
                end
            endcase
        end
    end
end
endgenerate

generate if (g_slave_mode == g_master_mode) begin: gen_x2x
    assign ma_stb_o = sl_stb_i;
    assign sl_stall_o = ma_stall_i;
end
endgenerate

assign ma_dat_o = sl_dat_i;
assign ma_cyc_o = sl_cyc_i;
assign ma_sel_o = sl_sel_i;
assign ma_we_o  = sl_we_i;

assign sl_ack_o = ma_ack_i;
assign sl_err_o = ma_err_i;
assign sl_rty_o = ma_rty_i;
assign sl_dat_o = ma_dat_i;

endmodule
