// branching_unit.v - Branch condition logic for Execute stage

module branching_unit (
input [2:0] funct3,
input       Zero,
input       ALUR31,
output reg  Branch
);

always @(*) begin
case (funct3)

    3'b000: Branch =  Zero;   // BEQ
    3'b001: Branch = ~Zero;  // BNE

    3'b100: Branch = ~Zero;  // BLT: signed less than
    3'b101: Branch =  Zero;  // BGE: signed greater/equal

    3'b110: Branch = ~Zero;  // BLTU: unsigned less than
    3'b111: Branch =  Zero;  // BGEU: unsigned greater/equal

    default: Branch = 1'b0;

endcase


end

endmodule
