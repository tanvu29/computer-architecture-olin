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
    output logic    RGB_R,
    output logic    RGB_G,
    output logic    RGB_B
);

    logic [$clog2(PWM_INTERVAL)-1 : 0] pwm_duty_red;
    logic [$clog2(PWM_INTERVAL)-1 : 0] pwm_duty_green;
    logic [$clog2(PWM_INTERVAL)-1 : 0] pwm_duty_blue;

    logic pwm_out_red;
    logic pwm_out_green;
    logic pwm_out_blue;

    fade #(
        .PWM_INTERVAL       (PWM_INTERVAL)
    ) u1 (
        .clk                (clk),
        .pwm_duty_red       (pwm_duty_red),
        .pwm_duty_green     (pwm_duty_green),
        .pwm_duty_blue      (pwm_duty_blue)
    );

    pwm #(
        .PWM_INTERVAL       (PWM_INTERVAL)
    ) u2 (
        .clk                (clk),
        .pwm_duty_red       (pwm_duty_red),
        .pwm_duty_green     (pwm_duty_green),
        .pwm_duty_blue      (pwm_duty_blue),
        .pwm_out_red        (pwm_out_red),
        .pwm_out_green      (pwm_out_green),
        .pwm_out_blue       (pwm_out_blue)
    );

    assign RGB_R = ~pwm_out_red;
    assign RGB_G = ~pwm_out_green;
    assign RGB_B = ~pwm_out_blue;

endmodule
