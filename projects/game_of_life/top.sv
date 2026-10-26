`include "ws2812b.sv"
`include "controller.sv"
`include "game_of_life.sv"

`include "fade.sv"
`include "pwm.sv"

module top #(
    parameter PWM_INTERVAL = 1200
)(
    input logic     clk,
    output logic    _48b
);

    logic [$clog2(PWM_INTERVAL)-1 : 0] pwm_duty_red;
    logic [$clog2(PWM_INTERVAL)-1 : 0] pwm_duty_green;
    logic [$clog2(PWM_INTERVAL)-1 : 0] pwm_duty_blue;

    logic [7:0] pwm_out_red;
    logic [7:0] pwm_out_green;
    logic [7:0] pwm_out_blue;

    logic [5:0] pixel;
    logic [4:0] frame;
    logic [10:0] address;

    logic [23:0] shift_reg = 24'd0;
    logic load_sreg;
    logic transmit_pixel;
    logic shift;
    logic ws2812b_out;

    logic compute_generation;
    logic cell_alive;

    // Instance the WS2812B output driver
    ws2812b u1 (
        .clk                (clk),
        .serial_in          (shift_reg[23]),
        .transmit           (transmit_pixel),
        .ws2812b_out        (ws2812b_out),
        .shift              (shift)
    );

    // Instance the controller
    controller u2 (
        .clk                (clk),
        .load_sreg          (load_sreg),
        .transmit_pixel     (transmit_pixel),
        .pixel              (pixel),
        .frame              (frame),
        .compute_generation (compute_generation)
    );

    game_of_life #(
        .INIT_FILE("glider_init.mem")
    ) u3 (
        .clk                (clk),
        .compute_generation (compute_generation),
        .pixel              (pixel),
        .cell_alive         (cell_alive)
    );

    fade #(
        .PWM_INTERVAL       (PWM_INTERVAL)
    ) u4 (
        .clk                (clk),
        .pwm_duty_red       (pwm_duty_red),
        .pwm_duty_green     (pwm_duty_green),
        .pwm_duty_blue      (pwm_duty_blue)
    );

    pwm #(
        .PWM_INTERVAL       (PWM_INTERVAL)
    ) u5 (
        .clk                (clk),
        .pwm_duty_red       (pwm_duty_red),
        .pwm_duty_green     (pwm_duty_green),
        .pwm_duty_blue      (pwm_duty_blue),
        .pwm_out_red        (pwm_out_red),
        .pwm_out_green      (pwm_out_green),
        .pwm_out_blue       (pwm_out_blue)
    );

    always_ff @(posedge clk) begin
        if (load_sreg) begin
            if (cell_alive) begin
                shift_reg <= {pwm_out_green, pwm_out_red, pwm_out_blue};
            end
            else begin
                shift_reg <= {8'h00, 8'h00, 8'h00};
            end
        end
        else if (shift) begin
            shift_reg <= { shift_reg[22:0], 1'b0 };
        end
    end

    assign _48b = ws2812b_out;

endmodule
