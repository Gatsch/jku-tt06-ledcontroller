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
`ifndef __i2c__
`define __i2c__

module i2c #(
	parameter ADDRESS = 7'h69
)(
	input wire scl_i,
	output wire scl_o,	//needed?
	input wire sda_i,
	output wire sda_o,
	input wire clk,
	input wire reset,
	output reg [7:0] address,
	output reg [7:0] data,
	output wire address_valid_o,
	output wire data_valid_o,
	output wire start,
	output wire stop
);

	reg scl;
	reg last_scl;
	wire scl_posedge = scl & ~last_scl;
	wire scl_negedge = ~scl & last_scl;
	reg scl_out;
	
	reg sda;
	reg last_sda;
	wire sda_posedge = sda & ~last_sda;
	wire sda_negedge = ~sda & last_sda;
	reg sda_out;
	
	wire start_signal = scl_i & sda_negedge;
	wire stop_signal = scl_i & sda_posedge;
	
	localparam Data_size = 8;
	//reg [Data_size-1:0]data;
	reg [3:0] data_cnt;
	reg data_valid;
	reg read;
	reg deviceaddressread;
	reg address_valid;
	
	
	localparam IDLE = 3'd0;
	localparam READADDRESS = 3'd1;
	localparam PREPACK = 3'd2;
	localparam ACK = 3'd3;
	localparam WRITE = 3'd4;
	reg [2:0] state, next_state;

	always @(posedge clk) begin
		if (reset) begin
			state <= IDLE;
            
        end else begin
        	scl <= scl_i;
        	sda <= sda_i;
        	last_scl <= scl;
    		last_sda <= sda;
    		state <= next_state;
        end
    end
    
	always @(state, start_signal, stop_signal, scl_posedge, scl_negedge) begin
		if (start_signal) begin
			data_cnt <= 4'b0000;
			data_valid <= 1'b0;
			sda_out <= 1'b1;
			scl_out <= 1'b1;
			address <= 8'b0;
			deviceaddressread <= 1'b0;
			address_valid <= 1'b0;
			next_state <= READADDRESS;
		end else if (stop_signal) begin
			next_state <= IDLE;
		end else begin
			case(state)
				IDLE: begin
					data_cnt <= 4'b0000;
					data_valid <= 1'b0;
					sda_out <= 1'b1;
					scl_out <= 1'b1;
					next_state <= IDLE;
				end
				/*READADDRESS: begin
					if (data_cnt < Data_size-1) begin
						if (scl_posedge) begin
							data <= data<<1;
							data[0] <= sda;
							data_cnt <= data_cnt + 4'b0001;
						end
						next_state <= READADDRESS;
					end else begin
						next_state <= READORWRITE;
					end
				end
				READORWRITE: begin
					if (scl_posedge) begin
						read <= sda;
						data[Data_size-1] <= 0;
						if (data[Data_size-2:0] == ADDRESS) begin
							data_cnt <= 4'b0;
							next_state <= PREPACK;
						end else begin
							next_state <= IDLE;
						end
					end else begin
						next_state <= READORWRITE;
					end
				end*/
				READADDRESS: begin
					if (data_cnt < Data_size) begin
						if (scl_posedge) begin
							data <= data<<1;
							data[0] <= sda;
							data_cnt <= data_cnt + 4'b0001;
						end
						next_state <= READADDRESS;
					end else if (!deviceaddressread) begin
						if (data[Data_size-1:1] == ADDRESS) begin
							read <= data[0];
							deviceaddressread <= 1'b1;
							next_state <= PREPACK;
						end else begin
							next_state <= IDLE;
						end
					end else begin
						address <= data;
						address_valid <= 1'b1;
						next_state <= PREPACK;
					end
				end
				/*
				READDEVICEADDRESS: begin
					if (data_cnt < Data_size) begin
						if (scl_posedge) begin
							data <= data<<1;
							data[0] <= sda;
							data_cnt <= data_cnt + 4'b0001;
						end
						next_state <= READDEVICEADDRESS;
					end else if (data[Data_size-1:1] == ADDRESS) begin
						read <= data[0];
						data_cnt <= 4'b0;
						next_state <= PREPACK;
					end else begin
						next_state <= IDLE;
					end
				end
				READREGISTERADDRESS: begin
					if (data_cnt < Data_size) begin
						if (scl_posedge) begin
							data <= data<<1;
							data[0] <= sda;
							data_cnt <= data_cnt + 4'b0001;
						end
						next_state <= READREGISTERADDRESS;
					end else begin
						dataaddressread <= 1'b1;
						address <= data;
						next_state <= PREPACK;
					end
				end
				*/
				PREPACK: begin
						if (scl_negedge) begin
							sda_out <= 1'b0;
							data_valid <= 1'b0;
							next_state <= ACK;
						end else begin
							next_state <= PREPACK;
						end
					
				end
				ACK: begin
					if (scl_negedge) begin
						sda_out <= 1'b1;
						data_cnt <= 4'b0;
						if (!address_valid) begin
							next_state <= READADDRESS;
						end else if (read) begin
							next_state <= IDLE;
						end else begin
							next_state <= WRITE;
						end
					end else begin
						next_state <= ACK;
					end
				end
				WRITE: begin
					if (data_cnt < Data_size) begin
						if (scl_posedge) begin
							data <= data<<1;
							data[0] <= sda;
							data_cnt <= data_cnt + 4'b0001;
						end
						next_state <= WRITE;
					end else begin
						data_valid <= 1'b1;
						next_state <= PREPACK;
					end
				end
				/*
				ADDRESSINCREMENT: begin
					address <= address + 8'b1;
					next_state <= PREPACK;
				end
				*/
				default:
		    		next_state <= IDLE;
			endcase
		end
    	
    	
    end
    assign sda_o = sda_out;
    assign scl_o = scl_out;
    assign data_valid_o = data_valid;
    assign address_valid_o = address_valid;
    assign start = start_signal;
    assign stop = stop_signal;
endmodule
`endif
