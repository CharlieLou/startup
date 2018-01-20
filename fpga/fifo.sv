//this file is used to quickly save and output data and addr from image
//written by Charlie Lou
`define FIFO_LEN 			32
`define ADDR_LEN			64
`define DATA_LEN			64
`define NUM_WAY				3

module fifo( 
//input
input [`NUM_WAY-1: 0] ren,
input [`NUM_WAY-1: 0] wen,
input rst_n,
input clk,
input [`NUM_WAY-1: 0] [$clog2(`ADDR_LEN)-1:0]  addr_in,
input [`NUM_WAY-1: 0] [$clog2(`DATA_LEN)-1:0]  data_in,
//output
output full, near_full
//one hot style like 111, 011, 001, 000 for 3-way
//1:empty; 0: used
//wrong naming, just check if next N entries are used or not from head.
output [`NUM_WAY -1 :0] near_full_arr, //near full when empty entries is less than NUM_WAY
output empty,
//one hot style like 000, 100, 110, 111 for 3-way
//1: empty, 0: used
//wrong naming, just check if next N entries are used or not from tail.
output [`NUM_WAY-1 : 0] near_empty_arr, //near empty when used entries is less than NUM_WAY
output [`NUM_WAY-1: 0] [$clog2(`ADDR_LEN)-1:0] addr_out,
output [`NUM_WAY-1: 0] [$clog2(`DATA_LEN)-1:0] data_out,
output [`NUM_WAY-1]  success_in,
output [`NUM_WAY-1]  success_out,
output write_stall, read_stall 
);

//entry
logic [$clog2(`FIFO_LEN)-1:0] vld;
logic [$clog2(`FIFO_LEN)-1:0] [$clog2(`ADDR_LEN)-1:0] addr_entry;
logic [$clog2(`FIFO_LEN)-1:0] [$clog2(`DATA_LEN)-1:0] data_entry;
logic head, tail;

logic [`NUM_WAY-1:0] real_slot;

assign full =  &vld; 
assign empty = |vld;

assign near_full  = ~(&near_full_arr);
assign near_empty = ~(&near_empty_arr); 

assign write_stall = full & (~|real_slot);
assign read_stall  = empty;

//OR gate to get the true empty slot that could be used in next cycle.
assign real_slot  = near_full_arr | near_empty_arr;

assign success_in  = real_slot & wen;
assign success_out = (~near_full_arr) & ren;
always @(posedge clk or rst_n) begin
	if(~rst_n) begin
		vld <= 0;
		addr_entry <= 0;
		data_entry <= 0;
		head <= 0;
		tail <= 0;
	end else if begin
		//here, the length of i should be dedicated assigned for overflow usage.
		for(logic [$clog2(NUM_WAY)-1 : 0] i = 0; i <= `NUM_WAY-1; i++) begin
			if(success_in[i]) begin
				addr_entry[tail+i] <= addr_in[i];
				data_entry[tail+i] <= data_in[i];
			end
		end
		//a unique case for tail.
		for(logic [$clog2(NUM_WAY)-1 : 0] i = 0; i <= `NUM_WAY-1; i++) begin
			if(success_in[i]) begin
				tail <= tail + i +1;
			end
		end
		//a unique case for head
		for(logic [$clog2(NUM_WAY)-1 : 0] i = 0; i <= `NUM_WAY-1; i++) begin
			if(success_out[i]) begin
				head <= head + i +1;
			end
		end
		//vld, most difficult one, cause an entry could be read & written at the same time. so need to keep it remain valid.
		for(logic [$clog2(NUM_WAY)-1 : 0] i = 0; i <= `NUM_WAY-1; i++) begin
			if(sucess_out[i]) vld[head+i] <= 1'b0;
		end
		for(logic [$clog2(NUM_WAY)-1 : 0] i = 0; i <= `NUM_WAY-1; i++) begin
			if(sucess_in[i]) vld[tail +i] <= 1'b1;
		end
	end
end

//read_out
always_comb begin
	for(logic [$clog2(NUM_WAY)-1 : 0] i = 0; i <= `NUM_WAY-1; i++) begin
		if(success_out[i]) begin
			addr_out[i] = addr_entry[head+i];
			data_out[i] = data_entry[head+i];
		end else begin
			addr_out[i] = 0;
			data_out[i] = 0;
		end
	end
end

always_comb begin
	for(logic [$clog2(NUM_WAY)-1 : 0] i = 0; i <= `NUM_WAY-1; i++) begin
		near_empty_arr[i] = ~vld[tail+i];
		near_full_arr[i]  = ~vld[head+i];
	end	
end	
endmodule
