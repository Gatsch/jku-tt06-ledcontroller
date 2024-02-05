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
