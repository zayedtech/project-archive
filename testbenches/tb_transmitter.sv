`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_transmitter ();

    localparam CLK_PERIOD = 10ns;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

    logic clk, n_rst;

    logic [7:0]  TX_Packet_Data;
    logic [6:0]  buffer_occupancy;
    logic [2:0]  tx_packet;
    logic        get_tx_packet_data;
    logic        tx_transfer_active;
    logic        tx_error;
    logic        dp_out;
    logic        dm_out;

    string testname;

    always begin
        clk = 0;
        #(CLK_PERIOD / 2.0);
        clk = 1;
        #(CLK_PERIOD / 2.0);
    end

    task reset_dut;
    begin
        n_rst = 0;
        @(posedge clk);
        @(posedge clk);
        @(negedge clk);
        n_rst = 1;
        @(posedge clk);
        @(posedge clk);
    end
    endtask

    task init_signals;
    begin
        tx_packet        = 3'd0;
        buffer_occupancy = 7'd0;
        TX_Packet_Data   = 8'd0;
    end
    endtask

    task wait_bit_period;
    begin
        repeat(15) @(posedge clk);
    end
    endtask

    task wait_n_bits;
        input integer n;
        integer i;
    begin
        for (i = 0; i < n; i++)
            wait_bit_period();
    end
    endtask

    task wait_byte;
    begin
        wait_n_bits(8);
    end
    endtask

    task wait_handshake_packet;
    begin
        wait_n_bits(30);
    end
    endtask

    transmitter DUT (.*);

    initial begin
        n_rst = 1;
        init_signals();
        reset_dut();

        // ─────────────────────────────────────────
        // TEST 1: idle state
        // ─────────────────────────────────────────
        testname = "test_idle";
        @(negedge clk);
        tx_packet = 3'd0;
        repeat(50) @(posedge clk);

        // ─────────────────────────────────────────
        // TEST 2: send ACK packet
        // ─────────────────────────────────────────
        testname = "test_ack";
        reset_dut();
        init_signals();
        @(negedge clk);
        tx_packet = 3'd3;
        repeat(20) @(posedge clk);
        wait_handshake_packet();
        repeat(20) @(posedge clk);

        // ─────────────────────────────────────────
        // TEST 3: send NAK packet
        // ─────────────────────────────────────────
        testname = "test_nak";
        reset_dut();
        init_signals();
        @(negedge clk);
        tx_packet = 3'd4;
        repeat(20) @(posedge clk);
        wait_handshake_packet();
        repeat(20) @(posedge clk);

        // ─────────────────────────────────────────
        // TEST 4: send STALL packet
        // ─────────────────────────────────────────
        testname = "test_stall";
        reset_dut();
        init_signals();
        @(negedge clk);
        tx_packet = 3'd5;
        repeat(20) @(posedge clk);
        wait_handshake_packet();
        repeat(20) @(posedge clk);

        // ─────────────────────────────────────────
        // TEST 5: send DATA0 with 1 byte
        // ─────────────────────────────────────────
        testname = "test_data0_1byte";
        reset_dut();
        init_signals();
        @(negedge clk);
        tx_packet        = 3'd1;
        buffer_occupancy = 7'd1;
        TX_Packet_Data   = 8'hAA;
        repeat(20) @(posedge clk);
        // wait through SYNC + PID
        wait_n_bits(18);
        // drop occupancy for last byte
        buffer_occupancy = 7'd0;
        // wait through DATA + CRC + EOP + DONE
        wait_n_bits(35);
        repeat(20) @(posedge clk);

        // ─────────────────────────────────────────
        // TEST 6: send DATA1 with 3 bytes
        // ─────────────────────────────────────────
        testname = "test_data1_3bytes";
        reset_dut();
        init_signals();
        @(negedge clk);
        tx_packet        = 3'd2;
        buffer_occupancy = 7'd3;
        TX_Packet_Data   = 8'hAA;
        repeat(20) @(posedge clk);
        // wait through SYNC + PID
        wait_n_bits(18);
        // byte 1
        buffer_occupancy = 7'd2;
        TX_Packet_Data   = 8'hBB;
        wait_byte();
        // byte 2
        buffer_occupancy = 7'd1;
        TX_Packet_Data   = 8'hCC;
        wait_byte();
        // byte 3 last
        buffer_occupancy = 7'd0;
        wait_byte();
        // CRC + EOP + DONE
        wait_n_bits(30);
        repeat(20) @(posedge clk);

        // ─────────────────────────────────────────
        // TEST 7: EOP drives both lines low
        // ─────────────────────────────────────────
        testname = "test_eop";
        reset_dut();
        init_signals();
        @(negedge clk);
        tx_packet = 3'd3;
        // wait through SYNC + PID
        wait_n_bits(18);
        // now in EOP — observe dp_out and dm_out in waveform
        repeat(20) @(posedge clk);

        // ─────────────────────────────────────────
        // TEST 8: get_tx_packet_data in DATA
        // ─────────────────────────────────────────
        testname = "test_get_tx_packet_data";
        reset_dut();
        init_signals();
        @(negedge clk);
        tx_packet        = 3'd1;
        buffer_occupancy = 7'd2;
        TX_Packet_Data   = 8'hAA;
        // wait through SYNC + PID into DATA
        wait_n_bits(18);
        // observe get_tx_packet_data pulsing in waveform
        wait_n_bits(10);

        // ─────────────────────────────────────────
        // TEST 9: n_rst mid transmission
        // ─────────────────────────────────────────
        testname = "test_mid_reset";
        reset_dut();
        init_signals();
        @(negedge clk);
        tx_packet        = 3'd1;
        buffer_occupancy = 7'd4;
        TX_Packet_Data   = 8'hAA;
        // wait into SYNC
        wait_n_bits(5);
        // reset mid transmission
        reset_dut();
        repeat(20) @(posedge clk);

        // ─────────────────────────────────────────
        // TEST 10: line returns to idle after packet
        // ─────────────────────────────────────────
        testname = "test_idle_after_packet";
        reset_dut();
        init_signals();
        @(negedge clk);
        tx_packet = 3'd3;
        wait_handshake_packet();
        repeat(50) @(posedge clk);

        $display("ALL TESTS DONE");
        // $finish;
    end

endmodule
/* verilator coverage_on */
