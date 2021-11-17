`timescale 1 ns / 1 ps

//====================================================================
// Testbench for pixelSensor
// - clock
// - instanciate pixel
// - State Machine for controlling pixel sensor
// - Model the ADC and ADC
// - Readout of the databus
// - Stuff neded for testbench. Store the output file etc.
//====================================================================
module pixelState_tb;

   //------------------------------------------------------------
   // Testbench clock
   //------------------------------------------------------------
   logic clk = 0;
   logic reset = 0;
   parameter integer clk_period = 500;
   parameter integer sim_end = clk_period*2400;
   always #clk_period clk=~clk;

   parameter int horizontal_pixels = 2; //number of pixels in the horizontal direction
   parameter int vertical_pixels = 2; //number of pixels in the vertical direction
   parameter real dv_pixel = 0.5;

   //Analog signals
   logic              anaBias1;
   logic              anaRamp;
   logic              anaReset;

   //Tie off the unused lines
   assign anaReset = 1;

   //Digital
   wire             erase;
   wire             expose;
   wire[vertical_pixels-1:0]  read;
   wire             convert;
      
   tri [0:horizontal_pixels-1][7:0] pixData;

   //Instantiate the pixel
   PIXEL_ARRAY #(.dv_pixel(dv_pixel)) pa(.anaBias1(anaBias1), .anaRamp(anaRamp), .anaReset(anaReset), .erase(erase),
    .expose(expose), .read(read), .pixData(pixData));

   pixelState fsm(.clk(clk),.reset(reset),.erase(erase),.expose(expose),.read(read),.convert(convert));

   //------------------------------------------------------------
   // DAC and ADC model
   //------------------------------------------------------------
   logic[7:0] data;

   // If we are to convert, then provide a clock via anaRamp
   // This does not model the real world behavior, as anaRamp would be a voltage from the ADC
   // however, we cheat
   assign anaRamp = convert ? clk : 0;

   // During exposure, provide a clock via anaBias1.
   // Again, no resemblence to real world, but we cheat.
   assign anaBias1 = expose ? clk : 0;

   // If we're not reading the pixData, then we should drive the bus
   assign pixData[0] = read[0] ? 8'bZ: data;
   assign pixData[1] = read[0] ? 8'bZ: data;
   assign pixData[0] = read[1] ? 8'bZ: data;
   assign pixData[1] = read[1] ? 8'bZ: data;
   
   // When convert, then run a analog ramp (via anaRamp clock) and digtal ramp via
   // data bus.
   always_ff @(posedge clk or posedge reset) begin
      if(reset) begin
         data = 0;
      end
      if(convert) begin
         data +=  1;
      end
      else begin
         data = 0;
      end
   end // always @ (posedge clk or reset)

   //------------------------------------------------------------
   // Readout from databus
   //------------------------------------------------------------
   logic [0:horizontal_pixels-1][7:0] pixelDataOut;

   always_ff @(posedge clk or posedge reset) begin
      if(reset) begin
         pixelDataOut[0] <= 0;
         pixelDataOut[1] <= 0;
      end
      else begin
         for(int i=0; i < vertical_pixels; i++) begin
            if(read[i]) begin
               for(int j=0; j < horizontal_pixels; j++) begin
                     pixelDataOut[j] <= pixData[j];
               end
            end
         end
      end
   end

   //------------------------------------------------------------
   // Testbench stuff
   //------------------------------------------------------------
   initial
     begin
        reset = 1;

        #clk_period  reset=0;

        $dumpfile("pixelState_tb.vcd");
        $dumpvars(0,pixelState_tb);

        #sim_end
          $stop;

     end

endmodule // test
