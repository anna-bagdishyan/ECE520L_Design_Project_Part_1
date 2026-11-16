//////////////////////////////////////////////////////////////////////////////////
// Title      : CSUN ECE 520 Design Project 1
// Project    : Design Project 1
//////////////////////////////////////////////////////////////////////////////////
// File       : tb_spi_master.v<tb_spi_master.srcs>
// Author     : Anna Bagdishyan 203475460
// Company    : CSUN
// Created    : 2026-11-13
// Last update: 2026-11-15
// Platform   :
// Standard   : SystemVerilog
//////////////////////////////////////////////////////////////////////////////////
// Description: Testbench for spi_master.v
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module tb_spi_master;

    reg sys_clk;
    reg sys_rst_n;
    reg spi_en;
    reg [7:0] clk_div;
    reg start;
    reg [15:0] tx_data;
    reg miso;

    wire cs_n;
    wire sclk;
    wire mosi;
    wire [15:0] rx_data;
    wire busy;
    wire done;

    integer i;

    // DUT
    spi_master DUT (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .spi_en(spi_en),
        .clk_div(clk_div),
        .start(start),
        .tx_data(tx_data),
        .miso(miso),

        .cs_n(cs_n),
        .sclk(sclk),
        .mosi(mosi),
        .rx_data(rx_data),
        .busy(busy),
        .done(done)
    );
    
    // 20 ns period = 50 MHz clk
    always #10 sys_clk = ~sys_clk;

    initial begin
    sys_clk = 0;
    sys_rst_n = 0;
    spi_en = 0;
    clk_div = 8'd2;
    start = 0;
    tx_data = 16'd0;
    miso = 0;

    
    // holding reset for 5 clk cycles
    #100;
    sys_rst_n = 1;
    
    // Test 1 - check after reset
    #1;
    
    if (cs_n != 1'b1) begin
        $display("FAILED: cs_n should be 1 after reset");
        $finish;
    end
    
    if (sclk != 1'b1) begin
        $display("FAILED: sclk should be 1 after reset");
        $finish;
    end

    if (busy != 1'b0) begin
        $display("FAILED: busy should be 0 after reset");
        $finish;
    end

    if (mosi != 1'b0) begin
        $display("FAILED: mosi should be 0 after reset");
        $finish;
    end

    // Test 2 - 0xA5C3
    clk_div = 8'd2;
    spi_en = 1;
    tx_data = 16'hA5C3;
    start = 1;

    @(posedge sys_clk);
    #1;
    start = 0;

    if (busy != 1'b1) begin
    $display("FAILED: busy should be 1");
    $finish;
    end

    @(posedge sys_clk);
    #1;

    if (cs_n != 1'b0) begin
        $display("FAILED: cs_n should be 0 before first SCLK falling edge");
        $finish;
    end

    if (sclk != 1'b1) begin
        $display("FAILED: sclk should still be 1");
        $finish;
    end

    // 16 bit transmitted MSB first
     for (i = 0; i < 16; i = i + 1) begin
        @(posedge sys_clk);
        #1;

        if (mosi != tx_data[15-i]) begin
            $display("FAILED: MOSI incorrect at bit %0d", i);
            $finish;
        end

        if (cs_n != 1'b0) begin
            $display("FAILED: cs_n should remain 0 during transfer");
            $finish;
        end
    end

    // cs_n should remain low after final rising edge
    @(posedge sys_clk);
    #1;

    if (cs_n != 1'b0) begin
        $display("FAILED: cs_n should remain low after final rising edge");
        $finish;
    end

    // Test 3 - 0x1940
    clk_div = 8'd2;
    spi_en = 1;
    tx_data = 16'hA5C3;
    start = 1;

    


    $display("TEST PASSED");
    $finish;
    end
    
    initial begin
    #1_0000_0000;
    $display ("TEST FAILED: TIMOUT");
    $finish;
    end
endmodule