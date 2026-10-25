
module forwarding_unit (
    input  [4:0] Rs1E,
    input  [4:0] Rs2E,
    input  [4:0] RdM,
    input  [4:0] RdW,
    input        RegWriteM,
    input        RegWriteW,

    output reg [1:0] ForwardAE,
    output reg [1:0] ForwardBE
);

always @(*) begin
    // Default: use operands from the ID/EX pipeline register
    ForwardAE = 2'b00;
    ForwardBE = 2'b00;

    // Forward operand A from the Memory stage
    if (RegWriteM && (RdM != 5'd0) && (RdM == Rs1E))
        ForwardAE = 2'b10;

    // Forward operand A from the Write-Back stage
    else if (RegWriteW && (RdW != 5'd0) && (RdW == Rs1E))
        ForwardAE = 2'b01;

    // Forward operand B from the Memory stage
    if (RegWriteM && (RdM != 5'd0) && (RdM == Rs2E))
        ForwardBE = 2'b10;

    // Forward operand B from the Write-Back stage
    else if (RegWriteW && (RdW != 5'd0) && (RdW == Rs2E))
        ForwardBE = 2'b01;
end

endmodule

