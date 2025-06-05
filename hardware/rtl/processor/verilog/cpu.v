`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

module cpu(
    input         clk_i,
    input         reset_n_i,
    // Instruction memory
    output [31:0] inst_mem_in,
    input  [31:0] inst_mem_out,
    // Data memory
    input  [31:0] data_mem_out,
    output [31:0] data_mem_addr,
    output [31:0] data_mem_WrData,
    output        data_mem_memwrite,
    output        data_mem_memread,
    output [ 3:0] data_mem_sign_mask,
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

    // Pipeline registers
    wire [ 63:0] if_id_out;
    wire [177:0] id_ex_out;
    wire [154:0] ex_mem_out;
    wire [116:0] mem_wb_out;

    // Control signals
    wire         MemtoReg1;
    wire         RegWrite1;
    wire         MemWrite1;
    wire         MemRead1;
    wire         branch1;
    wire         jump1;
    wire         Jalr1;
    wire         ALUSrc1;
    wire         Lui1;
    wire         Auipc1;
    wire         Fence_signal;

    // ID
    wire [ 31:0] cont_mux_out; //control signal mux
    wire [ 31:0] regA_out;
    wire [ 31:0] regB_out;
    wire [ 31:0] imm_out;
    wire [  3:0] dataMem_sign_mask;

    // EX
    wire [ 31:0] ex_cont_mux_out;
    wire [ 31:0] addr_adder_mux_out;
    wire [ 31:0] alu_mux_out;
    wire [ 31:0] addr_adder_sum;
    wire [  6:0] alu_ctl;
    wire         alu_branch_enable;
    wire [ 31:0] alu_result;
    wire [ 31:0] lui_result;

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
    mux2to1 pc_mux(
        .input0(pc_mux0),
        .input1(ex_mem_out[72:41]),
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
        .clk_i(clk_i),
        .reset_n_i      (reset_n_i),
        .data_i(pc_in),
        .delayed_data_o(pc_out)
    );

    mux2to1 inst_mux(
        .input0(inst_mem_out),
        .input1(32'b0),
        .select(inst_mux_sel),
        .out   (inst_mux_out)
    );

    mux2to1 fence_mux(
        .input0(pc_adder_out),
        .input1(pc_out),
        .select(Fence_signal),
        .out   (fence_mux_out)
    );

    // IF-ID Pipeline Register
    dff #(
        .WIDTH(64)
    ) if_id_reg (
        .clk_i          (clk_i),
        .reset_n_i      (reset_n_i),
        .data_i         ({inst_mux_out,     // [63:32] (32 bits)
                          pc_out}),         // [31: 0] (32 bits)
        .delayed_data_o (if_id_out)
    );

    control_unit control_unit_inst(
        .opcode  ({if_id_out[38:32]}),    // Opcode field in instruction
        .MemtoReg(MemtoReg1),
        .RegWrite(RegWrite1),
        .MemWrite(MemWrite1),
        .MemRead (MemRead1),
        .branch  (branch1),
        .ALUSrc  (ALUSrc1),
        .jump    (jump1),
        .Jalr    (Jalr1),
        .Lui     (Lui1),
        .Auipc   (Auipc1),
        .Fence   (Fence_signal)
    );

    mux2to1 cont_mux(
        .input0({21'b0,
                Jalr1,
                ALUSrc1,
                Lui1,
                Auipc1,
                branch1,
                MemRead1,
                MemWrite1,
                1'b0,
                RegWrite1,
                MemtoReg1,
                jump1}),
        .input1(32'b0),
        .select(decode_ctrl_mux_sel),
        .out   (cont_mux_out)
    );

    regfile register_files(
        .clk      (clk_i),
        .write(ex_mem_out[2]),
        .wrAddr   (ex_mem_out[142:138]),
        .wrData   (reg_dat_mux_out),
        .rdAddrA  (inst_mux_out[19:15]),
        .rdDataA  (regA_out),
        .rdAddrB  (inst_mux_out[24:20]),
        .rdDataB  (regB_out)
    );

    imm_gen immediate_generator(
        .inst(if_id_out[63:32]),
        .imm (imm_out)
    );

    alu_control alu_control(
        .Opcode  (if_id_out[38:32]),    // opcode
        .FuncCode({if_id_out[62],       // funct7[5]
                   if_id_out[46:44]}),  // funct3
        .ALUCtl  (alu_ctl)
    );

    sign_mask_gen sign_mask_gen_inst(
        .func3    (if_id_out[46:44]),
        .sign_mask(dataMem_sign_mask)
    );
    
    // ID-EX Pipeline Register
    dff #(
        .WIDTH(178)
    ) id_ex_reg (
        .clk_i         (clk_i),
        .reset_n_i     (reset_n_i),
        .data_i        ({if_id_out[63:52],     // [177:166] (11 bits)
                          if_id_out[56:52],    // [165:161] ( 5 bits)
                          if_id_out[51:47],    // [160:156] ( 5 bits)
                          if_id_out[43:39],    // [155:151] ( 5 bits)
                          dataMem_sign_mask,   // [150:147] ( 4 bits)
                          alu_ctl,             // [146:140] (32 bits)
                          imm_out,             // [139:108] (32 bits)
                          regB_out,            // [107: 76] (32 bits)
                          regA_out,            // [ 75: 44] (32 bits)
                          if_id_out[31:0],     // [ 43: 12] (32 bits)
                          cont_mux_out[10:7],  // [ 11:  8] ( 4 bits)
                          predict,             // [    7  ] ( 1 bit )
                          cont_mux_out[6:0]}), // [  6:  0] ( 7 bits)
        .delayed_data_o(id_ex_out)
    );
    
    mux2to1 ex_cont_mux(
        .input0({23'b0, id_ex_out[8:0]}),   // {23'b0, cont_mux_out[10:7], predict(wire), cont_mux_out[6:0]}
        .input1(32'b0),
        .select(pcsrc),
        .out   (ex_cont_mux_out)
    );

    mux2to1 addr_adder_mux(
        .input0(id_ex_out[43:12]),          // if_id_out    [31:0]
        .input1(wb_fwd1_mux_out),
        .select(id_ex_out[11]),             // cont_mux_out [10]
        .out   (addr_adder_mux_out)
    );

    adder addr_adder(
        .input1(addr_adder_mux_out),
        .input2(id_ex_out[139:108]),        // imm_out     ([31:0])
        .out   (addr_adder_sum)
    );

    mux2to1 alu_mux(
        .input0(wb_fwd2_mux_out),
        .input1(id_ex_out[139:108]),        // imm_out
        .select(id_ex_out[10]),             // cont_mux_out [9]
        .out   (alu_mux_out)
    );

    alu alu_main(
        .ALUctl       (id_ex_out[146:140]), // alu_ctl
        .A            (wb_fwd1_mux_out),
        .B            (alu_mux_out),
        .ALUOut       (alu_result),
        .branch_enable(alu_branch_enable)
    );

    mux2to1 lui_mux(
        .input0(alu_result),
        .input1(id_ex_out[139:108]),
        .select(id_ex_out[9]),
        .out   (lui_result)
    );

    // EX-MEM Pipeline Register
    dff#(
        .WIDTH(155)
    ) ex_mem_reg(
        .clk_i         (clk_i),
        .reset_n_i     (reset_n_i),
        .data_i        ({id_ex_out[177:166],     // [154:143] (12 bits)
                         id_ex_out[155:151],     // [142:138] ( 5 bits)
                         wb_fwd2_mux_out,        // [137:106] (32 bits)
                         lui_result,             // [105: 74] (32 bits)
                         alu_branch_enable,      // [    73 ] ( 1 bit )
                         addr_adder_sum,         // [ 72: 41] (32 bits)
                         id_ex_out[43:12],       // [ 40:  9] (32 bits)
                         ex_cont_mux_out[8:0]}), // [  8:  0] ( 9 bits)
        .delayed_data_o(ex_mem_out)
    );

    branch_decide branch_decide_0(
        .branch             (ex_mem_out[6]),
        .predicted          (ex_mem_out[7]),
        .branch_enable      (ex_mem_out[73]),
        .jump               (ex_mem_out[0]),
        .mispredict         (mistake_trigger),
        .decision           (actual_branch_decision),
        .branch_jump_trigger(pcsrc)
    );

    mux2to1 auipc_mux(
        .input0(ex_mem_out[105:74]),
        .input1(ex_mem_out[72:41]),
        .select(ex_mem_out[8]),
        .out   (auipc_mux_out)
    );

    // MEM-WB Pipeline Register
    dff #(
        .WIDTH(117)
    ) mem_wb_reg(
        .clk_i         (clk_i),
        .reset_n_i     (reset_n_i),
        .data_i        ({ex_mem_out[154:143], // [116:105] (12 bits)
                         ex_mem_out[142:138], // [104:100] ( 5 bits)
                         data_mem_out,        // [ 99: 68] (32 bits)
                         auipc_mux_out,       // [ 67: 36] (32 bits)
                         ex_mem_out[105:74],  // [ 35:  4] (32 bits)
                         ex_mem_out[3:0]}),   // [  3:  0] ( 4 bits)
        .delayed_data_o(mem_wb_out)
    );

    mux2to1 wb_mux(
        .input0(mem_wb_out[67:36]),
        .input1(mem_wb_out[99:68]),
        .select(mem_wb_out[1]),
        .out   (wb_mux_out)
    );

    mux2to1 reg_dat_mux( //TODO cleanup
        .input0(mem_regwb_mux_out),
        .input1(id_ex_out[43:12]),
        .select(ex_mem_out[0]),
        .out   (reg_dat_mux_out)
    );

    forwarding_unit forwarding_unit(
        .rs1             (id_ex_out[160:156]),
        .rs2             (id_ex_out[165:161]),
        .MEM_RegWriteAddr(ex_mem_out[142:138]),
        .WB_RegWriteAddr (mem_wb_out[104:100]),
        .MEM_RegWrite    (ex_mem_out[2]),
        .WB_RegWrite     (mem_wb_out[2]),
        .MEM_fwd1        (mfwd1),
        .MEM_fwd2        (mfwd2),
        .WB_fwd1         (wfwd1),
        .WB_fwd2         (wfwd2)
    );

    mux2to1 mem_fwd1_mux(
        .input0(id_ex_out[75:44]),
        .input1(dataMemOut_fwd_mux_out),
        .select(mfwd1),
        .out   (mem_fwd1_mux_out)
    );

    mux2to1 mem_fwd2_mux(
        .input0(id_ex_out[107:76]),
        .input1(dataMemOut_fwd_mux_out),
        .select(mfwd2),
        .out   (mem_fwd2_mux_out)
    );

    mux2to1 wb_fwd1_mux(
        .input0(mem_fwd1_mux_out),
        .input1(wb_mux_out),
        .select(wfwd1),
        .out   (wb_fwd1_mux_out)
    );

    mux2to1 wb_fwd2_mux(
        .input0(mem_fwd2_mux_out),
        .input1(wb_mux_out),
        .select(wfwd2),
        .out   (wb_fwd2_mux_out)
    );

    mux2to1 dataMemOut_fwd_mux(
        .input0(ex_mem_out[105:74]),
        .input1(data_mem_out),
        .select(ex_mem_out[1]),
        .out   (dataMemOut_fwd_mux_out)
    );

    branch_predictor branch_predictor_FSM(
        .clk_i                 (clk_i),
        .actual_branch_decision(actual_branch_decision),
        .branch_decode_sig     (cont_mux_out[6]),
        .branch_mem_sig        (ex_mem_out[6]),
        .in_addr               (if_id_out[31:0]),
        .offset                (imm_out),
        .branch_addr           (branch_predictor_addr),
        .prediction            (predict)
    );

    mux2to1 branch_predictor_mux(
        .input0(fence_mux_out),
        .input1(branch_predictor_addr),
        .select(predict),
        .out   (branch_predictor_mux_out)
    );

    mux2to1 mistaken_branch_mux(
        .input0(branch_predictor_mux_out),
        .input1(id_ex_out[43:12]),
        .select(mistake_trigger),
        .out   (pc_mux0)
    );

    wire[31:0] mem_regwb_mux_out;
    // Copy of WB mux, but in MEM stage. Move back and cleanup
    mux2to1 mem_regwb_mux(
        .input0(auipc_mux_out),
        .input1(data_mem_out),
        .select(ex_mem_out[1]),
        .out   (mem_regwb_mux_out)
    );

    // OR gate assignments, used for flushing
    assign decode_ctrl_mux_sel = pcsrc | mistake_trigger;
    assign inst_mux_sel = pcsrc | predict | mistake_trigger | Fence_signal;

    // Instruction Memory Connections
    assign inst_mem_in = pc_out;

    // Data Memory Connections
    assign data_mem_addr = lui_result;
    assign data_mem_WrData = wb_fwd2_mux_out;
    assign data_mem_memwrite = ex_cont_mux_out[4];
    assign data_mem_memread = ex_cont_mux_out[5];
    assign data_mem_sign_mask = id_ex_out[150:147];
endmodule
