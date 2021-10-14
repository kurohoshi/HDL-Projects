`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Date: 2021/10/03
// Description: Nandland's Verilog Tutorial
//////////////////////////////////////////////////////////////////////////////////


module led_blinker #(
  parameter FREQ = 100000000,
  parameter SCALER = 1
) (
  input clk,
  input enable,
  input switch_1,
  input switch_2,
  output driver_led
);

parameter CLK_1 = ( FREQ / ( 1 * 2 * SCALER ) );
parameter CLK_2 = ( FREQ / ( 10 * 2 * SCALER ) );
parameter CLK_3 = ( FREQ / ( 50 * 2 * SCALER ) );
parameter CLK_4 = ( FREQ / ( 100 * 2 * SCALER ) );

wire d_clk_1;
wire d_clk_2;
wire d_clk_3;
wire d_clk_4;

reg led_select;

// modules for clock dividers
clk_div #(.div(CLK_1)) div1 (
  clk,
  d_clk_1
);

clk_div #(.div(CLK_2)) div2 (
  clk,
  d_clk_2
);

clk_div #(.div(CLK_3)) div3 (
  clk,
  d_clk_3
);

clk_div #(.div(CLK_4)) div4 (
  clk,
  d_clk_4
);

// ternary operator method
assign led_select = switch_1
  ? (switch_2 ? d_clk_4 : d_clk_3 )
  : (switch_2 ? d_clk_2 : d_clk_1 );

// case statement method
//always @ (*)
//  begin
//    case({switch_1, switch_2})
//      2'b00 : led_select <= d_clk_1;
//      2'b01 : led_select <= d_clk_2;
//      2'b10 : led_select <= d_clk_3;
//      2'b11 : led_select <= d_clk_4;
//      default : led_select <= 0;
//    endcase
//  end

assign driver_led = led_select & enable;

endmodule

module clk_div #(
  parameter div = 100
) (
  input clk,
  output o_clk
);

reg [31:0] clk_counter = 0;
reg clk_toggle = 1'b0;

always @ (posedge clk)
  begin
    if(clk_counter == div-1)
      begin
        clk_toggle <= !clk_toggle;
        clk_counter <= 0;
      end
    else
      begin
        clk_counter <= clk_counter + 1;
      end
  end
  
assign o_clk = clk_toggle;

endmodule
