`timescale 1 ns / 1 ps

module atta_tb #(
    parameter VERBOSE = 0
);

    reg clk = 1;
    reg rst_n = 0;
    wire trap;

    always #5 clk = ~clk;
    wire rst = ~rst_n;

    initial begin
        repeat (100) @(posedge clk);
        rst_n <= 1;
    end

    initial begin
        if ($test$plusargs("vcd")) begin
            $dumpfile("testbench.vcd");
            $dumpvars(0, dut);
        end
        repeat (1000000) @(posedge clk);
        $display("TIMEOUT");
        $finish;
    end

    wire trace_valid;
    wire [35:0] trace_data;
    integer trace_file;

    initial begin
        if ($test$plusargs("trace")) begin
            trace_file = $fopen("testbench.trace", "w");
            repeat (10) @(posedge clk);
            while (!trap) begin
                @(posedge clk);
                if (trace_valid)
                    $fwrite(trace_file, "%x\n", trace_data);
            end
            $fclose(trace_file);
            $display("Finished writing testbench.trace.");
        end
    end

    reg [1023:0] firmware_file;
    initial begin
        if (!$value$plusargs("firmware=%s", firmware_file))
            firmware_file = "firmware/MMX.hex";
        $readmemh(firmware_file, dut.cmp_wb_ram.ram0.mem);
    end

    integer cycle_counter;
    always @(posedge clk) begin
        cycle_counter <= !rst ? cycle_counter + 1 : 0;
        if (!rst && trap) begin
            repeat (10) @(posedge clk);
            $display("TRAP after %1d clock cycles", cycle_counter);
            if ($test$plusargs("noerror"))
                $finish;
            $stop;
        end
    end

    reg [31:0] irq = 0;

    atta_system # (
        .firmware_file  ("")
    )
    dut
    (
        .clk_i          (clk),
        .rst_i          (rst),

        .trap_o         (trap),
        .trace_valid_o  (trace_valid),
        .trace_data_o   (trace_data),
        .mem_instr_o    (),
        .irq_i          (irq),

        .gpio_o         ()
    );

endmodule
