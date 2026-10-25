
// datapath.v

module datapath (
	input         clk, reset,
	input  [1:0]  ResultSrc,
	input         ALUSrc, RegWrite, MemWrite,
	input  [1:0]  ImmSrc,
	input  [3:0]  ALUControl,
	input         Branch, Jump, Jalr,
	output [31:0] PC,
	input  [31:0] Instr,
	output [31:0] Mem_WrAddr, Mem_WrData,
	input  [31:0] ReadData,
	output [31:0] Result,
	output [31:0] PCW, ALUResultW, WriteDataW,
	output [31:0] InstrD,
	output MemWriteM,
	output [2:0] funct3M
);


// FETCH-STAGE SIGNALS

wire [31:0] PCNext, PCJalr, PCPlus4;
wire [31:0] PCTarget;
wire [31:0] AuiPCE, lAuiPCE;


// DECODE-STAGE SIGNALS

wire [31:0] PCD, PCPlus4D;
wire [31:0] RD1D, RD2D, ImmExtD;
wire [4:0] Rs1D, Rs2D, RdD;


// EXECUTE-STAGE SIGNALS
wire [31:0] PCE, PCPlus4E;
wire [31:0] RD1E, RD2E, ImmExtE, InstrE;
wire [4:0] Rs1E, Rs2E, RdE;

wire [31:0] SrcAE, SrcBE, ALUResultE;
wire [31:0] WriteDataE;
wire ZeroE, TakeBranchE;

wire [3:0] ALUControlE;
wire ALUSrcE, BranchE, JumpE, JalrE;
wire MemWriteE, RegWriteE;
wire [1:0] ResultSrcE;

// FORWARDING CONTROL SIGNALS
wire [1:0] ForwardAE;
wire [1:0] ForwardBE;

// Forwarded operand values
wire [31:0] ForwardedRD1E;
wire [31:0] ForwardedRD2E;

// Correct value available from the write-back stage
wire [31:0] ForwardResultW;


// MEMORY-STAGE SIGNALS


wire [31:0] ALUResultM;
wire [31:0] WriteDataM;
wire [31:0] PCPlus4M;
wire [31:0] lAuiPCM;
wire [31:0] ForwardResultM;

wire [4:0] RdM;


wire [1:0] ResultSrcM;

wire RegWriteM;




// WRITEBACK-STAGE SIGNALS


wire [31:0] ALUResultW_internal;
wire [31:0] ReadDataW;
wire [31:0] PCPlus4W;
wire [31:0] lAuiPCW;

wire [4:0] RdW;

wire [1:0] ResultSrcW;
wire RegWriteW;



// EXISTING DATAPATH SIGNALS
// Temporarily retained while we migrate the logic.

wire [31:0] ImmExt, SrcA, SrcB;
wire [31:0] WriteData, ALUResult;
wire Zero, TakeBranch;


// EXECUTE-STAGE PC CONTROL


wire PCSrcE;
wire [31:0] JalrTargetE;

assign PCSrcE = (BranchE && TakeBranchE) || JumpE || JalrE;

// JALR target: (rs1 + immediate) with bit 0 cleared
assign JalrTargetE = {ALUResultE[31:1], 1'b0};

// Select sequential PC or branch/jump target
mux2 #(32) pcmux (
	PCPlus4,
	PCTarget,
	PCSrcE,
	PCNext
);

// JALR uses its ALU-calculated target
mux2 #(32) jalrmux (
	PCNext,
	JalrTargetE,
	JalrE,
	PCJalr
);


// Hazard-control signals
wire StallF;
wire StallD;
wire FlushD;
wire FlushE;

// Program counter register
reset_ff #(32) pcreg(clk, reset, StallF, PCJalr, PC);
adder          pcadd4(PC, 32'd4, PCPlus4);

// Pipeline Register 1 -> Fetch | Decode


pl_reg_fd plfd (
    clk,
    StallD,
    FlushD,
    Instr,
    PC,
    PCPlus4,
    InstrD,
    PCD,
    PCPlus4D
);

adder pcaddbranch(PCE, ImmExtE, PCTarget);

// Decode-stage register addresses
assign Rs1D = InstrD[19:15];
assign Rs2D = InstrD[24:20];
assign RdD  = InstrD[11:7];

// Register file: read operands using the Decode-stage instruction
reg_file rf (
	clk,
	RegWriteW,
	Rs1D,
	Rs2D,
	RdW,
	Result,
	RD1D,
	RD2D
);

// Immediate generation for the Decode-stage instruction
imm_extend ext (
    InstrD[31:7],
    InstrD[6:0],
    ImmSrc,
    ImmExtD
);


// Pipeline Register 2 -> Decode | Execute

pl_reg_de plde (
    .clk(clk),
    .reset(reset),
    .FlushE(FlushE),

    .InstrD(InstrD),
    .RD1D(RD1D),
    .RD2D(RD2D),
    .ImmExtD(ImmExtD),
    .PCD(PCD),
    .PCPlus4D(PCPlus4D),

    .Rs1D(Rs1D),
    .Rs2D(Rs2D),
    .RdD(RdD),

    .ALUControlD(ALUControl),
    .ALUSrcD(ALUSrc),
    .BranchD(Branch),
    .JumpD(Jump),
    .JalrD(Jalr),
    .MemWriteD(MemWrite),
    .RegWriteD(RegWrite),
    .ResultSrcD(ResultSrc),

    .InstrE(InstrE),
    .RD1E(RD1E),
    .RD2E(RD2E),
    .ImmExtE(ImmExtE),
    .PCE(PCE),
    .PCPlus4E(PCPlus4E),

    .Rs1E(Rs1E),
    .Rs2E(Rs2E),
    .RdE(RdE),

    .ALUControlE(ALUControlE),
    .ALUSrcE(ALUSrcE),
    .BranchE(BranchE),
    .JumpE(JumpE),
    .JalrE(JalrE),
    .MemWriteE(MemWriteE),
    .RegWriteE(RegWriteE),
    .ResultSrcE(ResultSrcE)
);


// EXECUTE STAGE

// Select the correct value for source register 1
mux4 #(32) forwardAMux (
    RD1E,
    ForwardResultW,
    ForwardResultM,
    32'b0,
    ForwardAE,
    ForwardedRD1E
);

