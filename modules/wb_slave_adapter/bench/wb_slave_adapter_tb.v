// TODO: this only tests address conversion, not classic to pipeline not
// pipeline to classic transactions
module wb_slave_adapter_tb;
    localparam clk_period = 5;
    localparam clk_half_period = clk_period/2;
    localparam num_cycles_rst = 4;
    localparam rst_period = num_cycles_rst * clk_period;

    localparam MAX_ADDR_TEST = (2**10) >> 2; // byte addressed
    localparam WB_AW = 32;
    localparam WB_DW = 32;
    //Word size in bytes
    localparam WSB = WB_DW/8;

    localparam MEM_SIZE_BYTES = 32'h0000_8000; // 32KB
    localparam BYTES_PER_DW = (WB_DW/8);
    localparam MEM_WORDS = (MEM_SIZE_BYTES/BYTES_PER_DW);

    localparam c_num_tests = 4; // X2X, C2P, C2P_B2W, C2P_W2B
    localparam c_num_tests_width = $clog2(c_num_tests);
    localparam [c_num_tests_width-1:0]
        TEST_X2X = 0,
        TEST_C2P = 1,
        TEST_C2P_B2W = 2,
        TEST_C2P_W2B = 3;
    localparam [0:c_num_tests-1] c_wb_adp_sl_gran = 'b0001;
    localparam [0:c_num_tests-1] c_wb_adp_ma_gran = 'b0010;
    localparam [0:c_num_tests-1] c_wb_adp_sl_mode = 'b0000;
    localparam [0:c_num_tests-1] c_wb_adp_ma_mode = 'b0111;

    reg clk = 1'b1;
    reg rst_n = 1'b0;
    reg test_addr = 0;
    wire rst;

    always #clk_half_period clk <= !clk;
    initial #rst_period rst_n <= 1;
    assign rst = ~rst_n;

    vlog_tb_utils vlog_tb_utils0();
    vlog_functions utils();
    vlog_tap_generator #("wb_slave_adapter_tb.tap", 1) tap();

    // Wishbone configuration interface
    wire [WB_AW-1:0]    wb_m2s_adr [0:c_num_tests-1];
    wire [WB_DW-1:0]    wb_m2s_dat [0:c_num_tests-1];
    wire [WB_DW/8-1:0]  wb_m2s_sel [0:c_num_tests-1];
    wire                wb_m2s_we  [0:c_num_tests-1];
    wire                wb_m2s_cyc [0:c_num_tests-1];
    wire                wb_m2s_stb [0:c_num_tests-1];
    wire [WB_DW-1:0]    wb_s2m_dat [0:c_num_tests-1];
    wire                wb_s2m_ack [0:c_num_tests-1];
    wire                wb_s2m_err [0:c_num_tests-1];

    wire [WB_AW-1:0]    wb_adp_m2s_adr [0:c_num_tests-1];
    wire [WB_DW-1:0]    wb_adp_m2s_dat [0:c_num_tests-1];
    wire [WB_DW/8-1:0]  wb_adp_m2s_sel [0:c_num_tests-1];
    wire                wb_adp_m2s_we  [0:c_num_tests-1];
    wire                wb_adp_m2s_cyc [0:c_num_tests-1];
    wire                wb_adp_m2s_stb [0:c_num_tests-1];
    wire [WB_DW-1:0]    wb_adp_s2m_dat [0:c_num_tests-1];
    wire                wb_adp_s2m_ack [0:c_num_tests-1];
    wire                wb_adp_s2m_err [0:c_num_tests-1];

    genvar i;
    generate for (i=0 ; i<c_num_tests; i=i+1) begin : gen_wb_dut
        wb_bfm_mod_master wb_cfg_ma (
            .wb_clk_i       (clk),
            .wb_rst_i       (rst),
            .wb_adr_o       (wb_m2s_adr[i]),
            .wb_dat_o       (wb_m2s_dat[i]),
            .wb_sel_o       (wb_m2s_sel[i]),
            .wb_we_o        (wb_m2s_we[i]),
            .wb_cyc_o       (wb_m2s_cyc[i]),
            .wb_stb_o       (wb_m2s_stb[i]),
            .wb_dat_i       (wb_s2m_dat[i]),
            .wb_ack_i       (wb_s2m_ack[i]),
            .wb_err_i       (wb_s2m_err[i]),
            .wb_rty_i       (1'b0));

        wb_slave_adapter #(
          .g_master_mode            (c_wb_adp_ma_mode[i]),
          .g_master_granularity     (c_wb_adp_ma_gran[i]),
          .g_slave_mode             (c_wb_adp_sl_mode[i]),
          .g_slave_granularity      (c_wb_adp_sl_gran[i])
        ) dut
        (
            .clk_i          (clk),
            .rst_n_i        (rst_n),

            .sl_adr_i       (wb_m2s_adr[i]),
            .sl_dat_i       (wb_m2s_dat[i]),
            .sl_sel_i       (wb_m2s_sel[i]),
            .sl_we_i        (wb_m2s_we[i]),
            .sl_cyc_i       (wb_m2s_cyc[i]),
            .sl_stb_i       (wb_m2s_stb[i]),
            .sl_dat_o       (wb_s2m_dat[i]),
            .sl_ack_o       (wb_s2m_ack[i]),
            .sl_err_o       (wb_s2m_err[i]),
            .sl_stall_o     (),

            .ma_adr_o       (wb_adp_m2s_adr[i]),
            .ma_dat_o       (wb_adp_m2s_dat[i]),
            .ma_sel_o       (wb_adp_m2s_sel[i]),
            .ma_we_o        (wb_adp_m2s_we[i]),
            .ma_cyc_o       (wb_adp_m2s_cyc[i]),
            .ma_stb_o       (wb_adp_m2s_stb[i]),
            .ma_dat_i       (wb_adp_s2m_dat[i]),
            .ma_ack_i       (wb_adp_s2m_ack[i]),
            .ma_err_i       (wb_adp_s2m_err[i]),
            .ma_rty_i       (1'b0),
            .ma_stall_i     (1'b0)
        );

        wb_bfm_mod_memory #(
            .DEBUG(1),
            .mem_size_bytes(MEM_SIZE_BYTES)
        ) wb_bfm_mod_mem
        (
            .wb_clk_i       (clk),
            .wb_rst_i       (rst),
            .wb_adr_i       (wb_adp_m2s_adr[i]),
            .wb_dat_i       (wb_adp_m2s_dat[i]),
            .wb_sel_i       (wb_adp_m2s_sel[i]),
            .wb_we_i        (wb_adp_m2s_we[i]),
            .wb_bte_i       (2'b0),
            .wb_cti_i       (3'b0),
            .wb_cyc_i       (wb_adp_m2s_cyc[i]),
            .wb_stb_i       (wb_adp_m2s_stb[i]),
            .wb_dat_o       (wb_adp_s2m_dat[i]),
            .wb_ack_o       (wb_adp_s2m_ack[i]),
            .wb_err_o       (wb_adp_s2m_err[i]),
            .wb_rty_o       ()
        );
    end
    endgenerate

    integer mw;
    integer max_addr;
    reg     VERBOSE = 2;
    initial begin
        if($test$plusargs("verbose"))
            VERBOSE = 2;

        @(negedge rst);
        @(posedge clk);

        cfg_rst_all();
        test_main();
        tap.ok("All done");
        $finish;
    end

    task test_main;
        reg [WB_AW-1:0] adr;
        reg [WB_AW-1:0] adr_write;
        reg [WB_DW-1:0] dat;

        begin
            // Can't do "for(i=0;i<=c_num_tests;i=i+1) begin" as gen_wb_dut[i]
            // is not compile-time constant...
            adr = gen_urandom(MAX_ADDR_TEST-1);
            adr_write = adr << 2; // byte addressed
            dat = gen_urandom(2**WB_DW-1);
            cfg_write(TEST_X2X, adr_write, dat);
            @(posedge clk);
            @(posedge clk);
            verify("test_adp_x2x", dat, gen_wb_dut[TEST_X2X].wb_bfm_mod_mem.mem[adr]);

            //adr = gen_urandom(MAX_ADDR_TEST-1);
            //adr_write = adr << 2; // byte addressed
            //dat = gen_urandom(2**WB_DW-1);
            //cfg_write(TEST_C2P, adr_write, dat);
            //@(posedge clk);
            //@(posedge clk);
            //verify("test_adp_c2p", dat, gen_wb_dut[TEST_C2P].wb_bfm_mod_mem.mem[adr]);

            adr = gen_urandom(MAX_ADDR_TEST-1);
            adr_write = adr << 2; // byte addressed
            dat = gen_urandom(2**WB_DW-1);
            cfg_write(TEST_C2P_B2W, adr_write, dat);
            @(posedge clk);
            @(posedge clk);
            verify("test_adp_c2p_b2w", dat, gen_wb_dut[TEST_C2P_B2W].wb_bfm_mod_mem.mem[adr >> 2]);

            adr = gen_urandom(MAX_ADDR_TEST-1);
            adr_write = adr << 2; // byte addressed
            dat = gen_urandom(2**WB_DW-1);
            cfg_write(TEST_C2P_W2B, adr_write, dat);
            @(posedge clk);
            @(posedge clk);
            verify("test_adp_c2p_w2b", dat, gen_wb_dut[TEST_C2P_W2B].wb_bfm_mod_mem.mem[adr << 2]);
        end
    endtask

    function [31:0] gen_urandom;
        input integer max;

        integer tmp;
        begin
            tmp = $urandom % max;
            gen_urandom = tmp[31:0];
        end
    endfunction

    task cfg_write;
        input integer test_wb_dut_i;
        input [WB_AW-1:0] addr_i;
        input [WB_DW-1:0] dat_i;

        reg  err;
        begin
            // Can't do gen_wb_dut[test_wb_dut_i].wb_cfg_ma...
            case (test_wb_dut_i)
                TEST_X2X:
                    gen_wb_dut[TEST_X2X].wb_cfg_ma.write(addr_i, dat_i, 4'hf, err);
                TEST_C2P:
                    gen_wb_dut[TEST_C2P].wb_cfg_ma.write(addr_i, dat_i, 4'hf, err);
                TEST_C2P_B2W:
                    gen_wb_dut[TEST_C2P_B2W].wb_cfg_ma.write(addr_i, dat_i, 4'hf, err);
                TEST_C2P_W2B:
                    gen_wb_dut[TEST_C2P_W2B].wb_cfg_ma.write(addr_i, dat_i, 4'hf, err);
            endcase

            if(err) begin
                $display("Error writing to config interface wb_cfg[%d], address 0x%8x",
                    test_wb_dut_i, addr_i);
                $finish;
            end
        end
    endtask

    task cfg_rst;
        input integer test_wb_dut_i;

        reg  err;
        begin
            // Can't do gen_wb_dut[test_wb_dut_i].wb_cfg_ma...
            case (test_wb_dut_i)
                TEST_X2X:
                    gen_wb_dut[TEST_X2X].wb_cfg_ma.reset;
                TEST_C2P:
                    gen_wb_dut[TEST_C2P].wb_cfg_ma.reset;
                TEST_C2P_B2W:
                    gen_wb_dut[TEST_C2P_B2W].wb_cfg_ma.reset;
                TEST_C2P_W2B:
                    gen_wb_dut[TEST_C2P_W2B].wb_cfg_ma.reset;
            endcase
        end
    endtask

    task cfg_rst_all;
        integer i;
        begin
            for(i=0; i<c_num_tests; i=i+1)
                cfg_rst(i);
        end
    endtask

    task verify;
        input [8*20:1] test;
        input [WB_DW-1:0] expected;
        input [WB_DW-1:0] received;
        begin
            if(received !== expected) begin
                $display("%0d : Verify failed for test \"%s\". Expected 0x%8x : Got 0x%8x",
                    $time,
                    test,
                    expected,
                    received);
                $finish;
            end
        end
    endtask


endmodule
