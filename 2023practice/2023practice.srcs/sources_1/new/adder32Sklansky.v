`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/16/2023
// Design Name: 
// Module Name:
// Project Name:
// Target Devices: 
// Tool Versions: 
// Description: 32-bit Sklansky Tree Adder
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Variable Width
//                      buffers not included; sparsity not includd, velency not included
// 
//////////////////////////////////////////////////////////////////////////////////


module adderSklanskyModuleGray #(
    parameter WIDTH = 1
  )(
    input  [WIDTH:0] i_busG,
    input  [WIDTH:1] i_busP,
    output [WIDTH:1] o_busG
  );
  
    wire [WIDTH:1] w_ggroup;
    wire [WIDTH:1] w_pgroup;
    assign w_ggroup[1] = i_busG[1];
    assign w_pgroup[1] = i_busP[1];

    if(WIDTH>1) begin
        genvar ii;
        for(ii=2; ii<WIDTH*2; ii=ii*2) begin: pg_section
            localparam integer LIMIT = (ii <= WIDTH ? ii : WIDTH);
                    
            adderSklanskyModuleBlack #(.WIDTH(LIMIT-ii/2)) adderSklanskyModuleBlack (
              .i_busG ({i_busG[LIMIT:ii/2+1], w_ggroup[ii/2]}),
              .i_busP ({i_busP[LIMIT:ii/2+1], w_pgroup[ii/2]}),
              .o_busG (w_ggroup[LIMIT:ii/2+1]),
              .o_busP (w_pgroup[LIMIT:ii/2+1])
            );
        end
    end
    
    genvar jj;
    for(jj=1; jj<=WIDTH; jj=jj+1) begin: pg_gray
        pg_gray #(.RADIX(2)) pg_gray (
          .i_busG ({w_ggroup[jj], i_busG[0]}),
          .i_busP (w_pgroup[jj]),
          .o_bitG (o_busG[jj])
        );
    end
endmodule

module adderSklanskyModuleBlack #(
    parameter WIDTH = 1
  )(
    input  [WIDTH:0] i_busG,
    input  [WIDTH:0] i_busP,
    output [WIDTH:1] o_busG,
    output [WIDTH:1] o_busP
  );
  
    wire [WIDTH:1] w_ggroup;
    wire [WIDTH:1] w_pgroup;
    assign w_ggroup[1] = i_busG[1];
    assign w_pgroup[1] = i_busP[1];

    if(WIDTH>1) begin
        genvar ii;
        for(ii=2; ii<WIDTH*2; ii=ii*2) begin: pg_section
            localparam integer LIMIT = (ii <= WIDTH ? ii : WIDTH);
                    
            adderSklanskyModuleBlack #(.WIDTH(LIMIT-ii/2)) adderSklanskyModuleBlack (
              .i_busG ({i_busG[LIMIT:ii/2+1], w_ggroup[ii/2]}),
              .i_busP ({i_busP[LIMIT:ii/2+1], w_pgroup[ii/2]}),
              .o_busG (w_ggroup[LIMIT:ii/2+1]),
              .o_busP (w_pgroup[LIMIT:ii/2+1])
            );
        end
    end

    genvar jj;
    for(jj=1; jj<=WIDTH; jj=jj+1) begin: pg_black
        pg_black #(.RADIX(2)) pg_black (
          .i_busG ({w_ggroup[jj], i_busG[0]}),
          .i_busP ({w_pgroup[jj], i_busP[0]}),
          .o_bitG (o_busG[jj]),
          .o_bitP (o_busP[jj])
        );
    end
endmodule

module adder32Sklansky2 #(
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
    wire [WIDTH:0] w_ggroupOut;
    assign w_generate[0] = i_bitCin;
    assign w_ggroupOut[0] = i_bitCin;
    
    
    pg_gen #(.WIDTH(WIDTH)) pg_gen (
      .i_busA (i_busA),
      .i_busB (i_busB),
      .o_busG (w_generate[WIDTH:1]),
      .o_busP (w_propagate)
    );
    
    genvar ii;
    for(ii=2; ii-1<=WIDTH*2; ii=ii*2) begin: pg_section
        localparam integer LIMIT = (ii-1 <= WIDTH ? ii-1 : WIDTH);
        
        adderSklanskyModuleGray #(.WIDTH(LIMIT-ii/2+1)) adderSklanskyModuleGray (
          .i_busG ({w_generate[LIMIT:ii/2],w_ggroupOut[ii/2-1]}),
          .i_busP (w_propagate[LIMIT:ii/2]),
          .o_busG (w_ggroupOut[LIMIT:ii/2])
        );
    end
    
    pg_sum #(.WIDTH(WIDTH)) pg_sum (
      .i_busP      (w_propagate),
      .i_busGGroup ({w_ggroupOut[WIDTH-1:1], i_bitCin}),
      .o_busSum    (o_busSum)
    );
    
    assign o_bitCout = w_ggroupOut[WIDTH];
endmodule