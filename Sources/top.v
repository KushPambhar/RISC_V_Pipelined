module top(input clk, input reset);
    wire [31:0] pc_in, pc_out;
    wire [31:0] Instruction;
    wire [31:0] pc_next;
    wire PcWrite;

    wire [31:0] pc_if_id, pc_next_if_id, Instruction_if_id;
    wire IF_ID_Write;
    wire stall;

    wire Branch, MemRead, MemtoReg, MemWrite, AluSrcB, RegWrite;
    wire [1:0] AluOP, AluSrcA;
    wire [31:0] ReadData1, ReadData2;
    wire [31:0] Imm_Gen_Out;

    wire [31:0] pc_id_ex, pc_next_id_ex, Instruction_id_ex;
    wire [31:0] ReadData1_id_ex, ReadData2_id_ex, Imm_Gen_Out_id_ex;
    wire [1:0] AluOP_id_ex, AluSrcA_id_ex;
    wire Branch_id_ex, MemRead_id_ex, MemtoReg_id_ex, MemWrite_id_ex, AluSrcB_id_ex, RegWrite_id_ex;

    wire [1:0] forward_a, forward_b;
    wire [31:0] ReadData1_fwd_a, ReadData2_fwd_b;

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
    pc pc_inst(pc_in, clk, reset, PcWrite, pc_out);
    inst_mem imem_inst(pc_out, Instruction);
    adder a1(pc_out,32'd4,pc_next);
    
    //IF_ID
    IF_ID if_id(clk, reset, pc_out, pc_next,Instruction,IF_ID_Write,pc_if_id, pc_next_if_id, Instruction_if_id);

    //Hazard-detection
    hazard_detection hazard_inst(Instruction_if_id[19:15],Instruction_if_id[24:20],Instruction_id_ex[11:7],MemRead_id_ex,RegWrite_ex_mem,PcWrite,IF_ID_Write,stall);
    
    //ID
    reg_file rf_inst(clk,Instruction_if_id[19:15],Instruction_if_id[24:20],Instruction_mem_wb[11:7],WriteData,ReadData1,ReadData2,RegWrite_mem_wb); 
    immgen immgen_inst(Instruction_if_id,Imm_Gen_Out);
    control control_inst(Instruction_if_id[6:0],RegWrite,MemWrite,MemRead,MemtoReg,Branch,AluSrcB,AluSrcA,AluOP);
    
    //control_mux
    assign RegWrite_id_ex = stall ? 0 : RegWrite;
    assign MemWrite_id_ex = stall ? 0 : MemWrite;   
    assign MemRead_id_ex = stall ? 0 : MemRead;
    assign MemtoReg_id_ex = stall ? 0 : MemtoReg;
    assign Branch_id_ex = stall ? 0 : Branch;
    assign AluSrcB_id_ex = stall ? 0 : AluSrcB;
    assign AluSrcA_id_ex = stall ? 0 : AluSrcA;
    assign AluOP_id_ex = stall ? 0 : AluOP;


    //ID_EX
    ID_EX id_ex(clk, reset,
        pc_if_id, pc_next_if_id, Instruction_if_id,
        ReadData1,ReadData2,Imm_Gen_Out,
        AluOP, AluSrcA,AluSrcB,
        Branch,MemRead,MemWrite,
        RegWrite,MemtoReg,

        pc_id_ex, pc_next_id_ex, Instruction_id_ex,
        ReadData1_id_ex, ReadData2_id_ex, Imm_Gen_Out_id_ex,
        AluOP_id_ex, AluSrcA_id_ex, AluSrcB_id_ex,
        Branch_id_ex, MemRead_id_ex,MemWrite_id_ex,
        RegWrite_id_ex, MemtoReg_id_ex
        );
    
    //EX
    forwarding_unit fwd_unit(Instruction_id_ex[19:15],Instruction_id_ex[24:20],Instruction_ex_mem[11:7],Instruction_mem_wb[11:7],RegWrite_ex_mem,RegWrite_mem_wb,forward_a,forward_b);
    
    adder a2(pc_id_ex,Imm_Gen_Out_id_ex,pc_branch);
    mux_4x1 mux4_srcA(ReadData1_id_ex,32'b0, pc_id_ex, 32'b0, AluSrcA_id_ex ,SrcAOut);
    mux_2x1 mux2_srcB(ReadData2_id_ex,Imm_Gen_Out_id_ex, AluSrcB_id_ex ,SrcBOut);
    ALUControl alu_ctrl_inst(AluOP_id_ex,Instruction_id_ex[14:12],Instruction_id_ex[30],AluControlOut);
    ALU alu_inst(SrcAOut,SrcBOut,AluControlOut, AluOut, zero, lt, ltu);

    assign ReadData1_fwd_a = (forward_a == 2'b00) ? SrcAOut : (forward_a == 2'b01) ? AluOut_ex_mem : WriteData;
    assign ReadData2_fwd_b = (forward_b == 2'b00) ? SrcBOut : (forward_b == 2'b01) ? AluOut_ex_mem : WriteData;
    

    //EX_MEM
    EX_MEM ex_mem(clk, reset,
        pc_id_ex, pc_next_id_ex, Instruction_id_ex,
        ReadData2_id_ex,
        Branch_id_ex, MemRead_id_ex,MemWrite_id_ex,
        RegWrite_id_ex, MemtoReg_id_ex,
        pc_branch,AluOut,zero,lt,ltu,

        pc_ex_mem, pc_next_ex_mem, Instruction_ex_mem,
        ReadData2_ex_mem,
        Branch_ex_mem, MemRead_ex_mem, MemWrite_ex_mem,
        RegWrite_ex_mem, MemtoReg_ex_mem,
        pc_branch_ex_mem, AluOut_ex_mem,
        zero_ex_mem, lt_ex_mem, ltu_ex_mem
    );

    // MEM
    branch_logic branch_inst(Instruction_ex_mem[14:12],zero_ex_mem,lt_ex_mem,ltu_ex_mem,branch_taken);
    assign branch_and = branch_taken & Branch_ex_mem;
    mux_2x1 mux2_pcsel(pc_next,pc_branch_ex_mem, branch_and, pc_in);
    data_mem dmem_inst(AluOut_ex_mem,clk,ReadData2_ex_mem,DataMemoryOut,MemRead_ex_mem,MemWrite_ex_mem);

    //MEM_WB
    MEM_WB mem_wb(clk, reset, Instruction_ex_mem, 
    RegWrite_ex_mem, MemtoReg_ex_mem,
    AluOut_ex_mem,DataMemoryOut,

    Instruction_mem_wb,
    RegWrite_mem_wb, MemtoReg_mem_wb,
    AluOut_mem_wb, DataMemoryOut_mem_wb
    );

    mux_2x1 mux2_wb(AluOut_mem_wb,DataMemoryOut_mem_wb,MemtoReg_mem_wb,WriteData);

 
endmodule
