//-----------------------------------------------------
// Design Name : divhalfprecision
// File Name   : divhalfprecision.v
// Coder     : Badilla
//-----------------------------------------------------
module divhalfprecision(
output reg [15:0] 	o_Quotient,		// Output of the division.
output reg		  	o_Exception,	// Output division by zero.
input wire [15:0]   i_Dividend,		// Input Dividend.
input wire [15:0]	i_Divisor		// Input Divisor.
);
	initial
	begin
		$dumpfile ("signals.vcd");
		$dumpvars;
	end

//Internal Variables
wire[10:0] w_Mantissa_Division	; 
wire[4:0]  w_Sub_Exps	;
wire 		w_XOR_Sign	;
reg 		r_one_found	;
reg[3:0] 	counter_shift_mantissa	;
wire[10:0] w_mantisa_shifted	;
reg[3:0] i	;

//Assignments:
assign w_Mantissa_Division[10:0] = {1'b1,i_Dividend[9:0],10'b0} / {1'b1,i_Divisor[9:0]};
assign w_Sub_Exps[4:0] = i_Dividend[14:10] - i_Divisor[14:10];
assign w_XOR_Sign = i_Dividend[15] ^ i_Divisor[15];

//Code Starts Here
	always @(*) begin
		if (i_Divisor[14:0] == 15'd0) begin //Exception.
			o_Quotient[15:0] = 16'bz;
			o_Exception = 1'b1;
		end
		else if (i_Dividend[14:0] == 15'd0) begin // Special case, dividend zero.
			o_Quotient[15:0] = 16'd0;
			o_Exception = 1'b0;
		end
		else if ( i_Dividend[14:10] > i_Divisor[14:10] ) begin
			o_Exception = 1'b0;				
			o_Quotient[15] = w_XOR_Sign;
			r_one_found = 1'b0;
			counter_shift_mantissa[3:0] = 4'd0;
			for(i=11; i >= 1; i=i-1 ) begin //Normalizing the mantissa and update the exponent.
				if(w_Mantissa_Division[i-1] == 0 && r_one_found == 1'b0)
				counter_shift_mantissa[3:0] = counter_shift_mantissa[3:0] + 4'b0001;
				else
				r_one_found = 1'b1;
				end
				if(w_Sub_Exps[4:0] - counter_shift_mantissa[3:0] > 16)
				o_Quotient[15:0] = 16'b0111111111111111; //Overflow
				else begin
					o_Quotient[15] = w_XOR_Sign;
					o_Quotient[14:10] = w_Sub_Exps[4:0]-counter_shift_mantissa[3:0]+5'd15;					
					o_Quotient[9:0] = w_Mantissa_Division[10:0] << counter_shift_mantissa[3:0];
				end
			end
			else if(i_Dividend[14:10] < i_Divisor[14:10]) begin
				o_Exception = 1'b0;
				o_Quotient[15] = w_XOR_Sign;
				r_one_found = 1'b0;
				counter_shift_mantissa[3:0] = 4'd0; 
				for(i=11; i >= 1; i=i-1 ) begin //Normalizing the mantissa and update the exponent.
					if(w_Mantissa_Division[i-1] == 0 && r_one_found == 1'b0)
					counter_shift_mantissa[3:0] = counter_shift_mantissa[3:0] + 4'b0001;
					else
					r_one_found = 1'b1;
					end
					if(w_Sub_Exps[4:0] - counter_shift_mantissa[3:0] < 16)
						o_Quotient[15:0] = 16'd0; //Underflow
					else begin
						o_Quotient[15] = w_XOR_Sign;
						o_Quotient[14:10] = w_Sub_Exps[4:0]-counter_shift_mantissa[3:0]+5'd15;					
						o_Quotient[9:0] = w_Mantissa_Division[10:0] << counter_shift_mantissa[3:0];
					end					
				end
			else if(i_Dividend[14:10] == i_Divisor[14:10]) begin
				o_Exception = 1'b0;
				o_Quotient[15] = w_XOR_Sign;
				r_one_found = 1'b0;
				counter_shift_mantissa[3:0] = 4'd0;
				for(i=11; i >= 1; i=i-1 ) begin //Normalizing the mantissa and update the exponent.
					if(w_Mantissa_Division[i-1] == 0 && r_one_found == 1'b0)
					counter_shift_mantissa[3:0] = counter_shift_mantissa[3:0] + 4'b0001;
					else
					r_one_found = 1'b1;
					end
					o_Quotient[14:10] = -counter_shift_mantissa[3:0]+5'd15;	
					o_Quotient[9:0] = w_Mantissa_Division[10:0] << counter_shift_mantissa[3:0];
				end
			else begin
				o_Quotient[15:0] = 16'bz;
				o_Exception = 1'b1;
			end
		end
endmodule
