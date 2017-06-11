//-----------------------------------------------------
// Design Name	: adderhalfprecision
// File Name	: adderhalfprecision.v
// Coder		: Badilla
//-----------------------------------------------------
module adderhalfprecision(
output reg [15:0]  	o_Sum,		// Output of the sum.
input wire [15:0]   i_Addend1,	//Input Addend 1.
input wire [15:0]   i_Addend2	//Input Addend 2.
);
/*	initial 
	begin
		$dumpfile ("signals_adder.vcd");
		$dumpvars;
	end
*/
//Internal Variables
reg[15:0] r_higher_addend	;
reg[15:0] r_lower_addend	;
reg		  r_one_found	;
reg[3:0] counter_shift_mantissa	;
wire[4:0] w_sub_exps	;
wire[10:0] w_mantisa_shifted	;
wire w_XOR_Sign	;
wire[10:0] w_sub_result_mantisa	;
wire[10:0] w_sub_result_mantisa_l_h;
wire[11:0] w_add_result_mantisa	;
reg[3:0] i	;

//Assignments:
assign w_sub_exps[4:0] = r_higher_addend[14:10] - r_lower_addend[14:10];
assign w_mantisa_shifted[10:0] =  {1'b1,r_lower_addend[9:0]} >> w_sub_exps[4:0];
assign w_XOR_Sign = i_Addend1[15] ^ i_Addend2[15];
assign w_sub_result_mantisa[10:0] = {1'b1,r_higher_addend[9:0]} - w_mantisa_shifted[10:0];
assign w_sub_result_mantisa_l_h[10:0] = {1'b1,r_lower_addend[9:0]} - {1'b1,r_higher_addend[9:0]};
assign w_add_result_mantisa[11:0] = {1'b1,r_higher_addend[9:0]} + w_mantisa_shifted[10:0];

//Code Starts Here
	always @(*) begin
		if (i_Addend1[14:10] >= i_Addend2[14:10]) begin//Choose the higher exponent of the addend.
			r_higher_addend[15:0] = i_Addend1[15:0];
			r_lower_addend[15:0]  = i_Addend2[15:0];
		end
		else begin
			r_higher_addend[15:0] = i_Addend2[15:0];
			r_lower_addend[15:0]  = i_Addend1[15:0];
		end
//-
		if(r_higher_addend[14:10] == r_lower_addend[14:10]) begin //Equal exponents.
			if(r_higher_addend[14:0]==0 && r_lower_addend[14:0]==0) //Special case: 0+0.
				o_Sum[15:0] = 16'd0;	
			else if(w_XOR_Sign) begin//Different sign
				if(r_higher_addend[9:0] == r_lower_addend[9:0]) //Equal mantissa.
					o_Sum[15:0] = 16'b0;
				else if(r_higher_addend[9:0] > r_lower_addend[9:0]) begin //Normalizing the mantissa and update the exponent.
					r_one_found = 1'b0;
					counter_shift_mantissa[3:0] = 4'd0;
					for(i=11; i >= 1; i=i-1 ) begin 
						if(w_sub_result_mantisa[i-1] == 0 && r_one_found == 1'b0)
							counter_shift_mantissa[3:0] = counter_shift_mantissa[3:0] + 4'b0001;
						else begin
							r_one_found = 1'b1;
							o_Sum[15] = r_higher_addend[15];
							o_Sum[14:10] = r_higher_addend[14:10] - {1'b0,counter_shift_mantissa[3:0]};
							o_Sum[9:0] = w_sub_result_mantisa[10:0] << counter_shift_mantissa[3:0];
						end
					end
				end
				else begin //Normalizing the mantissa and update the exponent.
					r_one_found = 1'b0;
					counter_shift_mantissa[3:0] = 4'd0;
					for(i=11; i >= 1; i=i-1 ) begin
						if(w_sub_result_mantisa_l_h[i-1] == 0 && r_one_found == 1'b0)
							counter_shift_mantissa[3:0] = counter_shift_mantissa[3:0] + 4'b0001;
						else begin
							r_one_found = 1'b1;
							o_Sum[15] = r_lower_addend[15];
							o_Sum[14:10] = r_higher_addend[14:10] - {1'b0,counter_shift_mantissa[3:0]};
							o_Sum[9:0] = w_sub_result_mantisa_l_h[10:0] << counter_shift_mantissa[3:0];
						end
					end
				end
			end
			else begin //Not necessary shift mantissa
				o_Sum[15] = r_higher_addend[15];
				o_Sum[14:10] = r_higher_addend[14:10]+1'b1;
				o_Sum[9:0] = w_add_result_mantisa[11:1];
			end
		end
		else if (r_higher_addend[14:10] - r_lower_addend[14:10] > 5'd10) //Underflow
			o_Sum[15:0] = r_higher_addend[15:0];
		else begin //General case
			o_Sum[15] = r_higher_addend[15];			
				if(w_XOR_Sign) begin
					r_one_found = 1'b0;
					counter_shift_mantissa[3:0] = 4'd0;
					for(i=11; i >= 1; i=i-1 ) //Normalizing the mantissa and update the exponent.
							begin
							if(w_sub_result_mantisa[i-1] == 0 && r_one_found == 1'b0) 
								counter_shift_mantissa[3:0] = counter_shift_mantissa[3:0] + 4'b0001;
							else
							r_one_found = 1'b1;
							end
					o_Sum[14:10] = r_higher_addend[14:10] - {1'b0,counter_shift_mantissa[3:0]};
					o_Sum[9:0] = w_sub_result_mantisa[10:0] << counter_shift_mantissa[3:0];
					end
				else //equal sign
					begin
						if(w_add_result_mantisa[11] == 1'b1)
							begin
								o_Sum[14:10] =  r_higher_addend[14:10]+5'b00001;
								o_Sum[9:0] = w_add_result_mantisa[10:1];
							end
						else
							begin
								o_Sum[14:10] =  r_higher_addend[14:10];
								o_Sum[9:0] = w_add_result_mantisa[9:0];
							end
					end
			end			
		end
endmodule
