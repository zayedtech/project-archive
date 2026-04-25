`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_usb_rx ();

    localparam CLK_PERIOD = 10ns;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars;
    end

    logic clk, n_rst, dp_in, dm_in, rx_data_ready, rx_transfer_active, rx_error, flush, store_rx_packet_data;
    logic [6:0] buffer_occupancy;
    logic [2:0] rx_packet;
    logic [7:0] rx_packet_data; 
    string test_name;
    usb_rx DUT(.clk(clk), .n_rst(n_rst), .dp_in(dp_in), .dm_in(dm_in), .buffer_occupancy(buffer_occupancy), .rx_data_ready(rx_data_ready), .rx_transfer_active(rx_transfer_active), .rx_error(rx_error), .flush(flush), .store_rx_packet_data(store_rx_packet_data), .rx_packet(rx_packet), .rx_packet_data(rx_packet_data));

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
        @(negedge clk);
    end
    endtask
    
    task sync_byte;
    begin
        /*10000000*/
        dp_in = 1;
        dm_in = 0;
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
        dp_in = 0;
        dm_in = 1;
        #(83.33333ns);
        #(83.33333ns);
    end
    endtask

    task incorrect_sync_byte;
    begin
        
        /*10000000*/
        dp_in = 1;
        dm_in = 0;
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
        #(83.33333ns);
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

    task incorrect_token_data_crc;
    begin
        /*11111_0000_0111110*/
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

        #(83.33333ns);
        #(83.33333ns);
        #(83.33333ns);
        #(83.33333ns);
        #(83.33333ns);
        
    end
    endtask


    task token_data_crc_incorrect_ep;
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

        #(83.33333ns);
        #(83.33333ns);
        #(83.33333ns);
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


    task twobytesofdata;
    begin
        /*10101010_01010101*/
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

    task incorrect_pid;
    begin
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

    task onebyteofdata;
    begin
        /*01010101*/
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

    initial begin
        n_rst = 1;
        test_name = "";
        dp_in = 1;
        dm_in = 0;

        test_name = "reset";
        reset_dut();

        test_name = "correct ack";
        buffer_occupancy = 0;
        sync_byte();
        ack_pid();
        eop();
        #(83.33333ns);
        #(83.33333ns);
        #(83.33333ns);

        reset_dut();

        test_name = "correct data0";
        buffer_occupancy = 0;
        sync_byte(); //1byte
        data0_pid(); //1byte
        twobytesofdata(); //2bytes
        twobytesofdata(); //2bytes
        data_crc(); //2bytes
        eop(); //EOP
        #(83.33333ns);
        #(83.33333ns);
        #(83.33333ns);

        reset_dut();

        test_name = "correct data1";
        buffer_occupancy = 0;
        sync_byte(); //1byte
        data1_pid(); //1byte
        twobytesofdata(); //2bytes
        twobytesofdata(); //2bytes
        data_crc(); //2bytes
        eop(); //EOP
        #(83.33333ns);
        #(83.33333ns);
        #(83.33333ns);

        reset_dut();

        test_name = "correct in";
        buffer_occupancy = 0;
        sync_byte(); //1byte
        in_pid(); //1byte
        token_data_crc(); //2bytes
        eop(); //EOP
        #(83.33333ns);
        #(83.33333ns);
        #(83.33333ns);

        reset_dut();

        test_name = "correct out";
        buffer_occupancy = 0;
        sync_byte(); //1byte
        out_pid(); //1byte
        token_data_crc(); //2bytes
        eop(); //EOP
        #(83.33333ns);
        #(83.33333ns);
        #(83.33333ns);

        reset_dut();

        test_name = "Buffer Filled";
        sync_byte(); //1byte
        data0_pid(); //1byte
        buffer_occupancy = 63;
        twobytesofdata(); //2bytes
        onebyteofdata(); //1byte
        repeat(9) begin @(negedge clk); end
        buffer_occupancy = 64;
        onebyteofdata(); //1byte
        data_crc(); //2bytes
        eop(); //EOP
        #(83.33333ns);
        #(83.33333ns);
        #(83.33333ns);


        reset_dut();

        test_name = "EOP Error";
        buffer_occupancy = 0;
        sync_byte();
        ack_pid();
        dp_in = 1;
        dm_in = 0;
        #(83.33333ns);
        #(83.33333ns);
        #(83.33333ns);
        #(83.33333ns);
        #(83.33333ns);
        #(83.33333ns);

        reset_dut();

        test_name = "Incorrect CRC";
        buffer_occupancy = 0;
        sync_byte(); //1byte
        in_pid(); //1byte
        incorrect_token_data_crc(); //2bytes
        eop(); //EOP
        #(83.33333ns);
        #(83.33333ns);
        #(83.33333ns);
        
        reset_dut();
        
        test_name = "Incorrect PID";
        buffer_occupancy = 0;
        sync_byte();
        incorrect_pid();
        eop();
        #(83.33333ns);
        #(83.33333ns);
        #(83.33333ns);

        reset_dut();
        
        test_name = "Incorrect Sync";
        buffer_occupancy = 0;
        incorrect_sync_byte();
        ack_pid();
        eop();
        #(83.33333ns);
        #(83.33333ns);
        #(83.33333ns);

        reset_dut();

        test_name = "Incorrect Endpoint";
        buffer_occupancy = 0;
        sync_byte(); //1byte
        out_pid(); //1byte
        token_data_crc_incorrect_ep(); //2bytes
        eop(); //EOP
        #(83.33333ns);
        #(83.33333ns);
        #(83.33333ns);


        $finish;
    end
endmodule

/* verilator coverage_on */
