module ALUControl (
    input  [1:0] ALUOp,
    input  [2:0] funct3,
    input        funct7_5,     // bit 30 of instruction (funct7[5])
    output reg [3:0] ALUControl
);
    always @(*) begin
        case (ALUOp)
            2'b00: ALUControl = 4'b0000;  // LW/SW/JALR -> ADD

            2'b01: begin // Branch -> depends on funct3
                case (funct3)
                    3'b000: ALUControl = 4'b0001; // BEQ  -> SUB (uses Zero)
                    3'b001: ALUControl = 4'b0001; // BNE  -> SUB (uses Zero)
                    3'b100: ALUControl = 4'b1000; // BLT  -> SLT (uses LT)
                    3'b101: ALUControl = 4'b1000; // BGE  -> SLT (uses LT)
                    3'b110: ALUControl = 4'b1001; // BLTU -> SLTU (uses LTU)
                    3'b111: ALUControl = 4'b1001; // BGEU -> SLTU (uses LTU)
                    default: ALUControl = 4'b0001; // safe default: SUB
                endcase
            end

            2'b10: begin // R-type: use funct3 + funct7
                case (funct3)
                    3'b000: ALUControl = funct7_5 ? 4'b0001 : 4'b0000; // SUB : ADD
                    3'b001: ALUControl = 4'b0101; // SLL
                    3'b010: ALUControl = 4'b1000; // SLT
                    3'b011: ALUControl = 4'b1001; // SLTU
                    3'b100: ALUControl = 4'b0100; // XOR
                    3'b101: ALUControl = funct7_5 ? 4'b0111 : 4'b0110; // SRA : SRL
                    3'b110: ALUControl = 4'b0011; // OR
                    3'b111: ALUControl = 4'b0010; // AND
                    default: ALUControl = 4'b0000;
                endcase
            end

            2'b11: begin // I-type ALU: use funct3 (funct7 only for shifts)
                case (funct3)
                    3'b000: ALUControl = 4'b0000; // ADDI
                    3'b010: ALUControl = 4'b1000; // SLTI
                    3'b011: ALUControl = 4'b1001; // SLTIU
                    3'b100: ALUControl = 4'b0100; // XORI
                    3'b110: ALUControl = 4'b0011; // ORI
                    3'b111: ALUControl = 4'b0010; // ANDI
                    3'b001: ALUControl = 4'b0101; // SLLI
                    3'b101: ALUControl = funct7_5 ? 4'b0111 : 4'b0110; // SRAI : SRLI
                    default: ALUControl = 4'b0000;
                endcase
            end

            default: ALUControl = 4'b0000;
        endcase
    end
endmodule
