`timescale 10ns / 1ps
//`include "memory.sv"
//`include "game_of_life.sv"
`include "top.sv"

module game_of_life_tb;
    parameter PWM_INTERVAL = 1200;


    logic clk = 0;
    logic _48b;


    /*
    logic clk = 0;
    logic compute_generation = 0;
    logic [5:0] pixel = 6'd0;
    logic cell_alive;

    game_of_life #(
        .INIT_FILE("blinker_init.mem")
    ) dut (
        .clk(clk),
        .compute_generation(compute_generation),
        .pixel(pixel),
        .cell_alive(cell_alive)
    );
    */


    top # (
        .PWM_INTERVAL   (PWM_INTERVAL)
    ) u0 (
        .clk            (clk),
        ._48b           (_48b)
    );


    initial begin
        $dumpfile("game_of_life.vcd");
        $dumpvars(0, game_of_life_tb);
        #50000000 // 50,000,000 * 10ns = 0.5s
        $finish;
    end

    always begin
        #4.16 // 41.6 ns toggle delay -> simulation CLK period: 83.2 ns
        clk = ~clk;
    end


endmodule
