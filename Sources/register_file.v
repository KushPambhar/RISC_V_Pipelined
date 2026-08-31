//32 General Purpose Reg. each 32 bits wide.

module reg_file(clk, rs1, rs2, rd, write , read_1, read_2 , regWrite);
    input clk, regWrite;
    input [4:0] rs1,rs2,rd;
    input [31:0] write;
    output [31:0] read_1,read_2;

    assign read_1 = (rs1 == 5'd0) ? 32'd0 :
                    (regWrite && rd == rs1) ? write : registers[rs1];
    assign read_2 = (rs2 == 5'd0) ? 32'd0 :
                    (regWrite && rd == rs2) ? write : registers[rs2];

    always @(posedge clk) begin 
        if(regWrite && rd != 5'd0)
            registers[rd]<=write;
    end
   

endmodule
