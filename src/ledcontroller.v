// Copyright 2024 Mathias Garstenauer
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE−2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

`default_nettype none
`ifndef __i2c_led__
`define __i2c_led__
`include "i2c.v"
`include "led.v"

module ledcontroller #(
	parameter ADDRESS = 7'h69,			//i2c address
	parameter CLK_SPEED = 25_000_000,	//internal clock speed
	parameter LED_CNT = 3				//number of ws2812b leds
)(
	input wire scl_i,					//i2c scl input
	output wire scl_o,					//i2c scl output
	input wire sda_i,					//i2c sda input
	output wire sda_o,					//i2c sda output
	output wire led_o,					//ws2812b led output
	input wire clk,						//internal clock
	input wire reset					//chip reset
);

	//calculating multiple constants out of the parameters 
	localparam DATAWIDTH = LED_CNT*3*8;
	localparam DATAADDRESSWIDTH = $clog2(DATAWIDTH);
	localparam DATACOUNT32 = LED_CNT*3;
	localparam DATACOUNTWIDTH = $clog2(DATACOUNT32);
	localparam DATACOUNT = DATACOUNT32[DATACOUNTWIDTH-1:0];

	wire start;
	wire stop;
	wire [7:0] data;
	wire [7:0] address;
	wire data_valid;
	wire address_valid;
	reg [DATAWIDTH-1:0]leddata;
	
	
	localparam IDLE = 2'd0;
	localparam WAIT_ADDRESS = 2'd1;
	localparam WRITE = 2'd2;
	reg [1:0] state, next_state;
	reg [DATACOUNTWIDTH-1:0] datacounter, next_datacounter;
	
    /* verilator lint_off UNUSEDSIGNAL */
	wire [7:DATACOUNTWIDTH] dummy = address[7:DATACOUNTWIDTH];
    /* verilator lint_on UNUSEDSIGNAL */
    
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
			.address_valid_o(address_valid),
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
		
	//the registers are updated each clock cylce with their new values
	always @(posedge clk) begin
		if (reset) begin
			state <= 0;
			datacounter <= 0;
			leddata <= {DATACOUNTWIDTH{1'b0}};
		end else begin
			state <= next_state;
			datacounter <= next_datacounter;
		end
		
	end

	//saves data from i2c into the register used by the led module	
	always @(state, start, stop, address_valid, data_valid) begin
		if (start) begin
			next_state <= WAIT_ADDRESS;
		end else if (stop) begin
			next_state <= IDLE;
		end else begin
			case (state) 
				//waits until start condition
				IDLE: begin
					next_state <= IDLE;
				end
				//waits until the register adress is read from i2c
				WAIT_ADDRESS: begin
					if (address_valid) begin
						next_datacounter <= address[DATACOUNTWIDTH-1:0];
						next_state <= WRITE;
					end else begin
						next_state <= WAIT_ADDRESS;
					end
				end
				//when the i2c data is valid it is stored in the register
				//bit reversal is required as ws2812b led expect the MSB first
				WRITE: begin
					if (data_valid) begin
						if (datacounter < DATACOUNT) begin
							for(i=0;i<8;i=i+1) begin
								leddata[({3'b0,datacounter}<<3)+i[DATAADDRESSWIDTH-1:0]] <= data[7-i];
							end
							next_datacounter <= datacounter + 1;
							next_state <= WRITE;
						end else begin
							next_state <= IDLE;
						end
					end
				end
				default: begin
					next_state <= IDLE;
				end
			endcase
		end
		
	end
	
	
endmodule

`endif
