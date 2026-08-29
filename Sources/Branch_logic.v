module branch_logic(
    input [2:0] funct3,
    input zero, lt, ltu,
    output reg branch_taken
);
    always @(*) begin
        case(funct3)
            3'b000: branch_taken = zero;     // BEQ
            3'b001: branch_taken = ~zero;    // BNE
            3'b100: branch_taken = lt;       // BLT
            3'b101: branch_taken = ~lt;      // BGE
            3'b110: branch_taken = ltu;      // BLTU
            3'b111: branch_taken = ~ltu;     // BGEU
            default: branch_taken = 1'b0;
        endcase
    end
endmodule
