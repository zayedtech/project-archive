`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_controller ();

    localparam CLK_PERIOD = 10ns;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

    logic clk, n_rst;

    // DUT signals
    logic        bit_tick;
    logic [2:0]  tx_packet;
    logic [6:0]  buffer_occupancy;
    logic [7:0]  TX_Packet_Data;
    logic [7:0]  load_byte;
    logic        load_new_byte;
    logic        get_tx_packet_data;
    logic        tx_transfer_active;
    logic        tx_error;
    logic        eop_active;

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
        bit_tick         = 0;
        tx_packet        = 3'd0;
        buffer_occupancy = 7'd0;
        TX_Packet_Data   = 8'd0;
    end
    endtask

    // task to simulate one bit_tick pulse
    task send_bit_tick;
    begin
    // idle cycles before tick
    repeat(7) @(posedge clk);
    @(negedge clk);
    bit_tick = 1;
    @(posedge clk);
    @(negedge clk);
    bit_tick = 0;
    end
    endtask

    // task to simulate n bit_ticks
    task send_n_ticks;
        input integer n;
        integer i;
    begin
        for (i = 0; i < n; i++) begin
            send_bit_tick();
        end
    end
    endtask

    // task to send a full byte (8 bit_ticks)
    task send_byte;
    begin
        send_n_ticks(8);
    end
    endtask

    controller DUT (.*);

    initial begin
        n_rst = 1;
        init_signals();
        reset_dut();

        
        testname = "test_ack";
        @(negedge clk);
        tx_packet = 3'd3; // ACK
        send_bit_tick();
        // should be in SYNC now
        assert (tx_transfer_active == 1'b1)
            else $error("FAILED %s: expected tx_transfer_active=1 in SYNC", testname);
        assert (load_byte == 8'b00000001)
            else $error("FAILED %s: expected sync byte, got 0x%0h", testname, load_byte);
        // send 8 bit_ticks for SYNC
        send_byte();
        // should be in PID now
        assert (load_byte == 8'b01001011) // ACK PID
            else $error("FAILED %s: expected ACK PID, got 0x%0h", testname, load_byte);
        // send 8 bit_ticks for PID
        send_byte();
        // should be in EOP now
        assert (eop_active == 1'b1)
            else $error("FAILED %s: expected eop_active=1", testname);
        // send 3 bit_ticks for EOP
        send_n_ticks(3);
        // should be in DONE then IDLE
        send_bit_tick();
        assert (tx_transfer_active == 1'b0)
            else $error("FAILED %s: expected tx_transfer_active=0 in IDLE", testname);

        
      
        testname = "test_nak";
        reset_dut();
        init_signals();
        @(negedge clk);
        tx_packet = 3'd4; // NAK
        send_bit_tick();
        send_byte(); // SYNC
        assert (load_byte == 8'b01011010) // NAK PID
            else $error("FAILED %s: expected NAK PID, got 0x%0h", testname, load_byte);
        send_byte(); // PID
        assert (eop_active == 1'b1)
            else $error("FAILED %s: expected eop_active=1", testname);
        send_n_ticks(3);
        send_bit_tick();
        assert (tx_transfer_active == 1'b0)
            else $error("FAILED %s: expected tx_transfer_active=0 in IDLE", testname);


        testname = "test_stall";
        reset_dut();
        init_signals();
        @(negedge clk);
        tx_packet = 3'd5; // STALL
        send_bit_tick();
        send_byte(); // SYNC
        assert (load_byte == 8'b00011110) // STALL PID
            else $error("FAILED %s: expected STALL PID, got 0x%0h", testname, load_byte);
        send_byte(); // PID
        assert (eop_active == 1'b1)
            else $error("FAILED %s: expected eop_active=1", testname);
        send_n_ticks(3);
        send_bit_tick();
        assert (tx_transfer_active == 1'b0)
            else $error("FAILED %s: expected tx_transfer_active=0 in IDLE", testname);

   
        testname = "test_data0";
        reset_dut();
        init_signals();
        @(negedge clk);
        tx_packet        = 3'd1; // DATA0
        buffer_occupancy = 7'd3;
        TX_Packet_Data   = 8'hAA;
        send_bit_tick();
        send_byte(); // SYNC
        assert (load_byte == 8'b11000011) // DATA0 PID
            else $error("FAILED %s: expected DATA0 PID, got 0x%0h", testname, load_byte);
        send_byte(); // PID
        // should be in DATA now
        assert (tx_transfer_active == 1'b1)
            else $error("FAILED %s: expected tx_transfer_active=1 in DATA", testname);
        // send 3 bytes of data
        buffer_occupancy = 7'd2;
        send_byte();
        buffer_occupancy = 7'd1;
        TX_Packet_Data   = 8'hBB;
        send_byte();
        buffer_occupancy = 7'd0;
        TX_Packet_Data   = 8'hCC;
        send_byte();
        // should be in CRC now
        assert (get_tx_packet_data == 1'b0)
            else $error("FAILED %s: expected get_tx_packet_data=0 in CRC", testname);
        send_n_ticks(16); // CRC — 2 bytes = 16 bit_ticks
        // should be in EOP
        assert (eop_active == 1'b1)
            else $error("FAILED %s: expected eop_active=1", testname);
        send_n_ticks(3);
        send_bit_tick();
        assert (tx_transfer_active == 1'b0)
            else $error("FAILED %s: expected tx_transfer_active=0", testname);

     
        testname = "test_data1";
        reset_dut();
        init_signals();
        @(negedge clk);
        tx_packet        = 3'd2; // DATA1
        buffer_occupancy = 7'd1;
        TX_Packet_Data   = 8'hFF;
        send_bit_tick();
        send_byte(); // SYNC
        assert (load_byte == 8'b11010100) // DATA1 PID
            else $error("FAILED %s: expected DATA1 PID, got 0x%0h", testname, load_byte);
        send_byte(); // PID
        buffer_occupancy = 7'd0;
        send_byte(); // DATA
        send_n_ticks(16); // CRC
        assert (eop_active == 1'b1)
            else $error("FAILED %s: expected eop_active=1", testname);
        send_n_ticks(3);
        send_bit_tick();
        assert (tx_transfer_active == 1'b0)
            else $error("FAILED %s: expected tx_transfer_active=0", testname);

       
        testname = "test_bit_tick_gate";
        reset_dut();
        init_signals();
        @(negedge clk);
        tx_packet = 3'd3; // ACK
        // hold bit_tick low for 10 cycles
        repeat(10) @(posedge clk);
        assert (tx_transfer_active == 1'b0)
            else $error("FAILED %s: FSM advanced without bit_tick", testname);
        // now send bit_tick
        send_bit_tick();
        assert (tx_transfer_active == 1'b1)
            else $error("FAILED %s: FSM did not advance on bit_tick", testname);

 

        testname = "test_mid_reset";
        reset_dut();
        init_signals();
        @(negedge clk);
        tx_packet = 3'd1; // DATA0
        buffer_occupancy = 7'd4;
        send_bit_tick();
        send_byte(); // SYNC
        send_byte(); // PID 
       
        reset_dut();
        assert (tx_transfer_active == 1'b0)
            else $error("FAILED %s: expected tx_transfer_active=0 after reset", testname);
        assert (eop_active == 1'b0)
            else $error("FAILED %s: expected eop_active=0 after reset", testname);

        $display("ALL TESTS DONE");
        $finish;
    end

endmodule
/* verilator coverage_on */
