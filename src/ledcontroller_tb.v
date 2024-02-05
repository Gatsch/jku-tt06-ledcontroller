`timescale 1ns/1ns
`include "ledcontroller.v"

module ledcontroller_tb;

	reg rst_i = 1'b0;
	reg clk_i = 1'b0;
	reg scl_i = 1'b0;
	wire scl_o;
	reg sda_i = 1'b0;
	wire sda_o;
	wire led_o;
	integer i;
	reg [7:0] data;
	
	localparam I2CCYCLE = 10000;
	localparam I2CHALFCYCLE = I2CCYCLE/2;
	localparam I2C2CYCLE = I2CCYCLE/2;
	localparam I2C4CYCLE = I2CCYCLE/4;
	
	ledcontroller 
		#(
		.ADDRESS(7'h4A),
		.LED_CNT(3)
		)
		ledcontroller_dut (
			.scl_i(scl_i),
			.scl_o(scl_o),
			.sda_i(sda_i),
			.sda_o(sda_o),
			.led_o(led_o),
			.clk(clk_i),
			.reset(rst_i)
		);
		
	always #20 clk_i  = ~clk_i;
	
	//always #I2CHALFCYCLE scl_i = ~scl_i;
	
	task start();
		begin
			scl_i = 1'b1;
			sda_i = 1'b1;
			#I2C4CYCLE sda_i = 1'b0;
			#I2C4CYCLE scl_i = 1'b0;
		end
	endtask
	
	task i2cwrite(input [7:0] i2cdata);
		begin
			scl_i = 1'b0;
			for(i=0;i<8;i=i+1)begin
				#I2C4CYCLE sda_i = i2cdata[7-i];
				#I2C4CYCLE scl_i = 1'b1;
				#I2C2CYCLE scl_i = 1'b0;
			end
			#I2C4CYCLE;
			#I2C2CYCLE scl_i = 1'b1;
			#I2C2CYCLE scl_i = 1'b0;
		end
	endtask
	
	task stop();
		begin
			scl_i = 1'b1;
			sda_i = 1'b0;
			#I2C4CYCLE sda_i = 1'b1;
			#I2C4CYCLE scl_i = 1'b0;
		end
	endtask
	
	initial begin 
		$dumpfile("tb.vcd");
		$dumpvars;
		i2c_led_dut.leddata = 0;
		
		#50 rst_i = 1'b1;
		#50 rst_i = 1'b0;
		
		start();
		#I2CCYCLE;
		
		i2cwrite({7'h4A,1'b0});
		#I2CCYCLE;
		i2cwrite({7'h0C,1'b0});
		#I2CCYCLE;
		i2cwrite(8'hAB);
		#I2CCYCLE;
		i2cwrite(8'h36);
		#I2CCYCLE;
		i2cwrite(8'h84);
		stop();
		
		#200000 $finish;
	end
endmodule
