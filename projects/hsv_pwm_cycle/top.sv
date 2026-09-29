`include "fade.sv"
`include "pwm.sv"

module top #(
    /*
     * PWM_INTERVAL = # CLK cycles for 1 PWM cycle
     *
     * CLK frequency is 12MHz
     * 1 PWM cycle takes 1,200 clock cycles, so PWM frequency is 10kHz
     */
    parameter PWM_INTERVAL = 1200
) (
    input logic     clk,
    output logic    LED
);

    logic [$clog2(PWM_INTERVAL)-1 : 0] pwm_value;
    logic pwm_out;

    fade #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u1 (
        .clk            (clk),
        .pwm_value      (pwm_value),
    );

    pwm #(
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u2 (
        .clk            (clk),
        .pwm_value      (pwm_value),
        .pwm_out        (pwm_out)
    );

    assign LED = ~pwm_out;

endmodule
