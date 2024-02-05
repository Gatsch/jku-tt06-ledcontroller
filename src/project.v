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

`define default_netname none
`ifndef __tt__um__i2c__
`define __tt__um__i2c__
`include "ledcontroller.v"

module tt_um_ledcontroller_Gatsch (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  wire reset = ! rst_n;
	wire sda_o;
	wire sda_i = uio_in[1];
	wire scl_o;
	wire scl_i = uio_in[0];
	wire led_o;
	assign uio_out = 8'b0;
	assign uio_oe[7:2] = 6'b0;
	assign uio_oe[1] = ~sda_o;
	assign uio_oe[0] = ~scl_o;
	assign uo_out[7:3] = 5'b0;
	assign uo_out[2] = led_o;
	assign uo_out[1] = ~sda_o;
	assign uo_out[0] = ~scl_o;

    /* verilator lint_off UNUSEDSIGNAL */
    wire dummy0 = ena;
    wire dummy1 = |ui_in[7:0];
    wire dummy2 = |uio_in[7:2];
    /* verilator lint_on UNUSEDSIGNAL */
    
    i2c_led 
		#(
		.ADDRESS(7'h4A),
		.LED_CNT(11)
		)
		i2c_led_dut (
			.scl_i(scl_i),
			.scl_o(scl_o),
			.sda_i(sda_i),
			.sda_o(sda_o),
			.led_o(led_o),
			.clk(clk),
			.reset(reset)
		);


endmodule
`endif
