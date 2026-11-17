//////////////////////////////////////////////////////////////////////////////////
// Title      : CSUN ECE 520 Design Project 1
// Project    : Design Project 1
//////////////////////////////////////////////////////////////////////////////////
// File       : spi_fsm.v<spi_fsm.srcs>
// Author     : Anna Bagdishyan 203475460
// Company    : CSUN
// Created    : 2026-11-13
// Last update: 2026-11-15
// Platform   :
// Standard   : Verilog
//////////////////////////////////////////////////////////////////////////////////
// Description: Top file for spi_fsm.v
//////////////////////////////////////////////////////////////////////////////////

module spi_fsm (
    input wire sys_clk,
    input wire sys_rst_n,
    input wire spi_en,
    input wire start,
    input wire fall_en,
    input wire rise_en,

    output reg sclk,
    output reg clk_div_en,
    output reg load,
    output reg latch_rx,
    output reg assert_cs,
    output reg deassert_cs,
    output reg busy,
    output reg done
);
    reg [1:0] state;
    reg [4:0] counter;

    parameter IDLE = 0, TRANSFER = 1, DONE = 2;

    always @(posedge sys_clk) begin
        if (!sys_rst_n) begin
            state <= IDLE;
            counter <= 0;

            sclk <= 1;
            clk_div_en <= 0;
            load <= 0;
            latch_rx <= 0;
            assert_cs <= 0;
            deassert_cs <= 0;
            busy <= 0;
            done <= 0;
        end
        else begin
            load <= 0;
            latch_rx <= 0;
            assert_cs <= 0;
            deassert_cs <= 0;
            done <= 0;

            case (state)
            IDLE: begin
                sclk <= 1;
                busy <= 0;
                clk_div_en <= 0;

                if (start && spi_en) begin
                    state <= TRANSFER;

                    counter <= 0;
                    load <= 1;
                    assert_cs <= 1;
                    busy <= 1;
                    clk_div_en <= 1;
                end
            end

            TRANSFER: begin
                busy <= 1;
                clk_div_en <= 1;

                if (fall_en) begin
                    sclk <= 0;
                end
                if (rise_en) begin
                    sclk <= 1;
                    counter <= counter + 1;

                    if (counter == 15) begin
                        latch_rx <= 1;
                        state <= DONE;
                    end
                end
            end

            DONE: begin
                sclk <= 1;
                busy <= 1;
                clk_div_en <= 0;
                done <= 1;
                deassert_cs <= 1;
                state <= IDLE;
            end

            default: begin
                state <= IDLE;
            end

        endcase
            
        end
    end
endmodule