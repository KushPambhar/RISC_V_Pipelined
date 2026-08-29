`timescale 1ns/1ps
// ---------------------------------------------------------------------------
// Testbench for top.v (single-cycle RV32I core)
//
// What it does:
//   1. Generates clk/reset.
//   2. Zero-initialises the register file at time 0 (see NOTE below).
//   3. Runs the program loaded from imem.hex by inst_mem.
//   4. Waits for the program to reach its final infinite self-branch
//      (the "halt" instruction), then checks register + data-memory
//      results against the expected values and reports PASS/FAIL.
//
// NOTE on the register-file init:
//   reg_file (register_file.v) has no reset, so registers[] (including x0)
//   are X at t=0 in simulation, and nothing in the design ever forces
//   x0 = 0. Real RV32I requires x0 to always read as 0. This testbench
//   force-clears the register file before releasing reset purely so the
//   simulation is deterministic; it is a workaround, not a fix -- the
//   underlying reg_file should hard-wire x0 to zero and/or add a reset.
// ---------------------------------------------------------------------------

module tb_top;

    reg clk;
    reg reset;

    integer i;
    integer errors;

    top dut (
        .clk   (clk),
        .reset (reset)
    );

    // 100 MHz-style test clock (period arbitrary in sim time)
    initial clk = 0;
    always #5 clk = ~clk;

    // Reset pulse + register-file clear (see NOTE above)
    initial begin
        reset = 1;
        for (i = 0; i < 32; i = i + 1)
            dut.rf_inst.registers[i] = 32'h0;
        repeat (2) @(posedge clk);
        reset = 0;
    end

    // Optional per-instruction trace
    initial begin
        $display("time\t pc\t\t instr\t\t RegWrite rd  wdata");
    end
    always @(posedge clk) begin
        if (!reset)
            $display("%0t\t %h\t %h\t %b\t\t %0d\t %h",
                $time, dut.pc_out, dut.Instruction,
                dut.RegWrite, dut.Instruction[11:7], dut.WriteData);
    end

    // Main check sequence
    initial begin
        errors = 0;
        @(negedge reset);

        // Program is 27 instructions; give it a healthy margin of cycles
        // to execute (including the branches) before we start checking.
        repeat (40) @(posedge clk);
        #1;

        // ---- Register file checks ----
        check_reg(1,  32'd5,   "x1 (addi x1,x0,5)");
        check_reg(2,  32'd12,  "x2 (addi x2,x0,12)");
        check_reg(4,  32'd17,  "x4 (add x4,x1,x2)");
        check_reg(5,  32'd7,   "x5 (sub x5,x2,x1)");
        check_reg(6,  32'd4,   "x6 (and x6,x1,x2)");
        check_reg(7,  32'd13,  "x7 (or  x7,x1,x2)");
        check_reg(8,  32'd9,   "x8 (xor x8,x1,x2)");
        check_reg(9,  32'd1,   "x9 (slt x9,x1,x2)");
        check_reg(10, 32'd17,  "x10 (lw x10,0(x0))");

        check_reg(11, 32'd0,   "x11 must stay 0 -- BEQ should have skipped it");
        check_reg(12, 32'd111, "x12 (BEQ branch-taken target)");

        check_reg(13, 32'd0,   "x13 must stay 0 -- BNE should have skipped it");
        check_reg(14, 32'd222, "x14 (BNE branch-taken target)");

        check_reg(15, 32'd0,   "x15 must stay 0 -- BLT should have skipped it");
        check_reg(16, 32'd333, "x16 (BLT branch-taken target)");

        check_reg(17, 32'd0,   "x17 must stay 0 -- BGE should have skipped it");
        check_reg(18, 32'd444, "x18 (BGE branch-taken target)");

        check_reg(19, 32'd17,  "x19 (lw x19,4(x0))");
        check_reg(20, 32'd25,  "x20 (addi x20,x0,25)");

        // ---- Data memory checks (byte lanes as written by SW, little-endian) ----
        check_dmem_word(0,   32'd17, "dmem[0]  (sw x4,0(x0))");
        check_dmem_word(4,   32'd17, "dmem[4]  (sw x4,4(x0))");
        check_dmem_word(100, 32'd25, "dmem[100] success marker (sw x20,100(x0))");

        if (errors == 0)
            $display("\n*** ALL CHECKS PASSED ***\n");
        else
            $display("\n*** %0d CHECK(S) FAILED ***\n", errors);

        $finish;
    end

    // ---- helper tasks ----
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

    // Safety timeout in case something hangs before the loop
    initial begin
        #2000;
        $display("\n*** TIMEOUT -- simulation did not finish in time ***\n");
        $finish;
    end

endmodule
