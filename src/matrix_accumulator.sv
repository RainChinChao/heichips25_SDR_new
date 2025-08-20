module matrix_accumulator#(
    parameter RANGE_X_MIN,                  // inclusive
    parameter RANGE_X_MAX,    // inclusive
    parameter RANGE_Y_MIN,
    parameter RANGE_Y_MAX
)

(
    input  logic clk,
    input  logic rst_n,
    //input  logic enable,                        // when high, triggers the update
    input  logic [5:0] x_index,
    input  logic [5:0] y_index,
    output logic [8:0] [8:0]matrix // 8-bit counters
);

    // Internal signals
    logic in_range;
    logic [5:0] x_local;
    logic [5:0] y_local;

    // Check if x and y are in valid range
    always_comb begin
        in_range = (x_index >= RANGE_X_MIN && x_index <= RANGE_X_MAX) &&
                   (y_index >= RANGE_Y_MIN && y_index <= RANGE_Y_MAX);
        x_local  = x_index - RANGE_X_MIN;
        y_local  = y_index - RANGE_Y_MIN;
    end

    // Update matrix on clock
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset matrix
            integer i, j;
            for (i = 0; i < 3; i = i + 1)
                for (j = 0; j < 3; j = j + 1)
                    matrix[i*3+j] <= '0;
        end else begin
            if (in_range) begin
                matrix[x_local*3+y_local] <= matrix[x_local*3+y_local] + 1;
            end
        end
    end

endmodule
