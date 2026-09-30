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
     * PWM_INTERVAL = # CLK cycles for 1 complete PWM cycle (0% -> 100% duty)
     *
     * CLK frequency is 12MHz
     * 1 PWM cycle takes 1,200 clock cycles, so PWM frequency is 10kHz
     */
    parameter PWM_INTERVAL = 1200,

    /*
     * FADE_STEP_NUM = # of times duty cycle is incremented/decremented
     * in a complete PWM cycle
     *
     * Controls smoothness of fading
     */
    parameter FADE_STEP_NUM = 200,

    /*
     * FADE_STEP_INTERVAL = # CLK cycles between each fade step
     *
     * Period of complete fade cycle = FADE_STEP_INTERVAL * FADE_STEP_NUM
     */
    parameter FADE_STEP_INTERVAL = 10000,

    /*
     * FADE_STEP_SIZE = # of CLK cycles the duty cycle is incremented/decremented by each step
     *
     * Depends on # of CLK cycles in 1 complete PWM cycle
     */
    parameter FADE_STEP_SIZE = PWM_INTERVAL / FADE_STEP_NUM
) (
    input logic clk,
    output logic [$clog2(PWM_INTERVAL)-1 : 0] pwm_duty_red,
    output logic [$clog2(PWM_INTERVAL)-1 : 0] pwm_duty_green,
    output logic [$clog2(PWM_INTERVAL)-1 : 0] pwm_duty_blue
);

    /*
     * Finite state machine
     *
     * States names describe color transition
     *
     * Each state lasts for 1 complete PWM cycle
     */
    typedef enum logic [2:0] {
        RED_YELLOW,
        YELLOW_GREEN,
        GREEN_CYAN,
        CYAN_BLUE,
        BLUE_MAGENTA,
        MAGENTA_RED
    } fade_state_t;

    fade_state_t current_state = RED_YELLOW;
    fade_state_t next_state;

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
        pwm_duty_red = PWM_INTERVAL;
        pwm_duty_green = 0;
        pwm_duty_blue = 0;
    end

    // Register fade state transition
    always_ff @(posedge fade_transition) begin
        current_state <= next_state;
    end

    // Compute next state of the FSM
    always_comb begin
        next_state = fade_state_t'(3'bxxx); // typecast as enum
        case (current_state)
            RED_YELLOW:
                next_state = YELLOW_GREEN;
            YELLOW_GREEN:
                next_state = GREEN_CYAN;
            GREEN_CYAN:
                next_state = CYAN_BLUE;
            CYAN_BLUE:
                next_state = BLUE_MAGENTA;
            BLUE_MAGENTA:
                next_state = MAGENTA_RED;
            MAGENTA_RED:
                next_state = RED_YELLOW;
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
            RED_YELLOW:
                pwm_duty_green <= pwm_duty_green + FADE_STEP_SIZE;
            YELLOW_GREEN:
                pwm_duty_red <= pwm_duty_red - FADE_STEP_SIZE;
            GREEN_CYAN:
                pwm_duty_blue <= pwm_duty_blue + FADE_STEP_SIZE;
            CYAN_BLUE:
                pwm_duty_green <= pwm_duty_green - FADE_STEP_SIZE;
            BLUE_MAGENTA:
                pwm_duty_red <= pwm_duty_red + FADE_STEP_SIZE;
            MAGENTA_RED:
                pwm_duty_blue <= pwm_duty_blue - FADE_STEP_SIZE;
        endcase
    end

    // Counter for fade state transition
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

endmodule
