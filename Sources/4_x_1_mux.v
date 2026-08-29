module mux_4x1 (
    input      [31:0] input_a,
    input      [31:0] input_b,
    input      [31:0] input_c,
    input      [31:0] input_d,
    input      [1:0]  select_line,
    output reg [31:0] output_mux
);
    always @(*) begin
        case (select_line)
            2'b00: output_mux = input_a;
            2'b01: output_mux = input_b;
            2'b10: output_mux = input_c;
            2'b11: output_mux = input_d;
        endcase
    end
endmodule
