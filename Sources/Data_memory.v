module data_mem(data_address,clk,write_data, Read_data, MemRead, MemWrite);
    input [31:0] data_address, write_data;
    input MemRead,MemWrite,clk;
    output reg [31:0] Read_data;


    reg [7:0] mem [0:1023];
    initial $readmemh("dmem.hex", mem);
    wire [9:0]add;
    assign add = data_address[9:0];
    always@(*) begin 
        Read_data = 32'b0;
        if(MemRead) begin
            Read_data[7:0] = mem[add];
            Read_data[15:8] = mem[add+1];
            Read_data[23:16] = mem[add+2];
            Read_data[31:24] = mem[add+3];
        end
    end

    always@(posedge clk) begin 
        if(MemWrite) begin
            mem[add] <= write_data[7:0];
            mem[add+1] <= write_data[15:8];
            mem[add+2] <= write_data[23:16];
            mem[add+3] <= write_data[31:24];
        end
    end
endmodule
