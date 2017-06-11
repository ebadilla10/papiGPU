`include "graphics_pipeline.v"
module test(
output  reg [15:0]	o_CamVerX, o_CamVerY, o_CamVerZ,
output  reg [15:0]	o_CamDc,
output  reg [15:0]	o_CosRoll, o_CosPitch, o_CosYaw,
output  reg [15:0]	o_SenRoll, o_SenPitch,o_SenYaw,
output  reg [15:0]	o_ScaleX, o_ScaleY, o_ScaleZ,
output  reg [15:0]	o_TranslX, o_TranslY, o_TranslZ,
output  reg [15:0]	o_VertexX, o_VertexY, o_VertexZ
);

initial begin
		#1
/*	params = 't_x': -7.6, 't_y': -3.5, 't_z': 25,
		  	'cos_pitch': 1, 'cos_yaw': 0.5, 'cos_roll': 0.5,
			'sen_pitch': 0, 'sen_yaw': 0.866, 'sen_roll': 0.866,
		  	's_x': -3.75, 's_y': 14.0, 's_z': -3.5,
			'c_x': 13.0, 'c_y': 4.0, 'c_z': -8.0,
			'X': -21, 'Y': 7.5, 'Z': -5.0,
			'd_f': 7.0
*/
	o_TranslX	=	16'b1100011110011001;
	o_TranslY	=	16'b1100001100000000;
	o_TranslZ	=	16'b0100111001000000;

	o_CosRoll	= 	16'b0011100000000000;
	o_CosPitch	= 	16'b0011110000000000;
	o_CosYaw	= 	16'b0011100000000000;

	o_SenRoll	= 	16'b0011101011101101;
	o_SenPitch	=	16'b0000000000000000;
	o_SenYaw	=	16'b0011101011101101;

	o_ScaleX	= 	16'b0100101100000000;
	o_ScaleY	=	16'b0100101100000000;
	o_ScaleZ	=	16'b1100001100000000;

	o_CamVerX	= 	16'b0100101010000000;
	o_CamVerY	=	16'b0100010000000000;
	o_CamVerZ	= 	16'b1100100000000000;

	o_VertexX	=	16'b0100011110000000;
	o_VertexY	=	16'b0100011110000000;
	o_VertexZ	=	16'b1100010100000000;

	o_CamDc		= 	16'b0100011100000000;
	#5
	$finish;
	end

graphicspipeline gp1 (
	.i_CamVerX(o_CamVerX),	.i_CamVerY(o_CamVerY),	.i_CamVerZ(o_CamVerZ),
	.i_CamDc(o_CamDc),  	.i_CosRoll(o_CosRoll),	.i_CosPitch(o_CosPitch),
	.i_CosYaw(o_CosYaw),	.i_SenRoll(o_SenRoll), 	.i_SenPitch(o_SenPitch),
	.i_SenYaw(o_SenYaw), 	.i_ScaleX(o_ScaleX),  	.i_ScaleY(o_ScaleY),
	.i_ScaleZ(o_ScaleZ), 	.i_TranslX(o_TranslX), 	.i_TranslY(o_TranslY),
	.i_TranslZ(o_TranslZ),	.i_VertexX(o_VertexX), 	.i_VertexY(o_VertexY),
	.i_VertexZ(o_VertexZ)
	);

endmodule











