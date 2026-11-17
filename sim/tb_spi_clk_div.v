//////////////////////////////////////////////////////////////////////////////////
// Title      : CSUN ECE 520 Design Project 1
// Project    : Design Project 1
//////////////////////////////////////////////////////////////////////////////////
// File       : tb_spi_clk_div.v<tb_spi_clk_div.sim>
// Author     : Anna Bagdishyan 203475460
// Company    : CSUN
// Created    : 2026-11-13
// Last update: 2026-11-15
// Platform   :
// Standard   : Verilog
//////////////////////////////////////////////////////////////////////////////////
// Description: Testbench for spi_clk_div.v
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module tb_spi_clk_div;

    reg sys_clk;
    reg sys_rst_n;
    reg [7:0] clk_div;
    reg en;
    wire fall_en;
    wire rise_en;

    integer i;


    // DUT
    spi_clk_div DUT (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .clk_div(clk_div),
        .en(en),

        .fall_en(fall_en),
        .rise_en(rise_en)
    );
    
    // 20 ns period = 50 MHz clk
    always #10 sys_clk = ~sys_clk;

    initial begin
    sys_clk = 0;
    sys_rst_n = 0;
    clk_div = 8'd0; 
    en = 1;
    
    // holding reset for 5 clk cycles
    #100;
    sys_rst_n = 1;
    
    // Test 1 - check reset
    #1;
    
    if (fall_en != 1'b0) begin
        $display("FAILED: fall_en should be 0 after reset");
        $finish;
    end
    if (rise_en != 1'b0) begin
        $display("FAILED: rise_en should be 0 after reset");
        $finish;
    end
    
    // Test 2 - clk_div = 2
    clk_div = 8'd2;
    en = 1;

    @(posedge sys_clk);
    #1;

    if (fall_en != 1'b0 || rise_en != 1'b0) begin
        $display("FAILED: Outputs should be 0 between pulses");
        $finish;
    end

    @(posedge sys_clk);
    @(posedge sys_clk);
    #1;
    if (fall_en != 1'b1 || rise_en != 1'b0) begin
        $display("FAILED: fall_en should be 1 and rise_en should be 0");
        $finish;
    end

    @(posedge sys_clk);
    @(posedge sys_clk);
    @(posedge sys_clk);
    #1;
    if (fall_en != 1'b0 || rise_en != 1'b1) begin
        $display("FAILED: fall_en should be 0 and rise_en should be 1");
        $finish;
    end

    // Test 3 - Transition en from 1 to 0
    en = 0;
    @(posedge sys_clk);
    #1;

    if (fall_en != 1'b0) begin
        $display("FAILED: fall_en should be 0 after transitioning en");
        $finish;
    end
    if (rise_en != 1'b0) begin
        $display("FAILED: rise_en should be 0 after transitioning en");
        $finish;
    end

    // Test 4 - clk_div = 0
    clk_div = 8'd0;
    en = 1;

    for (i = 0; i < 8; i = i + 1) begin
        @(posedge sys_clk);
        #1;

        if (i % 2 == 0) begin // should alternate
                if (fall_en != 1'b1 || rise_en != 1'b0) begin
                    $display("FAILED: Expected fall_en at cycle %0d", i);
                    $finish;
                end
            end
            else begin
                if (fall_en != 1'b0 || rise_en != 1'b1) begin
                    $display("FAILED: Expected rise_en at cycle %0d", i);
                    $finish;
                end
            end
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
