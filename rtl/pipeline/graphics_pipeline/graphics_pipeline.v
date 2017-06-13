`include "../../../rtl/pipeline/modules/adder/adder_half_precision.v"
`include "../../../rtl/pipeline/modules/multiplier/mult_half_precision.v"
`include "../../../rtl/pipeline/modules/divider/div_half_precision.v"
//-----------------------------------------------------
// Design Name : graphicspipeline
// File Name   : graphicspipeline.v
// Coder     : Badilla
//-----------------------------------------------------
module graphicspipeline(
output reg [15:0]	o_X, o_Y,
output reg		    o_Exception,	
input  wire [15:0]	i_CamVerX, i_CamVerY, i_CamVerZ,
input  wire [15:0]	i_CamDc,
input  wire [15:0]	i_CosRoll, i_CosPitch, i_CosYaw,
input  wire [15:0]	i_SenRoll, i_SenPitch, i_SenYaw,
input  wire [15:0]	i_ScaleX,  i_ScaleY,   i_ScaleZ,
input  wire [15:0]	i_TranslX, i_TranslY,  i_TranslZ,
input  wire [15:0]	i_VertexX, i_VertexY,  i_VertexZ
);

//Internal Variables
wire [15:0] w_wire1, w_wire2, w_wire3, w_wire4;
wire [15:0] w_wire5, w_wire6, w_wire7, w_wire8;
wire [15:0] w_wire9, w_wire10, w_wire11, w_wire12;
wire [15:0] w_wire13, w_wire14, w_wire15, w_wire16;
wire [15:0] w_wire17, w_wire18, w_wire19, w_wire20;
wire [15:0] w_wire21, w_wire22, w_wire23, w_wire24;
wire [15:0] w_wire25, w_wire26, w_wire27, w_wire28;
wire [15:0] w_wire29, w_wire30, w_wire31, w_wire32;
wire [15:0] w_wire33, w_wire34, w_wire35, w_wire36;
wire [15:0] w_wire37, w_wire38, w_wire39, w_wire40;	
wire [15:0] w_wire41, w_wire42, w_wire43, w_wire44;
wire [15:0] w_wire45, w_wire46, w_wire47, w_wire48;
wire [15:0] w_wire49, w_wire50, w_wire51, w_wire52;
wire [15:0] w_wire53, w_wire54, w_wire55, w_wire56;
wire 		exc, w_wire_exc_div1, w_wire_exc_div2;
wire 		w_wire_exc_mult1, w_wire_exc_mult2, w_wire_exc_mult3, w_wire_exc_mult4, w_wire_exc_mult5;
wire 		w_wire_exc_mult6, w_wire_exc_mult7, w_wire_exc_mult8, w_wire_exc_mult9, w_wire_exc_mult10;
wire 		w_wire_exc_mult11, w_wire_exc_mult12, w_wire_exc_mult13, w_wire_exc_mult14, w_wire_exc_mult15;
wire 		w_wire_exc_mult16, w_wire_exc_mult17, w_wire_exc_mult18, w_wire_exc_mult19, w_wire_exc_mult20;
wire 		w_wire_exc_mult21, w_wire_exc_mult22, w_wire_exc_mult23, w_wire_exc_mult24, w_wire_exc_mult25;
wire 		w_wire_exc_mult26, w_wire_exc_mult27, w_wire_exc_mult28, w_wire_exc_mult29, w_wire_exc_mult30;
wire 		w_wire_exc_mult31, w_wire_exc_mult32, w_wire_exc_mult33, w_wire_exc_mult34, w_wire_exc_mult35;
wire 		w_wire_exc_mult36, w_wire_exc_mult37;
wire  [15:0] Const_neg;
	
//Assignments:
assign exc = w_wire_exc_div1||w_wire_exc_div2||w_wire_exc_mult1||w_wire_exc_mult2||w_wire_exc_mult3||w_wire_exc_mult4||w_wire_exc_mult5||w_wire_exc_mult6||w_wire_exc_mult7||w_wire_exc_mult8||w_wire_exc_mult9||w_wire_exc_mult10||w_wire_exc_mult11||w_wire_exc_mult12||w_wire_exc_mult13||w_wire_exc_mult14||w_wire_exc_mult15||w_wire_exc_mult16||w_wire_exc_mult17||w_wire_exc_mult18||w_wire_exc_mult19||w_wire_exc_mult20||w_wire_exc_mult21||w_wire_exc_mult22||w_wire_exc_mult23||w_wire_exc_mult24||w_wire_exc_mult25||w_wire_exc_mult26||w_wire_exc_mult27||w_wire_exc_mult28||w_wire_exc_mult29||w_wire_exc_mult30||w_wire_exc_mult31||w_wire_exc_mult32||w_wire_exc_mult33||w_wire_exc_mult34||w_wire_exc_mult35||w_wire_exc_mult36||w_wire_exc_mult37;
assign Const_neg = 16'b1011110000000000;

//To obtain x': w_wire19, output of ahp4.
	multhalfprecision mhp1( 	.i_Factor1(i_CosYaw), 	.i_Factor2(i_CosRoll), 	.o_Product(w_wire1), .o_Exception(w_wire_exc_mult1)		);
	multhalfprecision mhp2( 	.i_Factor1(i_SenYaw), 	.i_Factor2(i_SenPitch),	.o_Product(w_wire2), .o_Exception(w_wire_exc_mult2)		);
	multhalfprecision mhp3( 	.i_Factor1(w_wire2), 	.i_Factor2(i_SenRoll), 	.o_Product(w_wire3), .o_Exception(w_wire_exc_mult3)		);
	multhalfprecision mhp4( 	.i_Factor1(i_VertexX), 	.i_Factor2(i_ScaleX), 	.o_Product(w_wire5), .o_Exception(w_wire_exc_mult4)		);
	multhalfprecision mhp5( 	.i_Factor1(w_wire4), 	.i_Factor2(w_wire5), 	.o_Product(w_wire6), .o_Exception(w_wire_exc_mult5)		);
	multhalfprecision mhp6( 	.i_Factor1(i_SenYaw), 	.i_Factor2(i_SenPitch), .o_Product(w_wire7), .o_Exception(w_wire_exc_mult6)		);
	multhalfprecision mhp7( 	.i_Factor1(w_wire7), 	.i_Factor2(i_CosRoll), 	.o_Product(w_wire8), .o_Exception(w_wire_exc_mult7)		);
	multhalfprecision mhp8( 	.i_Factor1(Const_neg),	.i_Factor2(i_CosYaw), 	.o_Product(w_wire9), .o_Exception(w_wire_exc_mult8)		);
	multhalfprecision mhp9( 	.i_Factor1(w_wire9), 	.i_Factor2(i_SenRoll), 	.o_Product(w_wire10), .o_Exception(w_wire_exc_mult9)	);
	multhalfprecision mhp10(	.i_Factor1(i_VertexY), 	.i_Factor2(i_ScaleY), 	.o_Product(w_wire12), .o_Exception(w_wire_exc_mult10)	);
	multhalfprecision mhp11(	.i_Factor1(w_wire11), 	.i_Factor2(w_wire12), 	.o_Product(w_wire13), .o_Exception(w_wire_exc_mult11)	);
	multhalfprecision mhp12(	.i_Factor1(i_SenYaw), 	.i_Factor2(i_CosPitch), .o_Product(w_wire15), .o_Exception(w_wire_exc_mult12)	);
	multhalfprecision mhp13(	.i_Factor1(i_VertexZ), 	.i_Factor2(i_ScaleZ), 	.o_Product(w_wire16), .o_Exception(w_wire_exc_mult13)	);
	multhalfprecision mhp14(	.i_Factor1(w_wire15), 	.i_Factor2(w_wire16), 	.o_Product(w_wire17), .o_Exception(w_wire_exc_mult14)	);
	adderhalfprecision ahp1(	.i_Addend1(w_wire1), 	.i_Addend2(w_wire3), 	.o_Sum(w_wire4));
	adderhalfprecision ahp2(	.i_Addend1(w_wire6), 	.i_Addend2(w_wire13), 	.o_Sum(w_wire14));
	adderhalfprecision ahp3(	.i_Addend1(w_wire8), 	.i_Addend2(w_wire10), 	.o_Sum(w_wire11));
	adderhalfprecision ahp4(	.i_Addend1(w_wire14), 	.i_Addend2(w_wire18), 	.o_Sum(w_wire19));
	adderhalfprecision ahp5(	.i_Addend1(w_wire17), 	.i_Addend2(i_TranslX), 	.o_Sum(w_wire18));
//To obtain y': w_wire29, output of ahp8.
	multhalfprecision mhp15( 	.i_Factor1(i_CosPitch), .i_Factor2(i_SenRoll), 	.o_Product(w_wire20), .o_Exception(w_wire_exc_mult15)	);
	multhalfprecision mhp16( 	.i_Factor1(i_CosPitch), .i_Factor2(i_CosRoll), 	.o_Product(w_wire22), .o_Exception(w_wire_exc_mult16)	);
	multhalfprecision mhp17( 	.i_Factor1(Const_neg), 	.i_Factor2(i_SenPitch),	.o_Product(w_wire24), .o_Exception(w_wire_exc_mult17)	);
	multhalfprecision mhp18( 	.i_Factor1(w_wire5), 	.i_Factor2(w_wire20), 	.o_Product(w_wire21), .o_Exception(w_wire_exc_mult18)	);
	multhalfprecision mhp19( 	.i_Factor1(w_wire12), 	.i_Factor2(w_wire22), 	.o_Product(w_wire23), .o_Exception(w_wire_exc_mult19)	);
	multhalfprecision mhp20( 	.i_Factor1(w_wire16), 	.i_Factor2(w_wire24), 	.o_Product(w_wire25), .o_Exception(w_wire_exc_mult20)	);
	adderhalfprecision ahp6(	.i_Addend1(w_wire21), 	.i_Addend2(w_wire23), 	.o_Sum(w_wire26)		);
	adderhalfprecision ahp7(	.i_Addend1(w_wire25), 	.i_Addend2(i_TranslY), 	.o_Sum(w_wire27)		);
	adderhalfprecision ahp8(	.i_Addend1(w_wire26), 	.i_Addend2(w_wire27), 	.o_Sum(w_wire28)		);
//To obtain z': w_wire44, output of ahp13.
	multhalfprecision mhp21( 	.i_Factor1(i_CosYaw), 	.i_Factor2(i_SenPitch),	.o_Product(w_wire29), .o_Exception(w_wire_exc_mult21)	);
	multhalfprecision mhp22( 	.i_Factor1(Const_neg), 	.i_Factor2(i_SenYaw), 	.o_Product(w_wire30), .o_Exception(w_wire_exc_mult22)	);
	multhalfprecision mhp23( 	.i_Factor1(i_CosYaw), 	.i_Factor2(i_SenPitch), .o_Product(w_wire31), .o_Exception(w_wire_exc_mult23)	);
	multhalfprecision mhp24( 	.i_Factor1(i_SenYaw), 	.i_Factor2(i_SenRoll), 	.o_Product(w_wire32), .o_Exception(w_wire_exc_mult24)	);
	multhalfprecision mhp25( 	.i_Factor1(i_CosYaw), 	.i_Factor2(i_CosPitch), .o_Product(w_wire33), .o_Exception(w_wire_exc_mult25)	);
	multhalfprecision mhp26( 	.i_Factor1(w_wire29), 	.i_Factor2(i_SenRoll), 	.o_Product(w_wire34), .o_Exception(w_wire_exc_mult26)	);
	multhalfprecision mhp27( 	.i_Factor1(w_wire30), 	.i_Factor2(i_CosRoll), 	.o_Product(w_wire35), .o_Exception(w_wire_exc_mult27)	);
	multhalfprecision mhp28( 	.i_Factor1(w_wire31), 	.i_Factor2(i_CosRoll), 	.o_Product(w_wire36), .o_Exception(w_wire_exc_mult28)	);
	multhalfprecision mhp29( 	.i_Factor1(w_wire16), 	.i_Factor2(w_wire33), 	.o_Product(w_wire37), .o_Exception(w_wire_exc_mult29)	);
	multhalfprecision mhp30( 	.i_Factor1(w_wire5), 	.i_Factor2(w_wire38), 	.o_Product(w_wire40), .o_Exception(w_wire_exc_mult30)	);
	multhalfprecision mhp31( 	.i_Factor1(w_wire12), 	.i_Factor2(w_wire39), 	.o_Product(w_wire41), .o_Exception(w_wire_exc_mult31)	);
	adderhalfprecision ahp9(	.i_Addend1(w_wire34), 	.i_Addend2(w_wire35), 	.o_Sum(w_wire38)		);
	adderhalfprecision ahp10(	.i_Addend1(w_wire36), 	.i_Addend2(w_wire32), 	.o_Sum(w_wire39)		);
	adderhalfprecision ahp11(	.i_Addend1(w_wire40), 	.i_Addend2(w_wire41), 	.o_Sum(w_wire42)		);
	adderhalfprecision ahp12(	.i_Addend1(w_wire37), 	.i_Addend2(i_TranslZ), 	.o_Sum(w_wire43)		);
	adderhalfprecision ahp13(	.i_Addend1(w_wire42), 	.i_Addend2(w_wire43), 	.o_Sum(w_wire44)		);
////To obtain respect to the camera.
	multhalfprecision mhp32( 	.i_Factor1(Const_neg), 	.i_Factor2(i_CamVerX), 	.o_Product(w_wire45), .o_Exception(w_wire_exc_mult32)	);
	multhalfprecision mhp33( 	.i_Factor1(Const_neg), 	.i_Factor2(i_CamVerY), 	.o_Product(w_wire46), .o_Exception(w_wire_exc_mult33)	);
	multhalfprecision mhp34( 	.i_Factor1(Const_neg), 	.i_Factor2(i_CamVerZ), 	.o_Product(w_wire47), .o_Exception(w_wire_exc_mult34)	);
	multhalfprecision mhp35( 	.i_Factor1(w_wire48), 	.i_Factor2(Const_neg), 	.o_Product(w_wire51), .o_Exception(w_wire_exc_mult35)	);
	multhalfprecision mhp36( 	.i_Factor1(w_wire51), 	.i_Factor2(i_CamDc), 	.o_Product(w_wire52), .o_Exception(w_wire_exc_mult36)	);
	multhalfprecision mhp37( 	.i_Factor1(w_wire49), 	.i_Factor2(i_CamDc), 	.o_Product(w_wire53), .o_Exception(w_wire_exc_mult37)	);
	adderhalfprecision ahp14(	.i_Addend1(w_wire45), 	.i_Addend2(w_wire19), 	.o_Sum(w_wire48)		);
	adderhalfprecision ahp15(	.i_Addend1(w_wire46), 	.i_Addend2(w_wire28), 	.o_Sum(w_wire49)		);
	adderhalfprecision ahp16(	.i_Addend1(w_wire47), 	.i_Addend2(w_wire44), 	.o_Sum(w_wire50)		);
	divhalfprecision dhp1 (.i_Dividend(w_wire52), .i_Divisor(w_wire50),  .o_Quotient(w_wire54), .o_Exception(w_wire_exc_div1));
	divhalfprecision dhp2 (.i_Dividend(w_wire53), .i_Divisor(w_wire50),  .o_Quotient(w_wire55), .o_Exception(w_wire_exc_div2));
//---------------------------------------
	initial begin
		$dumpfile ("signalsgp.vcd");
		$dumpvars;
	end

always @(*)
	begin
	o_X = w_wire54;
	o_Y = w_wire55;
	o_Exception = exc;
	end
endmodule
