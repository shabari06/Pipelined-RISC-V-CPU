// pl_reg_de.v
// Pipeline Register: Decode -> Execute

module pl_reg_de (
    input clk,
    input reset,
    input FlushE,

    // Data signals from Decode
	 input [31:0] InstrD,
    input [31:0] RD1D,
    input [31:0] RD2D,
    input [31:0] ImmExtD,
    input [31:0] PCD,
    input [31:0] PCPlus4D,

    // Register addresses
    input [4:0] Rs1D,
    input [4:0] Rs2D,
    input [4:0] RdD,

    // Control signals from Decode
    input [3:0] ALUControlD,
    input ALUSrcD,
    input BranchD,
    input JumpD,
    input JalrD,
    input MemWriteD,
    input RegWriteD,
    input [1:0] ResultSrcD,

    // Data signals to Execute
	 output reg [31:0] InstrE,
    output reg [31:0] RD1E,
    output reg [31:0] RD2E,
    output reg [31:0] ImmExtE,
    output reg [31:0] PCE,
    output reg [31:0] PCPlus4E,

    // Register addresses to Execute
    output reg [4:0] Rs1E,
    output reg [4:0] Rs2E,
    output reg [4:0] RdE,

    // Control signals to Execute
    output reg [3:0] ALUControlE,
    output reg ALUSrcE,
    output reg BranchE,
    output reg JumpE,
    output reg JalrE,
    output reg MemWriteE,
    output reg RegWriteE,
    output reg [1:0] ResultSrcE
);

always @(posedge clk) begin
    if (reset || FlushE) begin

        // Clear data signals
        RD1E       <= 32'b0;
        RD2E       <= 32'b0;
        ImmExtE    <= 32'b0;
        PCE        <= 32'b0;
        PCPlus4E   <= 32'b0;
		  InstrE     <= 32'b0;

        // Clear register addresses
        Rs1E       <= 5'b0;
        Rs2E       <= 5'b0;
        RdE        <= 5'b0;

        // Clear control signals
        ALUControlE <= 4'b0;
        ALUSrcE     <= 1'b0;
        BranchE     <= 1'b0;
        JumpE       <= 1'b0;
        JalrE       <= 1'b0;
        MemWriteE   <= 1'b0;
        RegWriteE   <= 1'b0;
        ResultSrcE  <= 2'b0;

    end else begin
			

        // Capture Decode-stage data
        RD1E       <= RD1D;
        RD2E       <= RD2D;
        ImmExtE    <= ImmExtD;
        PCE        <= PCD;
        PCPlus4E   <= PCPlus4D;
		  
		  InstrE     <= InstrD;

        // Capture register addresses
        Rs1E       <= Rs1D;
        Rs2E       <= Rs2D;
        RdE        <= RdD;

        // Capture control signals
        ALUControlE <= ALUControlD;
        ALUSrcE     <= ALUSrcD;
        BranchE     <= BranchD;
        JumpE       <= JumpD;
        JalrE       <= JalrD;
        MemWriteE   <= MemWriteD;
        RegWriteE   <= RegWriteD;
        ResultSrcE  <= ResultSrcD;

    end
end

endmodule