//////////////////////////////////////////////////////////////////////////////////
// Title      : CSUN ECE 520 Design Project 1
// Project    : Design Project 1
//////////////////////////////////////////////////////////////////////////////////
// File       : tb_spi_shift_reg.v<tb_spi_shift_reg.srcs>
// Author     : Anna Bagdishyan 203475460
// Company    : CSUN
// Created    : 2026-11-13
// Last update: 2026-11-15
// Platform   :
// Standard   : Verilog
//////////////////////////////////////////////////////////////////////////////////
// Description: Testbench for spi_shift_reg.v
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module tb_spi_shift_reg;

    reg sys_clk;
    reg sys_rst_n;
    reg fall_en;
    reg rise_en;
    reg load;
    reg [15:0] tx_data;
    reg miso;
    reg latch_rx;
    wire mosi;
    wire [15:0] rx_data;

    integer i;

    // DUT
    spi_shift_reg DUT (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .fall_en(fall_en),
        .rise_en(rise_en),
        .load(load),
        .tx_data(tx_data),
        .miso(miso),
        .latch_rx(latch_rx),
        .mosi(mosi),
        .rx_data(rx_data)
    );
    
    // 20 ns period = 50 MHz clk
    always #10 sys_clk = ~sys_clk;

    initial begin
    sys_clk = 0;
    sys_rst_n = 0;
    fall_en = 0;
    rise_en = 0;
    tx_data = 16'd0;
    load = 0;
    miso = 0;
    latch_rx = 0;

    
    // holding reset for 5 clk cycles
    #100;
    sys_rst_n = 1;
    
    // Test 1 - check reset
    #1;
    
    if (rx_data != 1'b0) begin
        $display("FAILED: rx_data should be 0 after reset");
        $finish;
    end
    if (mosi != 1'b0) begin
        $display("FAILED: mosi should be 0 after reset");
        $finish;
    end
    
    // Test 2 - loading 0xA5C3
    load = 1;
    tx_data = 16'hA5C3;
    @(posedge sys_clk);
    #1;
    load = 0;

    for (i = 0; i < 16; i = i + 1) begin
            fall_en = 1;
            @(posedge sys_clk);
            #1;
            fall_en = 0;

            if (mosi != tx_data[15-i]) begin
                $display("FAILED: mosi match bit incorrect at %0d", i);
                $finish;
            end

            if (i < 8) // first 8 = 1, last 8 = 0
            miso = 1;
            else
            miso = 0;
            
            rise_en = 1;
            @(posedge sys_clk);
            #1;
            rise_en = 0;

    end

    // Test 3 - latch data
    latch_rx = 1;
    @(posedge sys_clk);
    #1;
    latch_rx = 0;

    if (rx_data != 16'hFF00) begin
        $display("FAILED: rx_data should be FF00");
        $finish;
    end

    $display("TEST PASSED");
    $finish;
    end
    
    initial begin
    #1_0000_0000;
    $display ("TEST FAILED: TIMOUT");
    $finish;
    end
endmodule