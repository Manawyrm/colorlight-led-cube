// Description of the LED panel:
// http://bikerglen.com/projects/lighting/led-panel-1up/#The_LED_Panel
//
// PANEL_[ABCD] ... select rows (in pairs from top and bottom half)
// PANEL_OE ....... display the selected rows (active low)
// PANEL_CLK ...... serial clock for color data
// PANEL_STB ...... latch shifted data (active high)
// PANEL_[RGB]0 ... color channel for top half
// PANEL_[RGB]1 ... color channel for bottom half
// taken from http://svn.clifford.at/handicraft/2015/c3demo/fpga/ledpanel.v
// modified by Niklas Fauth 2020

`default_nettype none
module ledpanel (
	input wire ctrl_clk,

	input wire ctrl_en,
	input wire [3:0] ctrl_wr,           // Which color memory block to write
	input wire [15:0] ctrl_addr,        // Addr to write color info on [col_info][row_info]
	input wire [23:0] ctrl_wdat,        // Data to be written [R][G][B]

	input wire display_clock,
	output reg panel_r0, panel_g0, panel_b0, panel_r1, panel_g1, panel_b1,
	output reg panel_a, panel_b, panel_c, panel_d, panel_e, panel_clk, panel_stb, panel_oe
);

	localparam integer HEIGHT               = 64;
	localparam integer WIDTH                = 64;
	localparam integer PIXEL_COUNT          = HEIGHT * WIDTH;
	localparam integer INPUT_DEPTH          = BITS_RED + BITS_GREEN + BITS_BLUE;     // bits of color before gamma correction
	localparam integer COLOR_DEPTH          = 7;    // bits of color after gamma correction

	localparam integer BITS_RED             = 5;
	localparam integer BITS_GREEN           = 6;
	localparam integer BITS_BLUE            = 5;

	localparam integer SIZE_BITS = 1;

	reg [INPUT_DEPTH-1:0] video_mem [0:PIXEL_COUNT-1];

	reg [COLOR_DEPTH-1:0] gamma_mem_red   [0:(2**BITS_RED)-1];
	reg [COLOR_DEPTH-1:0] gamma_mem_green [0:(2**BITS_GREEN)-1];
	reg [COLOR_DEPTH-1:0] gamma_mem_blue  [0:(2**BITS_RED)-1];

	initial begin:video_mem_init
		panel_a <= 0;
		panel_b <= 0;
		panel_c <= 0;
		panel_d <= 0;
		panel_e <= 0;

		$readmemh("gamma_5_to_7.mem",gamma_mem_red);
		$readmemh("gamma_6_to_7.mem",gamma_mem_green);
		$readmemh("gamma_5_to_7.mem",gamma_mem_blue);

		$readmemh("Bliss.mem",video_mem);
	end

	/*always @(posedge ctrl_clk) begin
		if (ctrl_en && ctrl_wr[2]) video_mem_r[ctrl_addr] <= ctrl_wdat[16+INPUT_DEPTH-1:16];
		if (ctrl_en && ctrl_wr[1]) video_mem_g[ctrl_addr] <= ctrl_wdat[8+INPUT_DEPTH-1:8];
		if (ctrl_en && ctrl_wr[0]) video_mem_b[ctrl_addr] <= ctrl_wdat[0+INPUT_DEPTH-1:0];
	end*/

	reg [5+COLOR_DEPTH+SIZE_BITS:0] cnt_x = 0;
	reg [4:0]                       cnt_y = 0;
	reg [3:0]                       cnt_z = 0;
	reg state = 0;

	reg [5+SIZE_BITS:0] addr_x;
	reg [5:0]           addr_y;
	reg [5:0]           addr_y_q;
	reg [3:0]           addr_z;
	reg [5:0]           data_rgb;
	reg [5+COLOR_DEPTH+SIZE_BITS:0] max_cnt_x;

	reg [INPUT_DEPTH-1:0] current_pixel_rgb;


	always @(posedge display_clock) begin
		case (cnt_z)
			0: max_cnt_x = 64+8;
			1: max_cnt_x = 128;
			2: max_cnt_x = 256;
			3: max_cnt_x = 512;
			4: max_cnt_x = 1024;
			5: max_cnt_x = 2048;
			6: max_cnt_x = 4096;
			7: max_cnt_x = 8192;
		endcase
	end

	always @(posedge display_clock) begin
		state <= !state;
		if (!state) begin
			if (cnt_x > max_cnt_x) begin
				cnt_x <= 0;
				cnt_z <= cnt_z + 1;
				if (cnt_z == COLOR_DEPTH-1) begin
					cnt_y <= cnt_y + 1;
					cnt_z <= 0;
				end
			end else begin
				cnt_x <= cnt_x + 1;
			end
		end
	end

	always @(posedge display_clock) begin
		panel_oe <= 64-8 < cnt_x && cnt_x < 64+8;
		if (state) begin
			panel_clk <= 1 < cnt_x && cnt_x < 64+2;
			panel_stb <= cnt_x == 64+2;
		end else begin
			panel_clk <= 0;
			panel_stb <= 0;
		end
	end

	always @(posedge display_clock) begin
		addr_x <= cnt_x[5+SIZE_BITS:0];
		addr_y <= cnt_y + 32*(!state);
		addr_y_q <= cnt_y + 16;
		addr_z <= cnt_z;
	end

	always @(posedge display_clock) begin
		// Red - 4:0
		data_rgb[2] = gamma_mem_red[video_mem[{addr_y, addr_x}][BITS_RED-1:0]][addr_z];
		data_rgb[5] = gamma_mem_red[video_mem[{addr_y_q, addr_x}][BITS_RED-1:0]][addr_z];
	end
	always @(posedge display_clock) begin
		// Green - 10:5
		data_rgb[1] = gamma_mem_green[video_mem[{addr_y, addr_x}][BITS_GREEN + BITS_RED-1:BITS_RED]][addr_z];
		data_rgb[4] = gamma_mem_green[video_mem[{addr_y_q, addr_x}][BITS_GREEN + BITS_RED-1:BITS_RED]][addr_z];
	end
	always @(posedge display_clock) begin
		// Blue - 15:11
		data_rgb[0] = gamma_mem_blue[video_mem[{addr_y, addr_x}][BITS_GREEN + BITS_RED + BITS_BLUE-1:BITS_GREEN + BITS_RED]][addr_z];
		data_rgb[3] = gamma_mem_blue[video_mem[{addr_y_q, addr_x}][BITS_GREEN + BITS_RED + BITS_BLUE-1:BITS_GREEN + BITS_RED]][addr_z];
	end

	always @(posedge display_clock) begin
		//data_rgb_q = data_rgb;
		if (!state) begin
			if (0 < cnt_x && cnt_x < 64+1) begin
				{panel_r1, panel_r0} <= {data_rgb[2], data_rgb[5]};
				{panel_g1, panel_g0} <= {data_rgb[1], data_rgb[4]};
				{panel_b1, panel_b0} <= {data_rgb[0], data_rgb[3]};
			end else begin
				{panel_r1, panel_r0} <= 0;
				{panel_g1, panel_g0} <= 0;
				{panel_b1, panel_b0} <= 0;
			end
		end
		else if (cnt_x == 64)  begin
			{panel_e, panel_d, panel_c, panel_b, panel_a} <= cnt_y;
		end
	end
endmodule
