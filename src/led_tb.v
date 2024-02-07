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
`include "led.v"

module led_tb;
	reg rst_i = 1'b0;
	reg clk_i = 1'b0;
	wire led_o;
	reg [3*8-1:0]data;
	
	led 
		#(.LED_CNT(1))
		led_dut (
			.data(data),
			.led_o(led_o),
			.clk(clk_i),
			.reset(rst_i)
		);
		
	always #20 clk_i  = ~clk_i;	//25MHz
	
	initial begin
        $dumpfile ("tb.vcd");
        $dumpvars (0, led_tb);
        data <= 24'b010011000101010111001001;
        rst_i <= 1'b1;
        #100; rst_i <= 1'b0;
        #200000;
        $finish;
    end
endmodule
