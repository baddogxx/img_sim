`timescale 1ns / 1ps

module tb_max_domain();

    // Inputs
    reg clk;
    reg rst_n;
    reg [8:0] in_up;
    reg [8:0] in_dowm;
    reg [8:0] in_left;
    reg [8:0] in_right;
    reg [9:0] label;
    reg [19:0] pixel_num;
    
max_domain u_max_domain(
    .clk       (clk       ),
    .rst_n     (rst_n     ),

    .in_vsync  (in_vsync  ),
    .in_valid  (in_valid  ),
    .in_href   (in_href   ),
    .in_data   (in_data   ),

    .out_vsync (out_vsync ),
    .out_valid (out_valid ),
    .out_href  (out_href  ),
    .out_data  (out_data  ),
    
    .center_x  (center_x  ),
    .center_y  (center_y  )
);

    

    // Outputs
    wire [8:0] out_up;
    wire [8:0] out_dowm;
    wire [8:0] out_left;
    wire [8:0] out_right;



    // Clock generation
    always #5 clk = ~clk;  // Clock period of 10 ns

    // Initial Setup and Test Stimuli
    initial begin
        // Initialize Inputs
        clk = 0;
        rst_n = 0;
        in_up = 0;
        in_dowm = 0;
        in_left = 0;
        in_right = 0;
        label = 0;
        pixel_num = 0;

        // Reset the system
        #15;
        rst_n = 1;

        // Test cycle 11
        #10;  // Wait until 10th cycle
        label = 1;
        pixel_num = 39996;
        in_up = 101;
        in_dowm = 300;
        in_left = 344;
        in_right = 31;

        // Test cycle 12
        #10;  // Next cycle
        label = 2;
        pixel_num = 9996;
        in_up = 281;
        in_dowm = 380;
        in_left = 104;
        in_right = 203;

        // Return to zero input
        #10;  // Cycles 13, 14, and 15
        label = 0;
        pixel_num = 0;
        in_up = 0;
        in_dowm = 0;
        in_left = 0;
        in_right = 0;

        // End of Test
        #30;
        $finish;
    end

endmodule

