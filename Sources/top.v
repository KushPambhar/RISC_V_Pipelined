module top(input clk, input reset);
    wire [31:0] pc_in, pc_out;

    wire [31:0] Instruction;

    wire Branch, MemRead, MemtoReg, MemWrite, AluSrcB, RegWrite;
    wire [1:0] AluOP, AluSrcA;

    wire [31:0] ReadData1, ReadData2;

    wire [31:0] Imm_Gen_Out;

    wire [3:0] AluControlOut;

    wire [31:0] SrcAOut, SrcBOut;

    wire [31:0] AluOut;
    wire zero, lt, ltu;

    wire branch_taken;

    wire branch_and;

    wire [31:0] pc_branch;
    wire [31:0] pc_next;

    wire [31:0] DataMemoryOut;

    wire [31:0] WriteData;

    pc pc_inst(pc_in, clk, reset, pc_out);

    inst_mem imem_inst(pc_out, Instruction);

    reg_file rf_inst(clk,Instruction[19:15],Instruction[24:20],Instruction[11:7],WriteData,ReadData1,ReadData2,RegWrite);

    immgen immgen_inst(Instruction,Imm_Gen_Out);

    control control_inst(Instruction[6:0],RegWrite,MemWrite,MemRead,MemtoReg,Branch,AluSrcB,AluSrcA,AluOP);

    adder a1(pc_out,32'd4,pc_next);
    adder a2(pc_out,Imm_Gen_Out,pc_branch);

    mux_4x1 mux4_srcA(ReadData1,32'b0, pc_out, 32'b0, AluSrcA ,SrcAOut);
    mux_2x1 mux2_srcB(ReadData2,Imm_Gen_Out, AluSrcB ,SrcBOut);

    ALUControl alu_ctrl_inst(AluOP,Instruction[14:12],Instruction[30],AluControlOut);

    ALU alu_inst(SrcAOut,SrcBOut,AluControlOut, AluOut, zero, lt, ltu);

    branch_logic branch_inst(Instruction[14:12],zero,lt,ltu,branch_taken);

    assign branch_and = branch_taken & Branch;

    mux_2x1 mux2_pcsel(pc_next,pc_branch,branch_and, pc_in);

    data_mem dmem_inst(AluOut,clk,ReadData2,DataMemoryOut,MemRead,MemWrite);

    mux_2x1 mux2_wb(AluOut,DataMemoryOut,MemtoReg,WriteData);

 
endmodule
