//////////////////////////////////////////////////////////////////////////////////
// Title      : CSUN ECE 520 Design Project 1
// Project    : Design Project 1
//////////////////////////////////////////////////////////////////////////////////
// File       : tb_spi_cs_ctrl.v<tb_spi_cs_ctrl.sim>
// Author     : Anna Bagdishyan 203475460
// Company    : CSUN
// Created    : 2026-11-13
// Last update: 2026-11-15
// Platform   :
// Standard   : Verilog
//////////////////////////////////////////////////////////////////////////////////
// Description: Testbench for spi_cs_ctrl.v
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module tb_spi_cs_ctrl;

    reg sys_clk;
    reg sys_rst_n;
    reg assert_cs;
    reg deassert_cs;
    wire cs_n;

    // DUT
    spi_cs_ctrl DUT (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .assert_cs(assert_cs),
        .deassert_cs(deassert_cs),
        .cs_n(cs_n)
    );
    
    // 20 ns period = 50 MHz clk
    always #10 sys_clk = ~sys_clk;

    initial begin
    sys_clk = 0;
    sys_rst_n = 0;
    assert_cs = 0;
    deassert_cs = 0;

    
    // holding reset for 5 clk cycles
    #100;
    sys_rst_n = 1;
    
    // Test 1 - check cs_n after reset
    #1;
    
    if (cs_n != 1'b1) begin
        $display("FAILED: cs_n should be 1 after reset");
        $finish;
    end
    
    // Test 2 - assert_cs
    assert_cs = 1;
    @(posedge sys_clk);
    #1;
    assert_cs = 0;
    if (cs_n != 1'b0) begin
        $display("FAILED: cs_n should be 0 after a clock cycle");
        $finish;
    end

    @(posedge sys_clk);
    #1;
    @(posedge sys_clk);
    #1;
    @(posedge sys_clk);
    #1;

    if (cs_n != 1'b0) begin
        $display("FAILED: cs_n should be 0 after several clock cycle");
        $finish;
    end


       // Test 3 - deassert_cs
    deassert_cs = 1;
    @(posedge sys_clk);
    #1;
    deassert_cs = 0;

    if (cs_n != 1'b1) begin
        $display("FAILED: cs_n should be 1 after a clock cycle");
        $finish;
    end

    @(posedge sys_clk);
    #1;
    @(posedge sys_clk);
    #1;
    @(posedge sys_clk);
    #1;

    if (cs_n != 1'b1) begin
        $display("FAILED: cs_n should be 1 after several clock cycle");
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