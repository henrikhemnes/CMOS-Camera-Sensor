// State machine that controls reset, exposure, analog-to-digital
// conversion, and readout of the pixel array

`timescale 1 ns / 1 ps


module pixelState(
                       input  logic clk,
                       input  logic reset,
                       output logic erase,
                       output logic expose,
                       output logic[vertical_pixels-1:0] read,
                       output logic convert
                      );


   //State duration in clock cycles
   parameter integer c_erase = 5;
   parameter integer c_expose = 255;
   parameter integer c_convert = 255;
   parameter integer c_read = 5;

   parameter int horizontal_pixels = 2; 
   parameter int vertical_pixels = 2; 

   //------------------------------------------------------------
   // State Machine
   //------------------------------------------------------------
   parameter ERASE=0, EXPOSE=1, CONVERT=2, READ=3, IDLE=4;

   logic [2:0]         state, next_state; 
   int                 counter; //counts clk cycles
   int                 row_count = 0; //holds information on which row we are on

   // Control the output signals
   always_ff @(negedge clk ) begin
      case(state)
        ERASE: begin
           erase <= 1;
           read <= 0;
           expose <= 0;
           convert <= 0;
           row_count <= 0;
        end
        EXPOSE: begin
           erase <= 0;
           read <= 0;
           expose <= 1;
           convert <= 0;
        end
        CONVERT: begin
           erase <= 0;
           read <= 0;
           expose <= 0;
           convert = 1;
        end
        READ: begin
           erase <= 0;
           if(row_count == 0) begin
              read <= vertical_pixels'('b1); //set LSB in read to 1
           end
           else if (row_count > 0) begin 
               read <= vertical_pixels'('b1) << row_count; //Left shift '1' according to the row we are on
           end
           expose <= 0;
           convert <= 0;
        end
        IDLE: begin
           erase <= 0;
           expose <= 0;
           convert <= 0;
        end
      endcase // case (state)
   end // always @ (state)


   // Control of the state transitions.
   always_ff @(posedge clk or posedge reset) begin
      if(reset) begin
         state = IDLE;
         next_state = ERASE;
         counter  = 0;
         convert  = 0;
      end
      else begin
         case (state)
           ERASE: begin
              if(counter == c_erase) begin
                 next_state <= EXPOSE;
                 state <= IDLE;
              end
           end
           EXPOSE: begin
              if(counter == c_expose) begin
                 next_state <= CONVERT;
                 state <= IDLE;
              end
           end
           CONVERT: begin
              if(counter == c_convert) begin
                 next_state <= READ;
                 state <= IDLE;
              end
           end
            READ: begin //We will go to this state as long as there are more rows of pixels to read
             if(counter == c_read) begin
                if(row_count < vertical_pixels) begin
                   row_count++;
                   next_state <= READ;
                   state <= IDLE;
                end
                else begin
                  next_state <= ERASE;
                  state <= IDLE;
                end
             end
            end
           IDLE:
             state <= next_state;
         endcase // case (state)
         if(state == IDLE)
           counter = 0;
         else
           counter = counter + 1;
      end
   end // always @ (posedge clk or posedge reset)

endmodule // test
