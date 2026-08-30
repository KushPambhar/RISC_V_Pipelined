module EX_MEM(input clk, input reset ,input [31:0] pc_ex, input [31:0] pc_4_ex, input [31:0] instruction_ex,

            // 
            input [31:0] ReadData2_ex,
            //control lines
            input Branch_ex, input MemRead_ex, input MemWrite_ex, //MEM
            input RegWrite_ex, input MemtoReg_ex, //WB

            //
            input [31:0] pc_branch_ex, input [31:0] ALUOut_ex, input zero_ex,input lt_ex, input ltu_ex,


            output reg [31:0] pc_mem, output reg [31:0] pc_4_mem, output reg [31:0] instruction_mem,
            // 
            output reg [31:0] ReadData2_mem,

            //control lines
            output reg Branch_mem, output reg MemRead_mem, output reg MemWrite_mem, //MEM
            output reg RegWrite_mem, output reg MemtoReg_mem, //WB

            //
            output reg [31:0] pc_branch_mem, output reg [31:0] ALUOut_mem, output reg zero_mem , output reg lt_mem , output reg ltu_mem

            );

            always @(posedge clk or posedge reset) begin
                if(reset) begin
                    pc_mem         <= 32'b0;
                    pc_4_mem       <= 32'b0;
                    instruction_mem<= 32'b0;

                    ReadData2_mem  <= 32'b0;

                    Branch_mem     <= 1'b0;
                    MemRead_mem    <= 1'b0;
                    MemWrite_mem   <= 1'b0;
                    RegWrite_mem   <= 1'b0;
                    MemtoReg_mem   <= 1'b0;

                    pc_branch_mem  <= 32'b0;
                    ALUOut_mem     <= 32'b0;
                    zero_mem       <= 1'b0;
                    lt_mem         <= 1'b0;
                    ltu_mem        <= 1'b0;
                end
                else begin
                    pc_mem         <= pc_ex;
                    pc_4_mem       <= pc_4_ex;
                    instruction_mem<= instruction_ex;

                    ReadData2_mem  <= ReadData2_ex;

                    Branch_mem     <= Branch_ex;
                    MemRead_mem    <= MemRead_ex;
                    MemWrite_mem   <= MemWrite_ex;
                    RegWrite_mem   <= RegWrite_ex;
                    MemtoReg_mem   <= MemtoReg_ex;

                    pc_branch_mem  <= pc_branch_ex;
                    ALUOut_mem     <= ALUOut_ex;
                    zero_mem       <= zero_ex;
                    lt_mem         <= lt_ex;
                    ltu_mem        <= ltu_ex;
                end
            end
endmodule
