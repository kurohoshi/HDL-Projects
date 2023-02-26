`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/15/2023
// Design Name: 
// Module Name:
// Project Name:
// Target Devices: 
// Tool Versions: 
// Description: 32-bit Kogge-Stone Tree Adder
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Variable Width
//                      buffers not included; sparsity not includd, velency not included
// 
//////////////////////////////////////////////////////////////////////////////////

module adder32KoggeStone2 #(
    parameter WIDTH = 15
  )(
    input  [WIDTH-1:0] i_busA,
    input  [WIDTH-1:0] i_busB,
    input              i_bitCin,
    output [WIDTH-1:0] o_busSum,
    output             o_bitCout
  );
  
    wire [WIDTH:0] w_generate;
    wire [WIDTH:1] w_propagate;
    wire [WIDTH:1] w_ggroupOut;
    assign w_generate[0] = i_bitCin;

    pg_gen #(.WIDTH(WIDTH)) pg_gen (
      .i_busA (i_busA),
      .i_busB (i_busB),
      .o_busG (w_generate[WIDTH:1]),
      .o_busP (w_propagate)
    );
    
    genvar ii;
    for(ii=1; 2**ii<=WIDTH*2; ii=ii+1) begin: pg_row
        localparam integer iii = 2**ii;
        localparam integer GRAY_CELL_LIMIT = iii < WIDTH+1 ? iii : WIDTH+1;
    
        wire [WIDTH:GRAY_CELL_LIMIT-1] w_ggroup;
        wire [WIDTH:GRAY_CELL_LIMIT-1] w_pgroup;
    
        genvar jj;
        for(jj=iii/2; jj<GRAY_CELL_LIMIT; jj=jj+1) begin: pg_cell_gray
            if(ii==1) begin
                pg_gray #(.RADIX(2)) pg_gray (
                  .i_busG (w_generate[jj -: 2]),
                  .i_busP (w_propagate[jj]),
                  .o_bitG (w_ggroupOut[jj])
                );
            end
            else begin
                pg_gray #(.RADIX(2)) pg_gray (
                  .i_busG ({pg_row[ii-1].w_ggroup[jj],pg_row[ii-1].w_ggroup[jj-iii/2]}),
                  .i_busP (pg_row[ii-1].w_pgroup[jj]),
                  .o_bitG (w_ggroupOut[jj])
                );
            end
        end
        
        genvar kk;
        for(kk=GRAY_CELL_LIMIT; kk<=WIDTH; kk=kk+1) begin: pg_cell_black
            if(ii==1) begin
                pg_black #(.RADIX(2)) pg_black (
                  .i_busG (w_generate[kk -: 2]),
                  .i_busP (w_propagate[kk]),
                  .o_bitG (w_ggroup[kk]),
                  .o_bitP (w_pgroup[kk])
                );
            end
            else begin
                pg_black #(.RADIX(2)) pg_black (
                  .i_busG ({pg_row[ii-1].w_ggroup[kk],pg_row[ii-1].w_ggroup[kk-iii/2]}),
                  .i_busP (pg_row[ii-1].w_pgroup[kk]),
                  .o_bitG (w_ggroup[kk]),
                  .o_bitP (w_pgroup[kk])
                );
            end
        end
    end
    
    pg_sum #(.WIDTH(WIDTH)) pg_sum (
      .i_busP      (w_propagate),
      .i_busGGroup ({w_ggroupOut[WIDTH-1:1], i_bitCin}),
      .o_busSum    (o_busSum)
    );
    
    assign o_bitCout = w_ggroupOut[WIDTH];
endmodule