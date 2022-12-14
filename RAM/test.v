`timescale 1 ns / 100 ps

module test();

localparam                      DATA_WIDTH        = 16;
localparam                      ADDR_WIDTH        = 4;
localparam                      TOTAL_TESTS       = 3;
localparam                      DEPTH             = 2**ADDR_WIDTH;
localparam                      CLK_HALF_PERIOD   = 5;
localparam                      FR_DELAY          = 9;

reg                             data_corrupted;
reg        [ADDR_WIDTH - 1 : 0] addr;
reg        [DATA_WIDTH - 1 : 0] mem [0 : DEPTH - 1];
reg                             clk;
reg                             wr_en;
reg        [DATA_WIDTH - 1 : 0] tmp_data;
wire       [DATA_WIDTH - 1 : 0] data;

integer                         iter;
integer                         passed_tests_count;
integer                         failed_tests_count;
integer                         skipped_tests_count;
realtime                        start_capture;
realtime                        end_capture;
realtime                        all_tests_end;

initial
begin
    clk <= 1'b1;
    wr_en <= 1'b0;
    iter <= 0;
    passed_tests_count <= 0;
    failed_tests_count <= 0;
    skipped_tests_count <= 0;
end

always
begin
    #CLK_HALF_PERIOD clk = ~clk;
end

assign data = wr_en ? tmp_data : 'hz;

task check_wr_en_change;
begin
    @(posedge clk);
    $display("\nTest check_wr_en_change started. (Testing properly work with 'wr_en' changing).");
    start_capture = $realtime;
    wr_en = 1'b1;
    data_corrupted = 1'b0;
    #0;

    @(posedge clk);
    #2;
    addr = {(ADDR_WIDTH){1'b0}};
    tmp_data = $random;

    wr_en = 1'b0;

    @(posedge clk);
    #2;
    mem[0] = ram.mem[0];
    #0;

    if(!(mem[0] == tmp_data))
    begin
        $display("Test check_wr_en_change FAILED.");
        failed_tests_count = failed_tests_count + 1;
    end else begin
        $display("Test check_wr_en_change PASSED.");
        passed_tests_count = passed_tests_count + 1;
    end

    $display("Test check_wr_en_change ended.");
    end_capture = $realtime;
    $display("Time elapsed for this test: %t", end_capture - start_capture);
end
endtask //check_wr_en_change

task check_wr_en_true;
begin
    @(posedge clk);
    $display("\nTest check_wr_en_true started. (Testing properly work with 'wr_en' enabled).");
    start_capture = $realtime;
    wr_en = 1'b1;
    data_corrupted = 1'b0;
    #0;

    for(iter = 0; iter < 16; iter = iter + 1)
    begin
        @(posedge clk);
        #2;
        addr = iter;
        tmp_data = $random;
    end
    #0;

    for(iter = 0; iter < 16; iter = iter + 1)
    begin
        @(posedge clk);
        #2;
        mem[iter] = ram.mem[iter];
    end
    #0;

    for(iter = 0;iter < 16;iter = iter + 1)
    begin
        if(mem[iter] == 'hx)
        begin
            data_corrupted = 1'b1;
        end
    end
    #0;

    if(data_corrupted)
    begin
        $display("Test check_wr_en_true FAILED.");
        failed_tests_count = failed_tests_count + 1;
    end else begin
        $display("Test check_wr_en_true PASSED.");
        passed_tests_count = passed_tests_count + 1;
    end

    $display("Test check_wr_en_true ended.");
    end_capture = $realtime;
    $display("Time elapsed for this test: %t", end_capture - start_capture);
end
endtask //check_wr_en_true

task check_wr_en_false;
begin
    @(posedge clk);
    $display("\nTest check_wr_en_false started. (Testing properly work with 'wr_en' disabled).");
    start_capture = $realtime;
    wr_en = 1'b0;
    data_corrupted = 1'b0;
    #0;

    for(iter = 0;iter < 16;iter = iter + 1)
    begin
        @(posedge clk);
        ram.mem[iter] = 'hx;
    end
    #0;

    for(iter = 0; iter < 16; iter = iter + 1)
    begin
        @(posedge clk);
        #2;
        addr = iter;
    end
    #0;

    for(iter = 0;iter < 16;iter = iter + 1)
    begin
        @(posedge clk);
        #2;
        mem[iter] = ram.mem[iter];
    end
    #0;

    for(iter = 0;iter < 16;iter = iter + 1)
    begin
        if(mem[iter] == data)
            begin
                data_corrupted = 1'b1;
            end
    end
    #0;

    if(data_corrupted)
    begin
        $display("Test check_wr_en_false FAILED.");
        failed_tests_count = failed_tests_count + 1;
    end else begin
        $display("Test check_wr_en_false PASSED.");
        passed_tests_count = passed_tests_count + 1;
    end

    $display("Test check_wr_en_false ended.");
    end_capture = $realtime;
    $display("Time elapsed for this test: %t", end_capture - start_capture);
end
endtask //check_wr_en_false

initial
begin
    $dumpvars;
    $timeformat(-9, 3, " ns", 10);
    $display("\nStarting tests...");

    check_wr_en_true;
    check_wr_en_false;
    check_wr_en_change;

    if(passed_tests_count + failed_tests_count != TOTAL_TESTS)
    begin
        skipped_tests_count = TOTAL_TESTS - (passed_tests_count + failed_tests_count);
    end

    all_tests_end = $realtime;

    $display("\nTOTAL TESTS: %0d, PASSED: %0d, FAILED: %0d, SKIPPED: %0d.",
                TOTAL_TESTS, passed_tests_count, failed_tests_count, skipped_tests_count);
    $display("Time elapsed for all tests: %0t\n", all_tests_end);

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
