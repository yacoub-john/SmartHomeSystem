
//  CLKS_PER_BIT regulates the baud rate.  This is the number of 
//  input clock cycles to hold each each bit before shifting out 
//  the next bit.  
//
//  The calculation is as follows:
//
//                                                  1
//     CLKS_PER_BIT =  F_clk [cycles/sec] * --------------------
//                                           baud_rate[bit/sec]
//
//
//  Some examples for common baud rates are listed below:
//  (assuming, 50 MHz input clock)
//
//      target           CLKS_PER_BIT            actual
//    baud rate      (exact)    (rounded)      baud rate*
//    [bits/sec]                               [bits/sec]
//   -----------------------------------------------------
//         300      166,667.67   166,667          300.0
//       9,600        5,208.33     5,208        9,600.6
//      19,200        2,604.17     2,604       19,201.2   
//      38,400        1,302.08     1,302       38,402.5
//      57,600          868.06       868       57,603.7
//     115,200          434.03       434      115,207.4  
//
//  For the baud rates in the table above, the baud rate 
//  errors are less than 0.1%, though for other baud rates, 
//  the errors may be larger.  
//
//  300 baud was included on the low low range just to show
//  how large CLKS_PER_BIT can become for slow baud rates.
//  Slow baud rates drive the bit width required for the 
//  associated counter variables.  
//
//  *assuming 50 MHz input clock has no error.
////////////////////////////////////////////////////////////////////////////////
//
//

module	warningMessage #(
		// Here we set i_setup to something appropriate to create a
		// 57600 Baud UART system from a 50MHz clock.  This also sets
		// us to an 8-bit data word, 1-stop bit, and no parity. 
		parameter	UART_SETUP = 31'd868
	) (
		input		wire		i_clk,
		input 	wire     send,
		output	wire		o_uart_tx
	);

	// Signal declarations
	reg	[7:0]	message	[0:15];
	reg		pwr_reset;
	reg	[27:0]	counter;
	wire		tx_break, tx_busy;
	reg		tx_stb;
	reg	[3:0]	tx_index;
	reg	[7:0]	tx_data;
	wire		cts_n;
	

	initial	pwr_reset = 1'b1;
	always @(posedge i_clk)
		if(send)
			pwr_reset <= 1'b0;
		else
			pwr_reset <= 1'b1;

	// Initialize the message
	initial begin
		message[ 0] = "I";
		message[ 1] = "N";
		message[ 2] = "T";
		message[ 3] = "R";
		message[ 4] = "U";
		message[ 5] = "D";
		message[ 6] = "E";
		message[ 7] = "R";
		message[ 8] = " ";
		message[ 9] = "A";
		message[10] = "L";
		message[11] = "E";
		message[12] = "R";
		message[13] = "T";
		message[14] = "\r";
		message[15] = "\n";
	end


	// Send a message to the transmitter
	initial	counter = 28'hffffff0;
	always @(posedge i_clk)
		counter <= counter + 1'b1;

	assign	tx_break = 1'b0;

	initial	tx_index = 4'h0;
	always @(posedge i_clk)
	if ((tx_stb)&&(!tx_busy))
		tx_index <= tx_index + 1'b1;

	always @(posedge i_clk)
		tx_data <= message[tx_index];

	initial	tx_stb = 1'b0;
	always @(posedge i_clk)
	if (&counter)
		tx_stb <= 1'b1;
	else if ((tx_stb)&&(!tx_busy)&&(tx_index==4'hf))
		tx_stb <= 1'b0;

	// The UART transmitter
	assign	cts_n = 1'b0;

	txuart	transmitter(i_clk, pwr_reset, UART_SETUP, tx_break,
			tx_stb, tx_data, cts_n, o_uart_tx, tx_busy);

endmodule