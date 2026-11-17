//////////////////////////////////////////////////////////////////////////////////
// Title      : CSUN ECE 520 Design Project 1
// Project    : Design Project 1
//////////////////////////////////////////////////////////////////////////////////
// File       : spi_shift_reg.v<spi_shift_reg.srcs>
// Author     : Anna Bagdishyan 203475460
// Company    : CSUN
// Created    : 2026-11-13
// Last update: 2026-11-15
// Platform   :
// Standard   : Verilog
//////////////////////////////////////////////////////////////////////////////////
// Description: Top file for spi_shift_reg.v
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module spi_shift_reg (
    input wire sys_clk,
    input wire sys_rst_n,
    input wire fall_en,
    input wire rise_en,
    input wire load,
    input wire [15:0] tx_data,
    input wire miso,
    input wire latch_rx,
    output reg mosi,
    output reg [15:0] rx_data
);
    reg [15:0] tx_shift;
    reg [15:0] rx_shift;

    always @(posedge sys_clk) begin
        if (!sys_rst_n) begin
            tx_shift <= 0;
            rx_shift <= 0;
            mosi <= 0;
            rx_data <= 0;
        end
        else begin
            if (load) begin // load takes priority over fall_en
                tx_shift <= tx_data;
            end
            else if (fall_en) begin
                mosi <= tx_shift[15];
                tx_shift <= tx_shift << 1;
            end

            if (rise_en) begin
                rx_shift <= {rx_shift[14:0], miso}; // concat miso to LSB        
            end
            if (latch_rx) begin
                rx_data <= rx_shift;
            end 
        end
    end
endmodule