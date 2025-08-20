module DP_Matrix_G  #(
	
    parameter RANGE_X_MIN_o,                  // inclusive
    parameter RANGE_X_MAX_o,    // inclusive
    parameter RANGE_Y_MIN_o,
    parameter RANGE_Y_MAX_o
)(
    input  logic clk,
    input  logic rst_n,  // Active-low synchronous reset
    input  logic signed [3:0] in_data_I,  // Q5.10 fixed-point input
	input  logic signed [3:0] in_data_Q,

    output logic [8:0] [8:0]matrix // 8-bit counters
);




logic [5:0] out_data_I;
logic [5:0] out_data_Q;


Input_pro I_range(
     clk,
    rst_n,  // Active-low synchronous reset
    in_data_I,  // Q5.10 fixed-point input
    out_data_I        // Rounded unsigned output (0 to 8)
);

Input_pro Q_range(
     clk,
    rst_n,  // Active-low synchronous reset
    in_data_Q,  // Q5.10 fixed-point input
    out_data_Q        // Rounded unsigned output (0 to 8)
);

matrix_accumulator  #(
        .RANGE_X_MIN(RANGE_X_MIN_o),
        .RANGE_X_MAX(RANGE_X_MAX_o),
        .RANGE_Y_MIN(RANGE_Y_MIN_o),
        .RANGE_Y_MAX(RANGE_Y_MAX_o))u_matrix_accumulator(
    clk,
	rst_n,
    out_data_I,
    out_data_Q,
    matrix// 8-bit counters
);


endmodule