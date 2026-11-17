//////////////////////////////////////////////////////////////////////////////////
// Title      : CSUN ECE 520 Design Project 1
// Project    : Design Project 1
//////////////////////////////////////////////////////////////////////////////////
// File       : spi_cs_ctrl.v<spi_cs_ctrl.srcs>
// Author     : Anna Bagdishyan 203475460
// Company    : CSUN
// Created    : 2026-11-13
// Last update: 2026-11-15
// Platform   :
// Standard   : Verilog
//////////////////////////////////////////////////////////////////////////////////
// Description: Top file for spi_cs_ctrl.v
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module spi_cs_ctrl (
    input wire sys_clk,
    input wire sys_rst_n,
    input wire assert_cs,
    input wire deassert_cs,
    output reg cs_n
);

    always @(posedge sys_clk) begin
        if (!sys_rst_n) begin
            cs_n <= 1;
        end
        else if (deassert_cs) begin // deassert takes priority
            cs_n <= 1;
        end
        else if (assert_cs) begin
            cs_n <= 0;
        end
    end
endmodule