//32 General Purpose Reg. each 32 bits wide.

module reg_file(clk, rs1, rs2, rd, write , read_1, read_2 , regWrite);
    input clk, regWrite;
    input [4:0] rs1,rs2,rd;
    input [31:0] write;
    output [31:0] read_1,read_2;

    reg [31:0] registers [31:0];
    assign    read_1 =  registers[rs1];
    assign    read_2 = registers[rs2];

    always @(posedge clk) begin 
        if(regWrite)
            registers[rd]<=write;
    end
   

endmodule
