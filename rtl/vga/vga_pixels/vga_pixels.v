`timescale 1ns / 1ps

//`include "../../pipeline/modules/adder/adder_half_precision.v"
//`include "../../pipeline/modules/multiplier/mult_half_precision.v"
//`include "../../pipeline/modules/divider/div_half_precision.v"
`include "./whole_part/wholepart.v"

module vga_pixels(
output reg [16:0]	o_PixelesX,
output reg [16:0]	o_PixelesY,
output reg		    o_Valid,
output reg		    o_Exception,
input  wire [15:0]	i_ieee754X,
input  wire [15:0]	i_ieee754Y
);


//Internal Variables
wire [15:0] H, W, twenty754, two754, _twenty754;
wire [15:0] wire1, wire2, wire3, wire6, wire7, wire8;
wire [16:0] wire4, wire9;
wire 		wire5, wire10, wire11, wire12, wire13, wire14;
wire exception;

//Assigns
assign twenty754[15:0] 	= 	16'b0100011000000000; // NOW IS 6
assign _twenty754[15:0]	= 	16'b1100011000000000; // NOW IS -6
assign two754[15:0]		=	16'b0100000000000000;
assign H[15:0]			=	16'b0101011110000000; //400 // NOW IS 120
assign W[15:0]			=	16'b0101011110000000; //400 // NOW IS 120
assign exception = wire11 || wire12 || wire13 || wire14;


	multhalfprecision pixmhp1( 	.i_Factor1(twenty754), 		.i_Factor2(i_ieee754X), 	.o_Product(wire1), .o_Exception(wire11)		);
	divhalfprecision  pixdhp1 (	.i_Dividend(W), 			.i_Divisor(two754),  		.o_Quotient(wire2), .o_Exception(wire12)	);
	adderhalfprecision pixahp1(	.i_Addend1(wire1), 			.i_Addend2(wire2), 			.o_Sum(wire3)								);
	wholepart			pixwp1( .i_ieee754(wire3),			.o_Pixeles(wire4)														);


	multhalfprecision pixmhp2( 	.i_Factor1(_twenty754), 	.i_Factor2(i_ieee754Y), 	.o_Product(wire6), .o_Exception(wire13)		);
	divhalfprecision  pixdhp2 (	.i_Dividend(H), 			.i_Divisor(two754),  		.o_Quotient(wire7), .o_Exception(wire14)	);
	adderhalfprecision pixahp2(	.i_Addend1(wire6), 			.i_Addend2(wire7), 			.o_Sum(wire8)								);
	wholepart			pixwp2( .i_ieee754(wire8),			.o_Pixeles(wire9)														);




	initial begin
		$dumpfile("signalspixeles.vcd");
		$dumpvars;
	end

always @(*)
	begin
	o_PixelesX = wire4;
	o_PixelesY = wire9;
	o_Exception = exception;
		if (wire4 < W || wire9 < H ) o_Valid = 1'b1;
		else o_Valid =  1'b0;
	end

endmodule
