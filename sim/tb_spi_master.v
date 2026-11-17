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

    // Test 2.1 - Transmit 0xA5C3, receive 0x1940
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

    // Test 2.2 - asserting start when busy is high
    start = 1;
    @(posedge sys_clk);
    #1;
    start = 0;

    if (busy != 1'b1) begin
        $display("FAILED: Transfer should continue when start is asserted");
        $finish;
    end

    // transmitting 0xA5C3 and receving 0x1940
    for (i = 0; i < 16; i = i + 1) begin
        @(negedge sclk);
        #1;
        miso = (16'h1940 >> (15-i)) & 1'b1; // shifts desired bit to position, extracts it, and assigns to miso

        @(posedge sclk);
        #1;

        // verify transmitted bit
        if (mosi != tx_data[15-i]) begin
            $display("FAILED: MOSI incorrect at bit %0d", i);
            $finish;
        end

        // chip select should remain low
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

    if (rx_data != 16'h1940) begin
        $display("FAILED: rx_data should be 0x1940");
        $finish;
    end
    
    if (done != 1'b1) begin
    $display("FAILED: done should be 1");
    $finish;
    end

    // Test 3 - perform back to back transfers
    @(posedge sys_clk);
    #1;

    // idle period of 5 clock cycles
    for (i = 0; i < 5; i = i + 1) begin
        @(posedge sys_clk);
        #1;

        if (sclk != 1'b1 || cs_n != 1'b1) begin
            $display("FAILED: sclk and cs_n should be 1 during IDLE period b/w two transfers");
            $finish;
        end
    end

    // second transfer
    tx_data = 16'hA5C3;
    start = 1;
    miso = 0;

    @(posedge sys_clk);
    #1;
    start = 0;

    if (busy != 1'b1) begin
        $display("FAILED: Second transfer should begin");
        $finish;
    end

    @(posedge sys_clk);
    #1;
    
    // verify second transfer
    for (i = 0; i < 16; i = i + 1) begin
        @(posedge sclk);
        #1;

        if (mosi != tx_data[15-i]) begin
            $display("FAILED: MOSI incorrect during second transfer");
            $finish;
        end
    end

    @(posedge sys_clk);
    #1;
    
    if (done != 1'b1) begin
        $display("FAILED: Second transfer should complete");
        $finish;
    end

    @(posedge sys_clk);
    #1;
    
    // Test 4 - spi_en = 0 and 
    spi_en = 0;
    start = 1;

    @(posedge sys_clk);
    #1;

    if (busy != 1'b0) begin
        $display("FAILED: No transfer should begin");
        $finish;
    end

    if (cs_n != 1'b1) begin
        $display("FAILED: No transfer should begin");
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