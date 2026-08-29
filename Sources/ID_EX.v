module ID_EX(input clk, input reset ,input [31:0] pc_id, input [31:0] pc_4_id, input [31:0] instruction_id,
            input [31:0] ReadData1_id,input [31:0] ReadData2_id,input [31:0] ImmGenOut_id,

            //control lines
            input [1:0] AluOp_id, input [1:0]AluSrcA_id, input AluSrcB_id, // EX
            input Branch_id, input MemRead_id, input MemWrite_id, //MEM
            input RegWrite_id, input MemtoReg_id, //WB

            output reg [31:0] pc_ex, output reg [31:0] pc_4_ex, output reg [31:0] instruction_ex,
            output [31:0] ReadData1_ex,output [31:0] ReadData2_ex,output [31:0] ImmGenOut_ex,

            //control lines
            output [1:0] AluOp_ex, output [1:0]AluSrcA_ex, output AluSrcB_ex, // EX
            output Branch_ex, output MemRead_ex, output MemWrite_ex, //MEM
            output RegWrite_ex, output MemtoReg_ex, //WB
            );

            always @(posedge clk or posedge reset) begin
                if(reset) begin
                    pc_ex<=32'b0;
                    pc_4_ex<=32'b0;
                    instruction_ex <=32'b0;
                    ReadData1_ex <=32'b0;
                    ReadData2_ex <=32'b0;
                    ImmGenOut_ex <=32'b0;
                    AluOp_ex <= 2'b0;
                    AluSrcA_ex <= 2'b0;
                    AluSrcB_ex <= 1'b0;
                    Branch_ex <= 1'b0;
                    MemRead_ex <= 1'b0;
                    MemWrite_ex <= 1'b0;
                    RegWrite_ex <= 1'b0;
                    MemtoReg_ex <= 1'b0;
                end
                else begin
                    pc_ex<=pc_id;
                    pc_4_ex<=pc_4_id;
                    instruction_ex <= instruction_id;
                    ReadData1_ex   <= ReadData1_id;
                    ReadData2_ex   <= ReadData2_id;
                    ImmGenOut_ex   <= ImmGenOut_id;
                    AluOp_ex       <= AluOp_id;
                    AluSrcA_ex     <= AluSrcA_id;
                    AluSrcB_ex     <= AluSrcB_id;
                    Branch_ex      <= Branch_id;
                    MemRead_ex     <= MemRead_id;
                    MemWrite_ex    <= MemWrite_id;
                    RegWrite_ex    <= RegWrite_id;
                    MemtoReg_ex    <= MemtoReg_id;
                end
            end
endmodule;