//////////////////////////////////////////////////////////////////////////////////
// Title      : CSUN ECE 520 Design Project 1
// Project    : Design Project 1
//////////////////////////////////////////////////////////////////////////////////
// File       : tb_spi_fsm.v<tb_spi_fsm.sim>
// Author     : Anna Bagdishyan 203475460
// Company    : CSUN
// Created    : 2026-11-13
// Last update: 2026-11-15
// Platform   :
// Standard   : SystemVerilog
//////////////////////////////////////////////////////////////////////////////////
// Description: Testbench for spi_fsm.v
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module tb_spi_fsm;

    reg sys_clk;
    reg sys_rst_n;
    reg spi_en;
    reg start;
    reg fall_en;
    reg rise_en;

    wire sclk;
    wire clk_div_en;
    wire load;
    wire latch_rx;
    wire assert_cs;
    wire deassert_cs;
    wire busy;
    wire done;

    integer i;

    // DUT
    spi_fsm DUT (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .spi_en(spi_en),
        .start(start),
        .fall_en(fall_en),
        .rise_en(rise_en),

        .sclk(sclk),
        .clk_div_en(clk_div_en),
        .load(load),
        .latch_rx(latch_rx),
        .assert_cs(assert_cs),
        .deassert_cs(deassert_cs),
        .busy(busy),
        .done(done)
    );
    
    // 20 ns period = 50 MHz clk
    always #10 sys_clk = ~sys_clk;

    initial begin
    sys_clk = 0;
    sys_rst_n = 0;
    spi_en = 0;
    start = 0;
    fall_en = 0;
    rise_en = 0;

    
    // holding reset for 5 clk cycles
    #100;
    sys_rst_n = 1;
    
    // Test 1 - check after reset
    #1;
    
    if (sclk != 1'b1) begin
        $display("FAILED: sclk should be 1 after reset");
        $finish;
    end
    
    if (busy != 1'b0) begin
        $display("FAILED: busy should be 0 after reset");
        $finish;
    end

    if (done != 1'b0) begin
        $display("FAILED: done should be 0 after reset");
        $finish;
    end

    // Test 2 - assert_cs
    spi_en = 1;
    start = 1;
    @(posedge sys_clk);
    #1;
    spi_en = 0;
    start = 0;

    if (clk_div_en != 1'b1) begin // checking state
        $display("FAILED: clk_div_en should be 1 during TRANSFER");
        $finish;
    end

    if (busy != 1'b1) begin
        $display("FAILED: busy should be 1 after asserting spi_en = 1 and start");
        $finish;
    end

    if (assert_cs != 1'b1) begin
        $display("FAILED: assert_cs should be 1 after asserting spi_en = 1 and start");
        $finish;
    end

    if (load != 1'b1) begin
        $display("FAILED: load should be 1 after asserting spi_en = 1 and start");
        $finish;
    end

     // Test 3 - asserting start when busy is high
    spi_en = 1;
    start = 1;
    @(posedge sys_clk);
    #1;
    start = 0;

    if (load != 1'b0) begin
        $display("FAILED: start should be ignored when busy");
        $finish;
    end
    if (busy != 1'b1) begin
        $display("FAILED: start should be ignored when busy");
        $finish;
    end

    // Test 4 - 16 rise_en pulses
    for (i = 0; i < 16; i = i + 1) begin
        fall_en = 1;
        @(posedge sys_clk);
        #1;
        fall_en = 0;

        if (sclk != 1'b0) begin
            $display("FAILED: sclk should be 0 after fall_en");
        $finish;
        end

        rise_en = 1;
        @(posedge sys_clk);
        #1;
        rise_en = 0;

        if (sclk != 1'b1) begin
            $display("FAILED: sclk should be 1 after rise_en");
        $finish;
        end
    end
    if (latch_rx != 1'b1) begin
        $display("FAILED: latch_rx should be 1 after 16 bits");
        $finish;
    end

    @(posedge sys_clk);
    #1;

    if (done != 1'b1) begin
        $display("FAILED: done should be 1");
        $finish;
     end

    if (deassert_cs != 1'b1) begin
        $display("FAILED: deassert_cs should be 1");
        $finish;
    end

    if (clk_div_en != 1'b0) begin // checking state
        $display("FAILED: clk_div_en should be 0 during DONE");
        $finish;
    end

    @(posedge sys_clk);
    #1;

    if (busy != 1'b0) begin
        $display("FAILED: busy should deassert");
        $finish;
    end

    if (sclk != 1'b1) begin
        $display("FAILED: sclk should be 1");
        $finish;
    end
    
    // verify no second transfer happens
    @(posedge sys_clk);
    #1;
    if (load != 1'b0) begin
        $display("FAILED: should not be a second transfer");
        $finish;
    end
    if (busy != 1'b0) begin
        $display("FAILED: should not be a second transfer");
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