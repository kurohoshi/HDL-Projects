`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/13/2023 04:37:14 PM
// Design Name: 
// Module Name: adder_tb
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


module adder_tb;
    reg r_cin = 1'b0;
    reg [31:0] r_INA = 'h0;
    reg [31:0] r_INB = 'h0;

    wire [31:0] w_sum;
    wire w_cout;

    adder32Sklansky2 #(.WIDTH(32)) DUT(
        .i_busA    (r_INA),
        .i_busB    (r_INB),
        .i_bitCin  (r_cin),
        .o_busSum  (w_sum),
        .o_bitCout (w_cout)
    );

    initial begin
        #500
        r_INA = 'haaaa5555;
        r_INB = 'h5555aaaa;
        
        #500;
        r_INA = 'h11111111;
        r_INB = 'heeeeeeee;
        #1000;
    end
endmodule
