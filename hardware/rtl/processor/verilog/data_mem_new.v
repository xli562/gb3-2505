`default_nettype none
`timescale 1ns / 1ps

module data_mem (
    input               clk_i,
    input       [31:0]  addr_i,
    input       [31:0]  w_data_i,
    input               w_ena_i,
    input               r_ena_i,
    input       [3:0]   sign_mask_i,
    output reg  [31:0]  r_data_o,
    output      [7:0]   led_o,
    output reg          clk_stall_o          // CPU-visible stall
);
    //--------------------------------------------------------------------
    //  Configuration constants
    //--------------------------------------------------------------------
    localparam DATA_BASE_WORD = 12'h400;     // 0x1000 >> 2

    //--------------------------------------------------------------------
    //  Storage (1 k × 32, LUT-RAM on iCE40)
    //--------------------------------------------------------------------
    reg [31:0] data_block [0:1023];
    reg [31:0] word_buf;
    reg [31:0] led_reg;

    //--------------------------------------------------------------------
    //  2-stage memory pipeline FSM
    //--------------------------------------------------------------------
    // State
    integer state = 0;
    parameter S_IDLE = 2'd0;
    parameter S_EXEC = 2'd1;

    // Latched request
    reg         r_ena_q;
    reg         w_ena_q;
    reg [31:0]  addr_q;
    reg [31:0]  w_data_q;
    reg [3:0]   smask_q;

    // Derived fields -----------------------------------------------------
    wire  [1:0] byte_off  = addr_q[1:0];
    wire        hit_data  = addr_q[13]   && !addr_q[31:14];             // 0x1000-0x1FFF
    wire [9:0]  mem_idx   = addr_q[11:2] - DATA_BASE_WORD;             // 0-1023

    //--------------------------------------------------------------------
    //  Helper: byte-enable mask for stores
    //--------------------------------------------------------------------
    function automatic [3:0] be_mask;
        input [3:0] smask;      // [1:0]=size, [2]=signed/unsigned
        input [1:0] off;
        begin
            case (smask[1:0])
                2'b00 : be_mask = 4'b1111;                       // word
                2'b01 : be_mask = off[1] ? 4'b1100 : 4'b0011;    // half-word
                default: be_mask = 4'b0001 << off;               // byte
            endcase
        end
    endfunction

    //--------------------------------------------------------------------
    //  Helper: format read data (sign/zero extend)
    //--------------------------------------------------------------------
    function automatic [31:0] fmt_read;
        input [31:0] word;
        input [1:0]  off;
        input [3:0]  smask;
        reg   [31:0] t;
        begin
            case (smask[1:0])
                2'b00 : t = word;                                // LW
                2'b01 : begin                                    // LH/LHU
                    t = off[1] ? word[31:16] : word[15:0];
                    t = smask[2] ? {{16{t[15]}}, t[15:0]}
                                 : {16'd0, t[15:0]};
                end
                default : begin                                  // LB/LBU
                    t = (off == 2'd0) ? word[7:0]   :
                        (off == 2'd1) ? word[15:8]  :
                        (off == 2'd2) ? word[23:16] : word[31:24];
                    t = smask[2] ? {{24{t[7]}}, t[7:0]}
                                 : {24'd0, t[7:0]};
                end
            endcase
            fmt_read = t;
        end
    endfunction

    //--------------------------------------------------------------------
    //  Reset / initialisation
    //--------------------------------------------------------------------
    initial begin
        `ifdef SYNTHESIS
            $readmemh("processor/verilog/data.hex", data_block);
        `else
            $readmemh("verilog/data.hex", data_block);
        `endif
        state        = S_IDLE;
        clk_stall_o  = 1'b0;
        r_data_o     = 32'd0;
        led_reg      = 8'd0;
    end

    //--------------------------------------------------------------------
    //  Main sequential logic
    //--------------------------------------------------------------------
    always @(posedge clk_i) begin
        case (state)
            //----------------------------------------------------------------
            //  Stage-0 – capture request (1 LUT of gating only)
            //----------------------------------------------------------------
            S_IDLE: begin
                clk_stall_o <= 1'b0;

                if (w_ena_i | r_ena_i) begin
                    r_ena_q    <= r_ena_i;
                    w_ena_q    <= w_ena_i;
                    addr_q     <= addr_i;
                    w_data_q   <= w_data_i;
                    smask_q    <= sign_mask_i;
                    clk_stall_o <= 1'b1;           // back-pressure one cycle
                    state       <= S_EXEC;
                end
            end

            //----------------------------------------------------------------
            //  Stage-1 – execute (all inside a single cycle)
            //----------------------------------------------------------------
            S_EXEC: begin
                clk_stall_o <= 1'b0;

                // ---------------- WRITE ----------------
                if (w_ena_q) begin
                    if (hit_data) begin
                        data_block[mem_idx] <=
                            (w_data_q & { 8{be_mask(smask_q, byte_off)} }) |
                            (data_block[mem_idx] &
                            ~{ 8{be_mask(smask_q, byte_off)} });
                    end
                end

                // ---------------- READ -----------------
                if (r_ena_q && hit_data) begin
                    word_buf <= data_block[mem_idx];
                    r_data_o <= fmt_read(data_block[mem_idx],
                                         byte_off,
                                         smask_q);
                end

                state <= S_IDLE;
            end
        endcase
    end

    always @(posedge clk_i) begin
        if(w_ena_i == 1'b1 && addr_i == 32'h2000) begin
            led_reg <= w_data_i;
        end
    end

    assign led_o = led_reg[7:0];
endmodule
