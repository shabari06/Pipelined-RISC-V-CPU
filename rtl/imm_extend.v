
// imm_extend.v - logic for immediate generation

module imm_extend (
    input  [31:7] instr,
    input  [6:0]  op,
    input  [1:0]  immsrc,
    output reg [31:0] immext
);

always @(*) begin
    case (immsrc)

        // I-type: ADDI, loads, JALR
        2'b00:
            immext = {{20{instr[31]}}, instr[31:20]};

        // S-type: SB, SH, SW
        2'b01:
            immext = {{20{instr[31]}}, instr[31:25],
                      instr[11:7]};

        // B-type: BEQ, BNE, BLT, BGE, BLTU, BGEU
        2'b10:
            immext = {{19{instr[31]}}, instr[31], instr[7],
                      instr[30:25], instr[11:8], 1'b0};

        // J-type: JAL; U-type: LUI, AUIPC
        2'b11: begin
            if (op == 7'b1101111)
                immext = {{11{instr[31]}}, instr[31],
                          instr[19:12], instr[20],
                          instr[30:21], 1'b0};
            else
                immext = {instr[31:12], 12'b0};
        end

        default:
            immext = 32'b0;

    endcase
end

endmodule
