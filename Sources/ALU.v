module ALU (
    input  [31:0] A, B,        // operands (rs1, rs2/imm)
    input  [3:0]  ALUControl,  // operation selector from ALU Control unit
    output reg [31:0] Result,
    output        Zero,         // for branches (BEQ/BNE)
    output        LT,          // NEW: signed less-than, for BLT/BGE
    output        LTU          // NEW: unsigned less-than, for BLTU/BGEU

);

    always @(*) begin
        case (ALUControl)
            4'b0000: Result = A + B;                     // ADD / ADDI / LW/SW/JALR addr
            4'b0001: Result = A - B;                     // SUB (also used for SLT compare)
            4'b0010: Result = A & B;                     // AND / ANDI
            4'b0011: Result = A | B;                     // OR  / ORI
            4'b0100: Result = A ^ B;                      // XOR / XORI
            4'b0101: Result = A << B[4:0];                // SLL / SLLI (Shift Left Logical)
            4'b0110: Result = A >> B[4:0];                 // SRL / SRLI (Shift Right Logical)
            4'b0111: Result = $signed(A) >>> B[4:0];       // SRA / SRAI (arithmetic)
            4'b1000: Result = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0; // SLT/SLTI (set less than, signed)
            4'b1001: Result = (A < B) ? 32'b1 : 32'b0;      // SLTU / SLTIU (set less than, unsigned)
            4'b1010: Result = B;                            // LUI passthrough
            default: Result = 32'b0;
        endcase
    end

    assign Zero = (Result == 32'b0);  // used by BEQ/BNE
    assign LT   = ($signed(A) < $signed(B));  // NEW: always computed, for BLT/BGE
    assign LTU  = (A < B);                     // NEW: always computed, for BLTU/BGEU


endmodule
