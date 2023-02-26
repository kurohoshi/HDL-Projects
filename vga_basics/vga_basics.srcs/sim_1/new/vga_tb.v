`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2021 02:55:03 PM
// Design Name: 
// Module Name: vga_tb
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


module vga_tb;
  // Registers for test values
  reg r_clk   = 1'b0;
  reg r_reset = 1'b0;
  reg w_switch2 = 1'b0;
  reg w_switch1 = 1'b0;
  reg w_switch0 = 1'b0;
    
  // Wires for reading output
  wire w_vga_hsync;
  wire w_vga_vsync;
  wire [3:0] w_vga_red, w_vga_green, w_vga_blue;
  
  vga_interface UUT (
    .i_clk(r_clk),
    .i_reset(r_reset),
    .i_switch2(w_switch2),
    .i_switch1(w_switch1),
    .i_switch0(w_switch0),
    .o_vga_hsync(w_vga_hsync),
    .o_vga_vsync(w_vga_vsync),
    .o_vga_red(w_vga_red),
    .o_vga_green(w_vga_green),
    .o_vga_blue(w_vga_blue)
  );
  
  always #5 r_clk <= !r_clk;
  
  initial begin
    r_reset <= 1'b1;
    #100;
    r_reset <= 1'b0;
    #100;
    
    w_switch2 <= 1'b1;
  end
endmodule
