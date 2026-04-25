`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_ahb_usb ();

    localparam CLK_PERIOD = 10ns;
    localparam TIMEOUT    = 1000;

    localparam BURST_SINGLE = 3'd0;

    initial begin
        $dumpfile("waveform.fst");
        $dumpvars;
    end

    logic clk, n_rst;

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
        @(negedge clk);
        @(negedge clk);
    end
    endtask

    logic        hsel;
    logic [3:0]  haddr;
    logic [2:0]  hsize;
    logic [2:0]  hburst;
    logic [1:0]  htrans;
    logic        hwrite;
    logic [31:0] hwdata;
    logic [31:0] hrdata;
    logic        hresp;
    logic        hready;
    logic        dp_in;
    logic        dm_in;
    logic        dp_out;
    logic        dm_out;
    logic        d_mode;

    string testname;

    // assign dp_in = 1'b1;
    // assign dm_in = 1'b0;

    ahb_model_updated #(
        .ADDR_WIDTH(4),
        .DATA_WIDTH(4)
    ) BFM (
        .clk    (clk),
        .hsel   (hsel),
        .haddr  (haddr),
        .hsize  (hsize),
        .htrans (htrans),
        .hburst (hburst),
        .hwrite (hwrite),
        .hwdata (hwdata),
        .hrdata (hrdata),
        .hresp  (hresp),
        .hready (hready)
    );

    ahb_usb DUT (
        .clk    (clk),
        .n_rst  (n_rst),
        .hsel   (hsel),
        .haddr  (haddr),
        .hsize  (hsize),
        .hburst (hburst),
        .htrans (htrans),
        .hwrite (hwrite),
        .hwdata (hwdata),
        .hrdata (hrdata),
        .hresp  (hresp),
        .hready (hready),
        .dp_in  (dp_in),
        .dm_in  (dm_in),
        .dp_out (dp_out),
        .dm_out (dm_out),
        .d_mode (d_mode)
    );

    task reset_model;
        BFM.reset_model();
    endtask

    task enqueue_poll (
        input logic [3:0] addr,
        input logic [1:0] size
    );
        logic [31:0] data [];
    begin
        data    = new [1];
        data[0] = 32'hXXXXXXXX;
        BFM.enqueue_transaction(1'b1, 1'b0, addr, data, 1'b0, {1'b0, size}, 3'b0, 1'b0);
    end
    endtask
    




    //From Harry and Almothana







    task enqueue_read(input logic [3:0] addr, input logic [1:0] size, input logic [31:0] exp_read);
        logic [31:0] data[];
    begin
        data = new[1];
        data[0] = exp_read;
        BFM.enqueue_transaction(1'b1, 1'b0, addr, data, 1'b0, {1'b0,size}, BURST_SINGLE, 1'b1);
    end
    endtask











        task sync_byte;
    begin
        /*10000000*/
        dp_in = 0;
        dm_in = 1;
        #(83.33333ns);
        dp_in = 1;
        dm_in = 0;
        #(83.33333ns);
        dp_in = 0;
        dm_in = 1;
        #(83.33333ns);
        dp_in = 1;
        dm_in = 0;
        #(83.33333ns);
        dp_in = 0;
        dm_in = 1;
        #(83.33333ns);
        dp_in = 1;
        dm_in = 0;
        #(83.33333ns);
        dp_in = 0;
        dm_in = 1;
        #(83.33333ns);
        #(83.33333ns);
    end
    endtask

    task ack_pid;
    begin
        /*11010010*/
        dp_in = 1;
        dm_in = 0;
        #(83.33333ns);
        #(83.33333ns);
        dp_in = 0;
        dm_in = 1;
        #(83.33333ns);
        dp_in = 1;
        dm_in = 0;
        #(83.33333ns);
        #(83.33333ns);
        dp_in = 0;
        dm_in = 1;
        #(83.33333ns);
        #(83.33333ns);
        #(83.33333ns);
    end
    endtask

    task in_pid;
    begin
        /*01101001*/
        #(83.33333ns);
        dp_in = 1;
        dm_in = 0;
        #(83.33333ns);
        dp_in = 0;
        dm_in = 1;
        #(83.33333ns);
        #(83.33333ns);
        dp_in = 1;
        dm_in = 0;
        #(83.33333ns);
        #(83.33333ns);
        #(83.33333ns);
        dp_in = 0;
        dm_in = 1;
        #(83.33333ns);
    end
    endtask

    task out_pid;
    begin
        /*11100001*/
        #(83.33333ns);
        dp_in = 1;
        dm_in = 0;
        #(83.33333ns);
        dp_in = 0;
        dm_in = 1;
        #(83.33333ns);
        dp_in = 1;
        dm_in = 0;
        #(83.33333ns);
        dp_in = 0;
        dm_in = 1;
        #(83.33333ns);
        #(83.33333ns);
        #(83.33333ns);
        #(83.33333ns);
    end
    endtask
    
    task data0_pid;
    begin
        /*11000011*/
        #(83.33333ns);
        #(83.33333ns);
        dp_in = 1;
        dm_in = 0;
        #(83.33333ns);
        dp_in = 0;
        dm_in = 1;
        #(83.33333ns);
        dp_in = 1;
        dm_in = 0;
        #(83.33333ns);
        dp_in = 0;
        dm_in = 1;
        #(83.33333ns);
        #(83.33333ns);
        #(83.33333ns);
    end
    endtask

    task data1_pid;
    begin
        /*01001011*/
        #(83.33333ns);
        #(83.33333ns);
        dp_in = 1;
        dm_in = 0;
        #(83.33333ns);
        #(83.33333ns);
        dp_in = 0;
        dm_in = 1;
        #(83.33333ns);
        dp_in = 1;
        dm_in = 0;
        #(83.33333ns);
        #(83.33333ns);
        dp_in = 0;
        dm_in = 1;
        #(83.33333ns);
    end
    endtask

    task data_crc;
    begin
          /*00000001_00000001*/
        #(83.4ns);
        dp_in = 1;
        dm_in = 0;
        #(83.4ns);
        dp_in = 0;
        dm_in = 1;
        #(83.4ns);
        dp_in = 1;
        dm_in = 0;
        #(83.4ns);
        dp_in = 0;
        dm_in = 1;
        #(83.4ns);
        dp_in = 1;
        dm_in = 0;
        #(83.4ns);
        dp_in = 0;
        dm_in = 1;
        #(83.4ns);
        dp_in = 1;
        dm_in = 0;
        #(83.4ns);

        #(83.4ns);
        dp_in = 0;
        dm_in = 1;
        #(83.4ns);
        dp_in = 1;
        dm_in = 0;
        #(83.4ns);
        dp_in = 0;
        dm_in = 1;
        #(83.4ns);
        dp_in = 1;
        dm_in = 0;
        #(83.4ns);
        dp_in = 0;
        dm_in = 1;
        #(83.4ns);
        dp_in = 1;
        dm_in = 0;
        #(83.4ns);
        dp_in = 0;
        dm_in = 1;
        #(83.4ns);
    end
    endtask

    task token_data_crc;
    begin
        /*01110_0000_0111110*/
        dp_in = 1;
        dm_in = 0;
        #(83.33333ns);
        #(83.33333ns);
        #(83.33333ns);
        #(83.33333ns);
        #(83.33333ns);
        #(83.33333ns);
        dp_in = 0;
        dm_in = 1;
        #(83.33333ns);
        dp_in = 1;
        dm_in = 0;
        #(83.33333ns);
        dp_in = 0;
        dm_in = 1;
        #(83.33333ns);
        dp_in = 1;
        dm_in = 0;
        #(83.33333ns);
        dp_in = 0;
        dm_in = 1;
        #(83.33333ns);
        dp_in = 1;
        dm_in = 0;
        #(83.33333ns);
        #(83.33333ns);
        #(83.33333ns);
        #(83.33333ns);
        dp_in = 0;
        dm_in = 1;
        #(83.33333ns);
        
    end
    endtask

    task random_data;
    begin
        /*10101010_01010101 = aa_55*/
        #(83.33333ns);
        dp_in = 1;
        dm_in = 0;
        #(83.33333ns);
        #(83.33333ns);
        dp_in = 0;
        dm_in = 1;
        #(83.33333ns);
        #(83.33333ns);
        dp_in = 1;
        dm_in = 0;
        #(83.33333ns);
        #(83.33333ns);
        dp_in = 0;
        dm_in = 1;
        #(83.33333ns);

        dp_in = 1;
        dm_in = 0;
        #(83.33333ns);
        #(83.33333ns);
        dp_in = 0;
        dm_in = 1;
        #(83.33333ns);
        #(83.33333ns);
        dp_in = 1;
        dm_in = 0;
        #(83.33333ns);
        #(83.33333ns);
        dp_in = 0;
        dm_in = 1;
        #(83.33333ns);
        #(83.33333ns);
    end
    endtask

    task eop;
    begin
        dp_in = 0;
        dm_in = 0;
        #(83.33333ns);
        #(83.33333ns);
        dp_in = 1;
        #(83.33333ns);
    end
    endtask



    // From Harry and Almothana







    task enqueue_write (
        input logic [3:0]  addr,
        input logic [1:0]  size,
        input logic [31:0] wdata
    );
        logic [31:0] data [];
    begin
        data    = new [1];
        data[0] = wdata;
        BFM.enqueue_transaction(1'b1, 1'b1, addr, data, 1'b0, {1'b0, size}, 3'b0, 1'b0);
    end
    endtask

    task execute_transactions (input int num_transactions);
        BFM.run_transactions(num_transactions);
    endtask

    task finish_transactions;
        BFM.wait_done();
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

    task wait_handshake_packet;
    begin
        wait_n_bits(30);
    end
    endtask

    task do_reset;
    begin
        reset_model();
        reset_dut();
        // flush buffer after every reset
        enqueue_write(4'hD, 2'd0, 32'h00000001);
        execute_transactions(1);
        finish_transactions();
        repeat(10) @(posedge clk);
    end
    endtask

    initial begin
        n_rst = 1;
        reset_model();
        reset_dut();


        testname = "test_write_one_byte_occupancy";
        do_reset();
        enqueue_write(4'h0, 2'd0, 32'h000000AB);
        execute_transactions(1);
        finish_transactions();
        enqueue_poll(4'h8, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=1 in waveform

       
        testname = "test_write_multiple_bytes_occupancy";
        do_reset();
        enqueue_write(4'h0, 2'd0, 32'h000000AA);
        enqueue_write(4'h0, 2'd0, 32'h000000BB);
        enqueue_write(4'h0, 2'd0, 32'h000000CC);
        enqueue_write(4'h0, 2'd0, 32'h000000DD);
        execute_transactions(4);
        finish_transactions();
        enqueue_poll(4'h8, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=4 in waveform

    
        testname = "test_write_read_fifo_order";
        do_reset();
        enqueue_write(4'h0, 2'd0, 32'h000000AA);
        enqueue_write(4'h0, 2'd0, 32'h000000BB);
        enqueue_write(4'h0, 2'd0, 32'h000000CC);
        execute_transactions(3);
        finish_transactions();
        enqueue_poll(4'h0, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=0xAA
        enqueue_poll(4'h0, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=0xBB
        enqueue_poll(4'h0, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=0xCC

        
        testname = "test_occupancy_after_reads";
        do_reset();
        enqueue_write(4'h0, 2'd0, 32'h000000AA);
        enqueue_write(4'h0, 2'd0, 32'h000000BB);
        enqueue_write(4'h0, 2'd0, 32'h000000CC);
        enqueue_write(4'h0, 2'd0, 32'h000000DD);
        enqueue_write(4'h0, 2'd0, 32'h000000EE);
        execute_transactions(5);
        finish_transactions();
        enqueue_poll(4'h8, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=5
        enqueue_poll(4'h0, 2'd0);
        enqueue_poll(4'h0, 2'd0);
        execute_transactions(2);
        finish_transactions();
        enqueue_poll(4'h8, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=3

      
        testname = "test_flush_buffer";
        do_reset();
        enqueue_write(4'h0, 2'd0, 32'h000000AA);
        enqueue_write(4'h0, 2'd0, 32'h000000BB);
        enqueue_write(4'h0, 2'd0, 32'h000000CC);
        execute_transactions(3);
        finish_transactions();
        enqueue_poll(4'h8, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=3
        enqueue_write(4'hD, 2'd0, 32'h00000001);
        execute_transactions(1);
        finish_transactions();
        repeat(10) @(posedge clk);
        enqueue_poll(4'h8, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=0

        
        testname = "test_hsize_byte_write";
        do_reset();
        enqueue_write(4'h0, 2'd0, 32'h000000AB);
        execute_transactions(1);
        finish_transactions();
        enqueue_poll(4'h8, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=1

        
        testname = "test_hsize_halfword_write";
        do_reset();
        enqueue_write(4'h0, 2'd1, 32'h0000AABB);
        execute_transactions(1);
        finish_transactions();
        enqueue_poll(4'h8, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=2

    
        testname = "test_hsize_word_write";
        do_reset();
        enqueue_write(4'h0, 2'd2, 32'hAABBCCDD);
        execute_transactions(1);
        finish_transactions();
        enqueue_poll(4'h8, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=4

        
        testname = "test_send_ack";
        do_reset();
        enqueue_write(4'hC, 2'd0, 32'h00000003);
        execute_transactions(1);
        finish_transactions();
        repeat(20) @(posedge clk);
        // observe tx_transfer_active=1 and d_mode=1 in waveform
        wait_handshake_packet();
        // observe tx_transfer_active=0 and d_mode=0
        enqueue_poll(4'hC, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=0 — control register cleared

        
        testname = "test_send_nak";
        do_reset();
        enqueue_write(4'hC, 2'd0, 32'h00000004);
        execute_transactions(1);
        finish_transactions();
        repeat(20) @(posedge clk);
        wait_handshake_packet();
        enqueue_poll(4'hC, 2'd0);
        execute_transactions(1);
        finish_transactions();

        
        testname = "test_send_stall";
        do_reset();
        enqueue_write(4'hC, 2'd0, 32'h00000005);
        execute_transactions(1);
        finish_transactions();
        repeat(20) @(posedge clk);
        wait_handshake_packet();
        enqueue_poll(4'hC, 2'd0);
        execute_transactions(1);
        finish_transactions();

    
        testname = "test_send_data0";
        do_reset();
        enqueue_write(4'h0, 2'd0, 32'h000000AA);
        enqueue_write(4'h0, 2'd0, 32'h000000BB);
        enqueue_write(4'h0, 2'd0, 32'h000000CC);
        execute_transactions(3);
        finish_transactions();
        enqueue_write(4'hC, 2'd0, 32'h00000001);
        execute_transactions(1);
        finish_transactions();
        repeat(20) @(posedge clk);
        wait_n_bits(50);
        enqueue_poll(4'hC, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=0
        enqueue_poll(4'h8, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=0


        testname = "test_send_data1";
        do_reset();
        enqueue_write(4'h0, 2'd0, 32'h000000DD);
        enqueue_write(4'h0, 2'd0, 32'h000000EE);
        execute_transactions(2);
        finish_transactions();
        enqueue_write(4'hC, 2'd0, 32'h00000002);
        execute_transactions(1);
        finish_transactions();
        repeat(20) @(posedge clk);
        wait_n_bits(45);
        enqueue_poll(4'hC, 2'd0);
        execute_transactions(1);
        finish_transactions();
        enqueue_poll(4'h8, 2'd0);
        execute_transactions(1);
        finish_transactions();

   
        testname = "test_status_register_idle";
        do_reset();
        enqueue_poll(4'h4, 2'd1);
        execute_transactions(1);
        finish_transactions();

        
        testname = "test_status_tx_transfer_active";
        do_reset();
        enqueue_write(4'hC, 2'd0, 32'h00000003);
        execute_transactions(1);
        finish_transactions();
        repeat(20) @(posedge clk);
        enqueue_poll(4'h4, 2'd1);
        execute_transactions(1);
        finish_transactions();
        wait_handshake_packet();
        enqueue_poll(4'h4, 2'd1);
        execute_transactions(1);
        finish_transactions();
        // observe bit 9 low in hrdata

        
        testname = "test_error_register_idle";
        do_reset();
        enqueue_poll(4'h6, 2'd1);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=0

        
        testname = "test_tx_packet_invalid";
        do_reset();
        enqueue_write(4'hC, 2'd0, 32'h00000006);
        execute_transactions(1);
        finish_transactions();
        repeat(50) @(posedge clk);

   
        testname = "test_buffer_full_protection";
        do_reset();
        begin
            int i;
            for (i = 0; i < 64; i++) begin
                enqueue_write(4'h0, 2'd0, 32'h000000AA);
                execute_transactions(1);
                finish_transactions();
            end
        end
        enqueue_poll(4'h8, 2'd0);
        execute_transactions(1);
        finish_transactions();
        enqueue_write(4'h0, 2'd0, 32'h000000FF);
        execute_transactions(1);
        finish_transactions();
        enqueue_poll(4'h8, 2'd0);
        execute_transactions(1);
        finish_transactions();

        testname = "test_d_mode_follows_tx_transfer_active";
        do_reset();
        enqueue_write(4'hC, 2'd0, 32'h00000003);
        execute_transactions(1);
        finish_transactions();
        repeat(20) @(posedge clk);
        wait_handshake_packet();
        repeat(20) @(posedge clk);
        

      
        testname = "test_tx_control_clears_after_send";
        do_reset();
        enqueue_write(4'hC, 2'd0, 32'h00000003);
        execute_transactions(1);
        finish_transactions();
        wait_handshake_packet();
        repeat(20) @(posedge clk);
        enqueue_poll(4'hC, 2'd0);
        execute_transactions(1);
        finish_transactions();
        // observe hrdata=0










        testname = "AHB BUFFER RX";
        repeat(50) @(posedge clk);
        








        n_rst = 1;
        dp_in = 1;
        dm_in = 0;

        testname = "Reset defaults";
        reset_dut();
        enqueue_read(4'h4, 2'd1, 32'h0000_0000);
        execute_transactions(1);
        finish_transactions();
        enqueue_read(4'h6, 2'd1, 32'h0000_0000);
        execute_transactions(1);
        finish_transactions();
        enqueue_read(4'h8, 2'd0, 32'h0000_0000);
        execute_transactions(1);
        finish_transactions();

        testname = "ACK Received";
        reset_dut();
        sync_byte();
        ack_pid();
        eop();
        #(83.33333ns);
        

        enqueue_read(4'h4, 2'd1, 32'h0000_0108);
        execute_transactions(1);
        finish_transactions();

        testname = "OUT Received";
        reset_dut();
        sync_byte();
        out_pid();
        token_data_crc();
        eop();
        #(83.33333);

        enqueue_read(4'h4, 2'd1, 32'h0000_0005);
        execute_transactions(1);
        finish_transactions();

        testname = "IN Received";
        reset_dut();
        sync_byte();
        in_pid();
        token_data_crc();
        eop();
        #(83.33333);

        enqueue_read(4'h4, 2'd1, 32'h0000_0003);
        execute_transactions(1);
        finish_transactions();

        testname = "DATA0 Received";
        reset_dut();
        sync_byte();
        data0_pid();
        random_data();
        data_crc();
        eop();
        #(83.33333);
        #(83.33333);
        enqueue_read(4'h8, 2'd0, 32'h0000_0002);
        execute_transactions(1);
        finish_transactions();
        enqueue_read(4'h4, 2'd1, 32'h0000_0011);
        execute_transactions(1);
        finish_transactions();

        testname = "READ DATA0 1st Byte";
        enqueue_read(4'h0, 2'd0, 32'h0000_0055);
        execute_transactions(1);
        finish_transactions();
        enqueue_read(4'h8, 2'd0, 32'h0000_0001);
        execute_transactions(1);
        finish_transactions();
        enqueue_read(4'h4, 2'd0, 32'h0000_0011);
        execute_transactions(1);
        finish_transactions();

        testname = "READ DATA0 2nd Byte";
        enqueue_read(4'h0, 2'd0, 32'h0000_00aa);
        execute_transactions(1);
        finish_transactions();
        enqueue_read(4'h8, 2'd0, 32'h0000_0000);
        execute_transactions(1);
        finish_transactions();
        enqueue_read(4'h4, 2'd0, 32'h0000_0010);
        execute_transactions(1);
        finish_transactions();

        testname = "DATA0 halfword read";
        reset_dut();
        sync_byte();
        data0_pid();
        random_data();
        data_crc();
        eop();
        #(83.33333);
        #(83.33333);
        enqueue_read(4'h8, 2'd0, 32'h0000_0002);
        execute_transactions(1);
        finish_transactions();
        enqueue_read(4'h0, 2'd1, 32'h0000_aa55);
        execute_transactions(1);
        finish_transactions();
        enqueue_read(4'h8, 2'd0, 32'h0000_0000);
        execute_transactions(1);
        finish_transactions();

        testname = "OUT then DATA0 host to endpoint";
        reset_dut();
        sync_byte();
        out_pid();
        token_data_crc();
        eop();
        #(400ns);

        sync_byte();
        data0_pid();
        random_data();
        data_crc();
        eop();
        #(83.33333);
        #(83.33333);
        enqueue_read(4'h4, 2'd1, 32'h0000_0015);
        execute_transactions(1);
        finish_transactions();
        enqueue_read(4'h8, 2'd0, 32'h0000_0002);
        execute_transactions(1);
        finish_transactions();
        enqueue_read(4'h4, 2'd1, 32'h0000_0015);
        execute_transactions(1);
        finish_transactions();
        enqueue_read(4'h0, 2'd0, 32'h0000_0055);
        execute_transactions(1);
        finish_transactions();
        enqueue_read(4'h0, 2'd0, 32'h0000_00aa);
        execute_transactions(1);
        finish_transactions();
        enqueue_read(4'h8, 2'd0, 32'h0000_0000);
        execute_transactions(1);
        finish_transactions();
        enqueue_read(4'h4, 2'd1, 32'h0000_0014);
        execute_transactions(1);
        finish_transactions();





        $display("ALL TESTS DONE");
        $finish;
    end

endmodule
/* verilator coverage_on */
