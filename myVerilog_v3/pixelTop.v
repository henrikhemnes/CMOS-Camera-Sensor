module pixelTop (      input logic anaBias1,
                       input logic anaRamp,
                       input logic anaReset,
                       input logic clk,
                       input logic reset,
                       output logic erase,
                       output logic expose,
                       output logic[vertical_pixels-1:0] read,
                       output logic convert,
                       output tri [0:vertical_pixels-1][7:0] pixData
);
   parameter int horizontal_pixels = 2;
   parameter int vertical_pixels = 2; 
   parameter real dv_pixel = 0.5;

    //Instantiate the pixels
   PIXEL_ARRAY  #(.dv_pixel(dv_pixel), .horizontal_pixels(horizontal_pixels), .vertical_pixels(vertical_pixels))
    pa(.anaBias1(anaBias1), .anaRamp(anaRamp), .anaReset(anaReset), .erase(erase),
     .expose(expose), .read(read), .pixData(pixData));
    
    //Instantiate the pixelState module
   pixelState #(.horizontal_pixels(horizontal_pixels), .vertical_pixels(vertical_pixels))
    fsm(.clk(clk),.reset(reset),.erase(erase),.expose(expose),.read(read),.convert(convert));

endmodule