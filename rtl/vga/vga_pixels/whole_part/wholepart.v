module wholepart(
output reg [16:0]	o_Pixeles,
input  wire [15:0]	i_ieee754
);

/*	initial 
	begin
		$dumpfile ("signals_wholepart.vcd");
		$dumpvars;
	end
*/
reg [3:0] i;
reg [8:0] var_shift;
reg [8:0] exp_real;

always @(i_ieee754) begin
	o_Pixeles = 9'd1 << i_ieee754[14:10]-5'd15;
	exp_real = 9'd1 << i_ieee754[14:10]-5'd15;
	for(i=0; i < 10; i=i+1 ) begin
		if( i_ieee754[9-i] == 1'b1 ) begin
		var_shift =  exp_real >> (i+1);
		o_Pixeles = o_Pixeles + var_shift;
		end
	end
end
endmodule
