`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/05/2021 09:56:13 PM
// Design Name: 
// Module Name: vga_driver
// Project Name: VGA Interface
// Target Devices: Zedboard
// Tool Versions: 
// Description: a simple vga interface for the zedboard
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module vga_driver #(
  parameter FRAME_WIDTH   = 640,
  parameter FRAME_HEIGHT  = 480,

  parameter H_BACK_PORCH  = 48,
  parameter H_FRONT_PORCH = 16,
  parameter H_SYNC_PULSE  = 96,

  parameter V_BACK_PORCH  = 31,
  parameter V_FRONT_PORCH = 11,
  parameter V_SYNC_PULSE  = 2
) (
  input i_pxl_clk,
  input i_reset,
  output o_vga_hsync, o_vga_vsync, o_active,
  output [11:0] o_x, o_y
);

  parameter H_SYNC_POSITION_START = H_BACK_PORCH + FRAME_WIDTH + H_FRONT_PORCH;
  parameter H_MAX = FRAME_WIDTH + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH;
  
  parameter V_SYNC_POSITION_START = V_BACK_PORCH + FRAME_HEIGHT + V_FRONT_PORCH;
  parameter V_MAX = FRAME_HEIGHT + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH;
  
  //////////////////////////////////////////
  // VGA Controller wires
  //////////////////////////////////////////
  
  // Counter Registers
  reg [11:0] h_counter_reg, v_counter_reg;
  
  // Sync Registers
  wire h_sync_reg, v_sync_reg;
  
  // Counter Logic + Reset
  always @ (posedge i_pxl_clk, posedge i_reset) begin
    if(i_reset) begin
      h_counter_reg <= 12'b0;
      v_counter_reg <= 12'b0;
    end
    else begin
      h_counter_reg <= h_counter_reg == (H_MAX - 1)
        ? 12'b0
        : h_counter_reg + 1;
      
      if(h_counter_reg == (H_MAX - 1)) begin
        v_counter_reg <= (v_counter_reg == (V_MAX - 1))
          ? 12'b0
          : v_counter_reg + 1;
      end
    end
  end
  
  // Sync Logic
  assign o_vga_hsync = (h_counter_reg < H_SYNC_POSITION_START)
    ? 1'b1
    : 1'b0;
  assign o_vga_vsync = (v_counter_reg < V_SYNC_POSITION_START)
    ? 1'b1
    : 1'b0;
    
  // Screen coordinates and Active region signal
  assign o_x = (h_counter_reg >= H_BACK_PORCH)
    ? h_counter_reg - H_BACK_PORCH
    : 1'b0;
  assign o_y = (v_counter_reg >= V_BACK_PORCH)
    ? v_counter_reg - V_BACK_PORCH
    : 1'b0;
  assign o_active = (h_counter_reg >= H_BACK_PORCH) && (h_counter_reg <= H_BACK_PORCH + FRAME_WIDTH - 1)
    && (v_counter_reg >= V_BACK_PORCH) && (v_counter_reg <= V_BACK_PORCH + FRAME_HEIGHT - 1)
    ? 1'b1
    : 1'b0;
endmodule
