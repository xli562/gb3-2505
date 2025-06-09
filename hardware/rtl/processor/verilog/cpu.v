`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

module cpu(
    input         clk_i,
    input         reset_n_i,
    // Instruction memory
    output [31:0] inst_mem_addr_o,
    input  [31:0] inst_i,
    // Data memory
    input  [31:0] data_mem_data_i,
    output [31:0] data_mem_addr_o,
    output [31:0] data_mem_data_o,
    output        data_mem_w_ena_o,
    output        data_mem_r_ena_o,
    output [ 3:0] data_mem_sign_mask_o,
    // Debug signal
    output        debug_o
);
    // PC
    wire [ 31:0] pc_mux0;
    wire [ 31:0] pc_in;
    wire [ 31:0] pc_out;
    wire         pcsrc;
    wire [ 31:0] inst_mux_out;
    wire [ 31:0] fence_mux_out;

    // Control signals
    wire         mem_to_reg_inst_id_s;
    wire         w_reg_inst_id_s;
    wire         w_mem_inst_id_s;
    wire         r_mem_inst_id_s;
    wire         branch_inst_id_s;
    wire         jump_inst_id_s;
    wire         jalr_inst_id_s;
    wire         alusrc_inst_id_s;
    wire         lui_inst_id_s;
    wire         auipc_inst_id_s;
    wire         fence_inst_id_s;

    // ID
    wire [  9:0] id_cont_mux_out; //control signal mux
    wire [ 31:0] regA_out;
    wire [ 31:0] regB_out;
    wire [ 31:0] imm_out;
    wire [  3:0] dataMem_sign_mask;
    wire [`kALU_OP_SEL_WIDTH-1:0] alu_op_sel_id_s;
    wire [`kALU_BRANCH_SEL_WIDTH-1:0] alu_branch_sel_id_s;

    // EX
    wire [  7:0] ex_cont_mux_out;
    wire [ 31:0] addr_adder_mux_out;
    wire [ 31:0] alu_mux_out;
    wire [ 31:0] addr_adder_out;
    wire         alu_branch_enable;
    wire [ 31:0] alu_result;
    wire [ 31:0] lui_mux_out;

    // MA
    wire [ 31:0] auipc_mux_out;

    // WB
    wire [ 31:0] wb_mux_out;
    wire [ 31:0] reg_dat_mux_out;

    // Forwarding multiplexer wires
    wire [ 31:0] dataMemOut_fwd_mux_out;
    wire [ 31:0] mem_fwd1_mux_out;
    wire [ 31:0] mem_fwd2_mux_out;
    wire [ 31:0] wb_fwd1_mux_out;
    wire [ 31:0] wb_fwd2_mux_out;
    wire         mfwd1;
    wire         mfwd2;
    wire         wfwd1;
    wire         wfwd2;

    // Branch Predictor
    wire [ 31:0] pc_adder_out;
    wire [ 31:0] branch_predictor_addr;
    wire         predict;
    wire [ 31:0] branch_predictor_mux_out;
    wire         actual_branch_decision;
    wire         mistake_trigger;
    wire         decode_ctrl_mux_sel;
    wire         inst_mux_sel;

    // Pipeline begins
    // IF stage
    mux2to1 #(
        .WIDTH(32)
    ) pc_mux(
        .input0(pc_mux0),
        .input1(addr_adder_out_ma_s),
        .select(pcsrc),
        .out   (pc_in)
    );

    adder pc_adder(
        .input1(32'b100),
        .input2(pc_out),
        .out   (pc_adder_out)
    );

    dff #(
        .WIDTH(32)
    ) PC (
        .clk_i         (clk_i),
        .reset_n_i     (reset_n_i),
        .data_i        (pc_in),
        .delayed_data_o(pc_out)
    );

    mux2to1 #(
        .WIDTH(32)
    ) inst_mux (
        .input0(inst_i),
        .input1(32'b0),
        .select(inst_mux_sel),
        .out   (inst_mux_out)
    );

    mux2to1 #(
        .WIDTH(32)
    ) fence_mux (
        .input0(pc_adder_out),
        .input1(pc_out),
        .select(fence_inst_id_s),
        .out   (fence_mux_out)
    );

    // IF-ID Pipeline Register
    wire [31:0] inst_id_s;
    wire [31:0] pc_id_s;
    dff #(
        .WIDTH(64)
    ) if_id_reg (
        .clk_i          (clk_i),
        .reset_n_i      (reset_n_i),
        .data_i         ({inst_mux_out,     // [63:32] (32 bits)
                          pc_out}),         // [31: 0] (32 bits)
        .delayed_data_o ({inst_id_s,
                          pc_id_s})
    );

    control_unit control_unit_inst(
        .opcode  (inst_id_s[6:0]),    // Opcode field in instruction
        .MemtoReg(mem_to_reg_inst_id_s),
        .RegWrite(w_reg_inst_id_s),
        .MemWrite(w_mem_inst_id_s),
        .MemRead (r_mem_inst_id_s),
        .branch  (branch_inst_id_s),
        .ALUSrc  (alusrc_inst_id_s),
        .jump    (jump_inst_id_s),
        .Jalr    (jalr_inst_id_s),
        .Lui     (lui_inst_id_s),
        .Auipc   (auipc_inst_id_s),
        .Fence   (fence_inst_id_s)
    );

    mux2to1 #(
        .WIDTH(10)
    ) id_cont_mux (
        .input0({jalr_inst_id_s,
                alusrc_inst_id_s,
                lui_inst_id_s,
                auipc_inst_id_s,
                branch_inst_id_s,
                r_mem_inst_id_s,
                w_mem_inst_id_s,
                w_reg_inst_id_s,
                mem_to_reg_inst_id_s,
                jump_inst_id_s}),
        .input1(10'b0),
        .select(decode_ctrl_mux_sel),
        .out   (id_cont_mux_out)
    );

    regfile register_files(
        .clk      (clk_i),
        .write    (w_reg_inst_ma_s),
        .wrAddr   (inst_ma_s[11:7]),
        .wrData   (reg_dat_mux_out),
        .rdAddrA  (inst_mux_out[19:15]),
        .rdDataA  (regA_out),
        .rdAddrB  (inst_mux_out[24:20]),
        .rdDataB  (regB_out)
    );

    imm_gen immediate_generator(
        .inst(inst_id_s),
        .imm (imm_out)
    );

    alu_control alu_control(
        .reset_n_i       (reset_n_i),
        .opcode_i        (inst_id_s[6:0]),
        .funct7_bit5_i   (inst_id_s[30]),      // ADD / SUB
        .funct3_i        (inst_id_s[14:12]),
        .alu_op_sel_o    (alu_op_sel_id_s),
        .alu_branch_sel_o(alu_branch_sel_id_s)
    );

    sign_mask_gen sign_mask_gen_inst(
        .func3    (inst_id_s[14:12]),
        .sign_mask(dataMem_sign_mask)
    );
    
    // ID-EX Pipeline Register
    wire [`kALU_OP_SEL_WIDTH-1:0] alu_op_sel_ex_s;
    wire [`kALU_BRANCH_SEL_WIDTH-1:0] alu_branch_sel_ex_s;
    wire [31:0] inst_ex_s, imm_out_ex_s, reg_a_out_ex_s, reg_b_out_ex_s;
    wire [ 3:0] data_mem_sign_mask_o_ex_s;
    wire [31:0] pc_ex_s;
    wire predict_ex_s;
    wire jump_inst_ex_s, mem_to_reg_inst_ex_s, w_reg_inst_ex_s;
    wire w_mem_inst_ex_s, r_mem_inst_ex_s, branch_inst_ex_s;
    wire auipc_inst_ex_s, lui_inst_ex_s, alusrc_inst_ex_s, jalr_inst_ex_s;
    dff #(
        .WIDTH(180)
    ) id_ex_reg (
        .clk_i         (clk_i),
        .reset_n_i     (reset_n_i),
        .data_i        ({inst_id_s[31:20],    // [177:166] (11 bits)
                         inst_id_s[19:15],    // [160:156] ( 5 bits)
                         inst_id_s[11: 7],    // [155:151] ( 5 bits)
                         dataMem_sign_mask,   // [150:147] ( 4 bits)
                         alu_branch_sel_id_s,
                         alu_op_sel_id_s, 
                         imm_out,             // [139:108] (32 bits)
                         regB_out,            // [107: 76] (32 bits)
                         regA_out,            // [ 75: 44] (32 bits)
                         pc_id_s,             // [ 43: 12] (32 bits)
                         predict,             // [    7  ] ( 1 bit )
                         id_cont_mux_out}), // [  6:  0] ( 7 bits)
        .delayed_data_o({inst_ex_s[31:20],
                         inst_ex_s[19:15],
                         inst_ex_s[11: 7],
                         data_mem_sign_mask_o_ex_s,
                         alu_branch_sel_ex_s,
                         alu_op_sel_ex_s,
                         imm_out_ex_s,
                         reg_b_out_ex_s,
                         reg_a_out_ex_s,
                         pc_ex_s,
                         predict_ex_s,
                         jalr_inst_ex_s,
                         alusrc_inst_ex_s,
                         lui_inst_ex_s,
                         auipc_inst_ex_s,
                        //  ctrl_mux_out_ex_s[10:7],
                         branch_inst_ex_s,
                         r_mem_inst_ex_s,
                         w_mem_inst_ex_s,
                         w_reg_inst_ex_s,
                         mem_to_reg_inst_ex_s,
                         jump_inst_ex_s})
                        //  ctrl_mux_out_ex_s[6:0]})
    );
    
    mux2to1 #(
        .WIDTH(8)
    ) ex_cont_mux (
        .input0({predict_ex_s,
                 auipc_inst_ex_s,
                 branch_inst_ex_s,
                 r_mem_inst_ex_s,
                 w_mem_inst_ex_s,
                 w_reg_inst_ex_s,
                 mem_to_reg_inst_ex_s,
                 jump_inst_ex_s}),
        .input1(8'b0),
        .select(pcsrc),
        .out   (ex_cont_mux_out)
    );

    mux2to1 #(
        .WIDTH(32)
    ) addr_adder_mux (
        .input0(pc_ex_s),
        .input1(wb_fwd1_mux_out),
        .select(jalr_inst_ex_s),
        .out   (addr_adder_mux_out)
    );

    adder addr_adder(
        .input1(addr_adder_mux_out),
        .input2(imm_out_ex_s),
        .out   (addr_adder_out)
    );

    mux2to1 #(
        .WIDTH(32)
    ) alu_mux (
        .input0(wb_fwd2_mux_out),
        .input1(imm_out_ex_s),
        .select(alusrc_inst_ex_s),
        .out   (alu_mux_out)
    );

    alu alu_inst(
        .a_i(wb_fwd1_mux_out),
        .b_i(alu_mux_out),
        .branch_sel_i(alu_branch_sel_ex_s),
        .op_sel_i(alu_op_sel_ex_s),
        .result_o(alu_result),
        .branch_ena_o(alu_branch_enable)
    );

    mux2to1 #(
        .WIDTH(32)
    ) lui_mux (
        .input0(alu_result),
        .input1(imm_out_ex_s),
        .select(lui_inst_ex_s),
        .out   (lui_mux_out)
    );

    // EX-MA Pipeline Register
    wire [31:0] inst_ma_s, pc_ma_s;
    wire [31:0] lui_mux_out_ma_s, addr_adder_out_ma_s;
    wire alu_branch_enable_ma_s;
    wire jump_inst_ma_s, mem_to_reg_inst_ma_s, w_reg_inst_ma_s;
    wire branch_inst_ma_s, predict_ma_s, auipc_inst_ma_s;
    dff #(
        .WIDTH(120)
    ) ex_ma_reg (
        .clk_i         (clk_i),
        .reset_n_i     (reset_n_i),
        .data_i        ({inst_ex_s[31:20],     // [154:143] (12 bits)
                         inst_ex_s[11: 7],     // [142:138] ( 5 bits)
                         lui_mux_out,             // [105: 74] (32 bits)
                         alu_branch_enable,      // [    73 ] ( 1 bit )
                         addr_adder_out,         // [ 72: 41] (32 bits)
                         pc_ex_s,       // [ 40:  9] (32 bits)
                         ex_cont_mux_out[7:5],
                         ex_cont_mux_out[2:0]}), // [  8:  0] ( 9 bits)
        .delayed_data_o({inst_ma_s[31:20],
                         inst_ma_s[11:7],
                         lui_mux_out_ma_s,
                         alu_branch_enable_ma_s,
                         addr_adder_out_ma_s,
                         pc_ma_s,
                         predict_ma_s,
                         auipc_inst_ma_s,
                         branch_inst_ma_s,
                         w_reg_inst_ma_s,
                         mem_to_reg_inst_ma_s,
                         jump_inst_ma_s})
    );

    branch_decide branch_decide_0 (
        .branch             (branch_inst_ma_s),
        .predicted          (predict_ma_s),
        .branch_enable      (alu_branch_enable_ma_s),
        .jump               (jump_inst_ma_s),
        .mispredict         (mistake_trigger),
        .decision           (actual_branch_decision),
        .branch_jump_trigger(pcsrc)
    );

    mux2to1 #(
        .WIDTH(32)
    ) auipc_mux (
        .input0(lui_mux_out_ma_s),
        .input1(addr_adder_out_ma_s),
        .select(auipc_inst_ma_s),
        .out   (auipc_mux_out)
    );

    // MA-WB Pipeline Register
    wire [31:0] inst_wb_s, auipc_mux_out_wb_s;
    wire [31:0] data_mem_data_i_wb_s, lui_mux_out_wb_s;
    wire mem_to_reg_inst_wb_s, w_reg_inst_wb_s;
    dff #(
        .WIDTH(115)
    ) ma_wb_reg (
        .clk_i         (clk_i),
        .reset_n_i     (reset_n_i),
        .data_i        ({inst_ma_s[31:20], // [116:105] (12 bits)
                         inst_ma_s[11:7], // [104:100] ( 5 bits)
                         data_mem_data_i,        // [ 99: 68] (32 bits)
                         auipc_mux_out,       // [ 67: 36] (32 bits)
                         lui_mux_out_ma_s,  // [ 35:  4] (32 bits)
                         w_reg_inst_ma_s,
                         mem_to_reg_inst_ma_s}),   // [  3:  0] ( 4 bits)
        .delayed_data_o({inst_wb_s[31:20],
                         inst_wb_s[11:7],
                         data_mem_data_i_wb_s,
                         auipc_mux_out_wb_s,
                         lui_mux_out_wb_s,
                         w_reg_inst_wb_s,
                         mem_to_reg_inst_wb_s})
    );

    mux2to1 #(
        .WIDTH(32)
    ) wb_mux (
        .input0(auipc_mux_out_wb_s),
        .input1(data_mem_data_i_wb_s),
        .select(mem_to_reg_inst_wb_s),
        .out   (wb_mux_out)
    );

    mux2to1 #(
        .WIDTH(32)
    ) reg_dat_mux ( //TODO cleanup
        .input0(mem_regwb_mux_out),
        .input1(pc_ex_s),
        .select(jump_inst_ma_s),
        .out   (reg_dat_mux_out)
    );

    forwarding_unit forwarding_unit (
        .rs1             (inst_ex_s[19:15]),
        .rs2             (inst_ex_s[24:20]),
        .MA_RegWriteAddr(inst_ma_s[11:7]),
        .WB_RegWriteAddr (inst_wb_s[11:7]),
        .MA_RegWrite    (w_reg_inst_ma_s),
        .WB_RegWrite     (w_reg_inst_wb_s),
        .MA_fwd1        (mfwd1),
        .MA_fwd2        (mfwd2),
        .WB_fwd1         (wfwd1),
        .WB_fwd2         (wfwd2)
    );

    mux2to1 #(
        .WIDTH(32)
    ) mem_fwd1_mux (
        .input0(reg_a_out_ex_s),
        .input1(dataMemOut_fwd_mux_out),
        .select(mfwd1),
        .out   (mem_fwd1_mux_out)
    );

    mux2to1 #(
        .WIDTH(32)
    ) mem_fwd2_mux (
        .input0(reg_b_out_ex_s),
        .input1(dataMemOut_fwd_mux_out),
        .select(mfwd2),
        .out   (mem_fwd2_mux_out)
    );

    mux2to1 #(
        .WIDTH(32)
    ) wb_fwd1_mux (
        .input0(mem_fwd1_mux_out),
        .input1(wb_mux_out),
        .select(wfwd1),
        .out   (wb_fwd1_mux_out)
    );

    mux2to1 #(
        .WIDTH(32)
    ) wb_fwd2_mux (
        .input0(mem_fwd2_mux_out),
        .input1(wb_mux_out),
        .select(wfwd2),
        .out   (wb_fwd2_mux_out)
    );

    mux2to1 #(
        .WIDTH(32)
    ) dataMemOut_fwd_mux (
        .input0(lui_mux_out_ma_s),
        .input1(data_mem_data_i),
        .select(mem_to_reg_inst_ma_s),
        .out   (dataMemOut_fwd_mux_out)
    );

    branch_predictor branch_predictor_FSM (
        .clk_i                 (clk_i),
        .actual_branch_decision(actual_branch_decision),
        .branch_decode_sig     (id_cont_mux_out[5]),
        .branch_mem_sig        (branch_inst_ma_s),
        .in_addr               (pc_id_s),
        .offset                (imm_out),
        .branch_addr           (branch_predictor_addr),
        .prediction            (predict)
    );

    mux2to1 #(
        .WIDTH(32)
    ) branch_predictor_mux (
        .input0(fence_mux_out),
        .input1(branch_predictor_addr),
        .select(predict),
        .out   (branch_predictor_mux_out)
    );

    mux2to1 #(
        .WIDTH(32)
    ) mistaken_branch_mux (
        .input0(branch_predictor_mux_out),
        .input1(pc_ex_s),
        .select(mistake_trigger),
        .out   (pc_mux0)
    );

    wire[31:0] mem_regwb_mux_out;
    // Copy of WB mux, but in MA stage. Move back and cleanup
    mux2to1 #(
        .WIDTH(32)
    ) mem_regwb_mux(
        .input0(auipc_mux_out),
        .input1(data_mem_data_i),
        .select(mem_to_reg_inst_ma_s),
        .out   (mem_regwb_mux_out)
    );

    // OR gate assignments, used for flushing
    assign decode_ctrl_mux_sel = pcsrc | mistake_trigger;
    assign inst_mux_sel = pcsrc | predict | mistake_trigger | fence_inst_id_s;

    // Instruction Memory Connections
    assign inst_mem_addr_o = pc_out;

    // Data Memory Connections
    assign data_mem_addr_o = lui_mux_out;
    assign data_mem_data_o = wb_fwd2_mux_out;
    assign data_mem_w_ena_o = ex_cont_mux_out[3];
    assign data_mem_r_ena_o = ex_cont_mux_out[4];
    assign data_mem_sign_mask_o = data_mem_sign_mask_o_ex_s;
endmodule
