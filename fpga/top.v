`default_nettype none
module top
    (
    input wire osc25m,
    /*
     * RGMII interface
     */
    input  wire                       rgmii_rx_clk,
    input  wire [3:0]                 rgmii_rxd,
    input  wire                       rgmii_rx_ctl,
    output wire                       rgmii_tx_clk,
    output wire [3:0]                 rgmii_txd,
    output wire                       rgmii_tx_ctl,
    /*
     * MDIO interface
     */
    output wire mdio_scl,
    output wire mdio_sda,
    /*
     * USER I/O (Button, LED)
     */
    input wire button,
    output wire led,
    output wire phy_resetn,

    output wire [8:0] R0,
    output wire [8:0] G0,
    output wire [8:0] B0,
    output wire [8:0] R1,
    output wire [8:0] G1,
    output wire [8:0] B1,
    output wire A,
    output wire B,
    output wire C,
    output wire D,
    output wire E, // for 1/32 scan
    output wire LAT,
    output wire OE, //blank
    output wire CLK

);

    //------------------------------------------------------------------
    // PLL Instantiation and Locked Reset generation
    //------------------------------------------------------------------

    wire phy_init_done;
    wire                 locked;
    wire                 clock;
    reg [3:0]            locked_reset = 4'b1111;
    wire                 reset = locked_reset[3];
    wire                 display_clock;

    pll pll_inst(.clkin(osc25m),.clock(clock),.panel_clock(display_clock),.locked(locked));

    always @(posedge clock or negedge locked) begin
        if (locked == 1'b0) begin
            locked_reset <= 4'b1111;
        end else begin
            locked_reset <= {locked_reset[2:0], 1'b0};
        end
    end

    wire          udp0_sink_valid;
    wire          udp0_sink_last;
    wire          udp0_sink_ready;
    wire    [7:0] udp0_sink_data;
    wire          udp0_source_valid;
    wire          udp0_source_last;
    wire          udp0_source_ready;
    wire    [7:0] udp0_source_data;
    wire          udp0_source_error;


    liteeth_core ethernet (
        /* input         */ .sys_clock            (clock                ),
        /* input         */ .sys_reset            (reset),
        /* output        */ .rgmii_eth_clocks_tx  (rgmii_tx_clk         ),
        /* input         */ .rgmii_eth_clocks_rx  (rgmii_rx_clk         ),
        /* output        */ .rgmii_eth_rst_n      (                     ),
        /* input         */ .rgmii_eth_int_n      (                     ),
        /* inout         */ .rgmii_eth_mdio       (                     ),
        /* output        */ .rgmii_eth_mdc        (                     ),
        /* input         */ .rgmii_eth_rx_ctl     (rgmii_rx_ctl         ),
        /* input  [3:0]  */ .rgmii_eth_rx_data    (rgmii_rxd            ),
        /* output        */ .rgmii_eth_tx_ctl     (rgmii_tx_ctl         ),
        /* output [3:0]  */ .rgmii_eth_tx_data    (rgmii_txd            ),
                            .udp0_sink_valid      (udp0_sink_valid      ),
                            .udp0_sink_last       (udp0_sink_last       ),
                            .udp0_sink_ready      (udp0_sink_ready      ),
                            .udp0_sink_data       (udp0_sink_data       ),
                            .udp0_source_valid    (udp0_source_valid    ),
                            .udp0_source_last     (udp0_source_last     ),
                            .udp0_source_ready    (udp0_source_ready    ),
                            .udp0_source_data     (udp0_source_data     ),
                            .udp0_source_error    (udp0_source_error    ),
    );

    wire [7:0]  ctrl_en;
    wire [3:0]  ctrl_wr;
    wire [15:0] ctrl_addr;
    wire [23:0] ctrl_wdat;

    udp_panel_writer udp_inst
                    (.clock(clock),
                     .reset(reset),

                     .udp0_source_valid    (udp0_source_valid    ),
                     .udp0_source_last     (udp0_source_last     ),
                     .udp0_source_ready    (udp0_source_ready    ),
                     .udp0_source_data     (udp0_source_data     ),
                     .udp0_source_error    (udp0_source_error    ),

                     .ctrl_en(ctrl_en),
                     .ctrl_wr(ctrl_wr),
                     .ctrl_addr(ctrl_addr),
                     .ctrl_wdat(ctrl_wdat),
                     .led_reg(led)
                     );

    genvar panel_index;

    wire [8:0] A_int;
    wire [8:0] B_int;
    wire [8:0] C_int;
    wire [8:0] D_int;
    wire [8:0] E_int;
    wire [8:0] LAT_int;
    wire [8:0] OE_int;
    wire [8:0] CLK_int;

    generate
        for (panel_index = 0; panel_index < 9; panel_index=panel_index+1) begin
            ledpanel panel_inst (
                .panel_index(panel_index + 1),
                .ctrl_clock(clock),
                .ctrl_en(ctrl_en),
                .ctrl_addr(ctrl_addr),   // Addr to write color info on [col_info][row_info]
                .ctrl_wdat(ctrl_wdat),   // Data to be written [R][G][B]

                .display_clock(display_clock),
                .panel_r0(R0[panel_index]),
                .panel_g0(G0[panel_index]),
                .panel_b0(B0[panel_index]),
                .panel_r1(R1[panel_index]),
                .panel_g1(G1[panel_index]),
                .panel_b1(B1[panel_index]),
                .panel_a(A_int[panel_index]),
                .panel_b(B_int[panel_index]),
                .panel_c(C_int[panel_index]),
                .panel_d(D_int[panel_index]),
                .panel_e(E_int[panel_index]),
                .panel_clk(CLK_int[panel_index]),
                .panel_stb(LAT_int[panel_index]),
                .panel_oe(OE_int[panel_index])
            );
        end
    endgenerate

    assign A = A_int[0];
    assign B = B_int[0];
    assign C = C_int[0];
    assign D = D_int[0];
    assign E = E_int[0];
    assign LAT = LAT_int[0];
    assign OE  = OE_int[0];
    assign CLK = CLK_int[0];
endmodule
