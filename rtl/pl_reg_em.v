

module pl_reg_em (
    input clk,
    input reset,

    // Execute-stage data inputs
    input [31:0] ALUResultE,
    input [31:0] WriteDataE,
    input [31:0] PCPlus4E,
    input [31:0] lAuiPCE,
    input [4:0] RdE,
    input [2:0] funct3E,

    // Execute-stage control inputs
    input [1:0] ResultSrcE,
    input MemWriteE,
    input RegWriteE,

    // Memory-stage data outputs
    output reg [31:0] ALUResultM,
    output reg [31:0] WriteDataM,
    output reg [31:0] PCPlus4M,
    output reg [31:0] lAuiPCM,
    output reg [4:0] RdM,
    output reg [2:0] funct3M,

    // Memory-stage control outputs
    output reg [1:0] ResultSrcM,
    output reg MemWriteM,
    output reg RegWriteM
);

always @(posedge clk) begin
    if (reset) begin
        ALUResultM <= 32'b0;
        WriteDataM <= 32'b0;
        PCPlus4M   <= 32'b0;
        lAuiPCM    <= 32'b0;
        RdM        <= 5'b0;
        funct3M    <= 3'b0;

        ResultSrcM <= 2'b0;
        MemWriteM  <= 1'b0;
        RegWriteM  <= 1'b0;
    end
    else begin
        ALUResultM <= ALUResultE;
        WriteDataM <= WriteDataE;
        PCPlus4M   <= PCPlus4E;
        lAuiPCM    <= lAuiPCE;
        RdM        <= RdE;
        funct3M    <= funct3E;

        ResultSrcM <= ResultSrcE;
        MemWriteM  <= MemWriteE;
        RegWriteM  <= RegWriteE;
    end
end

endmodule