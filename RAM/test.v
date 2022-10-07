`timescale 1 ns / 100 ps

module test();

localparam                      DATA_WIDTH  = 16;
localparam                      ADDR_WIDTH  = 4;
localparam                      TOTAL_TESTS = 2;
localparam                      DEPTH       = 2**ADDR_WIDTH;

reg        [ADDR_WIDTH - 1 : 0] addr;
reg        [DATA_WIDTH - 1 : 0] tmp_data;
reg        [DATA_WIDTH - 1 : 0] mem [0 : DEPTH - 1];
reg                             clk         = 1'b1;
reg                             wr_en;
wire       [DATA_WIDTH - 1 : 0] data;

integer                         passed_tests_count = 0;
integer                         failed_tests_count = 0;
integer                         skipped_tests_count = 0;
realtime                        start_capture;
realtime                        end_capture;
realtime                        all_tests_end;

always
    begin
        #1 clk = ~clk;
    end

initial
    begin
        addr     <= $random;
        tmp_data <= $random;
    end

initial
    begin
        force data = tmp_data;
    end

task check_wr_en_enabled;
    begin
        @(posedge clk);
        $display("");
        $display("Test check_wr_en_enabled started. (Testing properly work with 'wr_en' enabled).");

        start_capture = $realtime;
        wr_en     = 1'b1;

        repeat(20)@(posedge clk);

        wr_en     = 1'b0;
        mem[addr] = data;

        if(data == mem[addr])
            begin
                $display("Test with enabled 'wr_en' PASSED.");
                passed_tests_count = passed_tests_count + 1;
            end else begin
                $display("Test with enabled 'wr_en' FAILED.");
                failed_tests_count = failed_tests_count + 1;
            end

        $display("Test check_wr_en_enabled ended.");
        end_capture = $realtime;
        $display("Time elapsed for this test: %t", end_capture - start_capture);
    end
endtask

task check_wr_en_disabled;
    begin
        @(posedge clk);
        $display("");
        $display("Test check_wr_en_disabled started. (Testing properly work with 'wr_en' disabled).");

        start_capture = $realtime;
        wr_en = 1'b0;

        repeat(20)@(posedge clk);

        mem[addr] = data;

        if(data == mem[addr])
            begin
                $display("Test with enabled 'wr_en' FAILED.");
                passed_tests_count = passed_tests_count + 1;
            end else begin
                $display("Test with enabled 'wr_en' PASSED.");
                failed_tests_count = failed_tests_count + 1;
            end
        $display("Test check_wr_en_disabled ended.");
        end_capture = $realtime;
        $display("Time elapsed for this test: %t", end_capture - start_capture);
    end
endtask

initial
    begin
        $dumpvars;
        $timeformat(-9, 3, " ns", 10);
        $display("");
        $display("Starting tests...");

        check_wr_en_enabled;
        check_wr_en_disabled;

        if(passed_tests_count + failed_tests_count != TOTAL_TESTS)
            begin
                skipped_tests_count = TOTAL_TESTS - (passed_tests_count + failed_tests_count);
            end

        all_tests_end = $realtime;

        $display("");
        $display("TOTAL TESTS: %0d, PASSED: %0d, FAILED: %0d, SKIPPED: %0d.",
                    TOTAL_TESTS, passed_tests_count, failed_tests_count, skipped_tests_count);
        $display("Time elapsed for all tests: %0t", all_tests_end);
        $display("");

        #1000 $finish;
    end //end of initial block

ram #(.DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH))
     ram
     (.clk(clk),
      .addr(addr),
      .data(data),
      .wr_en(wr_en));

endmodule //test
