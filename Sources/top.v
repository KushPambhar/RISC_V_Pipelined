module top(input clk, input reset);
    wire [31:0] pc_in, pc_out;
    wire [31:0] Instruction;
    wire [31:0] pc_next;

    wire [31:0] pc_if_id, pc_next_if_id, Instruction_if_id;

    wire Branch, MemRead, MemtoReg, MemWrite, AluSrcB, RegWrite;
    wire [1:0] AluOP, AluSrcA;
    wire [31:0] ReadData1, ReadData2;
    wire [31:0] Imm_Gen_Out;

    wire [31:0] pc_id_ex, pc_next_id_ex, Instruction_id_ex;
    wire [31:0] ReadData1_id_ex, ReadData2_id_ex, Imm_Gen_Out_id_ex;
    wire [1:0] AluOP_id_ex, AluSrcA_id_ex;
    wire Branch_id_ex, MemRead_id_ex, MemtoReg_id_ex, MemWrite_id_ex, AluSrcB_id_ex, RegWrite_id_ex;


    wire [3:0] AluControlOut;
    wire [31:0] SrcAOut, SrcBOut;
    wire [31:0] AluOut;
    wire zero, lt, ltu;

    wire [31:0] pc_ex_mem, pc_next_ex_mem, Instruction_ex_mem;
    wire [31:0]  ReadData2_ex_mem;
    wire Branch_ex_mem, MemRead_ex_mem, MemWrite_ex_mem ;
    wire RegWrite_ex_mem, MemtoReg_ex_mem ;
    wire [31:0] pc_branch_ex_mem, AluOut_ex_mem;
    wire zero_ex_mem, lt_ex_mem, ltu_ex_mem;

    wire branch_taken;
    wire branch_and;
    wire [31:0] pc_branch;
    wire [31:0] DataMemoryOut;

    wire [31:0] Instruction_mem_wb;
    wire RegWrite_mem_wb, MemtoReg_mem_wb;
    wire [31:0] AluOut_mem_wb, DataMemoryOut_mem_wb;

    wire [31:0] WriteData;

    //IF
    pc pc_inst(pc_in, clk, reset, pc_out);
    inst_mem imem_inst(pc_out, Instruction);
    adder a1(pc_out,32'd4,pc_next);
    
    //IF_ID
    IF_ID if_id(clk, reset, pc_out, pc_next,Instruction,pc_if_id, pc_next_if_id, Instruction_if_id);
    
    //ID
    reg_file rf_inst(clk,Instruction_if_id[19:15],Instruction_if_id[24:20],Instruction_if_id[11:7],WriteData,ReadData1,ReadData2,RegWrite_mem_wb); 
    immgen immgen_inst(Instruction_if_id,Imm_Gen_Out);
    control control_inst(Instruction_if_id[6:0],RegWrite,MemWrite,MemRead,MemtoReg,Branch,AluSrcB,AluSrcA,AluOP);
    
    //ID_EX
    ID_EX id_ex(clk, reset,
        pc_if_id, pc_next_if_id, Instruction_if_id,
        ReadData1,ReadData2,Imm_Gen_Out,
        AluOP, AluSrcA,AluSrcB,
        Branch,MemRead,MemWrite,
        RegWrite,MemtoReg,

        pc_id_ex, pc_next_id_ex, Instruction_id_ex,
        ReadData1_id_ex, ReadData2_id_ex, Imm_Gen_Out_id_ex,
        AluOP_id_ex, AluSrcA_id_ex, ALuSrcB_id_ex,
        Branch_id_ex, MemRead_id_ex,MemWrite_id_ex,
        RegWrite_id_ex, MemtoReg_id_ex, 
        )
    
    //EX
    adder a2(pc_out_id_ex,Imm_Gen_Out_id_ex,pc_branch);
    mux_4x1 mux4_srcA(ReadData1_id_ex,32'b0, pc_out_id_ex, 32'b0, AluSrcA_id_ex ,SrcAOut);
    mux_2x1 mux2_srcB(ReadData2_id_ex,Imm_Gen_Out_id_ex, AluSrcB_id_ex ,SrcBOut);
    ALUControl alu_ctrl_inst(AluOP_id_ex,Instruction_id_ex[14:12],Instruction_id_ex[30],AluControlOut);
    ALU alu_inst(SrcAOut,SrcBOut,AluControlOut, AluOut, zero, lt, ltu);

    //EX_MEM
    EX_MEM ex_mem(clk, reset,
        pc_id_ex, pc_next_id_ex, Instruction_id_ex,
        ReadData2_id_ex,
        Branch_id_ex, MemRead_id_ex,MemWrite_id_ex,
        RegWrite_id_ex, MemtoReg_id_ex,
        pc_branch,AluOut,zero,lt,ltu,

        pc_ex_mem, pc_next_ex_mem, Instruction_ex_mem;
        ReadData2_ex_mem;
        Branch_ex_mem, MemRead_ex_mem, MemWrite_ex_mem ;
        RegWrite_ex_mem, MemtoReg_ex_mem ;
        pc_branch_ex_mem, AluOut_ex_mem;
        zero_ex_mem, lt_ex_mem, ltu_ex_mem;
    )

    // MEM
    branch_logic branch_inst(Instruction_ex_mem[14:12],zero_ex_mem,lt_ex_mem,ltu_ex_mem,branch_taken);
    assign branch_and = branch_taken & Branch_ex_mem;
    mux_2x1 mux2_pcsel(pc_next,pc_branch_ex_mem, branch_and, pc_in);
    data_mem dmem_inst(AluOut_ex_mem,clk,ReadData2_ex_mem,DataMemoryOut,MemRead_ex_mem,MemWrite_ex_mem);

    //MEM_WB
    MEM_WB mem_wb(clk, reset, Instruction_ex_mem, 
    RegWrite_ex_mem, MemtoReg_ex_mem,
    AluOut_ex_mem,DataMemoryOut,

    Instruction_mem_wb;
    RegWrite_mem_wb, MemtoReg_mem_wb;
    [31:0] AluOut_mem_wb, DataMemoryOut_mem_wb;
    );

    mux_2x1 mux2_wb(AluOut_mem_wb,DataMemoryOut_mem_wb,MemtoReg_mem_wb,WriteData);

 
endmodule
