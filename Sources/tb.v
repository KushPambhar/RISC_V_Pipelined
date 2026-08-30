`timescale 1ns/1ps
// ---------------------------------------------------------------------------
// Testbench for the PIPELINED top.v (IF_ID / ID_EX / EX_MEM / MEM_WB
// registers only -- no forwarding unit, no hazard detection, no branch
// flush implemented yet).
//
// Because there is no forwarding or flush logic, this testbench does NOT
// run arbitrary code -- it runs a program that is deliberately spaced so
// the current (bypass-free, flush-free) pipeline still produces correct
// results:
//   - every register write is followed by at least 3 filler instructions
//     before any instruction reads that register (so the ID-stage read
//     always happens strictly after the producer's WB-stage write has
//     already committed -- no same-cycle race, no forwarding needed)
//   - every branch is unconditionally followed by exactly 3 NOPs, since
//     with no flush, whatever sits in the 3 instruction slots right after
//     a branch will be fetched and executed regardless of the branch
//     outcome
// This program and its expected values were generated together (see
// program.py) -- do not edit imem.hex without regenerating this testbench,
// and vice versa.
//
// NOTE on register-file init: this reg_file (register_file.v) has no
// reset and does not hard-wire x0, so registers[] are X at t=0 in
// simulation. This testbench force-clears the register file before
// releasing reset purely for determinism; the RTL itself should still be
// fixed (hard-wire x0, add reset) independent of this testbench.
// ---------------------------------------------------------------------------

module tb_pipeline;

    reg clk;
    reg reset;
    integer i;
    integer errors;

    top dut (
        .clk   (clk),
        .reset (reset)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset = 1;
        for (i = 0; i < 32; i = i + 1)
            dut.rf_inst.registers[i] = 32'h0;
        repeat (2) @(posedge clk);
        reset = 0;
    end

    // Per-cycle trace: fetch (IF) vs. commit (WB)
    initial begin
        $display("time\t IF_pc\t IF_instr\t | WB_instr\t WB_regwrite rd  wdata");
    end
    always @(posedge clk) begin
        if (!reset)
            $display("%0t\t %h\t %h\t | %h\t %b\t\t %0d\t %h",
                $time, dut.pc_out, dut.Instruction,
                dut.Instruction_mem_wb, dut.RegWrite_mem_wb,
                dut.Instruction_mem_wb[11:7], dut.WriteData);
    end

    initial begin
        errors = 0;
        @(negedge reset);

        // 60 static instructions, pipeline drain (+4), generous margin for
        // the dead-code (skipped canary) slots after taken branches.
        repeat (90) @(posedge clk);
        #1;

        check_reg(1,  32'd5,   "x1  (addi x1,x0,5)");
        check_reg(2,  32'd12,  "x2  (addi x2,x0,12)");
        check_reg(4,  32'd17,  "x4  (add x4,x1,x2)");
        check_reg(5,  32'd7,   "x5  (sub x5,x2,x1)");
        check_reg(6,  32'd4,   "x6  (and x6,x1,x2)");
        check_reg(7,  32'd13,  "x7  (or  x7,x1,x2)");
        check_reg(8,  32'd9,   "x8  (xor x8,x1,x2)");
        check_reg(9,  32'd1,   "x9  (slt x9,x1,x2)");
        check_reg(10, 32'd17,  "x10 (lw x10,0(x0))");

        check_reg(11, 32'd0,   "x11 canary must stay 0 -- BEQ was taken");
        check_reg(12, 32'd111, "x12 BEQ branch-taken landing");

        check_reg(13, 32'd0,   "x13 canary must stay 0 -- BNE was taken");
        check_reg(14, 32'd222, "x14 BNE branch-taken landing");

        check_reg(15, 32'd0,   "x15 canary must stay 0 -- BLT was taken");
        check_reg(16, 32'd333, "x16 BLT branch-taken landing");

        check_reg(17, 32'd0,   "x17 canary must stay 0 -- BGE was taken");
        check_reg(18, 32'd444, "x18 BGE branch-taken landing");

        check_reg(21, 32'd55,  "x21 fall-through executes -- BLT was NOT taken");
        check_reg(22, 32'd77,  "x22 both paths converge here");

        check_reg(19, 32'd17,  "x19 (lw x19,4(x0))");
        check_reg(20, 32'd25,  "x20 (addi x20,x0,25)");

        check_dmem_word(0,   32'd17, "dmem[0]   (sw x4,0(x0))");
        check_dmem_word(4,   32'd17, "dmem[4]   (sw x4,4(x0))");
        check_dmem_word(100, 32'd25, "dmem[100] success marker (sw x20,100(x0))");

        if (errors == 0)
            $display("\n*** ALL CHECKS PASSED ***\n");
        else
            $display("\n*** %0d CHECK(S) FAILED ***\n", errors);

        $finish;
    end

    task check_reg(input [4:0] idx, input [31:0] expected, input [255:0] name);
        reg [31:0] actual;
        begin
            actual = dut.rf_inst.registers[idx];
            if (actual !== expected) begin
                $display("FAIL: %0s -- expected %0d (0x%h), got %0d (0x%h)",
                          name, expected, expected, actual, actual);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s -- %0d (0x%h)", name, actual, actual);
            end
        end
    endtask

    task check_dmem_word(input [9:0] addr, input [31:0] expected, input [255:0] name);
        reg [31:0] actual;
        begin
            actual = { dut.dmem_inst.mem[addr+3], dut.dmem_inst.mem[addr+2],
                       dut.dmem_inst.mem[addr+1], dut.dmem_inst.mem[addr] };
            if (actual !== expected) begin
                $display("FAIL: %0s -- expected %0d (0x%h), got %0d (0x%h)",
                          name, expected, expected, actual, actual);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s -- %0d (0x%h)", name, actual, actual);
            end
        end
    endtask

    initial begin
        #2000;
        $display("\n*** TIMEOUT -- simulation did not finish in time ***\n");
        $finish;
    end

endmodule
