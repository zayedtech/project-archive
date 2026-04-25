`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_data_buffer ();

    localparam CLK_PERIOD = 10ns;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

    logic clk, n_rst;

    // DUT signals
    logic        store_tx_data;
    logic [7:0]  tx_data;
    logic        get_rx_data;
    logic        store_rx_packet_data;
    logic [7:0]  rx_packet_data;
    logic        get_tx_packet_data;
    logic        flush;
    logic        clear;
    logic [7:0]  rx_data;
    logic [7:0]  tx_packet_data;
    logic [6:0]  buffer_occupancy;

    // test name tracker
    string testname;

    // clockgen
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
        store_tx_data        = 0;
        tx_data              = '0;
        get_rx_data          = 0;
        store_rx_packet_data = 0;
        rx_packet_data       = '0;
        get_tx_packet_data   = 0;
        flush                = 0;
        clear                = 0;
    end
    endtask

    data_buffer DUT (.*);

    initial begin
        n_rst = 1;
        init_signals();
        reset_dut();

        // ─────────────────────────────────────────
        // TEST 1
        // ─────────────────────────────────────────
        testname = "test_ahb_push";
        @(negedge clk);
        store_tx_data = 1;
        tx_data       = 8'hAB;
        @(posedge clk);
        @(negedge clk);
        store_tx_data = 0;
        assert (buffer_occupancy == 7'd1)
            else $error("FAILED %s: expected occupancy=1, got %0d", testname, buffer_occupancy);

        // ─────────────────────────────────────────
        // TEST 2
        // ─────────────────────────────────────────
        testname = "test_tx_pop";
        @(negedge clk);
        get_tx_packet_data = 1;
        @(posedge clk);
        @(negedge clk);
        get_tx_packet_data = 0;
        assert (tx_packet_data == 8'hAB)
            else $error("FAILED %s: expected tx_packet_data=0xAB, got 0x%0h", testname, tx_packet_data);
        assert (buffer_occupancy == 7'd0)
            else $error("FAILED %s: expected occupancy=0, got %0d", testname, buffer_occupancy);

        // ─────────────────────────────────────────
        // TEST 3
        // ─────────────────────────────────────────
        testname = "test_rx_push";
        reset_dut();
        @(negedge clk);
        store_rx_packet_data = 1;
        rx_packet_data       = 8'hCD;
        @(posedge clk);
        @(negedge clk);
        store_rx_packet_data = 0;
        assert (buffer_occupancy == 7'd1)
            else $error("FAILED %s: expected occupancy=1, got %0d", testname, buffer_occupancy);

        // ─────────────────────────────────────────
        // TEST 4
        // ─────────────────────────────────────────
        testname = "test_ahb_pop";
        @(negedge clk);
        get_rx_data = 1;
        @(posedge clk);
        @(negedge clk);
        get_rx_data = 0;
        assert (rx_data == 8'hCD)
            else $error("FAILED %s: expected rx_data=0xCD, got 0x%0h", testname, rx_data);
        assert (buffer_occupancy == 7'd0)
            else $error("FAILED %s: expected occupancy=0, got %0d", testname, buffer_occupancy);

        // ─────────────────────────────────────────
        // TEST 5
        // ─────────────────────────────────────────
        testname = "test_push_full";
        reset_dut();
        @(negedge clk);
        for (int i = 0; i < 64; i++) begin
            store_tx_data = 1;
            tx_data       = i[7:0];
            @(posedge clk);
            @(negedge clk);
        end
        store_tx_data = 0;
        assert (buffer_occupancy == 7'd64)
            else $error("FAILED %s: expected occupancy=64, got %0d", testname, buffer_occupancy);
        store_tx_data = 1;
        tx_data       = 8'hFF;
        @(posedge clk);
        @(negedge clk);
        store_tx_data = 0;
        assert (buffer_occupancy == 7'd64)
            else $error("FAILED %s: push when full not blocked, occupancy=%0d", testname, buffer_occupancy);

        // ─────────────────────────────────────────
        // TEST 6
        // ─────────────────────────────────────────
        testname = "test_pop_empty";
        reset_dut();
        @(negedge clk);
        get_tx_packet_data = 1;
        @(posedge clk);
        @(negedge clk);
        get_tx_packet_data = 0;
        assert (buffer_occupancy == 7'd0)
            else $error("FAILED %s: pop when empty not blocked, occupancy=%0d", testname, buffer_occupancy);

        // ─────────────────────────────────────────
        // TEST 7
        // ─────────────────────────────────────────
        testname = "test_clear";
        reset_dut();
        @(negedge clk);
        store_tx_data = 1;
        tx_data       = 8'hAA;
        repeat(10) @(posedge clk);
        @(negedge clk);
        store_tx_data = 0;
        clear         = 1;
        @(posedge clk);
        @(negedge clk);
        clear = 0;
        assert (buffer_occupancy == 7'd0)
            else $error("FAILED %s: clear did not flush, occupancy=%0d", testname, buffer_occupancy);

        // ─────────────────────────────────────────
        // TEST 8
        // ─────────────────────────────────────────
        testname = "test_flush";
        reset_dut();
        @(negedge clk);
        store_rx_packet_data = 1;
        rx_packet_data       = 8'hBB;
        repeat(5) @(posedge clk);
        @(negedge clk);
        store_rx_packet_data = 0;
        flush                = 1;
        @(posedge clk);
        @(negedge clk);
        flush = 0;
        assert (buffer_occupancy == 7'd0)
            else $error("FAILED %s: flush did not clear, occupancy=%0d", testname, buffer_occupancy);

        // ─────────────────────────────────────────
        // TEST 9
        // ─────────────────────────────────────────
        testname = "test_simultaneous";
        reset_dut();
        @(negedge clk);
        store_tx_data = 1;
        tx_data       = 8'hDE;
        @(posedge clk);
        @(negedge clk);
        store_tx_data      = 1;
        tx_data            = 8'hAD;
        get_tx_packet_data = 1;
        @(posedge clk);
        @(negedge clk);
        store_tx_data      = 0;
        get_tx_packet_data = 0;
        assert (buffer_occupancy == 7'd1)
            else $error("FAILED %s: expected occupancy=1, got %0d", testname, buffer_occupancy);

        // ─────────────────────────────────────────
        // TEST 10
        // ─────────────────────────────────────────
        testname = "test_occupancy";
        reset_dut();
        @(negedge clk);
        for (int i = 0; i < 5; i++) begin
            store_tx_data = 1;
            tx_data       = i[7:0];
            @(posedge clk);
            @(negedge clk);
        end
        store_tx_data = 0;
        assert (buffer_occupancy == 7'd5)
            else $error("FAILED %s: expected occupancy=5, got %0d", testname, buffer_occupancy);
        for (int i = 0; i < 3; i++) begin
            get_tx_packet_data = 1;
            @(posedge clk);
            @(negedge clk);
        end
        get_tx_packet_data = 0;
        assert (buffer_occupancy == 7'd2)
            else $error("FAILED %s: expected occupancy=2, got %0d", testname, buffer_occupancy);

        // ─────────────────────────────────────────
        // TEST 11
        // ─────────────────────────────────────────
        testname = "test_wraparound";
        reset_dut();
        @(negedge clk);
        for (int i = 0; i < 64; i++) begin
            store_tx_data = 1;
            tx_data       = i[7:0];
            @(posedge clk);
            @(negedge clk);
        end
        store_tx_data = 0;
        for (int i = 0; i < 64; i++) begin
            @(negedge clk);
            get_tx_packet_data = 1;
            @(posedge clk);
           
        end
        @(negedge clk);
        get_tx_packet_data = 0;
        @(posedge clk);
        @(negedge clk);
        store_tx_data = 1;
        tx_data       = 8'hC0;
        @(posedge clk);
        @(negedge clk);
        tx_data = 8'hDE;
        @(posedge clk);
        @(negedge clk);
        store_tx_data = 0;
        assert (buffer_occupancy == 7'd2)
            else $error("FAILED %s: expected occupancy=2 after wraparound, got %0d", testname, buffer_occupancy);

        // ─────────────────────────────────────────
        // TEST 12
        // ─────────────────────────────────────────
        testname = "test_reset";
        @(negedge clk);
        store_tx_data = 1;
        tx_data       = 8'hFF;
        repeat(5) @(posedge clk);
        @(negedge clk);
        store_tx_data = 0;

        get_tx_packet_data = 1;
        repeat (3) @(posedge clk);


        reset_dut();
        assert (buffer_occupancy == 7'd0)
            else $error("FAILED %s: n_rst did not reset occupancy, got %0d", testname, buffer_occupancy);

        $display("ALL TESTS DONE");
        $finish;
    end

endmodule
/* verilator coverage_on */
