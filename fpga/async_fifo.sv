`define FIFO_LEN  32 
module grey2bin(
	input  [$clog2(`FIFO_LEN)-1 : 0] grey_in,
	output [$clog2(`FIFO_LEN)-1 : 0] bin_out
);
	always_comb begin
		bin_out[$clog2(`FIFO_LEN)-1] = grey_in[$clog2(`FIFO_LEN)-1];
		for(integer i = 1; i <= n-1; i++) begin
			bin_out[i-1] = grey_in[i-1] ^ bin_out[i];
		end
	end
endmodule

module bin2grey(
	input  [$clog2(`FIFO_LEN)-1 : 0] bin_in,
	output [$clog2(`FIFO_LEN)-1 : 0] grey_out
);
	assign grey_out = bin_in>>1 ^ bin_in;
endmodule
		
module async_fifo(
);

endmodule
