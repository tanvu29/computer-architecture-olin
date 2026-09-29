/*
 * Generate PWM signal
 *
 * Inputs:
 * - CLK
 * - Duty cycle
 *
 * Outputs:
 * - PWM signal
 */

module pwm #(
    /*
     * PWM_INTERVAL = # CLK cycles for 1 PWM cycle
     *
     * CLK frequency is 12MHz
     * 1 PWM cycle takes 1,200 clock cycles, so PWM frequency is 10kHz
     */
    parameter PWM_INTERVAL = 1200
) (
    input logic clk,

    // threshold (# CLK cycles) for configuring duty cycle
    input logic [$clog2(PWM_INTERVAL)-1 : 0] pwm_value,

    // PWM signal directly driving LED
    output logic pwm_out
);

    logic [$clog2(PWM_INTERVAL)-1 : 0] pwm_count;

    // PWM timer
    always_ff @(posedge clk) begin
        if (pwm_count == PWM_INTERVAL - 1) begin
            pwm_count <= 0;
        end
        else begin
            pwm_count <= pwm_count + 1;
        end
    end

    // Duty cycle threshold
    assign pwm_out = (pwm_count > pwm_value) ? 1'b1 : 1'b0;

endmodule
