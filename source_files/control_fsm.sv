`timescale 1ns / 10ps

typedef enum logic [4:0]{
  IDLE=0, CLEAR=1, START=2, DATA1=3, DATA0=4, OUT=5, IN=6, ACK=7, EOP_START=8, EOP_0=9, WAIT_1=10, EOP_1=11, WAIT_2=12, IDLE_VAL=13, ERROR=14, DONE=15, FL_DATA1=16, FL_DATA0=17, FL_IN=18, FL_OUT=19
} state_t;


module control_fsm (input logic clk, n_rst, new_pack, pid_error, data_1, data_0, out_token, in_token, ack, token_done, cycles_8, dm, dp, data_done, data_err, token_err, sync_err,
output logic clear_err, en_timer, rx_data_ready, transfer_active, flush_data, eop_err, pack_done, flush_token, timer_8, output logic [2:0] rx_packet);

state_t state, nextstate;

logic [2:0] packet_type_ffin, packet_type_ffout;

always_comb begin : nextStateLogic
    casez ({state, new_pack, pid_error, data_1, data_0, out_token, in_token, ack, token_done, cycles_8, dm, dp, data_done, data_err, token_err, sync_err})
        {IDLE, 1'b1, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}: begin nextstate = CLEAR; packet_type_ffin = packet_type_ffout;end
        {CLEAR, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}: begin nextstate = START; packet_type_ffin = packet_type_ffout;end
        {START, 1'b?, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b0}: begin nextstate = ERROR; packet_type_ffin = packet_type_ffout;end
        {START, 1'b?, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b1}: begin nextstate = ERROR; packet_type_ffin = packet_type_ffout;end
        
        {START, 1'b?, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}: begin nextstate = FL_DATA1;packet_type_ffin = 3'b010;end
        {START, 1'b?, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}: begin nextstate = FL_DATA0;packet_type_ffin = 3'b001;end
        {START, 1'b?, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}: begin nextstate = FL_OUT; packet_type_ffin = 3'b110;end
        {START, 1'b?, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}: begin nextstate = FL_IN;packet_type_ffin = 3'b111;end
        {START, 1'b?, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}: begin nextstate = ACK;packet_type_ffin = 3'b011;end
        {OUT, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b1, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}: begin nextstate = EOP_START;packet_type_ffin = packet_type_ffout;end
        {IN, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b1, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}: begin nextstate = EOP_START;packet_type_ffin = packet_type_ffout;end
        {EOP_START, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}: begin nextstate = EOP_0;packet_type_ffin = packet_type_ffout;end
        {EOP_0, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b0, 1'b0, 1'b?, 1'b?, 1'b?, 1'b?}: begin nextstate = WAIT_1;packet_type_ffin = packet_type_ffout;end
        {EOP_0, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b1, 1'b?, 1'b?, 1'b?, 1'b?}: begin nextstate = ERROR;packet_type_ffin = packet_type_ffout;end
        {WAIT_1, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b1, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}: begin nextstate = EOP_1;packet_type_ffin = packet_type_ffout;end
        {EOP_1, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b0, 1'b0, 1'b?, 1'b?, 1'b?, 1'b?}: begin nextstate = WAIT_2;packet_type_ffin = packet_type_ffout;end
        {EOP_1, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b1, 1'b?, 1'b?, 1'b?, 1'b?}: begin nextstate = ERROR;packet_type_ffin = packet_type_ffout;end
        {WAIT_2, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b1, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}:begin  nextstate = IDLE_VAL;packet_type_ffin = packet_type_ffout;end
        {IDLE_VAL, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b0, 1'b1, 1'b?, 1'b?, 1'b?, 1'b?}: begin nextstate = DONE;packet_type_ffin = packet_type_ffout;end
        {IDLE_VAL, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b0, 1'b?, 1'b?, 1'b?, 1'b?}: begin nextstate = ERROR;packet_type_ffin = packet_type_ffout;end
        {DONE, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}: begin nextstate = IDLE;packet_type_ffin = 3'b000;end
        {ERROR, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}: begin nextstate = IDLE; packet_type_ffin = 3'b000;end
        {DATA0, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b1, 1'b0, 1'b?, 1'b?}: begin nextstate = EOP_START;  packet_type_ffin = packet_type_ffout;end  
        {DATA1, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b1, 1'b0, 1'b?, 1'b?}: begin nextstate = EOP_START;packet_type_ffin = packet_type_ffout;end
        {ACK, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}:begin  nextstate = EOP_START;   packet_type_ffin = packet_type_ffout; end
        {FL_DATA1, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}: begin nextstate = DATA1; packet_type_ffin = packet_type_ffout; end  
        {FL_DATA0, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}: begin nextstate = DATA0; packet_type_ffin = packet_type_ffout;end     
        {FL_IN, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}:begin  nextstate = IN;   packet_type_ffin = packet_type_ffout; end
        {FL_OUT, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?}: begin nextstate = OUT;  packet_type_ffin = packet_type_ffout; end 
        {DATA0, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b1, 1'b?, 1'b?}: begin nextstate = ERROR;  packet_type_ffin = packet_type_ffout;end  
        {DATA1, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b1, 1'b?, 1'b?}: begin nextstate = ERROR;packet_type_ffin = packet_type_ffout;end
        {OUT, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b0, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b1, 1'b?}: begin nextstate = ERROR;packet_type_ffin = packet_type_ffout;end
        {IN, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b0, 1'b?, 1'b?, 1'b?, 1'b?, 1'b?, 1'b1, 1'b?}: begin nextstate = ERROR;packet_type_ffin = packet_type_ffout;end
        


        default: begin nextstate = state; packet_type_ffin = packet_type_ffout; end
    endcase
end

always_ff @(posedge clk, negedge n_rst) begin : stateFF
    if (n_rst == 0) begin
        state <= IDLE;
        packet_type_ffout <= 3'b000;
    end
    else begin
        state <= nextstate;
        packet_type_ffout <= packet_type_ffin;
    end
end

always_comb begin : outputLogic
    case(state)
        IDLE: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b0;
            
            flush_data = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            flush_token = 1'b0;
            timer_8 = 1'b0;
        end
        CLEAR: begin
            clear_err = 1'b1;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            
            flush_data = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            flush_token = 1'b0;
            timer_8 = 1'b0;
        end
        START: begin
            clear_err = 1'b0;
            en_timer = 1'b1;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            
            flush_data = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            flush_token = 1'b0;
            timer_8 = 1'b0;
        end
        FL_DATA1: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            
            flush_data = 1'b1;
            eop_err = 1'b0;
            pack_done = 1'b0;
            flush_token = 1'b0;
            timer_8 = 1'b0;
        end
        DATA1: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            
            flush_data = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            flush_token = 1'b0;
            timer_8 = 1'b0;
        end
        FL_DATA0: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            
            flush_data = 1'b1;
            eop_err = 1'b0;
            pack_done = 1'b0;
            flush_token = 1'b0;
            timer_8 = 1'b0;
        end
        DATA0: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            
            flush_data = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            flush_token = 1'b0;
            timer_8 = 1'b0;
        end
        FL_OUT: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            
            flush_data = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            flush_token = 1'b1;
            timer_8 = 1'b0;
        end
        OUT: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            
            flush_data = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            flush_token = 1'b0;
            timer_8 = 1'b0;
        end
        FL_IN: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            
            flush_data = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            flush_token = 1'b1;
            timer_8 = 1'b0;
        end
        IN: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            
            flush_data = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            flush_token = 1'b0;
            timer_8 = 1'b0;
        end
        ACK: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            
            flush_data = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            flush_token = 1'b0;
            timer_8 = 1'b0;
        end
        EOP_START: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            
            flush_data = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            flush_token = 1'b0;
            timer_8 = 1'b0;
        end
        EOP_0: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            
            flush_data = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            flush_token = 1'b0;
            timer_8 = 1'b0;
        end
        WAIT_1: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            
            flush_data = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            flush_token = 1'b0;
            timer_8 = 1'b1;
        end
        EOP_1: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            
            flush_data = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            flush_token = 1'b0;
            timer_8 = 1'b0;
        end
        ERROR: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            
            flush_data = 1'b0;
            eop_err = 1'b1;
            pack_done = 1'b0;
            flush_token = 1'b0;
            timer_8 = 1'b0;
        end
        WAIT_2: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            
            flush_data = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            flush_token = 1'b0;
            timer_8 = 1'b1;
        end
        IDLE_VAL: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b1;
            
            flush_data = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            flush_token = 1'b0;
            timer_8 = 1'b0;
        end
        DONE: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b1;
            transfer_active = 1'b1; //maybe off
            
            flush_data = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            flush_token = 1'b0;
            timer_8 = 1'b0;
        end
        default: begin
            clear_err = 1'b0;
            en_timer = 1'b0;
            rx_data_ready = 1'b0;
            transfer_active = 1'b0;
            
            flush_data = 1'b0;
            eop_err = 1'b0;
            pack_done = 1'b0;
            flush_token = 1'b0;
            timer_8 = 1'b0;
        end
    endcase
end

assign rx_packet = packet_type_ffout;

endmodule
