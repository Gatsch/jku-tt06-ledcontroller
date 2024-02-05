`default_nettype none
`ifndef __i2c_led__
`define __i2c_led__
`include "i2c.v"
`include "led.v"

module ledcontroller #(
	parameter ADDRESS = 7'h69,
	parameter CLK_SPEED = 25_000_000,
	parameter LED_CNT = 3
)(
	input wire scl_i,
	output wire scl_o,
	input wire sda_i,
	output wire sda_o,
	output wire led_o,
	input wire clk,
	input wire reset
);

	
	localparam DATAWIDTH = LED_CNT*3*8;
//	localparam DATAWIDTH = DATAWIDTH32[$clog2(DATAWIDTH32)-1:0];
	localparam DATACOUNTWIDTH32 = $clog2(LED_CNT*3);
	localparam DATACOUNTWIDTH = DATACOUNTWIDTH32[DATACOUNTWIDTH32:0];

	wire [7:0] data;
	wire [7:0] address;
	wire data_valid;
	wire start;
	wire stop;
	reg [DATAWIDTH-1:0]leddata;
	
	
	localparam IDLE = 2'd0;
	localparam WAIT = 2'd1;
	localparam WRITE = 2'd2;
	reg [1:0] state, next_state;
	reg [DATACOUNTWIDTH-1:0] datacounter, next_datacounter;
	integer i;
	
	
	i2c 
		#(.ADDRESS(ADDRESS))
		i2c_dut (
			.scl_i(scl_i),
			.scl_o(scl_o),
			.sda_i(sda_i),
			.sda_o(sda_o),
			.clk(clk),
			.reset(reset),
			.address(address),
			.data(data),
			.data_valid_o(data_valid),
			.start(start),
			.stop(stop)
		);


	led 
		#(
		.CLK_SPEED(CLK_SPEED),
		.LED_CNT(LED_CNT)
		)
		led_dut (
			.data(leddata),
			.led_o(led_o),
			.clk(clk),
			.reset(reset)
		);
		
	
	always @(posedge clk) begin
		if (reset) begin
			state <= 0;
			datacounter <= 0;
		end else begin
			state <= next_state;
			datacounter <= next_datacounter;
		end
		
	end
	
	always @(state, start, stop, data_valid) begin
		next_state <= state;
		next_datacounter <= datacounter;
		
		case (state) 
			IDLE: begin
				if (start) begin
					next_datacounter <= address[DATACOUNTWIDTH-1:0];//{(DATACOUNTWIDTH){1'b0}};
					next_state <= WRITE;
				end else begin
					next_state <= IDLE;
				end
			end
			WRITE: begin
				if (data_valid) begin
					if (datacounter < DATAWIDTH) begin
						for(i=0;i<8;i=i+1) begin
							leddata[(datacounter<<3)+i[DATACOUNTWIDTH-1:0]] <= data[7-i];
						end
						next_datacounter <= datacounter + 1;
						next_state <= WRITE;
					end else begin
						next_state <= IDLE;
					end
				end else if (stop) begin
					next_state <= IDLE;
				end
			end
		endcase
		
		
	end
	
	
endmodule

`endif
