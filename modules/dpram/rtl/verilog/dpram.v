`timescale 1ns / 1ns
// True Dual-Port memory with independent clocks, and independent read/writes
// At least Xilinx synthesis tools should "find" this as block memory. See:
// https://www.xilinx.com/support/documentation/sw_manuals/xilinx2017_1/ug901-vivado-synthesis.pdf
// page 118, 119
module dpram(
	clka, clkb,
	addra, douta, dina, wena,
	addrb, doutb, dinb, wenb
);
parameter aw=8;
parameter dw=8;
parameter sz=(32'b1<<aw)-1;
	input clka, clkb, wena, wenb;
	input [aw-1:0] addra, addrb;
	input [dw-1:0] dina, dinb;
	output [dw-1:0] douta, doutb;

reg [dw-1:0] mem[sz:0];
reg [dw-1:0] douta, doutb;

// In principle this should work OK for synthesis, but
// there seems to be a bug in the Xilinx synthesizer
// triggered when k briefly becomes sz+1.
`ifdef SIMULATE
integer k=0;
initial
begin
	for (k=0;k<sz+1;k=k+1)
	begin
		mem[k]=0;
	end
end
`endif

// Conflict resolution is read-first for both ports
always @(posedge clka) begin
	if (wena) mem[addra]<=dina;
	douta <= mem[addra];
end
always @(posedge clkb) begin
	if (wenb) mem[addrb]<=dinb;
	doutb <= mem[addrb];
end

endmodule
