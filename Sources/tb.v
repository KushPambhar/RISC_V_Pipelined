`timescale 1ns/1ps
// ---------------------------------------------------------------------------
// Testbench for top.v with forwarding_unit + hazard_detection wired in
// (data hazards only -- EX/MEM forward, MEM/WB forward, load-use stall,
// and store-data forwarding). Branch control hazards are NOT flushed yet,
// so the test program still relies on 3 mandatory NOP delay slots after
// every branch (see program.py) -- that part is unchanged from before.
//
// Unlike the earlier hazard-free testbench, this program deliberately uses
// ZERO spacing between producers and consumers (including load-use, which
// needs the hazard-detection stall) to prove forwarding/stalling actually
// works, rather than working around their absence.
//
// NOTE: register_file.v still has no reset and doesn't hard-wire x0, so
// this testbench force-clears the register file before releasing reset,
// same workaround as before.
// ---------------------------------------------------------------------------

module tb_pipeline_fwd;

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

    initial begin
        $display("time\t IF_pc\t IF_instr\t stall\t | WB_instr\t WB_rw rd  wdata");
    end
    always @(posedge clk) begin
        if (!reset)
            $display("%0t\t %h\t %h\t %b\t | %h\t %b     %0d\t %h",
                $time, dut.pc_out, dut.Instruction, dut.stall,
                dut.Instruction_mem_wb, dut.RegWrite_mem_wb,
                dut.Instruction_mem_wb[11:7], dut.WriteData);
    end

    initial begin
        errors = 0;
        @(negedge reset);

        // 58 static instructions + pipeline drain + a couple of stall
        // cycles from load-use hazards -- generous margin.
        repeat (90) @(posedge clk);
        #1;

        check_reg(1,  32'd5,   "x1  (addi x1,x0,5)");
        check_reg(2,  32'd10,  "x2  (add x2,x1,x1 -- EX/MEM fwd, gap0)");
        check_reg(3,  32'd1,   "x3  (addi x3,x0,1)");
        check_reg(4,  32'd9,   "x4  (sub x4,x2,x3 -- MEM/WB fwd + EX/MEM fwd combined)");
        check_reg(5,  32'd1,   "x5  (and x5,x4,x1)");
        check_reg(6,  32'd11,  "x6  (or  x6,x4,x2)");
        check_reg(7,  32'd3,   "x7  (xor x7,x4,x2)");
        check_reg(8,  32'd1,   "x8  (slt x8,x1,x2)");

        check_reg(9,  32'd42,  "x9  (addi x9,x0,42)");
        check_reg(10, 32'd42,  "x10 (lw x10,0(x0) after store-data fwd)");
        check_reg(11, 32'd84,  "x11 (add x11,x10,x10 -- load-use stall+fwd)");

        check_reg(12, 32'd17,  "x12 (addi x12,x0,17)");
        check_reg(13, 32'd17,  "x13 (lw x13,4(x0) after store-data fwd)");
        check_reg(14, 32'd34,  "x14 (add x14,x13,x12 -- load-use stall+fwd)");

        check_reg(15, 32'd7,   "x15");
        check_reg(16, 32'd7,   "x16");
        check_reg(17, 32'd0,   "x17 canary must stay 0 -- BEQ was taken");
        check_reg(18, 32'd111, "x18 BEQ landing");

        check_reg(19, 32'd3,   "x19");
        check_reg(20, 32'd4,   "x20");
        check_reg(21, 32'd0,   "x21 canary must stay 0 -- BNE was taken");
        check_reg(22, 32'd222, "x22 BNE landing");

        check_reg(23, 32'd2,   "x23");
        check_reg(24, 32'd9,   "x24");
        check_reg(25, 32'd0,   "x25 canary must stay 0 -- BLT was taken");
        check_reg(26, 32'd333, "x26 BLT landing");

        check_reg(27, 32'd9,   "x27");
        check_reg(28, 32'd2,   "x28");
        check_reg(29, 32'd0,   "x29 canary must stay 0 -- BGE was taken");
        check_reg(30, 32'd444, "x30 BGE landing");

        check_reg(31, 32'd99,  "x31 (both paths converge -- BLT NOT taken)");

        check_dmem_word(0, 32'd42, "dmem[0] (sw x9,0(x0)  -- store-data forward)");
        check_dmem_word(4, 32'd17, "dmem[4] (sw x12,0,4   -- store-data forward)");

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
