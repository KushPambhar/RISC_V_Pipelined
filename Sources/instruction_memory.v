module inst_mem(address, instruction_out);
    input [31:0] address;
    output wire [31:0] instruction_out;
    reg [7:0] mem [0:1023];  // 1024 rows , each 8 bits wide (1KB)
    
    initial $readmemh("imem.hex",mem);
    // Little Endian : High byte high address
    assign instruction_out[7:0]=mem[address[9:0]]; // Only used 10 Address-lines from pc since we have 1024 rows i.e. 2^10.
    assign instruction_out[15:8]=mem[address[9:0]+1];
    assign instruction_out[23:16]=mem[address[9:0]+2];
    assign instruction_out[31:24]=mem[address[9:0]+3];


endmodule
