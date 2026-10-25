
module hazard_unit (
    input  [31:0] InstrD,

    input  [4:0] Rs1D,
    input  [4:0] Rs2D,

    input  [4:0] Rs1E,
    input  [4:0] Rs2E,
    input  [4:0] RdE,
    input  [6:0] OpcodeE,

    input  [4:0] RdM,
    input  [4:0] RdW,

    input        RegWriteM,
    input        RegWriteW,
    input        ResultSrcE0,
    input        PCSrcE,

    output reg [1:0] ForwardAE,
    output reg [1:0] ForwardBE,

    output reg StallF,
    output reg StallD,
    output reg FlushD,
    output reg FlushE
);

reg UsesRs1D;
reg UsesRs2D;

always @(*) begin
    UsesRs1D = 1'b0;
    UsesRs2D = 1'b0;

    case (InstrD[6:0])
        7'b0110011: begin // R-type
            UsesRs1D = 1'b1;
            UsesRs2D = 1'b1;
        end

        7'b0010011: begin // I-type arithmetic
            UsesRs1D = 1'b1;
        end

        7'b0000011: begin // Load
            UsesRs1D = 1'b1;
        end

        7'b0100011: begin // Store
            UsesRs1D = 1'b1;
            UsesRs2D = 1'b1;
        end

        7'b1100011: begin // Branch
            UsesRs1D = 1'b1;
            UsesRs2D = 1'b1;
        end

        7'b1100111: begin // JALR
            UsesRs1D = 1'b1;
        end

        default: begin
            UsesRs1D = 1'b0;
            UsesRs2D = 1'b0;
        end
    endcase
end

always @(*) begin
    ForwardAE = 2'b00;
    ForwardBE = 2'b00;

    StallF = 1'b0;
    StallD = 1'b0;
    FlushD = 1'b0;
    FlushE = 1'b0;

    // Forwarding priority: Memory stage before Write-back stage
    if (RegWriteM && (RdM != 5'd0) && (RdM == Rs1E))
        ForwardAE = 2'b10;
    else if (RegWriteW && (RdW != 5'd0) && (RdW == Rs1E))
        ForwardAE = 2'b01;

    if (RegWriteM && (RdM != 5'd0) && (RdM == Rs2E))
        ForwardBE = 2'b10;
    else if (RegWriteW && (RdW != 5'd0) && (RdW == Rs2E))
        ForwardBE = 2'b01;

    // Load-use hazard
    if (ResultSrcE0 && (RdE != 5'd0) &&
        ((UsesRs1D && (RdE == Rs1D)) ||
         (UsesRs2D && (RdE == Rs2D)))) begin
        StallF = 1'b1;
        StallD = 1'b1;
        FlushE = 1'b1;
    end

    // A taken branch or jump flushes younger instructions
    if (PCSrcE) begin
        FlushD = 1'b1;
        FlushE = 1'b1;
    end
end

endmodule

