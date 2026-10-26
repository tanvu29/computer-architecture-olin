`include "memory.sv"

module game_of_life #(
    parameter INIT_FILE = ""
)(
    input logic clk,
    input logic compute_generation,
    input logic [5:0] pixel, // pixel index (0-63)
    output logic cell_alive
);

    logic current_grid[0:7][0:7];
    logic next_grid[0:7][0:7];

    // only for viewing in gtkwave, since unpacked arrays aren't supported
    logic [63:0] current_grid_packed;
    logic [63:0] next_grid_packed;

    // load initial state from memory (ROM)
    logic [5:0] init_address = 6'd0; // 5-bit address (0-63)
    logic [5:0] temp_address = 6'd0; // use this to populate grid while incrementing the address

    logic init_data;
    logic init_read_valid = 1'b0;
    logic init_done = 1'b0;

    memory #(
        .INIT_FILE(INIT_FILE)
    ) initial_state_rom (
        .clk          (clk),
        .read_address (init_address),
        .read_data    (init_data)
    );

    always_ff @(posedge clk) begin
        if (!init_done) begin
            if (init_read_valid) begin
                current_grid[temp_address[5:3]][temp_address[2:0]] <= init_data;

                if (address_d == 6'd63) begin
                    init_done <= 1'b1;
                end
            end

            init_read_valid <= 1'b1; // skip 1st clock cycle to wait for ROM latency
            temp_address <= init_address; // record temp address while address increments

            if (init_address != 6'd63) begin
                init_address <= init_address + 1'b1;
            end
        end
    end

    // register next grid of cells
    always_ff @(posedge clk) begin
        if (compute_generation && init_done) begin

            // load cells one by one, since icarus verilog doesn't support assigning unpacked arrays
            for (int r = 0; r < 8; r++) begin
                for (int c = 0; c < 8; c++) begin
                    current_grid[r][c] <= next_grid[r][c];
                end
            end
        end
    end

    // only for viewing in gtkwave, since unpacked arrays aren't supported
    always_comb begin
        for (int r = 0; r < 8; r++) begin
            for (int c = 0; c < 8; c++) begin
                current_grid_packed[r * 8 + c] = current_grid[r][c];
                next_grid_packed[r * 8 + c] = next_grid[r][c];
            end
        end
    end

    // compute cell state in next generation
    generate
        for (genvar row = 0; row < 8; row++) begin
            for (genvar col = 0; col < 8; col++) begin

                localparam int UP = (row == 0) ? 7 : (row - 1);
                localparam int DOWN = (row == 7) ? 0 : (row + 1);
                localparam int LEFT = (col == 0) ? 7 : (col - 1);
                localparam int RIGHT = (col == 7) ? 0 : (col + 1);

                logic [3:0] neighbors;

                always_comb begin
                    neighbors =
                        {3'b000, current_grid[UP][LEFT]}  +
                        {3'b000, current_grid[UP][col]}   +
                        {3'b000, current_grid[UP][RIGHT]} +
                        {3'b000, current_grid[row][LEFT]} +
                        {3'b000, current_grid[row][RIGHT]}+
                        {3'b000, current_grid[DOWN][LEFT]}+
                        {3'b000, current_grid[DOWN][col]} +
                        {3'b000, current_grid[DOWN][RIGHT]};
                end

                // Conway's Game of Life rules, in one line
                assign next_grid[row][col] =
                    (neighbors == 4'd3) || (current_grid[row][col] && neighbors == 4'd2);
            end
        end
    endgenerate

    assign cell_alive = init_done && current_grid[pixel[5:3]][pixel[2:0]];

endmodule