mux4 #(32) forwardBMux (
    RD2E,
    ForwardResultW,
    ForwardResultM,
    32'b0,
    ForwardBE,
    ForwardedRD2E
);
// ALU operand A receives the forwarded value
assign SrcAE = ForwardedRD1E;

// ALU operand B selects forwarded register data or immediate
mux2 #(32) srcbmuxE (
    ForwardedRD2E,
    ImmExtE,
    ALUSrcE,
    SrcBE
);

// Store instructions need the forwarded register data
assign WriteDataE = ForwardedRD2E;



// Existing ALU, now driven by Execute-stage signals
alu aluE (
    .a(SrcAE),
    .b(SrcBE),
    .alu_ctrl(ALUControlE),
    .alu_out(ALUResultE),
    .zero(ZeroE)
);

// AUIPC result = instruction PC + upper immediate
assign AuiPCE = PCE + ImmExtE;

// LUI result = upper immediate
// AUIPC and LUI are distinguished by opcode bit InstrE[5]
assign lAuiPCE = InstrE[5] ? ImmExtE : AuiPCE;


// Branch decision using the Execute-stage instruction
branching_unit buE (
InstrE[14:12],
ZeroE,
ALUResultE[31],
TakeBranchE
);


// Pipeline Register 3 -> Execute | Memory

pl_reg_em plem (
    .clk(clk),
    .reset(reset),

    // Execute-stage data
    .ALUResultE(ALUResultE),
    .WriteDataE(WriteDataE),
    .PCPlus4E(PCPlus4E),
    .lAuiPCE(lAuiPCE),
    .RdE(RdE),
    .funct3E(InstrE[14:12]),

    // Execute-stage control
    .ResultSrcE(ResultSrcE),
    .MemWriteE(MemWriteE),
    .RegWriteE(RegWriteE),

    // Memory-stage data
    .ALUResultM(ALUResultM),
    .WriteDataM(WriteDataM),
    .PCPlus4M(PCPlus4M),
    .lAuiPCM(lAuiPCM),
    .RdM(RdM),
    .funct3M(funct3M),

    // Memory-stage control
    .ResultSrcM(ResultSrcM),
    .MemWriteM(MemWriteM),
    .RegWriteM(RegWriteM)
);

// Select the correct result for forwarding from Memory stage
mux4 #(32) forwardResultMMux (
    ALUResultM,
    ReadData,
    PCPlus4M,
    lAuiPCM,
    ResultSrcM,
    ForwardResultM
);

// Pipeline Register 4 -> Memory | Writeback

pl_reg_mw plmw (
	.clk(clk),
	.reset(reset),

	// Memory-stage data
	.ALUResultM(ALUResultM),
	.ReadDataM(ReadData),
	.PCPlus4M(PCPlus4M),
	.lAuiPCM(lAuiPCM),
	.RdM(RdM),

	// Memory-stage control
	.ResultSrcM(ResultSrcM),
	.RegWriteM(RegWriteM),

	// Writeback-stage data
	.ALUResultW(ALUResultW_internal),
	.ReadDataW(ReadDataW),
	.PCPlus4W(PCPlus4W),
	.lAuiPCW(lAuiPCW),
	.RdW(RdW),

	// Writeback-stage control
	.ResultSrcW(ResultSrcW),
	.RegWriteW(RegWriteW),
	.WriteDataM(WriteDataM),
   .WriteDataW(WriteDataW)

);



// WRITEBACK STAGE

mux4 #(32) resultmux (
	ALUResultW_internal,
	ReadDataW,
	PCPlus4W,
	lAuiPCW,
	ResultSrcW,
	Result
);

assign ForwardResultW = Result;
// hazard unit

// Hazard detection and forwarding control
hazard_unit hu (
    .InstrD(InstrD),

    .Rs1D(Rs1D),
    .Rs2D(Rs2D),

    .Rs1E(Rs1E),
    .Rs2E(Rs2E),
    .RdE(RdE),
    .OpcodeE(InstrE[6:0]),

    .RdM(RdM),
    .RdW(RdW),

    .RegWriteM(RegWriteM),
    .RegWriteW(RegWriteW),
    .ResultSrcE0(ResultSrcE == 2'b01),
    .PCSrcE(PCSrcE),

    .ForwardAE(ForwardAE),
    .ForwardBE(ForwardBE),

    .StallF(StallF),
    .StallD(StallD),
    .FlushD(FlushD),
	 
	 
    .FlushE(FlushE)
);

assign Mem_WrData = WriteDataM;
assign Mem_WrAddr = ALUResultM;

// eventually this statements will be removed while adding pipeline registers
assign PCW        = PCPlus4W - 32'd4;
assign ALUResultW = ALUResultW_internal;


endmodule
