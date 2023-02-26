`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/13/2023 02:50:03 PM
// Design Name: 
// Module Name:
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: basic 1-bit adder
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module adder1half(
    input i_bitA,
    input i_bitB,
    output o_sum,
    output o_cout
  );

    assign o_sum = i_bitA ^ i_bitB;
    assign o_cout = i_bitA & i_bitB;
endmodule

module adder1full(
    input i_bitA,
    input i_bitB,
    input i_bitCin,
    output o_sum,
    output o_cout
  );

    // wire w_wire1
    // wire w_wire2
    // assign w_wire1 = i_bitA ^ i_bitB;
    // assign o_sum = w_wire1 ^ i_bitCin;
    // assign o_cout = w_wire1 * i_bitCin | i_bitA & i_bitB;

    assign o_sum = i_bitA ^ i_bitB ^ i_bitCin;
    assign o_cout = i_bitA & i_bitB | i_bitA & i_bitCin | i_bitB & i_bitCin;
endmodule

module pg_black #(
    parameter RADIX = 2
  )(
    input [RADIX-1:0] i_busG,
    input [RADIX-1:0] i_busP,
    output o_bitG,
    output o_bitP
  );
  
  pg_gray #(.RADIX(RADIX)) pg_gray (
      .i_busG  (i_busG),
      .i_busP  (i_busP[RADIX-2:0]),
      .o_bitG  (o_bitG)
  );
  
  assign o_bitP = &i_busP;
endmodule

module pg_gray #(
    parameter RADIX = 2
  )(
    input [RADIX-1:0] i_busG,
    input [RADIX-2:0] i_busP,
    output o_bitG
  );
  
    wire [RADIX-1:1] w_ggroup;
      
    genvar ii;
    for(ii=1; ii<RADIX; ii=ii+1) begin
        assign w_ggroup[ii] = i_busG[ii] | (i_busP[ii] & i_busG[ii-1]);
    end
    assign o_bitG = w_ggroup[RADIX-1];
endmodule

module pg_sum #(
    parameter WIDTH = 4
  )(
    input  [WIDTH-1:0] i_busP,
    output [WIDTH-1:0] i_busGGroup,
    output [WIDTH-1:0] o_busSum
  );
  
  genvar ii;
  for(ii=0; ii<WIDTH; ii=ii+1) begin
    assign o_busSum[ii] = i_busP[ii] ^ i_busGGroup[ii];
  end
endmodule