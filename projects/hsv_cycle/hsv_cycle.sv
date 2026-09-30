// RGB cycle

module hsv_cycle(
    input logic     clk,
    output logic    RGB_R,
    output logic    RGB_G,
    output logic    RGB_B
);

    // CLK frequency is 12MHz, so 2,000,000 CLK cycles is 1/6 of a second
    parameter COLOR_INTERVAL = 2000000;

    // LED timer
    logic [$clog2(COLOR_INTERVAL) - 1:0] count = 0;

    /*
     * FSM for RGB states
     *
     * Defines the 6 required states and
     * maps each to a 3 bit state index
     *
     * Each bit represents an LED state:
     * Bit 0: red
     * Bit 1: green
     * Bit 2: blue
    */
    typedef enum logic [2:0] {
        RED = 3'b001,
        YELLOW = 3'b011,
        GREEN = 3'b010,
        CYAN = 3'b110,
        BLUE = 3'b100,
        MAGENTA = 3'b101
    } state_t;

    state_t state;
    state_t next_state;

    always_comb begin
        case (state)
            RED:     next_state = YELLOW;
            YELLOW:  next_state = GREEN;
            GREEN:   next_state = CYAN;
            CYAN:    next_state = BLUE;
            BLUE:    next_state = MAGENTA;
            MAGENTA: next_state = RED;
            default: next_state = RED;
        endcase
    end

    always_ff @(posedge clk) begin
        if (count == COLOR_INTERVAL - 1) begin
            count <= 0;
            state <= next_state;
        end

        else begin
            count <= count + 1;
        end
    end

    assign RGB_R = ~state[0];
    assign RGB_G = ~state[1];
    assign RGB_B = ~state[2];


endmodule
