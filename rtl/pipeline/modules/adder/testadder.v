`include "adder_half_precision.v"
module testadder(
	output reg [15:0] testintnum1,
	output reg [15:0] testintnum2,
	input wire [15:0] resultadder
);
real exp1, exp2, S1, S2, float1, float2;
real result, expresult, Sresult, porcentaje;
reg[3:0] i=0;
initial begin
		$display("In1:\t\tIn2:\t\tResult:\t\tError:");
	repeat(25) begin
#3 float1=0; float2=0; result=0; exp1=0; exp2=0; S1=0; S2=0; expresult=0; Sresult=0; porcentaje=0;
		testintnum1 = $random % 32768;
		testintnum2 = $random % 32768;
		S1 = (-1.0)**(testintnum1[15]);
		S2 = (-1.0)**(testintnum2[15]);
		exp1 = testintnum1[14:10]-15.0;
		exp2 = testintnum2[14:10]-15.0;
		for(i=1; i<10; i=i+1) begin
		if(testintnum1[i]==1'b1)
			float1 = float1 + 2.0**(-1.0*((10.0-i)));
		if(testintnum2[i]==1'b1)
			float2 = float2 + 2.0**(-1.0*((10.0-i)));
		end
		float1 = (S1)*(2.0**(exp1))*(1.0+float1);
		float2 = (S2)*(2.0**(exp2))*(1.0+float2);
#1
		Sresult = (-1.0)**(resultadder[15]);
		expresult = resultadder[14:10]-15.0;
		for(i=1; i<10; i=i+1) begin
		if(resultadder[i]==1'b1)
			result = result + 2.0**(-1.0*((10.0-i)));
		end
		result = (Sresult)*(2.0**(expresult))*(1.0+result);
		porcentaje = (float1+float2-result)/(float1+float2)*100;
		$display("%f\t",float1, "%f\t", float2,"%f\t", result, "%f %%",porcentaje);
	end
		#5 $finish;
end
adderhalfprecision c1 (
.i_Addend1(testintnum1),  
.i_Addend2(testintnum2),
.o_Sum(resultadder)
);
endmodule
