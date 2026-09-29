/*
 * Fade LED in and out
 *
 * Inputs:
 * - CLK
 *
 * Outputs:
 * - Duty cycle
 */

module fade #(
    /*
     * PWM_INTERVAL = # CLK cycles for 1 PWM cycle
     *
     * CLK frequency is 12MHz
     * 1 PWM cycle takes 1,200 clock cycles, so PWM frequency is 10kHz
     *
     * Determines when fade in/out transition occurs
     */
    parameter PWM_INTERVAL = 1200,

    /*
     * FADE_STEP_INTERVAL = # CLK cycles between each fade step
     *
     * CLK frequency is 12MHz
     * 1 fade cycle takes 12,000 clock cycles, so fade frequency is 1kHz
     */
    parameter FADE_STEP_INTERVAL = 12000,

    /*
     * FADE_STEP_NUM = # of times duty cycle is incremented/decremented
     *
     * Switch fade direction every 200 steps
     */
    parameter FADE_STEP_NUM = 200,

    /*
     * FADE_STEP_SIZE = # of CLK cycles the duty cycle is incremented/decremented by each step
     *
     * Depends on # of CLK cycles in 1 PWM cycle
     */
    parameter FADE_STEP_SIZE = PWM_INTERVAL / FADE_STEP_NUM
) (
    input logic clk,
    output logic [$clog2(PWM_INTERVAL)-1 : 0] pwm_value
);

    /*
     * Finite state machine
     *
     * States:
     * - Fading in: INCREMENT
     * - Fading out: DECREMENT
     */
    typedef enum logic {
        FADE_IN = 1'b0,
        FADE_OUT = 1'b1
    } fade_direction_t;

    fade_direction_t current_state = FADE_IN;
    fade_direction_t next_state;

    /*
     * State transition timing
     */

    // Counter for CLK cycles between each step
    logic [$clog2(FADE_STEP_INTERVAL)-1 : 0] step_interval_count = 0;

    // Counter for steps between each transition
    logic [$clog2(FADE_STEP_NUM)-1 : 0] step_num_count = 0;

    // Condition to trigger step
    logic fade_step = 1'b0;

    // Condition to trigger state transition
    logic fade_transition = 1'b0;

    initial begin
        pwm_value = 0;
    end

    // Compute next state of the FSM
    always_comb begin
        next_state = 1'bx;
        case (current_state)
            FADE_IN:
                next_state = FADE_OUT;
            FADE_OUT:
                next_state = FADE_IN;
        endcase
    end

    // Counter for fade step
    always_ff @(posedge clk) begin
        if (step_interval_count == FADE_STEP_INTERVAL - 1) begin
            step_interval_count <= 0;
            fade_step <= 1'b1;
        end
        else begin
            step_interval_count <= step_interval_count + 1;
            fade_step <= 1'b0;
        end
    end

    // Register fade step (increment/decrement duty cycle)
    always_ff @(posedge fade_step) begin
        case (current_state)
            FADE_IN:
                pwm_value <= pwm_value + FADE_STEP_SIZE;
            FADE_OUT:
                pwm_value <= pwm_value - FADE_STEP_SIZE;
        endcase
    end

    // Counter for fade transition
    always_ff @(posedge fade_step) begin
        if (step_num_count == FADE_STEP_NUM - 1) begin
            step_num_count <= 0;
            fade_transition <= 1'b1;
        end
        else begin
            step_num_count <= step_num_count + 1;
            fade_transition <= 1'b0;
        end
    end

    // Register fade transition (write next state)
    always_ff @(posedge fade_transition) begin
        current_state <= next_state;
    end

endmodule
