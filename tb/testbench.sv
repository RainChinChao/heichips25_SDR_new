`timescale 1ns / 1ps

module heichips25_template_tb;

    // Testbench signals
    logic clk;
    logic rst_n;
    logic [7:0] ui_in;
    logic [7:0] uio_in;
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;
    logic ena;

    // Instantiate the DUT
    heichips25_template dut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );

    // Clock generation
    always #5 clk = ~clk; // 100MHz clock

    // Task to apply input vector
    task apply_inputs(
        input [3:0] I1, Q1,
        input [3:0] I2, Q2
    );
        begin
            ui_in = {Q1, I1};
            uio_in = {I2, Q2};
        end
    endtask

    // Initial block
    initial begin
        // Init
        clk = 0;
        rst_n = 0;
        ena = 1;
        ui_in = 8'd0;
        uio_in = 8'd0;

        // Reset pulse
        #10;
        rst_n = 1;

        // Apply stimulus
        
            apply_inputs(4'd0, 4'd2, 4'd0, 4'd2); // within valid ranges for all DP
           #10;
           apply_inputs(4'd0,4'd2, 4'd0, 4'd2);
            #10;
           apply_inputs(4'd0,4'd2, 4'd0, 4'd2);
            #10;
           apply_inputs(4'd0,4'd2, 4'd0, 4'd2);
            #80;
           apply_inputs(4'd0,4'd2, 4'd0, 4'd2);
            #10;
           apply_inputs(4'd0,4'd0, 4'd0, 4'd0);
//        repeat (4) begin
//            apply_inputs(4'd31, 4'd23, 4'd34, 4'd42); // edge range testing
//            #10;
//        end

//        apply_inputs(4'd10, 4'd10, 4'd10, 4'd10); // outside range
//        #20;

        // Wait for outputs to settle
        #50;

        // Print results
        $display("uo_out = %h", uo_out);
        $display("uio_out = %h", uio_out);
        $finish;
    end

endmodule
