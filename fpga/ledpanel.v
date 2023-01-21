// Description of the LED panel:
// http://bikerglen.com/projects/lighting/led-panel-1up/#The_LED_Panel
//
// PANEL_[ABCDE] ... select rows (in pairs from top and bottom half)
// PANEL_OE ....... display the selected rows (active low)
// PANEL_CLK ...... serial clock for color data
// PANEL_STB ...... latch shifted data (active high)
// PANEL_[RGB]0 ... color channel for top half
// PANEL_[RGB]1 ... color channel for bottom half
// taken from http://svn.clifford.at/handicraft/2015/c3demo/fpga/ledpanel.v
// modified by Lucy in 2020, Manawyrm & tsys in 2023

`default_nettype none
module ledpanel (
	input wire [7:0] panel_index,			// static panel index, index of panel on ctrl_en bus, starts at 1

	input wire ctrl_clock,				// clock driving ctrl bus
	input wire [7:0]			ctrl_en,	// index of panel to write to + 1, 0 selects no panel at all
	input wire [15:0]			ctrl_addr,	// addr to write color info on [col_info][row_info]
	input wire [INPUT_DEPTH-1:0]	ctrl_wdat,	// RGB565 datum to be written

	input wire display_clock,				// clock driving the display itself

	/* standard HUB75 data lines */
	output reg panel_r0, panel_g0, panel_b0, panel_r1, panel_g1, panel_b1,
	output reg panel_a, panel_b, panel_c, panel_d, panel_e, panel_clk, panel_stb, panel_oe
);

	/*
	 * Panel configuration. This set of parameters depends entirely on the
	 * HUB75 panel used.
	 */
	localparam integer HEIGHT               = 64;
	localparam integer WIDTH                = 64;
	localparam integer RGB1_OFFSET			= 32; // height offset between RGB0 and RGB1 lines

	localparam integer COLOR_DEPTH          = 6; // bits of color after gamma correction

	localparam integer BITS_RED             = 8;
	localparam integer BITS_GREEN           = 8;
	localparam integer BITS_BLUE            = 8;

	localparam integer PIXEL_COUNT          = HEIGHT * WIDTH;
	localparam integer INPUT_DEPTH          = BITS_RED + BITS_GREEN + BITS_BLUE; // bits of color before gamma correction
	localparam integer BITS_HEIGHT          = $clog2(HEIGHT) - 1;
	localparam integer BITS_WIDTH           = $clog2(WIDTH);
	localparam integer BITS_COLOR_DEPTH     = $clog2(COLOR_DEPTH);

	reg [INPUT_DEPTH-1:0] video_mem_rgb0 [0:PIXEL_COUNT / 2 - 1];
	reg [INPUT_DEPTH-1:0] video_mem_rgb1 [0:PIXEL_COUNT / 2 - 1];

	reg [COLOR_DEPTH-1:0] gamma_mem_red   [0:2 ** BITS_RED - 1];
	reg [COLOR_DEPTH-1:0] gamma_mem_green [0:2 ** BITS_GREEN - 1];
	reg [COLOR_DEPTH-1:0] gamma_mem_blue  [0:2 ** BITS_RED - 1];

	initial begin:video_mem_init
		panel_a <= 0;
		panel_b <= 0;
		panel_c <= 0;
		panel_d <= 0;
		panel_e <= 0;

		/*
		 * Gamma correction tables specific to selected bit depths.
		 * Needs to map BITS_{REG,GREEN,BLUE} to COLOR_DEPTH bits
		 */
		$readmemh("gamma_8_to_6.mem",gamma_mem_red);
		$readmemh("gamma_8_to_6.mem",gamma_mem_green);
		$readmemh("gamma_8_to_6.mem",gamma_mem_blue);

		/*
		 * Initial data for video memory. Non gamma-corrected,
		 * Must fit panel size specified above.
		 */
		$readmemh("no_signal.rgb0",video_mem_rgb0);
		$readmemh("no_signal.rgb1",video_mem_rgb1);
	end

	always @(posedge ctrl_clock) begin
		if (ctrl_en == panel_index) begin
			if (ctrl_addr[15:BITS_WIDTH] >= RGB1_OFFSET) begin
				video_mem_rgb1[ctrl_addr - (RGB1_OFFSET * WIDTH)] <= ctrl_wdat;
			end else begin
				video_mem_rgb0[ctrl_addr] <= ctrl_wdat;
			end
		end
	end

	reg [BITS_WIDTH + COLOR_DEPTH + 3 - 1:0]	cnt_x = 0;
	reg [BITS_HEIGHT - 1:0]						cnt_y = 0;
	reg [BITS_COLOR_DEPTH - 1:0]				cnt_z = 0;

	reg [BITS_WIDTH - 1:0]						addr_x;
	reg [BITS_HEIGHT - 1:0]						addr_y;
	reg [BITS_COLOR_DEPTH - 1:0]				addr_z;
	reg [5:0]									data_rgb; // R0, G0, B0, R1, G1, G2 -> 6 bits


	reg	[BITS_GREEN : 0] data_rgb0;
	reg	[BITS_GREEN : 0] data_rgb1;
	reg	[BITS_GREEN : 0] data_rgb2;
	reg	[BITS_GREEN : 0] data_rgb3;
	reg	[BITS_GREEN : 0] data_rgb4;
	reg	[BITS_GREEN : 0] data_rgb5;

	reg clkdiv = 0;
	reg state = 0;

	/*
	 * HUB75 are slooooooooow
	 * Divide our primary clock by 2 so we get stable output
	 */
	//always @(posedge display_clock) begin
	//	clkdiv = !clkdiv;
	//end

	/*
	 * Binary operation state.
	 * On even cycles we apply new data to the output and emit falling clock edge
	 * On odd cycles we calculate new addresses and emit rising clock edge
	 */
	always @(posedge display_clock) begin
			state = !state;
	end

	/*
	 * Main address calculation
	 * cnt_x counts to number of clock cycles we spent clocking out + showing a line of data
	 * cnt_z is the current bit we are at in our @COLOR_DEPTH
	 * cnt_y is the index of rgb0 and rgb1 line we are displaying right now
	 */
	always @(posedge display_clock) begin
			if (state) begin
				if (cnt_x == (WIDTH << cnt_z) + 8) begin
					cnt_x = 0;
					if (cnt_z == COLOR_DEPTH-1) begin
						cnt_y = cnt_y + 1;
						cnt_z = 0;
					end else begin
						cnt_z = cnt_z + 1;
					end
				end else begin
					cnt_x = cnt_x + 1;
				end
			end
	end
	/*always @(posedge display_clock) begin
		cnt_x = cnt_x + 1;
		cnt_y = cnt_y + 1;
		cnt_z = cnt_z + 1;
	end*/

	/*
	 * From here on we stop caring about clkdiv since all input values used are
	 * steady state while clkdiv = 0
	 */

	/*
	 * New data is always applied to rgb0 and rgb1 on !state.
	 * We need to wait for some time after applying that data
	 * to ensure the shift registers on the HUB75 panels capture
	 * a stabler signal state.
	 * Thus we emit a rising clock edge only once state is no longer 0.
	 * Also note that we must stop emitting rising edges when we want
	 * to strobe. Else we might misalign data in the shift register by
	 * one bit.
	 */
	always @(posedge display_clock) begin
		if (state) begin
			panel_clk = cnt_x > 1 && cnt_x < WIDTH + 2;
		end else begin
			panel_clk = 0;
		end
	end

	/*
	 * Once a full line has been clocked out we need to assert
	 * strobe briefly to start displaying it. We can not assign
	 * this line since comparison with cnt_x is glitchy and we
	 * want to synchronize with panel_clk.
	 * Additionally we need to make sure the correct line 
	 */
	always @(posedge display_clock) begin
		if (cnt_x == WIDTH) begin
			{panel_e, panel_d, panel_c, panel_b, panel_a} <= cnt_y;
		end

		panel_stb = cnt_x == WIDTH+2;
	end

	/*
	 * To avoid artifacting we need to have some deadtime around
	 * both our strobe signal and line address decoder input change.
	 * We start strobing as soon as the last bit
	 * has been clocked out. Deassert output enable 10 clock cycles
	 * before that and reenable it 6 after.
	 * We have 8 clock cycles margin both before and after changing
	 * the line address. This is important since the line address
	 * decoders are often really slow.
	 */
	assign panel_oe = cnt_x > WIDTH - 8 && cnt_x < WIDTH + 8;

	/*
	 * Relative display cycle zero. Latch addresses.
	 */
	reg [BITS_WIDTH + COLOR_DEPTH + 3 - 1:0] cnt_x_latched;
	always @(posedge display_clock) begin
		addr_x = cnt_x[BITS_WIDTH:0] - 1;
		addr_y = cnt_y[BITS_HEIGHT - 1:0];
		addr_z = cnt_z;
		cnt_x_latched = cnt_x;
	end

	wire [INPUT_DEPTH-1:0] rgb0;
	wire [INPUT_DEPTH-1:0] rgb1;

	always @(posedge display_clock) begin
		rgb0 <= video_mem_rgb0[{addr_y, addr_x}];
		rgb1 <= video_mem_rgb1[{addr_y, addr_x}];
	end

	/*
	 * Relative display cycle one. Latch rgb line data from BRAM.
	 */
	always @(posedge display_clock) begin
		/*
		// Red - 4:0
		data_rgb[0] = gamma_mem_red[video_mem_rgb0[{addr_y, addr_x}][BITS_RED-1:0]][addr_z];
		data_rgb[1] = gamma_mem_red[video_mem_rgb1[{addr_y, addr_x}][BITS_RED-1:0]][addr_z];
		// Green - 10:5
		data_rgb[2] = gamma_mem_green[video_mem_rgb0[{addr_y, addr_x}][BITS_GREEN + BITS_RED-1:BITS_RED]][addr_z];
		data_rgb[3] = gamma_mem_green[video_mem_rgb1[{addr_y, addr_x}][BITS_GREEN + BITS_RED-1:BITS_RED]][addr_z];
		// Blue - 15:11
		data_rgb[4] = gamma_mem_blue[video_mem_rgb0[{addr_y, addr_x}][BITS_GREEN + BITS_RED + BITS_BLUE-1:BITS_GREEN + BITS_RED]][addr_z];
		data_rgb[5] = gamma_mem_blue[video_mem_rgb1[{addr_y, addr_x}][BITS_GREEN + BITS_RED + BITS_BLUE-1:BITS_GREEN + BITS_RED]][addr_z];
		*/


		/*
		// Red - 4:0
		data_rgb[0] = gamma_mem_red[rgb0[BITS_RED-1:0]][addr_z];
		data_rgb[1] = gamma_mem_red[rgb1[BITS_RED-1:0]][addr_z];
		// Green - 10:5
		data_rgb[2] = gamma_mem_green[rgb0[BITS_GREEN + BITS_RED-1:BITS_RED]][addr_z];
		data_rgb[3] = gamma_mem_green[rgb1[BITS_GREEN + BITS_RED-1:BITS_RED]][addr_z];
		// Blue - 15:11
		data_rgb[4] = gamma_mem_blue[rgb0[BITS_GREEN + BITS_RED + BITS_BLUE-1:BITS_GREEN + BITS_RED]][addr_z];
		data_rgb[5] = gamma_mem_blue[rgb1[BITS_GREEN + BITS_RED + BITS_BLUE-1:BITS_GREEN + BITS_RED]][addr_z];
		*/
		// Red - 4:0
		data_rgb0 = rgb0[BITS_RED-1:0];
		data_rgb1 = rgb1[BITS_RED-1:0];
		// Green - 10:5
		data_rgb2 = rgb0[BITS_GREEN + BITS_RED-1:BITS_RED];
		data_rgb3 = rgb1[BITS_GREEN + BITS_RED-1:BITS_RED];
		// Blue - 15:11
		data_rgb4 = rgb0[BITS_GREEN + BITS_RED + BITS_BLUE-1:BITS_GREEN + BITS_RED];
		data_rgb5 = rgb1[BITS_GREEN + BITS_RED + BITS_BLUE-1:BITS_GREEN + BITS_RED];
	end

	/*
	 * Relative display cycle two. Latch rgb line values.
	 * It does not matter that we insert up to two additional clock
	 * cycles latency in the display data since cnt_x will always
	 * keep counting for at least 8 additional cycles beyound the end
	 * of our display data.
	 */
	always @(posedge display_clock) begin
		if (!state) begin
			if (cnt_x_latched > 0 && cnt_x_latched <= WIDTH + 1) begin
				panel_r1 = data_rgb1[addr_z];
				panel_r0 = data_rgb0[addr_z];

				panel_g1 = data_rgb3[addr_z];
				panel_g0 = data_rgb2[addr_z];

				panel_b1 = data_rgb5[addr_z];
				panel_b0 = data_rgb4[addr_z];
			end else begin
				panel_r1 = 0;
				panel_r0 = 0;
				panel_g1 = 0;
				panel_g0 = 0;
				panel_b1 = 0;
				panel_b0 = 0;
			end
		end
	end
endmodule
