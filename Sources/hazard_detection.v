module hazard_detection(
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd_id_ex,
    input MemRead_id_ex,
    output reg PcWrite,
    output reg IF_ID_Write,
    output reg stall
);

    always @(*) begin
        // Check for hazards
        if (MemRead_id_ex && ((rd_id_ex == rs1) || (rd_id_ex == rs2))) begin
            stall = 1; // Hazard detected, stall the pipeline
            PcWrite = 0; // Prevent PC from updating
            IF_ID_Write = 0; // Prevent IF/ID register from updating
        end else begin
            stall = 0; // No hazard, continue execution
            PcWrite = 1; // Allow PC to update
            IF_ID_Write = 1; // Allow IF/ID register to update
        end
    end
    
endmodule
