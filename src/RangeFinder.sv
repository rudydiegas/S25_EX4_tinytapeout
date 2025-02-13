`default_nettype none

module RangeFinder
#(parameter WIDTH=16)
 (input  logic [WIDTH-1:0] data_in,
  input  logic             clock, reset,
  input  logic             go, finish,
  output logic [WIDTH-1:0] range,
  output logic             debug_error);

  enum logic [1:0] {WAIT, COMPUTE} curr_state, next_state;

  logic invalid_start, valid_start, error;
  logic [WIDTH-1:0] min_val, max_val;

  assign valid_start = go & ~finish;
  assign invalid_start = go & finish;
  assign debug_error = error | invalid_start;
  assign range = max_val - min_val;

  always_comb begin
    next_state = WAIT;
    case (curr_state)
      WAIT:
        next_state = (valid_start) ? COMPUTE : WAIT;
      COMPUTE:
        next_state = (finish) ? WAIT : COMPUTE;
    endcase
  end

  always_ff @(posedge clock, posedge reset) begin
    if (reset)
      error <= '0;
    else if (valid_start)
      error <= '0;
    else if (go && finish)
      error <= '1;
  end

  always_ff @(posedge clock, posedge reset) begin
    if (reset) begin
      min_val <= '1;
      max_val <= '0;
    end
    else if (curr_state == COMPUTE || valid_start) begin
      if (data_in < min_val) begin
        min_val <= data_in;
      end

      if (max_val < data_in) begin
        max_val <= data_in;
      end
    end
  end

  always_ff @(posedge clock, posedge reset) begin
    if (reset)
      curr_state <= WAIT;
    else
      curr_state <= next_state;
  end

endmodule : RangeFinder
