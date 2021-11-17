module pixelTop_tb;

   //------------------------------------------------------------
   // Testbench clock
   //------------------------------------------------------------
   logic clk =0;
   logic reset =0;
   parameter integer clk_period = 200;
   parameter integer sim_end = clk_period*400;
   always #clk_period clk=~clk;

   //------------------------------------------------------------
   // Pixelsensor parameters
   //------------------------------------------------------------
   parameter int     horizontal_pixels = 4; //number of pixels in the horizontal direction
   parameter int     vertical_pixels = 4; //number of pixels in the vertical direction
   parameter real    dv_pixel = 0.5; //Change this (0-1) to vary the simulated light hitting the pixel sensors

   //Analog signals
   logic              anaBias1;
   logic              anaRamp;
   logic              anaReset;

   //Tie off the unused lines
   assign anaReset = 1;

   //Digital
   wire                       erase;
   wire                       expose;
   wire[vertical_pixels-1:0]  read;
   wire                       convert;

   tri [0:horizontal_pixels-1][7:0] pixData; //  We need this to be a wire, because we're tristating it

   //Instantiate pixelTop module
   pixelTop  #(.dv_pixel(dv_pixel), .horizontal_pixels(horizontal_pixels), .vertical_pixels(vertical_pixels))
    ptop(.anaBias1(anaBias1), .anaRamp(anaRamp), .anaReset(anaReset), .clk(clk), .reset(reset),
    .erase(erase),.expose(expose),.read(read),.convert(convert), .pixData(pixData));

   //------------------------------------------------------------
   // DAC and ADC model
   //------------------------------------------------------------
   logic[7:0] counter_data;

   // If we are to convert, then provide a clock via anaRamp
   // This does not model the real world behavior, as anaRamp would be a voltage from the ADC
   // however, it works
   assign anaRamp = convert ? clk : 0;

   // During exposure, provide a clock via anaBias1.
   // Again, no resemblence to real world, but we cheat.
   assign anaBias1 = expose ? clk : 0;


   // If we're not reading the pixData, then we should drive the bus. We set all the
   // databusses to data if read on each row is low, else the databusses are connected
   // to the counter.
   reg [0:horizontal_pixels-1][7:0] pixData_reg;
   bit readIsHigh = 0; //variable that flips to 1 if read is high on either of the rows

   always @(posedge clk) begin
      for(int i=0; i < horizontal_pixels; i++) begin
         readIsHigh = 0;

         //check if read is high on every row
         for(int j=0; j < vertical_pixels; j++) begin
            if(read[j]) begin
               readIsHigh = 1;
            end
         end

         if(readIsHigh) begin
            pixData_reg[i] = 8'bZ; //disconnect databus
         end
         else begin
            pixData_reg[i] = counter_data; //connect databus to counter
         end
      end
   end
   assign pixData = pixData_reg;


   // When convert is high, we run a analog ramp (via anaRamp clock) and digtal ramp via data bus.
   always_ff @(posedge clk or posedge reset) begin
      if(reset) begin
         counter_data = 0;
      end
      if(convert) begin
         counter_data +=  1;
      end
      else begin
         counter_data = 0;
      end
   end // always @ (posedge clk or reset)

   //------------------------------------------------------------
   // Readout from databus
   //------------------------------------------------------------
   logic [0:horizontal_pixels-1][7:0] pixelDataOut;

   always_ff @(posedge clk or posedge reset) begin
      if(reset) begin
         for(int i=0; i < vertical_pixels; i++) begin
            pixelDataOut[i] = 0; //we reset all the values
         end
      end
      else begin
         //We write out all the pixel values at each row to the terminal
         for(int i=0; i < vertical_pixels; i++) begin
            if(read[i]) begin
               $display("----------------------");
               for(int j=0; j < horizontal_pixels; j++) begin
                  pixelDataOut[i] <= pixData[j];
                  $display("Pixel %d: %d", j, pixelDataOut[i]);
               end
               $display("======================");
               $display("Row %d: ", i);
            end
         end
      end
   end   


   //Start the simulation
   initial begin
      reset = 1;

      #clk_period  reset=0;

      $dumpfile("pixelTop_tb.vcd");
      $dumpvars(0,pixelTop_tb);

      #sim_end  begin
      end
      #sim_end 

      #sim_end
         $stop;
   end
    
endmodule