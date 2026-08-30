// 32-bits wide PC

module pc(next_pc, clk, reset, pc_write, pc_out);
    input [31:0]next_pc;
    input clk,reset,pc_write;
    output  reg [31:0]pc_out;

    always @(posedge clk or posedge reset) begin 
        
        if(reset) begin
            pc_out <= 32'b0;
        end
        else if(pc_write) begin
            pc_out <= next_pc;
        end
    end
endmodule
