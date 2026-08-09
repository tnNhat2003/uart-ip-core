module UartTxResetTest ();

reg reset_i = 1'b0;
reg clock_i = 1'b0;
reg write_i = 1'b0;
reg two_stop_bits_i = 1'b0;
reg parity_bit_i = 1'b0;
reg parity_even_i = 1'b0;
reg [15:0] clock_divider_i = 0;
reg [7:0] data_i = 8'h00;
wire serial_o;
wire busy_o;

UartTx uart_tx (
  .reset_i(reset_i),
  .clock_i(clock_i),
  .write_i(write_i),
  .two_stop_bits_i(two_stop_bits_i),
  .parity_bit_i(parity_bit_i),
  .parity_even_i(parity_even_i),
  .clock_divider_i(clock_divider_i),
  .data_i(data_i),
  .serial_o(serial_o),
  .busy_o(busy_o)
);

always #1 clock_i <= ~clock_i;

always @ (*) begin
  if (reset_i) begin
    if (!busy_o)
      $display("FAILED - busy_o should be high when reset_i is high");

    if (!serial_o)
      $display("FAILED - serial_o should be high when reset_i is high");
  end
end

initial begin
  #1 reset_i = 1'b1;

  #1
  if (!busy_o)
    $display("FAILED - Should be busy during reset_i");

  reset_i = 1'b0;

  #24 if (!busy_o)
    $display("FAILED - Should wait one packet length after reset");

  #2 if (busy_o)
    $display("FAILED - busy_o should go low after reset wait time");
end

endmodule
