`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/14/2023
// Design Name: 
// Module Name:
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 32-bit Carry LookAhead Adder
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: TODO - modify to implement n-bit CLA adder
// 
//////////////////////////////////////////////////////////////////////////////////


module adder4CLA (
    input  [3:0] i_busA,
    input  [3:0] i_busB,
    input        i_bitCin,
    output [3:0] o_busSum,
    output       o_bitCout
  );
  
    wire [3:0] w_generate;
    wire [3:0] w_propagate;
    wire [3:0] w_ggroup;
    wire w_pgroup = &w_propagate;
    wire w_gen_val4;
    wire w_prop_val4;
    
    pg_gen #(.WIDTH(4)) pg_gen (
      .i_busA (i_busA),
      .i_busB (i_busB),
      .o_busG (w_generate),
      .o_busP (w_propagate)
    );
    
    pg_black #(.RADIX(4)) pg_val4 (
      .i_busG (w_generate),
      .i_busP (w_propagate),
      .o_bitG (w_gen_val4),
      .o_bitP (w_prop_val4)
    );
    
    genvar ii; // probably not a good idea to use ii for multiple buses
    for(ii=0; ii<4; ii=ii+1) begin
        if(ii==3) begin
            pg_gray #(.RADIX(2)) pg_gray (
              .i_busG ({w_gen_val4, i_bitCin}),
              .i_busP (w_pgroup),
              .o_bitG (o_bitCout)
            );
        end
        else if(ii==0) begin
            pg_gray #(.RADIX(2)) pg_gray(
              .i_busG ({w_generate[ii], i_bitCin}),
              .i_busP (w_propagate[ii]),
              .o_bitG (w_ggroup[ii])
            );
        end
        else begin
            pg_gray #(.RADIX(2)) pg_gray (
              .i_busG (w_generate[ii:ii-1]),
              .i_busP (w_propagate[ii]),
              .o_bitG (w_ggroup[ii])
            );
        end
    end
    
    pg_sum #(.WIDTH(4)) pg_sum (
        .i_busP      (w_propagate),
        .i_busGGroup ({w_ggroup[2:0], i_bitCin}),
        .o_busSum    (o_busSum)
    );
endmodule


module adder32CLA (
    input  [31:0] i_busA,
    input  [31:0] i_busB,
    input         i_bitCin,
    output [31:0] o_busSum,
    output        o_bitCout
  );
  
    wire [8:0] w_carry;
    assign w_carry[0] = i_bitCin;
    
    genvar ii;
    for(ii=0; ii<32; ii=ii+4) begin
        adder4CLA adder4(
          .i_busA    (i_busA[ii+3:ii]),
          .i_busB    (i_busB[ii+3:ii]),
          .i_bitCin  (w_carry[ii/4]),
          .o_busSum  (o_busSum[ii+3:ii]),
          .o_bitCout (w_carry[(ii/4)+1])
        );
    end
    
    assign o_bitCout = w_carry[8];
endmodule