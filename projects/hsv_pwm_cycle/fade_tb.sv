`timescale 10ns / 100ps // resolution needed to approximate 12 MHz clock (83.333... ns)
`include "top.sv"

module fade_tb;

    parameter PWM_INTERVAL = 1200;

    logic clk = 0;
    logic RGB_R;
    logic RGB_G;
    logic RGB_B;

    top # (
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u0 (
        .clk            (clk),
        .RGB_R          (RGB_R),
        .RGB_G          (RGB_G),
        .RGB_B          (RGB_B)
    );

    initial begin
        $dumpfile("fade.vcd");
        $dumpvars(0, fade_tb);
        #100000000 // 10,000,000 * 10ns = 1s
        $finish;
    end

    always begin
        #4.16 // 41.6 ns toggle delay -> simulation CLK period: 83.2 ns
        clk = ~clk;
    end

endmodule
