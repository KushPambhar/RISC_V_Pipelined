// 32-bits wide PC

module pc(next_pc, clk, reset, pc_out);
    input [31:0]next_pc;
    input clk,reset;
    output  reg [31:0]pc_out;

    always @(posedge clk or posedge reset) begin 
        if(reset)
            pc_out<=32'b0;
        else
            pc_out<=next_pc;
    
    end
endmodule
