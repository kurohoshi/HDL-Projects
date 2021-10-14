`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Date: 2021/10/03
// Description: Nandland's Verilog Tutorial
//////////////////////////////////////////////////////////////////////////////////


module example_and_gate(
  input input_1,
  input input_2,
  output and_result
);

wire and_temp;
assign and_temp = input_1 & input_2;
assign and_result = and_temp;

endmodule
