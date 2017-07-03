`timescale 1ns / 1ps


module vga_ctrl # (
       parameter X_WIDTH=7,
			 parameter Y_WIDTH=7
			 )
   (
    input wire 		     iClock,
    input wire 		     iReset,
    output [X_WIDTH-1:0] oVideoMemCol,
    output [Y_WIDTH-1:0] oVideoMemRow,
    output  	     oVGAHorizontalSync,
    output  	     oVGAVerticalSync,
    output         oDisplay
    );

   reg [9:0] 	      hCount = 0;
   reg [9:0] 	      vCount = 0;

   wire wOpen;
 	 assign wOpen = 1'bz;

   assign oVGAHorizontalSync = (hCount >= 656 && hCount <= 752)? 1'b0 : 1'b1;
   assign oVGAVerticalSync = (vCount >= 490 && vCount <= 492)? 1'b0 : 1'b1;
   assign oDisplay = (hCount <= 119 && vCount <= 119)? 1'b1 : 1'b0;

   assign oVideoMemCol 	= (oDisplay == 1'b1) ? hCount : 0;
   assign oVideoMemRow 	= (oDisplay == 1'b1) ? vCount : 0;


   always @(posedge Clk25Mhz)
      begin
	 if(iReset)
	    begin
	       hCount <= 0;
	       vCount <= 0;
	    end
	 else
	    begin
	       if (hCount < 799)
		  hCount <= hCount + 1;
	       else
		  begin
		     hCount <= 0;
		     if (vCount < 524)
			vCount <= vCount + 1;
		     else
			vCount <= 0;
		  end
	    end
      end


        // Clocking primitive
        //--------------------------------------

        // Instantiation of the DCM primitive
        //    * Unused inputs are tied off
        //    * Unused outputs are labeled unused
      DCM_SP #(
          .CLKDV_DIVIDE(2.000),
          .CLKFX_DIVIDE(32),
          .CLKFX_MULTIPLY(25),
          .CLKIN_DIVIDE_BY_2("FALSE"),
          .CLKIN_PERIOD(31.25),
          .CLKOUT_PHASE_SHIFT("NONE"),
          .CLK_FEEDBACK("1X"),
          .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"),
          .PHASE_SHIFT(0),
          .STARTUP_WAIT("FALSE")
      )
      DCM_SP_inst(
          // Input clock
          .CLKIN(iClock),
          .CLKFB(clkfb),
          // Output clocks
          .CLK0(clk0),
          .CLK90(wOpen),
          .CLK180(wOpen),
          .CLK270(wOpen),
          .CLK2X(wOpen),
          .CLK2X180(wOpen),
          .CLKFX(clkfx),
          .CLKFX180(wOpen),
          .CLKDV(wOpen),
          // Ports for dynamic phase shift
          .PSCLK(1'b0),
          .PSEN(1'b0),
          .PSINCDEC(1'b0),
          .PSDONE(wOpen),
          // Other control and status signals
          .LOCKED(),
          .STATUS(),
          .RST(1'b0),
          // Unused pin, tie low
          .DSSEN(1'b0)
          );

      // Output buffering
      // -------------------------------------

      BUFG BUFG_inst_1(
        .O(clkfb),
        .I(clk0)
      );


      BUFG BUFG_inst_2(
        .O(Clk25Mhz),
        .I(clkfx)
      );


endmodule
