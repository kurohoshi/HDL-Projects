`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2021 10:04:46 PM
// Design Name: 
// Module Name: clk_divider
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clk_divider #(
  parameter CLK_DIV = 4
) (
    input i_clk,
    input i_reset,
    output o_clk
);

  reg r_clk;
  reg [1:0] clk_counter;

  // clock divider (50k MHz)
  always @ (negedge i_clk) begin
    if(i_reset) begin
      clk_counter <= 2'b0;
      r_clk <= 1'b0;
    end
    else begin
      clk_counter <= clk_counter != CLK_DIV - 1 ? clk_counter + 1 : 2'b0;
      r_clk <= clk_counter < CLK_DIV/2 ? 1'b0 : 1'b1;
    end
  end
  
  assign o_clk = r_clk;
endmodule
