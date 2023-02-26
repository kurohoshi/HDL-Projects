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
// Description: 32-bit Ripple Carry Adder
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Variable Width
// 
//////////////////////////////////////////////////////////////////////////////////


module adder32Ripple #(
    parameter WIDTH = 16
  )(
    input  [WIDTH-1:0] i_busA,
    input  [WIDTH-1:0] i_busB,
    input              i_bitCin,
    output [WIDTH-1:0] o_busSum,
    output             o_bitCout
  );

    wire [WIDTH:0] w_carry;
    assign w_carry[0] = i_bitCin;
    
    genvar ii;
    for(ii=0; ii<WIDTH; ii=ii+1) begin
        adder1full adder(
          .i_bitA    (i_busA[ii]),
          .i_bitB    (i_busB[ii]),
          .i_bitCin  (w_carry[ii]),
          .o_sum     (o_busSum[ii]),
          .o_cout    (w_carry[ii+1])
        );
    end
    
    assign o_bitCout = w_carry[WIDTH];
endmodule