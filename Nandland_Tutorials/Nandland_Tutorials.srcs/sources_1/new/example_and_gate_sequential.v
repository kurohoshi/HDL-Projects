`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Date: 2021/10/03
// Description: Nandland's Verilog Tutorial
//////////////////////////////////////////////////////////////////////////////////


module example_and_gate_sequential(
  input input_1,
  input input_2,
  input clk,
  output and_result
);

always @ (posedge clk)
  begin
    and_result <= input_1 & input_2;
  end
endmodule