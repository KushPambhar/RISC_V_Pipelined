module control(
    input      [6:0] opcode,
    output reg RegWrite,
    output reg MemWrite,
    output reg MemRead,
    output reg MemtoReg,
    output reg Branch,
    output reg  ALUSrcA,      // 0 = rs2, 1 = immediate  -> ALU input B
    output reg [1:0] ALUSrcB,     // 0 = rs1, 1 = PC, 2 = 0   -> ALU input A
    output reg [1:0]  ALUOp        // coarse op class, refined by alu_control
);
    always @(*) begin
        // ---- safe defaults (also covers illegal/unsupported opcode) ----
        RegWrite  = 1'b0;
        MemWrite  = 1'b0;
        Branch    = 1'b0;
        MemRead   = 1'b0;
        MemtoReg  = 1'b0;
        ALUSrcA   = 1'b0;
        ALUSrcB   = 2'b00;
        ALUOp     = 2'b00;

        case (opcode)

            // ---------------- LOAD: LB/LH/LW/LBU/LHU ----------------
            7'b0000011: begin
                RegWrite  = 1'b1;
                MemWrite  = 1'b0;
                Branch    = 1'b0;
                MemRead   = 1'b1;
                MemtoReg  = 1'b1;
                ALUSrcA   = 1'b1;
                ALUSrcB   = 2'b00;
                ALUOp     = 2'b00; //to be updated
            end

            // ---------------- STORE: SB/SH/SW ----------------
            7'b0100011: begin
                RegWrite  = 1'b0;
                MemWrite  = 1'b1;
                Branch    = 1'b0;
                MemRead   = 1'b0;
                MemtoReg  = 1'b0;
                ALUSrcA   = 1'b1;
                ALUSrcB   = 2'b00;
                ALUOp     = 2'b00;
            end

            // ---------------- BRANCH: BEQ/BNE/BLT/BGE/BLTU/BGEU ----------------
            7'b1100011: begin
                RegWrite  = 1'b0;
                MemWrite  = 1'b0;
                Branch    = 1'b1;
                MemRead   = 1'b0;
                MemtoReg  = 1'b0;
                ALUSrcA   = 1'b0;
                ALUSrcB   = 2'b00;
                ALUOp     = 2'b01;    // subtract/compare
            end

            // ---------------- I-TYPE ALU: ADDI/SLTI/.../SRAI ----------------
            7'b0010011: begin
                RegWrite  = 1'b1;
                MemWrite  = 1'b0;
                Branch    = 1'b0;
                MemRead   = 1'b0;
                MemtoReg  = 1'b0;
                ALUSrcA   = 1'b1;
                ALUSrcB   = 2'b00;
                ALUOp     = 2'b11;
            end

            // ---------------- R-TYPE ALU: ADD/SUB/.../AND ----------------
            7'b0110011: begin
                RegWrite  = 1'b1;
                MemWrite  = 1'b0;
                Branch    = 1'b0;
                MemRead   = 1'b0;
                MemtoReg  = 1'b0;
                ALUSrcA   = 1'b0;
                ALUSrcB   = 2'b00;
                ALUOp     = 2'b10;
            end

            // ---------------- LUI ----------------
            7'b0110111: begin
                RegWrite  = 1'b1;
                MemWrite  = 1'b0;
                Branch    = 1'b0;
                MemRead   = 1'b0;
                MemtoReg  = 1'b0;
                ALUSrcA   = 1'b0;
                ALUSrcB   = 2'b01;
                ALUOp     = 2'b00;
            end

            // ---------------- AUIPC ----------------
            7'b0010111: begin
                RegWrite  = 1'b1;
                MemWrite  = 1'b0;
                Branch    = 1'b0;
                MemRead   = 1'b0;
                MemtoReg  = 1'b0;
                ALUSrcA   = 1'b0;
                ALUSrcB   = 2'b10;
                ALUOp     = 2'b00;
            end

            // ---------------- JAL ----------------
            // 7'b1101111: begin
            //     RegWrite  = 1'b1;
            //     Jump      = 1'b1;
            //     ResultSrc = 2'b10;     // write back PC+4
            //     ImmSrc    = 3'b100;    // J-type imm
            //     // target = PC + imm, computed via PC-adder, not main ALU
            // end

            // // ---------------- JALR ----------------
            // 7'b1100111: begin
            //     RegWrite  = 1'b1;
            //     Jump      = 1'b1;
            //     ALUSrc    = 1'b1;      // rs1 + imm
            //     ALUSrcA   = 2'b00;     // A = rs1
            //     ResultSrc = 2'b10;     // write back PC+4
            //     ImmSrc    = 3'b000;    // I-type imm
            //     ALUOp     = 2'b00;     // add -> target address
            // end

            
        endcase
    end
endmodule
