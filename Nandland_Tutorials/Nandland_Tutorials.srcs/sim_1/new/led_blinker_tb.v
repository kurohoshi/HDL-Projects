`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Date: 2021/10/03
// Description: Nandland's Verilog Tutorial
//////////////////////////////////////////////////////////////////////////////////


module led_blinker_tb;
  reg r_CLOCK    = 1'b0;
  reg r_ENABLE   = 1'b0;
  reg r_SWITCH_1 = 1'b0;
  reg r_SWITCH_2 = 1'b0;
  
  wire w_LED_DRIVE;
  
  parameter SCALER = 1000;
  
  led_blinker #(
    .SCALER(SCALER)
  ) UUT (
    .clk(r_CLOCK),       
    .enable(r_ENABLE),    
    .switch_1(r_SWITCH_1),  
    .switch_2(r_SWITCH_2),  
    .driver_led(w_LED_DRIVE)
  );
  
  always #5 r_CLOCK <= !r_CLOCK;
  
  initial
    begin
      r_ENABLE <= 1'b1;
      
      r_SWITCH_1 <= 1'b0;
      r_SWITCH_2 <= 1'b0;
      #2000000 // 2 seconds
     
      r_SWITCH_1 <= 1'b0;
      r_SWITCH_2 <= 1'b1;
      #500000 // 0.5 seconds
       
      r_SWITCH_1 <= 1'b1;
      r_SWITCH_2 <= 1'b0;
      #200000 // 0.2 seconds
 
      r_SWITCH_1 <= 1'b1;
      r_SWITCH_2 <= 1'b1;
      #200000 // 0.2 seconds
 
      $display("Test Complete");
    end
endmodule
