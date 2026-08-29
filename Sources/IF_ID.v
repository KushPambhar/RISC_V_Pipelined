module IF_ID(input clk, input reset ,input [31:0] pc_if, input [31:0] pc_4_if, input [31:0] instruction_if, 
            output reg [31:0] pc_id, output reg [31:0] pc_4_id, output reg [31:0] instruction_id );

            always @(posedge clk or posedge reset) begin
                if(reset) begin
                    pc_id<=32'b0;
                    pc_4_id<=32'b0;
                    instruction_id <=32'b0;
                end
                else begin
                    pc_id<=pc_if;
                    pc_4_id<=pc_4_if;
                    instruction_id <= instruction_if;
                end
            end
endmodule;