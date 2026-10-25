
module riscv_cpu (
	input         clk, reset,
	output [31:0] PC,
	input  [31:0] Instr,
	output        MemWrite,
	output [31:0] Mem_WrAddr, Mem_WrData,
	input  [31:0] ReadData,
	output [31:0] Result,
	output [2:0]  funct3,
	output [31:0] PCW, ALUResultW, WriteDataW
);

wire        ALUSrc, RegWrite, Branch, Jump, Jalr;
wire [1:0]  ResultSrc, ImmSrc;
wire [3:0]  ALUControl;
wire [31:0] InstrD;

wire MemWriteD;
wire MemWriteM;





controller c (
	InstrD[6:0],
	InstrD[14:12],
	InstrD[30],
	ResultSrc,
	MemWriteD,
	ALUSrc,
	RegWrite,
	Branch,
	Jump,
	Jalr,
	ImmSrc,
	ALUControl
);


datapath dp (
	.clk(clk),
	.reset(reset),

	
	.ResultSrc(ResultSrc),
	.ALUSrc(ALUSrc),
	.RegWrite(RegWrite),
	.MemWrite(MemWriteD),

	.ImmSrc(ImmSrc),
	.ALUControl(ALUControl),
	.Branch(Branch),
	.Jump(Jump),
	.Jalr(Jalr),

	.PC(PC),
	.Instr(Instr),

	.Mem_WrAddr(Mem_WrAddr),
	.Mem_WrData(Mem_WrData),
	.ReadData(ReadData),
	.Result(Result),

	.PCW(PCW),
	.ALUResultW(ALUResultW),
	.WriteDataW(WriteDataW),

	.InstrD(InstrD),
	.MemWriteM(MemWriteM),
	.funct3M(funct3)
	

);



// EXTERNAL OUTPUTS



assign MemWrite = MemWriteM;

endmodule
