//-----------------------------------------------------
// Design Name : multhalfprecision
// File Name   : multhalfprecision.v
// Coder     : Badilla
//-----------------------------------------------------
module multhalfprecision(
output reg [15:0]	o_Product,	//Output of the mult
output reg 			o_Exception,
input wire [15:0]   i_Factor1,	//Input Factor 1
input wire [15:0]   i_Factor2	//Input Factor 2
);
/*	initial
	begin
		$dumpfile ("signals_multiplier.vcd");
		$dumpvars;
	end
*/
//------------Internal Variables--------
wire[21:0]	w_Mantissa_Product;
wire[4:0]	w_Sum_Exps;
wire		w_AND_MSB_Exps;
wire 		w_NOR_MSB_Exps;

//Assignments:
	assign w_Mantissa_Product[21:0] = {1'b1,i_Factor1[9:0]}*{1'b1,i_Factor2[9:0]};
	assign w_Sum_Exps[4:0] = i_Factor1[14:10] + i_Factor2[14:10];
	assign w_AND_MSB_Exps = i_Factor1[14] && i_Factor2[14];
	assign w_NOR_MSB_Exps = ~(i_Factor1[14] ||  i_Factor2[14]);

//Code Starts Here
	always @(*) begin
		if (i_Factor1[14:0] == 15'b0 || i_Factor2[14:0] == 15'b0) begin //Special case, some is zero.
		o_Product[15:0] = 16'b0;
		o_Exception = 1'b0;
		end
		else if ( (w_AND_MSB_Exps == 1'b1 && w_Sum_Exps[4:0] >= 5'd14 )) begin //Positive exponents, no more than 14 the sum, else overflow.
		o_Product[15] = i_Factor1[15] ^ i_Factor2[15];
			if(w_Sum_Exps[4:0] == 5'd14) begin//Sum of exponets equal zero, depends of the result mantissa overflow or not.
			o_Product[14:0] = (w_Mantissa_Product[21]) ? 15'b111111111111111 : {5'b11111,w_Mantissa_Product[19:10]};
			o_Exception = (w_Mantissa_Product[21]) ? 1'b1 : 1'b0;
			end
			else begin
			o_Product[14:0] = 15'b111111111111111;
			o_Exception = 1'b1;
			end
		end
		else if((w_NOR_MSB_Exps == 1'b1) && (w_Sum_Exps[4:0] < 5'd15)) begin //Negative exponents, no less than 15 the sum, else underflow.
		o_Product[15] = i_Factor1[15] ^ i_Factor2[15];
		o_Product[14:0] = 15'd0;
		o_Exception = 1'b1;
		end
		else begin //General case.
		o_Product[15] = i_Factor1[15] ^ i_Factor2[15];
			if ( (i_Factor1[14:10] == 5'b11111 && i_Factor2[14:10]==5'b01111) || (i_Factor2[14:10]==5'b11111 && i_Factor1[14:10] == 5'b01111) ) begin
				o_Product[14:0] = (w_Mantissa_Product[21]) ? 15'b111111111111111 : {5'b11111,w_Mantissa_Product[19:10]};
				o_Exception = (w_Mantissa_Product[21]) ? 1'b1 : 1'b0;
				end
			else begin
				o_Product[14:10] = (w_Mantissa_Product[21]) ? i_Factor1[14:10] + i_Factor2[14:10] - 5'd14 : i_Factor1[14:10] + i_Factor2[14:10] - 5'd15; // E_1 - 15 + E_2 - 15 + 1 + 15
				o_Product[9:0]   = (w_Mantissa_Product[21]) ? w_Mantissa_Product[20:11] : w_Mantissa_Product[19:10];
				o_Exception = 1'b0;
			end
		end
	end
endmodule
