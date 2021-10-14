`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2021 05:22:22 PM
// Design Name: 
// Module Name: vga_interface
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

//////////////////////////////////////////////////////////////////////////////////
// Example VGA Timings (https://web.mit.edu/6.111/www/labkit/vga.shtml)
// 
//                      |                 H                |                  V
//    Format    | Pxl Clk | Width | F Porch | Sync | B Porch | Height | F Porch | Sync | B Porch 
// -------------|---------|-------|---------|------|---------|--------|---------|------|---------
// 640x480p60   | 25.175  | 640   | 16      | 96   | 48      | 480    | 11      | 2    | 31
// 640x480p72   | 31.500  | 640   | 24      | 40   | 128     | 480    | 9       | 3    | 28
// 640x480p75   | 31.500  | 640   | 16      | 96   | 48      | 480    | 11      | 2    | 32
// 640x480p85   | 36.000  | 640   | 32      | 48   | 112     | 480    | 1       | 3    | 25
// 800x600p56   | 38.100  | 800   | 32      | 128  | 128     | 600    | 1       | 4    | 14
// 800x600p60   | 40.000  | 800   | 40      | 128  | 88      | 600    | 1       | 4    | 23
// 800x600p72   | 50.000  | 800   | 56      | 120  | 64      | 600    | 37      | 6    | 23
// 800x600p75   | 49.500  | 800   | 16      | 80   | 160     | 600    | 1       | 2    | 21
// 800x600p85   | 56.250  | 800   | 32      | 64   | 152     | 600    | 1       | 3    | 27
// 1024x768p60  |	65.000 	| 1024	| 24	    | 136	 | 160 	   | 768	  | 3	      | 6    | 29
// 1024x768p70  |	75.000 	| 1024	| 24	    | 136	 | 144 	   | 768	  | 3	      | 6    | 29
// 1024x768p75  |	78.750 	| 1024	| 16	    | 96	 | 176 	   | 768	  | 1	      | 3    | 28
// 1024x768p85  |	94.500 	| 1024	| 48	    | 96	 | 208 	   | 768	  | 1	      | 3    | 36
// 1280x1024p60 |	108.00 	| 1280	| 48	    | 112	 | 248 	   | 768	  | 1	      | 3    | 38
//
//////////////////////////////////////////////////////////////////////////////////

module vga_interface(
  input i_clk,i_reset,
  input i_switch2, i_switch1, i_switch0,
  output o_vga_hsync, o_vga_vsync,
  output [3:0] o_vga_red, o_vga_green, o_vga_blue
);

  wire w_pxl_clk;
  
  clk_divider #(
    .CLK_DIV(4)
  ) pxl_clk_divider (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .o_clk(w_pxl_clk)
  );

  wire w_vga_hsync;
  wire w_vga_vsync;
  wire [11:0] w_x;
  wire [11:0] w_y;
  wire w_active;
  wire [18:0] w_vga_mem_addr = w_x + w_y;

  vga_driver #(
    .FRAME_WIDTH(640),
    .FRAME_HEIGHT(480),

    .H_BACK_PORCH(48),
    .H_FRONT_PORCH(16),
    .H_SYNC_PULSE(96),

    .V_BACK_PORCH(31),
    .V_FRONT_PORCH(11),
    .V_SYNC_PULSE(2)
  ) vga_driver (
    .i_pxl_clk(w_pxl_clk),
    .i_reset(i_reset),
    .o_vga_hsync(w_vga_hsync),
    .o_vga_vsync(w_vga_vsync),
    .o_active(w_active),
    .o_x(w_x),
    .o_y(w_y)
  );

  wire w_mem_wea = 1'b0;
  wire [18:0] w_mem_addra = 19'b0;
  wire [2:0] w_mem_dina = 3'b1;
  wire [2:0] w_mem_doutb;

  vga_mem vga_mem (
    .addra(w_mem_addra),
    .clka(w_pxl_clk),
    .dina(w_mem_dina),
    .wea(w_mem_wea),
    .addrb(w_vga_mem_addr),
    .clkb(w_pxl_clk),
    .doutb(w_mem_doutb)
  );
  
  assign o_vga_hsync = w_vga_hsync;
  assign o_vga_vsync = w_vga_vsync;
//  assign o_vga_red = {3{w_mem_doutb[2]}};
//  assign o_vga_red = {3{w_mem_doutb[1]}};
//  assign o_vga_red = {3{w_mem_doutb[0]}};
  assign o_vga_red   = w_active ? {4{i_switch2}} : 4'b0;
  assign o_vga_green = w_active ? {4{i_switch1}} : 4'b0;
  assign o_vga_blue  = w_active ? {4{i_switch0}} : 4'b0;
endmodule
