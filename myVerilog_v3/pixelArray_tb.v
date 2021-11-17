// Make a testbench pixelArray_tb.v to check that the
// pixelArray.v compiles and do some rudementary tests to
// check that you've hooked things up correctly

`timescale 1 ns / 1 ps

module PIXEL_ARRAY_tb();
   parameter int horizontal_pixels = 2; //number of pixels in the horizontal direction
   parameter int vertical_pixels = 2; //number of pixels in the vertical direction

   logic anaBias1, anaRamp, anaReset;
   logic erase, expose;
   logic read[vertical_pixels-1:0];
   tri[7:0] pixData [1:0];


   PIXEL_ARRAY dut(anaBias1, anaRamp, anaReset, erase, expose, read, pixData);

   initial begin
      anaReset = 1; erase = 1; expose = 0; anaRamp = 0; read[0] = 0; read[1] = 0; #10;
      anaReset = 1; erase = 0; expose = 1; anaRamp = 0; read[0] = 0; read[1] = 0; #400;
      anaReset = 1; erase = 0; expose = 0; anaRamp = 0; read[0] = 0; read[1] = 0; #10;
      anaReset = 1; erase = 0; expose = 0; anaRamp = 1; read[0] = 0; read[1] = 0; #400;

      anaReset = 1; erase = 0; expose = 0; anaRamp = 0; read[0] = 1; read[1] = 0; #20;
      anaReset = 1; erase = 0; expose = 0; anaRamp = 0; read[0] = 0; read[1] = 1; #20;
      
      anaReset = 1; erase = 0; expose = 0; anaRamp = 0; read[0] = 0; read[1] = 0; #10;
      anaReset = 1; erase = 1; expose = 0; anaRamp = 0; read[0] = 0; read[1] = 0; #10;
   end
    

   //------------------------------------------------------------
   // Testbench stuff
   //------------------------------------------------------------
   initial begin
      $dumpfile("pixelArray.vcd");
      $dumpvars(0,PIXEL_ARRAY_tb);
   end
endmodule
