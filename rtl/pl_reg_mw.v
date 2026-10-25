

module pl_reg_mw (
	input clk,
	input reset,

	
	// Memory-stage data inputs
	input [31:0] ALUResultM,
	input [31:0] ReadDataM,
	input [31:0] PCPlus4M,
	input [31:0] lAuiPCM,
	input [4:0]  RdM,

	// Memory-stage control inputs
	input [1:0] ResultSrcM,
	input       RegWriteM,
	
	input [31:0] WriteDataM,
	

	// Writeback-stage data outputs
	output reg [31:0] ALUResultW,
	output reg [31:0] ReadDataW,
	output reg [31:0] PCPlus4W,
	output reg [31:0] lAuiPCW,
	output reg [4:0]  RdW,

	// Writeback-stage control outputs
	output reg [1:0] ResultSrcW,
	output reg       RegWriteW,
	
	output reg [31:0] WriteDataW
	

);

always @(posedge clk) begin
	if (reset) begin
		ALUResultW <= 32'b0;
		ReadDataW  <= 32'b0;
		PCPlus4W   <= 32'b0;
		lAuiPCW    <= 32'b0;
		RdW        <= 5'b0;

		ResultSrcW <= 2'b0;
		RegWriteW  <= 1'b0;
		WriteDataW <= 32'b0;
	end
	else begin
		 ALUResultW <= ALUResultM;
		 ReadDataW  <= ReadDataM;
		 PCPlus4W   <= PCPlus4M;
		 lAuiPCW    <= lAuiPCM;
		 RdW        <= RdM;

		 ResultSrcW <= ResultSrcM;
		 RegWriteW  <= RegWriteM;
		 WriteDataW <= WriteDataM;
	end


end

endmodule
