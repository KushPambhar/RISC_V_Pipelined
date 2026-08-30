module forwarding_unit(
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd_ex_mem,
    input [4:0] rd_mem_wb,
    input reg_write_ex,
    input reg_write_mem,
    output reg forward_a,
    output reg forward_b
);
    //EX & MEM-hazard
    always @(*) begin
        // Forwarding for rs1
        if (reg_write_ex && (rd_ex_mem != 0) && (rd_ex_mem == rs1)) begin
            forward_a = 1; // Forward from EX stage
        end else if (reg_write_mem && (rd_mem_wb != 0) && (rd_mem_wb == rs1)) begin
            forward_a = 2; // Forward from MEM stage
        end else begin
            forward_a = 0; // No forwarding
        end

        // Forwarding for rs2
        if (reg_write_ex && (rd_ex_mem != 0) && (rd_ex_mem == rs2)) begin
            forward_b = 1; // Forward from EX stage
        end else if (reg_write_mem && (rd_mem_wb != 0) && (rd_mem_wb == rs2)) begin
            forward_b = 2; // Forward from MEM stage
        end else begin
            forward_b = 0; // No forwarding
        end
    end

endmodule