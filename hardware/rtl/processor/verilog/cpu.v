`default_nettype none
`timescale 1ns / 1ps
`include "../include/rv32i-defines.v"

module cpu(
			clk,
			inst_mem_in,
			inst_mem_out,
			data_mem_out,
			data_mem_addr,
			data_mem_WrData,
			data_mem_memwrite,
			data_mem_memread,
			data_mem_sign_mask,
			led_i,
			led_o
		);
	/*
	 *	Input Clock
	 */
	input clk;

	/*
	 *	instruction memory input
	 */
	output [31:0]		inst_mem_in;
	input [31:0]		inst_mem_out;

	/*
	 *	Data Memory
	 */
	input [31:0]		data_mem_out;
	output [13:0]		data_mem_addr;
	output [31:0]		data_mem_WrData;
	output			data_mem_memwrite;
	output			data_mem_memread;
	output [2:0]		data_mem_sign_mask;

	input  [7:0] led_i;
	output  [7:0] led_o;

	/*
	 *	Program Counter
	 */
	wire [31:0]		pc_mux0;
	wire [31:0]		pc_in;
	wire [31:0]		pc_out;
	wire			pcsrc;
	wire [31:0]		inst_mux_out;
	wire [31:0]		fence_mux_out;

	/*
	 *	Pipeline Registers
	 */
	wire [63:0]		if_id_out;
	wire [177:0]		id_ex_out;
	wire [154:0]		ex_mem_out;
	wire [116:0]		mem_wb_out;

	/*
	 *	Control signals
	 */
	wire			MemtoReg1;
	wire			RegWrite1;
	wire			MemWrite1;
	wire			MemRead1;
	wire			Branch1;
	wire			Jump1;
	wire			Jalr1;
	wire			ALUSrc1;
	wire			Lui1;
	wire			Auipc1;
	wire			Fence_signal;

	/*
	 *	Decode stage
	 */
	wire [10:0]		cont_mux_out; //control signal mux
	wire [31:0]		RegB_out;
	wire [31:0]		RegA_out;
	wire [31:0]		imm_out;
	wire [4:0]		RegA_AddrFwdFlush_mux_out;
	wire [4:0]		RegB_AddrFwdFlush_mux_out;
	wire [2:0]		dataMem_sign_mask;

	/*
	 *	Execute stage
	 */
	wire [8:0]		ex_cont_mux_out;
	wire [31:0]		addr_adder_mux_out;
	wire [31:0]		alu_mux_out;
	wire [31:0]		addr_adder_sum;
	wire [6:0]		alu_ctl;
	wire			alu_branch_enable;
	wire [31:0]		alu_result;
	wire [31:0]		lui_result;

	/*
	 *	Memory access stage
	 */
	wire [31:0]		auipc_mux_out;
	wire [31:0]		mem_out_mux_out;

	/*
	 *	Writeback to registers stage
	 */
	wire [31:0]		wb_mux_out;
	wire [31:0]		reg_dat_mux_out;

	/*
	 *	Forwarding multiplexer wires
	 */
	wire [31:0]		dataMemOut_fwd_mux_out;
	wire [31:0]		mem_fwd1_mux_out;
	wire [31:0]		mem_fwd2_mux_out;
	wire [31:0]		wb_fwd1_mux_out;
	wire [31:0]		wb_fwd2_mux_out;
	wire			mfwd1;
	wire			mfwd2;
	wire			wfwd1;
	wire			wfwd2;

	/*
	 *	Branch Predictor
	 */
	wire [31:0]		pc_adder_out;
	wire [31:0]		branch_predictor_addr;
	wire			predict;
	wire [31:0]		branch_predictor_mux_out;
	wire			actual_branch_decision;
	wire			mistake_trigger;
	wire			decode_ctrl_mux_sel;
	wire			inst_mux_sel;

	/*
	 *	Instruction Fetch Stage
	 */
	mux2to1 pc_mux(
			.input0(pc_mux0),
			.input1(ex_mem_out[72:41]),
			.select(pcsrc),
			.out(pc_in)
		);

	adder pc_adder(
			.input1(32'b100),
			.input2(pc_out),
			.out(pc_adder_out)
		);

	program_counter PC(
			.inAddr(pc_in),
			.outAddr(pc_out),
			.clk(clk)
		);

	mux2to1 inst_mux(
			.input0(inst_mem_out),
			.input1(32'b0),
			.select(inst_mux_sel),
			.out(inst_mux_out)
		);

	mux2to1 fence_mux(
			.input0(pc_adder_out),
			.input1(pc_out),
			.select(Fence_signal),
			.out(fence_mux_out)
		);

	/*
	 *	IF/ID Pipeline Register
	 */
	if_id if_id_reg(
			.clk(clk),
			.data_in({inst_mux_out, pc_out}),
			.data_out(if_id_out)
		);

	/*
	 *	Decode Stage
	 */
	control_unit control_unit_inst(
			.opcode({if_id_out[38:32]}),
			.MemtoReg(MemtoReg1),
			.RegWrite(RegWrite1),
			.MemWrite(MemWrite1),
			.MemRead(MemRead1),
			.Branch(Branch1),
			.ALUSrc(ALUSrc1),
			.Jump(Jump1),
			.Jalr(Jalr1),
			.Lui(Lui1),
			.Auipc(Auipc1),
			.Fence(Fence_signal)
		);

	mux2to1 #(
        .WIDTH(11)
    ) cont_mux(
			.input0({Jalr1, ALUSrc1, Lui1, Auipc1, Branch1, MemRead1, MemWrite1, 1'b0, RegWrite1, MemtoReg1, Jump1}),
			.input1(11'b0),
			.select(decode_ctrl_mux_sel),
			.out(cont_mux_out)
		);

	regfile register_files(
			.clk(clk),
			.write(ex_mem_out[2]),
			.wrAddr(ex_mem_out[142:138]),
			.wrData(reg_dat_mux_out),
			.rdAddrA(inst_mux_out[19:15]),
			.rdDataA(RegA_out),
			.rdAddrB(inst_mux_out[24:20]),
			.rdDataB(RegB_out)
		);

	imm_gen immediate_generator(
			.inst({if_id_out[63:37], if_id_out[35:34]}),
			.imm(imm_out)
		);

	alu_control alu_control(
			.Opcode(if_id_out[38:32]),
			.FuncCode({if_id_out[62], if_id_out[46:44]}),
			.ALUCtl(alu_ctl)
		);

	sign_mask_gen sign_mask_gen_inst(
			.func3(if_id_out[46:44]),
			.sign_mask(dataMem_sign_mask)
		);


	assign RegA_AddrFwdFlush_mux_out = if_id_out[51:47];

	assign RegB_AddrFwdFlush_mux_out = if_id_out[56:52];

	//ID/EX Pipeline Register
	id_ex id_ex_reg(
			.clk(clk),
			.data_in({if_id_out[63:52], RegB_AddrFwdFlush_mux_out, RegA_AddrFwdFlush_mux_out, if_id_out[43:39], 1'b0, dataMem_sign_mask, alu_ctl, imm_out, RegB_out, RegA_out, if_id_out[31:0], cont_mux_out[10:7], predict, cont_mux_out[6:0]}),
			.data_out(id_ex_out)
		);

	//Execute stage
	mux2to1 #(
        .WIDTH(9)
    ) ex_cont_mux(
			.input0(id_ex_out[8:0]),
			.input1(9'b0),
			.select(pcsrc),
			.out(ex_cont_mux_out)
		);

	mux2to1 addr_adder_mux(
			.input0(id_ex_out[43:12]),
			.input1(wb_fwd1_mux_out),
			.select(id_ex_out[11]),
			.out(addr_adder_mux_out)
		);

	adder addr_adder(
			.input1(addr_adder_mux_out),
			.input2(id_ex_out[139:108]),
			.out(addr_adder_sum)
		);

	mux2to1 alu_mux(
			.input0(wb_fwd2_mux_out),
			.input1(id_ex_out[139:108]),
			.select(id_ex_out[10]),
			.out(alu_mux_out)
		);

	assign led_o = led_i;
	// Uncomment for cycle counting and morse output via led
	// // Fast clock is 48 MHz
	// wire [`kCYCLE_COUNTER_WIDTH-1:0] counter_readout;
	// assign led_o[6:1] = led_i[6:1];
	// assign led_o[0] = led_o[7];
		

	// // Start counting if decimal 100 appears at ALU inputs
	// morse_encoder morse_encoder_0 (
	// 		.clk_i(clk),
	// 		.rstn_i(1'b1),
	// 		.parallel_i(counter_readout),
	// 		.send_i(led_o[2]),
	// 		.serial_o(led_o[7])
	// 	);

	// // clk counts clock cycles,
	// cycle_counter counter_clock_inst (
	// 		.clk_i(clk),
	// 		.rstn_i(1'b1),
	// 		.cycles_i('1),	// Start count at 1
	// 		.start_i(1'b1),
	// 		.enable_i(led_o[1]),
	// 		.readout_o(counter_readout)
	// 	);


	alu alu_main(
			.ALUctl(id_ex_out[146:140]),
			.A(wb_fwd1_mux_out),
			.B(alu_mux_out),
			.ALUOut(alu_result),
			.Branch_Enable(alu_branch_enable)
		);

	mux2to1 lui_mux(
			.input0(alu_result),
			.input1(id_ex_out[139:108]),
			.select(id_ex_out[9]),
			.out(lui_result)
		);

	//EX/MEM Pipeline Register
	ex_mem ex_mem_reg(
			.clk(clk),
			.data_in({id_ex_out[177:166], id_ex_out[155:151], wb_fwd2_mux_out, lui_result, alu_branch_enable, addr_adder_sum, id_ex_out[43:12], ex_cont_mux_out}),
			.data_out(ex_mem_out)
		);

	//Memory Access Stage
	branch_decide branch_decide_0(
			.Branch(ex_mem_out[6]),
			.predicted(ex_mem_out[7]),
			.branch_enable(ex_mem_out[73]),
			.Jump(ex_mem_out[0]),
			.mispredict(mistake_trigger),
			.decision(actual_branch_decision),
			.branch_jump_trigger(pcsrc)
		);

	mux2to1 auipc_mux(
			.input0(ex_mem_out[105:74]),
			.input1(ex_mem_out[72:41]),
			.select(ex_mem_out[8]),
			.out(auipc_mux_out)
		);

	//MEM/WB Pipeline Register
	mem_wb mem_wb_reg(
			.clk(clk),
			.data_in({ex_mem_out[154:143], ex_mem_out[142:138], data_mem_out, auipc_mux_out, ex_mem_out[105:74], ex_mem_out[3:0]}),
			.data_out(mem_wb_out)
		);

	//Writeback to Register Stage
	mux2to1 wb_mux(
			.input0(mem_wb_out[67:36]),
			.input1(mem_wb_out[99:68]),
			.select(mem_wb_out[1]),
			.out(wb_mux_out)
		);

	mux2to1 reg_dat_mux( //TODO cleanup
			.input0(mem_regwb_mux_out),
			.input1(id_ex_out[43:12]),
			.select(ex_mem_out[0]),
			.out(reg_dat_mux_out)
		);

	//Forwarding Unit
	forwarding_unit forwarding_unit(
			.rs1(id_ex_out[160:156]),
			.rs2(id_ex_out[165:161]),
			.MEM_RegWriteAddr(ex_mem_out[142:138]),
			.WB_RegWriteAddr(mem_wb_out[104:100]),
			.MEM_RegWrite(ex_mem_out[2]),
			.WB_RegWrite(mem_wb_out[2]),
			.MEM_fwd1(mfwd1),
			.MEM_fwd2(mfwd2),
			.WB_fwd1(wfwd1),
			.WB_fwd2(wfwd2)
		);

	mux2to1 mem_fwd1_mux(
			.input0(id_ex_out[75:44]),
			.input1(dataMemOut_fwd_mux_out),
			.select(mfwd1),
			.out(mem_fwd1_mux_out)
		);

	mux2to1 mem_fwd2_mux(
			.input0(id_ex_out[107:76]),
			.input1(dataMemOut_fwd_mux_out),
			.select(mfwd2),
			.out(mem_fwd2_mux_out)
		);

	mux2to1 wb_fwd1_mux(
			.input0(mem_fwd1_mux_out),
			.input1(wb_mux_out),
			.select(wfwd1),
			.out(wb_fwd1_mux_out)
		);

	mux2to1 wb_fwd2_mux(
			.input0(mem_fwd2_mux_out),
			.input1(wb_mux_out),
			.select(wfwd2),
			.out(wb_fwd2_mux_out)
		);

	mux2to1 dataMemOut_fwd_mux(
			.input0(ex_mem_out[105:74]),
			.input1(data_mem_out),
			.select(ex_mem_out[1]),
			.out(dataMemOut_fwd_mux_out)
		);

	//Branch Predictor
	branch_predictor branch_predictor_FSM(
			.clk(clk),
			.actual_branch_decision(actual_branch_decision),
			.branch_decode_sig(cont_mux_out[6]),
			.branch_mem_sig(ex_mem_out[6]),
			.in_addr(if_id_out[31:0]),
			.offset(imm_out),
			.branch_addr(branch_predictor_addr),
			.prediction(predict)
		);

	mux2to1 branch_predictor_mux(
			.input0(fence_mux_out),
			.input1(branch_predictor_addr),
			.select(predict),
			.out(branch_predictor_mux_out)
		);

	mux2to1 mistaken_branch_mux(
			.input0(branch_predictor_mux_out),
			.input1(id_ex_out[43:12]),
			.select(mistake_trigger),
			.out(pc_mux0)
		);

	wire[31:0] mem_regwb_mux_out; //TODO copy of wb_mux but in mem stage, move back and cleanup
	//A copy of the writeback mux, but in MEM stage //TODO move back and cleanup
	mux2to1 mem_regwb_mux(
			.input0(auipc_mux_out),
			.input1(data_mem_out),
			.select(ex_mem_out[1]),
			.out(mem_regwb_mux_out)
		);

	//OR gate assignments, used for flushing
	assign decode_ctrl_mux_sel = pcsrc | mistake_trigger;
	assign inst_mux_sel = pcsrc | predict | mistake_trigger | Fence_signal;

	//Instruction Memory Connections
	assign inst_mem_in = pc_out;

	//Data Memory Connections
	assign data_mem_addr = lui_result[13:0];
	assign data_mem_WrData = wb_fwd2_mux_out;
	assign data_mem_memwrite = ex_cont_mux_out[4];
	assign data_mem_memread = ex_cont_mux_out[5];
	assign data_mem_sign_mask = id_ex_out[149:147];
endmodule
