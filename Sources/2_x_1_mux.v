module mux_2x1(input [31:0] input_a, input [31:0] input_b, input select_line, output [31:0] output_mux);
    assign output_mux = select_line ? input_b : input_a ;
endmodule
