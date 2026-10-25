
// data_mem.v - data memory

module data_mem #(
    parameter DATA_WIDTH = 32,
    ADDR_WIDTH = 32,
    MEM_SIZE = 16
) (
    input clk,
    input wr_en,
    input [2:0] funct3,
    input [ADDR_WIDTH-1:0] wr_addr,
    input [DATA_WIDTH-1:0] wr_data,
    output reg [DATA_WIDTH-1:0] rd_data_mem
);

    // Array of 32-bit data words
    reg [DATA_WIDTH-1:0] data_ram [0:MEM_SIZE-1];

    // Word address derived from byte address
    wire [$clog2(MEM_SIZE)-1:0] word_addr =
        wr_addr[$clog2(MEM_SIZE)+1:2];

    // Synchronous write logic
    always @(posedge clk) begin
        if (wr_en) begin
            case (funct3)

                // SB: Store byte
                3'b000: begin
                    case (wr_addr[1:0])
                        2'b00: data_ram[word_addr][7:0]   <= wr_data[7:0];
                        2'b01: data_ram[word_addr][15:8]  <= wr_data[7:0];
                        2'b10: data_ram[word_addr][23:16] <= wr_data[7:0];
                        2'b11: data_ram[word_addr][31:24] <= wr_data[7:0];
                    endcase
                end

                // SH: Store halfword
                3'b001: begin
                    case (wr_addr[1])
                        1'b0: data_ram[word_addr][15:0]  <= wr_data[15:0];
                        1'b1: data_ram[word_addr][31:16] <= wr_data[15:0];
                    endcase
                end

                // SW: Store word
                3'b010: begin
                    data_ram[word_addr] <= wr_data;
                end

                default: begin
                    // No write for unsupported funct3
                end

            endcase
        end
    end

    // Combinational read logic
    always @(*) begin
        case (funct3)

            // LB: Load byte, sign-extended
            3'b000: begin
                case (wr_addr[1:0])
                    2'b00: rd_data_mem = {{24{data_ram[word_addr][7]}},   data_ram[word_addr][7:0]};
                    2'b01: rd_data_mem = {{24{data_ram[word_addr][15]}},  data_ram[word_addr][15:8]};
                    2'b10: rd_data_mem = {{24{data_ram[word_addr][23]}},  data_ram[word_addr][23:16]};
                    2'b11: rd_data_mem = {{24{data_ram[word_addr][31]}},  data_ram[word_addr][31:24]};
                endcase
            end

            // LH: Load halfword, sign-extended
            3'b001: begin
                case (wr_addr[1])
                    1'b0: rd_data_mem = {{16{data_ram[word_addr][15]}}, data_ram[word_addr][15:0]};
                    1'b1: rd_data_mem = {{16{data_ram[word_addr][31]}}, data_ram[word_addr][31:16]};
                endcase
            end

            // LW: Load word
            3'b010: begin
                rd_data_mem = data_ram[word_addr];
            end

            // LBU: Load byte, zero-extended
            3'b100: begin
                case (wr_addr[1:0])
                    2'b00: rd_data_mem = {24'b0, data_ram[word_addr][7:0]};
                    2'b01: rd_data_mem = {24'b0, data_ram[word_addr][15:8]};
                    2'b10: rd_data_mem = {24'b0, data_ram[word_addr][23:16]};
                    2'b11: rd_data_mem = {24'b0, data_ram[word_addr][31:24]};
                endcase
            end

            // LHU: Load halfword, zero-extended
            3'b101: begin
                case (wr_addr[1])
                    1'b0: rd_data_mem = {16'b0, data_ram[word_addr][15:0]};
                    1'b1: rd_data_mem = {16'b0, data_ram[word_addr][31:16]};
                endcase
            end

            default: begin
                rd_data_mem = 32'b0;
            end

        endcase
    end

endmodule

