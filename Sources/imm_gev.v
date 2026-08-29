module immgen(instruction,offset);
    input [31:0] instruction;
    output reg [31:0] offset;
    wire [ 6:0] opcode = instruction[6:0];

    always@(*) begin 
        case (opcode)
            7'b0000011 : offset ={{20{instruction[31]}},instruction[31:20]}; // I type (Load Type instr.)
            7'b0010011 : offset ={{20{instruction[31]}},instruction[31:20]}; // I type (Immediate Type instr.)
            7'b0100011 : offset = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; // S Type
            7'b1100011 : offset = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8],1'b0}; // B Type
            7'b0110111 : offset = {instruction[31:12], {12{1'b0}}}; // Utype (LUI)
            7'b0010111 : offset = {instruction[31:12], {12{1'b0}}}; // Utype (AUIPC)
            // 7'b1101111 : offset = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21],1'b0}; // J Type (JAL)
            // 7'b1100111 : offset ={{20{instruction[31]}},instruction[31:20]}; // IJALR
            default : offset = 32'b0; 
        endcase
    end

endmodule
