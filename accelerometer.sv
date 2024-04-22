module accelerometer (
   //////////// CLOCK //////////
   input 		          		MAX10_CLK1_50,
   //////////// Accelerometer ports //////////
   output		          		GSENSOR_CS_N,
   input 		     [2:1]		GSENSOR_INT,
   output		          		GSENSOR_SCLK,
   inout 		          		GSENSOR_SDI,
   inout 		          		GSENSOR_SDO,
	output           [15:0]    data_x, 
	output           [15:0]    data_y
   );

//===== Declarations
   localparam SPI_CLK_FREQ  = 200;  // SPI Clock (Hz)
   localparam UPDATE_FREQ   = 1;    // Sampling frequency (Hz)

   // clks and reset
   wire reset_n;
   wire clk, spi_clk, spi_clk_out;

   // output data
   wire data_update;

//===== Phase-locked Loop (PLL) instantiation. Code was copied from a module
//      produced by Quartus' IP Catalog tool.
ip ip_inst (
   .inclk0 ( MAX10_CLK1_50 ),
   .c0 ( clk ),                 // 25 MHz, phase   0 degrees
   .c1 ( spi_clk ),             //  2 MHz, phase   0 degrees
   .c2 ( spi_clk_out )          //  2 MHz, phase 270 degrees
   );

//===== Instantiation of the spi_control module which provides the logic to 
//      interface to the accelerometer.
spi_control #(     // parameters
      .SPI_CLK_FREQ   (SPI_CLK_FREQ),
      .UPDATE_FREQ    (UPDATE_FREQ))
   spi_ctrl (      // port connections
      .reset_n    (reset_n),
      .clk        (clk),
      .spi_clk    (spi_clk),
      .spi_clk_out(spi_clk_out),
      .data_update(data_update),
      .data_x     (data_x),
      .data_y     (data_y),
      .SPI_SDI    (GSENSOR_SDI),
      .SPI_SDO    (GSENSOR_SDO),
      .SPI_CSN    (GSENSOR_CS_N),
      .SPI_CLK    (GSENSOR_SCLK),
      .interrupt  (GSENSOR_INT)
   );

//Disable reset
assign reset_n = 1;

reg [15:0] data_x_reg, data_y_reg;

clock #(32'd2500000) slow(MAX10_CLK1_50, slowClock);

//Register outputs
always @(posedge slowClock)begin
	data_x_reg <= data_x;
	data_y_reg <= data_y;

end

endmodule