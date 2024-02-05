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

`timescale 1ns/1ns
`include "i2c.v"

module i2c_tb;

	reg rst_i = 1'b0;
	reg clk_i = 1'b0;
	reg scl_i = 1'b0;
	wire scl_o;
	reg sda_i = 1'b0;
	wire sda_o;
	wire [7:0] data;
	wire data_valid;
	wire start;
	wire stop;
	
	localparam I2CCYCLE = 10000;
	localparam I2CHALFCYCLE = I2CCYCLE/2;
	
	i2c 
		#(.ADDRESS(7'h4A))
		i2c_dut (
			.scl_i(scl_i),
			.scl_o(scl_o),
			.sda_i(sda_i),
			.sda_o(sda_o),
			.clk(clk_i),
			.reset(rst_i),
			.data(data),
			.data_valid_o(data_valid),
			.start(start),
			.stop(stop)
		);
		
	always #20 clk_i  = ~clk_i;
	
	always #I2CHALFCYCLE scl_i = ~scl_i;
	
	initial begin 
		$dumpfile("tb.vcd");
		$dumpvars;
		#50 rst_i = 1'b1;
		#50 rst_i = 1'b0;
		
		#2400 sda_i = 1'b1;
		#I2CHALFCYCLE sda_i = 1'b0; //start
		
		//20 high 40 low 60 high 80 low
		
		//ADDRESS
		#I2CHALFCYCLE sda_i = 1'b1;
		#I2CCYCLE sda_i = 1'b0;
		#I2CCYCLE sda_i = 1'b0;
		#I2CCYCLE sda_i = 1'b1;
		#I2CCYCLE sda_i = 1'b0;
		#I2CCYCLE sda_i = 1'b1;
		#I2CCYCLE sda_i = 1'b0;
		#I2CCYCLE sda_i = 1'b0; //1 read 0 write
		
		#I2CCYCLE;
		//WRITE ADDRESS
		#I2CCYCLE sda_i = 1'b0;
		#I2CCYCLE sda_i = 1'b0;
		#I2CCYCLE sda_i = 1'b0;
		#I2CCYCLE sda_i = 1'b0;
		#I2CCYCLE sda_i = 1'b0;
		#I2CCYCLE sda_i = 1'b0;
		#I2CCYCLE sda_i = 1'b0;
		#I2CCYCLE sda_i = 1'b1;
		
		#I2CCYCLE;
		//BYTE 1
		#I2CCYCLE sda_i = 1'b0;
		#I2CCYCLE sda_i = 1'b1;
		#I2CCYCLE sda_i = 1'b1;
		#I2CCYCLE sda_i = 1'b1;
		#I2CCYCLE sda_i = 1'b0;
		#I2CCYCLE sda_i = 1'b0;
		#I2CCYCLE sda_i = 1'b0;
		#I2CCYCLE sda_i = 1'b1;
		
		#I2CCYCLE;
		//BYTE 2
		#I2CCYCLE sda_i = 1'b1;
		#I2CCYCLE sda_i = 1'b0;
		#I2CCYCLE sda_i = 1'b1;
		#I2CCYCLE sda_i = 1'b0;
		#I2CCYCLE sda_i = 1'b1;
		#I2CCYCLE sda_i = 1'b0;
		#I2CCYCLE sda_i = 1'b0;
		#I2CCYCLE sda_i = 1'b0;
		
		#I2CCYCLE;
		//NEW START
		#I2CCYCLE sda_i = 1'b1;
		#I2CCYCLE sda_i = 1'b0;
		#I2CCYCLE sda_i = 1'b0;
		#I2CCYCLE sda_i = 1'b1;
		#I2CHALFCYCLE sda_i = 1'b0;
		
		//ADDRESS
		#I2CHALFCYCLE sda_i = 1'b1;
		#I2CCYCLE sda_i = 1'b0;
		#I2CCYCLE sda_i = 1'b0;
		#I2CCYCLE sda_i = 1'b1;
		#I2CCYCLE sda_i = 1'b0;
		#I2CCYCLE sda_i = 1'b1;
		#I2CCYCLE sda_i = 1'b0;
		#I2CCYCLE sda_i = 1'b0;
		
		#I2CCYCLE;
		//BYTE1
		#I2CCYCLE sda_i = 1'b1;
		#I2CCYCLE sda_i = 1'b0;
		#I2CCYCLE sda_i = 1'b1;
		#I2CCYCLE sda_i = 1'b0;
		#I2CCYCLE sda_i = 1'b1;
		#I2CCYCLE sda_i = 1'b0;
		#I2CCYCLE sda_i = 1'b0;
		#I2CCYCLE sda_i = 1'b0;
		
		#I2CCYCLE;
		#I2CCYCLE;
		#I2CHALFCYCLE sda_i = 1'b1; //stop
		#I2CHALFCYCLE sda_i = 1'b0;
		
		#4000 $finish;
	end
endmodule
