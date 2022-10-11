module ram #(parameter ADDR_WIDTH = 4,
             parameter DATA_WIDTH = 32)
(
             input 					    clk,
             input 					    wr_en,
             input [ADDR_WIDTH - 1 : 0] addr,
             inout [DATA_WIDTH - 1 : 0] data
);

localparam                    DEPTH = 2**DATA_WIDTH;
reg       [DATA_WIDTH - 1:0]  mem [0 : DEPTH - 1];

always @ (posedge clk)
    begin
        if (wr_en)
            begin
                mem[addr] <= data;
            end
    end

assign data = !wr_en ? mem[addr] : 'hz;

endmodule

