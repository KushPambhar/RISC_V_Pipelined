module MEM_WB(input clk, input reset, input [31:0] instruction_mem,
            //control lines
            input RegWrite_mem, input MemtoReg_mem, //WB
            //
            input [31:0] ALUOut_mem,
            //
            input [31:0] DataMemOut_mem,
            //
            output reg [31:0] instruction_wb,
            //control lines
            output reg RegWrite_wb, output reg MemtoReg_wb, //WB
            //
            output reg [31:0] ALUOut_wb,
            //
            output reg [31:0] DataMemOut_wb
            );

            always @(posedge clk or posedge reset) begin
                if(reset) begin
                    instruction_wb <= 32'b0;

                    RegWrite_wb    <= 1'b0;
                    MemtoReg_wb    <= 1'b0;

                    ALUOut_wb      <= 32'b0;

                    DataMemOut_wb  <= 32'b0;
                end
                else begin
                    instruction_wb <= instruction_mem;

                    RegWrite_wb    <= RegWrite_mem;
                    MemtoReg_wb    <= MemtoReg_mem;

                    ALUOut_wb      <= ALUOut_mem;

                    DataMemOut_wb  <= DataMemOut_mem;
                end
            end
endmodule