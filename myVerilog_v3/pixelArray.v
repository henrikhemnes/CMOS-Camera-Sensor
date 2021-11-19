module PIXEL_ARRAY(
                        input logic anaBias1,
                        input logic anaRamp,
                        input logic anaReset,
                        input logic erase,
                        input logic expose,
                        input logic[vertical_pixels-1:0] read,
                        output tri [horizontal_pixels-1:0][7:0] pixData
                    );
    //Pixelsensor parameters
    parameter int horizontal_pixels = 2; 
    parameter int vertical_pixels = 2; 
    parameter real dv_pixel = 0.5;

    //Generates pixels from PIXEL_SENSOR module
    genvar i, j;
    generate
        for(i=0; i < vertical_pixels; i++) begin
            for(j=0; j < horizontal_pixels; j++) begin
                PIXEL_SENSOR #(.dv_pixel(dv_pixel)) pix (.VBN1(anaBias1), .RAMP(anaRamp), .RESET(anaReset), .ERASE(erase),
                 .EXPOSE(expose), .READ(read[i]), .DATA(pixData[j]));
            end
        end
    endgenerate

endmodule
